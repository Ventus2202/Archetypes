import 'package:archetypes/data/repositories/content_repository.dart';
import 'package:archetypes/domain/affinity/relationship_dynamics.dart';
import 'package:archetypes/domain/career/career_catalog.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_functions.dart';
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

/// Asserts `entry[field]` is a non-empty string. [at] names the entry so a
/// failure says which of the 16 types (or 8 functions) is broken.
void expectText(Map<String, dynamic> entry, String field, {required String at}) {
  expect(entry[field], isA<String>(), reason: '$at senza $field');
  expect(entry[field] as String, isNotEmpty, reason: '$at con $field vuoto');
}

/// Same for a list of strings: the list must exist, carry at least one item and
/// no blank one. `content_viewer` renders these with `?? []`, so an empty list
/// is a section that silently disappears.
void expectTextList(Map<String, dynamic> entry, String field,
    {required String at}) {
  expect(entry[field], isA<List>(), reason: '$at senza $field');
  final items = entry[field] as List;
  expect(items, isNotEmpty, reason: '$at con $field vuoto');
  for (var i = 0; i < items.length; i++) {
    expect(items[i], isA<String>(), reason: '$at.$field[$i] non è una stringa');
    expect(items[i] as String, isNotEmpty, reason: '$at.$field[$i] vuoto');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const locales = ['it', 'en'];
  final repo = ContentRepository();

  for (final locale in locales) {
    group('assets/content/$locale', () {
      test('mbti.json: i 16 tipi portano i campi che la scheda legge', () async {
        final content = await repo.loadMbtiContent(locale);

        expect(content.types, hasLength(16));
        for (final type in MbtiType.values) {
          final entry = repo.getTypeContent(content, type.label);
          expect(entry, isNotNull,
              reason: 'manca il contenuto per ${type.label}');

          // The fields `_MbtiTypeBody` renders. Every one of them is behind a
          // `?? []` or an `if (... != null)`, so a missing one is a section
          // that vanishes from the card without a word.
          final at = 'types.${type.label}';
          expectText(entry!, 'title', at: at);
          expectText(entry, 'tagline', at: at);
          // One string, paragraphs separated by a blank line — not a list.
          expectText(entry, 'description', at: at);
          expectText(entry, 'in_relationships', at: at);
          expectText(entry, 'at_work', at: at);
          expectTextList(entry, 'stack', at: at);
          expectTextList(entry, 'strengths', at: at);
          expectTextList(entry, 'weaknesses', at: at);
          expectTextList(entry, 'behavioral_traits', at: at);
          expectTextList(entry, 'famous_examples_fictional', at: at);

          // Compatibility is three lists of type labels rendered as chips: a
          // typo there is a chip that names no type at all.
          final compat = entry['compatibility_notes'] as Map<String, dynamic>?;
          expect(compat, isNotNull, reason: '$at senza compatibility_notes');
          for (final group in const [
            'high_affinity',
            'good_working',
            'challenging_growth',
          ]) {
            expectTextList(compat!, group, at: at);
            for (final label in (compat[group] as List).cast<String>()) {
              expect(MbtiType.fromLabel(label), isNotNull,
                  reason: '$at.$group: $label non è un tipo MBTI');
            }
          }
        }
      });

      test('mbti.json: le 8 funzioni portano i campi che la scheda legge',
          () async {
        final content = await repo.loadMbtiContent(locale);

        expect(content.functions, hasLength(8));
        for (final f in CognitiveFunction.values) {
          final entry = repo.getFunctionContent(content, f.label);
          expect(entry, isNotNull, reason: 'manca il contenuto per ${f.label}');

          final at = 'functions.${f.label}';
          expectText(entry!, 'title', at: at);
          expectText(entry, 'full_name', at: at);
          expectText(entry, 'description', at: at);
          // One per stack position: the card shows what the function looks like
          // when dominant, auxiliary, tertiary and inferior.
          expectText(entry, 'as_dominant', at: at);
          expectText(entry, 'as_auxiliary', at: at);
          expectText(entry, 'as_tertiary', at: at);
          expectText(entry, 'as_inferior', at: at);
        }
      });

      test('mbti.json: le 4 dicotomie portano i campi che la scheda legge',
          () async {
        final content = await repo.loadMbtiContent(locale);

        // The axes `QuizEngine` scores; each pole key is a letter of the axis.
        const axes = ['IE', 'NS', 'TF', 'JP'];
        expect(content.dichotomies, hasLength(axes.length));
        for (final axis in axes) {
          final entry = repo.getDichotomyContent(content, axis);
          expect(entry, isNotNull, reason: 'manca il contenuto per $axis');

          final at = 'dichotomies.$axis';
          expectText(entry!, 'title', at: at);
          expectText(entry, 'spectrum_note', at: at);
          expectTextList(entry, 'common_myths', at: at);

          // `poles` is an object keyed by letter, not a list — reading it as a
          // list is what `_MbtiDichotomyBody` did until 2026-08-03.
          final poles = entry['poles'] as Map<String, dynamic>?;
          expect(poles, isNotNull, reason: '$at senza poles');
          expect(poles!.keys, unorderedEquals(axis.split('')),
              reason: '$at: i poli non sono le due lettere dell\'asse');
          for (final letter in axis.split('')) {
            final pole = poles[letter] as Map<String, dynamic>?;
            expect(pole, isNotNull, reason: '$at manca il polo $letter');
            expectText(pole!, 'label', at: '$at.$letter');
            expectText(pole, 'description', at: '$at.$letter');
            expectTextList(pole, 'behavioral_markers', at: '$at.$letter');
          }
        }
      });

      test('mbti.json: stack e liste per posizione coincidono con kMbtiStacks',
          () async {
        final content = await repo.loadMbtiContent(locale);

        // These fields restate in JSON what `kMbtiStacks` already knows, so the
        // test derives the expected value instead of pinning a copy: the asset
        // is only allowed to say what the engine says. This is how the wrong
        // `Si.tertiary_in` / `Si.inferior_in` surfaced (2026-08-03) — the card
        // claimed ENFJ and ENTJ have inferior Si, and neither has Si at all.
        for (final type in MbtiType.values) {
          final entry = repo.getTypeContent(content, type.label)!;
          expect(
            (entry['stack'] as List).cast<String>(),
            kMbtiStacks[type]!.map((f) => f.label).toList(),
            reason: 'stack di ${type.label} diverso da kMbtiStacks',
          );
        }

        const positions = [
          'dominant_in',
          'auxiliary_in',
          'tertiary_in',
          'inferior_in',
        ];
        for (final f in CognitiveFunction.values) {
          final entry = repo.getFunctionContent(content, f.label)!;
          for (var i = 0; i < positions.length; i++) {
            final expected = MbtiType.values
                .where((t) => kMbtiStacks[t]![i] == f)
                .map((t) => t.label)
                .toList();
            expect(
              (entry[positions[i]] as List).cast<String>(),
              unorderedEquals(expected),
              reason: '${f.label}.${positions[i]} non corrisponde a kMbtiStacks',
            );
          }
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
