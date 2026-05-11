import '../entities/person.dart';
import '../personality_systems/mbti/mbti_types.dart';
import '../personality_systems/mbti/mbti_profile.dart';

enum TeamObjective {
  creative,
  execution,
  crisis,
  innovation,
  support,
  strategy,
}

class FunctionCoverage {
  final Map<CognitiveFunction, double> coverage;
  const FunctionCoverage(this.coverage);
}

class TeamComposition {
  final List<Person> members;
  final List<MbtiProfile> profiles;
  final double overallScore;
  final FunctionCoverage coverage;
  final double pairwiseAffinity;
  final double diversityIndex;
  final List<String> strengths;
  final List<String> blindSpots;

  const TeamComposition({
    required this.members,
    required this.profiles,
    required this.overallScore,
    required this.coverage,
    required this.pairwiseAffinity,
    required this.diversityIndex,
    required this.strengths,
    required this.blindSpots,
  });
}
