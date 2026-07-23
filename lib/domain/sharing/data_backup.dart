import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:archive/archive.dart';
import '../../data/database/app_database.dart';

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

  static BackupData fromJson(Map<String, dynamic> json) {
    return BackupData(
      persons: (json['persons'] as List).map((e) => _personFromJson(e)).toList(),
      profiles: (json['profiles'] as List).map((e) => _profileFromJson(e)).toList(),
      relationships: (json['relationships'] as List).map((e) => _relationshipFromJson(e)).toList(),
      groups: (json['groups'] as List).map((e) => _groupFromJson(e)).toList(),
      personGroups: (json['personGroups'] as List).map((e) => _personGroupFromJson(e)).toList(),
      events: (json['events'] as List).map((e) => _eventFromJson(e)).toList(),
      schemaVersion: json['schemaVersion'] as int,
    );
  }

  static Map<String, dynamic> _personToJson(PersonEntry e) => {
    'id': e.id, 'name': e.name, 'nickname': e.nickname, 'avatarPath': e.avatarPath,
    'avatarBytes': e.avatarBytes != null ? base64Encode(e.avatarBytes!) : null,
    'birthDate': e.birthDate?.toIso8601String(), 'gender': e.gender, 'role': e.role,
    'notes': e.notes, 'firstMetDate': e.firstMetDate?.toIso8601String(),
    'isSelf': e.isSelf, 'createdAt': e.createdAt.toIso8601String(),
  };

  static PersonEntry _personFromJson(Map<String, dynamic> j) => PersonEntry(
    id: j['id'], name: j['name'], nickname: j['nickname'], avatarPath: j['avatarPath'],
    avatarBytes: j['avatarBytes'] != null ? base64Decode(j['avatarBytes'] as String) : null,
    birthDate: j['birthDate'] != null ? DateTime.parse(j['birthDate']) : null,
    gender: j['gender'], role: j['role'], notes: j['notes'],
    firstMetDate: j['firstMetDate'] != null ? DateTime.parse(j['firstMetDate']) : null,
    isSelf: j['isSelf'], createdAt: DateTime.parse(j['createdAt']),
  );

  static Map<String, dynamic> _profileToJson(PersonalityProfileEntry e) => {
    'id': e.id, 'personId': e.personId, 'system': e.system, 'dataJson': e.dataJson,
    'confidence': e.confidence, 'source': e.source, 'updatedAt': e.updatedAt.toIso8601String(),
    'shareId': e.shareId,
  };

  static PersonalityProfileEntry _profileFromJson(Map<String, dynamic> j) => PersonalityProfileEntry(
    id: j['id'], personId: j['personId'], system: j['system'], dataJson: j['dataJson'],
    confidence: j['confidence'], source: j['source'], updatedAt: DateTime.parse(j['updatedAt']),
    shareId: j['shareId'] as String?,
  );

  static Map<String, dynamic> _relationshipToJson(RelationshipEntry e) => {
    'id': e.id, 'personAId': e.personAId, 'personBId': e.personBId, 'kind': e.kind,
    'strength': e.strength, 'note': e.note, 'startDate': e.startDate?.toIso8601String(),
    'endDate': e.endDate?.toIso8601String(),
  };

  static RelationshipEntry _relationshipFromJson(Map<String, dynamic> j) => RelationshipEntry(
    id: j['id'], personAId: j['personAId'], personBId: j['personBId'], kind: j['kind'],
    strength: j['strength'], note: j['note'], 
    startDate: j['startDate'] != null ? DateTime.parse(j['startDate']) : null,
    endDate: j['endDate'] != null ? DateTime.parse(j['endDate']) : null,
  );

  static Map<String, dynamic> _groupToJson(GroupEntry e) => {
    'id': e.id, 'name': e.name, 'color': e.color, 'icon': e.icon,
  };

  static GroupEntry _groupFromJson(Map<String, dynamic> j) => GroupEntry(
    id: j['id'], name: j['name'], color: j['color'], icon: j['icon'],
  );

  static Map<String, dynamic> _personGroupToJson(PersonGroupEntry e) => {
    'personId': e.personId, 'groupId': e.groupId,
  };

  static PersonGroupEntry _personGroupFromJson(Map<String, dynamic> j) => PersonGroupEntry(
    personId: j['personId'], groupId: j['groupId'],
  );

  static Map<String, dynamic> _eventToJson(EventEntry e) => {
    'id': e.id, 'personId': e.personId, 'date': e.date.toIso8601String(),
    'kind': e.kind, 'description': e.description,
  };

  static EventEntry _eventFromJson(Map<String, dynamic> j) => EventEntry(
    id: j['id'], personId: j['personId'], date: DateTime.parse(j['date']),
    kind: j['kind'], description: j['description'],
  );
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

  Future<void> importFromBytes(Uint8List zipBytes, {bool replace = false}) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);

    final dataFile = archive.findFile('data.json');
    if (dataFile == null) throw Exception('Missing data.json in ZIP');

    final jsonContent = utf8.decode(dataFile.content);
    final backup = BackupData.fromJson(json.decode(jsonContent));

    if (backup.schemaVersion > db.schemaVersion) {
      throw Exception('Backup version mismatch');
    }

    if (replace) {
      await db.transaction(() async {
        await db.delete(db.eventEntries).go();
        await db.delete(db.personGroups).go();
        await db.delete(db.groups).go();
        await db.delete(db.relationships).go();
        await db.delete(db.personalityProfiles).go();
        await db.delete(db.persons).go();
      });
    }

    await db.transaction(() async {
      for (final g in backup.groups) {
        await db.into(db.groups).insert(g, mode: InsertMode.insertOrReplace);
      }

      for (final pEntry in backup.persons) {
        // Avatar bytes ride along inside pEntry (deserialized from data.json).
        await db.into(db.persons).insert(pEntry, mode: InsertMode.insertOrReplace);
      }

      for (final pr in backup.profiles) {
        await db.into(db.personalityProfiles).insert(pr, mode: InsertMode.insertOrReplace);
      }
      for (final rel in backup.relationships) {
        await db.into(db.relationships).insert(rel, mode: InsertMode.insertOrReplace);
      }
      for (final pg in backup.personGroups) {
        await db.into(db.personGroups).insert(pg, mode: InsertMode.insertOrReplace);
      }
      for (final ev in backup.events) {
        await db.into(db.eventEntries).insert(ev, mode: InsertMode.insertOrReplace);
      }
    });
  }
}
