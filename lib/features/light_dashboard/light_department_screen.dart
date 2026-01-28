import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/daily_cash_entry.dart';
import '../../core/providers/daily_cash_provider.dart';
import 'domain/user_role.dart';
import 'models/device.dart';
import 'notifiers/light_dashboard_controller.dart';
import 'providers.dart';
import 'widgets/device_filters.dart';
import 'widgets/device_entry_form.dart';
import 'widgets/devices_table.dart';
import 'widgets/employee_management_panel.dart';
import 'widgets/light_sidebar.dart';
import 'widgets/password_dialog.dart';
import '../pos_dashboard/pos_dashboard_screen.dart';

class LightDepartmentScreen extends ConsumerStatefulWidget {
  const LightDepartmentScreen({
    super.key,
    required this.currentUserName,
    required this.currentUserRole,
    required this.initialDepartment,
    required this.onNavigateHome,
  });

  final String currentUserName;
  final UserRole currentUserRole;
  final String initialDepartment;
  final VoidCallback onNavigateHome;

  @override
  ConsumerState<LightDepartmentScreen> createState() =>
      _LightDepartmentScreenState();
}

class _LightDepartmentScreenState
    extends ConsumerState<LightDepartmentScreen> {
  late final TextEditingController _searchController;
  bool _showAddDeviceForm = false;
  bool _showEmployeePanel = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = LightDashboardArgs(
      department: widget.initialDepartment,
      userRole: widget.currentUserRole,
      userName: widget.currentUserName,
    );
    final state = ref.watch(lightDashboardControllerProvider(args));
    final controller =
        ref.read(lightDashboardControllerProvider(args).notifier);

    if (_searchController.text != state.searchTerm) {
      _searchController.value = _searchController.value.copyWith(
        text: state.searchTerm,
        selection:
            TextSelection.collapsed(offset: state.searchTerm.length),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 256,
              child: LightSidebar(
                currentDepartment: widget.initialDepartment,
                isAdminView: controller.isAdmin,
                statusCounts: state.statusCounts,
                onNavigateBack: controller.isAdmin
                    ? () => _handleBackToDashboard()
                    : null,
                onOpenPosDashboardTab: (tab) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PosDashboardScreen(initialTab: tab),
                    ),
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: SizedBox(
                          height: 120,
                          child: Image.asset(
                            AppTheme.logoAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.lightbulb, size: 64),
                          ),
                        ),
                      ),
                    ),
                    _buildTopActions(context, controller),
                    const SizedBox(height: 16),
                    if (_showEmployeePanel)
                      Expanded(
                        child: EmployeeManagementPanel(
                          employees: state.employees,
                          isLoading: state.isLoadingEmployees,
                          isProcessing: state.isEmployeeOperationLoading,
                          statusMessage: state.employeeOperationMessage,
                          onAddEmployee: (name, department) =>
                              controller.addEmployee(
                            name: name,
                            department: department,
                          ),
                          onUpdateDepartment: (id, department) =>
                              controller.updateEmployeeDepartmentAction(
                            employeeId: id,
                            department: department,
                          ),
                          onDeleteEmployee: (id) =>
                              controller.deleteEmployeeAction(id),
                        ),
                      )
                    else
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DeviceFilters(
                              searchController: _searchController,
                              onSearchChanged: (value) =>
                                  controller.onSearchTermChanged(value),
                              onDateSelected: (date) =>
                                  controller.onDateSelected(date),
                              onStatusChanged: (value) =>
                                  controller.onStatusFilterChanged(value),
                              onEmployeeChanged: (value) =>
                                  controller.onEmployeeFilterChanged(value),
                              onDepartmentChanged: (value) =>
                                  controller.onDepartmentFilterChanged(value),
                              selectedDate: state.selectedDate,
                              statusFilter: state.statusFilter,
                              employeeFilter: state.employeeFilter,
                              departmentFilter: state.departmentFilter,
                              employeeNames: state.employeeNames,
                              showDepartmentFilter: controller.isAdmin,
                            ),
                            const SizedBox(height: 16),
                            DeviceEntryForm(
                              isVisible: _showAddDeviceForm,
                              isSubmitting: state.isSubmittingDevice,
                              errorText: state.deviceActionError,
                              onSubmit: controller.createDevice,
                              employeeNames: state.employeeNames,
                              defaultDepartment: controller.isAdmin &&
                                      state.departmentFilter != 'الكل'
                                  ? state.departmentFilter
                                  : widget.initialDepartment,
                              isAdmin: controller.isAdmin,
                              currentUserName: widget.currentUserName,
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: DevicesTable(
                                devices: state.devices,
                                isLoading: state.isLoadingDevices,
                                errorText: state.devicesError,
                                employees: state.employeeNames,
                                isEmployeesLoading: state.isLoadingEmployees,
                                onRetry: controller.fetchDevices,
                                canModify: controller.canModify,
                                onAssignEmployee: controller.updateEmployee,
                                onUpdateStatus: (device, status) =>
                                    _handleStatusChange(
                                      context,
                                      controller,
                                      device,
                                      status,
                                    ),
                                onShowDetails: (device) =>
                                    _showDeviceDetails(context, controller, device),
                                onDeleteDevice: controller.deleteDevice,
                                onUpdateCost: controller.updateCost,
                                onPrintCompact: (device, note) =>
                                    controller.printCompactLabel(device, note),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActions(
    BuildContext context,
    LightDashboardController controller,
  ) {
    final title = _showEmployeePanel ? 'إدارة الموظفين' : 'الأجهزة المستلمة';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: () {
                setState(() {
                  _showEmployeePanel = false;
                  _showAddDeviceForm = false;
                });
                controller.fetchDevices();
              },
              child: const Text('عرض القائمة'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _showEmployeePanel = false;
                  _showAddDeviceForm = !_showAddDeviceForm;
                });
              },
              child: Text(_showAddDeviceForm ? 'إخفاء النموذج' : 'إضافة جهاز'),
            ),
            if (controller.isAdmin)
              FilledButton.tonal(
                onPressed: () {
                  setState(() {
                    _showEmployeePanel = !_showEmployeePanel;
                    _showAddDeviceForm = false;
                  });
                },
                child: Text(
                  _showEmployeePanel ? 'عرض الأجهزة' : 'إدارة الموظفين',
                ),
              ),
            if (controller.isAdmin)
              FilledButton.icon(
                onPressed: () async {
                  final path = await controller.migrateDeliveredDevices();
                  if (!context.mounted) return;
                  if (path == null) {
                    _showSnack(context, 'تعذر إنشاء النسخة الاحتياطية', true);
                  } else {
                    _showSnack(context, 'تم حفظ النسخة الاحتياطية: $path', false);
                  }
                },
                icon: const Icon(Icons.backup),
                label: const Text('نسخ احتياطي للأجهزة (Excel/CSV)'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleBackToDashboard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PasswordDialog(requiredPassword: 'admin'),
    );
    if (confirmed == true) {
      widget.onNavigateHome();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الخروج إلى لوحة التحكم')),
        );
      }
    }
  }

  Future<String?> _handleStatusChange(
    BuildContext context,
    LightDashboardController controller,
    Device device,
    String status,
  ) async {
    if (status != 'تم التسليم') {
      return controller.updateStatus(device.id, status);
    }

    final result = await _showDeliveryCostDialog(context, device);
    if (result == null) {
      return 'تم إلغاء تحديث الحالة';
    }

    final updatedCost = result.useOriginal ? device.cost : result.cost;
    final updatedCurrency =
        result.useOriginal ? device.costCurrency : result.currency;

    final cost = updatedCost.trim().isEmpty ? '0' : updatedCost.trim();
    final currency = updatedCurrency.trim().isEmpty
        ? 'الدولار'
        : updatedCurrency.trim();

    if (cost != device.cost || currency != device.costCurrency) {
      final costError = await controller.updateCost(
        device.id,
        cost,
        currency,
      );
      if (costError != null) return costError;
    }

    final statusError = await controller.updateStatus(device.id, status);
    if (statusError != null) return statusError;

    final entry = DailyCashEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      currency: currency,
      receipt: cost,
      payment: '0',
      description: 'تسليم جهاز #${device.id} - ${device.deviceName}',
      createdAt: DateTime.now(),
    );
    await ref.read(dailyCashControllerProvider.notifier).addEntry(entry);

    return null;
  }

  Future<_DeliveryCostResult?> _showDeliveryCostDialog(
    BuildContext context,
    Device device,
  ) async {
    final costController = TextEditingController(text: device.cost);
    var currency =
        device.costCurrency.isEmpty ? 'الدولار' : device.costCurrency;

    final result = await showDialog<_DeliveryCostResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تأكيد تكلفة التسليم'),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'التكلفة',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey(currency),
                      initialValue: currency,
                      decoration: const InputDecoration(
                        labelText: 'عملة التكلفة',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'الدولار',
                          child: Text('الدولار'),
                        ),
                        DropdownMenuItem(
                          value: 'التركي',
                          child: Text('التركي'),
                        ),
                        DropdownMenuItem(
                          value: 'سوري',
                          child: Text('سوري'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          currency = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _DeliveryCostResult(
                        cost: device.cost,
                        currency: device.costCurrency,
                        useOriginal: true,
                      ),
                    );
                  },
                  child: const Text('تأكيد نفس الرقم'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _DeliveryCostResult(
                        cost: costController.text.trim(),
                        currency: currency,
                        useOriginal: false,
                      ),
                    );
                  },
                  child: const Text('تعديل الرقم'),
                ),
              ],
            );
          },
        );
      },
    );

    costController.dispose();
    return result;
  }

  Future<void> _showDeviceDetails(
    BuildContext context,
    LightDashboardController controller,
    Device device,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تفاصيل ${device.deviceName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('اسم الزبون', device.customerName),
              _detailRow('القسم', device.department),
              _detailRow('الحالة', device.status),
              _detailRow('العطل', device.issue),
              _detailRow(
                'التكلفة',
                device.cost.isEmpty
                    ? '-'
                    : '${device.cost} ${device.costCurrency}',
              ),
            ],
          ),
          actions: [
            FilledButton.tonal(
              onPressed: () async {
                final error = await controller.printLabel(device);
                if (!context.mounted) return;
                _showSnack(
                  context,
                  error ?? 'تم إرسال أمر الطباعة',
                  error != null,
                );
              },
              child: const Text('طباعة'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.redAccent : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _DeliveryCostResult {
  const _DeliveryCostResult({
    required this.cost,
    required this.currency,
    required this.useOriginal,
  });

  final String cost;
  final String currency;
  final bool useOriginal;
}
