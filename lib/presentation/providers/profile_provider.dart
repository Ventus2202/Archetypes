import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/personality_profile.dart';
import 'database_provider.dart';

final profilesForPersonProvider =
    StreamProvider.family<List<PersonalityProfile>, int>((ref, personId) {
  return ref.watch(profileRepositoryProvider).watchForPerson(personId);
});
