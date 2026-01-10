import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/light_constants.dart';
import '../data/light_department_repository.dart';
import '../domain/user_role.dart';
import '../models/device.dart';
import '../models/device_input.dart';
import '../services/device_label_service.dart';
import 'light_dashboard_state.dart';

class LightDashboardController extends StateNotifier<LightDashboardState> {
  LightDashboardController({
    required LightDepartmentRepository repository,
    required DeviceLabelService labelService,
    required this.currentDepartment,
    required this.currentUserRole,
    required this.currentUserName,
  })  : _repository = repository,
        _labelService = labelService,
        super(LightDashboardState.initial());

  final LightDepartmentRepository _repository;
  final DeviceLabelService _labelService;
  final String currentDepartment;
  final UserRole currentUserRole;
  final String currentUserName;

  bool get isAdmin => currentUserRole == UserRole.admin;

  Future<void> loadInitialData() async {
    if (!isAdmin) {
      state = state.copyWith(departmentFilter: currentDepartment);
    }
    await Future.wait([
      fetchEmployees(),
      fetchDevices(),
    ]);
  }

  Future<void> fetchEmployees() async {
    state = state.copyWith(isLoadingEmployees: true, clearEmployeesError: true);
    try {
      final employees = await _repository.fetchEmployees();
      state = state.copyWith(
        employees: employees,
        isLoadingEmployees: false,
      );
    } catch (error, stack) {
      debugPrint('Failed to load employees: $error\n$stack');
      state = state.copyWith(
        isLoadingEmployees: false,
        employeesError: 'تعذر تحميل الموظفين. حاول مرة أخرى.',
      );
    }
  }

  Future<void> fetchDevices() async {
    state = state.copyWith(isLoadingDevices: true, clearDevicesError: true);
    try {
      final devices = await _repository.fetchDevices(
        department: _resolveDepartmentQuery(),
        searchTerm: state.searchTerm,
        selectedDate: state.selectedDate,
        statusFilter: state.statusFilter,
        employeeFilter: state.employeeFilter == 'الكل'
            ? null
            : state.employeeFilter,
      );
      final statusCounts = _deriveStatusCounts(devices);
      state = state.copyWith(
        devices: devices,
        isLoadingDevices: false,
        statusCounts: statusCounts,
      );
    } catch (error, stack) {
      debugPrint('Failed to load devices: $error\n$stack');
      state = state.copyWith(
        isLoadingDevices: false,
        devicesError: 'تعذر تحميل الأجهزة. حاول التحديث.',
      );
    }
  }

  Map<String, int> _deriveStatusCounts(List<Device> devices) {
    final Map<String, int> counts = {
      for (final status in LightConstants.statusOptions) status: 0,
    };
    for (final device in devices) {
      if (counts.containsKey(device.status)) {
        counts.update(device.status, (value) => value + 1);
      }
    }
    return counts;
  }

  Future<void> onSearchTermChanged(String value) async {
    state = state.copyWith(searchTerm: value);
    await fetchDevices();
  }

  Future<void> onStatusFilterChanged(String value) async {
    state = state.copyWith(statusFilter: value);
    await fetchDevices();
  }

  Future<void> onDateSelected(DateTime? date) async {
    if (date == null) {
      state = state.copyWith(clearSelectedDate: true);
    } else {
      state = state.copyWith(selectedDate: date);
    }
    await fetchDevices();
  }

  Future<void> onEmployeeFilterChanged(String value) async {
    state = state.copyWith(employeeFilter: value);
    await fetchDevices();
  }

  Future<void> onDepartmentFilterChanged(String value) async {
    state = state.copyWith(departmentFilter: value);
    await fetchDevices();
  }

  Future<void> reloadAll() async {
    await Future.wait([fetchDevices(), fetchEmployees()]);
  }

  Future<String?> updateDepartment(String deviceId, String department) async {
    try {
      await _repository.updateDeviceDepartment(
        deviceId: deviceId,
        department: department,
      );
      final updatedDevices =
          state.devices.where((device) => device.id != deviceId).toList();
      state = state.copyWith(
        devices: updatedDevices,
        statusCounts: _deriveStatusCounts(updatedDevices),
      );
      return null;
    } catch (error) {
      return 'تعذر تحديث القسم.';
    }
  }

  Future<String?> updateEmployee(String deviceId, String employee) async {
    try {
      await _repository.assignDeviceToEmployee(
        deviceId: deviceId,
        employeeName: employee,
      );
      final updatedDevices = state.devices.map((device) {
        if (device.id == deviceId) {
          return device.copyWith(employeeName: employee);
        }
        return device;
      }).toList();
      state = state.copyWith(devices: updatedDevices);
      return null;
    } catch (error) {
      return 'تعذر تعيين الموظف.';
    }
  }

  Future<String?> updateStatus(String deviceId, String status) async {
    try {
      final now = DateTime.now();
      final deliveredDate =
          status == 'تم التسليم' ? _formatDate(now) : '';
      final deliveredTime =
          status == 'تم التسليم' ? _formatTime(now) : '';
      await _repository.updateDeviceStatus(
        deviceId: deviceId,
        status: status,
        deliveredDate: deliveredDate,
        deliveredTime: deliveredTime,
      );
      final updatedDevices = state.devices.map((device) {
        if (device.id == deviceId) {
          return device.copyWith(
            status: status,
            deliveredDate: deliveredDate,
            deliveredTime: deliveredTime,
          );
        }
        return device;
      }).toList();
      state = state.copyWith(
        devices: updatedDevices,
        statusCounts: _deriveStatusCounts(updatedDevices),
      );
      return null;
    } catch (error) {
      return 'تعذر تحديث الحالة.';
    }
  }

  Future<String?> deleteDevice(String deviceId) async {
    try {
      await _repository.deleteDevice(deviceId);
      final updatedDevices =
          state.devices.where((device) => device.id != deviceId).toList();
      state = state.copyWith(
        devices: updatedDevices,
        statusCounts: _deriveStatusCounts(updatedDevices),
      );
      return null;
    } catch (error) {
      return 'تعذر حذف الجهاز.';
    }
  }

  Future<String?> updateCost(String deviceId, String cost) async {
    try {
      await _repository.updateDeviceCost(deviceId: deviceId, cost: cost);
      final updatedDevices = state.devices.map((device) {
        if (device.id == deviceId) {
          return device.copyWith(cost: cost);
        }
        return device;
      }).toList();
      state = state.copyWith(devices: updatedDevices);
      return null;
    } catch (error) {
      return 'تعذر تحديث التكلفة.';
    }
  }

  Future<String?> printLabel(Device device) async {
    try {
      await _labelService.printDeviceLabel(device);
      return null;
    } catch (error, stack) {
      debugPrint('Failed to print label: $error\n$stack');
      return 'تعذر طباعة اللصاقة. تأكد من إعداد الطابعة.';
    }
  }

  Future<String?> migrateDeliveredDevices() async {
    if (!isAdmin) {
      return 'هذا الإجراء مخصص للمشرف فقط.';
    }
    try {
      await _repository.migrateDeliveredDevices();
      await fetchDevices();
      return null;
    } catch (error) {
      return 'لم يتم ترحيل الأجهزة. تأكد من إعداد دالة Supabase.';
    }
  }

  Future<String?> createDevice(DeviceInput input) async {
    final sanitizedInput = isAdmin
        ? input
        : DeviceInput(
            customerName: input.customerName,
            deviceName: input.deviceName,
            issue: input.issue,
            department: currentDepartment,
            employeeName: currentUserName,
            status: input.status,
            priorityColor: input.priorityColor,
            cost: input.cost,
          );
    state = state.copyWith(isSubmittingDevice: true, clearDeviceActionError: true);
    try {
      await _repository.createDevice(sanitizedInput);
      state = state.copyWith(isSubmittingDevice: false);
      await fetchDevices();
      return null;
    } catch (error) {
      state = state.copyWith(
        isSubmittingDevice: false,
        deviceActionError: 'تعذر حفظ الجهاز. حاول مرة أخرى.',
      );
      return state.deviceActionError;
    }
  }

  Future<String?> addEmployee({
    required String name,
    required String department,
  }) async {
    if (!isAdmin) {
      return 'صلاحية المشرف فقط.';
    }
    state = state.copyWith(
      isEmployeeOperationLoading: true,
      clearEmployeeOperationMessage: true,
    );
    try {
      await _repository.addEmployee(name: name, department: department);
      await fetchEmployees();
      state = state.copyWith(
        isEmployeeOperationLoading: false,
        employeeOperationMessage: 'تمت إضافة الموظف.',
      );
      return null;
    } catch (error) {
      state = state.copyWith(
        isEmployeeOperationLoading: false,
        employeeOperationMessage: 'تعذر إضافة الموظف.',
      );
      return state.employeeOperationMessage;
    }
  }

  Future<String?> updateEmployeeDepartmentAction({
    required String employeeId,
    required String department,
  }) async {
    if (!isAdmin) {
      return 'صلاحية المشرف فقط.';
    }
    state = state.copyWith(isEmployeeOperationLoading: true);
    try {
      await _repository.updateEmployeeDepartment(
        employeeId: employeeId,
        department: department,
      );
      await fetchEmployees();
      state = state.copyWith(
        isEmployeeOperationLoading: false,
        employeeOperationMessage: 'تم تحديث القسم.',
      );
      return null;
    } catch (error) {
      state = state.copyWith(
        isEmployeeOperationLoading: false,
        employeeOperationMessage: 'تعذر تعديل القسم.',
      );
      return state.employeeOperationMessage;
    }
  }

  Future<String?> deleteEmployeeAction(String employeeId) async {
    if (!isAdmin) {
      return 'صلاحية المشرف فقط.';
    }
    state = state.copyWith(isEmployeeOperationLoading: true);
    try {
      await _repository.deleteEmployee(employeeId);
      await fetchEmployees();
      state = state.copyWith(
        isEmployeeOperationLoading: false,
        employeeOperationMessage: 'تم حذف الموظف.',
      );
      return null;
    } catch (error) {
      state = state.copyWith(
        isEmployeeOperationLoading: false,
        employeeOperationMessage: 'تعذر حذف الموظف.',
      );
      return state.employeeOperationMessage;
    }
  }

  bool canModify(Device device) {
    if (isAdmin) return true;
    return device.employeeName == currentUserName;
  }

  String? _resolveDepartmentQuery() {
    if (!isAdmin) return currentDepartment;
    if (state.departmentFilter == 'الكل') {
      return null;
    }
    return state.departmentFilter;
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
