# Archetypes - Project Context & Guidelines

## Project Overview
Archetypes is a Flutter (Material 3) application designed to manage and visualize personality profiles (MBTI) of known individuals. It calculates interpersonal affinity based on Jungian cognitive functions and provides a relationship graph.

- **Primary Technologies**: Flutter, Riverpod, Drift (SQLite), Hive, GraphView.
- **Target OS**: Mobile (iOS/Android), Windows (Desktop support).

---

## Building and Running

### Prerequisites
- Flutter SDK (stable channel)
- Dart SDK (included with Flutter)
- PowerShell 7+ (for Windows environments)

### Key Commands
```powershell
# Install dependencies
flutter pub get

# Generate Drift database code and Riverpod providers
# Run this after any change to app_database.dart or files with @riverpod annotations
dart run build_runner build --delete-conflicting-outputs

# Generate localizations
# Run this after editing .arb files in lib/presentation/l10n/
flutter gen-l10n

# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test

# Run the app
flutter run
```

---

## Architecture

The project follows a **three-layer architecture**:

### 1. Data Layer (`lib/data/`)
- **Database (`database/app_database.dart`)**: Drift schema defining tables for `Persons`, `PersonalityProfiles`, `Relationships`, etc. Uses `@DataClassName` to prevent collisions with domain entities.
- **Repositories (`repositories/`)**: Handles data fetching and persistence. Converts Drift entries to Domain entities.

### 2. Domain Layer (`lib/domain/`)
- **Entities (`entities/`)**: Pure Dart classes representing core concepts (`Person`, `PersonalityProfile`, `Relationship`).
- **Personality Systems (`personality_systems/`)**: MBTI-specific logic, including `MbtiType` and `CognitiveFunction` enums, and the `kMbtiStacks` map.
- **Affinity (`affinity/`)**: Business logic for calculating compatibility scores (`CognitiveFunctionAffinity`).

### 3. Presentation Layer (`lib/presentation/`)
- **Providers (`providers/`)**: Riverpod providers for state management. `databaseProvider` is overridden in `main.dart`.
- **Theme (`theme/app_theme.dart`)**: Material 3 light/dark themes and MBTI-specific color mapping.
- **L10n (`l10n/`)**: Localization files (.arb). Template is `app_it.arb`.
- **Screens (`screens/`)**: UI implementation organized by feature.

---

## Development Conventions

### Coding Standards
- **Senior Software Engineer Approach**: Prioritize root causes, modularity, and separation of concerns.
- **No Magic Numbers**: All logic parameters must be dynamic or configurable (see `Constants` or `database`).
- **Surgical Edits**: Make precise changes. Read files before editing. Avoid unnecessary refactoring.
- **Error Handling**: Do not add error handling for impossible scenarios; focus on robust logic.
- **Python 3 Compatibility**: (Note: Applies if Python scripts are added) Always parenthesize multiple exceptions.

### State Management (Riverpod)
- Use `NotifierProvider` or `AsyncNotifierProvider` for state that can change.
- `databaseProvider` must be overridden at the root `ProviderScope`.

### Database (Drift)
- Always increment `schemaVersion` and add migrations in `AppDatabase` when changing table structures.
- Use `build_runner` immediately after modifying table definitions.

### Localizations
- Source ARB files: `lib/presentation/l10n/`.
- Import: `package:archetypes/presentation/l10n/app_localizations.dart`.
- Always run `flutter gen-l10n` after modifying translations.

### Affinity Algorithm
- Located in `CognitiveFunctionAffinity.calculate`.
- It iterates through function pairs, weighting complementary functions based on their position in the stack (Dominant to Inferior).

---

## UI/UX Guidelines
- **Material 3**: Use M3 components and color schemes.
- **MBTI Colors**: Use `AppTheme.mbtiTypeColor()` for consistent color coding of personality types.
- **Interactive Feedback**: Ensure visual responses for user actions (buttons, sliders, graph interactions).
