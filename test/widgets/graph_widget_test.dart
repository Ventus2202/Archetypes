import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/data/repositories/group_repository.dart';
import 'package:archetypes/data/repositories/person_repository.dart';
import 'package:archetypes/data/repositories/profile_repository.dart';
import 'package:archetypes/domain/entities/person.dart';
import 'package:archetypes/domain/entities/personality_profile.dart';
import 'package:archetypes/domain/entities/relationship.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/providers/group_provider.dart';
import 'package:archetypes/presentation/providers/person_provider.dart';
import 'package:archetypes/presentation/screens/graph/graph_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// `GraphScreen` had never been pumped by a test. It watches two drift streams,
/// so both are served from streams that close (the 2026-07-30 pattern); the
/// repositories keep the real in-memory database, which is what the graph body
/// reads for profiles, group memberships and relationships.
///
/// The first test settles an open question in Epica 3: a walkthrough on
/// 2026-07-22 reported the graph looking empty right after onboarding, with
/// only the self profile in the database. It was not empty, it was throwing:
/// graphview 1.5.1 drops every single-node cluster and then indexes the list it
/// just emptied, so a graph with no edges raises RangeError inside
/// `performLayout` and renders nothing. Measured at 1, 2, 3 and 4 unconnected
/// people; a single relationship anywhere makes it pass. The screen now lays
/// edgeless graphs out itself, so both branches are pinned below.
void main() {
  late AppDatabase db;
  late PersonRepository personRepo;
  late ProfileRepository profileRepo;
  late GroupRepository groupRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    personRepo = PersonRepository(db);
    profileRepo = ProfileRepository(db);
    groupRepo = GroupRepository(db);
  });

  tearDown(() => db.close());

  Future<int> addPerson(String name,
      {MbtiType? type, bool isSelf = false}) async {
    final id = await db.into(db.persons).insert(
        PersonsCompanion.insert(name: name, isSelf: Value(isSelf)));
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

  Future<void> pumpGraph(WidgetTester tester) async {
    final persons = await personRepo.getAll();
    final groups = await groupRepo.getAll();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        allPersonsProvider
            .overrideWith((ref) => Stream<List<Person>>.value(persons)),
        allGroupsProvider
            .overrideWith((ref) => Stream<List<Group>>.value(groups)),
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
        home: GraphScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    // `_loadData` and `_buildGraph` read the database for every person and then
    // take the first event of a drift stream: that real I/O only progresses
    // under `runAsync`, so without this nudge the body never leaves its initial
    // empty graph.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pumpAndSettle();
  }

  testWidgets('subito dopo l\'onboarding il nodo "io" c\'è', (tester) async {
    await addPerson('Ada', type: MbtiType.intj, isSelf: true);

    await pumpGraph(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Grafo relazioni'), findsOneWidget);
    // The node carries the initial, the type label and the full name.
    expect(find.text('A'), findsOneWidget);
    expect(find.text('INTJ'), findsWidgets);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Aggiungi persone per visualizzare le relazioni'),
        findsNothing);
  });

  testWidgets('rubrica vuota: invito ad aggiungere, non tela bianca',
      (tester) async {
    await pumpGraph(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Aggiungi persone per visualizzare le relazioni'),
        findsOneWidget);
  });

  testWidgets('più persone senza alcuna relazione: i nodi ci sono comunque',
      (tester) async {
    await addPerson('Ada', type: MbtiType.intj, isSelf: true);
    await addPerson('Bruno', type: MbtiType.enfp);
    await addPerson('Carla');

    await pumpGraph(tester);

    // This is the shape that used to throw: nodes, no edges.
    expect(tester.takeException(), isNull);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bruno'), findsOneWidget);
    expect(find.text('Carla'), findsOneWidget);
  });

  testWidgets('due persone e una relazione: entrambi i nodi ci sono',
      (tester) async {
    final ada = await addPerson('Ada', type: MbtiType.intj, isSelf: true);
    final bruno = await addPerson('Bruno', type: MbtiType.enfp);
    await db.into(db.relationships).insert(RelationshipsCompanion.insert(
          personAId: ada,
          personBId: bruno,
          kind: Value(RelationshipKind.friendship.name),
        ));

    await pumpGraph(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bruno'), findsOneWidget);
  });

  testWidgets('il filtro per tipo MBTI toglie chi non lo ha', (tester) async {
    await addPerson('Ada', type: MbtiType.intj, isSelf: true);
    await addPerson('Bruno', type: MbtiType.enfp);

    await pumpGraph(tester);
    expect(find.text('Bruno'), findsOneWidget);

    // The filter bar scrolls horizontally, so the chip has to be brought in
    // before it can be tapped.
    final chip = find.widgetWithText(FilterChip, 'INTJ');
    await tester.scrollUntilVisible(chip, 100,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bruno'), findsNothing);
  });

  testWidgets('errore dello stream: messaggio, non tela muta', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        allPersonsProvider.overrideWith(
            (ref) => Stream<List<Person>>.error(Exception('db down'))),
        allGroupsProvider.overrideWith((ref) => Stream<List<Group>>.value([])),
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
        home: GraphScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Si è verificato un errore'), findsOneWidget);
  });
}
