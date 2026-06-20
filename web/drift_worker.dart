import 'package:drift/wasm.dart';

// Compiled to web/drift_worker.js with:
//   dart compile js web/drift_worker.dart -o web/drift_worker.js
// Re-run after upgrading drift to keep the worker version-matched.
void main() {
  WasmDatabase.workerMainForOpen();
}
