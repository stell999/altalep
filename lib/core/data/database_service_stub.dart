class DatabaseService {
  DatabaseService._();
  static Future<DatabaseService> create() async {
    throw UnsupportedError('DatabaseService not supported on web.');
  }
}
