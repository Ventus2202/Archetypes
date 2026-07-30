import 'package:archetypes/data/repositories/content_repository.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
import 'package:archetypes/domain/team/team_models.dart';
import 'package:flutter_test/flutter_test.dart';

// `pubspec.yaml` listed `assets/content/<locale>/mbti.json` file by file, so
// `career_roles.json`, `relationship_dynamics.json` and `team_objectives.json`
// were never bundled: every screen reading them failed at runtime while the
// files sat in the repo. Loading through the real `rootBundle` is what catches
// an undeclared asset — a unit test on the JSON files themselves would not.
//
// The key coverage checks below are the other half: the engines emit keys and
// the content resolves them, so a key that exists on one side only is a label
// the user reads raw.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const locales = ['it', 'en'];
  final repo = ContentRepository();

  for (final locale in locales) {
    group('assets/content/$locale', () {
      test('mbti.json: 16 tipi e 8 funzioni', () async {
        final content = await repo.loadMbtiContent(locale);

        expect(content.types, hasLength(16));
        expect(content.functions, hasLength(8));
        for (final type in MbtiType.values) {
          expect(content.types[type.label], isNotNull,
              reason: 'manca il contenuto per ${type.label}');
        }
        for (final f in CognitiveFunction.values) {
          expect(content.functions[f.label], isNotNull,
              reason: 'manca il contenuto per ${f.label}');
        }
      });

      test('career_roles.json: si carica e ha ruoli', () async {
        final content = await repo.loadCareerRolesContent(locale);
        expect(content.roles, isNotEmpty);
      });

      test('relationship_dynamics.json: si carica e ha le tre sezioni',
          () async {
        final content = await repo.loadDynamicsContent(locale);

        expect(content.frictions, isNotEmpty);
        expect(content.growths, isNotEmpty);
        expect(content.communications, isNotEmpty);
      });

      test('team_objectives.json: copre obiettivi, punti di forza e blind spot',
          () async {
        final content = await repo.loadTeamObjectivesContent(locale);

        for (final objective in TeamObjective.values) {
          final entry =
              content.objectives[objective.name] as Map<String, dynamic>?;
          expect(entry, isNotNull,
              reason: 'manca l\'obiettivo ${objective.name}');
          for (final field in ['title', 'description', 'ideal_profile']) {
            expect(entry![field], isA<String>(),
                reason: '${objective.name} senza $field');
          }
        }

        // `TeamOptimizer` builds these keys from the cognitive function label,
        // for any function an objective weights at 0.8 or more — which, across
        // the six objectives, is all eight of them.
        for (final f in CognitiveFunction.values) {
          final key = f.label.toLowerCase();
          expect(content.strengths['strength_$key'], isA<String>(),
              reason: 'manca strength_$key');
          expect(content.blindSpots['blindspot_$key'], isA<String>(),
              reason: 'manca blindspot_$key');
        }
      });
    });
  }
}
