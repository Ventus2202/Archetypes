import 'package:archetypes/data/repositories/content_repository.dart';
import 'package:archetypes/domain/affinity/relationship_dynamics.dart';
import 'package:archetypes/domain/career/career_catalog.dart';
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
/// Asserts that `section[key]` exists and carries every [fields] entry as a
/// non-empty string. An entry that is present but blank reads on screen exactly
/// like a missing one.
void expectEntry(
  Map<String, dynamic> section,
  String key, {
  List<String> fields = const ['title', 'description'],
}) {
  final entry = section[key] as Map<String, dynamic>?;
  expect(entry, isNotNull, reason: 'manca la voce $key');
  for (final field in fields) {
    expect(entry![field], isA<String>(), reason: '$key senza $field');
    expect(entry[field] as String, isNotEmpty, reason: '$key con $field vuoto');
  }
}

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

      test('career_roles.json: copre i 16 ruoli del catalogo', () async {
        final content = await repo.loadCareerRolesContent(locale);

        // `career_fit_screen` indexes by `role.id` (not by `titleKey`) and
        // falls back to `?? titleKey` / `?? ''`, so a renamed id comes back on
        // screen as `career_researcher` with an empty body, silently.
        expect(content.roles, hasLength(kCareerRoles.length));
        for (final role in kCareerRoles) {
          expectEntry(content.roles, role.id,
              fields: const ['title', 'description', 'why_fit']);
        }
      });

      test('relationship_dynamics.json: copre le chiavi che il motore emette',
          () async {
        final content = await repo.loadDynamicsContent(locale);

        // `RelationshipDynamics` emits the naked content key and
        // `person_detail` resolves it with `?? contentKey`, so a missing entry
        // is a raw `conflict_ne_si` in the report.
        for (final key
            in RelationshipDynamics.kFunctionConflicts.values.toSet()) {
          expectEntry(content.frictions, key);
        }

        // `_calculateGrowth` builds `growth_<function>` for any function that
        // is weak on one side and strong on the other: all eight can occur.
        for (final f in CognitiveFunction.values) {
          expectEntry(content.growths, 'growth_${f.label.toLowerCase()}');
        }

        // Every I/E × T/F pairing, plus the fallback used when the pair is not
        // in the table.
        for (final key in {
          ...RelationshipDynamics.kCommunicationPatterns.values,
          'comm_default',
        }) {
          expectEntry(content.communications, key);
        }
      });

      test('team_objectives.json: copre obiettivi, punti di forza e blind spot',
          () async {
        final content = await repo.loadTeamObjectivesContent(locale);

        for (final objective in TeamObjective.values) {
          expectEntry(content.objectives, objective.name,
              fields: const ['title', 'description', 'ideal_profile']);
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
