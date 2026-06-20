import 'package:drift/drift.dart';
import 'connection/connection.dart';

part 'app_database.g.dart';

@DataClassName('PersonEntry')
class Persons extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nickname => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('other'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get firstMetDate => dateTime().nullable()();
  BoolColumn get isSelf => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PersonalityProfileEntry')
class PersonalityProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId =>
      integer().references(Persons, #id, onDelete: KeyAction.cascade)();
  TextColumn get system => text().withDefault(const Constant('mbti'))();
  TextColumn get dataJson => text()();
  IntColumn get confidence => integer().withDefault(const Constant(80))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  // Stable random id (hex) backing the 24-char share code. Null until the
  // profile is first shared; the visible code is derived from this id plus the
  // profile's current system/type/confidence/source.
  TextColumn get shareId => text().nullable()();
}

@DataClassName('RelationshipEntry')
class Relationships extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personAId =>
      integer().references(Persons, #id, onDelete: KeyAction.cascade)();
  IntColumn get personBId =>
      integer().references(Persons, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind =>
      text().withDefault(const Constant('acquaintance'))();
  IntColumn get strength => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
}

@DataClassName('GroupEntry')
class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('#607D8B'))();
  TextColumn get icon => text().withDefault(const Constant('group'))();
}

@DataClassName('PersonGroupEntry')
class PersonGroups extends Table {
  IntColumn get personId =>
      integer().references(Persons, #id, onDelete: KeyAction.cascade)();
  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {personId, groupId};
}

@DataClassName('EventEntry')
class EventEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId =>
      integer().references(Persons, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  TextColumn get kind => text()();
  TextColumn get description => text()();
}

@DriftDatabase(tables: [
  Persons,
  PersonalityProfiles,
  Relationships,
  Groups,
  PersonGroups,
  EventEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(personalityProfiles, personalityProfiles.shareId);
          }
        },
      );

  static Future<AppDatabase> create() async => AppDatabase(openConnection());
}
