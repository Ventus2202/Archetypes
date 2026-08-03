import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/data/repositories/content_repository.dart';
import 'package:archetypes/domain/quiz/quiz_models.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/providers/settings_provider.dart';
import 'package:archetypes/presentation/screens/content_viewer/content_viewer_screen.dart';
import 'package:archetypes/presentation/screens/quiz/quiz_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// `content_assets_test` pins the asset; this pins the *reader*. The two are not
// the same net: until 2026-08-03 every branch of this screen cast a field to
// the wrong type — `description` is a string and was read as a list, `poles` is
// an object and was read as a list — so all three cards threw a TypeError at
// build time. `flutter analyze` cannot see it (the value comes out of
// `jsonDecode` as `dynamic`) and a test on the JSON alone would not either:
// only pumping the screen against the real asset catches a shape mismatch.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpViewer(
    WidgetTester tester, {
    required String contentKey,
    required ContentViewerType contentType,
    Locale locale = const Locale('it'),
  }) async {
    // The screen loads the asset in a `FutureBuilder`, and real asset I/O only
    // runs under `runAsync`; warming this repository first (its cache is keyed
    // by locale) makes the future resolve in a microtask once pumped.
    final repo = ContentRepository();
    await tester.runAsync(() => repo.loadMbtiContent(locale.languageCode));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        localeProvider.overrideWithValue(locale),
        contentRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('it'), Locale('en')],
        home: ContentViewerScreen(
          contentKey: contentKey,
          contentType: contentType,
        ),
      ),
    ));
    // Not `pumpAndSettle`: the loading branch is a `CircularProgressIndicator`,
    // an endless animation that keeps scheduling frames, so settling never
    // happens. Two pumps are enough for the asset future to complete.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('scheda tipo: rende titolo, descrizione, stack e liste',
      (tester) async {
    await pumpViewer(
      tester,
      contentKey: 'INTJ',
      contentType: ContentViewerType.mbtiType,
    );

    expect(tester.takeException(), isNull);
    expect(find.text("L'Architetto"), findsOneWidget);
    // `description` is one string with blank-line separated paragraphs: all
    // three have to reach the screen, not just the first.
    expect(find.textContaining('Combinano immaginazione'), findsOneWidget);
    expect(find.textContaining('Il loro tallone d\'Achille'), findsOneWidget);
    // Stack chips, in stack order, with the position labels.
    expect(find.text('Ni (Dominante)'), findsOneWidget);
    expect(find.text('Se (Inferiore)'), findsOneWidget);
    expect(find.text('Pensiero sistemico e strategico a lungo termine'),
        findsOneWidget);
    // Two sections whose content and ARB labels were both already there and
    // which no screen rendered until 2026-08-03.
    expect(find.text('Esempi celebri'), findsOneWidget);
    expect(find.text('Tyrion Lannister (GoT)'), findsOneWidget);
    expect(find.text('Alta affinità'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'ENFP'), findsOneWidget);
  });

  testWidgets('scheda funzione: rende nome esteso e le quattro posizioni',
      (tester) async {
    await pumpViewer(
      tester,
      contentKey: 'Ni',
      contentType: ContentViewerType.mbtiFunction,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Intuizione Interiore'), findsOneWidget);
    expect(find.text('Introverted Intuition'), findsOneWidget);
    expect(find.textContaining('funzione della visione profonda'),
        findsOneWidget);
    expect(find.textContaining("L'INTJ e l'INFJ vivono guidati"), findsOneWidget);
  });

  testWidgets('scheda dicotomia: rende i due poli, i marker e i miti',
      (tester) async {
    await pumpViewer(
      tester,
      contentKey: 'IE',
      contentType: ContentViewerType.mbtiDichotomy,
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('è un continuum, non un binario'), findsOneWidget);
    // Both poles, in the order the axis names them.
    expect(find.text('Introversione'), findsOneWidget);
    expect(find.text('Estroversione'), findsOneWidget);
    expect(find.text('Preferiscono conversazioni profonde a piccole chiacchiere'),
        findsOneWidget);
    expect(find.textContaining("Mito: L'introverso è timido"), findsOneWidget);
  });

  testWidgets('EN: la stessa scheda si legge in inglese', (tester) async {
    await pumpViewer(
      tester,
      contentKey: 'INTJ',
      contentType: ContentViewerType.mbtiType,
      locale: const Locale('en'),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('The Architect'), findsOneWidget);
    expect(find.text("L'Architetto"), findsNothing);
    expect(find.text('Ni (Dominant)'), findsOneWidget);
  });

  // The dichotomy content had no caller at all: four axes written in both
  // languages that no screen could reach. The quiz results page is where the
  // user is looking at those exact four axes, so that is where they open from.
  testWidgets('i risultati del quiz aprono la scheda della dicotomia',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repo = ContentRepository();
    final questions = await tester.runAsync(() async {
      await repo.loadMbtiContent('it');
      return repo.loadQuizQuestions('it', QuizLength.short);
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        localeProvider.overrideWithValue(const Locale('it')),
        contentRepositoryProvider.overrideWithValue(repo),
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
        home: QuizScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(
      of: find.byType(Card),
      matching: find.text('Test breve'),
    ));
    // `loadQuizQuestions` is the one loader with no cache, so the screen reads
    // the asset for real here: the pending I/O only completes under `runAsync`,
    // and without this the length page never gives way to question 1.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    for (var i = 0; i < questions!.length; i++) {
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Introversione / Estroversione'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.text('Introversione'), findsOneWidget);
    expect(find.text('Estroversione'), findsOneWidget);
    expect(find.textContaining("Mito: L'introverso è timido"), findsOneWidget);
  });

  testWidgets('chiave inesistente: errore, non schermata vuota', (tester) async {
    await pumpViewer(
      tester,
      contentKey: 'XXXX',
      contentType: ContentViewerType.mbtiType,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Contenuto non trovato'), findsOneWidget);
  });
}
