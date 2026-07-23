import 'dart:typed_data';

/// Non-web fallback. Browser downloads only exist on web; native platforms
/// save or share bytes through their own APIs, so callers must guard with
/// `kIsWeb` and never reach this on the VM.
Future<void> downloadBytes(
  Uint8List bytes,
  String fileName,
  String mimeType,
) async {
  throw UnsupportedError('downloadBytes is only supported on web');
}
