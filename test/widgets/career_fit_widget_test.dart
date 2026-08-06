import 'dart:convert';

import 'package:archetypes/data/repositories/content_repository.dart';
import 'package:archetypes/domain/career/career_fit.dart';
import 'package:archetypes/domain/entities/personality_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/providers/settings_provider.dart';
import 'package:archetypes/presentation/screens/career_fit/career_fit_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// `CareerFitScreen` had never been pumped by a test. It is the closest twin of
/// the screen that turned out to be broken in production on 2026-08-03: it
/// reads the content JSON and casts it at the point of use, inside `build`,
/// where neither `avoid_dynamic_calls` nor `strict-casts` reaches.
class _ThrowingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw FlutterError('Unable to load asset: $key');

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      throw FlutterError('Unable to load asset: $key');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PersonalityProfile mbtiProfile(MbtiType type) => PersonalityProfile(
        id: 1,
        personId: 1,
        system: PersonalitySystem.mbti,
        data: MbtiProfile.fromType(type).toJson(),
        confidence: 90,
        source: ProfileSource.quizLong,
        updatedAt: DateTime(2026, 8, 6),
      );

  /// Pumps the real screen. The content arrives from a repository warmed under
  /// `runAsync` (asset I/O does not complete under the fake clock) so the
  /// screen's `FutureBuilder` resolves in a microtask; `pumpAndSettle` is not
  /// usable here because the loading branch is an endless spinner animation.
  Future<void> pumpScreen(
    WidgetTester tester, {
    required PersonalityProfile profile,
    Locale locale = const Locale('it'),
    ContentRepository? repository,
  }) async {
    final repo = repository ?? ContentRepository();
    if (repository == null) {
      await tester.runAsync(
          () => repo.loadCareerRolesContent(locale.languageCode));
    }

    await tester.pumpWidget(ProviderScope(
      overrides: [
        localeProvider.overrideWithValue(locale),
        contentRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('it'), Locale('en')],
        home: CareerFitScreen(profile: profile),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// The expected top role is derived from the engine, not copied into the
  /// test: if the catalog or the weights change, the assertion follows.
  Future<Map<String, dynamic>> roleEntry(
      WidgetTester tester, String id, String locale) async {
    final raw = await tester.runAsync(() =>
        rootBundle.loadString('assets/content/$locale/career_roles.json'));
    final roles = (json.decode(raw!) as Map<String, dynamic>)['roles'] as Map;
    return roles[id] as Map<String, dynamic>;
  }

  testWidgets('rende i ruoli con i titoli localizzati, in ordine di punteggio',
      (tester) async {
    final profile = mbtiProfile(MbtiType.intj);
    await pumpScreen(tester, profile: profile);

    expect(tester.takeException(), isNull);
    expect(find.text('Ruoli ideali'), findsOneWidget);

    final ranked = CareerFit.calculateAll(MbtiProfile.fromType(MbtiType.intj));
    final top = await roleEntry(tester, ranked.first.role.id, 'it');

    expect(find.text(top['title'] as String), findsOneWidget);

    // The list only builds the visible tiles, so the rendered scores are a
    // prefix of the engine's ranking — but they must be *that* prefix, in that
    // order. Ties are real (two roles score 84 for INTJ), which is why the
    // score is not matched by text alone.
    final rendered = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .map(int.tryParse)
        .whereType<int>()
        .toList();
    expect(rendered, isNotEmpty);
    expect(rendered, ranked.map((r) => r.score.round()).take(rendered.length));

    // `CareerRole.titleKey` resolves nowhere (no `career_*` key exists in the
    // ARB files), so the `?? res.role.titleKey` fallback would surface as a
    // raw key on screen. Nothing on this screen may read like one.
    expect(find.textContaining('career_'), findsNothing);
  });

  testWidgets('il tile si espande e mostra descrizione e motivazione',
      (tester) async {
    final profile = mbtiProfile(MbtiType.intj);
    await pumpScreen(tester, profile: profile);

    final ranked = CareerFit.calculateAll(MbtiProfile.fromType(MbtiType.intj));
    final top = await roleEntry(tester, ranked.first.role.id, 'it');

    expect(find.text(top['description'] as String), findsNothing);

    await tester.tap(find.text(top['title'] as String));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text(top['description'] as String), findsOneWidget);
    expect(find.text(top['why_fit'] as String), findsOneWidget);
  });

  testWidgets('EN: gli stessi ruoli si leggono in inglese', (tester) async {
    final profile = mbtiProfile(MbtiType.intj);
    await pumpScreen(tester, profile: profile, locale: const Locale('en'));

    expect(tester.takeException(), isNull);
    expect(find.text('Ideal Roles'), findsOneWidget);

    final ranked = CareerFit.calculateAll(MbtiProfile.fromType(MbtiType.intj));
    final topEn = await roleEntry(tester, ranked.first.role.id, 'en');
    final topIt = await roleEntry(tester, ranked.first.role.id, 'it');

    expect(find.text(topEn['title'] as String), findsOneWidget);
    if (topIt['title'] != topEn['title']) {
      expect(find.text(topIt['title'] as String), findsNothing);
    }
  });

  // `careerFitProvider` swallows a parse failure and returns an empty list, so
  // this screen would render the disclaimer over a blank area with no message.
  // That is unreachable from the app today — `person_detail` only offers the
  // entry point when `MbtiProfile.fromJson` succeeded and the system is MBTI —
  // so this pins the defensive branch as "does not crash", not as good UX.
  testWidgets('profilo illeggibile: la schermata non esplode', (tester) async {
    await pumpScreen(
      tester,
      profile: PersonalityProfile(
        id: 1,
        personId: 1,
        system: PersonalitySystem.mbti,
        data: const {},
        confidence: 50,
        source: ProfileSource.manual,
        updatedAt: DateTime(2026, 8, 6),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Ruoli ideali'), findsOneWidget);
  });

  testWidgets('asset illeggibile: errore esplicito, non lista muta',
      (tester) async {
    await pumpScreen(
      tester,
      profile: mbtiProfile(MbtiType.intj),
      repository: ContentRepository(bundle: _ThrowingBundle()),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Contenuto non trovato'), findsOneWidget);
  });
}
