import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/light_constants.dart';

class DeviceFilters extends StatelessWidget {
  const DeviceFilters({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onDateSelected,
    required this.onStatusChanged,
    required this.onEmployeeChanged,
    required this.onDepartmentChanged,
    required this.selectedDate,
    required this.statusFilter,
    required this.employeeFilter,
    required this.departmentFilter,
    required this.employeeNames,
    required this.showDepartmentFilter,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DateTime?> onDateSelected;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onEmployeeChanged;
  final ValueChanged<String> onDepartmentChanged;
  final DateTime? selectedDate;
  final String statusFilter;
  final String employeeFilter;
  final String departmentFilter;
  final List<String> employeeNames;
  final bool showDepartmentFilter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'بحث باسم الزبون',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: _DateFilterTile(
                selectedDate: selectedDate,
                onDateSelected: onDateSelected,
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: statusFilter,
                items: [
                  const DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                  ...LightConstants.statusOptions.map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: 'الحالة',
                ),
                onChanged: (value) {
                  if (value != null) onStatusChanged(value);
                },
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: employeeFilter,
                items: [
                  const DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                  ...employeeNames.map(
                    (name) =>
                        DropdownMenuItem(value: name, child: Text(name)),
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: 'الموظف',
                ),
                onChanged: (value) {
                  if (value != null) onEmployeeChanged(value);
                },
              ),
            ),
            if (showDepartmentFilter)
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: departmentFilter,
                  items: [
                    const DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                    ...LightConstants.departments.map(
                      (dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'القسم',
                  ),
                  onChanged: (value) {
                    if (value != null) onDepartmentChanged(value);
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DateFilterTile extends StatelessWidget {
  const _DateFilterTile({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ar'),
      confirmText: 'اختيار',
      cancelText: 'الغاء',
      helpText: 'اختر التاريخ',
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = selectedDate == null
        ? 'الكل'
        : DateFormat('dd/MM/yyyy', 'ar')
            .format(selectedDate!.toLocal());
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _pickDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'التاريخ',
          suffixIcon: Icon(Icons.date_range),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formattedDate),
            if (selectedDate != null)
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'إزالة التاريخ',
                onPressed: () => onDateSelected(null),
              ),
          ],
        ),
      ),
    );
  }
}
