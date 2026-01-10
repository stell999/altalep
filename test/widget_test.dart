import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:altalep_v2/features/light_dashboard/widgets/light_sidebar.dart';

void main() {
  testWidgets('LightSidebar shows admin title and counts',
      (WidgetTester tester) async {
    const statusCounts = {
      'جاري العمل': 3,
      'تم الإصلاح': 1,
      'تم التسليم': 0,
      'لا يصلح': 0,
      'انتظار': 1,
      'زبون مابدو': 0,
      'صلح': 0,
      'مرتجع': 0,
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: LightSidebar(
              currentDepartment: 'أعطال خفيفة',
              isAdminView: true,
              statusCounts: statusCounts,
            ),
          ),
        ),
      ),
    );

    expect(find.text('لوحة الصيانة (مشرف)'), findsOneWidget);
    expect(find.text('جاري العمل'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
  });
}
