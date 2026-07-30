import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/quiz/quiz_models.dart';

class MbtiContent {
  final Map<String, dynamic> types;
  final Map<String, dynamic> functions;
  final Map<String, dynamic> dichotomies;

  const MbtiContent({
    required this.types,
    required this.functions,
    required this.dichotomies,
  });
}

class RelationshipDynamicsContent {
  final Map<String, dynamic> frictions;
  final Map<String, dynamic> growths;
  final Map<String, dynamic> communications;

  const RelationshipDynamicsContent({
    required this.frictions,
    required this.growths,
    required this.communications,
  });
}

class CareerRolesContent {
  final Map<String, dynamic> roles;

  const CareerRolesContent({
    required this.roles,
  });
}

class TeamObjectivesContent {
  final Map<String, dynamic> objectives;

  /// Keyed by the strings `TeamOptimizer` emits (`strength_ni`,
  /// `blindspot_te`, one per cognitive function); each value is the localized
  /// label. Before 2026-07-30 the team builder resolved those keys through
  /// stubs that returned the key itself, so the user read `NI, TE`.
  final Map<String, dynamic> strengths;
  final Map<String, dynamic> blindSpots;

  const TeamObjectivesContent({
    required this.objectives,
    required this.strengths,
    required this.blindSpots,
  });
}

/// Loads the localized JSON content bundled in `assets/`.
///
/// Two rules hold for every loader here:
///
/// * **Caches are keyed by locale.** Until 2026-07-29 the four caches shared a
///   single `_loadedLocale` that each loader overwrote with its own language, so
///   one loader running in English was enough to make the guard pass for a cache
///   filled in Italian: after a language switch the MBTI cards came back in the
///   old language. Keying by locale also means switching back and forth is free.
/// * **Failures propagate.** A missing or malformed asset throws; callers show
///   an explicit error. Returning empty content instead (what four of the five
///   loaders used to do) turned a broken asset into a blank screen with no
///   explanation, and it is the same silent-failure class already fixed in
///   `_AppGate` and in the quiz screen.
class ContentRepository {
  ContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  final Map<String, MbtiContent> _mbtiCache = {};
  final Map<String, RelationshipDynamicsContent> _dynamicsCache = {};
  final Map<String, CareerRolesContent> _careerCache = {};
  final Map<String, TeamObjectivesContent> _teamCache = {};

  static const _supportedLocales = ['it', 'en'];

  static String _resolveLocale(String languageCode) =>
      _supportedLocales.contains(languageCode) ? languageCode : 'en';

  Future<Map<String, dynamic>> _loadJson(String path) async {
    final raw = await _bundle.loadString(path);
    return json.decode(raw) as Map<String, dynamic>;
  }

  Future<MbtiContent> loadMbtiContent(String languageCode) async {
    final locale = _resolveLocale(languageCode);
    final cached = _mbtiCache[locale];
    if (cached != null) return cached;

    final parsed = await _loadJson('assets/content/$locale/mbti.json');

    return _mbtiCache[locale] = MbtiContent(
      types: Map<String, dynamic>.from(parsed['types'] as Map? ?? {}),
      functions: Map<String, dynamic>.from(parsed['functions'] as Map? ?? {}),
      dichotomies:
          Map<String, dynamic>.from(parsed['dichotomies'] as Map? ?? {}),
    );
  }

  Future<RelationshipDynamicsContent> loadDynamicsContent(
      String languageCode) async {
    final locale = _resolveLocale(languageCode);
    final cached = _dynamicsCache[locale];
    if (cached != null) return cached;

    final parsed =
        await _loadJson('assets/content/$locale/relationship_dynamics.json');

    return _dynamicsCache[locale] = RelationshipDynamicsContent(
      frictions: Map<String, dynamic>.from(parsed['frictions'] as Map? ?? {}),
      growths: Map<String, dynamic>.from(parsed['growths'] as Map? ?? {}),
      communications:
          Map<String, dynamic>.from(parsed['communications'] as Map? ?? {}),
    );
  }

  Future<CareerRolesContent> loadCareerRolesContent(String languageCode) async {
    final locale = _resolveLocale(languageCode);
    final cached = _careerCache[locale];
    if (cached != null) return cached;

    final parsed = await _loadJson('assets/content/$locale/career_roles.json');

    return _careerCache[locale] = CareerRolesContent(
      roles: Map<String, dynamic>.from(parsed['roles'] as Map? ?? {}),
    );
  }

  Future<TeamObjectivesContent> loadTeamObjectivesContent(
      String languageCode) async {
    final locale = _resolveLocale(languageCode);
    final cached = _teamCache[locale];
    if (cached != null) return cached;

    final parsed =
        await _loadJson('assets/content/$locale/team_objectives.json');

    return _teamCache[locale] = TeamObjectivesContent(
      objectives: Map<String, dynamic>.from(parsed['objectives'] as Map? ?? {}),
      strengths: Map<String, dynamic>.from(parsed['strengths'] as Map? ?? {}),
      blindSpots: Map<String, dynamic>.from(parsed['blind_spots'] as Map? ?? {}),
    );
  }

  Future<List<QuizQuestion>> loadQuizQuestions(
      String languageCode, QuizLength length) async {
    final locale = _resolveLocale(languageCode);

    final parsed = await _loadJson('assets/quiz/$locale/${length.fileName}');
    final questionsRaw = parsed['questions'] as List? ?? [];
    return questionsRaw
        .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic>? getTypeContent(MbtiContent content, String typeKey) =>
      content.types[typeKey] as Map<String, dynamic>?;

  Map<String, dynamic>? getFunctionContent(
          MbtiContent content, String functionKey) =>
      content.functions[functionKey] as Map<String, dynamic>?;

  Map<String, dynamic>? getDichotomyContent(
          MbtiContent content, String dichotomyKey) =>
      content.dichotomies[dichotomyKey] as Map<String, dynamic>?;
}
