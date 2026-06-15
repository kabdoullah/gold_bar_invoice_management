import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_config.dart';

/// A backup file entry from Google Drive.
class DriveBackupFile {
  const DriveBackupFile({
    required this.driveFileId,
    required this.fileName,
    required this.createdAt,
    required this.sizeBytes,
  });

  final String driveFileId;
  final String fileName;
  final DateTime createdAt;
  final int sizeBytes;

  // Value equality keyed on the Drive file id so a selected file survives a
  // list refresh (new instances, same id compare equal).
  @override
  bool operator ==(Object other) =>
      other is DriveBackupFile && other.driveFileId == driveFileId;

  @override
  int get hashCode => driveFileId.hashCode;
}

/// Handles Google Drive authentication, upload, listing, and download.
///
/// Uses the `drive.file` scope — the app can only access files it created.
/// Folder hierarchy: `GoldInvoicesApp/backups/`.
///
/// Silent path (auto-backup): call [isAuthorizedSilently] first; if false,
/// skip the upload so no sign-in dialog appears in the background.
///
/// Interactive path (manual backup/restore): [uploadBackup], [listBackups],
/// [downloadBackup] will prompt for sign-in if needed.
class GoogleDriveService {
  static const _scopes = [drive.DriveApi.driveFileScope];
  static const _appFolderName = 'GoldInvoicesApp';
  static const _backupsFolderName = 'backups';
  static const _folderMimeType = 'application/vnd.google-apps.folder';
  static const _jsonMimeType = 'application/json';

  bool _initialized = false;

  /// Calls `initialize()` exactly once. No scopes param in v7 — scopes are
  /// requested lazily at authorization time via [_scopes].
  ///
  /// Also silently restores a previously signed-in account via
  /// [attemptLightweightAuthentication] so subsequent authorization checks
  /// reuse that session instead of popping an interactive dialog every visit.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    // Must pass the same serverClientId as main.dart — calling initialize()
    // bare on Android throws "serverClientId must be provided on Android".
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleServerClientId,
    );
    try {
      await GoogleSignIn.instance.attemptLightweightAuthentication();
    } catch (_) {
      // No restorable session — first run or signed out. The interactive
      // path will prompt once when a Drive action is taken.
    }
    _initialized = true;
  }

  /// Returns true if Drive is already authorized without prompting.
  /// Use this before silent auto-backup to avoid background sign-in dialogs.
  Future<bool> isAuthorizedSilently() async {
    try {
      await _ensureInitialized();
      final headers = await GoogleSignIn.instance.authorizationClient
          .authorizationHeaders(_scopes, promptIfNecessary: false);
      return headers != null;
    } catch (_) {
      return false;
    }
  }

  /// Runs [action] with an authenticated Drive API client, closing the
  /// underlying http client afterwards so no connection leaks.
  ///
  /// [promptIfNecessary]: shows sign-in + authorization dialogs when true.
  Future<T> _withDriveApi<T>(
    Future<T> Function(drive.DriveApi api) action, {
    bool promptIfNecessary = true,
  }) async {
    await _ensureInitialized();
    final headers = await _resolveHeaders(promptIfNecessary: promptIfNecessary);
    final client = _AuthenticatedClient(headers);
    try {
      return await action(drive.DriveApi(client));
    } finally {
      client.close();
    }
  }

  /// Resolves Drive authorization headers: silent first, then interactive
  /// authenticate + authorize when [promptIfNecessary].
  Future<Map<String, String>> _resolveHeaders({
    required bool promptIfNecessary,
  }) async {
    Map<String, String>? headers = await GoogleSignIn
        .instance.authorizationClient
        .authorizationHeaders(_scopes, promptIfNecessary: false);

    if (headers == null && promptIfNecessary) {
      final account =
          await GoogleSignIn.instance.authenticate(scopeHint: _scopes);
      headers = await account.authorizationClient
          .authorizationHeaders(_scopes, promptIfNecessary: true);
    }

    if (headers == null) {
      throw StateError('Could not obtain Drive authorization headers');
    }
    return headers;
  }

  /// Finds a Drive folder by name under [parentId], or creates it if absent.
  Future<String> _findOrCreateFolder(
    drive.DriveApi api,
    String name, {
    String? parentId,
  }) async {
    final q = StringBuffer(
      "mimeType='$_folderMimeType' and name='$name' and trashed=false",
    );
    if (parentId != null) {
      q.write(" and '$parentId' in parents");
    }

    final result = await api.files.list(
      q: q.toString(),
      spaces: 'drive',
      $fields: 'files(id)',
    );

    final files = result.files;
    if (files != null && files.isNotEmpty) {
      return files.first.id!;
    }

    final meta = drive.File()
      ..name = name
      ..mimeType = _folderMimeType
      ..parents = parentId != null ? [parentId] : null;

    final created = await api.files.create(meta, $fields: 'id');
    return created.id!;
  }

  Future<String> _getBackupsFolderId(drive.DriveApi api) async {
    final appFolderId = await _findOrCreateFolder(api, _appFolderName);
    return _findOrCreateFolder(
      api,
      _backupsFolderName,
      parentId: appFolderId,
    );
  }

  /// Uploads [backupFile] to `GoldInvoicesApp/backups/`.
  /// Returns the Drive file ID of the uploaded file.
  Future<String> uploadBackup(File backupFile) {
    return _withDriveApi((api) async {
      final folderId = await _getBackupsFolderId(api);

      final fileName = backupFile.uri.pathSegments.last;
      final bytes = await backupFile.readAsBytes();

      final meta = drive.File()
        ..name = fileName
        ..parents = [folderId]
        ..mimeType = _jsonMimeType;

      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: _jsonMimeType,
      );

      final result =
          await api.files.create(meta, uploadMedia: media, $fields: 'id');
      return result.id!;
    });
  }

  /// Lists backup files in `GoldInvoicesApp/backups/`, newest first.
  ///
  /// Silent: never prompts. If Drive isn't already authorized, returns an
  /// empty list so merely opening the backup screen never pops a sign-in
  /// dialog — only an explicit backup/restore action does.
  Future<List<DriveBackupFile>> listBackups() async {
    if (!await isAuthorizedSilently()) return const [];
    return _withDriveApi((api) async {
      final folderId = await _getBackupsFolderId(api);

      final result = await api.files.list(
        q: "'$folderId' in parents and trashed=false",
        spaces: 'drive',
        orderBy: 'createdTime desc',
        $fields: 'files(id,name,createdTime,size)',
      );

      final files = result.files ?? [];
      return files
          .where((f) => f.id != null && f.createdTime != null)
          .map(
            (f) => DriveBackupFile(
              driveFileId: f.id!,
              fileName: f.name ?? '',
              createdAt: f.createdTime!,
              sizeBytes: int.tryParse(f.size ?? '0') ?? 0,
            ),
          )
          .toList();
    }, promptIfNecessary: false);
  }

  /// Downloads the backup with [driveFileId] to a local temp file.
  Future<File> downloadBackup(String driveFileId) {
    return _withDriveApi((api) async {
      final response = await api.files.get(
        driveFileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = await _collectStream(response.stream);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/drive_restore_$driveFileId.json');
      await file.writeAsBytes(bytes);
      return file;
    });
  }

  /// Signs out the current Google account.
  Future<void> signOut() async {
    await _ensureInitialized();
    await GoogleSignIn.instance.signOut();
  }

  Future<List<int>> _collectStream(Stream<List<int>> stream) async {
    final buffer = <int>[];
    await for (final chunk in stream) {
      buffer.addAll(chunk);
    }
    return buffer;
  }
}

/// Injects pre-fetched authorization headers into every HTTP request.
class _AuthenticatedClient extends http.BaseClient {
  _AuthenticatedClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
