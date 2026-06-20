import 'package:drift/drift.dart';

/// Fallback for platforms with neither dart:io nor a JS runtime.
QueryExecutor openConnection() =>
    throw UnsupportedError('Database not supported on this platform');
