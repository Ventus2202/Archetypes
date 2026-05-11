import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/personality_profile.dart';
import '../../domain/personality_systems/mbti/mbti_profile.dart';
import '../../domain/career/career_fit.dart';

final careerFitProvider = Provider.family<List<CareerFitResult>, PersonalityProfile>((ref, profile) {
  if (profile.system.name != 'mbti') return [];
  
  try {
    final mbtiProfile = MbtiProfile.fromJson(Map<String, dynamic>.from(profile.data));
    return CareerFit.calculateAll(mbtiProfile);
  } catch (_) {
    return [];
  }
});
