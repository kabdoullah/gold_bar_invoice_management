/// Keys used with SharedPreferences for persistent local preferences.
abstract final class PrefsKeys {
  /// ISO 8601 UTC string of the last successful backup datetime.
  /// Null if no backup has ever been performed.
  static const String lastBackupAt = 'last_backup_at';
}
