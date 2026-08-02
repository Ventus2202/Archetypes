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
}
