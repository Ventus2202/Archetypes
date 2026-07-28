import '../personality_systems/mbti/mbti_confidence.dart';
import '../personality_systems/mbti/mbti_types.dart';
import 'quiz_models.dart';

class QuizEngine {
  /// Full outcome of a quiz run: type, per-axis breakdown and the confidence
  /// derived from it. Prefer this over calling the three pieces separately, so
  /// callers can persist a profile that says which quiz produced it and how
  /// clear-cut the answers were.
  static QuizResult evaluate(
    List<QuizQuestion> questions,
    Map<String, int> answers,
    QuizLength length,
  ) {
    final breakdown = calculateBreakdown(questions, answers);
    return QuizResult(
      type: calculateResult(questions, answers),
      length: length,
      breakdown: breakdown,
      confidence: confidenceFromAxisBalance(breakdown.values),
    );
  }

  static MbtiType calculateResult(List<QuizQuestion> questions, Map<String, int> answers) {
    final axisScores = <String, double>{
      'IE': 0.0,
      'NS': 0.0,
      'TF': 0.0,
      'JP': 0.0,
    };

    for (final q in questions) {
      final answer = answers[q.id];
      if (answer == null) continue;

      // answer_value: 1 (strongly disagree) to 5 (strongly agree)
      // score = (answer - 3) * direction * weight
      // 1 -> -2, 2 -> -1, 3 -> 0, 4 -> 1, 5 -> 2
      final score = (answer - 3) * q.direction * q.weight;
      axisScores[q.axis] = (axisScores[q.axis] ?? 0.0) + score;
    }

    String typeCode = '';

    // A tie (score exactly 0) falls to the first pole, so an all-neutral
    // questionnaire deterministically yields ENFP. That is not a claim about
    // the person: `evaluate` reports such a run with the minimum confidence,
    // which is the signal callers must read.
    typeCode += axisScores['IE']! >= 0 ? 'E' : 'I';
    typeCode += axisScores['NS']! >= 0 ? 'N' : 'S';
    typeCode += axisScores['TF']! >= 0 ? 'F' : 'T';
    typeCode += axisScores['JP']! >= 0 ? 'P' : 'J';

    return MbtiType.values.firstWhere(
      (e) => e.name == typeCode.toLowerCase(),
      orElse: () => MbtiType.intj,
    );
  }

  static Map<String, double> calculateBreakdown(List<QuizQuestion> questions, Map<String, int> answers) {
    final axisScores = <String, double>{
      'IE': 0.0,
      'NS': 0.0,
      'TF': 0.0,
      'JP': 0.0,
    };
    
    final axisMax = <String, double>{
      'IE': 0.0,
      'NS': 0.0,
      'TF': 0.0,
      'JP': 0.0,
    };

    for (final q in questions) {
      final answer = answers[q.id];
      if (answer == null) continue;

      final score = (answer - 3) * q.direction * q.weight;
      axisScores[q.axis] = (axisScores[q.axis] ?? 0.0) + score;
      axisMax[q.axis] = (axisMax[q.axis] ?? 0.0) + (2.0 * q.weight);
    }

    final breakdown = <String, double>{};
    for (final axis in axisScores.keys) {
      final score = axisScores[axis]!;
      final max = axisMax[axis]!;
      if (max == 0) {
        breakdown[axis] = 0.5;
      } else {
        // Normalize to 0..1 where 1 is the first polo (E, N, F, P)
        // score is in range [-max, max]
        breakdown[axis] = (score + max) / (2 * max);
      }
    }
    
    return breakdown;
  }
}
