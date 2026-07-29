import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/data/repositories/content_repository.dart';
import 'package:archetypes/domain/quiz/quiz_models.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/screens/quiz/quiz_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// `ContentRepository.loadQuizQuestions` turns *any* failure into an empty list
/// (asset missing from the bundle, malformed JSON, a file the PWA never
/// downloaded). This stands in for that case without needing a broken asset.
class _EmptyQuizRepository extends ContentRepository {
  @override
  Future<List<QuizQuestion>> loadQuizQuestions(
          String languageCode, QuizLength length) async =>
      const [];
}

// Before the fix this combination produced a red screen: `_buildQuestion`
// indexed an empty list, and `_selectedLength` was already set so there was no
// way back to the length choice.
void main() {
  Widget wrap(AppDatabase db) => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          contentRepositoryProvider.overrideWithValue(_EmptyQuizRepository()),
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
      );

  testWidgets('un asset del quiz non caricabile dà un errore, non un crash',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(
      of: find.byType(Card),
      matching: find.text('Test breve'),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull,
        reason: 'nessuna eccezione: prima qui arrivava un RangeError');
    expect(
        find.text('Non è stato possibile caricare le domande di questo test.'),
        findsOneWidget);

    // And the screen is not a dead end: the other lengths may load fine.
    await tester.tap(find.text('Indietro'));
    await tester.pumpAndSettle();

    expect(find.text('Test completo'), findsOneWidget,
        reason: 'si deve poter tornare alla scelta della lunghezza');
  });
}
