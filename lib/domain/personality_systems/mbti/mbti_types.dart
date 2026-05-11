enum MbtiType {
  intj, intp, infj, infp,
  entj, entp, enfj, enfp,
  istj, istp, isfj, isfp,
  estj, estp, esfj, esfp;

  String get label => name.toUpperCase();

  bool get isIntroverted => name.startsWith('i');
  bool get isIntuitive => name[1] == 'n';
  bool get isThinking => name[2] == 't';
  bool get isJudging => name[3] == 'j';

  static MbtiType? fromLabel(String label) {
    final lower = label.toLowerCase();
    try {
      return MbtiType.values.firstWhere((t) => t.name == lower);
    } catch (_) {
      return null;
    }
  }

  static const List<MbtiType> analysts = [
    MbtiType.intj, MbtiType.intp, MbtiType.entj, MbtiType.entp,
  ];
  static const List<MbtiType> diplomats = [
    MbtiType.infj, MbtiType.infp, MbtiType.enfj, MbtiType.enfp,
  ];
  static const List<MbtiType> sentinels = [
    MbtiType.istj, MbtiType.isfj, MbtiType.estj, MbtiType.esfj,
  ];
  static const List<MbtiType> explorers = [
    MbtiType.istp, MbtiType.isfp, MbtiType.estp, MbtiType.esfp,
  ];
}

enum CognitiveFunction {
  ni, ne, si, se, ti, te, fi, fe;

  String get label => '${name[0].toUpperCase()}${name[1]}';

  bool get isIntroverted => name[1] == 'i';
  bool get isPerceiving => name[0] == 'n' || name[0] == 's';
  bool get isJudging => name[0] == 't' || name[0] == 'f';

  static CognitiveFunction? fromLabel(String label) {
    final lower = label.toLowerCase();
    try {
      return CognitiveFunction.values.firstWhere((f) => f.name == lower);
    } catch (_) {
      return null;
    }
  }
}
