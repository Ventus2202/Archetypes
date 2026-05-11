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
}
