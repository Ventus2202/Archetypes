import 'dart:typed_data';

import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/domain/sharing/data_backup.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
