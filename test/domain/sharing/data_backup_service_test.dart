import 'dart:convert';

import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/domain/sharing/data_backup.dart';
import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds the ZIP layout the importer expects, so a test can hand it content
/// that `exportToBytes` would never produce.
Uint8List _zipWith(String dataJson) {
  final bytes = utf8.encode(dataJson);
  final archive = Archive()
    ..addFile(ArchiveFile('data.json', bytes.length, bytes));
  return ZipEncoder().encodeBytes(archive);
}

// End-to-end round-trip of the real ZIP path (exportToBytes -> importFromBytes)
// against in-memory databases. Now that backup I/O is pure bytes (no dart:io /
// path_provider), this needs no filesystem stubbing.
void main() {
  test('exportToBytes -> importFromBytes round-trips the whole DB', () async {
    final source = AppDatabase(NativeDatabase.memory());
    addTearDown(source.close);

    final avatar = Uint8List.fromList([0, 1, 2, 250, 255, 128]);

    // person 1 (self, with avatar bytes), person 2
    await source.into(source.persons).insert(PersonsCompanion.insert(
          name: 'Ada',
          avatarBytes: Value(avatar),
          isSelf: const Value(true),
        ));
    await source
        .into(source.persons)
        .insert(PersonsCompanion.insert(name: 'Bob'));

    await source.into(source.personalityProfiles).insert(
          PersonalityProfilesCompanion.insert(
            personId: 1,
            dataJson: '{"type":"intj"}',
            shareId: const Value('a1b2c3d4e5f6a7b8c9'),
          ),
        );

    await source.into(source.relationships).insert(
          RelationshipsCompanion.insert(
            personAId: 1,
            personBId: 2,
            strength: const Value(3),
          ),
        );

    await source
        .into(source.groups)
        .insert(GroupsCompanion.insert(name: 'Work'));
    await source.into(source.personGroups).insert(
          PersonGroupsCompanion.insert(personId: 1, groupId: 1),
        );
    await source.into(source.eventEntries).insert(
          EventEntriesCompanion.insert(
            personId: 1,
            date: DateTime.parse('2026-07-01T00:00:00.000'),
            kind: 'met',
            description: 'First met',
          ),
        );

    final bytes = await DataBackupService(source).exportToBytes();

    final target = AppDatabase(NativeDatabase.memory());
    addTearDown(target.close);
    await DataBackupService(target).importFromBytes(bytes, replace: true);

    final persons = await target.select(target.persons).get();
    expect(persons.length, 2);
    final ada = persons.firstWhere((p) => p.name == 'Ada');
    expect(ada.avatarBytes, avatar, reason: 'avatar bytes survive the ZIP');
    expect(ada.isSelf, isTrue);

    final profile = (await target.select(target.personalityProfiles).get()).single;
    expect(profile.shareId, 'a1b2c3d4e5f6a7b8c9');
    expect(profile.dataJson, '{"type":"intj"}');

    final rel = (await target.select(target.relationships).get()).single;
    expect(rel.personAId, 1);
    expect(rel.personBId, 2);
    expect(rel.strength, 3);

    final group = (await target.select(target.groups).get()).single;
    expect(group.name, 'Work');

    final pg = (await target.select(target.personGroups).get()).single;
    expect(pg.personId, 1);
    expect(pg.groupId, 1);

    final event = (await target.select(target.eventEntries).get()).single;
    expect(event.description, 'First met');
    expect(event.kind, 'met');
  });

  test('importFromBytes with replace clears existing rows first', () async {
    final source = AppDatabase(NativeDatabase.memory());
    addTearDown(source.close);
    await source
        .into(source.persons)
        .insert(PersonsCompanion.insert(name: 'Ada'));
    final bytes = await DataBackupService(source).exportToBytes();

    final target = AppDatabase(NativeDatabase.memory());
    addTearDown(target.close);
    await target
        .into(target.persons)
        .insert(PersonsCompanion.insert(name: 'Stale'));

    await DataBackupService(target).importFromBytes(bytes, replace: true);

    final names =
        (await target.select(target.persons).get()).map((p) => p.name).toList();
    expect(names, ['Ada']);
  });

  test('importFromBytes without replace keeps rows the backup does not carry',
      () async {
    // A merge import updates the person it finds; it must not take that
    // person's profile, relationships and events down with it. It would, if the
    // insert used REPLACE: SQLite runs that as DELETE + INSERT, and the delete
    // cascades now that foreign keys are enforced.
    final source = AppDatabase(NativeDatabase.memory());
    addTearDown(source.close);
    await source
        .into(source.persons)
        .insert(PersonsCompanion.insert(name: 'Ada Lovelace'));
    final bytes = await DataBackupService(source).exportToBytes();

    final target = AppDatabase(NativeDatabase.memory());
    addTearDown(target.close);
    // Same id as the person in the backup, plus local rows made after it.
    await target.into(target.persons).insert(PersonsCompanion.insert(name: 'Ada'));
    await target.into(target.personalityProfiles).insert(
          PersonalityProfilesCompanion.insert(
            personId: 1,
            dataJson: '{"type":"intj"}',
          ),
        );
    await target.into(target.eventEntries).insert(
          EventEntriesCompanion.insert(
            personId: 1,
            date: DateTime.parse('2026-08-01T00:00:00.000'),
            kind: 'met',
            description: 'Aggiunto dopo il backup',
          ),
        );

    await DataBackupService(target).importFromBytes(bytes, replace: false);

    expect(
      (await target.select(target.persons).get()).single.name,
      'Ada Lovelace',
      reason: 'the backup still wins on the columns it carries',
    );
    expect(await target.select(target.personalityProfiles).get(), hasLength(1));
    expect(
      (await target.select(target.eventEntries).get()).single.description,
      'Aggiunto dopo il backup',
    );
  });

  group('importFromBytes refuses a broken archive', () {
    test('bytes that are not a ZIP', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(
        () => DataBackupService(db)
            .importFromBytes(Uint8List.fromList(utf8.encode('hello'))),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('a ZIP without data.json', () async {
      final other = utf8.encode('nothing to see');
      final archive = Archive()
        ..addFile(ArchiveFile('notes.txt', other.length, other));

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(
        () => DataBackupService(db)
            .importFromBytes(ZipEncoder().encodeBytes(archive)),
        throwsA(isA<BackupFormatException>()
            .having((e) => e.problem, 'problem', contains('data.json'))),
      );
    });

    test('a data.json that is not JSON', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(
        () => DataBackupService(db).importFromBytes(_zipWith('{not json')),
        throwsA(isA<BackupFormatException>()
            .having((e) => e.path, 'path', 'data.json')),
      );
    });

    test('a backup newer than the app', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final future = DataBackupService(db).importFromBytes(_zipWith(jsonEncode({
        'persons': const [],
        'profiles': const [],
        'relationships': const [],
        'groups': const [],
        'personGroups': const [],
        'events': const [],
        'schemaVersion': 99,
      })));

      expect(
        future,
        throwsA(isA<BackupFormatException>()
            .having((e) => e.path, 'path', 'data.json.schemaVersion')),
      );
    });

    test('replace does not wipe the DB when the backup is malformed', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.into(db.persons).insert(PersonsCompanion.insert(name: 'Ada'));

      // Valid JSON, valid persons, but the last event carries a broken date:
      // the parse has to fail before the replace deletes anything.
      final broken = jsonEncode({
        'persons': [
          {
            'id': 1,
            'name': 'Bob',
            'role': 'friend',
            'isSelf': false,
            'createdAt': '2026-07-31T10:00:00.000',
          },
        ],
        'profiles': const [],
        'relationships': const [],
        'groups': const [],
        'personGroups': const [],
        'events': [
          {
            'id': 1,
            'personId': 1,
            'date': 'yesterday',
            'kind': 'met',
            'description': 'First met',
          },
        ],
        'schemaVersion': 3,
      });

      await expectLater(
        DataBackupService(db).importFromBytes(_zipWith(broken), replace: true),
        throwsA(isA<BackupFormatException>()
            .having((e) => e.path, 'path', 'events[0].date')),
      );

      final names =
          (await db.select(db.persons).get()).map((p) => p.name).toList();
      expect(names, ['Ada'], reason: 'the existing rows survive a failed import');
    });
  });
}
