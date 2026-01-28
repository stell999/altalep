import 'dart:math';

import 'package:flutter/material.dart';

class AttendanceSystemPage extends StatefulWidget {
  const AttendanceSystemPage({super.key});

  @override
  State<AttendanceSystemPage> createState() => _AttendanceSystemPageState();
}

class _AttendanceSystemPageState extends State<AttendanceSystemPage>
    with SingleTickerProviderStateMixin {
  static const _days = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  final Map<String, _Employee> _employees = {};
  final Map<String, Map<String, _AttendanceLog>> _logs = {};
  final Map<String, List<double>> _withdraws = {};

  final _scanController = TextEditingController();
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();
  final _withdrawController = TextEditingController();
  final _scanFocus = FocusNode();

  String _selectedDay = _days.first;
  String? _selectedEmployeeId;
  String? _manualEmployeeId;
  String _manualSession = '1';
  TimeOfDay? _manualInTime;
  TimeOfDay? _manualOutTime;

  String _statusMessage = 'جاهز...';
  _StatusType _statusType = _StatusType.idle;
  final Map<String, DateTime> _lastScanTimes = {};

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scanController.dispose();
    _nameController.dispose();
    _salaryController.dispose();
    _withdrawController.dispose();
    _scanFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lightTheme = theme.copyWith(
      scaffoldBackgroundColor: _PrintColors.bg,
      colorScheme: theme.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: _PrintColors.acc,
        surface: _PrintColors.panel,
      ),
      textTheme: theme.textTheme.apply(
        bodyColor: _PrintColors.text,
        displayColor: _PrintColors.text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _PrintColors.panel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _PrintColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _PrintColors.border),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );

    return Theme(
      data: lightTheme,
      child: Container(
        color: _PrintColors.bg,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginPage(),
                  _buildEmployeesPage(),
                  _buildDashboardPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: _PrintColors.panel,
      child: Text(
        'نظام الدوام الأسبوعي للموظفين',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: const Color(0xFFF0F3F8),
      child: TabBar(
        controller: _tabController,
        labelColor: _PrintColors.text,
        unselectedLabelColor: _PrintColors.secondary,
        indicatorColor: _PrintColors.acc,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'تسجيل الدخول/الخروج'),
          Tab(text: 'إدارة الموظفين'),
          Tab(text: 'لوحة التحكم'),
        ],
      ),
    );
  }

  Widget _buildLoginPage() {
    return _pageContainer(
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('تسجيل دخول / خروج'),
            const Text('يمكن التسجيل 4 مرات يوميًا'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: const InputDecoration(labelText: 'اختر اليوم'),
              items: _days
                  .map(
                    (day) => DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedDay = value);
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _scanController,
                    focusNode: _scanFocus,
                    decoration: const InputDecoration(
                      labelText: 'رقم الموظف',
                    ),
                    onSubmitted: (_) => _handleScan(),
                  ),
                ),
                ElevatedButton(
                  onPressed: _handleScan,
                  child: const Text('تسجيل'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      FocusScope.of(context).requestFocus(_scanFocus),
                  child: const Text('تنشيط'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _manualEntrySection(),
            const SizedBox(height: 12),
            _statusBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesPage() {
    return _pageContainer(
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('إدارة الموظفين'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'اسم الموظف'),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الراتب الأسبوعي (USD)',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addEmployee,
                  child: const Text('إضافة موظف'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_employees.isEmpty)
              const Text('لا يوجد موظفون بعد.')
            else
              _dataTable(
                columns: const ['الاسم', 'الرقم', 'الراتب', 'QR', 'إجراء'],
                rows: _employees.entries.map((entry) {
                  return [
                    Text(entry.value.name),
                    Text(entry.key),
                    Text(entry.value.salaryUSD.toStringAsFixed(0)),
                    const Icon(Icons.qr_code, size: 20),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: _PrintColors.danger),
                      onPressed: () => _deleteEmployee(entry.key),
                    ),
                  ];
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardPage() {
    final selectedId = _selectedEmployeeId;
    final logs = selectedId == null ? null : _logs[selectedId];
    final withdraws = selectedId == null ? [] : (_withdraws[selectedId] ?? []);
    final totalWithdraw = withdraws.fold<double>(0, (a, b) => a + b);
    final totalPay = selectedId == null
        ? 0
        : _days.fold<double>(
            0,
            (sum, day) => sum + _calcPay(selectedId, day),
          );
    final net = totalPay - totalWithdraw;

    return _pageContainer(
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('لوحة التحكم'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    value: selectedId,
                    decoration: const InputDecoration(labelText: 'الموظف'),
                    items: _employees.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text('${entry.value.name} (${entry.key})'),
                          ),
                        )
                        .toList(),
                    onChanged: _employees.isEmpty
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() => _selectedEmployeeId = value);
                          },
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: _withdrawController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'قيمة السحب (\$)'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _employees.isEmpty ? null : _addWithdraw,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _PrintColors.danger,
                  ),
                  child: const Text('إضافة سحب'),
                ),
                ElevatedButton(
                  onPressed: _employees.isEmpty ? null : _groupExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _PrintColors.danger,
                  ),
                  child: const Text('خروج جماعي (1)'),
                ),
                OutlinedButton(
                  onPressed: _employees.isEmpty ? null : _resetWeekly,
                  child: const Text('تصفير أسبوعي'),
                ),
                ElevatedButton(
                  onPressed: () => _showSnack('طباعة A5 غير مفعلة بعد'),
                  child: const Text('طباعة A5'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_employees.isEmpty)
              const Text('لا يوجد موظفون لعرض الدوام.')
            else ...[
              _sectionTitle('جدول الدوام'),
              const SizedBox(height: 8),
              _dataTable(
                columns: const ['اليوم', 'الدخول', 'الخروج', 'الساعات', 'الأجر'],
                rows: _days.map((day) {
                  final log = logs?[day];
                  final inText =
                      '${log?.in1 ?? '—'} / ${log?.in2 ?? '—'}';
                  final outText =
                      '${log?.out1 ?? '—'} / ${log?.out2 ?? '—'}';
                  final hours = _diffHours(log?.in1, log?.out1) +
                      _diffHours(log?.in2, log?.out2);
                  final pay =
                      selectedId == null ? 0 : _calcPay(selectedId, day);
                  return [
                    Text(day),
                    Text(inText),
                    Text(outText),
                    Text(hours.toStringAsFixed(2)),
                    Text(pay.toStringAsFixed(2)),
                  ];
                }).toList(),
              ),
              const SizedBox(height: 16),
              _sectionTitle('الملخص الأسبوعي'),
              const SizedBox(height: 8),
              Text(
                'الإجمالي: ${totalPay.toStringAsFixed(2)} \$\n'
                'السحب: ${totalWithdraw.toStringAsFixed(2)} \$\n'
                'الصافي: ${net.toStringAsFixed(2)} \$',
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showSnack('PDF غير مفعل بعد'),
                child: const Text('PDF'),
              ),
              const SizedBox(height: 16),
              _sectionTitle('جميع الموظفين'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showSnack('تصدير Excel غير مفعل بعد'),
                child: const Text('تصدير إلى Excel'),
              ),
              const SizedBox(height: 8),
              _dataTable(
                columns: [
                  'الموظف',
                  ..._days,
                  'الساعات',
                  'المستحق',
                ],
                rows: _employees.entries.map((entry) {
                  double totalHours = 0;
                  double totalPay = 0;
                  final cells = <Widget>[
                    Text(entry.value.name),
                  ];
                  for (final day in _days) {
                    final log = _logs[entry.key]?[day];
                    final hours = _diffHours(log?.in1, log?.out1) +
                        _diffHours(log?.in2, log?.out2);
                    totalHours += hours;
                    totalPay += _calcPay(entry.key, day);
                    cells.add(Text(hours.toStringAsFixed(2)));
                  }
                  final withdraw = (_withdraws[entry.key] ?? [])
                      .fold<double>(0, (a, b) => a + b);
                  cells.add(Text(totalHours.toStringAsFixed(2)));
                  cells.add(Text((totalPay - withdraw).toStringAsFixed(2)));
                  return cells;
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _manualEntrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        _sectionTitle('إدخال يدوي للدوام'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: _manualEmployeeId,
                decoration: const InputDecoration(labelText: 'الموظف'),
                items: _employees.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text('${entry.value.name} (${entry.key})'),
                      ),
                    )
                    .toList(),
                onChanged: _employees.isEmpty
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _manualEmployeeId = value);
                      },
              ),
            ),
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<String>(
                value: _manualSession,
                decoration: const InputDecoration(labelText: 'الفترة'),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('الفترة الأولى')),
                  DropdownMenuItem(value: '2', child: Text('الفترة الثانية')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _manualSession = value);
                },
              ),
            ),
            _timePickerField(
              label: 'وقت الدخول',
              value: _manualInTime,
              onPick: (time) => setState(() => _manualInTime = time),
            ),
            _timePickerField(
              label: 'وقت الخروج',
              value: _manualOutTime,
              onPick: (time) => setState(() => _manualOutTime = time),
            ),
            OutlinedButton(
              onPressed: _employees.isEmpty ? null : _manualEntry,
              child: const Text('حفظ يدوي'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('استخدم هذا الخيار لوضع أوقات الدخول/الخروج يدويًا.'),
      ],
    );
  }

  Widget _timePickerField({
    required String label,
    required TimeOfDay? value,
    required ValueChanged<TimeOfDay?> onPick,
  }) {
    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: value ?? TimeOfDay.now(),
          );
          if (!mounted) return;
          onPick(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Text(value == null ? '—' : value.format(context)),
        ),
      ),
    );
  }

  Widget _pageContainer({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      ),
    );
  }

  Widget _statusBox() {
    Color border;
    Color text;
    switch (_statusType) {
      case _StatusType.ok:
        border = _PrintColors.ok;
        text = _PrintColors.ok;
        break;
      case _StatusType.err:
        border = _PrintColors.danger;
        text = _PrintColors.danger;
        break;
      case _StatusType.idle:
        border = _PrintColors.border;
        text = _PrintColors.text;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        _statusMessage,
        style: TextStyle(color: text, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _PrintColors.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _PrintColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _dataTable({
    required List<String> columns,
    required List<List<Widget>> rows,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor:
            WidgetStateProperty.all(const Color(0xFFF0F3F8)),
        columnSpacing: 16,
        columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
        rows: rows
            .map(
              (cells) => DataRow(
                cells: cells.map((cell) => DataCell(cell)).toList(),
              ),
            )
            .toList(),
      ),
    );
  }

  void _handleScan() {
    final id = _scanController.text.trim();
    if (id.isEmpty) return;
    final emp = _employees[id];
    if (emp == null) {
      _setStatus('رقم غير معروف', _StatusType.err);
      return;
    }

    final last = _lastScanTimes[id];
    if (last != null &&
        DateTime.now().difference(last).inSeconds < 3) {
      _setStatus('أعد المحاولة بعد قليل', _StatusType.err);
      return;
    }
    _lastScanTimes[id] = DateTime.now();

    final now = TimeOfDay.now();
    final time = _formatTime(now);
    final log = _logs.putIfAbsent(id, () => {})[_selectedDay] ?? _AttendanceLog();

    if (log.in1 == null) {
      log.in1 = time;
      _setStatus('دخول أول: ${emp.name}', _StatusType.ok);
    } else if (log.out1 == null) {
      if (!_canLogout(log.in1!, time)) {
        _setStatus('يجب مرور 15 دقيقة على الأقل قبل الخروج', _StatusType.err);
        return;
      }
      log.out1 = time;
      _setStatus('خروج أول: ${emp.name}', _StatusType.ok);
    } else if (log.in2 == null) {
      log.in2 = time;
      _setStatus('دخول ثاني: ${emp.name}', _StatusType.ok);
    } else if (log.out2 == null) {
      if (!_canLogout(log.in2!, time)) {
        _setStatus('يجب مرور 15 دقيقة على الأقل قبل الخروج', _StatusType.err);
        return;
      }
      log.out2 = time;
      _setStatus('خروج نهائي: ${emp.name}', _StatusType.ok);
    } else {
      _setStatus('اليوم مكتمل', _StatusType.err);
      return;
    }

    _logs[id]![_selectedDay] = log;
    setState(() {});
    _scanController.clear();
  }

  void _manualEntry() {
    if (_manualEmployeeId == null) {
      _setStatus('اختر موظفًا للتعديل', _StatusType.err);
      return;
    }
    if (_manualInTime == null && _manualOutTime == null) {
      _setStatus('أدخل وقتًا واحدًا على الأقل', _StatusType.err);
      return;
    }

    final log = _logs.putIfAbsent(_manualEmployeeId!, () => {})[_selectedDay] ??
        _AttendanceLog();
    if (_manualSession == '1') {
      if (_manualInTime != null) log.in1 = _formatTime(_manualInTime!);
      if (_manualOutTime != null) log.out1 = _formatTime(_manualOutTime!);
    } else {
      if (_manualInTime != null) log.in2 = _formatTime(_manualInTime!);
      if (_manualOutTime != null) log.out2 = _formatTime(_manualOutTime!);
    }
    _logs[_manualEmployeeId!]![_selectedDay] = log;
    _manualInTime = null;
    _manualOutTime = null;
    _setStatus('تم تعديل السجل يدويًا', _StatusType.ok);
    setState(() {});
  }

  void _addEmployee() {
    final name = _nameController.text.trim();
    final salary = double.tryParse(_salaryController.text.trim());
    if (name.isEmpty || salary == null || salary <= 0) {
      _showSnack('الرجاء ملء الحقول بشكل صحيح');
      return;
    }
    final id = _generateId();
    setState(() {
      _employees[id] = _Employee(name: name, salaryUSD: salary);
      _selectedEmployeeId ??= id;
      _manualEmployeeId ??= id;
    });
    _nameController.clear();
    _salaryController.clear();
  }

  void _deleteEmployee(String id) {
    setState(() {
      _employees.remove(id);
      _logs.remove(id);
      _withdraws.remove(id);
      if (_selectedEmployeeId == id) {
        _selectedEmployeeId = _employees.keys.isEmpty
            ? null
            : _employees.keys.first;
      }
      if (_manualEmployeeId == id) {
        _manualEmployeeId = _selectedEmployeeId;
      }
    });
  }

  void _addWithdraw() {
    final id = _selectedEmployeeId;
    final amt = double.tryParse(_withdrawController.text.trim());
    if (id == null || amt == null || amt <= 0) return;
    _withdraws.putIfAbsent(id, () => []).add(amt);
    _withdrawController.clear();
    setState(() {});
  }

  void _resetWeekly() async {
    final confirmed = await _confirmAction(
      'تصفير أسبوعي',
      'هل تريد فعلاً تصفير جميع الحضور لهذا الأسبوع؟',
    );
    if (!confirmed) return;
    setState(() {
      _logs.clear();
      _withdraws.clear();
    });
  }

  void _groupExit() async {
    final confirmed = await _confirmAction(
      'خروج جماعي',
      'هل أنت متأكد من تسجيل خروج جماعي (الخروج الأول) للموظفين؟',
    );
    if (!confirmed) return;
    final time = _formatTime(TimeOfDay.now());
    for (final id in _employees.keys) {
      final dayLog = _logs.putIfAbsent(id, () => {})[_selectedDay] ??
          _AttendanceLog();
      if (dayLog.in1 != null && dayLog.out1 == null) {
        dayLog.out1 = time;
        _logs[id]![_selectedDay] = dayLog;
      }
    }
    setState(() {});
  }

  double _calcPay(String id, String day) {
    final emp = _employees[id];
    final log = _logs[id]?[day];
    if (emp == null || log == null) return 0;
    final base = emp.salaryUSD / (6 * 10 * 60);
    double total = 0;
    total += _calcPeriodPay(log.in1, log.out1, base);
    total += _calcPeriodPay(log.in2, log.out2, base);
    return total;
  }

  double _calcPeriodPay(String? inTime, String? outTime, double base) {
    if (inTime == null || outTime == null) return 0;
    final start = _parseTime(inTime);
    final end = _parseTime(outTime);
    final extra = _parseTime('18:00');
    double total = 0;
    for (var m = start; m < end; m++) {
      total += base * (m >= extra ? 2 : 1);
    }
    return total;
  }

  double _diffHours(String? inTime, String? outTime) {
    if (inTime == null || outTime == null) return 0;
    return max(0, (_parseTime(outTime) - _parseTime(inTime)) / 60);
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 +
        (int.tryParse(parts[1]) ?? 0);
  }

  bool _canLogout(String inTime, String outTime) {
    return _parseTime(outTime) - _parseTime(inTime) >= 15;
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _generateId() {
    String id;
    do {
      id = (200000 + Random().nextInt(900000)).toString();
    } while (_employees.containsKey(id));
    return id;
  }

  Future<bool> _confirmAction(String title, String message) async {
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

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _setStatus(String message, _StatusType type) {
    setState(() {
      _statusMessage = message;
      _statusType = type;
    });
  }
}

class _Employee {
  const _Employee({required this.name, required this.salaryUSD});

  final String name;
  final double salaryUSD;
}

class _AttendanceLog {
  String? in1;
  String? out1;
  String? in2;
  String? out2;
}

enum _StatusType { idle, ok, err }

class _PrintColors {
  static const bg = Color(0xFFF6F8FB);
  static const panel = Color(0xFFFFFFFF);
  static const border = Color(0xFFD7DCE2);
  static const acc = Color(0xFF0078FF);
  static const ok = Color(0xFF00A676);
  static const danger = Color(0xFFD9534F);
  static const text = Color(0xFF222222);
  static const secondary = Color(0xFF6C757D);

  const _PrintColors._();
}
