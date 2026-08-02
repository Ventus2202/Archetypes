import 'dart:io';

import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// The schema declares five `onDelete: KeyAction.cascade`, but SQLite disables
// foreign keys per connection and by default: without the `beforeOpen` pragma
// they are decoration, and every deleted person leaves a trail that then ends up
// in the backups. These tests pin both halves: the checks are on, and the rows
// the inert cascades already left behind get swept at open.
void main() {
  late AppDatabase db;

  Future<int> addPerson(String name) => db.into(db.persons).insert(
        PersonsCompanion.insert(name: name),
      );

  Future<int> addProfile(int personId) =>
      db.into(db.personalityProfiles).insert(
            PersonalityProfilesCompanion.insert(
              personId: personId,
              dataJson: MbtiProfile.fromType(MbtiType.intj).toJsonString(),
            ),
          );

  Future<int> pragmaForeignKeys() async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    return row.read<int>('foreign_keys');
  }

  group('in-memory', () {
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('foreign key enforcement is on once the database is open', () async {
      expect(await pragmaForeignKeys(), 1);
    });

    test('deleting a person cascades to everything that references it',
        () async {
      final alice = await addPerson('Alice');
      final bob = await addPerson('Bob');
      final groupId = await db.into(db.groups).insert(
            GroupsCompanion.insert(name: 'Lavoro'),
          );

      await addProfile(alice);
      // Both directions of the relationship reference the deleted person.
      await db.into(db.relationships).insert(
            RelationshipsCompanion.insert(personAId: alice, personBId: bob),
          );
      await db.into(db.relationships).insert(
            RelationshipsCompanion.insert(personAId: bob, personBId: alice),
          );
      await db.into(db.personGroups).insert(
            PersonGroupsCompanion.insert(personId: alice, groupId: groupId),
          );
      await db.into(db.eventEntries).insert(
            EventEntriesCompanion.insert(
              personId: alice,
              date: DateTime(2026, 8, 2),
              kind: 'note',
              description: 'primo incontro',
            ),
          );

      await (db.delete(db.persons)..where((t) => t.id.equals(alice))).go();

      expect(await db.select(db.personalityProfiles).get(), isEmpty);
      expect(await db.select(db.relationships).get(), isEmpty);
      expect(await db.select(db.personGroups).get(), isEmpty);
      expect(await db.select(db.eventEntries).get(), isEmpty);
      // The other person and the group are not referenced by the delete.
      expect(await db.select(db.persons).get(), hasLength(1));
      expect(await db.select(db.groups).get(), hasLength(1));
    });

    test('a profile cannot reference a person that does not exist', () async {
      await expectLater(addProfile(999), throwsA(isA<SqliteException>()));
    });

    test('the backup import order inserts parents before children', () async {
      // `data_backup.dart` writes groups → persons → profiles → relationships →
      // personGroups → events. With the checks on, any other order would throw
      // here instead of silently writing an orphan.
      final groupId = await db.into(db.groups).insert(
            GroupsCompanion.insert(name: 'Lavoro'),
          );
      final personId = await addPerson('Alice');
      await addProfile(personId);
      await db.into(db.personGroups).insert(
            PersonGroupsCompanion.insert(personId: personId, groupId: groupId),
          );

      expect(await db.select(db.personGroups).get(), hasLength(1));
    });
  });

  group('orphans left by the inert cascades', () {
    late Directory dir;
    late File file;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('archetypes_fk_test');
      file = File('${dir.path}/app.sqlite');
    });

    tearDown(() => dir.delete(recursive: true));

    test('are purged when the database is opened', () async {
      // Reproduce a pre-pragma database: checks off, delete a person, watch the
      // children survive. A file-backed DB is the only way to close and reopen.
      final legacy = AppDatabase(NativeDatabase(file));
      await legacy.customStatement('PRAGMA foreign_keys = OFF');
      final personId = await legacy.into(legacy.persons).insert(
            PersonsCompanion.insert(name: 'Alice'),
          );
      await legacy.into(legacy.personalityProfiles).insert(
            PersonalityProfilesCompanion.insert(
              personId: personId,
              dataJson: MbtiProfile.fromType(MbtiType.intj).toJsonString(),
            ),
          );
      await legacy.into(legacy.eventEntries).insert(
            EventEntriesCompanion.insert(
              personId: personId,
              date: DateTime(2026, 8, 2),
              kind: 'note',
              description: 'primo incontro',
            ),
          );
      await (legacy.delete(legacy.persons)
            ..where((t) => t.id.equals(personId)))
          .go();
      expect(
        await legacy.select(legacy.personalityProfiles).get(),
        hasLength(1),
        reason: 'without the pragma the cascade does nothing',
      );
      await legacy.close();

      db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      expect(await db.select(db.personalityProfiles).get(), isEmpty);
      expect(await db.select(db.eventEntries).get(), isEmpty);
      expect(await pragmaForeignKeys(), 1);
    });

    test('the purge leaves rows that still have their parent', () async {
      final first = AppDatabase(NativeDatabase(file));
      final personId = await first.into(first.persons).insert(
            PersonsCompanion.insert(name: 'Alice'),
          );
      await first.into(first.personalityProfiles).insert(
            PersonalityProfilesCompanion.insert(
              personId: personId,
              dataJson: MbtiProfile.fromType(MbtiType.intj).toJsonString(),
            ),
          );
      await first.close();

      db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      expect(await db.select(db.persons).get(), hasLength(1));
      expect(await db.select(db.personalityProfiles).get(), hasLength(1));
    });
  });
}
