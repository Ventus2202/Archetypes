import 'dart:typed_data';

import 'package:archetypes/core/media/avatar_codec.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

// Builds a high-entropy image so its PNG encoding is large (near-raw) and the
// downscaled JPEG re-encode is genuinely smaller. A smooth gradient or flat
// color compresses to almost nothing as PNG too, making the size assertion
// meaningless -- so fill every pixel from a seeded LCG for real noise.
Uint8List _noisyPng(int width, int height) {
  final src = img.Image(width: width, height: height);
  var seed = 1234567;
  int next() {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return (seed >> 16) & 0xff;
  }

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      src.setPixelRgb(x, y, next(), next(), next());
    }
  }
  return img.encodePng(src);
}

bool _isJpeg(Uint8List bytes) =>
    bytes.length > 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;

void main() {
  test('re-encodes an oversized PNG to a smaller, capped JPEG', () {
    final input = _noisyPng(1000, 800);
    final out = compressAvatar(input, maxDimension: 512, quality: 80);

    expect(_isJpeg(out), isTrue, reason: 'output should be JPEG');
    expect(out.length, lessThan(input.length), reason: 'should shrink');

    final decoded = img.decodeImage(out)!;
    expect(decoded.width, lessThanOrEqualTo(512));
    expect(decoded.height, lessThanOrEqualTo(512));
    // Longer side (width, since landscape) is pinned to the cap.
    expect(decoded.width, 512);
  });

  test('caps a portrait image on its longer (height) side', () {
    final out = compressAvatar(_noisyPng(600, 1200), maxDimension: 512);
    final decoded = img.decodeImage(out)!;
    expect(decoded.height, 512);
    expect(decoded.width, lessThanOrEqualTo(512));
  });

  test('leaves an already-small image within the cap', () {
    final out = compressAvatar(_noisyPng(200, 150), maxDimension: 512);
    final decoded = img.decodeImage(out)!;
    expect(decoded.width, 200);
    expect(decoded.height, 150);
  });

  test('returns the input unchanged when it cannot be decoded', () {
    final garbage = Uint8List.fromList([1, 2, 3, 4, 5]);
    expect(compressAvatar(garbage), same(garbage));
  });
}
