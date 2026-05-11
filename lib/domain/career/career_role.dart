import '../personality_systems/mbti/mbti_types.dart';

class DichotomyPreference {
  final String axis; // "ie", "ns", "tf", "jp"
  final String preferred; // "I", "E", "N", "S", "T", "F", "J", "P"
  final double weight;

  const DichotomyPreference({
    required this.axis,
    required this.preferred,
    required this.weight,
  });
}

class CareerRole {
  final String id;
  final String titleKey;
  final Map<CognitiveFunction, double> functionWeights;
  final List<DichotomyPreference> preferences;

  const CareerRole({
    required this.id,
    required this.titleKey,
    required this.functionWeights,
    this.preferences = const [],
  });

  double get maxPossibleScore {
    double score = 0;
    final sortedWeights = functionWeights.values.toList()..sort((a, b) => b.compareTo(a));
    final multipliers = [1.0, 0.7, 0.4, 0.2];
    for (int i = 0; i < sortedWeights.length && i < 4; i++) {
      score += sortedWeights[i] * multipliers[i];
    }
    for (final pref in preferences) {
      score += pref.weight;
    }
    return score;
  }
}
