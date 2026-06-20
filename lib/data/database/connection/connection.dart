// Picks the platform-specific database opener: native on mobile/desktop,
// WebAssembly on the web.
export 'unsupported.dart'
    if (dart.library.io) 'native.dart'
    if (dart.library.js_interop) 'web.dart';
