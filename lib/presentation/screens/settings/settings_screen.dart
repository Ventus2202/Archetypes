import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import '../../../core/constants.dart';
import '../../../core/platform/file_download.dart';
import '../../../domain/entities/personality_profile.dart';
import '../../../domain/personality_systems/mbti/mbti_profile.dart';
import '../../../domain/sharing/shared_profile.dart';
import '../../providers/settings_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/person_provider.dart';
import '../../providers/group_provider.dart';
import '../person_edit/person_edit_screen.dart';

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
              'Profilo',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: cs.primary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(l10n.settingsShareProfile),
            onTap: () => _shareMyProfile(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.content_paste_outlined),
            title: Text(l10n.settingsImportText),
            subtitle: Text(l10n.settingsImportTextDesc),
            onTap: () => _importFromText(context, ref),
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
            onTap: () => _exportData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.settingsImportData),
            subtitle: Text(l10n.settingsImportDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _importData(context, ref),
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

  Future<void> _shareMyProfile(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final self = await ref.read(personRepositoryProvider).getSelf();
    if (self == null) return;

    final profiles =
        await ref.read(profileRepositoryProvider).getForPerson(self.id);
    final mbti = profiles
        .where((p) => p.system == PersonalitySystem.mbti)
        .firstOrNull;
    if (mbti == null) return;

    try {
      final mbtiProfile =
          MbtiProfile.fromJson(Map<String, dynamic>.from(mbti.data));

      final shared = SharedProfile(
        name: self.name,
        type: mbtiProfile.type,
        confidence: mbti.confidence,
      );

      final payload = shared.encode();
      await SharePlus.instance.share(
        ShareParams(text: l10n.shareProfileText(payload)),
      );
    } catch (_) {}
  }

  Future<void> _importFromText(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importDialogTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.importDialogHint),
          maxLines: 5,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionCancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: Text(l10n.actionConfirm)),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    final shared = SharedProfile.decode(result);
    if (shared == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.importDialogError)));
      }
      return;
    }

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importPreviewTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                leading: const Icon(Icons.person),
                title: Text(shared.name)),
            ListTile(
                leading: const Icon(Icons.psychology),
                title: Text(shared.type.label)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.actionCancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.actionAdd)),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PersonEditScreen(sharedProfile: shared)));
    }
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final service = ref.read(dataBackupServiceProvider);
    try {
      final bytes = await service.exportToBytes();
      final fileName =
          'archetypes_backup_${DateTime.now().millisecondsSinceEpoch}.zip';
      if (kIsWeb) {
        // No dart:io / temp file on web: hand the bytes to a browser download.
        await downloadBytes(bytes, fileName, 'application/zip');
      } else {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(bytes,
                  mimeType: 'application/zip', name: fileName),
            ],
            text: 'Archetypes Backup',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore esportazione: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(dataBackupServiceProvider);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: true, // load bytes on all platforms; `path` is null on web.
    );

    final bytes = result?.files.single.bytes;
    if (bytes == null) return;

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsImportData),
        content: const Text(
            'Vuoi sostituire tutti i dati esistenti o aggiungere quelli nuovi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionCancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Aggiungi')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sostituisci')),
        ],
      ),
    );

    if (confirmed == null) return;

    try {
      await service.importFromBytes(bytes, replace: confirmed);
      ref.invalidate(allPersonsProvider);
      ref.invalidate(allGroupsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dati importati con successo')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore importazione: $e')));
      }
    }
  }
}
