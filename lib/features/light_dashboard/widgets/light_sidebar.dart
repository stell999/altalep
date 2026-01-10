import 'package:flutter/material.dart';

import '../constants/light_constants.dart';

class LightSidebar extends StatelessWidget {
  const LightSidebar({
    super.key,
    required this.currentDepartment,
    required this.isAdminView,
    required this.statusCounts,
    this.onNavigateBack,
  });

  final String currentDepartment;
  final bool isAdminView;
  final Map<String, int> statusCounts;
  final VoidCallback? onNavigateBack;

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
              'assets/logo.png',
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
