import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme.dart';
import 'main_screens.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _username = TextEditingController();
  final _name = TextEditingController();
  final _pass = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  String _error = '';

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    final svc = AuthService();
    final res = _isLogin
        ? await svc.login(
            username: _username.text.trim(),
            password: _pass.text,
          )
        : await svc.register(
            username: _username.text.trim(),
            fullName: _name.text.trim(),
            password: _pass.text,
          );

    if (res == null) {
      setState(() {
        _error = 'Login yoki ma\'lumot noto\'g\'ri';
        _loading = false;
      });
      return;
    }

    final fullName = (res['full_name'] ??
            (_name.text.trim().isNotEmpty
                ? _name.text.trim()
                : _username.text.trim()))
        .toString();

    await svc.saveToken((res['token'] ?? 'demo_token').toString());
    await svc.saveUserProfile(fullName);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TumanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? 'Kirish' : 'Ro\'yxatdan o\'tish';
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('ChiqindiNav'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tizimga kirib, hududingiz bo‘yicha jadval va bildirishnomalarni kuzating.',
            style: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.eco_outlined, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _username,
                  decoration: const InputDecoration(
                    labelText: 'Login',
                    hintText: 'Login (ism yoki nick)',
                  ),
                ),
                if (!_isLogin) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'F.I.Sh',
                      hintText: 'To‘liq ism familiya',
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Parol',
                  ),
                ),
                const SizedBox(height: 14),
                if (_error.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _error,
                      style: const TextStyle(
                        color: AppTheme.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (_error.isNotEmpty) const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isLogin ? 'Kirish' : 'Ro\'yxatdan o\'tish'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => setState(() {
                    _isLogin = !_isLogin;
                    _error = '';
                  }),
                  child: Text(_isLogin ? 'Ro\'yxatdan o\'tish' : 'Kirish'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
