import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/relationship_repository.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../domain/sharing/data_backup.dart';

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Override databaseProvider in main.dart'),
);

final personRepositoryProvider = Provider<PersonRepository>(
  (ref) => PersonRepository(ref.watch(databaseProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(databaseProvider)),
);

final relationshipRepositoryProvider = Provider<RelationshipRepository>(
  (ref) => RelationshipRepository(ref.watch(databaseProvider)),
);

final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) => GroupRepository(ref.watch(databaseProvider)),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(),
);

final dataBackupServiceProvider = Provider<DataBackupService>(
  (ref) => DataBackupService(ref.watch(databaseProvider)),
);
