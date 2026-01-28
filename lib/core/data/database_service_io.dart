import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/light_dashboard/models/device.dart';
import '../../features/light_dashboard/models/device_input.dart';

class DatabaseService {
  DatabaseService._(this._db, this._path);
  final Database _db;
  final String _path;
  String get dbPath => _path;

  static Future<DatabaseService> create() async {
    final dir = await getApplicationSupportDirectory();
    final path = '${dir.path}/altalep_devices.db';
    final db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE devices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT,
            device_name TEXT,
            issue TEXT,
            department TEXT,
            employee_name TEXT,
            status TEXT,
            priority_color TEXT,
            date TEXT,
            time TEXT,
            delivered_date TEXT,
            delivered_time TEXT,
            cost TEXT,
            cost_currency TEXT,
            created_at TEXT
          );
          ''');
          await db.execute('CREATE INDEX idx_devices_department ON devices(department);');
          await db.execute('CREATE INDEX idx_devices_status ON devices(status);');
          await db.execute('CREATE INDEX idx_devices_employee ON devices(employee_name);');
          await db.execute('CREATE INDEX idx_devices_created ON devices(created_at);');
          await db.execute('''
          CREATE TABLE screen_boards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            board TEXT,
            model TEXT,
            quantity INTEGER,
            unit_usd REAL,
            sold INTEGER,
            notes TEXT
          );
          ''');
          await db.execute('CREATE INDEX idx_screen_boards_board ON screen_boards(board);');
          await db.execute('CREATE INDEX idx_screen_boards_model ON screen_boards(model);');
        },
      ),
    );
    return DatabaseService._(db, path);
  }

  Future<List<Device>> queryDevices({
    String? department,
    String? searchTerm,
    DateTime? selectedDate,
    String? statusFilter,
    String? employeeFilter,
    int? limit,
    int? offset,
  }) async {
    final where = <String>[];
    final args = <Object?>[];
    if (department != null && department != 'الكل') {
      where.add('department = ?');
      args.add(department);
    }
    final trimmedSearch = (searchTerm ?? '').trim();
    if (trimmedSearch.isNotEmpty) {
      final normalized = trimmedSearch.replaceAll('#', '').trim();
      where.add('(customer_name LIKE ? OR CAST(id AS TEXT) LIKE ?)');
      args.add('%$trimmedSearch%');
      args.add('%$normalized%');
    }
    if (statusFilter != null && statusFilter != 'الكل') {
      where.add('status = ?');
      args.add(statusFilter);
    }
    if (employeeFilter != null && employeeFilter != 'الكل') {
      where.add('employee_name = ?');
      args.add(employeeFilter);
    }
    if (selectedDate != null) {
      final y = selectedDate.year.toString().padLeft(4, '0');
      final m = selectedDate.month.toString().padLeft(2, '0');
      final d = selectedDate.day.toString().padLeft(2, '0');
      where.add('date = ?');
      args.add('$y-$m-$d');
    }
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final lim = limit != null ? 'LIMIT $limit' : '';
    final off = offset != null ? 'OFFSET $offset' : '';
    final rows = await _db.rawQuery('''
      SELECT * FROM devices
      $whereClause
      ORDER BY created_at DESC
      $lim
      $off
    ''', args);
    return rows.map(_mapRowToDevice).toList();
  }

  Future<Device> insertDevice(DeviceInput input, DateTime now) async {
    final date = _formatDate(now);
    final time = _formatTime(now);
    final id = await _db.insert('devices', {
      'customer_name': input.customerName,
      'device_name': input.deviceName,
      'issue': input.issue,
      'department': input.department,
      'employee_name': input.employeeName,
      'status': input.status,
      'priority_color': input.priorityColor,
      'date': date,
      'time': time,
      'delivered_date': '',
      'delivered_time': '',
      'cost': input.cost,
      'cost_currency': input.costCurrency,
      'created_at': now.toIso8601String(),
    });
    return Device(
      id: '$id',
      customerName: input.customerName,
      deviceName: input.deviceName,
      issue: input.issue,
      department: input.department,
      employeeName: input.employeeName,
      status: input.status,
      priorityColor: input.priorityColor,
      date: date,
      time: time,
      deliveredDate: '',
      deliveredTime: '',
      cost: input.cost,
      costCurrency: input.costCurrency,
      createdAt: now,
    );
  }

  Future<void> updateDeviceDepartment(String id, String department) async {
    await _db.update('devices', {'department': department}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> assignDeviceToEmployee(String id, String employee) async {
    await _db.update('devices', {'employee_name': employee}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateDeviceStatus(String id, String status, {String? deliveredDate, String? deliveredTime}) async {
    await _db.update('devices', {
      'status': status,
      'delivered_date': deliveredDate ?? '',
      'delivered_time': deliveredTime ?? '',
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateDeviceCost(String id, String cost, String currency) async {
    await _db.update('devices', {
      'cost': cost,
      'cost_currency': currency,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteDevice(String id) async {
    await _db.delete('devices', where: 'id = ?', whereArgs: [id]);
  }

  Device _mapRowToDevice(Map<String, Object?> row) {
    return Device(
      id: '${row['id']}',
      customerName: (row['customer_name'] ?? '') as String,
      deviceName: (row['device_name'] ?? '') as String,
      issue: (row['issue'] ?? '') as String,
      department: (row['department'] ?? '') as String,
      employeeName: (row['employee_name'] ?? '') as String,
      status: (row['status'] ?? '') as String,
      priorityColor: (row['priority_color'] ?? '') as String,
      date: (row['date'] ?? '') as String,
      time: (row['time'] ?? '') as String,
      deliveredDate: (row['delivered_date'] ?? '') as String,
      deliveredTime: (row['delivered_time'] ?? '') as String,
      cost: (row['cost'] ?? '') as String,
      costCurrency: (row['cost_currency'] ?? 'الدولار') as String,
      createdAt: (row['created_at'] == null)
          ? null
          : DateTime.tryParse('${row['created_at']}'),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  Future<List<Map<String, Object?>>> queryScreenBoards({
    String? searchTerm,
  }) async {
    final where = <String>[];
    final args = <Object?>[];
    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      final s = searchTerm.trim().toLowerCase();
      where.add('(LOWER(board) LIKE ? OR LOWER(model) LIKE ?)');
      args.add('%$s%');
      args.add('%$s%');
    }
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    return _db.rawQuery('SELECT * FROM screen_boards $whereClause ORDER BY id DESC', args);
  }

  Future<int> insertScreenBoard({
    required String board,
    required String model,
    required int quantity,
    required double unitUsd,
    required int sold,
    required String notes,
  }) async {
    return _db.insert('screen_boards', {
      'board': board,
      'model': model,
      'quantity': quantity,
      'unit_usd': unitUsd,
      'sold': sold,
      'notes': notes,
    });
  }

  Future<void> updateScreenBoardQtySold({
    required int id,
    required int quantity,
    required int sold,
  }) async {
    await _db.update(
      'screen_boards',
      {
        'quantity': quantity,
        'sold': sold,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
