import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/daily_cash_entry.dart';
import '../../core/providers/daily_cash_provider.dart';
import 'attendance_system_page.dart';
import 'data/screen_board_repository.dart';

class PosDashboardScreen extends StatelessWidget {
  const PosDashboardScreen({super.key, this.initialTab = 3});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final textTheme = baseTheme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    final safeIndex = initialTab.clamp(0, 3).toInt();

    return Theme(
      data: baseTheme.copyWith(
        scaffoldBackgroundColor: PosColors.background,
        colorScheme: baseTheme.colorScheme.copyWith(
          brightness: Brightness.dark,
          primary: PosColors.primary,
          surface: PosColors.surface,
          onSurface: Colors.white,
        ),
        dividerColor: PosColors.divider,
        textTheme: textTheme,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: PosColors.input,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      child: _PosDashboardBody(initialTab: safeIndex),
    );
  }
}

class _PosDashboardBody extends StatelessWidget {
  const _PosDashboardBody({required this.initialTab});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: initialTab,
      child: Scaffold(
        body: Column(
          children: const [
            _TopNavBar(),
            Expanded(
              child: TabBarView(
                children: [
                  AccountPage(),
                  DailyFundsPage(),
                  AttendanceSystemTab(),
                  DevicesPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        );

    return Container(
      color: PosColors.navBar,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              const _BackToMainButton(),
              const SizedBox(width: 16),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TabBar(
                    isScrollable: true,
                    labelStyle: textStyle,
                    unselectedLabelColor: Colors.white70,
                    labelColor: Colors.white,
                    indicator: BoxDecoration(
                      color: PosColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'حسابي'),
                      Tab(text: 'صندوق اليومية'),
                      Tab(text: 'نظام الدوام'),
                      Tab(text: 'الشاشات والبوردات'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              const SizedBox(width: 280, child: _SearchField()),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: PosColors.divider),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'ابحث',
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.search, color: Colors.white70),
      ),
    );
  }
}

class _BackToMainButton extends StatelessWidget {
  const _BackToMainButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        }
      },
      icon: const Icon(Icons.arrow_back),
      label: const Text('الصفحة الرئيسية'),
      style: FilledButton.styleFrom(
        backgroundColor: PosColors.surface,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final _boardController = TextEditingController();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitUsdController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  final _boardFocus = FocusNode();
  final _typeFocus = FocusNode();
  final _quantityFocus = FocusNode();
  final _unitUsdFocus = FocusNode();
  final _notesFocus = FocusNode();

  final List<ScreenBoardEntry> _entries = [];
  final List<int> _entryIds = [];
  late final ScreenBoardRepository _repo;

  @override
  void dispose() {
    _boardController.dispose();
    _typeController.dispose();
    _quantityController.dispose();
    _unitUsdController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _boardFocus.dispose();
    _typeFocus.dispose();
    _quantityFocus.dispose();
    _unitUsdFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCount =
        _entries.fold<int>(0, (sum, entry) => sum + entry.quantity);
    final totalUsd = _entries.fold<double>(
      0,
      (sum, entry) => sum + (entry.quantity * entry.unitUsd),
    );
    final totalSales = _entries.fold<double>(
      0,
      (sum, entry) => sum + (entry.sold * entry.unitUsd),
    );
    final searchTerm = _searchController.text.trim().toLowerCase();
    final filteredEntries = searchTerm.isEmpty
        ? _entries
        : _entries
            .where(
              (entry) =>
                  entry.boardOrScreen.toLowerCase().contains(searchTerm),
            )
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageTitle(title: 'الشاشات والبوردات'),
          const SizedBox(height: 16),
          _buildSummaryCard(
            context,
            totalCount: totalCount,
            totalUsd: totalUsd,
            totalSales: totalSales,
          ),
          const SizedBox(height: 16),
          _buildSearchField(context),
          const SizedBox(height: 16),
          _buildEntryCard(context),
          const SizedBox(height: 16),
          if (filteredEntries.isEmpty)
            const _EmptyState(message: 'لا توجد عناصر بعد.')
          else
            _PosDataTable(
              columns: const [
                DataColumn(label: _TableHeaderText('البورد أو شاشة')),
                DataColumn(label: _TableHeaderText('النوع')),
                DataColumn(label: _TableHeaderText('العدد')),
                DataColumn(label: _TableHeaderText('دولار')),
                DataColumn(label: _TableHeaderText('تم البيع')),
                DataColumn(label: _TableHeaderText('ملاحظة')),
                DataColumn(label: _TableHeaderText('إجراء')),
              ],
              rows: filteredEntries
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row.boardOrScreen)),
                        DataCell(Text(row.model)),
                        DataCell(Text('${row.quantity}')),
                        DataCell(Text(_formatUsd(row.unitUsd))),
                        DataCell(Text('${row.sold}')),
                        DataCell(Text(row.notes)),
                        DataCell(
                          FilledButton.tonal(
                            onPressed: row.quantity > 0
                                ? () => _sellItem(row)
                                : null,
                            child: const Text('بيع'),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _repo = ScreenBoardRepository();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final rows = await _repo.fetch();
    setState(() {
      _entries
        ..clear()
        ..addAll(rows.map((r) => r.entry));
      _entryIds
        ..clear()
        ..addAll(rows.map((r) => r.id));
    });
  }

  Widget _buildEntryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PosColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إضافة صنف',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _boardController,
                  focusNode: _boardFocus,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_typeFocus),
                  decoration: _screenEntryDecoration('البورد أو شاشة'),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _typeController,
                  focusNode: _typeFocus,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_quantityFocus),
                  decoration: _screenEntryDecoration('النوع'),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _quantityController,
                  focusNode: _quantityFocus,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_unitUsdFocus),
                  decoration: _screenEntryDecoration('العدد'),
                ),
              ),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _unitUsdController,
                  focusNode: _unitUsdFocus,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_notesFocus),
                  decoration: _screenEntryDecoration('دولار'),
                ),
              ),
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _notesController,
                  focusNode: _notesFocus,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addEntry(),
                  decoration: _screenEntryDecoration('ملاحظة (اختياري)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: _addEntry,
              icon: const Icon(Icons.add),
              label: const Text('إضافة'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return SizedBox(
      width: 320,
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: _screenEntryDecoration('بحث باسم البورد أو الشاشة'),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  void _addEntry() {
    final board = _boardController.text.trim();
    final model = _typeController.text.trim();
    final quantityText = _quantityController.text.trim();
    final unitUsdText = _unitUsdController.text.trim();
    final notes = _notesController.text.trim();

    if (board.isEmpty ||
        model.isEmpty ||
        quantityText.isEmpty ||
        unitUsdText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الحقول الأساسية مطلوبة (ما عدا الملاحظة).'),
        ),
      );
      return;
    }

    final quantity = _parseInt(quantityText);
    final unitUsd = _parseDouble(unitUsdText);
    if (quantity <= 0 || unitUsd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال عدد وسعر صحيحين.')),
      );
      return;
    }

    final entry = ScreenBoardEntry(
      boardOrScreen: board.isEmpty ? '-' : board,
      model: model.isEmpty ? '-' : model,
      quantity: quantity,
      unitUsd: unitUsd,
      sold: 0,
      notes: notes.isEmpty ? '-' : notes,
    );
    _repo.insert(entry).then((id) {
      setState(() {
        _entries.insert(0, entry);
        _entryIds.insert(0, id ?? -1);
      });
    });

    _boardController.clear();
    _typeController.clear();
    _quantityController.clear();
    _unitUsdController.clear();
    _notesController.clear();
    _boardFocus.requestFocus();
  }

  void _sellItem(ScreenBoardEntry entry) {
    final index = _entries.indexOf(entry);
    if (index == -1) return;
    if (entry.quantity <= 0) return;
    final updated = entry.copyWith(
      quantity: entry.quantity - 1,
      sold: entry.sold + 1,
    );
    final id = (index < _entryIds.length) ? _entryIds[index] : -1;
    _repo.updateQtySold(id, updated.quantity, updated.sold).then((_) {
      setState(() {
        _entries[index] = updated;
      });
    });
  }

  int _parseInt(String value) {
    final normalized = _normalizeNumber(value);
    return int.tryParse(normalized) ?? 0;
  }

  double _parseDouble(String value) {
    final normalized = _normalizeNumber(value);
    return double.tryParse(normalized) ?? 0;
  }

  String _normalizeNumber(String value) {
    var output = value.trim();
    if (output.isEmpty) return '';
    const arabicDigits = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };
    const persianDigits = {
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',
    };
    output = output
        .split('')
        .map((ch) => arabicDigits[ch] ?? persianDigits[ch] ?? ch)
        .join();
    output = output
        .replaceAll('٬', '')
        .replaceAll(',', '')
        .replaceAll('٫', '.')
        .replaceAll(' ', '');
    return output.replaceAll(RegExp(r'[^0-9.\-]'), '');
  }

  String _formatUsd(double value) => value.toStringAsFixed(2);

  Widget _buildSummaryCard(
    BuildContext context, {
    required int totalCount,
    required double totalUsd,
    required double totalSales,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PosColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryTile(
              label: 'العدد الكلي',
              value: '$totalCount',
              icon: Icons.inventory_2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _summaryTile(
              label: 'إجمالي المخزون',
              value: _formatUsd(totalUsd),
              icon: Icons.attach_money,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _summaryTile(
              label: 'إجمالي المبيعات',
              value: _formatUsd(totalSales),
              icon: Icons.trending_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PosColors.input,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: PosColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _screenEntryDecoration(String label) {
    return InputDecoration(
      labelText: label,
      hintText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      floatingLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: PosColors.input.withValues(alpha: 0.9),
    );
  }
}

class AttendanceSystemTab extends StatelessWidget {
  const AttendanceSystemTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const AttendanceSystemPage();
  }
}

class DailyFundsPage extends ConsumerStatefulWidget {
  const DailyFundsPage({super.key});

  @override
  ConsumerState<DailyFundsPage> createState() => _DailyFundsPageState();
}

class _DailyFundsPageState extends ConsumerState<DailyFundsPage> {
  final _receiptController = TextEditingController();
  final _paymentController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _receiptFocus = FocusNode();
  final _paymentFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _currencyFocus = FocusNode();
  String _currency = 'الدولار';

  @override
  void dispose() {
    _receiptController.dispose();
    _paymentController.dispose();
    _descriptionController.dispose();
    _receiptFocus.dispose();
    _paymentFocus.dispose();
    _descriptionFocus.dispose();
    _currencyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(dailyCashControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageTitle(title: 'صندوق اليومية'),
          const SizedBox(height: 16),
          _buildEntryCard(context),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            const _EmptyState(message: 'لا توجد بيانات للصناديق اليومية.')
          else
            _PosDataTable(
              columns: const [
                DataColumn(label: _TableHeaderText('قبض')),
                DataColumn(label: _TableHeaderText('دفع')),
                DataColumn(label: _TableHeaderText('بيان')),
                DataColumn(label: _TableHeaderText('نوع العملة')),
              ],
              rows: rows
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row.receipt)),
                        DataCell(Text(row.payment)),
                        DataCell(Text(row.description)),
                        DataCell(
                          Text(
                            row.currency,
                            style: TextStyle(
                              color: _currencyColor(row.currency),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PosColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إضافة حركة يومية',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _receiptController,
                  focusNode: _receiptFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_paymentFocus),
                  decoration: _entryDecoration(
                    label: 'قبض',
                    color: PosColors.success,
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _paymentController,
                  focusNode: _paymentFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_descriptionFocus),
                  decoration: _entryDecoration(
                    label: 'دفع',
                    color: PosColors.danger,
                  ),
                ),
              ),
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocus,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleAdd(),
                  decoration: _entryDecoration(
                    label: 'بيان',
                    color: PosColors.warning,
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_currency),
                  initialValue: _currency,
                  focusNode: _currencyFocus,
                  dropdownColor: PosColors.surface,
                  decoration: const InputDecoration(
                    hintText: 'نوع العملة',
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
                      _currency = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: _handleAdd,
              icon: const Icon(Icons.add),
              label: const Text('إضافة'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _entryDecoration({
    required String label,
    required Color color,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: color),
      floatingLabelStyle:
          TextStyle(color: color, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: color.withValues(alpha: 0.12),
    );
  }

  void _handleAdd() {
    final receipt = _receiptController.text.trim();
    final payment = _paymentController.text.trim();
    final description = _descriptionController.text.trim();

    if (receipt.isEmpty && payment.isEmpty && description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال قبض أو دفع أو بيان')),
      );
      return;
    }

    final entry = DailyCashEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      currency: _currency,
      receipt: receipt.isEmpty ? '0' : receipt,
      payment: payment.isEmpty ? '0' : payment,
      description: description.isEmpty ? '-' : description,
      createdAt: DateTime.now(),
    );
    ref.read(dailyCashControllerProvider.notifier).addEntry(entry);

    _receiptController.clear();
    _paymentController.clear();
    _descriptionController.clear();
    _receiptFocus.requestFocus();
    setState(() {
      _currency = 'الدولار';
    });
  }
}

Color _currencyColor(String currency) {
  if (currency.contains('دولار')) return PosColors.success;
  if (currency.contains('تركي')) return PosColors.danger;
  if (currency.contains('سوري')) return PosColors.warning;
  return Colors.white70;
}

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashRows = ref.watch(dailyCashControllerProvider);
    final balances = _calculateBalances(cashRows);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageTitle(title: 'حسابي'),
          const SizedBox(height: 16),
          const _SectionTitle(title: 'صافي الحساب'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              BalanceCard(
                title: 'USD Balance',
                subtitle: 'الدولار',
                amount: balances.usd,
                icon: Icons.attach_money,
                iconColor: PosColors.success,
              ),
              BalanceCard(
                title: 'TRY Balance',
                subtitle: 'الليرة التركية',
                amount: balances.tryAmount,
                icon: Icons.currency_lira,
                iconColor: PosColors.danger,
              ),
              BalanceCard(
                title: 'SYR Balance',
                subtitle: 'الليرة السورية',
                amount: balances.syr,
                icon: Icons.monetization_on,
                iconColor: PosColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const _SectionTitle(title: 'بيان الصندوق'),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.tonal(
              onPressed: () async {
                final confirmed = await _confirmClear(context);
                if (!confirmed) return;
                await ref.read(dailyCashControllerProvider.notifier).clear();
              },
              child: const Text('تصفير الصندوق'),
            ),
          ),
          const SizedBox(height: 12),
          if (cashRows.isEmpty)
            const _EmptyState(message: 'لا توجد بيانات للصندوق بعد.')
          else
            _PosDataTable(
              columns: const [
                DataColumn(label: _TableHeaderText('قبض')),
                DataColumn(label: _TableHeaderText('دفع')),
                DataColumn(label: _TableHeaderText('بيان')),
                DataColumn(label: _TableHeaderText('نوع العملة')),
              ],
              rows: cashRows
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row.receipt)),
                        DataCell(Text(row.payment)),
                        DataCell(Text(row.description)),
                        DataCell(
                          Text(
                            row.currency,
                            style: TextStyle(
                              color: _currencyColor(row.currency),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Future<bool> _confirmClear(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تصفير الصندوق'),
        content: const Text('هل أنت متأكد من حذف جميع حركات الصندوق؟'),
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

  AccountBalances _calculateBalances(List<DailyCashEntry> rows) {
    double usd = 0;
    double tryAmount = 0;
    double syr = 0;

    for (final row in rows) {
      final receipt = _parseAmount(row.receipt);
      final payment = _parseAmount(row.payment);
      final net = receipt - payment;
      switch (_normalizeCurrency(row.currency)) {
        case _Currency.usd:
          usd += net;
          break;
        case _Currency.tryAmount:
          tryAmount += net;
          break;
        case _Currency.syr:
          syr += net;
          break;
        case _Currency.unknown:
          break;
      }
    }

    return AccountBalances(
      usd: _formatAmount(usd),
      tryAmount: _formatAmount(tryAmount),
      syr: _formatAmount(syr),
    );
  }

  double _parseAmount(String value) {
    final normalized = _normalizeNumber(value);
    if (normalized.isEmpty) return 0;
    return double.tryParse(normalized) ?? 0;
  }

  String _formatAmount(double value) => value.toStringAsFixed(2);

  String _normalizeNumber(String value) {
    var output = value.trim();
    if (output.isEmpty) return '';

    const arabicDigits = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };
    const persianDigits = {
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',
    };

    output = output
        .split('')
        .map((ch) => arabicDigits[ch] ?? persianDigits[ch] ?? ch)
        .join();

    output = output
        .replaceAll('٬', '')
        .replaceAll(',', '')
        .replaceAll('٫', '.')
        .replaceAll(' ', '');

    return output.replaceAll(RegExp(r'[^0-9.\\-]'), '');
  }

  _Currency _normalizeCurrency(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('دولار') || lower.contains('usd')) {
      return _Currency.usd;
    }
    if (lower.contains('تركي') || lower.contains('try')) {
      return _Currency.tryAmount;
    }
    if (lower.contains('سوري') || lower.contains('syr')) {
      return _Currency.syr;
    }
    return _Currency.unknown;
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PosColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(icon, color: iconColor, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  const _TableHeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _PosDataTable extends StatelessWidget {
  const _PosDataTable({required this.columns, required this.rows});

  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PosColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(PosColors.primary),
                  dataRowColor: WidgetStateProperty.all(PosColors.surface),
                  dividerThickness: 1,
                  columnSpacing: 32,
                  headingRowHeight: 56,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 64,
                  columns: columns,
                  rows: rows,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PosColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class AccountBalances {
  const AccountBalances({
    this.usd = '0.00',
    this.tryAmount = '0.00',
    this.syr = '0.00',
  });

  final String usd;
  final String tryAmount;
  final String syr;
}

class ScreenBoardEntry {
  const ScreenBoardEntry({
    required this.boardOrScreen,
    required this.model,
    required this.quantity,
    required this.unitUsd,
    required this.sold,
    required this.notes,
  });

  final String boardOrScreen;
  final String model;
  final int quantity;
  final double unitUsd;
  final int sold;
  final String notes;

  ScreenBoardEntry copyWith({
    int? quantity,
    int? sold,
  }) {
    return ScreenBoardEntry(
      boardOrScreen: boardOrScreen,
      model: model,
      quantity: quantity ?? this.quantity,
      unitUsd: unitUsd,
      sold: sold ?? this.sold,
      notes: notes,
    );
  }
}

enum _Currency {
  usd,
  tryAmount,
  syr,
  unknown,
}

class PosColors {
  static const Color background = Color(0xFF242A33);
  static const Color navBar = Color(0xFF2B313C);
  static const Color surface = Color(0xFF2E3541);
  static const Color input = Color(0xFF3B424F);
  static const Color primary = Color(0xFF4BA6EA);
  static const Color divider = Color(0xFF3F4654);
  static const Color success = Color(0xFF39C46D);
  static const Color danger = Color(0xFFE35151);
  static const Color warning = Color(0xFFF2C14E);

  const PosColors._();
}
