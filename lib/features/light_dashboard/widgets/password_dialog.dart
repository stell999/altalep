import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key, required this.requiredPassword});

  final String requiredPassword;

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  late final TextEditingController _controller;
  String? _error;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): const _DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _DismissIntent: CallbackAction<_DismissIntent>(
            onInvoke: (intent) {
              Navigator.of(context).pop(false);
              return null;
            },
          ),
        },
        child: FocusScope(
          autofocus: true,
          child: AlertDialog(
            title: const Text('تأكيد الخروج'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('أدخل كلمة مرور المشرف للعودة إلى لوحة التحكم:'),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  obscureText: _obscure,
                  autofocus: true,
                  onSubmitted: (_) => _validatePassword(),
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    errorText: _error,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: _validatePassword,
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validatePassword() {
    if (_controller.text.trim() == widget.requiredPassword) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _error = 'كلمة المرور غير صحيحة';
      });
    }
  }
}

class _DismissIntent extends Intent {
  const _DismissIntent();
}
