import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/person.dart';
import 'database_provider.dart';

final allPersonsProvider = StreamProvider<List<Person>>(
  (ref) => ref.watch(personRepositoryProvider).watchAll(),
);

final selfPersonProvider = FutureProvider<Person?>(
  (ref) => ref.watch(personRepositoryProvider).getSelf(),
);

final personByIdProvider =
    FutureProvider.family<Person?, int>((ref, id) async {
  return ref.watch(personRepositoryProvider).getById(id);
});

final hasOnboardedProvider = FutureProvider<bool>(
  (ref) async {
    final self = await ref.watch(personRepositoryProvider).getSelf();
    return self != null;
  },
);
