import 'dart:typed_data';

enum PersonRole {
  family,
  friend,
  partner,
  colleague,
  acquaintance,
  other;

  static PersonRole fromString(String s) =>
      PersonRole.values.firstWhere((r) => r.name == s, orElse: () => PersonRole.other);
}

class Person {
  final int id;
  final String name;
  final String? nickname;
  final String? avatarPath;
  final Uint8List? avatarBytes;
  final DateTime? birthDate;
  final String? gender;
  final PersonRole role;
  final String? notes;
  final DateTime? firstMetDate;
  final bool isSelf;
  final DateTime createdAt;

  const Person({
    required this.id,
    required this.name,
    this.nickname,
    this.avatarPath,
    this.avatarBytes,
    this.birthDate,
    this.gender,
    required this.role,
    this.notes,
    this.firstMetDate,
    required this.isSelf,
    required this.createdAt,
  });

  String get displayName => nickname?.isNotEmpty == true ? nickname! : name;

  Person copyWith({
    int? id,
    String? name,
    String? nickname,
    String? avatarPath,
    Uint8List? avatarBytes,
    DateTime? birthDate,
    String? gender,
    PersonRole? role,
    String? notes,
    DateTime? firstMetDate,
    bool? isSelf,
    DateTime? createdAt,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarBytes: avatarBytes ?? this.avatarBytes,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      notes: notes ?? this.notes,
      firstMetDate: firstMetDate ?? this.firstMetDate,
      isSelf: isSelf ?? this.isSelf,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
