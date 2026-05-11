import 'package:drift/drift.dart';
import '../database/app_database.dart';

class Group {
  final int id;
  final String name;
  final String color;
  final String icon;

  Group({required this.id, required this.name, required this.color, required this.icon});
}

class GroupRepository {
  final AppDatabase _db;

  GroupRepository(this._db);

  Group _fromEntry(GroupEntry e) => Group(
        id: e.id,
        name: e.name,
        color: e.color,
        icon: e.icon,
      );

  GroupsCompanion _toCompanion(Group g) => GroupsCompanion(
        id: g.id == 0 ? const Value.absent() : Value(g.id),
        name: Value(g.name),
        color: Value(g.color),
        icon: Value(g.icon),
      );

  Stream<List<Group>> watchAll() =>
      _db.select(_db.groups).watch().map((rows) => rows.map(_fromEntry).toList());

  Future<List<Group>> getAll() async {
    final rows = await _db.select(_db.groups).get();
    return rows.map(_fromEntry).toList();
  }

  Future<List<Group>> getForPerson(int personId) async {
    final query = _db.select(_db.groups).join([
      innerJoin(_db.personGroups, _db.personGroups.groupId.equalsExp(_db.groups.id)),
    ]) ..where(_db.personGroups.personId.equals(personId));
    
    final rows = await query.get();
    return rows.map((row) => _fromEntry(row.readTable(_db.groups))).toList();
  }

  Future<int> insert(Group group) =>
      _db.into(_db.groups).insert(_toCompanion(group));

  Future<bool> update(Group group) =>
      _db.update(_db.groups).replace(_toCompanion(group));

  Future<int> delete(int id) =>
      (_db.delete(_db.groups)..where((t) => t.id.equals(id))).go();
}
