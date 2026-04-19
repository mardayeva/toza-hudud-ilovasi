import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.contactTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const SizedBox(height: 4),
          Text(
            s.contactInfo,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.contactDesc,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 20),
          _ContactCard(
            icon: Icons.phone_outlined,
            title: s.phone,
            value: '+998 88 111 18 50',
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.telegram,
            title: 'Telegram',
            value: '@mardayeva_dilnura',
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'mardayevadilnuraa@gmail.com',
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ],
      ),
    );
  }
}
