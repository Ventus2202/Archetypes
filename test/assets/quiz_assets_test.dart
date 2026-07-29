import 'package:archetypes/data/repositories/content_repository.dart';
import 'package:archetypes/domain/quiz/quiz_models.dart';
import 'package:flutter_test/flutter_test.dart';

// Until 2026-07-29 the three quiz assets were byte-identical 16-question files
// while the UI advertised three lengths and badged the longest as "most
// accurate", so `ProfileSource.quizShort/Medium/Long` recorded three names for
// one questionnaire. These tests assert the structure of the shipped assets, so
// that class of lie cannot come back silently.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const locales = ['it', 'en'];
  const expectedCount = {
    QuizLength.short: 16,
    QuizLength.medium: 48,
    QuizLength.long: 80,
  };
  const axes = {'IE', 'NS', 'TF', 'JP'};

  final repo = ContentRepository();

  Future<List<QuizQuestion>> load(String locale, QuizLength length) =>
      repo.loadQuizQuestions(locale, length);

  for (final locale in locales) {
    group('assets/quiz/$locale', () {
      for (final entry in expectedCount.entries) {
        final length = entry.key;
        final count = entry.value;

        test('${length.name}: ha $count domande ben formate', () async {
          final questions = await load(locale, length);

          // `loadQuizQuestions` swallows every failure into an empty list, so a
          // missing or malformed asset shows up here as a count mismatch.
          expect(questions, hasLength(count));

          expect(questions.map((q) => q.id).toSet(), hasLength(count),
              reason: 'gli id devono essere unici');
          expect(questions.map((q) => q.text).toSet(), hasLength(count),
              reason: 'nessuna domanda duplicata');

          for (final q in questions) {
            expect(q.text.trim(), isNotEmpty);
            expect(axes, contains(q.axis));
            expect(q.direction, anyOf(1, -1));
            expect(q.weight, greaterThan(0));
          }
        });

        test('${length.name}: ogni asse è bilanciato', () async {
          final questions = await load(locale, length);

          for (final axis in axes) {
            final onAxis = questions.where((q) => q.axis == axis);
            expect(onAxis, hasLength(count ~/ 4),
                reason: 'asse $axis: stesso numero di domande per asse');

            final forward = onAxis.where((q) => q.direction > 0).length;
            final reverse = onAxis.where((q) => q.direction < 0).length;
            // Half the items on each axis are reverse-scored, so answering the
            // same value to everything is a perfect tie instead of a fake type.
            expect(forward, reverse,
                reason: 'asse $axis: item diretti e invertiti pari');
          }
        });
      }

      test('le tre lunghezze sono davvero diverse e annidate', () async {
        final short = await load(locale, QuizLength.short);
        final medium = await load(locale, QuizLength.medium);
        final long = await load(locale, QuizLength.long);

        final shortTexts = short.map((q) => q.text).toSet();
        final mediumTexts = medium.map((q) => q.text).toSet();
        final longTexts = long.map((q) => q.text).toSet();

        expect(shortTexts.length, lessThan(mediumTexts.length));
        expect(mediumTexts.length, lessThan(longTexts.length));

        // Nesting: a longer test asks everything the shorter one asks plus more,
        // so results stay comparable across lengths.
        expect(mediumTexts.containsAll(shortTexts), isTrue,
            reason: 'il test medio deve contenere le domande del breve');
        expect(longTexts.containsAll(mediumTexts), isTrue,
            reason: 'il test completo deve contenere le domande del medio');
      });
    });
  }

  test('IT ed EN hanno la stessa struttura', () async {
    for (final length in expectedCount.keys) {
      final it = await load('it', length);
      final en = await load('en', length);

      expect(it, hasLength(en.length),
          reason: '${length.name}: le due lingue devono avere lo stesso numero di domande');

      for (var i = 0; i < it.length; i++) {
        expect(it[i].id, en[i].id);
        expect(it[i].axis, en[i].axis,
            reason: '${length.name} q${i + 1}: asse divergente fra IT e EN');
        expect(it[i].direction, en[i].direction,
            reason: '${length.name} q${i + 1}: direzione divergente fra IT e EN');
        expect(it[i].text, isNot(en[i].text),
            reason: '${length.name} q${i + 1}: testo non tradotto');
      }
    }
  });
}
