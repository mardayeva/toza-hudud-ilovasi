import 'package:flutter/material.dart';

import '../data/surxondaryo_db.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../l10n/app_strings.dart';
import '../theme.dart';
import 'jadval_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Tuman? _selectedTuman;
  String? _selectedMahalla;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedTuman = SurxondaryoDB.tumanlar.first;
    _selectedMahalla = _selectedTuman!.mahallalar.first;
  }

  void _onTumanChanged(Tuman? value) {
    setState(() {
      _selectedTuman = value ?? SurxondaryoDB.tumanlar.first;
      _selectedMahalla = _selectedTuman!.mahallalar.first;
    });
  }

  void _onMahallaChanged(String? value) {
    setState(() {
      _selectedMahalla = value ?? (_selectedTuman?.mahallalar.first ?? '');
    });
  }

  Future<void> _continueToApp() async {
    final tuman = _selectedTuman ?? SurxondaryoDB.tumanlar.first;
    final mahalla = _selectedMahalla ?? tuman.mahallalar.first;

    setState(() {
      _loading = true;
    });

    await AuthService().saveResidentProfile(
      tumanId: tuman.id,
      tumanName: tuman.nomi,
      mahalla: mahalla,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => JadvalScreen(
          tumanId: tuman.id,
          tumanNomi: tuman.nomi,
          mahallaNomi: mahalla,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final selectedTuman = _selectedTuman ?? SurxondaryoDB.tumanlar.first;
    final mahallalar = selectedTuman.mahallalar;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Container(
              height: 190,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 92,
                      height: 92,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Image.asset(
                        'assets/logo.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        s.selectAreaTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.selectAreaSubtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.start,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.oneTimeAreaHint,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Tuman>(
                    value: selectedTuman,
                    items: SurxondaryoDB.tumanlar
                        .map(
                          (tuman) => DropdownMenuItem<Tuman>(
                            value: tuman,
                            child: Text(tuman.nomi),
                          ),
                        )
                        .toList(),
                    onChanged: _onTumanChanged,
                    decoration: InputDecoration(
                      labelText: s.districts,
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: mahallalar.contains(_selectedMahalla)
                        ? _selectedMahalla
                        : mahallalar.first,
                    items: mahallalar
                        .map(
                          (mahalla) => DropdownMenuItem<String>(
                            value: mahalla,
                            child: Text(mahalla),
                          ),
                        )
                        .toList(),
                    onChanged: _onMahallaChanged,
                    decoration: InputDecoration(
                      labelText: s.neighborhoods,
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _continueToApp,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(s.continueLabel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
