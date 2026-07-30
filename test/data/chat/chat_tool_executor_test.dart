import 'dart:convert';

import 'package:archetypes/data/chat/chat_tools.dart';
import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/data/repositories/person_repository.dart';
import 'package:archetypes/data/repositories/profile_repository.dart';
import 'package:archetypes/domain/career/career_catalog.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
// Only `Value` is needed, and a bare drift import would shadow the
// `isNull`/`isNotNull` matchers with drift's SQL expressions of the same name.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// The chat tools are the "thick" layer the model orchestrates: they run the
// domain engines against the real repositories and return JSON. These tests
// drive them over an in-memory database, so they cover both the repo wiring and
// the JSON contract the model sees.
void main() {
  late AppDatabase db;
  late ChatToolExecutor executor;

  Future<int> addPerson(String name, MbtiType? type, {bool isSelf = false}) async {
    final id = await db.into(db.persons).insert(
          PersonsCompanion.insert(name: name, isSelf: Value(isSelf)),
        );
    if (type != null) {
      await db.into(db.personalityProfiles).insert(
            PersonalityProfilesCompanion.insert(
              personId: id,
              dataJson: MbtiProfile.fromType(type).toJsonString(),
            ),
          );
    }
    return id;
  }

  Future<Map<String, dynamic>> run(
    String tool, [
    Map<String, dynamic> input = const {},
  ]) async =>
      jsonDecode(await executor.execute(tool, input)) as Map<String, dynamic>;

  // The tools return JSON arrays of objects, so every element comes out of
  // `jsonDecode` as `dynamic`. Casting once here keeps the field reads below
  // static calls (`avoid_dynamic_calls`) instead of thirteen dynamic ones.
  List<Map<String, dynamic>> rows(Object? value) =>
      (value! as List).cast<Map<String, dynamic>>();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    executor = ChatToolExecutor(
      personRepo: PersonRepository(db),
      profileRepo: ProfileRepository(db),
    );
  });

  tearDown(() => db.close());

  test('list_people include il flag is_self e il tipo MBTI', () async {
    await addPerson('Ada', MbtiType.intj, isSelf: true);
    await addPerson('Bob', MbtiType.enfp);
    await addPerson('Senza profilo', null);

    final people = rows((await run('list_people'))['people']);

    expect(people.length, 3);
    final ada = people.firstWhere((p) => p['name'] == 'Ada');
    expect(ada['is_self'], isTrue);
    expect(ada['mbti'], 'INTJ');
    expect(
      people.firstWhere((p) => p['name'] == 'Senza profilo')['mbti'],
      isNull,
    );
  });

  test('list_roles espone gli id del catalogo', () async {
    final roles = rows((await run('list_roles'))['roles']);

    expect(roles.length, kCareerRoles.length);
    expect(roles.map((r) => r['id']), contains('researcher'));
  });

  test('compute_affinity restituisce score e livello', () async {
    final a = await addPerson('Ada', MbtiType.intj);
    final b = await addPerson('Bob', MbtiType.enfp);

    final res = await run('compute_affinity', {
      'person_a_id': a,
      'person_b_id': b,
    });

    expect(res['person_a'], 'Ada');
    expect(res['person_b'], 'Bob');
    expect(res['score'], isA<int>());
    expect(res['score'], inInclusiveRange(0, 100));
    expect(res['level'], isNotNull);
    expect(res['top_factors'], isA<List>());
  });

  test('compute_affinity su persona senza profilo -> errore, non crash', () async {
    final a = await addPerson('Ada', MbtiType.intj);
    final b = await addPerson('Bob', null);

    final res = await run('compute_affinity', {
      'person_a_id': a,
      'person_b_id': b,
    });

    expect(res['error'], isNotNull);
  });

  test('gli id arrivano anche come stringa dal modello', () async {
    final a = await addPerson('Ada', MbtiType.intj);
    final b = await addPerson('Bob', MbtiType.enfp);

    final res = await run('compute_affinity', {
      'person_a_id': '$a',
      'person_b_id': '$b',
    });

    expect(res['error'], isNull);
    expect(res['person_a'], 'Ada');
  });

  test('best_pairs ordina per score e rispetta top_n', () async {
    await addPerson('Ada', MbtiType.intj);
    await addPerson('Bob', MbtiType.enfp);
    await addPerson('Cleo', MbtiType.istj);
    await addPerson('Dan', MbtiType.esfj);

    final all = rows((await run('best_pairs', {'top_n': 10}))['pairs']);
    expect(all.length, 6); // 4 persone -> C(4,2)
    for (var i = 1; i < all.length; i++) {
      expect(all[i - 1]['score'], greaterThanOrEqualTo(all[i]['score'] as int));
    }

    final limited = rows((await run('best_pairs', {'top_n': 2}))['pairs']);
    expect(limited.length, 2);
  });

  test('optimize_team con must_include_id tiene davvero la persona', () async {
    // ISFP è una scelta pessima per `execution`: senza il vincolo non entra.
    final isfp = await addPerson('Isa', MbtiType.isfp);
    await addPerson('Enzo', MbtiType.estj);
    await addPerson('Ivo', MbtiType.istj);
    await addPerson('Ester', MbtiType.estp);
    await addPerson('Ilde', MbtiType.istp);
    await addPerson('Ennio', MbtiType.esfj);

    final free = await run('optimize_team', {
      'objective': 'execution',
      'team_size': 3,
    });
    expect(free['team'], isNot(contains('Isa')));

    final pinned = await run('optimize_team', {
      'objective': 'execution',
      'team_size': 3,
      'must_include_id': isfp,
    });

    expect(pinned['error'], isNull);
    expect(pinned['team'], contains('Isa'));
    expect((pinned['team'] as List).length, 3);
  });

  test('optimize_team con must_include_id sconosciuto -> errore esplicito', () async {
    await addPerson('Ada', MbtiType.intj);
    await addPerson('Bob', MbtiType.enfp);
    await addPerson('Cleo', MbtiType.istj);

    final res = await run('optimize_team', {
      'objective': 'execution',
      'team_size': 3,
      'must_include_id': 999,
    });

    expect(res['team'], isNull);
    expect(res['error'], isNotNull);
  });

  test('optimize_team con troppe poche persone -> errore', () async {
    await addPerson('Ada', MbtiType.intj);

    final res = await run('optimize_team', {'objective': 'strategy'});

    expect(res['error'], isNotNull);
  });

  test('rank_people_for_role classifica in ordine decrescente', () async {
    await addPerson('Ada', MbtiType.intj);
    await addPerson('Bob', MbtiType.enfp);
    await addPerson('Cleo', MbtiType.estj);

    final res = await run('rank_people_for_role', {'role_id': 'researcher'});
    final ranking = rows(res['ranking']);

    expect(res['role'], 'researcher');
    expect(ranking.length, 3);
    for (var i = 1; i < ranking.length; i++) {
      expect(
        ranking[i - 1]['score'],
        greaterThanOrEqualTo(ranking[i]['score'] as int),
      );
    }
  });

  test('rank_people_for_role con ruolo ignoto elenca quelli validi', () async {
    await addPerson('Ada', MbtiType.intj);

    final res = await run('rank_people_for_role', {'role_id': 'astronauta'});

    expect(res['error'], isNotNull);
    expect(res['available'], contains('researcher'));
  });

  test('career_fit restituisce i ruoli migliori per la persona', () async {
    final id = await addPerson('Ada', MbtiType.intj);

    final res = await run('career_fit', {'person_id': id, 'top_n': 3});
    final roles = rows(res['roles']);

    expect(res['person'], 'Ada');
    expect(roles.length, 3);
    expect(roles.first['role_id'], isNotNull);
    for (var i = 1; i < roles.length; i++) {
      expect(roles[i - 1]['score'], greaterThanOrEqualTo(roles[i]['score'] as int));
    }
  });

  test('career_fit su id inesistente -> errore', () async {
    final res = await run('career_fit', {'person_id': 42});

    expect(res['error'], isNotNull);
  });

  test('tool sconosciuto -> errore, non eccezione', () async {
    final res = await run('teleport');

    expect(res['error'], contains('teleport'));
  });
}
