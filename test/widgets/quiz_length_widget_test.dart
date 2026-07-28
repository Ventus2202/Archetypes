import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/screens/quiz/quiz_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// The full test is the only length that can reach the top of the confidence
// range, so its card says so. Asserted on rendered geometry (the pattern from
// onboarding_method_widget_test.dart) so the badge can't drift onto another card.
void main() {
  Widget wrap(AppDatabase db) => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
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

  testWidgets('il badge "Più accurato" sta sulla card del test completo',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();

    expect(find.text('Più accurato'), findsOneWidget);

    final badgeY = tester.getCenter(find.text('Più accurato')).dy;
    final longY = tester.getCenter(find.text('Test completo')).dy;
    final mediumY = tester.getCenter(find.text('Test medio')).dy;

    expect((badgeY - longY).abs(), lessThan(40),
        reason: 'il badge deve stare sulla card del test completo');
    expect(badgeY, greaterThan(mediumY));
  });
}
