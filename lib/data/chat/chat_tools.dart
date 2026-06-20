import 'dart:convert';

import '../../domain/entities/person.dart';
import '../../domain/entities/personality_profile.dart';
import '../../domain/personality_systems/mbti/mbti_profile.dart';
import '../../domain/affinity/cognitive_function_affinity.dart';
import '../../domain/career/career_catalog.dart';
import '../../domain/career/career_fit.dart';
import '../../domain/team/team_models.dart';
import '../../domain/team/team_optimizer.dart';
import '../repositories/person_repository.dart';
import '../repositories/profile_repository.dart';

/// Tool definitions exposed to the model in OpenAI function-calling format
/// (Workers AI's OpenAI-compatible endpoint). The tools are deliberately
/// "thick": each does the full deterministic computation against the domain
/// engines and returns a ranked / summarized result, so the model only
/// orchestrates and narrates — it never reasons about MBTI math itself. This is
/// what lets a small free model do the job.
const List<Map<String, dynamic>> kChatTools = [
  {
    'type': 'function',
    'function': {
      'name': 'list_people',
      'description':
          'Elenca le persone nella mappa con il loro tipo MBTI. La persona con '
              '"is_self": true è l\'utente ("io"/"me"). Usalo per scoprire gli id.',
      'parameters': {'type': 'object', 'properties': {}},
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'list_roles',
      'description': 'Elenca i ruoli professionali disponibili con il loro id.',
      'parameters': {'type': 'object', 'properties': {}},
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'compute_affinity',
      'description': 'Calcola l\'affinità cognitiva (0-100) tra due persone.',
      'parameters': {
        'type': 'object',
        'properties': {
          'person_a_id': {'type': 'integer'},
          'person_b_id': {'type': 'integer'},
        },
        'required': ['person_a_id', 'person_b_id'],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'best_pairs',
      'description':
          'Classifica le migliori coppie per affinità tra tutte le persone con '
              'un profilo MBTI.',
      'parameters': {
        'type': 'object',
        'properties': {
          'top_n': {'type': 'integer', 'description': 'Default 5'},
        },
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'optimize_team',
      'description':
          'Compone il miglior team per un obiettivo. Usa must_include_id per '
              'forzare la presenza di una persona (es. "un team con me").',
      'parameters': {
        'type': 'object',
        'properties': {
          'objective': {
            'type': 'string',
            'enum': [
              'creative',
              'execution',
              'crisis',
              'innovation',
              'support',
              'strategy',
            ],
          },
          'team_size': {'type': 'integer', 'description': 'Default 3'},
          'must_include_id': {'type': 'integer'},
        },
        'required': ['objective'],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'rank_people_for_role',
      'description':
          'Classifica chi tra le persone si adatta meglio a un ruolo '
              'professionale ("chi se ne occuperebbe meglio?"). Usa list_roles '
              'per gli id.',
      'parameters': {
        'type': 'object',
        'properties': {
          'role_id': {'type': 'string'},
          'top_n': {'type': 'integer', 'description': 'Default 5'},
        },
        'required': ['role_id'],
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'career_fit',
      'description': 'I ruoli professionali più adatti a una singola persona.',
      'parameters': {
        'type': 'object',
        'properties': {
          'person_id': {'type': 'integer'},
          'top_n': {'type': 'integer', 'description': 'Default 5'},
        },
        'required': ['person_id'],
      },
    },
  },
];

/// Executes a tool call against the local repositories and domain engines, and
/// returns a JSON string for the tool result.
class ChatToolExecutor {
  ChatToolExecutor({required this.personRepo, required this.profileRepo});

  final PersonRepository personRepo;
  final ProfileRepository profileRepo;

  Future<String> execute(String name, Map<String, dynamic> input) async {
    try {
      switch (name) {
        case 'list_people':
          return await _listPeople();
        case 'list_roles':
          return _listRoles();
        case 'compute_affinity':
          return await _computeAffinity(input);
        case 'best_pairs':
          return await _bestPairs(input);
        case 'optimize_team':
          return await _optimizeTeam(input);
        case 'rank_people_for_role':
          return await _rankForRole(input);
        case 'career_fit':
          return await _careerFit(input);
        default:
          return jsonEncode({'error': 'unknown tool: $name'});
      }
    } catch (e) {
      return jsonEncode({'error': e.toString()});
    }
  }

  // --- tools ---

  Future<String> _listPeople() async {
    final persons = await personRepo.getAll();
    final people = <Map<String, dynamic>>[];
    for (final p in persons) {
      final profiles = await profileRepo.getForPerson(p.id);
      final mbti =
          profiles.where((x) => x.system == PersonalitySystem.mbti).firstOrNull;
      people.add({
        'id': p.id,
        'name': p.displayName,
        'is_self': p.isSelf,
        'mbti': mbti?.data['type'],
      });
    }
    return jsonEncode({'people': people});
  }

  String _listRoles() => jsonEncode({
        'roles': kCareerRoles.map((r) => {'id': r.id, 'key': r.titleKey}).toList(),
      });

  Future<String> _computeAffinity(Map<String, dynamic> input) async {
    final all = await _peopleWithProfiles();
    final a = _byId(all, _int(input['person_a_id']));
    final b = _byId(all, _int(input['person_b_id']));
    if (a == null || b == null) {
      return jsonEncode({'error': 'persona senza profilo MBTI o id errato'});
    }
    final res = CognitiveFunctionAffinity.calculate(a.profile, b.profile);
    return jsonEncode({
      'person_a': a.person.displayName,
      'person_b': b.person.displayName,
      'score': res.score.round(),
      'level': res.level,
      'top_factors': res.factors
          .take(3)
          .map((f) => '${f.functionA.label}/${f.functionB.label}')
          .toList(),
    });
  }

  Future<String> _bestPairs(Map<String, dynamic> input) async {
    final topN = _int(input['top_n']) ?? 5;
    final all = await _peopleWithProfiles();
    final pairs = <Map<String, dynamic>>[];
    for (var i = 0; i < all.length; i++) {
      for (var j = i + 1; j < all.length; j++) {
        final res =
            CognitiveFunctionAffinity.calculate(all[i].profile, all[j].profile);
        pairs.add({
          'a': all[i].person.displayName,
          'b': all[j].person.displayName,
          'score': res.score.round(),
        });
      }
    }
    pairs.sort((x, y) => (y['score'] as int).compareTo(x['score'] as int));
    return jsonEncode({'pairs': pairs.take(topN).toList()});
  }

  Future<String> _optimizeTeam(Map<String, dynamic> input) async {
    final objective = TeamObjective.values.firstWhere(
      (o) => o.name == input['objective'],
      orElse: () => TeamObjective.execution,
    );
    final size = _int(input['team_size']) ?? 3;
    final all = await _peopleWithProfiles();
    final comps = TeamOptimizer.findBest(
      candidates: all,
      objective: objective,
      teamSize: size,
    );
    if (comps.isEmpty) {
      return jsonEncode({'error': 'persone con profilo insufficienti'});
    }
    final mustId = _int(input['must_include_id']);
    final chosen = mustId == null
        ? comps.first
        : comps.firstWhere(
            (c) => c.members.any((m) => m.id == mustId),
            orElse: () => comps.first,
          );
    return jsonEncode({
      'team': chosen.members.map((m) => m.displayName).toList(),
      'score': chosen.overallScore.round(),
      'strengths': chosen.strengths,
      'blind_spots': chosen.blindSpots,
    });
  }

  Future<String> _rankForRole(Map<String, dynamic> input) async {
    final role = kCareerRoles.where((r) => r.id == input['role_id']).firstOrNull;
    if (role == null) {
      return jsonEncode({
        'error': 'ruolo sconosciuto',
        'available': kCareerRoles.map((r) => r.id).toList(),
      });
    }
    final topN = _int(input['top_n']) ?? 5;
    final all = await _peopleWithProfiles();
    final ranked = all
        .map((e) => {
              'name': e.person.displayName,
              'score': CareerFit.calculate(e.profile, role).round(),
            })
        .toList()
      ..sort((x, y) => (y['score'] as int).compareTo(x['score'] as int));
    return jsonEncode({'role': role.id, 'ranking': ranked.take(topN).toList()});
  }

  Future<String> _careerFit(Map<String, dynamic> input) async {
    final all = await _peopleWithProfiles();
    final entry = _byId(all, _int(input['person_id']));
    if (entry == null) {
      return jsonEncode({'error': 'persona senza profilo MBTI o id errato'});
    }
    final topN = _int(input['top_n']) ?? 5;
    final results = CareerFit.calculateAll(entry.profile)
        .take(topN)
        .map((r) => {'role_id': r.role.id, 'score': r.score.round()})
        .toList();
    return jsonEncode({'person': entry.person.displayName, 'roles': results});
  }

  // --- helpers ---

  Future<List<({Person person, MbtiProfile profile})>>
      _peopleWithProfiles() async {
    final persons = await personRepo.getAll();
    final out = <({Person person, MbtiProfile profile})>[];
    for (final p in persons) {
      final profiles = await profileRepo.getForPerson(p.id);
      final mbti =
          profiles.where((x) => x.system == PersonalitySystem.mbti).firstOrNull;
      if (mbti == null) continue;
      try {
        out.add((
          person: p,
          profile: MbtiProfile.fromJson(Map<String, dynamic>.from(mbti.data)),
        ));
      } catch (_) {}
    }
    return out;
  }

  ({Person person, MbtiProfile profile})? _byId(
    List<({Person person, MbtiProfile profile})> all,
    int? id,
  ) =>
      id == null ? null : all.where((e) => e.person.id == id).firstOrNull;

  int? _int(Object? v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
