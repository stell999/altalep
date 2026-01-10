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
      home: _SessionGate(navigatorKey: _navigatorKey),
    );
  }
}

class _SessionGate extends StatefulWidget {
  const _SessionGate({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  String? _userName;
  UserRole? _userRole;
  String _department = 'أعطال خفيفة';

  void _startSession(String name, UserRole role, String department) {
    setState(() {
      _userName = name;
      _userRole = role;
      _department = department;
    });
  }

  void _endSession() {
    setState(() {
      _userName = null;
      _userRole = null;
    });
    final context = widget.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تسجيل الخروج.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userName == null || _userRole == null) {
      return _LoginScreen(onSubmit: _startSession);
    }

    return LightDepartmentScreen(
      currentUserName: _userName!,
      currentUserRole: _userRole!,
      initialDepartment: _department,
      onNavigateHome: _endSession,
    );
  }
}

class _LoginScreen extends StatefulWidget {
  const _LoginScreen({required this.onSubmit});

  final void Function(String name, UserRole role, String department) onSubmit;

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  UserRole? _role;
  String _department = 'أعطال خفيفة';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 120,
                            child: Image.asset(
                              AppTheme.logoAsset,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.lightbulb, size: 64),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'بدء جلسة العمل',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المستخدم',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال الاسم';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UserRole>(
                      initialValue: _role,
                      decoration: const InputDecoration(labelText: 'الدور'),
                      items: const [
                        DropdownMenuItem(
                          value: UserRole.admin,
                          child: Text('مشرف'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.employee,
                          child: Text('موظف'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _role = value;
                        });
                      },
                      validator: (value) => value == null ? 'اختر الدور' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
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
                        if (value == null) return;
                        setState(() {
                          _department = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _handleSubmit,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('دخول'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(_nameController.text.trim(), _role!, _department);
  }
}
