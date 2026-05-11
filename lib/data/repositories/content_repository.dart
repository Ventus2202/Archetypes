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

class ContentRepository {
  MbtiContent? _cache;
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

  void invalidateCache() {
    _cache = null;
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
