import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../constants/light_constants.dart';

class LightSidebar extends StatelessWidget {
  const LightSidebar({
    super.key,
    required this.currentDepartment,
    required this.isAdminView,
    required this.statusCounts,
    this.onNavigateBack,
    this.onOpenPosDashboard,
    this.onOpenPosDashboardTab,
  });

  final String currentDepartment;
  final bool isAdminView;
  final Map<String, int> statusCounts;
  final VoidCallback? onNavigateBack;
  final VoidCallback? onOpenPosDashboard;
  final ValueChanged<int>? onOpenPosDashboardTab;

  void _openTab(int index) {
    if (onOpenPosDashboardTab != null) {
      onOpenPosDashboardTab!(index);
    } else {
      onOpenPosDashboard?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              AppTheme.logoAsset,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.lightbulb_circle,
                size: 64,
                color: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isAdminView ? 'لوحة الصيانة (مشرف)' : 'قسم $currentDepartment',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (onOpenPosDashboard != null || onOpenPosDashboardTab != null) ...[
            const SizedBox(height: 16),
            Text(
              'اختصارات',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _ShortcutButton(
              label: 'الشاشات والبوردات',
              icon: Icons.devices,
              onPressed: () => _openTab(3),
            ),
            const SizedBox(height: 8),
            _ShortcutButton(
              label: 'نظام الدوام',
              icon: Icons.print,
              onPressed: () => _openTab(2),
            ),
            const SizedBox(height: 8),
            _ShortcutButton(
              label: 'الصندوق اليومية',
              icon: Icons.account_balance_wallet,
              onPressed: () => _openTab(1),
            ),
            const SizedBox(height: 8),
            _ShortcutButton(
              label: 'حسابي',
              icon: Icons.person,
              onPressed: () => _openTab(0),
            ),
          ],
          // if (isAdminView) ...[
          //   const SizedBox(height: 16),
          //   FilledButton(
          //     onPressed: onNavigateBack,
          //     // child: const Text('العودة للوحة التحكم'),
          //   ),
          // ],
          const SizedBox(height: 24),
          Text(
            'حالات الأجهزة',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: LightConstants.statusOptions.length,
              itemBuilder: (context, index) {
                final label = LightConstants.statusOptions[index];
                final count = statusCounts[label] ?? 0;
                return _StatusRow(label: label, count: count);
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          CircleAvatar(
            radius: 12,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
