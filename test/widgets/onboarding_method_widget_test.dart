import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// The in-app test is the path we want people to take: it produces a real
// profile with a confidence value instead of a self-declared type. These tests
// pin that recommendation so a later edit can't silently undo it.
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
          home: OnboardingScreen(),
        ),
      );

  /// Walks past the name page onto the method page.
  Future<void> goToMethodPage(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, 'Ada');
    await tester.tap(find.text('Avanti'));
    await tester.pumpAndSettle();
  }

  testWidgets('il metodo consigliato è il test in-app, preselezionato',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();
    await goToMethodPage(tester);

    expect(find.text('Test in-app'), findsOneWidget);
    expect(find.text('Consigliato'), findsOneWidget);

    // Preselected: exactly one card shows the check, and it is the test one.
    final check = find.byIcon(Icons.check_circle);
    expect(check, findsOneWidget);

    final checkY = tester.getCenter(check).dy;
    final testY = tester.getCenter(find.text('Test in-app')).dy;
    final manualY = tester.getCenter(find.text('Selezione manuale')).dy;
    expect((checkY - testY).abs(), lessThan(40),
        reason: 'il check deve stare sulla card del test, non su un\'altra');

    // Recommended option is listed first.
    expect(testY, lessThan(manualY));
  });

  testWidgets('il badge sta sulla card del test, non sulle altre',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();
    await goToMethodPage(tester);

    final badgeY = tester.getCenter(find.text('Consigliato')).dy;
    final testY = tester.getCenter(find.text('Test in-app')).dy;
    final granularY = tester.getCenter(find.text('Inserimento granulare')).dy;

    expect((badgeY - testY).abs(), lessThan(40));
    expect(badgeY, lessThan(granularY));
  });

  testWidgets('le altre opzioni restano selezionabili', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();
    await goToMethodPage(tester);

    await tester.tap(find.text('Selezione manuale'));
    await tester.pumpAndSettle();

    final check = find.byIcon(Icons.check_circle);
    expect(check, findsOneWidget);
    expect(
      (tester.getCenter(check).dy -
              tester.getCenter(find.text('Selezione manuale')).dy)
          .abs(),
      lessThan(40),
      reason: 'la selezione deve spostarsi sulla card toccata',
    );
    // The recommendation badge stays put regardless of what is selected.
    expect(find.text('Consigliato'), findsOneWidget);
  });
}
