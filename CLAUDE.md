# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Fresh PC Setup

```powershell
# 1. Install Flutter (no admin required)
git clone --branch stable https://github.com/flutter/flutter.git C:\Users\<user>\flutter
$env:PATH += ";C:\Users\<user>\flutter\bin"

# 2. Clone repo and set up
git clone https://github.com/Ventus2202/Archetypes.git
cd Archetypes
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze   # should print "No issues found"
```

Steps 3–4 are **mandatory** — the project will not compile without the generated `.g.dart` and `app_localizations.dart` files.

---

## Commands

```bash
# After cloning or adding dependencies
flutter pub get

# Re-generate Drift DB code and any other build_runner output (run after ANY change to app_database.dart)
dart run build_runner build --delete-conflicting-outputs

# Re-generate localizations (run after editing any .arb file)
flutter gen-l10n

# Lint
flutter analyze

# Run tests (domain engines have unit tests under test/domain/: affinity, career, team, quiz, sharing)
flutter test

# Run a single test file
flutter test test/domain/quiz/quiz_engine_test.dart
```

> Both `build_runner` and `gen-l10n` must be re-run on a fresh clone before the project compiles.

## Architecture

Three-layer architecture: **data → domain → presentation**. The `domain` layer is pure Dart (no Flutter/Drift imports) and holds all the scoring engines; each feature engine is a stateless class with a static `calculate(...)` method that takes domain objects and returns a result object.

```
lib/
├── main.dart                   # Bootstraps Hive, Drift DB, ProviderScope override
├── app.dart                    # MaterialApp + _AppGate (onboarding vs HomeShell)
├── core/constants.dart         # App-wide string keys (Hive box names, etc.)
├── data/
│   ├── database/app_database.dart   # Drift schema (+ generated .g.dart)
│   ├── chat/                        # On-device chatbot: ChatClient (proxy), kChatTools,
│   │                                #   ChatToolExecutor, ChatEngine (tool-calling loop)
│   └── repositories/               # One repo per entity; convert Drift entries ↔ domain objects
│                                   # (content, person, profile, relationship, group)
├── domain/
│   ├── entities/               # Pure Dart: Person, PersonalityProfile, Relationship + enums
│   ├── personality_systems/mbti/   # MbtiType, CognitiveFunction enums; kMbtiStacks constant map; MbtiProfile
│   ├── affinity/              # cognitive_function_affinity.dart (score) + relationship_dynamics.dart
│   ├── career/               # CareerFit engine, CareerRole model, career_catalog.dart
│   ├── team/                 # TeamOptimizer (objective-weighted team scoring) + team_models.dart
│   ├── quiz/                 # QuizEngine (axis scoring → MbtiType) + quiz_models.dart
│   └── sharing/             # SharedProfile (JSON payload) + share_code.dart (24-char code)
│                            #   + data_backup.dart (ZIP export/import)
└── presentation/
    ├── l10n/                   # Generated AppLocalizations + .arb source files
    ├── theme/app_theme.dart    # Material 3 light/dark + mbtiTypeColor() helper
    ├── providers/              # Riverpod providers (database, repos, settings, person, profile, career, team, group)
    ├── home_shell.dart         # IndexedStack bottom-nav shell (Graph / People / Settings)
    └── screens/                # One subdirectory per screen (graph, people_list, person_detail,
                                #   person_edit, onboarding, settings, content_viewer, quiz,
                                #   career_fit, team_builder, chat, share)
```

## Key Patterns

### Database (Drift)
`app_database.dart` defines all tables. The `@DataClassName('PersonEntry')` annotation renames generated data classes to avoid collision with domain entity classes (e.g. `PersonEntry` vs `Person`). After any table change: **re-run build_runner**. Schema version lives in `AppDatabase.schemaVersion` (currently `2`); increment it and add an `onUpgrade` step in `migration` when modifying tables — follow the existing v1→v2 step that `addColumn`s `personalityProfiles.shareId`.

### State management (Riverpod)
`databaseProvider` is intentionally unimplemented — it **must** be overridden at startup via `ProviderScope(overrides: [databaseProvider.overrideWithValue(db)])` in `main.dart`. All repository providers depend on it. Settings (theme, locale) are persisted in Hive and exposed via `settingsProvider` (a `NotifierProvider`).

### Localizations
ARB source files live in `lib/presentation/l10n/`. Template is `app_it.arb`. Import the generated class as `package:archetypes/presentation/l10n/app_localizations.dart` (not `package:flutter_gen/...` — the output goes to the same directory as the ARB files).

### Personality data flow
`PersonalityProfile.data` is a raw `Map<String, dynamic>` stored as JSON in SQLite. For MBTI, deserialize it with `MbtiProfile.fromJson(profile.data)`. The canonical function stacks are in `kMbtiStacks` (`mbti_functions.dart`). Never hard-code a stack — always derive it from this map.

### Affinity algorithm
`CognitiveFunctionAffinity.calculate(profileA, profileB)` iterates all 4×4 function-pair combinations, scores complementary pairs (using `kComplementaryFunctions`) weighted by stack position (dominant=4 … inferior=1), and normalizes to 0–100. The `_maxRaw = 6.0` constant is the theoretical ceiling — adjust it if the scoring weights change.

### Feature engines (domain layer)
All four scoring features follow the same shape: a stateless engine with a static method, fed by domain objects derived from `MbtiProfile`, returning a plain result object. They never touch Drift or Flutter.
- **`CareerFit.calculate(profile, role)`** — scores a role by summing `role.functionWeights` weighted by stack position multipliers `[1.0, 0.7, 0.4, 0.2]`, plus dichotomy-preference bonuses. Roles come from `career_catalog.dart`.
- **`TeamOptimizer`** — uses `kTeamObjectiveWeights` (per-`TeamObjective` cognitive-function weight maps) plus pairwise affinity (reuses `CognitiveFunctionAffinity`) to score/assemble teams.
- **`QuizEngine.calculateResult(questions, answers)`** — answers are 1–5 Likert; per question `score = (answer-3) * direction * weight` accumulated per axis (IE/NS/TF/JP), then thresholded into a 4-letter `MbtiType`. `calculateBreakdown` returns the raw axis scores. Quiz JSON lives in `assets/quiz/{it,en}/mbti_{short,medium,long}.json`.
- **`SharedProfile`** — compact share/import payload `{"v":"arc1","n":...,"t":...,"c":...}`. `decode()` extracts the JSON even when embedded in surrounding text; bump `version` if the schema changes. `data_backup.dart` handles full ZIP export/import (`archive` package).
- **`ShareCode`** — fixed-length 24-char Crockford Base32 code (15 bytes: version, system, MBTI type, confidence, source, 9-byte random id, checksum) for sharing a single profile; rendered as text + QR (`qr_flutter`). The name is *not* encoded — the importer types it. Persist only the stable id (`shareId` column, `idHex`) and rebuild the code from it plus the profile's current fields via `ShareCode.new`, so the code always reflects the latest data. Bump `version` if the byte layout changes.

### Chatbot (on-device tool-calling, `data/chat/`)
The chatbot answers questions about the people in the map (affinity, best pairs, teams, role fit). It holds **no credentials**: `ChatClient` POSTs OpenAI-style chat-completions to a Cloudflare Worker proxy, which injects Cloudflare creds and forwards to Workers AI (free-tier open model with function calling, default `@hf/nousresearch/hermes-2-pro-mistral-7b`). The proxy URL is `kChatProxyUrl`, supplied at build time with `--dart-define=CHAT_PROXY_URL=https://<worker>.workers.dev` (empty by default, so the chat is disabled until configured — `ChatClient.isConfigured`). `ChatEngine.send()` runs the tool loop (max 6 rounds); `kChatTools` are **thick** tools — each runs the full deterministic computation against the domain engines (`CognitiveFunctionAffinity`, `TeamOptimizer`, `CareerFit`) via `ChatToolExecutor` and returns only ranked/summarized results, so a small model just orchestrates and narrates and never does MBTI math. Only tool results (names, types, scores) leave the device. The system prompt and tool descriptions are Italian; keep responses concise and grounded in tool output.

### Educational content
`assets/content/{it,en}/` holds the localized JSON content, loaded and cached per locale by `ContentRepository`: `mbti.json` (16 types, 8 cognitive functions, 4 dichotomies), `relationship_dynamics.json`, `career_roles.json`, `team_objectives.json`. Domain engines emit translation **keys** (e.g. `FrictionPoint.titleKey`); the content JSON / ARB resolve them to localized strings. Access MBTI content via `getTypeContent(content, "INTJ")`, `getFunctionContent(content, "Ni")`, `getDichotomyContent(content, "IE")`. `ContentViewerScreen` takes a `contentKey` + `ContentViewerType` enum and dispatches to the correct section.

### Adding a new personality system (future)
1. Add a value to `PersonalitySystem` enum (`personality_profile.dart`).
2. Create `lib/domain/personality_systems/<system>/` with its profile model.
3. Profiles are stored in the existing `PersonalityProfiles` table with `system = '<new_value>'`; only `dataJson` format changes.
4. Implement an affinity calculator and register it alongside `CognitiveFunctionAffinity`.
