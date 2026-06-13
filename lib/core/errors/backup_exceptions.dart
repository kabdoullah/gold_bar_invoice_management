/// Thrown when the backup JSON schema version does not match
/// the current app Drift schema version.
class SchemaVersionMismatchException implements Exception {
  final int backupVersion;
  final int currentVersion;

  const SchemaVersionMismatchException({
    required this.backupVersion,
    required this.currentVersion,
  });

  @override
  String toString() =>
      'Schema version mismatch: backup=$backupVersion, current=$currentVersion';
}

/// Thrown when the backup JSON file cannot be parsed or is structurally invalid.
class CorruptedBackupException implements Exception {
  final String reason;

  const CorruptedBackupException(this.reason);

  @override
  String toString() => 'Corrupted backup file: $reason';
}
