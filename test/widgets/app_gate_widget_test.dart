import 'package:archetypes/app.dart';
import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/presentation/home_shell.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/providers/person_provider.dart';
import 'package:archetypes/presentation/providers/settings_provider.dart';
import 'package:archetypes/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Pumps the real ArchetypesApp so _AppGate/_GateError (both private) are the
// actual code under test. ArchetypesApp only watches themeModeProvider and
// localeProvider (never settingsProvider directly), so overriding those two
// keeps Hive out of the test. hasOnboardedProvider drives which branch renders.
void main() {
  Widget wrap(AppDatabase db, Override onboarded) => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          themeModeProvider.overrideWithValue(ThemeMode.light),
          localeProvider.overrideWithValue(const Locale('it')),
          onboarded,
        ],
        child: const ArchetypesApp(),
      );

  testWidgets('GATE: a real getSelf() error shows the error screen, not HomeShell',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(wrap(
      db,
      hasOnboardedProvider.overrideWith((ref) async {
        throw Exception('db boom');
      }),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Si è verificato un errore'), findsOneWidget);
    expect(find.textContaining('db boom'), findsOneWidget);
    expect(find.text('Riprova'), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(HomeShell), findsNothing);
  });

  testWidgets('GATE: not onboarded shows OnboardingScreen, no error',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(wrap(
      db,
      hasOnboardedProvider.overrideWith((ref) async => false),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Si è verificato un errore'), findsNothing);
  });
}
