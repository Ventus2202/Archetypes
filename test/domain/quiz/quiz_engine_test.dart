import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/domain/quiz/quiz_models.dart';
import 'package:archetypes/domain/quiz/quiz_engine.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';

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
  });
}
