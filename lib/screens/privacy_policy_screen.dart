import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Last updated: January 2025',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 24),

            _PolicySection(
              title: '1. Information We Collect',
              body:
                  'CalcX Pro does not collect, store, or share any personal information. All calculations, history, and settings are stored locally on your device only using Hive local database. No account or login is required.',
            ),
            _PolicySection(
              title: '2. Internet Usage',
              body:
                  'CalcX Pro uses the internet solely to fetch live currency exchange rates for the Currency Converter feature. No personal data is sent during these requests. If no internet connection is available, the app uses the last known rates.',
            ),
            _PolicySection(
              title: '3. Data Storage',
              body:
                  'All your calculation history and app preferences are stored locally on your device. This data never leaves your device and is not accessible to us or any third party.',
            ),
            _PolicySection(
              title: '4. Third-Party Services',
              body:
                  'The Currency Converter feature fetches exchange rate data from a public API. This request contains no personal information. Please refer to the respective API provider\'s privacy policy for their data practices.',
            ),
            _PolicySection(
              title: '5. Permissions',
              body:
                  'CalcX Pro may request internet permission (for currency rates) and vibration permission (for haptic feedback on button presses). No other sensitive permissions are required.',
            ),
            _PolicySection(
              title: '6. Children\'s Privacy',
              body:
                  'CalcX Pro does not knowingly collect any information from children under 13. The app contains no user accounts, no data collection, and is safe for all ages.',
            ),
            _PolicySection(
              title: '7. Changes to This Policy',
              body:
                  'We may update this Privacy Policy from time to time. Any changes will be reflected in the app with an updated date. Continued use of the app after changes constitutes your acceptance of the updated policy.',
            ),
            _PolicySection(
              title: '8. Contact Us',
              body:
                  'If you have any questions about this Privacy Policy, feel free to contact us through the app\'s listing page on Google Play Store.',
            ),

            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'In short: CalcX Pro does not collect your personal data. Everything stays on your device.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
