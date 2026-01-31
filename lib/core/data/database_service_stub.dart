import '../../features/light_dashboard/models/device.dart';
import '../../features/light_dashboard/models/device_input.dart';

class DatabaseService {
  DatabaseService._();
  
  String get dbPath => '';

  static Future<DatabaseService> create() async {
    throw UnsupportedError('DatabaseService not supported on web.');
  }

  Future<List<Device>> queryDevices({
    String? department,
    String? searchTerm,
    DateTime? selectedDate,
    String? statusFilter,
    String? employeeFilter,
    int? limit,
    int? offset,
  }) async => [];

  Future<Device> insertDevice(DeviceInput input, DateTime now) async {
    throw UnimplementedError();
  }

  Future<void> updateDeviceDepartment(String id, String department) async {}

  Future<void> assignDeviceToEmployee(String id, String employee) async {}

  Future<void> updateDeviceStatus(String id, String status, {String? deliveredDate, String? deliveredTime}) async {}

  Future<void> updateDeviceCost(String id, String cost, String currency) async {}

  Future<void> deleteDevice(String id) async {}

  Future<List<Map<String, Object?>>> queryScreenBoards({
    String? searchTerm,
  }) async => [];

  Future<int> insertScreenBoard({
    required String board,
    required String model,
    required int quantity,
    required double unitUsd,
    required int sold,
    required String notes,
  }) async => 0;

  Future<void> updateScreenBoardQtySold({
    required int id,
    required int quantity,
    required int sold,
  }) async {}
}
