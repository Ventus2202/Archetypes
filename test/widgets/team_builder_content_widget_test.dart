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
import 'package:archetypes/presentation/screens/team_builder/team_builder_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// The team builder never resolved the keys its engine emits: objectives were
// rendered as the Dart enum names (identical in Italian and English) and
// strengths as `NI, TE`. These tests drive the real screen against the real
// assets, so a key that stops matching the content fails here.
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

  Future<void> addPerson(String name, MbtiType type) async {
    final id = await db
        .into(db.persons)
        .insert(PersonsCompanion.insert(name: name, isSelf: const Value(false)));
    await profileRepo.upsert(PersonalityProfile(
      id: 0,
      personId: id,
      system: PersonalitySystem.mbti,
      data: MbtiProfile.fromType(type).toJson(),
      confidence: 90,
      source: ProfileSource.quizLong,
      updatedAt: DateTime.now(),
    ));
  }

  // `allPersonsProvider` is a drift `.watch()` stream, which never goes idle
  // under the test clock and hangs `pumpAndSettle`. The screen only needs the
  // list, so it is served from a stream that closes.
  Future<void> pumpScreen(WidgetTester tester, {required Locale locale}) async {
    final persons = await personRepo.getAll();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        allPersonsProvider.overrideWith((ref) => Stream<List<Person>>.value(persons)),
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
        home: const TeamBuilderScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  // Objective `creative` weights Ne, Ni and Fi at or above 0.8, which is what
  // makes a function eligible as a strength or a blind spot. In this trio Ne is
  // dominant (ENFP) and Fi auxiliary, so both are strengths, while no one holds
  // Ni in their top four: exactly one blind spot.
  Future<void> addTrio() async {
    await addPerson('Ada', MbtiType.enfp);
    await addPerson('Bea', MbtiType.estj);
    await addPerson('Cleo', MbtiType.istj);
  }

  Future<void> calculate(WidgetTester tester) async {
    for (final name in ['Ada', 'Bea', 'Cleo']) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  }

  testWidgets('IT: obiettivi e punti di forza sono testo tradotto, non chiavi',
      (tester) async {
    await addTrio();
    await pumpScreen(tester, locale: const Locale('it'));

    // The dropdown used to show `obj.name`, i.e. the enum value.
    expect(find.text('Ideazione e Creatività'), findsOneWidget);
    expect(find.text('creative'), findsNothing);
    // Description of the selected objective, from `team_objectives.json`.
    expect(find.textContaining('pensiero divergente'), findsOneWidget);

    await calculate(tester);

    expect(find.textContaining('Esplorazione di alternative (Ne)'), findsOneWidget);
    expect(find.textContaining('Coerenza con i valori (Fi)'), findsOneWidget);
    expect(find.textContaining('Manca una visione a lungo termine (Ni)'),
        findsOneWidget);
    // The `ideal_profile` of the objective heads the results list.
    expect(find.textContaining('Il team ideale eccelle'), findsOneWidget);
    // What the user read before: the bare cognitive-function labels.
    expect(find.text('NE, FI'), findsNothing);
    expect(find.textContaining('strength_'), findsNothing);
    expect(find.textContaining('blindspot_'), findsNothing);
  });

  testWidgets('EN: the same screen reads in English, not in Italian',
      (tester) async {
    await addTrio();
    await pumpScreen(tester, locale: const Locale('en'));

    expect(find.text('Ideation and Creativity'), findsOneWidget);
    expect(find.text('Ideazione e Creatività'), findsNothing);

    await calculate(tester);

    expect(find.textContaining('Exploring alternatives (Ne)'), findsOneWidget);
    expect(find.textContaining('No long-term vision (Ni)'), findsOneWidget);
    expect(find.textContaining('The ideal team excels'), findsOneWidget);
  });
}
