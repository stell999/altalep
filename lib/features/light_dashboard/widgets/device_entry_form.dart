import 'package:flutter/material.dart';

import '../constants/light_constants.dart';
import '../models/device_input.dart';

class DeviceEntryForm extends StatefulWidget {
  const DeviceEntryForm({
    super.key,
    required this.isVisible,
    required this.isSubmitting,
    required this.errorText,
    required this.onSubmit,
    required this.employeeNames,
    required this.defaultDepartment,
    required this.isAdmin,
    required this.currentUserName,
  });

  final bool isVisible;
  final bool isSubmitting;
  final String? errorText;
  final Future<String?> Function(DeviceInput input) onSubmit;
  final List<String> employeeNames;
  final String defaultDepartment;
  final bool isAdmin;
  final String currentUserName;

  @override
  State<DeviceEntryForm> createState() => _DeviceEntryFormState();
}

class _DeviceEntryFormState extends State<DeviceEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _customerCtrl = TextEditingController();
  final _deviceCtrl = TextEditingController();
  final _issueCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  late String _departmentValue;
  late String _employeeValue;
  String _statusValue = LightConstants.statusOptions.first;
  String _priorityValue = LightConstants.priorityColors.first;

  @override
  void initState() {
    super.initState();
    _departmentValue = widget.defaultDepartment;
    _employeeValue = widget.isAdmin
        ? (widget.employeeNames.isEmpty ? '' : widget.employeeNames.first)
        : widget.currentUserName;
  }

  @override
  void didUpdateWidget(DeviceEntryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultDepartment != widget.defaultDepartment &&
        !widget.isAdmin) {
      _departmentValue = widget.defaultDepartment;
    }
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _deviceCtrl.dispose();
    _issueCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'إضافة جهاز جديد',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _customerCtrl,
                      decoration: const InputDecoration(
                        labelText: 'اسم الزبون',
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _deviceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'اسم الجهاز',
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _issueCtrl,
                      decoration: const InputDecoration(
                        labelText: 'العطل أو المشكلة',
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _departmentValue,
                      decoration: const InputDecoration(labelText: 'القسم'),
                      items: LightConstants.departments
                          .map(
                            (dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            ),
                          )
                          .toList(),
                      onChanged: widget.isAdmin
                          ? (value) {
                              if (value != null) {
                                setState(() => _departmentValue = value);
                              }
                            }
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _employeeValue.isEmpty ? null : _employeeValue,
                      decoration: const InputDecoration(labelText: 'الموظف'),
                      items: {
                        ...widget.employeeNames,
                        widget.currentUserName,
                      }
                          .where((name) => name.isNotEmpty)
                          .map(
                            (name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList(),
                      onChanged: widget.isAdmin
                          ? (value) {
                              if (value != null) {
                                setState(() => _employeeValue = value);
                              }
                            }
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _statusValue,
                      decoration: const InputDecoration(labelText: 'الحالة'),
                      items: LightConstants.statusOptions
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _statusValue = value);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _priorityValue,
                      decoration: const InputDecoration(labelText: 'الأولوية'),
                      items: LightConstants.priorityColors
                          .map(
                            (color) => DropdownMenuItem(
                              value: color,
                              child: Text(color),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _priorityValue = value);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _costCtrl,
                      decoration: const InputDecoration(
                        labelText: 'التكلفة',
                        prefixText: '₪ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              if (widget.errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: widget.isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: widget.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('حفظ الجهاز'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل إجباري';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final input = DeviceInput(
      customerName: _customerCtrl.text.trim(),
      deviceName: _deviceCtrl.text.trim(),
      issue: _issueCtrl.text.trim(),
      department: _departmentValue,
      employeeName: _employeeValue,
      status: _statusValue,
      priorityColor: _priorityValue,
      cost: _costCtrl.text.trim(),
    );
    final error = await widget.onSubmit(input);
    if (error == null) {
      _customerCtrl.clear();
      _deviceCtrl.clear();
      _issueCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الجهاز بنجاح')),
        );
      }
    }
  }
}
