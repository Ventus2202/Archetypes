enum RelationshipKind {
  friendship,
  romantic,
  family,
  professional,
  acquaintance,
  conflict;

  static RelationshipKind fromString(String s) => RelationshipKind.values
      .firstWhere((r) => r.name == s, orElse: () => RelationshipKind.acquaintance);
}

class Relationship {
  final int id;
  final int personAId;
  final int personBId;
  final RelationshipKind kind;
  final int? strength;
  final String? note;
  final DateTime? startDate;
  final DateTime? endDate;

  const Relationship({
    required this.id,
    required this.personAId,
    required this.personBId,
    required this.kind,
    this.strength,
    this.note,
    this.startDate,
    this.endDate,
  });
}
