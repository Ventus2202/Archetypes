# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/file_test.dart
```

> Both `build_runner` and `gen-l10n` must be re-run on a fresh clone before the project compiles.

## Architecture

Three-layer architecture: **data → domain → presentation**.

```
lib/
├── main.dart                   # Bootstraps Hive, Drift DB, ProviderScope override
├── app.dart                    # MaterialApp + _AppGate (onboarding vs HomeShell)
├── core/constants.dart         # App-wide string keys (Hive box names, etc.)
├── data/
│   ├── database/app_database.dart   # Drift schema (+ generated .g.dart)
│   └── repositories/               # One repo per entity; convert Drift entries ↔ domain objects
├── domain/
│   ├── entities/               # Pure Dart: Person, PersonalityProfile, Relationship + enums
│   ├── personality_systems/mbti/   # MbtiType, CognitiveFunction enums; kMbtiStacks constant map; MbtiProfile
│   └── affinity/cognitive_function_affinity.dart   # Affinity algorithm (see below)
└── presentation/
    ├── l10n/                   # Generated AppLocalizations + .arb source files
    ├── theme/app_theme.dart    # Material 3 light/dark + mbtiTypeColor() helper
    ├── providers/              # Riverpod providers (database, repos, settings, person, profile)
    ├── home_shell.dart         # IndexedStack bottom-nav shell (Graph / People / Settings)
    └── screens/                # One subdirectory per screen
```

## Key Patterns

### Database (Drift)
`app_database.dart` defines all tables. The `@DataClassName('PersonEntry')` annotation renames generated data classes to avoid collision with domain entity classes (e.g. `PersonEntry` vs `Person`). After any table change: **re-run build_runner**. Schema version lives in `AppDatabase.schemaVersion`; increment it and add a migration when modifying tables.

### State management (Riverpod)
`databaseProvider` is intentionally unimplemented — it **must** be overridden at startup via `ProviderScope(overrides: [databaseProvider.overrideWithValue(db)])` in `main.dart`. All repository providers depend on it. Settings (theme, locale) are persisted in Hive and exposed via `settingsProvider` (a `NotifierProvider`).

### Localizations
ARB source files live in `lib/presentation/l10n/`. Template is `app_it.arb`. Import the generated class as `package:archetypes/presentation/l10n/app_localizations.dart` (not `package:flutter_gen/...` — the output goes to the same directory as the ARB files).

### Personality data flow
`PersonalityProfile.data` is a raw `Map<String, dynamic>` stored as JSON in SQLite. For MBTI, deserialize it with `MbtiProfile.fromJson(profile.data)`. The canonical function stacks are in `kMbtiStacks` (`mbti_functions.dart`). Never hard-code a stack — always derive it from this map.

### Affinity algorithm
`CognitiveFunctionAffinity.calculate(profileA, profileB)` iterates all 4×4 function-pair combinations, scores complementary pairs (using `kComplementaryFunctions`) weighted by stack position (dominant=4 … inferior=1), and normalizes to 0–100. The `_maxRaw = 6.0` constant is the theoretical ceiling — adjust it if the scoring weights change.

### Educational content
`assets/content/{it,en}/mbti.json` contains all 16 types, 8 cognitive functions, and 4 dichotomies. `ContentRepository` loads and caches the JSON per locale. Access via `getTypeContent(content, "INTJ")`, `getFunctionContent(content, "Ni")`, `getDichotomyContent(content, "IE")`. The `ContentViewerScreen` takes a `contentKey` + `ContentViewerType` enum and dispatches to the correct section.

### Adding a new personality system (future)
1. Add a value to `PersonalitySystem` enum (`personality_profile.dart`).
2. Create `lib/domain/personality_systems/<system>/` with its profile model.
3. Profiles are stored in the existing `PersonalityProfiles` table with `system = '<new_value>'`; only `dataJson` format changes.
4. Implement an affinity calculator and register it alongside `CognitiveFunctionAffinity`.
