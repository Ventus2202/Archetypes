# Archetypes

App mobile cross-platform (iOS + Android) per gestire profili di personalità e visualizzare la rete di relazioni come grafo interattivo. Il sistema MVP si basa su MBTI e funzioni cognitive jungiane; l'architettura è progettata per accogliere Enneagramma, Big Five, Socionica e altri sistemi in futuro.

---

## Prerequisiti

- **Flutter 3.41.9 / Dart 3.11.5** (o versione stabile successiva compatibile)
- **Git** (per installare Flutter senza diritti di amministratore)
- **Android Studio** o un emulatore/dispositivo fisico Android per testare

### Installare Flutter senza diritti di amministratore (Windows)

```powershell
# Clona lo stable branch di Flutter in una directory utente
git clone --branch stable https://github.com/flutter/flutter.git C:\Users\<tuo_utente>\flutter

# Aggiunge Flutter al PATH solo per la sessione corrente
$env:PATH += ";C:\Users\<tuo_utente>\flutter\bin"

# Verifica installazione
flutter doctor
```

Per rendere il PATH permanente: Pannello di controllo → Variabili d'ambiente → PATH utente → aggiungi `C:\Users\<tuo_utente>\flutter\bin`.

I seguenti warning di `flutter doctor` sono **attesi e non bloccanti**:
- Android cmdline-tools missing
- Visual Studio not installed
- CocoaPods network error (solo macOS/iOS)

---

## Setup dopo il clone

```powershell
# 1. Clona il repository
git clone https://github.com/Ventus2202/Archetypes.git
cd Archetypes

# 2. Scarica le dipendenze
flutter pub get

# 3. Genera il codice Drift (ORM SQLite) — OBBLIGATORIO
dart run build_runner build --delete-conflicting-outputs

# 4. Genera le localizzazioni — OBBLIGATORIO
flutter gen-l10n

# 5. Verifica che non ci siano errori
flutter analyze
```

I passi 3 e 4 devono essere **sempre eseguiti su ogni clone fresco** e dopo qualsiasi modifica rispettivamente a `app_database.dart` (schema DB) e ai file `.arb` (stringhe UI).

---

## Avviare l'app

```powershell
# Lista dispositivi disponibili
flutter devices

# Avvia su un dispositivo specifico
flutter run -d <device_id>

# Build release APK
flutter build apk --release
```

---

## Stato del progetto

### Completato
- Scaffolding Flutter con `flutter analyze` pulito
- Database Drift (6 tabelle: Persons, PersonalityProfiles, Relationships, Groups, PersonGroups, EventEntries)
- 4 repository con conversione entry ↔ domain entity
- Riverpod providers (database, repos, settings, person, profile)
- Tema Material 3 light/dark con palette "costellazione"
- Internazionalizzazione IT + EN completa (ARB + codice generato)
- Dominio MBTI: 16 tipi, 8 funzioni cognitive, stack completi, `MbtiProfile`
- Motore affinità cognitiva (score 0–100 + breakdown)
- 7 schermate: onboarding wizard, grafo force-directed, lista persone, dettaglio, modifica, impostazioni, viewer contenuti
- Contenuti JSON: 16 tipi + 8 funzioni + 4 dicotomie in IT e EN (`assets/content/{it,en}/mbti.json`)

### Da implementare (prossimi passi)

1. **Condivisione profilo** — bottone "Condividi il mio profilo" in Impostazioni → share via `share_plus` come JSON `{"v":"arc1","n":"...","t":"INTJ","c":85}`; import: incolla testo → dialog preview → aggiungi persona. Richiede `share_plus` in `pubspec.yaml`.
2. **Quiz JSON** — scrivere `assets/quiz/{it,en}/mbti_{short,medium,long}.json` (directory create, file vuoti)
3. **Test unitari affinità** — `test/domain/affinity_test.dart` con coppie note: INTJ↔ENFP (alta), INTJ↔INTJ (media), INTJ↔ESTJ (buona lavorativa)
4. **Polish grafo** — nodi con avatar reale (`image_picker` già in pubspec), filtri per gruppo/tipo, animazione cluster
5. **Export/Import ZIP** — `archive` già in pubspec, stub UI presente in Impostazioni

---

## Struttura del progetto

```
lib/
├── main.dart                       # Bootstrap Hive + Drift + ProviderScope
├── app.dart                        # MaterialApp, routing, onboarding gate
├── core/constants.dart             # Costanti globali (nomi Hive box, ecc.)
├── data/
│   ├── database/app_database.dart  # Schema Drift (+ .g.dart generato)
│   └── repositories/              # 4 repository (person, profile, relationship, content)
├── domain/
│   ├── entities/                   # Person, PersonalityProfile, Relationship + enum
│   ├── personality_systems/mbti/   # MbtiType, CognitiveFunction, kMbtiStacks, MbtiProfile
│   └── affinity/                   # CognitiveFunctionAffinity.calculate()
└── presentation/
    ├── l10n/                       # AppLocalizations generato + file .arb sorgente
    ├── theme/app_theme.dart        # Temi Material 3 + mbtiTypeColor()
    ├── providers/                  # Riverpod providers
    ├── home_shell.dart             # Shell navigazione a tab (Grafo / Persone / Impostazioni)
    └── screens/                    # Una sottodirectory per schermata
assets/
├── content/{it,en}/mbti.json       # Schede didattiche (tipi, funzioni, dicotomie)
└── quiz/{it,en}/                   # File quiz (da scrivere)
```

---

## Architettura

Architettura a tre livelli: **data → domain → presentation**.

- **data**: repository Drift che convertono `Entry` (generati) ↔ entity di dominio
- **domain**: Dart puro — entità, logica MBTI, motore affinità
- **presentation**: Riverpod + schermate Flutter

Per dettagli su pattern chiave (Drift `@DataClassName`, override `databaseProvider`, import localizzazioni, algoritmo affinità) vedi [CLAUDE.md](CLAUDE.md).

---

## Tecnologie

| Pacchetto | Uso |
|-----------|-----|
| `flutter_riverpod` | State management |
| `drift` + `sqlite3_flutter_libs` | Database locale type-safe |
| `hive_flutter` | Preferenze utente |
| `graphview` | Grafo force-directed |
| `image_picker` | Foto avatar |
| `archive` | Export/import ZIP |
| `flutter_markdown` | Rendering contenuti didattici |
| `share_plus` | Condivisione profilo *(da aggiungere)* |
