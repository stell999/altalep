import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  LocalStorageService._({
    Directory? directory,
  }) : _directory = directory;

  final Directory? _directory;

  static Future<LocalStorageService> create() async {
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    return LocalStorageService._(directory: dir);
  }

  Future<List<Map<String, dynamic>>> readDevices() => _readList('devices.json');
  Future<List<Map<String, dynamic>>> readEmployees() =>
      _readList('employees.json');
  Future<List<Map<String, dynamic>>> readDailyCashEntries() =>
      _readList('daily_cash.json');

  Future<void> writeDevices(List<Map<String, dynamic>> data) =>
      _writeList('devices.json', data);
  Future<void> writeEmployees(List<Map<String, dynamic>> data) =>
      _writeList('employees.json', data);
  Future<void> writeDailyCashEntries(List<Map<String, dynamic>> data) =>
      _writeList('daily_cash.json', data);

  Future<List<Map<String, dynamic>>> _readList(String fileName) async {
    final file = await _ensureFile(fileName);
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final raw = jsonDecode(content) as List<dynamic>;
    return raw.cast<Map<String, dynamic>>();
  }

  Future<void> _writeList(
    String fileName,
    List<Map<String, dynamic>> data,
  ) async {
    final file = await _ensureFile(fileName);
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  Future<File> _ensureFile(String name) async {
    final file = File('${_directory!.path}/$name');
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('');
    }
    return file;
  }
}
