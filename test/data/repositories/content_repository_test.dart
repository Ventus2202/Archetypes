import 'dart:convert';

import 'package:archetypes/data/repositories/content_repository.dart';
import 'package:archetypes/domain/quiz/quiz_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// An asset bundle that serves crafted JSON per path and counts the reads, so
/// the tests can tell a cache hit from a reload without touching real assets.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.contents);

  final Map<String, String> contents;
  final List<String> loads = [];

  @override
  Future<ByteData> load(String key) async {
    loads.add(key);
    final value = contents[key];
    if (value == null) {
      throw FlutterError('Unable to load asset: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    // Bypass CachingAssetBundle's own string cache: these tests measure the
    // repository's caching, not the bundle's.
    final data = await load(key);
    return utf8.decode(data.buffer.asUint8List());
  }
}

String _mbtiJson(String marker) => json.encode({
      'types': {
        'INTJ': {'title': marker}
      },
      'functions': <String, dynamic>{},
      'dichotomies': <String, dynamic>{},
    });

void main() {
  Map<String, String> fullBundle() => {
        'assets/content/it/mbti.json': _mbtiJson('Architetto'),
        'assets/content/en/mbti.json': _mbtiJson('Architect'),
        'assets/content/it/career_roles.json': json.encode({
          'roles': {
            'dev': {'title': 'Sviluppatore'}
          }
        }),
        'assets/content/en/career_roles.json': json.encode({
          'roles': {
            'dev': {'title': 'Developer'}
          }
        }),
        'assets/content/it/relationship_dynamics.json':
            json.encode({'frictions': {}, 'growths': {}, 'communications': {}}),
        'assets/content/en/relationship_dynamics.json':
            json.encode({'frictions': {}, 'growths': {}, 'communications': {}}),
        'assets/content/it/team_objectives.json':
            json.encode({'objectives': {}}),
        'assets/content/en/team_objectives.json':
            json.encode({'objectives': {}}),
        'assets/quiz/it/mbti_short.json': json.encode({'questions': []}),
        'assets/quiz/en/mbti_short.json': json.encode({'questions': []}),
      };

  String titleOf(MbtiContent content) =>
      (content.types['INTJ'] as Map)['title'] as String;

  group('cache per locale', () {
    // Until 2026-07-29 the four caches shared one `_loadedLocale` and each
    // loader overwrote it with its own language, so this exact sequence served
    // the Italian MBTI cache to an English UI.
    test('un loader in EN non fa passare per EN la cache MBTI riempita in IT',
        () async {
      final bundle = _FakeBundle(fullBundle());
      final repo = ContentRepository(bundle: bundle);

      expect(titleOf(await repo.loadMbtiContent('it')), 'Architetto');
      await repo.loadCareerRolesContent('en');

      expect(titleOf(await repo.loadMbtiContent('en')), 'Architect');
    });

    test('tornare alla lingua precedente serve di nuovo il contenuto giusto',
        () async {
      final bundle = _FakeBundle(fullBundle());
      final repo = ContentRepository(bundle: bundle);

      expect(titleOf(await repo.loadMbtiContent('it')), 'Architetto');
      expect(titleOf(await repo.loadMbtiContent('en')), 'Architect');
      expect(titleOf(await repo.loadMbtiContent('it')), 'Architetto');
    });

    test('la stessa lingua si legge dal bundle una volta sola', () async {
      final bundle = _FakeBundle(fullBundle());
      final repo = ContentRepository(bundle: bundle);

      await repo.loadMbtiContent('it');
      await repo.loadMbtiContent('it');
      await repo.loadCareerRolesContent('it');
      await repo.loadCareerRolesContent('it');

      expect(bundle.loads, [
        'assets/content/it/mbti.json',
        'assets/content/it/career_roles.json',
      ]);
    });

    test('una lingua non supportata ricade su EN e condivide quella cache',
        () async {
      final bundle = _FakeBundle(fullBundle());
      final repo = ContentRepository(bundle: bundle);

      expect(titleOf(await repo.loadMbtiContent('fr')), 'Architect');
      await repo.loadMbtiContent('en');

      expect(bundle.loads, ['assets/content/en/mbti.json']);
    });
  });

  group('politica sugli errori: il repository propaga', () {
    // Four of the five loaders used to return empty content on any failure, so
    // a broken asset reached the user as a blank screen with no explanation.
    final broken = _FakeBundle({});

    test('loadMbtiContent', () {
      expect(ContentRepository(bundle: broken).loadMbtiContent('it'),
          throwsA(isA<FlutterError>()));
    });

    test('loadDynamicsContent', () {
      expect(ContentRepository(bundle: broken).loadDynamicsContent('it'),
          throwsA(isA<FlutterError>()));
    });

    test('loadCareerRolesContent', () {
      expect(ContentRepository(bundle: broken).loadCareerRolesContent('it'),
          throwsA(isA<FlutterError>()));
    });

    test('loadTeamObjectivesContent', () {
      expect(ContentRepository(bundle: broken).loadTeamObjectivesContent('it'),
          throwsA(isA<FlutterError>()));
    });

    test('loadQuizQuestions', () {
      expect(
          ContentRepository(bundle: broken)
              .loadQuizQuestions('it', QuizLength.short),
          throwsA(isA<FlutterError>()));
    });

    test('un JSON malformato propaga invece di dare contenuto vuoto', () {
      final malformed = _FakeBundle({
        'assets/content/it/career_roles.json': '{not json',
      });

      expect(ContentRepository(bundle: malformed).loadCareerRolesContent('it'),
          throwsA(isA<FormatException>()));
    });

    test('un errore non lascia in cache contenuto vuoto', () async {
      final contents = fullBundle();
      contents.remove('assets/content/it/mbti.json');
      final bundle = _FakeBundle(contents);
      final repo = ContentRepository(bundle: bundle);

      await expectLater(repo.loadMbtiContent('it'), throwsA(isA<FlutterError>()));

      contents['assets/content/it/mbti.json'] = _mbtiJson('Architetto');
      expect(titleOf(await repo.loadMbtiContent('it')), 'Architetto');
    });
  });
}
