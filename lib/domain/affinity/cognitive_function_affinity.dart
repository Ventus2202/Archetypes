import '../personality_systems/mbti/mbti_functions.dart';
import '../personality_systems/mbti/mbti_profile.dart';
import '../personality_systems/mbti/mbti_types.dart';

class AffinityFactor {
  final String labelKey;
  final double contribution;
  final CognitiveFunction functionA;
  final CognitiveFunction functionB;

  const AffinityFactor({
    required this.labelKey,
    required this.contribution,
    required this.functionA,
    required this.functionB,
  });
}

class AffinityResult {
  final double score;
  final List<AffinityFactor> factors;

  const AffinityResult({required this.score, required this.factors});

  String get level {
    if (score >= 75) return 'affinityHigh';
    if (score >= 50) return 'affinityMedium';
    return 'affinityLow';
  }
}

class CognitiveFunctionAffinity {
  static const _posWeights = [4.0, 3.0, 2.0, 1.0];

  // Calibrated maxRaw to target desired score ranges:
  // INTJ-ENFP > 70, INTJ-INTJ ~ 50, INFJ-ESTP < 40
  static const _maxRaw = 10.0;

  static AffinityResult calculate(MbtiProfile a, MbtiProfile b) {
    final factors = <AffinityFactor>[];
    var rawScore = 0.0;

    for (var ia = 0; ia < 4; ia++) {
      for (var ib = 0; ib < 4; ib++) {
        final fa = a.stack[ia];
        final fb = b.stack[ib];
        final wa = _posWeights[ia];
        final wb = _posWeights[ib];
        final posSimilarity = 4.0 - (ia - ib).abs();
        
        // Exact match (e.g. Ni vs Ni) - "Neutral" compatibility boost
        if (fa == fb) {
          final contribution = wa * wb * 0.9 * posSimilarity / 20.0;
          rawScore += contribution;
          factors.add(AffinityFactor(
            labelKey: 'affinitySimilarFunction',
            contribution: contribution,
            functionA: fa,
            functionB: fb,
          ));
        } 
        // Base match (Shadow) (e.g. Ni vs Ne) - "Ideal" compatibility boost
        else if (fa.name[0] == fb.name[0]) {
          final contribution = wa * wb * 1.9 * posSimilarity / 20.0;
          rawScore += contribution;
          factors.add(AffinityFactor(
            labelKey: 'affinitySimilarFunction',
            contribution: contribution,
            functionA: fa,
            functionB: fb,
          ));
        }
        // Jungian complement on the same axis (e.g. Te vs Fi) - "Growth" boost
        else if (kComplementaryFunctions[fa] == fb) {
          final contribution = wa * wb * 0.4 * posSimilarity / 20.0;
          rawScore += contribution;

          String labelKey;
          if (ia == 0 && ib == 0) {
            labelKey = 'affinityDominantComplement';
          } else if (ia <= 1 && ib <= 1) {
            labelKey = 'affinityCoreComplement';
          } else {
            labelKey = 'affinityComplement';
          }

          factors.add(AffinityFactor(
            labelKey: labelKey,
            contribution: contribution,
            functionA: fa,
            functionB: fb,
          ));
        }
      }
    }

    factors.sort((x, y) => y.contribution.compareTo(x.contribution));

    final score = (rawScore / _maxRaw * 100).clamp(0.0, 100.0);
    return AffinityResult(score: score, factors: factors);
  }

  static AffinityResult? calculateFromTypes(MbtiType a, MbtiType b) {
    final profileA = MbtiProfile.fromType(a);
    final profileB = MbtiProfile.fromType(b);
    return calculate(profileA, profileB);
  }
}
