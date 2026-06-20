// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PersonsTable extends Persons with TableInfo<$PersonsTable, PersonEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstMetDateMeta = const VerificationMeta(
    'firstMetDate',
  );
  @override
  late final GeneratedColumn<DateTime> firstMetDate = GeneratedColumn<DateTime>(
    'first_met_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSelfMeta = const VerificationMeta('isSelf');
  @override
  late final GeneratedColumn<bool> isSelf = GeneratedColumn<bool>(
    'is_self',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_self" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nickname,
    avatarPath,
    birthDate,
    gender,
    role,
    notes,
    firstMetDate,
    isSelf,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persons';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('first_met_date')) {
      context.handle(
        _firstMetDateMeta,
        firstMetDate.isAcceptableOrUnknown(
          data['first_met_date']!,
          _firstMetDateMeta,
        ),
      );
    }
    if (data.containsKey('is_self')) {
      context.handle(
        _isSelfMeta,
        isSelf.isAcceptableOrUnknown(data['is_self']!, _isSelfMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      firstMetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_met_date'],
      ),
      isSelf: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_self'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PersonsTable createAlias(String alias) {
    return $PersonsTable(attachedDatabase, alias);
  }
}

class PersonEntry extends DataClass implements Insertable<PersonEntry> {
  final int id;
  final String name;
  final String? nickname;
  final String? avatarPath;
  final DateTime? birthDate;
  final String? gender;
  final String role;
  final String? notes;
  final DateTime? firstMetDate;
  final bool isSelf;
  final DateTime createdAt;
  const PersonEntry({
    required this.id,
    required this.name,
    this.nickname,
    this.avatarPath,
    this.birthDate,
    this.gender,
    required this.role,
    this.notes,
    this.firstMetDate,
    required this.isSelf,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || firstMetDate != null) {
      map['first_met_date'] = Variable<DateTime>(firstMetDate);
    }
    map['is_self'] = Variable<bool>(isSelf);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PersonsCompanion toCompanion(bool nullToAbsent) {
    return PersonsCompanion(
      id: Value(id),
      name: Value(name),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      role: Value(role),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      firstMetDate: firstMetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(firstMetDate),
      isSelf: Value(isSelf),
      createdAt: Value(createdAt),
    );
  }

  factory PersonEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      gender: serializer.fromJson<String?>(json['gender']),
      role: serializer.fromJson<String>(json['role']),
      notes: serializer.fromJson<String?>(json['notes']),
      firstMetDate: serializer.fromJson<DateTime?>(json['firstMetDate']),
      isSelf: serializer.fromJson<bool>(json['isSelf']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nickname': serializer.toJson<String?>(nickname),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'gender': serializer.toJson<String?>(gender),
      'role': serializer.toJson<String>(role),
      'notes': serializer.toJson<String?>(notes),
      'firstMetDate': serializer.toJson<DateTime?>(firstMetDate),
      'isSelf': serializer.toJson<bool>(isSelf),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PersonEntry copyWith({
    int? id,
    String? name,
    Value<String?> nickname = const Value.absent(),
    Value<String?> avatarPath = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    String? role,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> firstMetDate = const Value.absent(),
    bool? isSelf,
    DateTime? createdAt,
  }) => PersonEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    nickname: nickname.present ? nickname.value : this.nickname,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    gender: gender.present ? gender.value : this.gender,
    role: role ?? this.role,
    notes: notes.present ? notes.value : this.notes,
    firstMetDate: firstMetDate.present ? firstMetDate.value : this.firstMetDate,
    isSelf: isSelf ?? this.isSelf,
    createdAt: createdAt ?? this.createdAt,
  );
  PersonEntry copyWithCompanion(PersonsCompanion data) {
    return PersonEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      gender: data.gender.present ? data.gender.value : this.gender,
      role: data.role.present ? data.role.value : this.role,
      notes: data.notes.present ? data.notes.value : this.notes,
      firstMetDate: data.firstMetDate.present
          ? data.firstMetDate.value
          : this.firstMetDate,
      isSelf: data.isSelf.present ? data.isSelf.value : this.isSelf,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('role: $role, ')
          ..write('notes: $notes, ')
          ..write('firstMetDate: $firstMetDate, ')
          ..write('isSelf: $isSelf, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nickname,
    avatarPath,
    birthDate,
    gender,
    role,
    notes,
    firstMetDate,
    isSelf,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.nickname == this.nickname &&
          other.avatarPath == this.avatarPath &&
          other.birthDate == this.birthDate &&
          other.gender == this.gender &&
          other.role == this.role &&
          other.notes == this.notes &&
          other.firstMetDate == this.firstMetDate &&
          other.isSelf == this.isSelf &&
          other.createdAt == this.createdAt);
}

class PersonsCompanion extends UpdateCompanion<PersonEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> nickname;
  final Value<String?> avatarPath;
  final Value<DateTime?> birthDate;
  final Value<String?> gender;
  final Value<String> role;
  final Value<String?> notes;
  final Value<DateTime?> firstMetDate;
  final Value<bool> isSelf;
  final Value<DateTime> createdAt;
  const PersonsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.role = const Value.absent(),
    this.notes = const Value.absent(),
    this.firstMetDate = const Value.absent(),
    this.isSelf = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PersonsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nickname = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.role = const Value.absent(),
    this.notes = const Value.absent(),
    this.firstMetDate = const Value.absent(),
    this.isSelf = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PersonEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nickname,
    Expression<String>? avatarPath,
    Expression<DateTime>? birthDate,
    Expression<String>? gender,
    Expression<String>? role,
    Expression<String>? notes,
    Expression<DateTime>? firstMetDate,
    Expression<bool>? isSelf,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nickname != null) 'nickname': nickname,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (birthDate != null) 'birth_date': birthDate,
      if (gender != null) 'gender': gender,
      if (role != null) 'role': role,
      if (notes != null) 'notes': notes,
      if (firstMetDate != null) 'first_met_date': firstMetDate,
      if (isSelf != null) 'is_self': isSelf,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PersonsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? nickname,
    Value<String?>? avatarPath,
    Value<DateTime?>? birthDate,
    Value<String?>? gender,
    Value<String>? role,
    Value<String?>? notes,
    Value<DateTime?>? firstMetDate,
    Value<bool>? isSelf,
    Value<DateTime>? createdAt,
  }) {
    return PersonsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      notes: notes ?? this.notes,
      firstMetDate: firstMetDate ?? this.firstMetDate,
      isSelf: isSelf ?? this.isSelf,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (firstMetDate.present) {
      map['first_met_date'] = Variable<DateTime>(firstMetDate.value);
    }
    if (isSelf.present) {
      map['is_self'] = Variable<bool>(isSelf.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('role: $role, ')
          ..write('notes: $notes, ')
          ..write('firstMetDate: $firstMetDate, ')
          ..write('isSelf: $isSelf, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PersonalityProfilesTable extends PersonalityProfiles
    with TableInfo<$PersonalityProfilesTable, PersonalityProfileEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalityProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _systemMeta = const VerificationMeta('system');
  @override
  late final GeneratedColumn<String> system = GeneratedColumn<String>(
    'system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mbti'),
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<int> confidence = GeneratedColumn<int>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(80),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _shareIdMeta = const VerificationMeta(
    'shareId',
  );
  @override
  late final GeneratedColumn<String> shareId = GeneratedColumn<String>(
    'share_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    system,
    dataJson,
    confidence,
    source,
    updatedAt,
    shareId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personality_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalityProfileEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('system')) {
      context.handle(
        _systemMeta,
        system.isAcceptableOrUnknown(data['system']!, _systemMeta),
      );
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_dataJsonMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('share_id')) {
      context.handle(
        _shareIdMeta,
        shareId.isAcceptableOrUnknown(data['share_id']!, _shareIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalityProfileEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalityProfileEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      )!,
      system: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      shareId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_id'],
      ),
    );
  }

  @override
  $PersonalityProfilesTable createAlias(String alias) {
    return $PersonalityProfilesTable(attachedDatabase, alias);
  }
}

class PersonalityProfileEntry extends DataClass
    implements Insertable<PersonalityProfileEntry> {
  final int id;
  final int personId;
  final String system;
  final String dataJson;
  final int confidence;
  final String source;
  final DateTime updatedAt;
  final String? shareId;
  const PersonalityProfileEntry({
    required this.id,
    required this.personId,
    required this.system,
    required this.dataJson,
    required this.confidence,
    required this.source,
    required this.updatedAt,
    this.shareId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_id'] = Variable<int>(personId);
    map['system'] = Variable<String>(system);
    map['data_json'] = Variable<String>(dataJson);
    map['confidence'] = Variable<int>(confidence);
    map['source'] = Variable<String>(source);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || shareId != null) {
      map['share_id'] = Variable<String>(shareId);
    }
    return map;
  }

  PersonalityProfilesCompanion toCompanion(bool nullToAbsent) {
    return PersonalityProfilesCompanion(
      id: Value(id),
      personId: Value(personId),
      system: Value(system),
      dataJson: Value(dataJson),
      confidence: Value(confidence),
      source: Value(source),
      updatedAt: Value(updatedAt),
      shareId: shareId == null && nullToAbsent
          ? const Value.absent()
          : Value(shareId),
    );
  }

  factory PersonalityProfileEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalityProfileEntry(
      id: serializer.fromJson<int>(json['id']),
      personId: serializer.fromJson<int>(json['personId']),
      system: serializer.fromJson<String>(json['system']),
      dataJson: serializer.fromJson<String>(json['dataJson']),
      confidence: serializer.fromJson<int>(json['confidence']),
      source: serializer.fromJson<String>(json['source']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      shareId: serializer.fromJson<String?>(json['shareId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personId': serializer.toJson<int>(personId),
      'system': serializer.toJson<String>(system),
      'dataJson': serializer.toJson<String>(dataJson),
      'confidence': serializer.toJson<int>(confidence),
      'source': serializer.toJson<String>(source),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'shareId': serializer.toJson<String?>(shareId),
    };
  }

  PersonalityProfileEntry copyWith({
    int? id,
    int? personId,
    String? system,
    String? dataJson,
    int? confidence,
    String? source,
    DateTime? updatedAt,
    Value<String?> shareId = const Value.absent(),
  }) => PersonalityProfileEntry(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    system: system ?? this.system,
    dataJson: dataJson ?? this.dataJson,
    confidence: confidence ?? this.confidence,
    source: source ?? this.source,
    updatedAt: updatedAt ?? this.updatedAt,
    shareId: shareId.present ? shareId.value : this.shareId,
  );
  PersonalityProfileEntry copyWithCompanion(PersonalityProfilesCompanion data) {
    return PersonalityProfileEntry(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      system: data.system.present ? data.system.value : this.system,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      source: data.source.present ? data.source.value : this.source,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      shareId: data.shareId.present ? data.shareId.value : this.shareId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalityProfileEntry(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('system: $system, ')
          ..write('dataJson: $dataJson, ')
          ..write('confidence: $confidence, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('shareId: $shareId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    system,
    dataJson,
    confidence,
    source,
    updatedAt,
    shareId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalityProfileEntry &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.system == this.system &&
          other.dataJson == this.dataJson &&
          other.confidence == this.confidence &&
          other.source == this.source &&
          other.updatedAt == this.updatedAt &&
          other.shareId == this.shareId);
}

class PersonalityProfilesCompanion
    extends UpdateCompanion<PersonalityProfileEntry> {
  final Value<int> id;
  final Value<int> personId;
  final Value<String> system;
  final Value<String> dataJson;
  final Value<int> confidence;
  final Value<String> source;
  final Value<DateTime> updatedAt;
  final Value<String?> shareId;
  const PersonalityProfilesCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.system = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.confidence = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.shareId = const Value.absent(),
  });
  PersonalityProfilesCompanion.insert({
    this.id = const Value.absent(),
    required int personId,
    this.system = const Value.absent(),
    required String dataJson,
    this.confidence = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.shareId = const Value.absent(),
  }) : personId = Value(personId),
       dataJson = Value(dataJson);
  static Insertable<PersonalityProfileEntry> custom({
    Expression<int>? id,
    Expression<int>? personId,
    Expression<String>? system,
    Expression<String>? dataJson,
    Expression<int>? confidence,
    Expression<String>? source,
    Expression<DateTime>? updatedAt,
    Expression<String>? shareId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (system != null) 'system': system,
      if (dataJson != null) 'data_json': dataJson,
      if (confidence != null) 'confidence': confidence,
      if (source != null) 'source': source,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (shareId != null) 'share_id': shareId,
    });
  }

  PersonalityProfilesCompanion copyWith({
    Value<int>? id,
    Value<int>? personId,
    Value<String>? system,
    Value<String>? dataJson,
    Value<int>? confidence,
    Value<String>? source,
    Value<DateTime>? updatedAt,
    Value<String?>? shareId,
  }) {
    return PersonalityProfilesCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      system: system ?? this.system,
      dataJson: dataJson ?? this.dataJson,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
      shareId: shareId ?? this.shareId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (system.present) {
      map['system'] = Variable<String>(system.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<int>(confidence.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (shareId.present) {
      map['share_id'] = Variable<String>(shareId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalityProfilesCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('system: $system, ')
          ..write('dataJson: $dataJson, ')
          ..write('confidence: $confidence, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('shareId: $shareId')
          ..write(')'))
        .toString();
  }
}

class $RelationshipsTable extends Relationships
    with TableInfo<$RelationshipsTable, RelationshipEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personAIdMeta = const VerificationMeta(
    'personAId',
  );
  @override
  late final GeneratedColumn<int> personAId = GeneratedColumn<int>(
    'person_a_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _personBIdMeta = const VerificationMeta(
    'personBId',
  );
  @override
  late final GeneratedColumn<int> personBId = GeneratedColumn<int>(
    'person_b_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('acquaintance'),
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<int> strength = GeneratedColumn<int>(
    'strength',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personAId,
    personBId,
    kind,
    strength,
    note,
    startDate,
    endDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<RelationshipEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_a_id')) {
      context.handle(
        _personAIdMeta,
        personAId.isAcceptableOrUnknown(data['person_a_id']!, _personAIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personAIdMeta);
    }
    if (data.containsKey('person_b_id')) {
      context.handle(
        _personBIdMeta,
        personBId.isAcceptableOrUnknown(data['person_b_id']!, _personBIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personBIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RelationshipEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personAId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_a_id'],
      )!,
      personBId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_b_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strength'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
    );
  }

  @override
  $RelationshipsTable createAlias(String alias) {
    return $RelationshipsTable(attachedDatabase, alias);
  }
}

class RelationshipEntry extends DataClass
    implements Insertable<RelationshipEntry> {
  final int id;
  final int personAId;
  final int personBId;
  final String kind;
  final int? strength;
  final String? note;
  final DateTime? startDate;
  final DateTime? endDate;
  const RelationshipEntry({
    required this.id,
    required this.personAId,
    required this.personBId,
    required this.kind,
    this.strength,
    this.note,
    this.startDate,
    this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_a_id'] = Variable<int>(personAId);
    map['person_b_id'] = Variable<int>(personBId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<int>(strength);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    return map;
  }

  RelationshipsCompanion toCompanion(bool nullToAbsent) {
    return RelationshipsCompanion(
      id: Value(id),
      personAId: Value(personAId),
      personBId: Value(personBId),
      kind: Value(kind),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
    );
  }

  factory RelationshipEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelationshipEntry(
      id: serializer.fromJson<int>(json['id']),
      personAId: serializer.fromJson<int>(json['personAId']),
      personBId: serializer.fromJson<int>(json['personBId']),
      kind: serializer.fromJson<String>(json['kind']),
      strength: serializer.fromJson<int?>(json['strength']),
      note: serializer.fromJson<String?>(json['note']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personAId': serializer.toJson<int>(personAId),
      'personBId': serializer.toJson<int>(personBId),
      'kind': serializer.toJson<String>(kind),
      'strength': serializer.toJson<int?>(strength),
      'note': serializer.toJson<String?>(note),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
    };
  }

  RelationshipEntry copyWith({
    int? id,
    int? personAId,
    int? personBId,
    String? kind,
    Value<int?> strength = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
  }) => RelationshipEntry(
    id: id ?? this.id,
    personAId: personAId ?? this.personAId,
    personBId: personBId ?? this.personBId,
    kind: kind ?? this.kind,
    strength: strength.present ? strength.value : this.strength,
    note: note.present ? note.value : this.note,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  RelationshipEntry copyWithCompanion(RelationshipsCompanion data) {
    return RelationshipEntry(
      id: data.id.present ? data.id.value : this.id,
      personAId: data.personAId.present ? data.personAId.value : this.personAId,
      personBId: data.personBId.present ? data.personBId.value : this.personBId,
      kind: data.kind.present ? data.kind.value : this.kind,
      strength: data.strength.present ? data.strength.value : this.strength,
      note: data.note.present ? data.note.value : this.note,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipEntry(')
          ..write('id: $id, ')
          ..write('personAId: $personAId, ')
          ..write('personBId: $personBId, ')
          ..write('kind: $kind, ')
          ..write('strength: $strength, ')
          ..write('note: $note, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personAId,
    personBId,
    kind,
    strength,
    note,
    startDate,
    endDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelationshipEntry &&
          other.id == this.id &&
          other.personAId == this.personAId &&
          other.personBId == this.personBId &&
          other.kind == this.kind &&
          other.strength == this.strength &&
          other.note == this.note &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class RelationshipsCompanion extends UpdateCompanion<RelationshipEntry> {
  final Value<int> id;
  final Value<int> personAId;
  final Value<int> personBId;
  final Value<String> kind;
  final Value<int?> strength;
  final Value<String?> note;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  const RelationshipsCompanion({
    this.id = const Value.absent(),
    this.personAId = const Value.absent(),
    this.personBId = const Value.absent(),
    this.kind = const Value.absent(),
    this.strength = const Value.absent(),
    this.note = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  });
  RelationshipsCompanion.insert({
    this.id = const Value.absent(),
    required int personAId,
    required int personBId,
    this.kind = const Value.absent(),
    this.strength = const Value.absent(),
    this.note = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  }) : personAId = Value(personAId),
       personBId = Value(personBId);
  static Insertable<RelationshipEntry> custom({
    Expression<int>? id,
    Expression<int>? personAId,
    Expression<int>? personBId,
    Expression<String>? kind,
    Expression<int>? strength,
    Expression<String>? note,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personAId != null) 'person_a_id': personAId,
      if (personBId != null) 'person_b_id': personBId,
      if (kind != null) 'kind': kind,
      if (strength != null) 'strength': strength,
      if (note != null) 'note': note,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
  }

  RelationshipsCompanion copyWith({
    Value<int>? id,
    Value<int>? personAId,
    Value<int>? personBId,
    Value<String>? kind,
    Value<int?>? strength,
    Value<String?>? note,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
  }) {
    return RelationshipsCompanion(
      id: id ?? this.id,
      personAId: personAId ?? this.personAId,
      personBId: personBId ?? this.personBId,
      kind: kind ?? this.kind,
      strength: strength ?? this.strength,
      note: note ?? this.note,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personAId.present) {
      map['person_a_id'] = Variable<int>(personAId.value);
    }
    if (personBId.present) {
      map['person_b_id'] = Variable<int>(personBId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (strength.present) {
      map['strength'] = Variable<int>(strength.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('personAId: $personAId, ')
          ..write('personBId: $personBId, ')
          ..write('kind: $kind, ')
          ..write('strength: $strength, ')
          ..write('note: $note, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, GroupEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#607D8B'),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('group'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class GroupEntry extends DataClass implements Insertable<GroupEntry> {
  final int id;
  final String name;
  final String color;
  final String icon;
  const GroupEntry({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['icon'] = Variable<String>(icon);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      icon: Value(icon),
    );
  }

  factory GroupEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<String>(icon),
    };
  }

  GroupEntry copyWith({int? id, String? name, String? color, String? icon}) =>
      GroupEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        icon: icon ?? this.icon,
      );
  GroupEntry copyWithCompanion(GroupsCompanion data) {
    return GroupEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon);
}

class GroupsCompanion extends UpdateCompanion<GroupEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> color;
  final Value<String> icon;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
  }) : name = Value(name);
  static Insertable<GroupEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? icon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
    });
  }

  GroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? color,
    Value<String>? icon,
  }) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

class $PersonGroupsTable extends PersonGroups
    with TableInfo<$PersonGroupsTable, PersonGroupEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [personId, groupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonGroupEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {personId, groupId};
  @override
  PersonGroupEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonGroupEntry(
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
    );
  }

  @override
  $PersonGroupsTable createAlias(String alias) {
    return $PersonGroupsTable(attachedDatabase, alias);
  }
}

class PersonGroupEntry extends DataClass
    implements Insertable<PersonGroupEntry> {
  final int personId;
  final int groupId;
  const PersonGroupEntry({required this.personId, required this.groupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['person_id'] = Variable<int>(personId);
    map['group_id'] = Variable<int>(groupId);
    return map;
  }

  PersonGroupsCompanion toCompanion(bool nullToAbsent) {
    return PersonGroupsCompanion(
      personId: Value(personId),
      groupId: Value(groupId),
    );
  }

  factory PersonGroupEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonGroupEntry(
      personId: serializer.fromJson<int>(json['personId']),
      groupId: serializer.fromJson<int>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'personId': serializer.toJson<int>(personId),
      'groupId': serializer.toJson<int>(groupId),
    };
  }

  PersonGroupEntry copyWith({int? personId, int? groupId}) => PersonGroupEntry(
    personId: personId ?? this.personId,
    groupId: groupId ?? this.groupId,
  );
  PersonGroupEntry copyWithCompanion(PersonGroupsCompanion data) {
    return PersonGroupEntry(
      personId: data.personId.present ? data.personId.value : this.personId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonGroupEntry(')
          ..write('personId: $personId, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(personId, groupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonGroupEntry &&
          other.personId == this.personId &&
          other.groupId == this.groupId);
}

class PersonGroupsCompanion extends UpdateCompanion<PersonGroupEntry> {
  final Value<int> personId;
  final Value<int> groupId;
  final Value<int> rowid;
  const PersonGroupsCompanion({
    this.personId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonGroupsCompanion.insert({
    required int personId,
    required int groupId,
    this.rowid = const Value.absent(),
  }) : personId = Value(personId),
       groupId = Value(groupId);
  static Insertable<PersonGroupEntry> custom({
    Expression<int>? personId,
    Expression<int>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (personId != null) 'person_id': personId,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonGroupsCompanion copyWith({
    Value<int>? personId,
    Value<int>? groupId,
    Value<int>? rowid,
  }) {
    return PersonGroupsCompanion(
      personId: personId ?? this.personId,
      groupId: groupId ?? this.groupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonGroupsCompanion(')
          ..write('personId: $personId, ')
          ..write('groupId: $groupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventEntriesTable extends EventEntries
    with TableInfo<$EventEntriesTable, EventEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES persons (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, personId, date, kind, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $EventEntriesTable createAlias(String alias) {
    return $EventEntriesTable(attachedDatabase, alias);
  }
}

class EventEntry extends DataClass implements Insertable<EventEntry> {
  final int id;
  final int personId;
  final DateTime date;
  final String kind;
  final String description;
  const EventEntry({
    required this.id,
    required this.personId,
    required this.date,
    required this.kind,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_id'] = Variable<int>(personId);
    map['date'] = Variable<DateTime>(date);
    map['kind'] = Variable<String>(kind);
    map['description'] = Variable<String>(description);
    return map;
  }

  EventEntriesCompanion toCompanion(bool nullToAbsent) {
    return EventEntriesCompanion(
      id: Value(id),
      personId: Value(personId),
      date: Value(date),
      kind: Value(kind),
      description: Value(description),
    );
  }

  factory EventEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventEntry(
      id: serializer.fromJson<int>(json['id']),
      personId: serializer.fromJson<int>(json['personId']),
      date: serializer.fromJson<DateTime>(json['date']),
      kind: serializer.fromJson<String>(json['kind']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personId': serializer.toJson<int>(personId),
      'date': serializer.toJson<DateTime>(date),
      'kind': serializer.toJson<String>(kind),
      'description': serializer.toJson<String>(description),
    };
  }

  EventEntry copyWith({
    int? id,
    int? personId,
    DateTime? date,
    String? kind,
    String? description,
  }) => EventEntry(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    date: date ?? this.date,
    kind: kind ?? this.kind,
    description: description ?? this.description,
  );
  EventEntry copyWithCompanion(EventEntriesCompanion data) {
    return EventEntry(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      date: data.date.present ? data.date.value : this.date,
      kind: data.kind.present ? data.kind.value : this.kind,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventEntry(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, personId, date, kind, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventEntry &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.date == this.date &&
          other.kind == this.kind &&
          other.description == this.description);
}

class EventEntriesCompanion extends UpdateCompanion<EventEntry> {
  final Value<int> id;
  final Value<int> personId;
  final Value<DateTime> date;
  final Value<String> kind;
  final Value<String> description;
  const EventEntriesCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.description = const Value.absent(),
  });
  EventEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int personId,
    required DateTime date,
    required String kind,
    required String description,
  }) : personId = Value(personId),
       date = Value(date),
       kind = Value(kind),
       description = Value(description);
  static Insertable<EventEntry> custom({
    Expression<int>? id,
    Expression<int>? personId,
    Expression<DateTime>? date,
    Expression<String>? kind,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (description != null) 'description': description,
    });
  }

  EventEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? personId,
    Value<DateTime>? date,
    Value<String>? kind,
    Value<String>? description,
  }) {
    return EventEntriesCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventEntriesCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PersonsTable persons = $PersonsTable(this);
  late final $PersonalityProfilesTable personalityProfiles =
      $PersonalityProfilesTable(this);
  late final $RelationshipsTable relationships = $RelationshipsTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $PersonGroupsTable personGroups = $PersonGroupsTable(this);
  late final $EventEntriesTable eventEntries = $EventEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    persons,
    personalityProfiles,
    relationships,
    groups,
    personGroups,
    eventEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('personality_profiles', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('relationships', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('relationships', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('person_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('person_groups', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'persons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('event_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PersonsTableCreateCompanionBuilder =
    PersonsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> nickname,
      Value<String?> avatarPath,
      Value<DateTime?> birthDate,
      Value<String?> gender,
      Value<String> role,
      Value<String?> notes,
      Value<DateTime?> firstMetDate,
      Value<bool> isSelf,
      Value<DateTime> createdAt,
    });
typedef $$PersonsTableUpdateCompanionBuilder =
    PersonsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> nickname,
      Value<String?> avatarPath,
      Value<DateTime?> birthDate,
      Value<String?> gender,
      Value<String> role,
      Value<String?> notes,
      Value<DateTime?> firstMetDate,
      Value<bool> isSelf,
      Value<DateTime> createdAt,
    });

final class $$PersonsTableReferences
    extends BaseReferences<_$AppDatabase, $PersonsTable, PersonEntry> {
  $$PersonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $PersonalityProfilesTable,
    List<PersonalityProfileEntry>
  >
  _personalityProfilesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.personalityProfiles,
        aliasName: $_aliasNameGenerator(
          db.persons.id,
          db.personalityProfiles.personId,
        ),
      );

  $$PersonalityProfilesTableProcessedTableManager get personalityProfilesRefs {
    final manager = $$PersonalityProfilesTableTableManager(
      $_db,
      $_db.personalityProfiles,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalityProfilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonGroupsTable, List<PersonGroupEntry>>
  _personGroupsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personGroups,
    aliasName: $_aliasNameGenerator(db.persons.id, db.personGroups.personId),
  );

  $$PersonGroupsTableProcessedTableManager get personGroupsRefs {
    final manager = $$PersonGroupsTableTableManager(
      $_db,
      $_db.personGroups,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_personGroupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventEntriesTable, List<EventEntry>>
  _eventEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventEntries,
    aliasName: $_aliasNameGenerator(db.persons.id, db.eventEntries.personId),
  );

  $$EventEntriesTableProcessedTableManager get eventEntriesRefs {
    final manager = $$EventEntriesTableTableManager(
      $_db,
      $_db.eventEntries,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PersonsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstMetDate => $composableBuilder(
    column: $table.firstMetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSelf => $composableBuilder(
    column: $table.isSelf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personalityProfilesRefs(
    Expression<bool> Function($$PersonalityProfilesTableFilterComposer f) f,
  ) {
    final $$PersonalityProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalityProfiles,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalityProfilesTableFilterComposer(
            $db: $db,
            $table: $db.personalityProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personGroupsRefs(
    Expression<bool> Function($$PersonGroupsTableFilterComposer f) f,
  ) {
    final $$PersonGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personGroups,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonGroupsTableFilterComposer(
            $db: $db,
            $table: $db.personGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventEntriesRefs(
    Expression<bool> Function($$EventEntriesTableFilterComposer f) f,
  ) {
    final $$EventEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventEntries,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventEntriesTableFilterComposer(
            $db: $db,
            $table: $db.eventEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstMetDate => $composableBuilder(
    column: $table.firstMetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSelf => $composableBuilder(
    column: $table.isSelf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get firstMetDate => $composableBuilder(
    column: $table.firstMetDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSelf =>
      $composableBuilder(column: $table.isSelf, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> personalityProfilesRefs<T extends Object>(
    Expression<T> Function($$PersonalityProfilesTableAnnotationComposer a) f,
  ) {
    final $$PersonalityProfilesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.personalityProfiles,
          getReferencedColumn: (t) => t.personId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PersonalityProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.personalityProfiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> personGroupsRefs<T extends Object>(
    Expression<T> Function($$PersonGroupsTableAnnotationComposer a) f,
  ) {
    final $$PersonGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personGroups,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.personGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventEntriesRefs<T extends Object>(
    Expression<T> Function($$EventEntriesTableAnnotationComposer a) f,
  ) {
    final $$EventEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventEntries,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.eventEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonsTable,
          PersonEntry,
          $$PersonsTableFilterComposer,
          $$PersonsTableOrderingComposer,
          $$PersonsTableAnnotationComposer,
          $$PersonsTableCreateCompanionBuilder,
          $$PersonsTableUpdateCompanionBuilder,
          (PersonEntry, $$PersonsTableReferences),
          PersonEntry,
          PrefetchHooks Function({
            bool personalityProfilesRefs,
            bool personGroupsRefs,
            bool eventEntriesRefs,
          })
        > {
  $$PersonsTableTableManager(_$AppDatabase db, $PersonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> firstMetDate = const Value.absent(),
                Value<bool> isSelf = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PersonsCompanion(
                id: id,
                name: name,
                nickname: nickname,
                avatarPath: avatarPath,
                birthDate: birthDate,
                gender: gender,
                role: role,
                notes: notes,
                firstMetDate: firstMetDate,
                isSelf: isSelf,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> nickname = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> firstMetDate = const Value.absent(),
                Value<bool> isSelf = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PersonsCompanion.insert(
                id: id,
                name: name,
                nickname: nickname,
                avatarPath: avatarPath,
                birthDate: birthDate,
                gender: gender,
                role: role,
                notes: notes,
                firstMetDate: firstMetDate,
                isSelf: isSelf,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                personalityProfilesRefs = false,
                personGroupsRefs = false,
                eventEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (personalityProfilesRefs) db.personalityProfiles,
                    if (personGroupsRefs) db.personGroups,
                    if (eventEntriesRefs) db.eventEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (personalityProfilesRefs)
                        await $_getPrefetchedData<
                          PersonEntry,
                          $PersonsTable,
                          PersonalityProfileEntry
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._personalityProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).personalityProfilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personGroupsRefs)
                        await $_getPrefetchedData<
                          PersonEntry,
                          $PersonsTable,
                          PersonGroupEntry
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._personGroupsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).personGroupsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventEntriesRefs)
                        await $_getPrefetchedData<
                          PersonEntry,
                          $PersonsTable,
                          EventEntry
                        >(
                          currentTable: table,
                          referencedTable: $$PersonsTableReferences
                              ._eventEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonsTableReferences(
                                db,
                                table,
                                p0,
                              ).eventEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PersonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonsTable,
      PersonEntry,
      $$PersonsTableFilterComposer,
      $$PersonsTableOrderingComposer,
      $$PersonsTableAnnotationComposer,
      $$PersonsTableCreateCompanionBuilder,
      $$PersonsTableUpdateCompanionBuilder,
      (PersonEntry, $$PersonsTableReferences),
      PersonEntry,
      PrefetchHooks Function({
        bool personalityProfilesRefs,
        bool personGroupsRefs,
        bool eventEntriesRefs,
      })
    >;
typedef $$PersonalityProfilesTableCreateCompanionBuilder =
    PersonalityProfilesCompanion Function({
      Value<int> id,
      required int personId,
      Value<String> system,
      required String dataJson,
      Value<int> confidence,
      Value<String> source,
      Value<DateTime> updatedAt,
      Value<String?> shareId,
    });
typedef $$PersonalityProfilesTableUpdateCompanionBuilder =
    PersonalityProfilesCompanion Function({
      Value<int> id,
      Value<int> personId,
      Value<String> system,
      Value<String> dataJson,
      Value<int> confidence,
      Value<String> source,
      Value<DateTime> updatedAt,
      Value<String?> shareId,
    });

final class $$PersonalityProfilesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PersonalityProfilesTable,
          PersonalityProfileEntry
        > {
  $$PersonalityProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PersonsTable _personIdTable(_$AppDatabase db) =>
      db.persons.createAlias(
        $_aliasNameGenerator(db.personalityProfiles.personId, db.persons.id),
      );

  $$PersonsTableProcessedTableManager get personId {
    final $_column = $_itemColumn<int>('person_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalityProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalityProfilesTable> {
  $$PersonalityProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get system => $composableBuilder(
    column: $table.system,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shareId => $composableBuilder(
    column: $table.shareId,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalityProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalityProfilesTable> {
  $$PersonalityProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get system => $composableBuilder(
    column: $table.system,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shareId => $composableBuilder(
    column: $table.shareId,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalityProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalityProfilesTable> {
  $$PersonalityProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get system =>
      $composableBuilder(column: $table.system, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get shareId =>
      $composableBuilder(column: $table.shareId, builder: (column) => column);

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalityProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalityProfilesTable,
          PersonalityProfileEntry,
          $$PersonalityProfilesTableFilterComposer,
          $$PersonalityProfilesTableOrderingComposer,
          $$PersonalityProfilesTableAnnotationComposer,
          $$PersonalityProfilesTableCreateCompanionBuilder,
          $$PersonalityProfilesTableUpdateCompanionBuilder,
          (PersonalityProfileEntry, $$PersonalityProfilesTableReferences),
          PersonalityProfileEntry,
          PrefetchHooks Function({bool personId})
        > {
  $$PersonalityProfilesTableTableManager(
    _$AppDatabase db,
    $PersonalityProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalityProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalityProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PersonalityProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> personId = const Value.absent(),
                Value<String> system = const Value.absent(),
                Value<String> dataJson = const Value.absent(),
                Value<int> confidence = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> shareId = const Value.absent(),
              }) => PersonalityProfilesCompanion(
                id: id,
                personId: personId,
                system: system,
                dataJson: dataJson,
                confidence: confidence,
                source: source,
                updatedAt: updatedAt,
                shareId: shareId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int personId,
                Value<String> system = const Value.absent(),
                required String dataJson,
                Value<int> confidence = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> shareId = const Value.absent(),
              }) => PersonalityProfilesCompanion.insert(
                id: id,
                personId: personId,
                system: system,
                dataJson: dataJson,
                confidence: confidence,
                source: source,
                updatedAt: updatedAt,
                shareId: shareId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalityProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable:
                                    $$PersonalityProfilesTableReferences
                                        ._personIdTable(db),
                                referencedColumn:
                                    $$PersonalityProfilesTableReferences
                                        ._personIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PersonalityProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalityProfilesTable,
      PersonalityProfileEntry,
      $$PersonalityProfilesTableFilterComposer,
      $$PersonalityProfilesTableOrderingComposer,
      $$PersonalityProfilesTableAnnotationComposer,
      $$PersonalityProfilesTableCreateCompanionBuilder,
      $$PersonalityProfilesTableUpdateCompanionBuilder,
      (PersonalityProfileEntry, $$PersonalityProfilesTableReferences),
      PersonalityProfileEntry,
      PrefetchHooks Function({bool personId})
    >;
typedef $$RelationshipsTableCreateCompanionBuilder =
    RelationshipsCompanion Function({
      Value<int> id,
      required int personAId,
      required int personBId,
      Value<String> kind,
      Value<int?> strength,
      Value<String?> note,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
    });
typedef $$RelationshipsTableUpdateCompanionBuilder =
    RelationshipsCompanion Function({
      Value<int> id,
      Value<int> personAId,
      Value<int> personBId,
      Value<String> kind,
      Value<int?> strength,
      Value<String?> note,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
    });

final class $$RelationshipsTableReferences
    extends
        BaseReferences<_$AppDatabase, $RelationshipsTable, RelationshipEntry> {
  $$RelationshipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PersonsTable _personAIdTable(_$AppDatabase db) =>
      db.persons.createAlias(
        $_aliasNameGenerator(db.relationships.personAId, db.persons.id),
      );

  $$PersonsTableProcessedTableManager get personAId {
    final $_column = $_itemColumn<int>('person_a_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personAIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PersonsTable _personBIdTable(_$AppDatabase db) =>
      db.persons.createAlias(
        $_aliasNameGenerator(db.relationships.personBId, db.persons.id),
      );

  $$PersonsTableProcessedTableManager get personBId {
    final $_column = $_itemColumn<int>('person_b_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personBIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RelationshipsTableFilterComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableFilterComposer get personAId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personAId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableFilterComposer get personBId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personBId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableOrderingComposer get personAId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personAId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableOrderingComposer get personBId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personBId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelationshipsTable> {
  $$RelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  $$PersonsTableAnnotationComposer get personAId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personAId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PersonsTableAnnotationComposer get personBId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personBId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RelationshipsTable,
          RelationshipEntry,
          $$RelationshipsTableFilterComposer,
          $$RelationshipsTableOrderingComposer,
          $$RelationshipsTableAnnotationComposer,
          $$RelationshipsTableCreateCompanionBuilder,
          $$RelationshipsTableUpdateCompanionBuilder,
          (RelationshipEntry, $$RelationshipsTableReferences),
          RelationshipEntry,
          PrefetchHooks Function({bool personAId, bool personBId})
        > {
  $$RelationshipsTableTableManager(_$AppDatabase db, $RelationshipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelationshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelationshipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> personAId = const Value.absent(),
                Value<int> personBId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> strength = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
              }) => RelationshipsCompanion(
                id: id,
                personAId: personAId,
                personBId: personBId,
                kind: kind,
                strength: strength,
                note: note,
                startDate: startDate,
                endDate: endDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int personAId,
                required int personBId,
                Value<String> kind = const Value.absent(),
                Value<int?> strength = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
              }) => RelationshipsCompanion.insert(
                id: id,
                personAId: personAId,
                personBId: personBId,
                kind: kind,
                strength: strength,
                note: note,
                startDate: startDate,
                endDate: endDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RelationshipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personAId = false, personBId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personAId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personAId,
                                referencedTable: $$RelationshipsTableReferences
                                    ._personAIdTable(db),
                                referencedColumn: $$RelationshipsTableReferences
                                    ._personAIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (personBId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personBId,
                                referencedTable: $$RelationshipsTableReferences
                                    ._personBIdTable(db),
                                referencedColumn: $$RelationshipsTableReferences
                                    ._personBIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RelationshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RelationshipsTable,
      RelationshipEntry,
      $$RelationshipsTableFilterComposer,
      $$RelationshipsTableOrderingComposer,
      $$RelationshipsTableAnnotationComposer,
      $$RelationshipsTableCreateCompanionBuilder,
      $$RelationshipsTableUpdateCompanionBuilder,
      (RelationshipEntry, $$RelationshipsTableReferences),
      RelationshipEntry,
      PrefetchHooks Function({bool personAId, bool personBId})
    >;
typedef $$GroupsTableCreateCompanionBuilder =
    GroupsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> color,
      Value<String> icon,
    });
typedef $$GroupsTableUpdateCompanionBuilder =
    GroupsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> color,
      Value<String> icon,
    });

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, GroupEntry> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PersonGroupsTable, List<PersonGroupEntry>>
  _personGroupsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personGroups,
    aliasName: $_aliasNameGenerator(db.groups.id, db.personGroups.groupId),
  );

  $$PersonGroupsTableProcessedTableManager get personGroupsRefs {
    final manager = $$PersonGroupsTableTableManager(
      $_db,
      $_db.personGroups,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_personGroupsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personGroupsRefs(
    Expression<bool> Function($$PersonGroupsTableFilterComposer f) f,
  ) {
    final $$PersonGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personGroups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonGroupsTableFilterComposer(
            $db: $db,
            $table: $db.personGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  Expression<T> personGroupsRefs<T extends Object>(
    Expression<T> Function($$PersonGroupsTableAnnotationComposer a) f,
  ) {
    final $$PersonGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personGroups,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.personGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsTable,
          GroupEntry,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (GroupEntry, $$GroupsTableReferences),
          GroupEntry,
          PrefetchHooks Function({bool personGroupsRefs})
        > {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
              }) =>
                  GroupsCompanion(id: id, name: name, color: color, icon: icon),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
              }) => GroupsCompanion.insert(
                id: id,
                name: name,
                color: color,
                icon: icon,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GroupsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({personGroupsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (personGroupsRefs) db.personGroups],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (personGroupsRefs)
                    await $_getPrefetchedData<
                      GroupEntry,
                      $GroupsTable,
                      PersonGroupEntry
                    >(
                      currentTable: table,
                      referencedTable: $$GroupsTableReferences
                          ._personGroupsRefsTable(db),
                      managerFromTypedResult: (p0) => $$GroupsTableReferences(
                        db,
                        table,
                        p0,
                      ).personGroupsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.groupId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsTable,
      GroupEntry,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (GroupEntry, $$GroupsTableReferences),
      GroupEntry,
      PrefetchHooks Function({bool personGroupsRefs})
    >;
typedef $$PersonGroupsTableCreateCompanionBuilder =
    PersonGroupsCompanion Function({
      required int personId,
      required int groupId,
      Value<int> rowid,
    });
typedef $$PersonGroupsTableUpdateCompanionBuilder =
    PersonGroupsCompanion Function({
      Value<int> personId,
      Value<int> groupId,
      Value<int> rowid,
    });

final class $$PersonGroupsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PersonGroupsTable, PersonGroupEntry> {
  $$PersonGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PersonsTable _personIdTable(_$AppDatabase db) =>
      db.persons.createAlias(
        $_aliasNameGenerator(db.personGroups.personId, db.persons.id),
      );

  $$PersonsTableProcessedTableManager get personId {
    final $_column = $_itemColumn<int>('person_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups.createAlias(
    $_aliasNameGenerator(db.personGroups.groupId, db.groups.id),
  );

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonGroupsTable> {
  $$PersonGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonGroupsTable> {
  $$PersonGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonGroupsTable> {
  $$PersonGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonGroupsTable,
          PersonGroupEntry,
          $$PersonGroupsTableFilterComposer,
          $$PersonGroupsTableOrderingComposer,
          $$PersonGroupsTableAnnotationComposer,
          $$PersonGroupsTableCreateCompanionBuilder,
          $$PersonGroupsTableUpdateCompanionBuilder,
          (PersonGroupEntry, $$PersonGroupsTableReferences),
          PersonGroupEntry,
          PrefetchHooks Function({bool personId, bool groupId})
        > {
  $$PersonGroupsTableTableManager(_$AppDatabase db, $PersonGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> personId = const Value.absent(),
                Value<int> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonGroupsCompanion(
                personId: personId,
                groupId: groupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int personId,
                required int groupId,
                Value<int> rowid = const Value.absent(),
              }) => PersonGroupsCompanion.insert(
                personId: personId,
                groupId: groupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false, groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable: $$PersonGroupsTableReferences
                                    ._personIdTable(db),
                                referencedColumn: $$PersonGroupsTableReferences
                                    ._personIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable: $$PersonGroupsTableReferences
                                    ._groupIdTable(db),
                                referencedColumn: $$PersonGroupsTableReferences
                                    ._groupIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PersonGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonGroupsTable,
      PersonGroupEntry,
      $$PersonGroupsTableFilterComposer,
      $$PersonGroupsTableOrderingComposer,
      $$PersonGroupsTableAnnotationComposer,
      $$PersonGroupsTableCreateCompanionBuilder,
      $$PersonGroupsTableUpdateCompanionBuilder,
      (PersonGroupEntry, $$PersonGroupsTableReferences),
      PersonGroupEntry,
      PrefetchHooks Function({bool personId, bool groupId})
    >;
typedef $$EventEntriesTableCreateCompanionBuilder =
    EventEntriesCompanion Function({
      Value<int> id,
      required int personId,
      required DateTime date,
      required String kind,
      required String description,
    });
typedef $$EventEntriesTableUpdateCompanionBuilder =
    EventEntriesCompanion Function({
      Value<int> id,
      Value<int> personId,
      Value<DateTime> date,
      Value<String> kind,
      Value<String> description,
    });

final class $$EventEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EventEntriesTable, EventEntry> {
  $$EventEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PersonsTable _personIdTable(_$AppDatabase db) =>
      db.persons.createAlias(
        $_aliasNameGenerator(db.eventEntries.personId, db.persons.id),
      );

  $$PersonsTableProcessedTableManager get personId {
    final $_column = $_itemColumn<int>('person_id')!;

    final manager = $$PersonsTableTableManager(
      $_db,
      $_db.persons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EventEntriesTable> {
  $$EventEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonsTableFilterComposer get personId {
    final $$PersonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableFilterComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EventEntriesTable> {
  $$EventEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonsTableOrderingComposer get personId {
    final $$PersonsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableOrderingComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventEntriesTable> {
  $$EventEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$PersonsTableAnnotationComposer get personId {
    final $$PersonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.persons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonsTableAnnotationComposer(
            $db: $db,
            $table: $db.persons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventEntriesTable,
          EventEntry,
          $$EventEntriesTableFilterComposer,
          $$EventEntriesTableOrderingComposer,
          $$EventEntriesTableAnnotationComposer,
          $$EventEntriesTableCreateCompanionBuilder,
          $$EventEntriesTableUpdateCompanionBuilder,
          (EventEntry, $$EventEntriesTableReferences),
          EventEntry,
          PrefetchHooks Function({bool personId})
        > {
  $$EventEntriesTableTableManager(_$AppDatabase db, $EventEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> personId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> description = const Value.absent(),
              }) => EventEntriesCompanion(
                id: id,
                personId: personId,
                date: date,
                kind: kind,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int personId,
                required DateTime date,
                required String kind,
                required String description,
              }) => EventEntriesCompanion.insert(
                id: id,
                personId: personId,
                date: date,
                kind: kind,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EventEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable: $$EventEntriesTableReferences
                                    ._personIdTable(db),
                                referencedColumn: $$EventEntriesTableReferences
                                    ._personIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventEntriesTable,
      EventEntry,
      $$EventEntriesTableFilterComposer,
      $$EventEntriesTableOrderingComposer,
      $$EventEntriesTableAnnotationComposer,
      $$EventEntriesTableCreateCompanionBuilder,
      $$EventEntriesTableUpdateCompanionBuilder,
      (EventEntry, $$EventEntriesTableReferences),
      EventEntry,
      PrefetchHooks Function({bool personId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PersonsTableTableManager get persons =>
      $$PersonsTableTableManager(_db, _db.persons);
  $$PersonalityProfilesTableTableManager get personalityProfiles =>
      $$PersonalityProfilesTableTableManager(_db, _db.personalityProfiles);
  $$RelationshipsTableTableManager get relationships =>
      $$RelationshipsTableTableManager(_db, _db.relationships);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$PersonGroupsTableTableManager get personGroups =>
      $$PersonGroupsTableTableManager(_db, _db.personGroups);
  $$EventEntriesTableTableManager get eventEntries =>
      $$EventEntriesTableTableManager(_db, _db.eventEntries);
}
