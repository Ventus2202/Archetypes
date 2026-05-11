import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/group_repository.dart';
import 'database_provider.dart';

final allGroupsProvider = StreamProvider<List<Group>>((ref) {
  return ref.watch(groupRepositoryProvider).watchAll();
});
