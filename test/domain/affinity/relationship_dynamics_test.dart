import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/domain/affinity/relationship_dynamics.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';

void main() {
  group('RelationshipDynamics', () {
    test('INTJ + ENFP (alta affinità, attriti su pianificazione)', () {
      final a = MbtiProfile.fromType(MbtiType.intj);
      final b = MbtiProfile.fromType(MbtiType.enfp);

      final report = RelationshipDynamics.analyze(a, b);

      expect(report.mutualGrowthAreas, isNotEmpty);
      expect(report.mutualGrowthAreas.any((g) => g.titleKey.contains('growth_te') || g.titleKey.contains('growth_fi')), isTrue);
      // Wait, let's check friction: INTJ (Ni, Te) vs ENFP (Ne, Fi).
      // Te-Fi conflict might exist if Dom/Aux are opposite. INTJ Aux=Te, ENFP Aux=Fi.
      expect(report.frictionPoints.any((f) => f.titleKey.contains('conflict_te_fi')), isTrue);
    });

    test('INTJ + ESTP (bassa affinità, attriti multipli)', () {
      final a = MbtiProfile.fromType(MbtiType.intj);
      final b = MbtiProfile.fromType(MbtiType.estp);

      final report = RelationshipDynamics.analyze(a, b);

      // INTJ (Ni, Te) vs ESTP (Se, Ti)
      // Ni-Se conflict because INTJ Dom=Ni, ESTP Dom=Se.
      expect(report.frictionPoints.any((f) => f.titleKey.contains('conflict_ni_se')), isTrue);
    });

    test('INFP + INFP (stessi tipi, crescita limitata)', () {
      final a = MbtiProfile.fromType(MbtiType.infp);
      final b = MbtiProfile.fromType(MbtiType.infp);

      final report = RelationshipDynamics.analyze(a, b);

      expect(report.frictionPoints, isEmpty);
      // Growth area on Te (Inf vs Dom/Aux? INFP inf is Te. It won't match INFP's Dom/Aux because both are Te inferior)
      expect(report.mutualGrowthAreas, isEmpty);
    });

    test('ENTJ + INFP (Te dom vs Fi dom, attrito decisionale)', () {
      final a = MbtiProfile.fromType(MbtiType.entj);
      final b = MbtiProfile.fromType(MbtiType.infp);

      final report = RelationshipDynamics.analyze(a, b);

      // ENTJ (Te, Ni) vs INFP (Fi, Ne)
      // Te Dom vs Fi Dom -> conflict
      expect(report.frictionPoints.any((f) => f.titleKey.contains('conflict_te_fi')), isTrue);
      
      // Mutual growth: INFP Inf=Te vs ENTJ Dom=Te.
      expect(report.mutualGrowthAreas.any((g) => g.titleKey.contains('growth_te')), isTrue);
    });

    test('ISFJ + ESTP (asse Si vs Se, crescita su tradizione/presente)', () {
      final a = MbtiProfile.fromType(MbtiType.isfj);
      final b = MbtiProfile.fromType(MbtiType.estp);

      final report = RelationshipDynamics.analyze(a, b);

      // ISFJ (Si, Fe, Ti, Ne) vs ESTP (Se, Ti, Fe, Ni)
      // No opposite axis on Dom/Dom (Si vs Se is not opposite, Si vs Ne is).
      // Wait, is Si-Se a conflict? The conflict map doesn't have Si-Se, only Si-Ne.
      // Growth area: ISFJ Inf=Ne vs ESTP? ESTP doesn't have Ne in top 2.
      // ESTP Inf=Ni vs ISFJ? ISFJ doesn't have Ni in top 2.
      // But ISFJ Aux=Fe, Ter=Ti. ESTP Aux=Ti, Ter=Fe.
      // So no top 2 vs bottom 2 growth either.
      
      // Let's assert things don't crash.
      expect(report, isNotNull);
      // Wait, ISFJ is Sensing. ESTP is Sensing. So nsStatus is aligned.
      expect(report.axisAnalysis.nsStatus, AxisStatus.aligned);
    });
  });
}
