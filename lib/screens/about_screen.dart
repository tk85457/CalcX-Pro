import 'package:flutter/material.dart';
import 'privacy_policy_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Icon + Name header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/icon/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.calculate_rounded,
                            size: 60,
                            color: colorScheme.primary,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CalcX Pro',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Version 1.0.2',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About section
            _SectionTitle(title: 'About This App'),
            const SizedBox(height: 10),
            Text(
              'CalcX Pro is a premium all-in-one calculator app offering basic, scientific, and 10+ specialized calculators. Built with a beautiful Material Design interface, smooth animations, and full dark/light theme support — your perfect everyday calculation companion.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
            ),

            const SizedBox(height: 28),

            // Features
            _SectionTitle(title: 'Features'),
            const SizedBox(height: 12),
            _FeatureItem(
                icon: Icons.calculate_rounded,
                label: 'Basic Calculator — fast & smooth'),
            _FeatureItem(
                icon: Icons.science,
                label: 'Scientific Calculator — sin, cos, tan, log & more'),
            _FeatureItem(
                icon: Icons.account_balance_wallet,
                label: 'EMI Calculator — loan planning made easy'),
            _FeatureItem(
                icon: Icons.receipt,
                label: 'GST Calculator — India GST rates built-in'),
            _FeatureItem(
                icon: Icons.percent,
                label: 'Percentage Calculator — quick % math'),
            _FeatureItem(
                icon: Icons.swap_horiz,
                label: 'Unit Converter — length, weight, temp & more'),
            _FeatureItem(
                icon: Icons.currency_exchange,
                label: 'Currency Converter — live exchange rates'),
            _FeatureItem(
                icon: Icons.cake,
                label: 'Age Calculator — exact age in years/months/days'),
            _FeatureItem(
                icon: Icons.discount,
                label: 'Discount Calculator — sale price at a glance'),
            _FeatureItem(
                icon: Icons.attach_money,
                label: 'Tax Calculator — income tax estimates'),
            _FeatureItem(
                icon: Icons.monitor_heart,
                label: 'BMI Calculator — health index tracker'),
            _FeatureItem(
                icon: Icons.history,
                label: 'Calculation History — never lose a result'),
            _FeatureItem(
                icon: Icons.dark_mode_outlined,
                label: 'Dark / Light Theme — easy on the eyes'),

            const SizedBox(height: 28),

            // Privacy Policy button
            _SectionTitle(title: 'Legal'),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.privacy_tip_outlined,
                    color: colorScheme.primary, size: 22),
              ),
              title: const Text('Privacy Policy'),
              subtitle: const Text('How we handle your data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),

            const Divider(height: 1),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.info_outline,
                    color: colorScheme.primary, size: 22),
              ),
              title: const Text('Licenses'),
              subtitle: const Text('Open source licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'CalcX Pro',
                  applicationVersion: '1.0.2',
                );
              },
            ),

            const SizedBox(height: 28),

            // Developer info
            Center(
              child: Column(
                children: [
                  Text(
                    'Made with ❤️ in India',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2025 CalcX Pro. All rights reserved.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
