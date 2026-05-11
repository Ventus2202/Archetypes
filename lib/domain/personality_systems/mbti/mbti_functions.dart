import 'mbti_types.dart';

const Map<MbtiType, List<CognitiveFunction>> kMbtiStacks = {
  MbtiType.intj: [CognitiveFunction.ni, CognitiveFunction.te, CognitiveFunction.fi, CognitiveFunction.se],
  MbtiType.intp: [CognitiveFunction.ti, CognitiveFunction.ne, CognitiveFunction.si, CognitiveFunction.fe],
  MbtiType.infj: [CognitiveFunction.ni, CognitiveFunction.fe, CognitiveFunction.ti, CognitiveFunction.se],
  MbtiType.infp: [CognitiveFunction.fi, CognitiveFunction.ne, CognitiveFunction.si, CognitiveFunction.te],
  MbtiType.entj: [CognitiveFunction.te, CognitiveFunction.ni, CognitiveFunction.se, CognitiveFunction.fi],
  MbtiType.entp: [CognitiveFunction.ne, CognitiveFunction.ti, CognitiveFunction.fe, CognitiveFunction.si],
  MbtiType.enfj: [CognitiveFunction.fe, CognitiveFunction.ni, CognitiveFunction.se, CognitiveFunction.ti],
  MbtiType.enfp: [CognitiveFunction.ne, CognitiveFunction.fi, CognitiveFunction.te, CognitiveFunction.si],
  MbtiType.istj: [CognitiveFunction.si, CognitiveFunction.te, CognitiveFunction.fi, CognitiveFunction.ne],
  MbtiType.istp: [CognitiveFunction.ti, CognitiveFunction.se, CognitiveFunction.ni, CognitiveFunction.fe],
  MbtiType.isfj: [CognitiveFunction.si, CognitiveFunction.fe, CognitiveFunction.ti, CognitiveFunction.ne],
  MbtiType.isfp: [CognitiveFunction.fi, CognitiveFunction.se, CognitiveFunction.ni, CognitiveFunction.te],
  MbtiType.estj: [CognitiveFunction.te, CognitiveFunction.si, CognitiveFunction.ne, CognitiveFunction.fi],
  MbtiType.estp: [CognitiveFunction.se, CognitiveFunction.ti, CognitiveFunction.fe, CognitiveFunction.ni],
  MbtiType.esfj: [CognitiveFunction.fe, CognitiveFunction.si, CognitiveFunction.ne, CognitiveFunction.ti],
  MbtiType.esfp: [CognitiveFunction.se, CognitiveFunction.fi, CognitiveFunction.te, CognitiveFunction.ni],
};

const Map<CognitiveFunction, CognitiveFunction> kComplementaryFunctions = {
  CognitiveFunction.ni: CognitiveFunction.se,
  CognitiveFunction.se: CognitiveFunction.ni,
  CognitiveFunction.ne: CognitiveFunction.si,
  CognitiveFunction.si: CognitiveFunction.ne,
  CognitiveFunction.ti: CognitiveFunction.fe,
  CognitiveFunction.fe: CognitiveFunction.ti,
  CognitiveFunction.te: CognitiveFunction.fi,
  CognitiveFunction.fi: CognitiveFunction.te,
};

List<CognitiveFunction> stackFromType(MbtiType type) =>
    kMbtiStacks[type] ?? [];

CognitiveFunction? complementOf(CognitiveFunction f) =>
    kComplementaryFunctions[f];
