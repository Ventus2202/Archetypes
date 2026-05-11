import '../personality_systems/mbti/mbti_profile.dart';
import 'career_role.dart';
import 'career_catalog.dart';

class CareerFitResult {
  final CareerRole role;
  final double score;

  const CareerFitResult({required this.role, required this.score});
}

class CareerFit {
  static double calculate(MbtiProfile profile, CareerRole role) {
    double score = 0;
    
    for (final entry in role.functionWeights.entries) {
      final function = entry.key;
      final weight = entry.value;
      
      final stackPosition = profile.stack.indexOf(function);
      if (stackPosition == -1) continue;
      
      final positionMultiplier = [1.0, 0.7, 0.4, 0.2][stackPosition];
      score += weight * positionMultiplier;
    }
    
    for (final pref in role.preferences) {
      bool matches = false;
      if (pref.axis == 'ie') {
        matches = (pref.preferred == 'I' && profile.type.isIntroverted) || (pref.preferred == 'E' && !profile.type.isIntroverted);
      } else if (pref.axis == 'ns') {
        matches = (pref.preferred == 'N' && profile.type.isIntuitive) || (pref.preferred == 'S' && !profile.type.isIntuitive);
      } else if (pref.axis == 'tf') {
        matches = (pref.preferred == 'T' && profile.type.isThinking) || (pref.preferred == 'F' && !profile.type.isThinking);
      } else if (pref.axis == 'jp') {
        matches = (pref.preferred == 'J' && profile.type.isJudging) || (pref.preferred == 'P' && !profile.type.isJudging);
      }
      
      if (matches) {
        score += pref.weight;
      } else {
        score -= pref.weight * 0.5;
      }
    }
    
    return (score / role.maxPossibleScore * 100).clamp(0.0, 100.0);
  }

  static List<CareerFitResult> calculateAll(MbtiProfile profile) {
    final results = kCareerRoles.map((role) {
      return CareerFitResult(
        role: role,
        score: calculate(profile, role),
      );
    }).toList();
    
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}
