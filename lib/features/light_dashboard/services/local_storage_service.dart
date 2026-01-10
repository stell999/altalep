import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  LocalStorageService._({
    Directory? directory,
    Map<String, List<Map<String, dynamic>>>? memoryStore,
  }) : _directory = directory,
       _memoryStore = memoryStore ?? {};

  final Directory? _directory;
  final Map<String, List<Map<String, dynamic>>> _memoryStore;

  static Future<LocalStorageService> create() async {
    try {
      final dir = await getApplicationSupportDirectory();
      await dir.create(recursive: true);
      return LocalStorageService._(directory: dir);
    } catch (error, stack) {
      debugPrint('Local storage fallback to memory: $error\n$stack');
      return LocalStorageService._();
    }
  }

  Future<List<Map<String, dynamic>>> readDevices() => _readList('devices.json');

  Future<List<Map<String, dynamic>>> readEmployees() =>
      _readList('employees.json');

  Future<void> writeDevices(List<Map<String, dynamic>> data) =>
      _writeList('devices.json', data);

  Future<void> writeEmployees(List<Map<String, dynamic>> data) =>
      _writeList('employees.json', data);

  Future<List<Map<String, dynamic>>> _readList(String fileName) async {
    if (_directory == null) {
      return List<Map<String, dynamic>>.from(_memoryStore[fileName] ?? []);
    }
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
    if (_directory == null) {
      _memoryStore[fileName] = data
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      return;
    }
    final file = await _ensureFile(fileName);
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  Future<File> _ensureFile(String name) async {
    if (_directory == null) {
      throw StateError('No directory available for file storage.');
    }
    final file = File('${_directory.path}/$name');
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('');
    }
    return file;
  }
}
