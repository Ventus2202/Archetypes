import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Re-encodes a picked avatar to a small JPEG so it doesn't bloat the DB and,
/// base64-inflated, every backup ZIP. `image_picker` only caps the dimensions
/// (and not reliably on web), keeping the original -- often PNG -- encoding, so
/// a single avatar can still weigh hundreds of KB. Decoding + JPEG re-encode is
/// pure Dart (`package:image`), so it runs on web too.
///
/// Returns the compressed JPEG bytes, or the original bytes unchanged when they
/// can't be decoded (unknown format) or the re-encoded result would be larger.
Uint8List compressAvatar(
  Uint8List input, {
  int maxDimension = 512,
  int quality = 80,
}) {
  // decodeImage throws (not just returns null) on corrupt/undecodable bytes,
  // e.g. a too-short buffer that its PSD probe reads past -- keep the original.
  img.Image? decoded;
  try {
    decoded = img.decodeImage(input);
  } catch (_) {
    return input;
  }
  if (decoded == null) return input;

  final tooBig = decoded.width > maxDimension || decoded.height > maxDimension;
  final resized = tooBig
      ? img.copyResize(
          decoded,
          // Constrain only the longer side; the other is derived to keep the
          // aspect ratio, so both end up <= maxDimension.
          width: decoded.width >= decoded.height ? maxDimension : null,
          height: decoded.height > decoded.width ? maxDimension : null,
          interpolation: img.Interpolation.average,
        )
      : decoded;

  final jpg = img.encodeJpg(resized, quality: quality);
  // An already-optimized small image can grow when re-encoded; keep the smaller.
  return jpg.length < input.length ? jpg : input;
}
