enum PersonalitySystem {
  mbti,
  enneagram,
  bigFive,
  disc,
  cliftonStrengths;

  static PersonalitySystem fromString(String s) => PersonalitySystem.values
      .firstWhere((p) => p.name == s, orElse: () => PersonalitySystem.mbti);
}

enum ProfileSource {
  manual,
  quizShort,
  quizMedium,
  quizLong,
  granular;

  static ProfileSource fromString(String s) => ProfileSource.values
      .firstWhere((p) => p.name == s, orElse: () => ProfileSource.manual);
}

class PersonalityProfile {
  final int id;
  final int personId;
  final PersonalitySystem system;
  final Map<String, dynamic> data;
  final int confidence;
  final ProfileSource source;
  final DateTime updatedAt;

  const PersonalityProfile({
    required this.id,
    required this.personId,
    required this.system,
    required this.data,
    required this.confidence,
    required this.source,
    required this.updatedAt,
  });

  PersonalityProfile copyWith({
    int? id,
    int? personId,
    PersonalitySystem? system,
    Map<String, dynamic>? data,
    int? confidence,
    ProfileSource? source,
    DateTime? updatedAt,
  }) {
    return PersonalityProfile(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      system: system ?? this.system,
      data: data ?? this.data,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
