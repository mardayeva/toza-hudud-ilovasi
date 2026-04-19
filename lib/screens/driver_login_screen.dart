import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'driver_screen.dart';
import '../l10n/app_strings.dart';
import '../theme.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _login = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String _error = '';

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    final res = await AuthService().driverLogin(
      login: _login.text.trim(),
      password: _pass.text,
    );
    if (res == null) {
      setState(() {
        _error = AppStrings.of(context).loginError;
        _loading = false;
      });
      return;
    }
    await AuthService().saveDriverToken((res['token'] ?? 'demo_token').toString());
    await AuthService().saveDriverProfile(
      fullName: (res['full_name'] ?? 'Haydovchi demo').toString(),
      vehicleNumber: (res['vehicle_number'] ?? '60 A 123 BA').toString(),
      login: _login.text.trim(),
      driverId: int.tryParse('${res['driver_id']}'),
      tumanId: int.tryParse('${res['tuman_id']}'),
      mahalla: res['mahalla']?.toString(),
    );
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DriverScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.driverLogin)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            s.driverMode,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Haydovchi hisobiga kirib, GPS va jadval ma\'lumotlarini yuboring.',
            style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _login,
                  decoration: InputDecoration(labelText: s.login),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: InputDecoration(labelText: s.password),
                ),
                const SizedBox(height: 14),
                if (_error.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _error,
                      style: const TextStyle(color: AppTheme.danger, fontSize: 12),
                    ),
                  ),
                if (_error.isNotEmpty) const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? Text(s.wait)
                        : Text(s.signIn),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
