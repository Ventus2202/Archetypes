import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_confidence.dart';

void main() {
  group('confidenceFromAxisBalance', () {
    test('every axis a perfect tie -> minimum confidence', () {
      expect(confidenceFromAxisBalance([0.5, 0.5, 0.5, 0.5]),
          kMinAxisConfidence);
    });

    test('fully decisive axes -> 100, whichever pole they lean to', () {
      expect(confidenceFromAxisBalance([1, 1, 1, 1]), 100);
      expect(confidenceFromAxisBalance([0, 0, 0, 0]), 100);
      expect(confidenceFromAxisBalance([1, 0, 1, 0]), 100);
    });

    test('half-decisive axes land halfway', () {
      expect(confidenceFromAxisBalance([0.75, 0.75, 0.75, 0.75]), 75);
      expect(confidenceFromAxisBalance([0.25, 0.25, 0.25, 0.25]), 75);
    });

    test('a single decisive axis among ties stays low', () {
      // Only one of four axes says anything: mean decisiveness 0.25.
      expect(confidenceFromAxisBalance([1, 0.5, 0.5, 0.5]), 63);
    });

    test('out-of-range values are clamped, empty input is the minimum', () {
      expect(confidenceFromAxisBalance([2, -1]), 100);
      expect(confidenceFromAxisBalance([]), kMinAxisConfidence);
    });

    test('self-declared confidence sits below anything axis-based', () {
      expect(kSelfDeclaredConfidence, lessThan(kMinAxisConfidence));
    });
  });

  group('confidenceFromDichotomySliders', () {
    test('sliders left untouched -> minimum confidence', () {
      expect(confidenceFromDichotomySliders([0, 0, 0, 0]), kMinAxisConfidence);
    });

    test('sliders pushed to either end -> 100', () {
      expect(confidenceFromDichotomySliders([100, -100, 100, -100]), 100);
    });

    test('half-pushed sliders land halfway', () {
      expect(confidenceFromDichotomySliders([50, -50, 50, -50]), 75);
    });
  });
}
