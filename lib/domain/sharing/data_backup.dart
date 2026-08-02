import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:archive/archive.dart';
import '../../data/database/app_database.dart';

/// Thrown when a backup archive is not shaped the way the importer expects.
///
/// [path] points at the offending value (`persons[2].createdAt`) and [problem]
/// says what is wrong with it, so a malformed or hand-edited backup is refused
/// with a message instead of blowing up as a bare `TypeError` halfway through
/// the restore.
class BackupFormatException implements Exception {
  final String path;
  final String problem;

  const BackupFormatException(this.path, this.problem);

  @override
  String toString() => 'Invalid backup: $path $problem';
}

/// What a restore left out, so the caller can say so instead of the rows
/// vanishing without a word.
class BackupImportReport {
  /// One line per dropped row, in the same `section[i].field` vocabulary as
  /// [BackupFormatException] (`profiles[0].personId points to person 7, …`).
  final List<String> skippedRows;

  const BackupImportReport({this.skippedRows = const []});

  bool get isClean => skippedRows.isEmpty;
}

class BackupData {
  final List<PersonEntry> persons;
  final List<PersonalityProfileEntry> profiles;
  final List<RelationshipEntry> relationships;
  final List<GroupEntry> groups;
  final List<PersonGroupEntry> personGroups;
  final List<EventEntry> events;
  final int schemaVersion;

  BackupData({
    required this.persons,
    required this.profiles,
    required this.relationships,
    required this.groups,
    required this.personGroups,
    required this.events,
    required this.schemaVersion,
  });

  Map<String, dynamic> toJson() => {
        'persons': persons.map((e) => _personToJson(e)).toList(),
        'profiles': profiles.map((e) => _profileToJson(e)).toList(),
        'relationships': relationships.map((e) => _relationshipToJson(e)).toList(),
        'groups': groups.map((e) => _groupToJson(e)).toList(),
        'personGroups': personGroups.map((e) => _personGroupToJson(e)).toList(),
        'events': events.map((e) => _eventToJson(e)).toList(),
        'schemaVersion': schemaVersion,
      };

  /// Rebuilds a backup from decoded `data.json`, checking every field against
  /// the type the DB column needs. Throws [BackupFormatException] naming the
  /// first field that does not fit; nothing is written to the DB from here, so
  /// a bad backup is rejected before the restore touches anything.
  static BackupData fromJson(Map<String, dynamic> json) {
    return BackupData(
      persons: _rows(json, 'persons', _personFromJson),
      profiles: _rows(json, 'profiles', _profileFromJson),
      relationships: _rows(json, 'relationships', _relationshipFromJson),
      groups: _rows(json, 'groups', _groupFromJson),
      personGroups: _rows(json, 'personGroups', _personGroupFromJson),
      events: _rows(json, 'events', _eventFromJson),
      schemaVersion: _int(json, 'schemaVersion', 'data.json'),
    );
  }

  /// Reads `json[key]` as a list of objects and parses each one, threading the
  /// index into the path so an error says *which* row is broken.
  static List<T> _rows<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic> row, String path) parse,
  ) {
    final Object? value = json[key];
    if (value is! List) {
      _fail(key, 'expected a list, found ${_describe(value)}');
    }
    return [
      for (var i = 0; i < value.length; i++)
        parse(_object(value[i], '$key[$i]'), '$key[$i]'),
    ];
  }

  /// Refuses an archive that lost a whole parent section but kept the rows
  /// that need it. Throws [BackupFormatException]; call it before the restore
  /// opens its transaction.
  ///
  /// [withoutOrphans] drops a dangling row because it is garbage left by the
  /// years the cascades were inert. That reasoning holds for orphans scattered
  /// among sound rows, not for an archive where *every* parent is gone: there
  /// the likelier story is a truncated or hand-edited file, and dropping is the
  /// wrong answer — under `replace: true` the restore would delete the DB, find
  /// no parent to put back, drop every child and report success. Refusing here
  /// keeps the existing rows, which is what the 787 used to do by accident.
  ///
  /// An archive with no parents *and* no children is a legitimately empty
  /// backup and passes: restoring it over a full DB is a coherent way to clear
  /// the app.
  void checkParentSectionsPresent() {
    if (persons.isEmpty) {
      final needy = <String, int>{
        'profiles': profiles.length,
        'relationships': relationships.length,
        'personGroups': personGroups.length,
        'events': events.length,
      }..removeWhere((_, count) => count == 0);
      if (needy.isNotEmpty) _fail('persons', _truncated(needy, 'a person'));
    }
    if (groups.isEmpty && personGroups.isNotEmpty) {
      _fail(
        'groups',
        _truncated({'personGroups': personGroups.length}, 'a group'),
      );
    }
  }

  /// Returns this backup without the child rows whose parent is missing from
  /// it, plus the report of what was left out.
  ///
  /// [DataBackupService.exportToBytes] dumps whole tables, so in a sound backup
  /// every child travels with its parent: a dangling reference can only be the
  /// orphan garbage that the inert cascades left in the DB before foreign keys
  /// were enforced (see `AppDatabase._purgeOrphans`), and by definition every
  /// backup taken from an affected database carries some. Now that the keys are
  /// enforced, inserting one of those rows aborts the whole restore with a bare
  /// `SqliteException(787)` — a code that names neither table nor row — so
  /// those archives would be permanently unimportable. Dropping the rows is the
  /// same call `_purgeOrphans` already makes on the DB side, and it applies to
  /// merge imports too: the parent a row needs may happen to exist locally
  /// under the same id, but ids are local `autoIncrement` values, so that would
  /// be a coincidence attaching the row to an unrelated person.
  ({BackupData data, BackupImportReport report}) withoutOrphans() {
    final personIds = {for (final p in persons) p.id};
    final groupIds = {for (final g in groups) g.id};
    final skipped = <String>[];

    List<T> keep<T>(
      List<T> rows,
      String section,
      String? Function(T row) orphanReason,
    ) {
      final kept = <T>[];
      for (var i = 0; i < rows.length; i++) {
        final reason = orphanReason(rows[i]);
        if (reason == null) {
          kept.add(rows[i]);
        } else {
          skipped.add('$section[$i].$reason');
        }
      }
      return kept;
    }

    return (
      data: BackupData(
        persons: persons,
        profiles: keep(profiles, 'profiles',
            (r) => _missingParent(personIds, 'personId', r.personId, 'person')),
        relationships: keep(
          relationships,
          'relationships',
          (r) =>
              _missingParent(personIds, 'personAId', r.personAId, 'person') ??
              _missingParent(personIds, 'personBId', r.personBId, 'person'),
        ),
        groups: groups,
        personGroups: keep(
          personGroups,
          'personGroups',
          (r) =>
              _missingParent(personIds, 'personId', r.personId, 'person') ??
              _missingParent(groupIds, 'groupId', r.groupId, 'group'),
        ),
        events: keep(events, 'events',
            (r) => _missingParent(personIds, 'personId', r.personId, 'person')),
        schemaVersion: schemaVersion,
      ),
      report: BackupImportReport(skippedRows: skipped),
    );
  }

  static Map<String, dynamic> _personToJson(PersonEntry e) => {
    'id': e.id, 'name': e.name, 'nickname': e.nickname, 'avatarPath': e.avatarPath,
    'avatarBytes': e.avatarBytes != null ? base64Encode(e.avatarBytes!) : null,
    'birthDate': e.birthDate?.toIso8601String(), 'gender': e.gender, 'role': e.role,
    'notes': e.notes, 'firstMetDate': e.firstMetDate?.toIso8601String(),
    'isSelf': e.isSelf, 'createdAt': e.createdAt.toIso8601String(),
  };

  static PersonEntry _personFromJson(Map<String, dynamic> j, String p) =>
      PersonEntry(
        id: _int(j, 'id', p),
        name: _string(j, 'name', p),
        nickname: _stringOrNull(j, 'nickname', p),
        avatarPath: _stringOrNull(j, 'avatarPath', p),
        avatarBytes: _bytesOrNull(j, 'avatarBytes', p),
        birthDate: _dateOrNull(j, 'birthDate', p),
        gender: _stringOrNull(j, 'gender', p),
        role: _string(j, 'role', p),
        notes: _stringOrNull(j, 'notes', p),
        firstMetDate: _dateOrNull(j, 'firstMetDate', p),
        isSelf: _bool(j, 'isSelf', p),
        createdAt: _date(j, 'createdAt', p),
      );

  static Map<String, dynamic> _profileToJson(PersonalityProfileEntry e) => {
    'id': e.id, 'personId': e.personId, 'system': e.system, 'dataJson': e.dataJson,
    'confidence': e.confidence, 'source': e.source, 'updatedAt': e.updatedAt.toIso8601String(),
    'shareId': e.shareId,
  };

  static PersonalityProfileEntry _profileFromJson(
    Map<String, dynamic> j,
    String p,
  ) =>
      PersonalityProfileEntry(
        id: _int(j, 'id', p),
        personId: _int(j, 'personId', p),
        system: _string(j, 'system', p),
        dataJson: _string(j, 'dataJson', p),
        confidence: _int(j, 'confidence', p),
        source: _string(j, 'source', p),
        updatedAt: _date(j, 'updatedAt', p),
        // Absent in backups written before the shareId fix (2026-07-22).
        shareId: _stringOrNull(j, 'shareId', p),
      );

  static Map<String, dynamic> _relationshipToJson(RelationshipEntry e) => {
    'id': e.id, 'personAId': e.personAId, 'personBId': e.personBId, 'kind': e.kind,
    'strength': e.strength, 'note': e.note, 'startDate': e.startDate?.toIso8601String(),
    'endDate': e.endDate?.toIso8601String(),
  };

  static RelationshipEntry _relationshipFromJson(
    Map<String, dynamic> j,
    String p,
  ) =>
      RelationshipEntry(
        id: _int(j, 'id', p),
        personAId: _int(j, 'personAId', p),
        personBId: _int(j, 'personBId', p),
        kind: _string(j, 'kind', p),
        strength: _intOrNull(j, 'strength', p),
        note: _stringOrNull(j, 'note', p),
        startDate: _dateOrNull(j, 'startDate', p),
        endDate: _dateOrNull(j, 'endDate', p),
      );

  static Map<String, dynamic> _groupToJson(GroupEntry e) => {
    'id': e.id, 'name': e.name, 'color': e.color, 'icon': e.icon,
  };

  static GroupEntry _groupFromJson(Map<String, dynamic> j, String p) =>
      GroupEntry(
        id: _int(j, 'id', p),
        name: _string(j, 'name', p),
        color: _string(j, 'color', p),
        icon: _string(j, 'icon', p),
      );

  static Map<String, dynamic> _personGroupToJson(PersonGroupEntry e) => {
    'personId': e.personId, 'groupId': e.groupId,
  };

  static PersonGroupEntry _personGroupFromJson(
    Map<String, dynamic> j,
    String p,
  ) =>
      PersonGroupEntry(
        personId: _int(j, 'personId', p),
        groupId: _int(j, 'groupId', p),
      );

  static Map<String, dynamic> _eventToJson(EventEntry e) => {
    'id': e.id, 'personId': e.personId, 'date': e.date.toIso8601String(),
    'kind': e.kind, 'description': e.description,
  };

  static EventEntry _eventFromJson(Map<String, dynamic> j, String p) =>
      EventEntry(
        id: _int(j, 'id', p),
        personId: _int(j, 'personId', p),
        date: _date(j, 'date', p),
        kind: _string(j, 'kind', p),
        description: _string(j, 'description', p),
      );
}

// --- Typed readers -----------------------------------------------------------
//
// Every value coming out of `data.json` is `dynamic`: passing it straight into
// the generated entry constructors made a wrong type explode as a `TypeError`
// mid-restore with nothing to act on. These readers check the type first and
// name the field instead.

Never _fail(String path, String problem) =>
    throw BackupFormatException(path, problem);

/// Says which sections are left pointing at a parent table that is entirely
/// absent. See [BackupData.checkParentSectionsPresent].
String _truncated(Map<String, int> sections, String parent) {
  final total = sections.values.reduce((a, b) => a + b);
  return 'is empty but ${total == 1 ? '1 row' : '$total rows'} in '
      '${sections.keys.join(', ')} still need $parent: the backup looks '
      'truncated, not merely inconsistent';
}

/// Null when [id] is one of [known], otherwise the sentence naming the parent
/// the row points at and cannot find. See [BackupData.withoutOrphans].
String? _missingParent(Set<int> known, String field, int id, String parent) =>
    known.contains(id)
        ? null
        : '$field points to $parent $id, missing from this backup';

String _describe(Object? value) =>
    value == null ? 'nothing' : '${value.runtimeType}';

Map<String, dynamic> _object(Object? value, String path) {
  if (value is! Map<String, dynamic>) {
    _fail(path, 'expected an object, found ${_describe(value)}');
  }
  return value;
}

int _int(Map<String, dynamic> j, String key, String path) {
  final Object? value = j[key];
  if (value is! int) {
    _fail('$path.$key', 'expected a number, found ${_describe(value)}');
  }
  return value;
}

int? _intOrNull(Map<String, dynamic> j, String key, String path) {
  if (j[key] == null) return null;
  return _int(j, key, path);
}

String _string(Map<String, dynamic> j, String key, String path) {
  final Object? value = j[key];
  if (value is! String) {
    _fail('$path.$key', 'expected text, found ${_describe(value)}');
  }
  return value;
}

String? _stringOrNull(Map<String, dynamic> j, String key, String path) {
  if (j[key] == null) return null;
  return _string(j, key, path);
}

bool _bool(Map<String, dynamic> j, String key, String path) {
  final Object? value = j[key];
  if (value is! bool) {
    _fail('$path.$key', 'expected true or false, found ${_describe(value)}');
  }
  return value;
}

DateTime _date(Map<String, dynamic> j, String key, String path) {
  final raw = _string(j, key, path);
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) _fail('$path.$key', 'is not an ISO-8601 date: "$raw"');
  return parsed;
}

DateTime? _dateOrNull(Map<String, dynamic> j, String key, String path) {
  if (j[key] == null) return null;
  return _date(j, key, path);
}

Uint8List? _bytesOrNull(Map<String, dynamic> j, String key, String path) {
  if (j[key] == null) return null;
  final raw = _string(j, key, path);
  try {
    return base64Decode(raw);
  } on FormatException {
    _fail('$path.$key', 'is not valid base64');
  }
}

class DataBackupService {
  final AppDatabase db;

  DataBackupService(this.db);

  /// Serializes the whole DB to ZIP bytes. Returning bytes (not a [File])
  /// keeps this web-safe: the caller triggers a browser download or a native
  /// share/save without touching `dart:io`.
  Future<Uint8List> exportToBytes() async {
    final persons = await db.select(db.persons).get();
    final profiles = await db.select(db.personalityProfiles).get();
    final relationships = await db.select(db.relationships).get();
    final groups = await db.select(db.groups).get();
    final personGroups = await db.select(db.personGroups).get();
    final events = await db.select(db.eventEntries).get();

    final backup = BackupData(
      persons: persons,
      profiles: profiles,
      relationships: relationships,
      groups: groups,
      personGroups: personGroups,
      events: events,
      schemaVersion: db.schemaVersion,
    );

    final jsonContent = json.encode(backup.toJson());

    // Avatars now live as bytes inside data.json (base64), so nothing else
    // needs to go into the archive.
    final dataBytes = utf8.encode(jsonContent);
    final archive = Archive();
    archive.addFile(ArchiveFile('data.json', dataBytes.length, dataBytes));

    return ZipEncoder().encodeBytes(archive);
  }

  /// Restores a backup produced by [exportToBytes]. Throws
  /// [BackupFormatException] — before touching the DB — if the archive is not
  /// readable or a field does not have the type its column needs.
  ///
  /// Rows pointing at a parent the backup does not carry are dropped rather
  /// than refused, and listed in the returned report: see
  /// [BackupData.withoutOrphans] for why an archive can contain them. An
  /// archive missing a whole parent section is refused instead — see
  /// [BackupData.checkParentSectionsPresent].
  Future<BackupImportReport> importFromBytes(
    Uint8List zipBytes, {
    bool replace = false,
  }) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (_) {
      _fail('backup', 'is not a readable ZIP archive');
    }

    final dataFile = archive.findFile('data.json');
    if (dataFile == null) _fail('backup', 'has no data.json entry');

    final Object? decoded;
    try {
      decoded = json.decode(utf8.decode(dataFile.content));
    } on FormatException {
      _fail('data.json', 'is not valid JSON');
    }

    final parsed = BackupData.fromJson(_object(decoded, 'data.json'));

    if (parsed.schemaVersion > db.schemaVersion) {
      _fail(
        'data.json.schemaVersion',
        'is ${parsed.schemaVersion}, newer than this app understands '
            '(${db.schemaVersion})',
      );
    }

    parsed.checkParentSectionsPresent();
    final (data: backup, :report) = parsed.withoutOrphans();

    await db.transaction(() async {
      if (replace) {
        // Wiping and refilling in one transaction: if an insert fails halfway
        // through, the rollback puts the old rows back instead of leaving an
        // empty DB.
        await db.delete(db.eventEntries).go();
        await db.delete(db.personGroups).go();
        await db.delete(db.groups).go();
        await db.delete(db.relationships).go();
        await db.delete(db.personalityProfiles).go();
        await db.delete(db.persons).go();
      }

      // Upsert, not insertOrReplace: SQLite implements REPLACE as DELETE +
      // INSERT, so with foreign keys enforced (since the beforeOpen pragma) a
      // merge import of a person that already exists locally would cascade away
      // that person's profile, relationships, memberships and events before
      // re-inserting only what the backup happens to carry. `ON CONFLICT DO
      // UPDATE` rewrites the row in place, so nothing cascades.
      for (final g in backup.groups) {
        await db.into(db.groups).insertOnConflictUpdate(g);
      }

      for (final pEntry in backup.persons) {
        // Avatar bytes ride along inside pEntry (deserialized from data.json).
        await db.into(db.persons).insertOnConflictUpdate(pEntry);
      }

      for (final pr in backup.profiles) {
        await db.into(db.personalityProfiles).insertOnConflictUpdate(pr);
      }
      for (final rel in backup.relationships) {
        await db.into(db.relationships).insertOnConflictUpdate(rel);
      }
      for (final pg in backup.personGroups) {
        await db.into(db.personGroups).insertOnConflictUpdate(pg);
      }
      for (final ev in backup.events) {
        await db.into(db.eventEntries).insertOnConflictUpdate(ev);
      }
    });

    return report;
  }
}
