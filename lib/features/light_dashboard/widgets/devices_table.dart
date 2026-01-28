import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/light_constants.dart';
import '../models/device.dart';

class DevicesTable extends StatelessWidget {
  const DevicesTable({
    super.key,
    required this.devices,
    required this.isLoading,
    required this.errorText,
    required this.employees,
    required this.isEmployeesLoading,
    required this.onRetry,
    required this.canModify,
    required this.onAssignEmployee,
    required this.onUpdateStatus,
    required this.onShowDetails,
    required this.onDeleteDevice,
    required this.onUpdateCost,
    required this.onPrintCompact,
  });

  final List<Device> devices;
  final bool isLoading;
  final String? errorText;
  final List<String> employees;
  final bool isEmployeesLoading;
  final Future<void> Function() onRetry;
  final bool Function(Device device) canModify;
  final Future<String?> Function(String deviceId, String employee)
      onAssignEmployee;
  final Future<String?> Function(Device device, String status) onUpdateStatus;
  final void Function(Device device) onShowDetails;
  final Future<String?> Function(String deviceId) onDeleteDevice;
  final Future<String?> Function(
    String deviceId,
    String cost,
    String costCurrency,
  ) onUpdateCost;
  final Future<String?> Function(Device device, String note) onPrintCompact;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorText != null) {
      return _ErrorState(
        message: errorText!,
        onRetry: onRetry,
      );
    }
    if (devices.isEmpty) {
      return const Center(
        child: Text('لا توجد أجهزة مطابقة للفلتر الحالي.'),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            dataRowMaxHeight: 64,
            headingTextStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('اسم الزبون')),
              DataColumn(label: Text('اسم الجهاز')),
              DataColumn(label: Text('العطل')),
              DataColumn(label: Text('التاريخ')),
              DataColumn(label: Text('الوقت')),
              DataColumn(label: Text('الموظف')),
              DataColumn(label: Text('الحالة')),
              DataColumn(label: Text('تاريخ التسليم')),
              DataColumn(label: Text('التكلفة')),
              DataColumn(label: Text('خيارات')),
            ],
            rows: [
              for (var i = 0; i < devices.length; i++)
                _buildRow(
                  context: context,
                  index: i + 1,
                  device: devices[i],
                ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildRow({
    required BuildContext context,
    required int index,
    required Device device,
  }) {
    final editable = canModify(device);
    return DataRow(
      cells: [
        DataCell(Text('$index')),
        DataCell(Text(device.formattedCustomer)),
        DataCell(Text(device.deviceName)),
        DataCell(Text(device.issue)),
        DataCell(Text(_formatDate(device))),
        DataCell(Text(_formatTime(device))),
        DataCell(_buildEmployeeCell(context, device, editable)),
        DataCell(_buildStatusCell(context, device, editable)),
        DataCell(_buildDeliveredCell(device)),
        DataCell(_buildCostCell(context, device, editable)),
        DataCell(_buildOptionsCell(context, device, editable)),
      ],
    );
  }

  Widget _buildEmployeeCell(
    BuildContext context,
    Device device,
    bool editable,
  ) {
    if (isEmployeesLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final employeeOptions = {
      '',
      ...employees,
      device.employeeName,
    }.where((name) => name.isNotEmpty).toList();
    employeeOptions.sort((a, b) => a.compareTo(b));

    if (!editable) {
      return Text(device.employeeName.isEmpty ? 'غير محدد' : device.employeeName);
    }

    return SizedBox(
      width: 140,
      child: DropdownButton<String>(
        value: device.employeeName.isEmpty ? null : device.employeeName,
        hint: const Text('اختر موظف'),
        underline: const SizedBox.shrink(),
        isExpanded: true,
        items: employeeOptions
            .map(
              (name) =>
                  DropdownMenuItem<String>(value: name, child: Text(name)),
            )
            .toList(),
        onChanged: (value) async {
          if (value == null || value == device.employeeName) return;
          final confirmed = await _confirmAction(
            context,
            'تعيين الموظف',
            'هل تريد تعيين $value على هذا الجهاز؟',
          );
          if (!confirmed) return;
          final error = await onAssignEmployee(device.id, value);
          if (!context.mounted) return;
          _showResult(context, error);
        },
      ),
    );
  }

  Widget _buildStatusCell(
    BuildContext context,
    Device device,
    bool editable,
  ) {
    if (!editable) {
      return Text(device.status);
    }

    return SizedBox(
      width: 140,
      child: DropdownButton<String>(
        value: device.status,
        underline: const SizedBox.shrink(),
        isExpanded: true,
        items: LightConstants.statusOptions
            .map(
              (status) =>
                  DropdownMenuItem<String>(value: status, child: Text(status)),
            )
            .toList(),
        onChanged: (value) async {
          if (value == null || value == device.status) return;
          final error = await onUpdateStatus(device, value);
          if (!context.mounted) return;
          _showResult(context, error);
        },
      ),
    );
  }

  Widget _buildOptionsCell(
    BuildContext context,
    Device device,
    bool editable,
  ) {
    return Wrap(
      spacing: 8,
      children: [
        FilledButton.tonal(
          onPressed: () async {
            final note = await _askNote(context);
            if (note == null) return;
            final error = await onPrintCompact(device, note);
            if (!context.mounted) return;
            _showResult(
              context,
              error,
              successMessage: 'تم إرسال أمر الطباعة',
            );
          },
          child: const Text('طباعة'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.redAccent,
          ),
          onPressed: editable
              ? () async {
                  final confirm = await _confirmAction(
                    context,
                    'حذف الجهاز',
                    'هل أنت متأكد من حذف هذا الجهاز؟',
                  );
                  if (!confirm) return;
                  final error = await onDeleteDevice(device.id);
                  if (!context.mounted) return;
                  _showResult(context, error);
                }
              : null,
          child: const Text('حذف'),
        ),
      ],
    );
  }

  Future<String?> _askNote(BuildContext context) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ملاحظة قبل الطباعة'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'اكتب ملاحظة'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }

  Widget _buildCostCell(
    BuildContext context,
    Device device,
    bool editable,
  ) {
    if (!editable) {
      final cost = device.cost.isEmpty ? '-' : device.cost;
      final currency =
          device.costCurrency.isEmpty ? '' : ' ${device.costCurrency}';
      return Text('$cost$currency');
    }

    return SizedBox(
      width: 200,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              key: ValueKey('${device.id}-cost'),
              initialValue: device.cost,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onFieldSubmitted: (value) async {
                final error = await onUpdateCost(
                  device.id,
                  value.trim(),
                  device.costCurrency.isEmpty ? 'الدولار' : device.costCurrency,
                );
                if (!context.mounted) return;
                _showResult(
                  context,
                  error,
                  successMessage: 'تم حفظ التكلفة',
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: device.costCurrency.isEmpty
                  ? 'الدولار'
                  : device.costCurrency,
              underline: const SizedBox.shrink(),
              isExpanded: true,
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
              onChanged: (value) async {
                if (value == null || value == device.costCurrency) return;
                final error = await onUpdateCost(
                  device.id,
                  device.cost,
                  value,
                );
                if (!context.mounted) return;
                _showResult(
                  context,
                  error,
                  successMessage: 'تم حفظ العملة',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveredCell(Device device) {
    if (device.deliveredDate.isEmpty) return const Text('-');
    final text = device.deliveredTime.isEmpty
        ? device.deliveredDate
        : '${device.deliveredDate} ${device.deliveredTime}';
    return Text(text);
  }

  Future<bool> _confirmAction(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showResult(
    BuildContext context,
    String? error, {
    String successMessage = 'تم تحديث البيانات بنجاح',
  }) {
    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    }
  }

  String _formatDate(Device device) {
    if (device.date.isNotEmpty) return device.date;
    final created = device.createdAt;
    if (created == null) return '-';
    return DateFormat('dd/MM/yyyy', 'ar').format(created);
  }

  String _formatTime(Device device) {
    if (device.time.isNotEmpty) return device.time;
    final created = device.createdAt;
    if (created == null) return '-';
    return DateFormat('HH:mm', 'ar').format(created);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
