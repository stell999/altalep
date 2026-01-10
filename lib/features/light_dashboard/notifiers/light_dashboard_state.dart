import '../constants/light_constants.dart';
import '../models/device.dart';
import '../models/employee.dart';

class LightDashboardState {
  const LightDashboardState({
    required this.devices,
    required this.isLoadingDevices,
    required this.devicesError,
    required this.employees,
    required this.isLoadingEmployees,
    required this.employeesError,
    required this.searchTerm,
    required this.selectedDate,
    required this.statusFilter,
    required this.employeeFilter,
    required this.departmentFilter,
    required this.statusCounts,
    required this.isSubmittingDevice,
    required this.deviceActionError,
    required this.isEmployeeOperationLoading,
    required this.employeeOperationMessage,
  });

  final List<Device> devices;
  final bool isLoadingDevices;
  final String? devicesError;
  final List<Employee> employees;
  final bool isLoadingEmployees;
  final String? employeesError;
  final String searchTerm;
  final DateTime? selectedDate;
  final String statusFilter;
  final String employeeFilter;
  final String departmentFilter;
  final Map<String, int> statusCounts;
  final bool isSubmittingDevice;
  final String? deviceActionError;
  final bool isEmployeeOperationLoading;
  final String? employeeOperationMessage;

  List<String> get employeeNames =>
      employees.map((employee) => employee.name).toList();

  factory LightDashboardState.initial() {
    return LightDashboardState(
      devices: const [],
      isLoadingDevices: false,
      devicesError: null,
      employees: const [],
      isLoadingEmployees: false,
      employeesError: null,
      searchTerm: '',
      selectedDate: null,
      statusFilter: 'الكل',
      employeeFilter: 'الكل',
      departmentFilter: 'الكل',
      statusCounts: {
        for (final status in LightConstants.statusOptions) status: 0,
      },
      isSubmittingDevice: false,
      deviceActionError: null,
      isEmployeeOperationLoading: false,
      employeeOperationMessage: null,
    );
  }

  LightDashboardState copyWith({
    List<Device>? devices,
    bool? isLoadingDevices,
    String? devicesError,
    bool clearDevicesError = false,
    List<Employee>? employees,
    bool? isLoadingEmployees,
    String? employeesError,
    bool clearEmployeesError = false,
    String? searchTerm,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    String? statusFilter,
    String? employeeFilter,
    String? departmentFilter,
    Map<String, int>? statusCounts,
    bool? isSubmittingDevice,
    String? deviceActionError,
    bool clearDeviceActionError = false,
    bool? isEmployeeOperationLoading,
    String? employeeOperationMessage,
    bool clearEmployeeOperationMessage = false,
  }) {
    return LightDashboardState(
      devices: devices ?? this.devices,
      isLoadingDevices: isLoadingDevices ?? this.isLoadingDevices,
      devicesError:
          clearDevicesError ? null : (devicesError ?? this.devicesError),
      employees: employees ?? this.employees,
      isLoadingEmployees: isLoadingEmployees ?? this.isLoadingEmployees,
      employeesError:
          clearEmployeesError ? null : (employeesError ?? this.employeesError),
      searchTerm: searchTerm ?? this.searchTerm,
      selectedDate:
          clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      statusFilter: statusFilter ?? this.statusFilter,
      employeeFilter: employeeFilter ?? this.employeeFilter,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      statusCounts: statusCounts ?? this.statusCounts,
      isSubmittingDevice: isSubmittingDevice ?? this.isSubmittingDevice,
      deviceActionError: clearDeviceActionError
          ? null
          : (deviceActionError ?? this.deviceActionError),
      isEmployeeOperationLoading:
          isEmployeeOperationLoading ?? this.isEmployeeOperationLoading,
      employeeOperationMessage: clearEmployeeOperationMessage
          ? null
          : (employeeOperationMessage ?? this.employeeOperationMessage),
    );
  }
}
