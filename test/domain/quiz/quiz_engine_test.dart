import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/domain/quiz/quiz_models.dart';
import 'package:archetypes/domain/quiz/quiz_engine.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
import 'package:archetypes/domain/entities/personality_profile.dart';

void main() {
  group('QuizEngine', () {
    final questions = [
      const QuizQuestion(id: 'q1', text: 'T1', axis: 'IE', direction: 1), // + E
      const QuizQuestion(id: 'q2', text: 'T2', axis: 'IE', direction: -1), // + I
      const QuizQuestion(id: 'q3', text: 'T3', axis: 'NS', direction: 1), // + N
      const QuizQuestion(id: 'q4', text: 'T4', axis: 'TF', direction: 1), // + F
      const QuizQuestion(id: 'q5', text: 'T5', axis: 'JP', direction: -1), // + J
    ];

    test('calculateResult - ENTJ case', () {
      final answers = {
        'q1': 5, // Strongly agree -> E (+2)
        'q2': 1, // Strongly disagree -> E (+2) -> Total IE = +4 (E)
        'q3': 5, // Strongly agree -> N (+2) -> Total NS = +2 (N)
        'q4': 1, // Strongly disagree -> T (+2) -> Total TF = -2 (T)
        'q5': 5, // Strongly agree -> J (+2) -> Total JP = -2 (J)
      };

      final result = QuizEngine.calculateResult(questions, answers);
      expect(result, MbtiType.entj);
    });

    test('calculateBreakdown - normalization', () {
      final answers = {
        'q1': 4, // Agree -> E (+1)
        'q2': 3, // Neutral -> 0
      };
      
      // Axis IE max possible score = 2 * 1.0 (q1) + 2 * 1.0 (q2) = 4.0
      // Current IE score = 1 * 1 * 1 + 0 * -1 * 1 = 1
      // Normalized = (1 + 4) / (2 * 4) = 5/8 = 0.625

      final breakdown = QuizEngine.calculateBreakdown(questions, answers);
      expect(breakdown['IE'], 0.625);
    });

    test('evaluate - decisive answers keep the type and report full confidence',
        () {
      final answers = {'q1': 5, 'q2': 1, 'q3': 5, 'q4': 1, 'q5': 5};

      final result =
          QuizEngine.evaluate(questions, answers, QuizLength.long);

      expect(result.type, MbtiType.entj);
      expect(result.confidence, 100);
      expect(result.length, QuizLength.long);
      expect(result.source, ProfileSource.quizLong);
    });

    test('evaluate - an all-neutral run is flagged by minimum confidence', () {
      // Every axis ties, so the type is whatever the tie-break picks. The
      // caller must be able to tell that from the confidence alone.
      final answers = {for (final q in questions) q.id: 3};

      final result =
          QuizEngine.evaluate(questions, answers, QuizLength.short);

      expect(result.type, MbtiType.enfp, reason: 'documented tie-break');
      expect(result.confidence, 50);
      expect(result.source, ProfileSource.quizShort);
    });

    test('evaluate - source follows the quiz actually taken', () {
      final answers = {'q1': 5};
      for (final entry in {
        QuizLength.short: ProfileSource.quizShort,
        QuizLength.medium: ProfileSource.quizMedium,
        QuizLength.long: ProfileSource.quizLong,
      }.entries) {
        expect(
          QuizEngine.evaluate(questions, answers, entry.key).source,
          entry.value,
        );
        expect(entry.key.source, entry.value);
      }
    });
  });
}
