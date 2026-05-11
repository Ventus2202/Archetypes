import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../../core/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n.settingsTheme,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined),
                    label: Text(l10n.settingsThemeSystem)),
                ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(l10n.settingsThemeLight)),
                ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(l10n.settingsThemeDark)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => notifier.setThemeMode(s.first),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.settingsLanguage,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'it', label: Text(l10n.languageIt)),
                ButtonSegment(
                    value: 'en', label: Text(l10n.languageEn)),
              ],
              selected: {settings.locale.languageCode},
              onSelectionChanged: (s) =>
                  notifier.setLocale(Locale(s.first)),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Dati',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: Text(l10n.settingsExportData),
            subtitle: Text(l10n.settingsExportDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.settingsImportData),
            subtitle: Text(l10n.settingsImportDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showComingSoon(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAbout),
            subtitle: Text(l10n.settingsVersion(kAppVersion)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funzionalità in arrivo')),
    );
  }
}
