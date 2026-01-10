import 'dart:async';
import 'dart:math';

import '../models/device.dart';
import '../models/device_input.dart';
import '../models/employee.dart';
import '../services/local_storage_service.dart';

class LightDepartmentRepository {
  LightDepartmentRepository() : _storageFuture = LocalStorageService.create();

  final Future<LocalStorageService> _storageFuture;
  final List<Device> _devices = [];
  final List<Employee> _employees = [];
  int _deviceCounter = 1;
  int _employeeCounter = 1;
  bool _isInitialized = false;

  Future<List<Device>> fetchDevices({
    String? department,
    String? searchTerm,
    DateTime? selectedDate,
    String? statusFilter,
    String? employeeFilter,
  }) async {
    await _ensureInitialized();
    final filtered =
        _devices.where((device) {
          final matchesDepartment =
              department == null ||
              department == 'الكل' ||
              device.department == department;
          final matchesSearch =
              searchTerm == null ||
              searchTerm.isEmpty ||
              device.customerName.contains(searchTerm);
          final matchesStatus =
              statusFilter == null ||
              statusFilter == 'الكل' ||
              device.status == statusFilter;
          final matchesEmployee =
              employeeFilter == null ||
              employeeFilter == 'الكل' ||
              device.employeeName == employeeFilter;
          final matchesDate =
              selectedDate == null ||
              (device.createdAt != null &&
                  device.createdAt!.year == selectedDate.year &&
                  device.createdAt!.month == selectedDate.month &&
                  device.createdAt!.day == selectedDate.day);
          return matchesDepartment &&
              matchesSearch &&
              matchesStatus &&
              matchesEmployee &&
              matchesDate;
        }).toList()..sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );
    return List<Device>.unmodifiable(filtered);
  }

  Future<List<Employee>> fetchEmployees() async {
    await _ensureInitialized();
    return List<Employee>.unmodifiable(_employees);
  }

  Future<void> updateDeviceDepartment({
    required String deviceId,
    required String department,
  }) async {
    await _ensureInitialized();
    _replaceDevice(
      deviceId,
      (device) => device.copyWith(department: department),
    );
    await _persistDevices();
  }

  Future<void> assignDeviceToEmployee({
    required String deviceId,
    required String employeeName,
  }) async {
    await _ensureInitialized();
    _replaceDevice(
      deviceId,
      (device) => device.copyWith(employeeName: employeeName),
    );
    await _persistDevices();
  }

  Future<void> updateDeviceStatus({
    required String deviceId,
    required String status,
    String? deliveredDate,
    String? deliveredTime,
  }) async {
    await _ensureInitialized();
    _replaceDevice(
      deviceId,
      (device) => device.copyWith(
        status: status,
        deliveredDate: deliveredDate ?? '',
        deliveredTime: deliveredTime ?? '',
      ),
    );
    await _persistDevices();
  }

  Future<Device> createDevice(DeviceInput input) async {
    await _ensureInitialized();
    final now = DateTime.now();
    final device = Device(
      id: '${_deviceCounter++}',
      customerName: input.customerName,
      deviceName: input.deviceName,
      issue: input.issue,
      department: input.department,
      employeeName: input.employeeName,
      status: input.status,
      priorityColor: input.priorityColor,
      date: _formatDate(now),
      time: _formatTime(now),
      deliveredDate: '',
      deliveredTime: '',
      cost: input.cost,
      createdAt: now,
    );
    _devices.insert(0, device);
    await _persistDevices();
    return device;
  }

  Future<void> deleteDevice(String deviceId) async {
    await _ensureInitialized();
    _devices.removeWhere((device) => device.id == deviceId);
    await _persistDevices();
  }

  Future<void> updateDeviceCost({
    required String deviceId,
    required String cost,
  }) async {
    await _ensureInitialized();
    _replaceDevice(deviceId, (device) => device.copyWith(cost: cost));
    await _persistDevices();
  }

  Future<void> migrateDeliveredDevices() async {
    await _ensureInitialized();
    _devices.removeWhere((device) => device.status == 'تم التسليم');
    await _persistDevices();
  }

  Future<void> addEmployee({
    required String name,
    required String department,
  }) async {
    await _ensureInitialized();
    final employee = Employee(
      id: '${_employeeCounter++}',
      name: name,
      department: department,
    );
    _employees.add(employee);
    await _persistEmployees();
  }

  Future<void> deleteEmployee(String employeeId) async {
    await _ensureInitialized();
    _employees.removeWhere((employee) => employee.id == employeeId);
    await _persistEmployees();
  }

  Future<void> updateEmployeeDepartment({
    required String employeeId,
    required String department,
  }) async {
    await _ensureInitialized();
    final index = _employees.indexWhere(
      (employee) => employee.id == employeeId,
    );
    if (index == -1) return;
    final updated = _employees[index].copyWith(department: department);
    _employees[index] = updated;
    await _persistEmployees();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    final storage = await _storageFuture;
    final savedDevices = await storage.readDevices();
    final savedEmployees = await storage.readEmployees();

    _devices
      ..clear()
      ..addAll(savedDevices.map(Device.fromJson));
    _employees
      ..clear()
      ..addAll(savedEmployees.map(Employee.fromJson));

    _deviceCounter = _nextId(_devices.map((device) => device.id));
    _employeeCounter = _nextId(_employees.map((employee) => employee.id));
    _isInitialized = true;
  }

  int _nextId(Iterable<String> ids) {
    if (ids.isEmpty) return 1;
    final highest = ids
        .map((id) => int.tryParse(id) ?? 0)
        .fold<int>(0, (previous, element) => max(previous, element));
    return highest + 1;
  }

  Future<void> _persistDevices() async {
    final storage = await _storageFuture;
    await storage.writeDevices(
      _devices.map((device) => device.toJson()).toList(),
    );
  }

  Future<void> _persistEmployees() async {
    final storage = await _storageFuture;
    await storage.writeEmployees(
      _employees.map((employee) => employee.toJson()).toList(),
    );
  }

  void _replaceDevice(String id, Device Function(Device device) transformer) {
    final index = _devices.indexWhere((device) => device.id == id);
    if (index == -1) return;
    _devices[index] = transformer(_devices[index]);
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
