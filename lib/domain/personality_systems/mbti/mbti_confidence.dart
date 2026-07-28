/// Confidence (0-100) of an MBTI profile, derived from how decisive the four
/// axes are. Shared by every source that produces per-axis evidence: the quiz
/// (normalized breakdown) and the granular sliders.
library;

/// Confidence for a self-declared type: no per-axis evidence at all, so it sits
/// deliberately below [kMinAxisConfidence], i.e. below anything the quiz or the
/// sliders can produce. The user can still raise it by hand in person_edit.
const int kSelfDeclaredConfidence = 45;

/// Lowest value the axis-based formula can return: every axis a perfect tie.
const int kMinAxisConfidence = 50;

/// [axisBalance] holds one value per axis in 0..1, where 0.5 is a perfect 50/50
/// tie and 0 / 1 are fully decisive answers. Values are read as *decisiveness*
/// (distance from the middle), not as a direction, so I-vs-E and E-vs-I are
/// equally confident.
///
/// The result is the mean decisiveness mapped onto 50..100: an all-neutral
/// questionnaire yields 50 (the type is effectively a coin flip and the caller
/// should treat it as such), a fully decisive one yields 100. It reports how
/// clear-cut the axes were, not the probability that all four letters are right.
int confidenceFromAxisBalance(Iterable<double> axisBalance) {
  final decisiveness = axisBalance
      .map((b) => ((b - 0.5).abs() * 2).clamp(0.0, 1.0))
      .toList(growable: false);
  if (decisiveness.isEmpty) return kMinAxisConfidence;
  final mean =
      decisiveness.reduce((a, b) => a + b) / decisiveness.length;
  return (kMinAxisConfidence + mean * 50).round();
}

/// Same formula for the granular sliders, whose raw range is -100..100.
int confidenceFromDichotomySliders(Iterable<double> sliders) =>
    confidenceFromAxisBalance(
      sliders.map((v) => (v.clamp(-100.0, 100.0) + 100) / 200),
    );
