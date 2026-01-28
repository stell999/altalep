import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LocalStorageService {
  LocalStorageService._();

  static Future<LocalStorageService> create() async {
    return LocalStorageService._();
  }

  Future<List<Map<String, dynamic>>> readDevices() =>
      _readList('devices.json');
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

  Future<List<Map<String, dynamic>>> _readList(String key) async {
    final content = html.window.localStorage[key] ?? '';
    if (content.trim().isEmpty) return [];
    final raw = jsonDecode(content) as List<dynamic>;
    return raw.cast<Map<String, dynamic>>();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> data) async {
    html.window.localStorage[key] = jsonEncode(data);
  }
}
