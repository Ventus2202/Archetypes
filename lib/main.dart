import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/constants.dart';
import 'data/database/app_database.dart';
import 'presentation/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(kHiveBoxSettings);

  final db = await AppDatabase.create();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const ArchetypesApp(),
    ),
  );
}
