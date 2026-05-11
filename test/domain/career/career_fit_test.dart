import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/domain/career/career_fit.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';

void main() {
  group('CareerFit', () {
    test('INTJ -> researcher alto, sales basso', () {
      final profile = MbtiProfile.fromType(MbtiType.intj);
      final results = CareerFit.calculateAll(profile);

      final researcher = results.firstWhere((r) => r.role.id == 'researcher');
      final sales = results.firstWhere((r) => r.role.id == 'sales');

      expect(researcher.score, greaterThan(70.0));
      expect(sales.score, lessThan(40.0));
      expect(researcher.score, greaterThan(sales.score));
    });

    test('ENFP -> creative_director alto, accountant basso', () {
      final profile = MbtiProfile.fromType(MbtiType.enfp);
      final results = CareerFit.calculateAll(profile);

      final creative = results.firstWhere((r) => r.role.id == 'creative_director');
      final accountant = results.firstWhere((r) => r.role.id == 'accountant');

      expect(creative.score, greaterThan(70.0));
      expect(accountant.score, lessThan(40.0));
    });

    test('ESTJ -> operations_manager alto, therapist medio-basso', () {
      final profile = MbtiProfile.fromType(MbtiType.estj);
      final results = CareerFit.calculateAll(profile);

      final ops = results.firstWhere((r) => r.role.id == 'operations_manager');
      final therapist = results.firstWhere((r) => r.role.id == 'therapist');

      expect(ops.score, greaterThan(70.0));
      expect(ops.score, greaterThan(therapist.score));
    });
  });
}
