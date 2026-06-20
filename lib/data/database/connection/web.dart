import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web connection: SQLite compiled to WebAssembly, run in a drift worker.
/// Loads `sqlite3.wasm` and `drift_worker.js` from the web root (see `web/`).
QueryExecutor openConnection() => LazyDatabase(() async {
      final result = await WasmDatabase.open(
        databaseName: 'archetypes',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    });
