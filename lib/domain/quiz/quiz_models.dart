import '../entities/personality_profile.dart';
import '../personality_systems/mbti/mbti_types.dart';

class QuizQuestion {
  final String id;
  final String text;
  final String axis; // IE, NS, TF, JP
  final int direction; // +1 or -1
  final double weight;

  const QuizQuestion({
    required this.id,
    required this.text,
    required this.axis,
    required this.direction,
    this.weight = 1.0,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      axis: json['axis'] as String,
      direction: json['direction'] as int,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

enum QuizLength {
  short,
  medium,
  long;

  String get fileName => switch (this) {
        QuizLength.short => 'mbti_short.json',
        QuizLength.medium => 'mbti_medium.json',
        QuizLength.long => 'mbti_long.json',
      };

  /// The profile source to persist for a profile produced by this quiz length.
  ProfileSource get source => switch (this) {
        QuizLength.short => ProfileSource.quizShort,
        QuizLength.medium => ProfileSource.quizMedium,
        QuizLength.long => ProfileSource.quizLong,
      };
}

/// Everything a completed quiz hands back to whoever started it: not just the
/// type, but which quiz produced it and how decisive the answers were.
class QuizResult {
  final MbtiType type;
  final QuizLength length;

  /// Per-axis normalized score (0..1), see [QuizEngine.calculateBreakdown].
  final Map<String, double> breakdown;

  /// 50..100, see `confidenceFromAxisBalance`.
  final int confidence;

  const QuizResult({
    required this.type,
    required this.length,
    required this.breakdown,
    required this.confidence,
  });

  ProfileSource get source => length.source;
}
