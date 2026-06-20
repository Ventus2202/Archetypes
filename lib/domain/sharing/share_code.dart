import 'dart:math';
import 'dart:typed_data';

import '../entities/personality_profile.dart';
import '../personality_systems/mbti/mbti_types.dart';

/// A self-contained 24-character share code for a personality profile.
///
/// Used to share your own profile with friends: the code encodes the profile
/// summary (system, MBTI type, confidence, source) plus a stable random id, as
/// Crockford Base32. On import it reconstructs the personality offline — the
/// name is entered by whoever imports it (a fixed-length code cannot carry an
/// arbitrary name). The id makes each profile's code stable and lets imports
/// deduplicate.
///
/// Layout (15 bytes = 120 bits = 24 Crockford Base32 chars):
///   [0] version  [1] system  [2] mbti type  [3] confidence  [4] source
///   [5..13] 9-byte random id  [14] checksum (sum of bytes 0..13, mod 256)
class ShareCode {
  static const int version = 1;
  static const int _payloadBytes = 15;
  static const int _codeLength = 24;
  static const int _idBytes = 9;

  /// Crockford Base32 alphabet (excludes I, L, O, U to avoid ambiguity).
  static const String _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  final PersonalitySystem system;
  final MbtiType type;
  final int confidence;
  final ProfileSource source;
  final List<int> id;

  ShareCode({
    required this.system,
    required this.type,
    required this.confidence,
    required this.source,
    required this.id,
  });

  /// Builds a code with a freshly generated random id. Generate once per
  /// profile and persist the resulting code so it stays stable.
  factory ShareCode.generate({
    required PersonalitySystem system,
    required MbtiType type,
    required int confidence,
    required ProfileSource source,
    Random? random,
  }) {
    final rng = random ?? Random.secure();
    final id = List<int>.generate(_idBytes, (_) => rng.nextInt(256));
    return ShareCode(
      system: system,
      type: type,
      confidence: confidence,
      source: source,
      id: id,
    );
  }

  /// The 24-character Crockford Base32 code.
  String encode() => _encodeBase32(_toBytes());

  /// The stable id as an 18-character hex string, for persistence. Store this
  /// once per profile; rebuild the code from it plus the profile's current
  /// fields via [ShareCode.new] so the code always reflects the latest data.
  String get idHex =>
      id.map((b) => (b & 0xFF).toRadixString(16).padLeft(2, '0')).join();

  /// Parses an [idHex] string back into 9 id bytes, or null if malformed.
  static List<int>? parseIdHex(String hex) {
    if (hex.length != _idBytes * 2) return null;
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      final b = int.tryParse(hex.substring(i, i + 2), radix: 16);
      if (b == null) return null;
      bytes.add(b);
    }
    return bytes;
  }

  /// Decodes a 24-character code. Returns null if the code is malformed, the
  /// checksum fails, or any field is unrecognized. Tolerates lowercase, spaces,
  /// dashes, and the ambiguous characters I/L (→1) and O (→0).
  static ShareCode? decode(String input) {
    final bytes = _decodeBase32(input);
    if (bytes == null || bytes.length != _payloadBytes) return null;
    if (bytes[14] != _checksum(bytes, 0, 14)) return null;
    if (bytes[0] != version) return null;
    if (bytes[1] >= PersonalitySystem.values.length) return null;
    if (bytes[2] >= MbtiType.values.length) return null;
    if (bytes[3] > 100) return null;
    if (bytes[4] >= ProfileSource.values.length) return null;
    return ShareCode(
      system: PersonalitySystem.values[bytes[1]],
      type: MbtiType.values[bytes[2]],
      confidence: bytes[3],
      source: ProfileSource.values[bytes[4]],
      id: bytes.sublist(5, 14),
    );
  }

  Uint8List _toBytes() {
    final b = Uint8List(_payloadBytes);
    b[0] = version;
    b[1] = system.index;
    b[2] = type.index;
    b[3] = confidence.clamp(0, 100);
    b[4] = source.index;
    for (var i = 0; i < _idBytes; i++) {
      b[5 + i] = id[i] & 0xFF;
    }
    b[14] = _checksum(b, 0, 14);
    return b;
  }

  static int _checksum(List<int> b, int start, int end) {
    var sum = 0;
    for (var i = start; i < end; i++) {
      sum = (sum + b[i]) & 0xFF;
    }
    return sum;
  }

  static String _encodeBase32(Uint8List bytes) {
    final sb = StringBuffer();
    var buffer = 0;
    var bits = 0;
    for (final byte in bytes) {
      buffer = (buffer << 8) | byte;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        sb.write(_alphabet[(buffer >> bits) & 0x1F]);
      }
    }
    if (bits > 0) {
      sb.write(_alphabet[(buffer << (5 - bits)) & 0x1F]);
    }
    return sb.toString();
  }

  static Uint8List? _decodeBase32(String input) {
    final cleaned =
        input.trim().toUpperCase().replaceAll('-', '').replaceAll(' ', '');
    if (cleaned.length != _codeLength) return null;
    final out = <int>[];
    var buffer = 0;
    var bits = 0;
    for (final ch in cleaned.split('')) {
      final val = _decodeSymbol(ch);
      if (val == null) return null;
      buffer = (buffer << 5) | val;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        out.add((buffer >> bits) & 0xFF);
      }
    }
    return Uint8List.fromList(out);
  }

  static int? _decodeSymbol(String ch) {
    switch (ch) {
      case 'I':
      case 'L':
        return 1;
      case 'O':
        return 0;
    }
    final idx = _alphabet.indexOf(ch);
    return idx == -1 ? null : idx;
  }
}
