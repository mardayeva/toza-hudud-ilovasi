import 'package:flutter/material.dart';
import 'driver_login_screen.dart';
import 'contact_screen.dart';
import 'auth_screen.dart';
import '../l10n/app_strings.dart';
import '../l10n/locale_controller.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.eco_outlined, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.appTitle,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(s.appSubtitle,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _DrawerTile(
              icon: Icons.local_shipping_outlined,
              title: s.driverLogin,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DriverLoginScreen()),
              ),
            ),
            _DrawerTile(
              icon: Icons.language,
              title: s.language,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(s.uzbek),
                        onTap: () {
                          LocaleController.setLocale(const Locale('uz'));
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text(s.russian),
                        onTap: () {
                          LocaleController.setLocale(const Locale('ru'));
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            _DrawerTile(
              icon: Icons.support_agent,
              title: s.contact,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactScreen()),
              ),
            ),
            const SizedBox(height: 8),
            _DrawerTile(
              icon: Icons.logout,
              title: s.changeArea,
              onTap: () async {
                await AuthService().logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon, color: const Color(0xFF0D631B)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
