import 'package:flutter/material.dart';

import '../constants/light_constants.dart';
import '../models/employee.dart';

class EmployeeManagementPanel extends StatefulWidget {
  const EmployeeManagementPanel({
    super.key,
    required this.employees,
    required this.isLoading,
    required this.isProcessing,
    required this.statusMessage,
    required this.onAddEmployee,
    required this.onUpdateDepartment,
    required this.onDeleteEmployee,
  });

  final List<Employee> employees;
  final bool isLoading;
  final bool isProcessing;
  final String? statusMessage;
  final Future<String?> Function(String name, String department) onAddEmployee;
  final Future<String?> Function(String id, String department)
      onUpdateDepartment;
  final Future<String?> Function(String id) onDeleteEmployee;

  @override
  State<EmployeeManagementPanel> createState() =>
      _EmployeeManagementPanelState();
}

class _EmployeeManagementPanelState extends State<EmployeeManagementPanel> {
  final _nameCtrl = TextEditingController();
  String _department = LightConstants.departments.first;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'إدارة الموظفين',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildAddForm(context),
            const Divider(height: 32),
            if (widget.statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(widget.statusMessage!),
              ),
            if (widget.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildEmployeeTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAddForm(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 240,
          child: TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'اسم الموظف',
            ),
          ),
        ),
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String>(
            initialValue: _department,
            decoration: const InputDecoration(labelText: 'القسم'),
            items: LightConstants.departments
                .map(
                  (dept) => DropdownMenuItem(
                    value: dept,
                    child: Text(dept),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _department = value);
            },
          ),
        ),
        FilledButton(
          onPressed:
              widget.isProcessing ? null : () => _handleAddEmployee(context),
          child: widget.isProcessing
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('إضافة موظف'),
        ),
      ],
    );
  }

  Widget _buildEmployeeTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('اسم الموظف')),
          DataColumn(label: Text('القسم')),
          DataColumn(label: Text('تحكم')),
        ],
        rows: [
          for (var i = 0; i < widget.employees.length; i++)
            DataRow(
              cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text(widget.employees[i].name)),
                DataCell(Text(widget.employees[i].department)),
                DataCell(
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: widget.isProcessing
                            ? null
                            : () => _showDepartmentDialog(
                                  context,
                                  widget.employees[i],
                                ),
                        child: const Text('تعديل القسم'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: widget.isProcessing
                            ? null
                            : () => _handleDeleteEmployee(
                                  context,
                                  widget.employees[i],
                                ),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _handleAddEmployee(BuildContext context) async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم الموظف.')),
      );
      return;
    }
    final error = await widget.onAddEmployee(
      _nameCtrl.text.trim(),
      _department,
    );
    if (error == null) {
      _nameCtrl.clear();
    }
  }

  Future<void> _handleDeleteEmployee(
    BuildContext context,
    Employee employee,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الموظف'),
        content: Text('هل تريد حذف ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.onDeleteEmployee(employee.id);
    }
  }

  Future<void> _showDepartmentDialog(
    BuildContext context,
    Employee employee,
  ) async {
    var selectedDepartment = employee.department;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('تعديل قسم ${employee.name}'),
              content: DropdownButton<String>(
                value: selectedDepartment,
                items: LightConstants.departments
                    .map(
                      (dept) => DropdownMenuItem(
                        value: dept,
                        child: Text(dept),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setStateDialog(() => selectedDepartment = value);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
    if (confirmed == true) {
      await widget.onUpdateDepartment(employee.id, selectedDepartment);
    }
  }
}
