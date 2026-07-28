import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/data/repositories/content_repository.dart';
import 'package:archetypes/data/repositories/profile_repository.dart';
import 'package:archetypes/domain/entities/personality_profile.dart';
import 'package:archetypes/domain/quiz/quiz_models.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_confidence.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/screens/person_edit/person_edit_screen.dart';
import 'package:archetypes/presentation/screens/quiz/quiz_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// `confidence` and `source` are what tells a real quiz result from a type picked
// by hand, and both are written by screens, not by the engines. The engine-level
// tests can't see a screen putting a constant back into the upsert, so these
// drive the actual UI and read the row back from an in-memory DB.
void main() {
  late AppDatabase db;
  late ProfileRepository profileRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    profileRepo = ProfileRepository(db);
  });

  tearDown(() => db.close());

  Future<int> addPerson(String name, {bool isSelf = false}) => db
      .into(db.persons)
      .insert(PersonsCompanion.insert(name: name, isSelf: Value(isSelf)));

  Future<void> addMbtiProfile(
    int personId, {
    required MbtiType type,
    required int confidence,
    required ProfileSource source,
  }) =>
      profileRepo.upsert(PersonalityProfile(
        id: 0,
        personId: personId,
        system: PersonalitySystem.mbti,
        data: MbtiProfile.fromType(type).toJson(),
        confidence: confidence,
        source: source,
        updatedAt: DateTime.now(),
      ));

  Future<PersonalityProfile> readMbti(int personId) async {
    final profiles = await profileRepo.getForPerson(personId);
    return profiles.firstWhere((p) => p.system == PersonalitySystem.mbti);
  }

  // Both screens under test pop themselves when they are done, so they are
  // pushed on top of a host route instead of being the root one.
  Widget hostOf(Widget screen) => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('it'), Locale('en')],
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx)
                      .push(MaterialPageRoute(builder: (_) => screen)),
                  child: const Text('apri'),
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> openScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(hostOf(screen));
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
  }

  testWidgets('QUIZ: il profilo salvato porta la confidence e la sorgente del test svolto',
      (tester) async {
    final personId = await addPerson('Io', isSelf: true);

    await openScreen(tester, const QuizScreen());

    // The app bar of the length page also reads "Test breve", so the card has to
    // be addressed through its Card.
    await tester.tap(find.descendant(
      of: find.byType(Card),
      matching: find.text('Test breve'),
    ));
    await tester.pumpAndSettle();

    // Half the questions are reverse-scored, so answering "5" to everything is
    // a perfect tie on every axis. Read the same asset the screen just loaded
    // and answer *against* each question's direction: every axis ends fully
    // negative, i.e. a decisive ISTJ at the top of the confidence range — and
    // not the ENFP the engine falls back to on a tie.
    final questions =
        await ContentRepository().loadQuizQuestions('it', QuizLength.short);
    expect(questions, isNotEmpty);

    for (final q in questions) {
      // The answer circles are the only bare digits on screen: the app bar
      // reads "Domanda N di M".
      await tester.tap(find.text(q.direction > 0 ? '1' : '5'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Salva'), findsOneWidget,
        reason: 'dopo tutte le risposte deve comparire la pagina risultati');

    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    final saved = await readMbti(personId);
    expect(MbtiProfile.fromJson(saved.data).type, MbtiType.istj);
    expect(saved.source, ProfileSource.quizShort,
        reason: 'la sorgente deve dire quale test è stato svolto');
    expect(saved.confidence, 100,
        reason: 'risposte tutte decise = massimo della scala axis-based');
  });

  testWidgets(
      'PERSON_EDIT: salvare senza toccare il tipo non declassa il profilo a manuale',
      (tester) async {
    final personId = await addPerson('Ada');
    await addMbtiProfile(personId,
        type: MbtiType.intj, confidence: 93, source: ProfileSource.quizLong);

    await openScreen(tester, PersonEditScreen(personId: personId));

    // Only the nickname changes: the MBTI section is untouched.
    await tester.enterText(find.byType(TextField).at(1), 'Adi');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    final saved = await readMbti(personId);
    expect(saved.source, ProfileSource.quizLong,
        reason: 'un salvataggio del nickname non è una dichiarazione del tipo');
    expect(saved.confidence, 93);
  });

  testWidgets('PERSON_EDIT: cambiare il tipo a mano lo rende manual e abbassa la confidence',
      (tester) async {
    final personId = await addPerson('Ada');
    await addMbtiProfile(personId,
        type: MbtiType.intj, confidence: 93, source: ProfileSource.quizLong);

    await openScreen(tester, PersonEditScreen(personId: personId));

    // The 16 type chips sit below the fold on a 800x600 test surface.
    await tester.ensureVisible(find.text('ENFP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ENFP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    final saved = await readMbti(personId);
    expect(MbtiProfile.fromJson(saved.data).type, MbtiType.enfp);
    expect(saved.source, ProfileSource.manual);
    expect(saved.confidence, kSelfDeclaredConfidence,
        reason: 'un tipo scelto a occhio non eredita la certezza di un quiz');
  });
}
