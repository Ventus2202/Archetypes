import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/domain/team/team_optimizer.dart';
import 'package:archetypes/domain/team/team_models.dart';
import 'package:archetypes/domain/entities/person.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';

void main() {
  Person createPerson(int id) => Person(id: id, name: 'P$id', role: PersonRole.other, isSelf: false, createdAt: DateTime.now());

  group('TeamOptimizer', () {
    test('4 candidati, objective creative, teamSize 2', () {
      final candidates = [
        (person: createPerson(1), profile: MbtiProfile.fromType(MbtiType.istj)), // Si, Te
        (person: createPerson(2), profile: MbtiProfile.fromType(MbtiType.enfp)), // Ne, Fi
        (person: createPerson(3), profile: MbtiProfile.fromType(MbtiType.intj)), // Ni, Te
        (person: createPerson(4), profile: MbtiProfile.fromType(MbtiType.esfj)), // Fe, Si
      ];

      final results = TeamOptimizer.findBest(
        candidates: candidates,
        objective: TeamObjective.creative,
        teamSize: 2,
      );

      expect(results, isNotEmpty);
      final best = results.first;
      // Creative needs Ne, Ni, Fi, Fe. ENFP (Ne, Fi) + INTJ (Ni, Te) is great.
      expect(best.members.any((p) => p.id == 2), isTrue); // ENFP should be in
      expect(best.strengths, contains('strength_ne'));
    });

    test('6 candidati, objective execution, teamSize 3', () {
      final candidates = [
        (person: createPerson(1), profile: MbtiProfile.fromType(MbtiType.enfp)),
        (person: createPerson(2), profile: MbtiProfile.fromType(MbtiType.estj)), // Te, Si
        (person: createPerson(3), profile: MbtiProfile.fromType(MbtiType.istp)), // Ti, Se
        (person: createPerson(4), profile: MbtiProfile.fromType(MbtiType.infj)), // Ni, Fe
        (person: createPerson(5), profile: MbtiProfile.fromType(MbtiType.esfp)), // Se, Ti
        (person: createPerson(6), profile: MbtiProfile.fromType(MbtiType.istj)), // Si, Te
      ];

      final results = TeamOptimizer.findBest(
        candidates: candidates,
        objective: TeamObjective.execution,
        teamSize: 3,
      );

      final best = results.first;
      // Execution needs Te, Si, Se. ESTJ + ISTJ + ESTP/ESFP/ISTP
      // ESTJ and ISTJ provide Te, Si. ISTP provides Se, Ti.
      expect(best.members.any((p) => p.id == 2 || p.id == 6), isTrue); // Should have ESTJ or ISTJ
      expect(best.strengths, contains('strength_te'));
    });

    test('Caso degenere: tutti ENFP, objective execution -> score basso, blind spot', () {
      final candidates = List.generate(4, (i) => 
        (person: createPerson(i), profile: MbtiProfile.fromType(MbtiType.enfp))
      );

      final results = TeamOptimizer.findBest(
        candidates: candidates,
        objective: TeamObjective.execution,
        teamSize: 3,
      );

      final best = results.first;
      // Execution needs Te, Si, Se. ENFP has Ne, Fi, Te, Si. But Si is inferior, Te is tertiary.
      expect(best.blindSpots, contains('blindspot_si'));
      expect(best.overallScore, lessThan(60.0));
    });
  });
}
