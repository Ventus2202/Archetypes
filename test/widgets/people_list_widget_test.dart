import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/data/repositories/person_repository.dart';
import 'package:archetypes/data/repositories/profile_repository.dart';
import 'package:archetypes/domain/entities/person.dart';
import 'package:archetypes/domain/entities/personality_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/providers/person_provider.dart';
import 'package:archetypes/presentation/screens/people_list/people_list_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// `PeopleListScreen` was the screen the earlier widget tests explicitly walked
/// around: it subscribes to a drift `.watch()` stream, which never goes idle
/// under the test clock and hangs `pumpAndSettle`. Serving the same list from a
/// stream that closes (the pattern the team builder proved on 2026-07-30) is
/// enough — the repositories keep the real in-memory database underneath, so
/// the per-tile MBTI lookup is real work.
void main() {
  late AppDatabase db;
  late PersonRepository personRepo;
  late ProfileRepository profileRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    personRepo = PersonRepository(db);
    profileRepo = ProfileRepository(db);
  });

  tearDown(() => db.close());

  Future<int> addPerson(
    String name, {
    MbtiType? type,
    bool isSelf = false,
    PersonRole role = PersonRole.friend,
    String? nickname,
  }) async {
    final id = await db.into(db.persons).insert(PersonsCompanion.insert(
          name: name,
          nickname: Value(nickname),
          role: Value(role.name),
          isSelf: Value(isSelf),
        ));
    if (type != null) {
      await profileRepo.upsert(PersonalityProfile(
        id: 0,
        personId: id,
        system: PersonalitySystem.mbti,
        data: MbtiProfile.fromType(type).toJson(),
        confidence: 90,
        source: ProfileSource.quizLong,
        updatedAt: DateTime(2026, 8, 6),
      ));
    }
    return id;
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    final persons = await personRepo.getAll();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        allPersonsProvider
            .overrideWith((ref) => Stream<List<Person>>.value(persons)),
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
        home: PeopleListScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('rubrica vuota: invito ad aggiungere, non lista bianca',
      (tester) async {
    await pumpScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Nessuna persona aggiunta ancora'), findsOneWidget);
    expect(find.text('Aggiungi la tua prima persona'), findsOneWidget);
  });

  testWidgets('rende nome, ruolo e badge del tipo, e nasconde il profilo self',
      (tester) async {
    await addPerson('Ada', type: MbtiType.intj);
    await addPerson('Bruno', role: PersonRole.colleague);
    await addPerson('Io', isSelf: true, type: MbtiType.enfp);

    await pumpScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('INTJ'), findsOneWidget);
    expect(find.text('Bruno'), findsOneWidget);
    expect(find.text('Collega'), findsOneWidget);
    // Bruno has no profile: the badge is absent, not an empty box.
    expect(find.text('Amico/a'), findsOneWidget);
    // The list is the address book, so the owner is not in it.
    expect(find.text('Io'), findsNothing);
    expect(find.text('ENFP'), findsNothing);
  });

  testWidgets('il nickname vince sul nome, come displayName promette',
      (tester) async {
    await addPerson('Adelaide', nickname: 'Ada', type: MbtiType.intj);

    await pumpScreen(tester);

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Adelaide'), findsNothing);
  });

  testWidgets('la ricerca filtra e dice quando non trova nulla',
      (tester) async {
    await addPerson('Ada');
    await addPerson('Bruno');

    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ada');
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bruno'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Nessun risultato per "zzz"'), findsOneWidget);
    // A search that matches nothing must not fall back to the empty-address-book
    // view, which invites adding a first person to a book that is not empty.
    expect(find.text('Nessuna persona aggiunta ancora'), findsNothing);

    // Closing the search restores the full list.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bruno'), findsOneWidget);
  });

  testWidgets('errore dello stream: messaggio, non schermata muta',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        allPersonsProvider.overrideWith(
            (ref) => Stream<List<Person>>.error(Exception('db down'))),
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
        home: PeopleListScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Si è verificato un errore'), findsOneWidget);
  });
}
