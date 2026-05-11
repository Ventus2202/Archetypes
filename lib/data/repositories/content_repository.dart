import 'dart:convert';
import 'package:flutter/services.dart';

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

class ContentRepository {
  MbtiContent? _cache;
  RelationshipDynamicsContent? _dynamicsCache;
  CareerRolesContent? _careerCache;
  String? _loadedLocale;

  Future<MbtiContent> loadMbtiContent(String languageCode) async {
    if (_cache != null && _loadedLocale == languageCode) return _cache!;

    final supportedLocales = ['it', 'en'];
    final locale = supportedLocales.contains(languageCode) ? languageCode : 'en';

    final raw =
        await rootBundle.loadString('assets/content/$locale/mbti.json');
    final parsed = json.decode(raw) as Map<String, dynamic>;

    _cache = MbtiContent(
      types: Map<String, dynamic>.from(parsed['types'] as Map? ?? {}),
      functions: Map<String, dynamic>.from(parsed['functions'] as Map? ?? {}),
      dichotomies:
          Map<String, dynamic>.from(parsed['dichotomies'] as Map? ?? {}),
    );
    _loadedLocale = languageCode;
    return _cache!;
  }

  Future<RelationshipDynamicsContent> loadDynamicsContent(String languageCode) async {
    if (_dynamicsCache != null && _loadedLocale == languageCode) return _dynamicsCache!;

    final supportedLocales = ['it', 'en'];
    final locale = supportedLocales.contains(languageCode) ? languageCode : 'en';

    try {
      final raw =
          await rootBundle.loadString('assets/content/$locale/relationship_dynamics.json');
      final parsed = json.decode(raw) as Map<String, dynamic>;

      _dynamicsCache = RelationshipDynamicsContent(
        frictions: Map<String, dynamic>.from(parsed['frictions'] as Map? ?? {}),
        growths: Map<String, dynamic>.from(parsed['growths'] as Map? ?? {}),
        communications: Map<String, dynamic>.from(parsed['communications'] as Map? ?? {}),
      );
    } catch (_) {
      _dynamicsCache = const RelationshipDynamicsContent(
        frictions: {}, growths: {}, communications: {}
      );
    }
    
    _loadedLocale = languageCode;
    return _dynamicsCache!;
  }

  Future<CareerRolesContent> loadCareerRolesContent(String languageCode) async {
    if (_careerCache != null && _loadedLocale == languageCode) return _careerCache!;

    final supportedLocales = ['it', 'en'];
    final locale = supportedLocales.contains(languageCode) ? languageCode : 'en';

    try {
      final raw =
          await rootBundle.loadString('assets/content/$locale/career_roles.json');
      final parsed = json.decode(raw) as Map<String, dynamic>;

      _careerCache = CareerRolesContent(
        roles: Map<String, dynamic>.from(parsed['roles'] as Map? ?? {}),
      );
    } catch (_) {
      _careerCache = const CareerRolesContent(roles: {});
    }
    
    _loadedLocale = languageCode;
    return _careerCache!;
  }

  void invalidateCache() {
    _cache = null;
    _dynamicsCache = null;
    _careerCache = null;
    _loadedLocale = null;
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
