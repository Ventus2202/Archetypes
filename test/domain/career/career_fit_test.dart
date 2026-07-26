import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/domain/career/career_catalog.dart';
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

  group('CareerFit.calculateAll', () {
    test('copre tutto il catalogo, una volta per ruolo', () {
      final results = CareerFit.calculateAll(MbtiProfile.fromType(MbtiType.infp));

      expect(results.length, kCareerRoles.length);
      expect(
        results.map((r) => r.role.id).toSet(),
        kCareerRoles.map((r) => r.id).toSet(),
      );
    });

    test('ordinato per score decrescente e clampato in 0..100, per ogni tipo', () {
      for (final type in MbtiType.values) {
        final results = CareerFit.calculateAll(MbtiProfile.fromType(type));

        for (var i = 1; i < results.length; i++) {
          expect(
            results[i - 1].score,
            greaterThanOrEqualTo(results[i].score),
            reason: '$type: risultati non ordinati',
          );
        }
        for (final r in results) {
          expect(r.score, inInclusiveRange(0.0, 100.0),
              reason: '$type / ${r.role.id}: score fuori range');
        }
      }
    });

    test('coerente con calculate() sul singolo ruolo', () {
      final profile = MbtiProfile.fromType(MbtiType.entp);
      for (final r in CareerFit.calculateAll(profile)) {
        expect(r.score, CareerFit.calculate(profile, r.role));
      }
    });
  });
}
