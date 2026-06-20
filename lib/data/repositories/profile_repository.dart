import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/entities/personality_profile.dart';
import '../database/app_database.dart';

class ProfileRepository {
  final AppDatabase _db;

  ProfileRepository(this._db);

  PersonalityProfile _fromEntry(PersonalityProfileEntry e) =>
      PersonalityProfile(
        id: e.id,
        personId: e.personId,
        system: PersonalitySystem.fromString(e.system),
        data: json.decode(e.dataJson) as Map<String, dynamic>,
        confidence: e.confidence,
        source: ProfileSource.fromString(e.source),
        updatedAt: e.updatedAt,
        shareId: e.shareId,
      );

  PersonalityProfilesCompanion _toCompanion(PersonalityProfile p) =>
      PersonalityProfilesCompanion(
        id: p.id == 0 ? const Value.absent() : Value(p.id),
        personId: Value(p.personId),
        system: Value(p.system.name),
        dataJson: Value(json.encode(p.data)),
        confidence: Value(p.confidence),
        source: Value(p.source.name),
        updatedAt: Value(p.updatedAt),
        // Absent when null so an existing share id is never clobbered by an
        // upsert from a profile object that didn't carry it.
        shareId: p.shareId == null ? const Value.absent() : Value(p.shareId),
      );

  Future<List<PersonalityProfile>> getForPerson(int personId) async {
    final rows = await (_db.select(_db.personalityProfiles)
          ..where((t) => t.personId.equals(personId)))
        .get();
    return rows.map(_fromEntry).toList();
  }

  Stream<List<PersonalityProfile>> watchForPerson(int personId) =>
      (_db.select(_db.personalityProfiles)
            ..where((t) => t.personId.equals(personId)))
          .watch()
          .map((rows) => rows.map(_fromEntry).toList());

  Future<PersonalityProfile?> getByShareId(String shareId) async {
    final row = await (_db.select(_db.personalityProfiles)
          ..where((t) => t.shareId.equals(shareId)))
        .getSingleOrNull();
    return row == null ? null : _fromEntry(row);
  }

  Future<int> upsert(PersonalityProfile profile) =>
      _db.into(_db.personalityProfiles).insertOnConflictUpdate(
            _toCompanion(profile),
          );

  Future<int> delete(int id) =>
      (_db.delete(_db.personalityProfiles)..where((t) => t.id.equals(id))).go();

  Future<int> deleteForPerson(int personId) =>
      (_db.delete(_db.personalityProfiles)
            ..where((t) => t.personId.equals(personId)))
          .go();
}
