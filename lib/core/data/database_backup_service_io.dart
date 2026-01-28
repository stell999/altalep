import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DatabaseBackupService {
  Future<String> backup(String dbPath, {String? toDirectory}) async {
    final dir = toDirectory != null
        ? Directory(toDirectory)
        : Directory('${(await getApplicationSupportDirectory()).path}/backups');
    await dir.create(recursive: true);
    final fileName =
        'altalep_devices_backup_${DateTime.now().millisecondsSinceEpoch}.db';
    final target = File('${dir.path}/$fileName');
    final source = File(dbPath);
    await source.copy(target.path);
    return target.path;
  }

  Future<void> restore(String sourcePath, String dbPath) async {
    final source = File(sourcePath);
    final target = File(dbPath);
    if (!await source.exists()) {
      throw StateError('Backup file not found');
    }
    if (await target.exists()) {
      await target.delete();
    }
    await source.copy(dbPath);
  }
}
