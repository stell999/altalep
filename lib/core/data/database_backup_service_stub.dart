class DatabaseBackupService {
  Future<String> backup(String dbPath, {String? toDirectory}) async {
    throw UnsupportedError('Database backup not supported on web.');
  }

  Future<void> restore(String sourcePath, String dbPath) async {
    throw UnsupportedError('Database restore not supported on web.');
  }
}
