import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/domain/sharing/data_backup.dart';

PersonEntry _person({Uint8List? avatarBytes}) => PersonEntry(
      id: 1,
      name: 'Ada',
      role: 'friend',
      avatarBytes: avatarBytes,
      isSelf: false,
      createdAt: DateTime.parse('2026-07-23T10:00:00.000'),
    );

void main() {
  group('BackupData serialization', () {
    test('profile shareId survives a toJson/fromJson round-trip', () {
      final backup = BackupData(
        persons: const [],
        profiles: [
          PersonalityProfileEntry(
            id: 1,
            personId: 1,
            system: 'mbti',
            dataJson: '{"type":"intj"}',
            confidence: 90,
            source: 'manual',
            updatedAt: DateTime.parse('2026-07-22T10:00:00.000'),
            shareId: 'a1b2c3d4e5f6a7b8c9',
          ),
        ],
        relationships: const [],
        groups: const [],
        personGroups: const [],
        events: const [],
        schemaVersion: 2,
      );

      // Full JSON encode/decode to mimic the real ZIP write/read path.
      final restored = BackupData.fromJson(
        jsonDecode(jsonEncode(backup.toJson())) as Map<String, dynamic>,
      );

      expect(restored.profiles.single.shareId, 'a1b2c3d4e5f6a7b8c9');
    });

    test('older backup without a shareId key decodes as null', () {
      final restored = BackupData.fromJson({
        'persons': const [],
        'profiles': [
          {
            'id': 1,
            'personId': 1,
            'system': 'mbti',
            'dataJson': '{}',
            'confidence': 80,
            'source': 'manual',
            'updatedAt': '2026-07-22T10:00:00.000',
            // no 'shareId' key: pre-fix backup format
          },
        ],
        'relationships': const [],
        'groups': const [],
        'personGroups': const [],
        'events': const [],
        'schemaVersion': 2,
      });

      expect(restored.profiles.single.shareId, isNull);
    });

    test('avatar bytes survive a base64 toJson/fromJson round-trip', () {
      final avatar = Uint8List.fromList([0, 1, 2, 250, 255, 128]);
      final backup = BackupData(
        persons: [_person(avatarBytes: avatar)],
        profiles: const [],
        relationships: const [],
        groups: const [],
        personGroups: const [],
        events: const [],
        schemaVersion: 3,
      );

      final restored = BackupData.fromJson(
        jsonDecode(jsonEncode(backup.toJson())) as Map<String, dynamic>,
      );

      expect(restored.persons.single.avatarBytes, avatar);
    });

    test('person without avatar bytes decodes as null', () {
      final backup = BackupData(
        persons: [_person()],
        profiles: const [],
        relationships: const [],
        groups: const [],
        personGroups: const [],
        events: const [],
        schemaVersion: 3,
      );

      final restored = BackupData.fromJson(
        jsonDecode(jsonEncode(backup.toJson())) as Map<String, dynamic>,
      );

      expect(restored.persons.single.avatarBytes, isNull);
    });
  });

  group('BackupData.fromJson rejects malformed input', () {
    // Every value in data.json arrives as `dynamic`. Before these checks a
    // wrong type went straight into a generated constructor and surfaced as a
    // bare TypeError with no clue about which field or row was at fault.
    Map<String, dynamic> backupWith({
      List<Object?> persons = const [],
      List<Object?> profiles = const [],
      List<Object?> events = const [],
    }) =>
        {
          'persons': persons,
          'profiles': profiles,
          'relationships': const [],
          'groups': const [],
          'personGroups': const [],
          'events': events,
          'schemaVersion': 3,
        };

    Map<String, dynamic> person({
      Object? id = 1,
      Object? name = 'Ada',
      Object? role = 'friend',
      Object? isSelf = false,
      Object? createdAt = '2026-07-31T10:00:00.000',
      Object? avatarBytes,
    }) =>
        {
          'id': id,
          'name': name,
          'role': role,
          'isSelf': isSelf,
          'createdAt': createdAt,
          'avatarBytes': avatarBytes,
        };

    Matcher throwsBackupError(String path, String problemPart) =>
        throwsA(isA<BackupFormatException>()
            .having((e) => e.path, 'path', path)
            .having((e) => e.problem, 'problem', contains(problemPart)));

    test('a missing required field names the field, not a TypeError', () {
      expect(
        () => BackupData.fromJson(
          backupWith(persons: [person(name: null)]),
        ),
        throwsBackupError('persons[0].name', 'expected text'),
      );
    });

    test('a field of the wrong type names the offending row', () {
      expect(
        () => BackupData.fromJson(backupWith(profiles: [
          {
            'id': 1,
            'personId': 1,
            'system': 'mbti',
            'dataJson': '{}',
            'confidence': '90', // text where the column wants an integer
            'source': 'manual',
            'updatedAt': '2026-07-31T10:00:00.000',
          },
        ])),
        throwsBackupError('profiles[0].confidence', 'expected a number'),
      );
    });

    test('an unparsable date is refused', () {
      expect(
        () => BackupData.fromJson(
          backupWith(persons: [person(createdAt: 'last tuesday')]),
        ),
        throwsBackupError('persons[0].createdAt', 'ISO-8601'),
      );
    });

    test('a corrupt avatar is refused instead of crashing base64Decode', () {
      expect(
        () => BackupData.fromJson(
          backupWith(persons: [person(avatarBytes: 'not base64!!')]),
        ),
        throwsBackupError('persons[0].avatarBytes', 'base64'),
      );
    });

    test('a row that is not an object is refused', () {
      expect(
        () => BackupData.fromJson(backupWith(persons: ['Ada'])),
        throwsBackupError('persons[0]', 'expected an object'),
      );
    });

    test('a missing top-level section is refused', () {
      final json = backupWith()..remove('events');
      expect(
        () => BackupData.fromJson(json),
        throwsBackupError('events', 'expected a list'),
      );
    });

    test('a missing schemaVersion is refused', () {
      final json = backupWith()..remove('schemaVersion');
      expect(
        () => BackupData.fromJson(json),
        throwsBackupError('data.json.schemaVersion', 'expected a number'),
      );
    });

    test('the index in the path points at the broken row', () {
      expect(
        () => BackupData.fromJson(backupWith(persons: [
          person(),
          person(id: 2),
          person(id: 'three'),
        ])),
        throwsBackupError('persons[2].id', 'expected a number'),
      );
    });
  });

  group('BackupData.withoutOrphans', () {
    // Every backup taken from a DB where a person had been deleted before the
    // foreign keys were enforced carries the rows that person left behind. With
    // the keys on, inserting one aborts the restore with SqliteException(787),
    // so those rows are dropped on the way in instead.
    BackupData backupOf({
      List<PersonEntry> persons = const [],
      List<PersonalityProfileEntry> profiles = const [],
      List<RelationshipEntry> relationships = const [],
      List<GroupEntry> groups = const [],
      List<PersonGroupEntry> personGroups = const [],
      List<EventEntry> events = const [],
    }) =>
        BackupData(
          persons: persons,
          profiles: profiles,
          relationships: relationships,
          groups: groups,
          personGroups: personGroups,
          events: events,
          schemaVersion: 3,
        );

    PersonalityProfileEntry profileOf(int id, int personId) =>
        PersonalityProfileEntry(
          id: id,
          personId: personId,
          system: 'mbti',
          dataJson: '{}',
          confidence: 80,
          source: 'manual',
          updatedAt: DateTime.parse('2026-08-02T10:00:00.000'),
        );

    test('a sound backup is passed through untouched', () {
      final backup = backupOf(
        persons: [_person()],
        profiles: [profileOf(1, 1)],
        events: [
          EventEntry(
            id: 1,
            personId: 1,
            date: DateTime.parse('2026-08-02T10:00:00.000'),
            kind: 'met',
            description: 'First met',
          ),
        ],
      );

      final (:data, :report) = backup.withoutOrphans();

      expect(report.isClean, isTrue);
      expect(data.profiles, hasLength(1));
      expect(data.events, hasLength(1));
    });

    test('a profile pointing outside the backup is dropped and named', () {
      final backup = backupOf(
        persons: [_person()], // id 1
        profiles: [profileOf(1, 1), profileOf(2, 7)],
      );

      final (:data, :report) = backup.withoutOrphans();

      expect(data.profiles.map((p) => p.id), [1]);
      expect(report.skippedRows, hasLength(1));
      expect(report.skippedRows.single, contains('profiles[1].personId'));
      expect(report.skippedRows.single, contains('person 7'));
    });

    test('a relationship is dropped if either end is missing', () {
      final backup = backupOf(
        persons: [_person()], // id 1
        relationships: [
          RelationshipEntry(id: 1, personAId: 1, personBId: 9, kind: 'friend'),
          RelationshipEntry(id: 2, personAId: 9, personBId: 1, kind: 'friend'),
        ],
      );

      final (:data, :report) = backup.withoutOrphans();

      expect(data.relationships, isEmpty);
      expect(report.skippedRows, [
        contains('relationships[0].personBId'),
        contains('relationships[1].personAId'),
      ]);
    });

    test('a membership is checked against both parents', () {
      final backup = backupOf(
        persons: [_person()], // id 1
        groups: [GroupEntry(id: 1, name: 'Work', color: '#000', icon: 'group')],
        personGroups: [
          PersonGroupEntry(personId: 1, groupId: 1),
          PersonGroupEntry(personId: 1, groupId: 4), // group gone
          PersonGroupEntry(personId: 5, groupId: 1), // person gone
        ],
      );

      final (:data, :report) = backup.withoutOrphans();

      expect(data.personGroups, hasLength(1));
      expect(report.skippedRows, [
        contains('personGroups[1].groupId points to group 4'),
        contains('personGroups[2].personId points to person 5'),
      ]);
    });

    test('an archive missing the whole persons section is refused, not pruned',
        () {
      // Dropping is right for orphans scattered among sound rows; an archive
      // with no parents at all is truncated, and under `replace: true` pruning
      // it would empty the DB and report success.
      final backup = backupOf(profiles: [profileOf(1, 1)]);

      expect(
        backup.checkParentSectionsPresent,
        throwsA(isA<BackupFormatException>()
            .having((e) => e.path, 'path', 'persons')
            .having((e) => e.problem, 'problem', contains('1 row in profiles'))
            .having((e) => e.problem, 'problem', contains('truncated'))),
      );
    });

    test('the refusal counts every section left without a parent', () {
      final backup = backupOf(
        profiles: [profileOf(1, 1), profileOf(2, 2)],
        events: [
          EventEntry(
            id: 1,
            personId: 1,
            date: DateTime.parse('2026-08-02T10:00:00.000'),
            kind: 'met',
            description: 'Orphan',
          ),
        ],
      );

      expect(
        backup.checkParentSectionsPresent,
        throwsA(isA<BackupFormatException>().having(
            (e) => e.problem, 'problem', contains('3 rows in profiles, events'))),
      );
    });

    test('a missing groups section is caught on its own', () {
      final backup = backupOf(
        persons: [_person()],
        personGroups: [PersonGroupEntry(personId: 1, groupId: 1)],
      );

      expect(
        backup.checkParentSectionsPresent,
        throwsA(isA<BackupFormatException>()
            .having((e) => e.path, 'path', 'groups')),
      );
    });

    test('an entirely empty backup is legitimate and passes', () {
      // Restoring one over a full DB is a coherent way to clear the app.
      expect(backupOf().checkParentSectionsPresent, returnsNormally);
    });

    test('orphans among sound rows stay a pruning matter, not a refusal', () {
      final backup = backupOf(
        persons: [_person()], // id 1
        profiles: [profileOf(1, 1), profileOf(2, 7)],
      );

      expect(backup.checkParentSectionsPresent, returnsNormally);
    });

    test('parents are never dropped, however many children point at them', () {
      final backup = backupOf(
        persons: [_person()],
        groups: [GroupEntry(id: 1, name: 'Work', color: '#000', icon: 'group')],
        profiles: [profileOf(1, 42)],
      );

      final (:data, :report) = backup.withoutOrphans();

      expect(data.persons, hasLength(1));
      expect(data.groups, hasLength(1));
      expect(report.skippedRows, hasLength(1));
    });
  });
}
