import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/light_dashboard/constants/light_constants.dart';
import 'features/light_dashboard/domain/user_role.dart';
import 'features/light_dashboard/light_department_screen.dart';

class AltalepApp extends ConsumerWidget {
  const AltalepApp({super.key});

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'لوحة قسم أعطال خفيفة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      navigatorKey: _navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: LightDepartmentScreen(
        currentUserName: 'المستخدم',
        currentUserRole: UserRole.admin,
        initialDepartment: LightConstants.departments.first,
        onNavigateHome: () {},
      ),
    );
  }
}
