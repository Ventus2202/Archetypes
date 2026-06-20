import 'dart:math';

import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/data/repositories/person_repository.dart';
import 'package:archetypes/data/repositories/profile_repository.dart';
import 'package:archetypes/domain/entities/person.dart';
import 'package:archetypes/domain/entities/personality_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_profile.dart';
import 'package:archetypes/domain/personality_systems/mbti/mbti_types.dart';
import 'package:archetypes/domain/sharing/share_code.dart';
import 'package:archetypes/presentation/l10n/app_localizations.dart';
import 'package:archetypes/presentation/providers/database_provider.dart';
import 'package:archetypes/presentation/screens/chat/chat_screen.dart';
import 'package:archetypes/presentation/screens/person_detail/person_detail_screen.dart';
import 'package:archetypes/presentation/screens/share/share_code_ui.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// NOTE: these tests deliberately avoid PeopleListScreen — it subscribes to a
// live drift `.watch()` stream which, under flutter_test's fake clock with an
// in-isolate database, never goes idle and hangs `pump`. The share sheet and
// import dialog are exercised directly; both use one-shot Futures only.

void main() {
  Widget wrap(Widget home, AppDatabase db) => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: home,
        ),
      );

  testWidgets('SHARE: tap generates+persists code and shows the sheet',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final personRepo = PersonRepository(db);
    final profileRepo = ProfileRepository(db);

    final selfId = await personRepo.insert(Person(
      id: 0,
      name: 'Io',
      role: PersonRole.other,
      isSelf: true,
      createdAt: DateTime.now(),
    ));
    await profileRepo.upsert(PersonalityProfile(
      id: 0,
      personId: selfId,
      system: PersonalitySystem.mbti,
      data: MbtiProfile.fromType(MbtiType.intj).toJson(),
      confidence: 80,
      source: ProfileSource.manual,
      updatedAt: DateTime.now(),
    ));

    expect((await profileRepo.getForPerson(selfId)).first.shareId, isNull);

    await tester.pumpWidget(wrap(PersonDetailScreen(personId: selfId), db));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Condividi codice'), findsOneWidget);
    await tester.tap(find.byTooltip('Condividi codice'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Condividi il profilo'), findsOneWidget);
    expect(find.text('Copia'), findsOneWidget);

    final persisted = (await profileRepo.getForPerson(selfId)).first.shareId;
    expect(persisted, isNotNull);
    expect(ShareCode.parseIdHex(persisted!), isNotNull);
  });

  testWidgets('IMPORT: dialog creates a person, re-import dedups',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final personRepo = PersonRepository(db);
    final profileRepo = ProfileRepository(db);

    final code = ShareCode.generate(
      system: PersonalitySystem.mbti,
      type: MbtiType.enfp,
      confidence: 70,
      source: ProfileSource.manual,
      random: Random(5),
    );

    await tester.pumpWidget(wrap(
      Consumer(
        builder: (ctx, ref, _) => Scaffold(
          body: Center(
            child: Builder(
              builder: (c) => ElevatedButton(
                onPressed: () => showImportCodeDialog(c, ref),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
      db,
    ));
    await tester.pumpAndSettle();

    Future<void> importAs(String name) async {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), code.encode());
      await tester.enterText(find.byType(TextField).at(1), name);
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Aggiungi'));
      await tester.pumpAndSettle();
    }

    await importAs('Marco');

    final afterFirst = await personRepo.getAll();
    expect(afterFirst.where((p) => p.name == 'Marco').length, 1);
    final imported = await profileRepo.getByShareId(code.idHex);
    expect(imported, isNotNull);
    expect(imported!.data['type'], 'ENFP');

    await importAs('Marco DUP');
    final afterSecond = await personRepo.getAll();
    expect(afterSecond.length, afterFirst.length);
    expect(afterSecond.where((p) => p.name == 'Marco DUP'), isEmpty);

    // Flush the SnackBar auto-dismiss timers before teardown.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('CHAT: screen opens, unconfigured proxy fails gracefully',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(wrap(const ChatScreen(), db));
    await tester.pumpAndSettle();

    expect(find.textContaining('Proxy non configurato'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Chi sono?');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('Chi sono?'), findsOneWidget);
    expect(find.textContaining('Errore'), findsOneWidget);
  });
}
