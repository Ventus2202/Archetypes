import '../personality_systems/mbti/mbti_profile.dart';
import '../personality_systems/mbti/mbti_types.dart';

/// The key of the entry in `relationship_dynamics.json` that describes this
/// item. The entry holds both `title` and `description`, so one key is enough.
///
/// Until 2026-07-31 the engine emitted `conflict_ne_si_title` / `_desc` while
/// the content was indexed `conflict_ne_si`, and `person_detail` stitched the
/// two contracts back together with six `replaceAll('_title', '')`.
class FrictionPoint {
  final String contentKey;
  final CognitiveFunction functionA;
  final CognitiveFunction functionB;

  const FrictionPoint({
    required this.contentKey,
    required this.functionA,
    required this.functionB,
  });
}

class GrowthArea {
  final String contentKey;
  final CognitiveFunction functionA;
  final CognitiveFunction functionB;
  final double weight;

  const GrowthArea({
    required this.contentKey,
    required this.functionA,
    required this.functionB,
    required this.weight,
  });
}

class CommunicationTip {
  final String contentKey;

  const CommunicationTip({required this.contentKey});
}

enum AxisStatus { aligned, complementary, tension }

class FunctionAxisAnalysis {
  final AxisStatus ieStatus;
  final AxisStatus nsStatus;
  final AxisStatus tfStatus;
  final AxisStatus jpStatus;

  const FunctionAxisAnalysis({
    required this.ieStatus,
    required this.nsStatus,
    required this.tfStatus,
    required this.jpStatus,
  });
}

class RelationshipReport {
  final List<FrictionPoint> frictionPoints;
  final List<GrowthArea> mutualGrowthAreas;
  final List<CommunicationTip> communicationTips;
  final FunctionAxisAnalysis axisAnalysis;

  const RelationshipReport({
    required this.frictionPoints,
    required this.mutualGrowthAreas,
    required this.communicationTips,
    required this.axisAnalysis,
  });
}

class RelationshipDynamics {
  static const Map<String, String> kFunctionConflicts = {
    'Te-Fi': 'conflict_te_fi',
    'Fi-Te': 'conflict_te_fi',
    'Fe-Ti': 'conflict_fe_ti',
    'Ti-Fe': 'conflict_fe_ti',
    'Ne-Si': 'conflict_ne_si',
    'Si-Ne': 'conflict_ne_si',
    'Ni-Se': 'conflict_ni_se',
    'Se-Ni': 'conflict_ni_se',
  };

  static final Map<String, String> kCommunicationPatterns = {
    'IT-IT': 'comm_it_it',
    'IT-IF': 'comm_it_if',
    'IT-ET': 'comm_it_et',
    'IT-EF': 'comm_it_ef',
    'IF-IT': 'comm_it_if',
    'IF-IF': 'comm_if_if',
    'IF-ET': 'comm_if_et',
    'IF-EF': 'comm_if_ef',
    'ET-IT': 'comm_it_et',
    'ET-IF': 'comm_if_et',
    'ET-ET': 'comm_et_et',
    'ET-EF': 'comm_et_ef',
    'EF-IT': 'comm_it_ef',
    'EF-IF': 'comm_if_ef',
    'EF-ET': 'comm_et_ef',
    'EF-EF': 'comm_ef_ef',
  };

  static RelationshipReport analyze(MbtiProfile a, MbtiProfile b) {
    return RelationshipReport(
      frictionPoints: _calculateFriction(a, b),
      mutualGrowthAreas: _calculateGrowth(a, b),
      communicationTips: _calculateCommunication(a, b),
      axisAnalysis: _calculateAxis(a, b),
    );
  }

  static List<FrictionPoint> _calculateFriction(MbtiProfile a, MbtiProfile b) {
    final frictions = <FrictionPoint>[];

    void checkConflict(CognitiveFunction fA, CognitiveFunction fB) {
      final key = '${fA.label}-${fB.label}';
      final contentKey = kFunctionConflicts[key];
      if (contentKey != null) {
        // Prevent duplicates
        if (!frictions.any((f) => f.contentKey == contentKey)) {
          frictions.add(FrictionPoint(
            contentKey: contentKey,
            functionA: fA,
            functionB: fB,
          ));
        }
      }
    }

    // Check Dom vs Dom
    checkConflict(a.dominant, b.dominant);
    
    // Check Dom vs Aux
    checkConflict(a.dominant, b.auxiliary);
    checkConflict(a.auxiliary, b.dominant);
    
    // Check Aux vs Aux
    checkConflict(a.auxiliary, b.auxiliary);

    return frictions;
  }

  static List<GrowthArea> _calculateGrowth(MbtiProfile a, MbtiProfile b) {
    final growths = <GrowthArea>[];
    
    void checkGrowth(CognitiveFunction weak, CognitiveFunction strong, int posWeak, int posStrong, bool isAWeak) {
      if (weak == strong) {
        final key = 'growth_${weak.label.toLowerCase()}';
        if (!growths.any((g) => g.contentKey == key)) {
          growths.add(GrowthArea(
            contentKey: key,
            functionA: isAWeak ? weak : strong,
            functionB: isAWeak ? strong : weak,
            weight: 10.0 - (posWeak + posStrong),
          ));
        }
      }
    }

    // A weak vs B strong
    checkGrowth(a.inferior, b.dominant, 4, 1, true);
    checkGrowth(a.inferior, b.auxiliary, 4, 2, true);
    checkGrowth(a.tertiary, b.dominant, 3, 1, true);
    checkGrowth(a.tertiary, b.auxiliary, 3, 2, true);

    // B weak vs A strong
    checkGrowth(b.inferior, a.dominant, 4, 1, false);
    checkGrowth(b.inferior, a.auxiliary, 4, 2, false);
    checkGrowth(b.tertiary, a.dominant, 3, 1, false);
    checkGrowth(b.tertiary, a.auxiliary, 3, 2, false);

    growths.sort((g1, g2) => g2.weight.compareTo(g1.weight));
    return growths;
  }

  static List<CommunicationTip> _calculateCommunication(MbtiProfile a, MbtiProfile b) {
    final codeA = '${a.type.isIntroverted ? "I" : "E"}${a.type.isThinking ? "T" : "F"}';
    final codeB = '${b.type.isIntroverted ? "I" : "E"}${b.type.isThinking ? "T" : "F"}';
    
    final patternKey = kCommunicationPatterns['$codeA-$codeB'] ?? 'comm_default';

    return [CommunicationTip(contentKey: patternKey)];
  }

  static FunctionAxisAnalysis _calculateAxis(MbtiProfile a, MbtiProfile b) {
    AxisStatus evaluateIE(bool isIntA, bool isIntB) {
       return isIntA == isIntB ? AxisStatus.aligned : AxisStatus.complementary;
    }
    
    AxisStatus evaluateNS(bool isIntA, bool isIntB) {
       return isIntA == isIntB ? AxisStatus.aligned : AxisStatus.tension;
    }
    
    AxisStatus evaluateTF(bool isThA, bool isThB) {
       return isThA == isThB ? AxisStatus.aligned : AxisStatus.tension;
    }
    
    AxisStatus evaluateJP(bool isJa, bool isJb) {
       return isJa == isJb ? AxisStatus.aligned : AxisStatus.complementary;
    }

    return FunctionAxisAnalysis(
      ieStatus: evaluateIE(a.type.isIntroverted, b.type.isIntroverted),
      nsStatus: evaluateNS(a.type.isIntuitive, b.type.isIntuitive),
      tfStatus: evaluateTF(a.type.isThinking, b.type.isThinking),
      jpStatus: evaluateJP(a.type.isJudging, b.type.isJudging),
    );
  }
}
