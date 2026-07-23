import 'package:drift/drift.dart';
import '../../domain/entities/person.dart';
import '../database/app_database.dart';

class PersonRepository {
  final AppDatabase _db;

  PersonRepository(this._db);

  Person _fromEntry(PersonEntry e) => Person(
        id: e.id,
        name: e.name,
        nickname: e.nickname,
        avatarPath: e.avatarPath,
        avatarBytes: e.avatarBytes,
        birthDate: e.birthDate,
        gender: e.gender,
        role: PersonRole.fromString(e.role),
        notes: e.notes,
        firstMetDate: e.firstMetDate,
        isSelf: e.isSelf,
        createdAt: e.createdAt,
      );

  PersonsCompanion _toCompanion(Person p) => PersonsCompanion(
        id: p.id == 0 ? const Value.absent() : Value(p.id),
        name: Value(p.name),
        nickname: Value(p.nickname),
        avatarPath: Value(p.avatarPath),
        avatarBytes: Value(p.avatarBytes),
        birthDate: Value(p.birthDate),
        gender: Value(p.gender),
        role: Value(p.role.name),
        notes: Value(p.notes),
        firstMetDate: Value(p.firstMetDate),
        isSelf: Value(p.isSelf),
        createdAt: Value(p.createdAt),
      );

  Stream<List<Person>> watchAll() =>
      _db.select(_db.persons).watch().map((rows) => rows.map(_fromEntry).toList());

  Future<List<Person>> getAll() async {
    final rows = await _db.select(_db.persons).get();
    return rows.map(_fromEntry).toList();
  }

  Future<Person?> getById(int id) async {
    final row = await (_db.select(_db.persons)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromEntry(row);
  }

  Future<Person?> getSelf() async {
    final row = await (_db.select(_db.persons)
          ..where((t) => t.isSelf.equals(true)))
        .getSingleOrNull();
    return row == null ? null : _fromEntry(row);
  }

  Future<int> insert(Person person) =>
      _db.into(_db.persons).insert(_toCompanion(person));

  Future<bool> update(Person person) =>
      _db.update(_db.persons).replace(_toCompanion(person));

  Future<int> delete(int id) =>
      (_db.delete(_db.persons)..where((t) => t.id.equals(id))).go();
}
