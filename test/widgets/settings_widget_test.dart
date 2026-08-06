import 'dart:convert';
import 'dart:typed_data';

import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/domain/sharing/data_backup.dart';
import 'package:archetypes/domain/sharing/shared_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/providers/settings_provider.dart';
import 'package:archetypes/presentation/screens/person_edit/person_edit_screen.dart';
import 'package:archetypes/presentation/screens/settings/settings_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// `SettingsScreen` had never been pumped by a test, and it holds the whole
/// backup UI — the one flow the backlog records as never verified at runtime:
/// every test so far called `DataBackupService` directly, so the dialog, the
/// replace/merge choice and the snackbar that reports dropped rows were code
/// nobody had run.
///
/// Two branches stay out of reach here and remain untested: export (`SharePlus`
/// on native, a browser download on web) and `_shareMyProfile`, both of which
/// need platform channels this harness cannot serve.

/// Keeps Hive out of the widget test — `SettingsNotifier.build()` opens a box.
/// Same approach as `app_gate_widget_test`, which overrides the two derived
/// providers for the same reason.
class _FakeSettings extends SettingsNotifier {
  @override
  ({ThemeMode themeMode, Locale locale}) build() =>
      (themeMode: ThemeMode.system, locale: const Locale('it'));

  @override
  void setThemeMode(ThemeMode mode) =>
      state = (themeMode: mode, locale: state.locale);

  @override
  void setLocale(Locale locale) =>
      state = (themeMode: state.themeMode, locale: locale);
}

/// `FilePicker.platform` is a settable static, so the import flow can be driven
/// without a file dialog: this hands the screen the bytes it would have picked.
class _StubFilePicker extends FilePicker {
  _StubFilePicker(this.bytes);

  final Uint8List? bytes;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    if (bytes == null) return null;
    return FilePickerResult([
      PlatformFile(name: 'backup.zip', size: bytes!.length, bytes: bytes),
    ]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppDatabase> seededDatabase() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  Future<void> pumpSettings(WidgetTester tester, AppDatabase db) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsProvider.overrideWith(_FakeSettings.new),
      ],
      child: const MaterialApp(
        locale: Locale('it'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('it'), Locale('en')],
        home: SettingsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('rende le quattro sezioni e la versione', (tester) async {
    await pumpSettings(tester, await seededDatabase());

    expect(tester.takeException(), isNull);
    expect(find.text('Impostazioni'), findsOneWidget);
    expect(find.text('Scuro'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Condividi il mio profilo'), findsOneWidget);
    expect(find.text('Importa da testo'), findsOneWidget);
    expect(find.text('Esporta dati'), findsOneWidget);
    expect(find.text('Importa dati'), findsOneWidget);

    // The About tile sits below the fold of the default test viewport, so the
    // list has to be scrolled before it is built at all.
    await tester.scrollUntilVisible(find.text('Informazioni'), 200);
    await tester.pumpAndSettle();
    expect(find.text('Versione 1.0.0'), findsOneWidget);
  });

  testWidgets('il selettore del tema aggiorna lo stato', (tester) async {
    final db = await seededDatabase();
    late WidgetRef capturedRef;

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        settingsProvider.overrideWith(_FakeSettings.new),
      ],
      child: MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('it'), Locale('en')],
        home: Consumer(builder: (context, ref, _) {
          capturedRef = ref;
          return const SettingsScreen();
        }),
      ),
    ));
    await tester.pumpAndSettle();

    expect(capturedRef.read(themeModeProvider), ThemeMode.system);

    await tester.tap(find.text('Scuro'));
    await tester.pumpAndSettle();
    expect(capturedRef.read(themeModeProvider), ThemeMode.dark);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(capturedRef.read(localeProvider).languageCode, 'en');
  });

  testWidgets('import da testo: un payload valido porta alla scheda persona',
      (tester) async {
    await pumpSettings(tester, await seededDatabase());

    await tester.tap(find.text('Importa da testo'));
    await tester.pumpAndSettle();

    expect(find.text('Importa profilo'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      SharedProfile(name: 'Ada', type: MbtiType.intj, confidence: 90).encode(),
    );
    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();

    // Preview: the name and the type the payload carried.
    expect(find.text('Anteprima importazione'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('INTJ'), findsOneWidget);

    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(PersonEditScreen), findsOneWidget);
  });

  testWidgets('import da testo: un payload illeggibile lo dice',
      (tester) async {
    await pumpSettings(tester, await seededDatabase());

    await tester.tap(find.text('Importa da testo'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'non un profilo');
    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();

    expect(find.text('Anteprima importazione'), findsNothing);
    expect(find.text('Codice non valido o versione non supportata'),
        findsOneWidget);
  });

  testWidgets('import backup: lo ZIP scelto entra nel DB e la snackbar lo dice',
      (tester) async {
    // A real archive, produced by the real exporter from a separate database.
    final source = AppDatabase(NativeDatabase.memory());
    addTearDown(source.close);
    await source.into(source.persons).insert(
        PersonsCompanion.insert(name: 'Ada', isSelf: const Value(true)));
    final backup = await DataBackupService(source).exportToBytes();

    final target = await seededDatabase();
    FilePicker.platform = _StubFilePicker(backup);

    await pumpSettings(tester, target);
    await tester.tap(find.text('Importa dati'));
    await tester.pumpAndSettle();

    expect(find.text('Sostituisci'), findsOneWidget);
    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Dati importati con successo'), findsOneWidget);
    expect((await target.select(target.persons).get()).single.name, 'Ada');
  });

  testWidgets('import backup: annullare la scelta non tocca il DB',
      (tester) async {
    final source = AppDatabase(NativeDatabase.memory());
    addTearDown(source.close);
    await source
        .into(source.persons)
        .insert(PersonsCompanion.insert(name: 'Ada'));
    final backup = await DataBackupService(source).exportToBytes();

    final target = await seededDatabase();
    FilePicker.platform = _StubFilePicker(backup);

    await pumpSettings(tester, target);
    await tester.tap(find.text('Importa dati'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(await target.select(target.persons).get(), isEmpty);
    expect(find.text('Dati importati con successo'), findsNothing);
  });

  testWidgets('import backup: un archivio rotto non passa in silenzio',
      (tester) async {
    final target = await seededDatabase();
    FilePicker.platform =
        _StubFilePicker(Uint8List.fromList(utf8.encode('not a zip')));

    await pumpSettings(tester, target);
    await tester.tap(find.text('Importa dati'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The message the user reads is still a hardcoded Italian string with the
    // raw exception appended (backlog: three of those live in this screen);
    // what the test pins is that the failure is reported at all.
    expect(find.textContaining('Errore importazione:'), findsOneWidget);
    expect(await target.select(target.persons).get(), isEmpty);
  });
}
