import 'dart:convert';
import 'mbti_types.dart';
import 'mbti_functions.dart';

class MbtiProfile {
  final MbtiType type;
  final Map<String, int> dichotomies;
  final Map<String, int> functions;
  final List<CognitiveFunction> stack;

  const MbtiProfile({
    required this.type,
    required this.dichotomies,
    required this.functions,
    required this.stack,
  });

  factory MbtiProfile.fromType(MbtiType type) {
    final stack = kMbtiStacks[type]!;
    const posWeights = [90, 70, 45, 25];
    final functions = <String, int>{
      for (int i = 0; i < stack.length; i++) stack[i].label: posWeights[i],
    };
    final dichotomies = {
      'ie': type.isIntroverted ? -70 : 70,
      'ns': type.isIntuitive ? 70 : -70,
      'tf': type.isThinking ? 70 : -70,
      'jp': type.isJudging ? 70 : -70,
    };
    return MbtiProfile(
      type: type,
      dichotomies: dichotomies,
      functions: functions,
      stack: stack,
    );
  }

  factory MbtiProfile.fromJson(Map<String, dynamic> json) {
    final type = MbtiType.fromLabel(json['type'] as String) ?? MbtiType.intj;
    final stack = kMbtiStacks[type]!;
    return MbtiProfile(
      type: type,
      dichotomies: Map<String, int>.from(
          (json['dichotomies'] as Map?)?.map(
                (k, v) => MapEntry(k as String, (v as num).toInt()),
              ) ??
              {}),
      functions: Map<String, int>.from(
          (json['functions'] as Map?)?.map(
                (k, v) => MapEntry(k as String, (v as num).toInt()),
              ) ??
              {}),
      stack: stack,
    );
  }

  factory MbtiProfile.fromDataJson(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return MbtiProfile.fromJson(map);
  }

  Map<String, dynamic> toJson() => {
        'type': type.label,
        'dichotomies': dichotomies,
        'functions': functions,
        'stack': stack.map((f) => f.label).toList(),
      };

  String toJsonString() => json.encode(toJson());

  CognitiveFunction get dominant => stack[0];
  CognitiveFunction get auxiliary => stack[1];
  CognitiveFunction get tertiary => stack[2];
  CognitiveFunction get inferior => stack[3];
}
