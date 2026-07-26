import 'dart:math';
import '../entities/person.dart';
import '../personality_systems/mbti/mbti_types.dart';
import '../personality_systems/mbti/mbti_profile.dart';
import '../affinity/cognitive_function_affinity.dart';
import 'team_models.dart';

class TeamOptimizer {
  static const Map<TeamObjective, Map<CognitiveFunction, double>> kTeamObjectiveWeights = {
    TeamObjective.creative: {
      CognitiveFunction.ne: 1.0,
      CognitiveFunction.ni: 0.9,
      CognitiveFunction.fi: 0.8,
      CognitiveFunction.fe: 0.6,
      CognitiveFunction.ti: 0.5,
    },
    TeamObjective.execution: {
      CognitiveFunction.te: 1.0,
      CognitiveFunction.si: 0.9,
      CognitiveFunction.se: 0.8,
      CognitiveFunction.ni: 0.6,
      CognitiveFunction.ti: 0.5,
    },
    TeamObjective.crisis: {
      CognitiveFunction.se: 1.0,
      CognitiveFunction.ti: 0.9,
      CognitiveFunction.te: 0.8,
      CognitiveFunction.ni: 0.6,
      CognitiveFunction.fe: 0.5,
    },
    TeamObjective.innovation: {
      CognitiveFunction.ne: 1.0,
      CognitiveFunction.ti: 0.9,
      CognitiveFunction.ni: 0.8,
      CognitiveFunction.te: 0.7,
      CognitiveFunction.fi: 0.5,
    },
    TeamObjective.support: {
      CognitiveFunction.fe: 1.0,
      CognitiveFunction.si: 0.9,
      CognitiveFunction.fi: 0.8,
      CognitiveFunction.ne: 0.6,
      CognitiveFunction.ni: 0.5,
    },
    TeamObjective.strategy: {
      CognitiveFunction.ni: 1.0,
      CognitiveFunction.te: 0.9,
      CognitiveFunction.ti: 0.8,
      CognitiveFunction.ne: 0.7,
      CognitiveFunction.si: 0.5,
    },
  };

  /// [mustIncludePersonId] pins a person into every returned team ("a team with
  /// me"). It is a hard constraint: if that person is not among [candidates] the
  /// result is empty rather than a team without them.
  static List<TeamComposition> findBest({
    required List<({Person person, MbtiProfile profile})> candidates,
    required TeamObjective objective,
    required int teamSize,
    int? mustIncludePersonId,
  }) {
    if (candidates.length < teamSize) return [];

    ({Person person, MbtiProfile profile})? pinned;
    if (mustIncludePersonId != null) {
      pinned = candidates
          .where((c) => c.person.id == mustIncludePersonId)
          .firstOrNull;
      if (pinned == null) return [];
    }

    List<List<({Person person, MbtiProfile profile})>> combos = [];
    if (candidates.length > 12) {
      // Greedy approach
      combos.add(_greedySelection(candidates, objective, teamSize, pinned));
      // Add a couple of variations? Just greedy is fine per prompt
    } else {
      combos = _generateCombinations(candidates, teamSize);
      if (pinned != null) {
        combos = combos
            .where((c) => c.any((m) => m.person.id == mustIncludePersonId))
            .toList();
      }
    }

    final compositions = combos.map((c) => _evaluateTeam(c, objective)).toList();
    compositions.sort((a, b) => b.overallScore.compareTo(a.overallScore));

    return compositions.take(3).toList();
  }

  static List<({Person person, MbtiProfile profile})> _greedySelection(
      List<({Person person, MbtiProfile profile})> candidates,
      TeamObjective objective,
      int teamSize,
      ({Person person, MbtiProfile profile})? pinned) {

    final selected = <({Person person, MbtiProfile profile})>[];
    final remaining = List<({Person person, MbtiProfile profile})>.from(candidates);

    // Seed: the pinned member if any, otherwise the highest individual
    // function coverage score.
    ({Person person, MbtiProfile profile})? bestFirst = pinned;
    if (bestFirst == null) {
      double bestFirstScore = -1;
      for (final c in remaining) {
        final score = _calculateFunctionCoverage([c], objective).score;
        if (score > bestFirstScore) {
          bestFirstScore = score;
          bestFirst = c;
        }
      }
    }

    if (bestFirst != null) {
      selected.add(bestFirst);
      remaining.removeWhere((c) => c.person.id == bestFirst!.person.id);
    }

    // Iteratively add members maximizing overall score
    while (selected.length < teamSize && remaining.isNotEmpty) {
      ({Person person, MbtiProfile profile})? bestNext;
      double bestScore = -1;
      
      for (final c in remaining) {
        final testTeam = [...selected, c];
        final score = _evaluateTeam(testTeam, objective).overallScore;
        if (score > bestScore) {
          bestScore = score;
          bestNext = c;
        }
      }
      
      if (bestNext != null) {
        selected.add(bestNext);
        remaining.remove(bestNext);
      } else {
        break;
      }
    }

    return selected;
  }

  static List<List<T>> _generateCombinations<T>(List<T> list, int length) {
    if (length == 1) return list.map((e) => [e]).toList();
    if (length == list.length) return [list];
    if (length > list.length) return [];

    final result = <List<T>>[];
    for (int i = 0; i <= list.length - length; i++) {
      final head = list[i];
      final tailCombinations = _generateCombinations(list.sublist(i + 1), length - 1);
      for (final tail in tailCombinations) {
        result.add([head, ...tail]);
      }
    }
    return result;
  }

  static TeamComposition _evaluateTeam(
      List<({Person person, MbtiProfile profile})> members,
      TeamObjective objective) {
    
    final coverageResult = _calculateFunctionCoverage(members, objective);
    final pairwiseScore = _calculatePairwiseAffinity(members);
    final diversityScore = _calculateDiversity(members);

    final overall = (0.5 * coverageResult.score) + (0.3 * pairwiseScore) + (0.2 * diversityScore);

    return TeamComposition(
      members: members.map((m) => m.person).toList(),
      profiles: members.map((m) => m.profile).toList(),
      overallScore: overall,
      coverage: FunctionCoverage(coverageResult.coverageMap),
      pairwiseAffinity: pairwiseScore,
      diversityIndex: diversityScore,
      strengths: coverageResult.strengths,
      blindSpots: coverageResult.blindSpots,
    );
  }

  static ({double score, Map<CognitiveFunction, double> coverageMap, List<String> strengths, List<String> blindSpots})
      _calculateFunctionCoverage(List<({Person person, MbtiProfile profile})> members, TeamObjective objective) {
    
    final weights = kTeamObjectiveWeights[objective]!;
    final coverageMap = <CognitiveFunction, double>{};
    
    for (final f in CognitiveFunction.values) {
      coverageMap[f] = 0.0;
    }

    final posMultipliers = [1.0, 0.7, 0.4, 0.2];

    for (final m in members) {
      for (int i = 0; i < m.profile.stack.length && i < 4; i++) {
        final f = m.profile.stack[i];
        final val = posMultipliers[i];
        if (val > coverageMap[f]!) {
          coverageMap[f] = val; // Take max, not sum! "Una funzione presente come dominante in qualcuno conta più che presente come inferiore in tutti."
        }
      }
    }

    double score = 0;
    double maxPossibleScore = 0;

    for (final entry in weights.entries) {
      maxPossibleScore += entry.value;
      score += (coverageMap[entry.key] ?? 0.0) * entry.value;
    }

    double normalizedScore = maxPossibleScore > 0 ? (score / maxPossibleScore) * 100 : 0;

    final strengths = <String>[];
    final blindSpots = <String>[];

    // Analyze top strengths & blind spots relative to objective
    for (final entry in weights.entries) {
      if (entry.value >= 0.8) {
        final cov = coverageMap[entry.key] ?? 0.0;
        if (cov >= 0.7) {
          strengths.add('strength_${entry.key.label.toLowerCase()}');
        } else if (cov < 0.4) {
          blindSpots.add('blindspot_${entry.key.label.toLowerCase()}');
        }
      }
    }

    return (
      score: normalizedScore,
      coverageMap: coverageMap,
      strengths: strengths,
      blindSpots: blindSpots
    );
  }

  static double _calculatePairwiseAffinity(List<({Person person, MbtiProfile profile})> members) {
    if (members.length < 2) return 100.0;

    double total = 0;
    int count = 0;

    for (int i = 0; i < members.length; i++) {
      for (int j = i + 1; j < members.length; j++) {
        final affinity = CognitiveFunctionAffinity.calculate(members[i].profile, members[j].profile);
        total += affinity.score;
        count++;
      }
    }

    return count > 0 ? total / count : 0.0;
  }

  static double _calculateDiversity(List<({Person person, MbtiProfile profile})> members) {
    if (members.isEmpty) return 100.0;

    int introverts = 0;
    int extraverts = 0;
    int judgers = 0;
    int perceivers = 0;

    for (final m in members) {
      if (m.profile.type.isIntroverted) {
        introverts++;
      } else {
        extraverts++;
      }
      if (m.profile.type.isJudging) {
        judgers++;
      } else {
        perceivers++;
      }
    }

    double ieRatio = min(introverts, extraverts) / max(1, max(introverts, extraverts));
    double jpRatio = min(judgers, perceivers) / max(1, max(judgers, perceivers));

    // Perfect ratio = 1.0 (e.g. 2 and 2). Score is based on how close we are to 1.0
    // Actually, diversity score penalty if unbalanced.
    // Let's say max penalty is 50 points per axis.
    double iePenalty = (1.0 - ieRatio) * 50;
    double jpPenalty = (1.0 - jpRatio) * 50;

    return max(0.0, 100.0 - iePenalty - jpPenalty);
  }
}
