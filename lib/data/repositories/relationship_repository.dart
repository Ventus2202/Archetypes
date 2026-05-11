import 'package:drift/drift.dart';
import '../../domain/entities/relationship.dart';
import '../database/app_database.dart';

class RelationshipRepository {
  final AppDatabase _db;

  RelationshipRepository(this._db);

  Relationship _fromEntry(RelationshipEntry e) => Relationship(
        id: e.id,
        personAId: e.personAId,
        personBId: e.personBId,
        kind: RelationshipKind.fromString(e.kind),
        strength: e.strength,
        note: e.note,
        startDate: e.startDate,
        endDate: e.endDate,
      );

  RelationshipsCompanion _toCompanion(Relationship r) =>
      RelationshipsCompanion(
        id: r.id == 0 ? const Value.absent() : Value(r.id),
        personAId: Value(r.personAId),
        personBId: Value(r.personBId),
        kind: Value(r.kind.name),
        strength: Value(r.strength),
        note: Value(r.note),
        startDate: Value(r.startDate),
        endDate: Value(r.endDate),
      );

  Future<List<Relationship>> getForPerson(int personId) async {
    final rows = await (_db.select(_db.relationships)
          ..where((t) =>
              t.personAId.equals(personId) | t.personBId.equals(personId)))
        .get();
    return rows.map(_fromEntry).toList();
  }

  Stream<List<Relationship>> watchAll() =>
      _db.select(_db.relationships).watch().map(
            (rows) => rows.map(_fromEntry).toList(),
          );

  Future<Relationship?> getBetween(int personAId, int personBId) async {
    final row = await (_db.select(_db.relationships)
          ..where((t) =>
              (t.personAId.equals(personAId) & t.personBId.equals(personBId)) |
              (t.personAId.equals(personBId) & t.personBId.equals(personAId))))
        .getSingleOrNull();
    return row == null ? null : _fromEntry(row);
  }

  Future<int> upsert(Relationship rel) =>
      _db.into(_db.relationships).insertOnConflictUpdate(_toCompanion(rel));

  Future<int> delete(int id) =>
      (_db.delete(_db.relationships)..where((t) => t.id.equals(id))).go();
}
