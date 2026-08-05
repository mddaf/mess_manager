import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/theme_toggle.dart';

class MessSettingsScreen extends StatelessWidget {
  final String messId;

  const MessSettingsScreen({super.key, required this.messId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code_rounded, size: 32),
              title: Text(l10n.inviteCode),
              subtitle: const Text('Share code with new flatmates to join'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'MESS88',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_pin_circle_rounded),
                  title: Text(l10n.currentManager),
                  subtitle: const Text('Fayed Rahman (Assigned for August)'),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('Rotate'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time_filled_rounded),
                  title: Text(l10n.cutoffTime),
                  subtitle: const Text('Daily cutoff at 10:00 PM'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l10n.language),
                  trailing: const LanguageSwitcherButton(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode_rounded),
                  title: Text(l10n.darkMode),
                  trailing: const ThemeToggleIconButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
