# Roadmap Archetypes

Roadmap viva del progetto. Lo sviluppo è **continuo**: ogni giorno si porta a termine
almeno un punto e, quando serve, se ne aggiungono di nuovi. Questo file è la fonte di
verità su "cosa è fatto" e "cosa manca".

## Come si usa

1. A inizio giornata scegli **almeno un task** da una delle epiche qui sotto (di norma
   dalla sezione con priorità più alta).
2. A fine giornata: spunta i task completati (`[x]`), aggiungi una riga nel
   [Log giornaliero](#log-giornaliero) e, se sono emerse idee nuove, mettile nel
   [Backlog](#backlog--idee-future).
3. Quando un'epica si svuota, promuovi task dal Backlog o apri una nuova epica.

**Legenda stato:** `[ ]` da fare · `[~]` in corso · `[x]` fatto · `[!]` bug/urgente

---

## Stato attuale (fatto)

Verificato dal codice al 2026-07-22.

- **Fondamenta**: scaffolding Flutter, `flutter analyze` pulito, architettura a 3 livelli
  (data → domain → presentation), dominio in Dart puro.
- **Database (Drift)**: 6 tabelle (Persons, PersonalityProfiles, Relationships, Groups,
  PersonGroups, EventEntries), schema **v2** con migration (`shareId`).
- **Repository**: person, profile, relationship, group, content.
- **State (Riverpod)**: provider per database, repo, settings, person, profile, career,
  team, group, chat.
- **UI di base**: tema Material 3 light/dark ("costellazione"), shell a tab
  (Grafo / Persone / Impostazioni), onboarding wizard.
- **Internazionalizzazione**: IT + EN completa (ARB + codice generato).
- **Dominio MBTI**: 16 tipi, 8 funzioni cognitive, stack completi (`kMbtiStacks`),
  `MbtiProfile`.
- **Motori di scoring** (domain, `calculate(...)` statici):
  - Affinità cognitiva (0–100 + breakdown)
  - Relationship dynamics
  - Career fit + `career_catalog`
  - Team optimizer (per obiettivo)
  - Quiz engine (Likert → asse → `MbtiType`)
- **Quiz**: JSON short / medium / long in IT + EN.
- **Condivisione**: `SharedProfile` (payload JSON) + `ShareCode` (codice 24 char Crockford
  Base32) con rendering QR.
- **Backup/Restore**: export/import ZIP completo (`data.json` + avatar).
- **Chatbot on-device**: `ChatEngine` con loop tool-calling, tool "thick" che eseguono i
  motori localmente, proxy Cloudflare Workers AI (nessuna credenziale sul device).
- **Schermate**: onboarding, graph, people_list, person_detail, person_edit, settings,
  content_viewer, quiz, career_fit, team_builder, chat, share.
- **Contenuti didattici JSON** (IT + EN): mbti, relationship_dynamics, career_roles,
  team_objectives.
- **Test**: affinity, career, team, quiz, sharing (SharedProfile + ShareCode), widget test
  import.

---

## Epiche

### 1. Qualità e stabilità (priorità alta)

- [x] **Bug backup**: `data_backup.dart` non serializzava `shareId` nei profili → i codici di
  condivisione andavano persi al restore. Aggiunto `shareId` a `_profileToJson` /
  `_profileFromJson` (retrocompatibile: i backup vecchi lo leggono come `null`).
- [ ] `_AppGate` (`app.dart`) ingoia l'errore di `hasOnboardedProvider` mostrando comunque
  la HomeShell: distinguere errore reale da "non ancora onboardato".
- [ ] Pulire i commenti-appunto lasciati in `data_backup.dart`
  ("Remove the check if analyzer says...", "Use Companion...").
- [x] **CI GitHub Actions**: `.github/workflows/ci.yml` gira su push/PR verso `main`:
  `flutter pub get` → `dart run build_runner build` → `flutter gen-l10n` →
  `flutter analyze` → `flutter test`. Flutter fissato a 3.41.9, cache abilitata.
  (Da attivare: commit + push su GitHub.)
- [ ] Aumentare copertura test: `QuizEngine.calculateBreakdown`, `CareerFit.calculateAll`,
  `TeamOptimizer` con `must_include`, `ChatToolExecutor` (con repo in-memory).
- [~] Test di `DataBackupService`: coperto il round-trip di serializzazione
  (`BackupData.toJson`/`fromJson`, incl. `shareId`) in `data_backup_test.dart`; manca
  ancora il test end-to-end su file ZIP (export → import → confronto DB, richiede DB
  in-memory + stub di `path_provider`).

### 2. Nuovi sistemi di personalità (l'architettura è già pronta)

L'enum `PersonalitySystem` prevede già: `mbti, enneagram, bigFive, disc, cliftonStrengths`.
Solo MBTI è implementato. Per ognuno: modello di profilo, contenuti JSON IT+EN, calcolatore
di affinità registrato accanto a `CognitiveFunctionAffinity`.

- [ ] **Enneagramma**: 9 tipi + ali + tritype, modello + contenuti + affinità.
- [ ] **Big Five (OCEAN)**: profilo a 5 tratti continui + quiz + contenuti.
- [ ] **DISC**: 4 dimensioni + contenuti.
- [ ] **CliftonStrengths**: 34 talenti (fase 1: solo storage + schede).
- [ ] Registro affinità multi-sistema (selezione del calcolatore in base a `system`).
- [ ] UI: selezione sistema attivo per persona e nel grafo.

### 3. Grafo e relazioni

- [ ] Avatar reali sui nodi del grafo (`image_picker` già presente).
- [ ] Filtri per gruppo / per tipo MBTI, con animazione cluster.
- [ ] Creazione/modifica relazioni direttamente dal grafo (tap su arco).
- [ ] **Gestione gruppi**: schermata CRUD (tabelle `Groups`/`PersonGroups` e repo esistono,
  manca la UI).
- [ ] **Timeline eventi**: la tabella `EventEntries` esiste ma non ha né repository né UI —
  aggiungere repo + schermata cronologia per persona.

### 4. Chatbot

- [ ] Documentare/creare il **Cloudflare Worker proxy** (README dedicato + esempio deploy).
- [ ] Rendere il chatbot **multilingua** (system prompt e descrizioni tool anche in EN,
  seguendo il locale).
- [ ] Streaming delle risposte (token-by-token).
- [ ] Nuovi tool: `relationship_dynamics`, dettaglio singola persona, spiegazione di una
  funzione cognitiva.
- [ ] Persistenza della conversazione tra sessioni.

### 5. Quiz e profili

- [ ] Implementare la sorgente `ProfileSource.granular` (assessment per funzione, non solo
  per asse).
- [ ] Schermata di confronto: profilo manuale vs risultato quiz, con ricalcolo `confidence`.
- [ ] Retake del quiz con storicizzazione dei risultati.

### 6. Contenuti

- [ ] Espandere le schede di relazione per **coppia di tipi** (16×16), non solo per coppia
  di funzioni.
- [ ] Rivedere/ampliare i testi didattici esistenti (tipi, funzioni, ruoli, obiettivi team).
- [ ] Predisporre una terza lingua (es. ES) come prova del flusso i18n.

### 7. Distribuzione

- [ ] Build **release Android** firmata + istruzioni keystore.
- [ ] Setup **iOS / TestFlight**.
- [ ] Verificare e abilitare la **build Web** (`connection/web.dart` esiste già).
- [ ] Icona app e branding coerenti su tutte le piattaforme.

### 8. Documentazione

- [ ] Aggiornare `README.md`: la sezione "Da implementare" è obsoleta (condivisione,
  quiz JSON, chatbot e backup sono già fatti).
- [ ] Aggiungere screenshot delle schermate principali.
- [ ] Allineare `README` e `CLAUDE.md` quando cambia l'architettura.

---

## Backlog / idee future

Contenitore per lo sviluppo "infinito": idee non ancora pianificate.

- Ricerca/filtro persone nella lista.
- Statistiche aggregate (distribuzione tipi nella propria rete).
- Note vocali / allegati sugli eventi.
- Export PDF di un profilo o di un team.
- Sincronizzazione cloud opzionale (E2E) al posto del solo backup ZIP.
- Widget home / quick actions.
- Modalità "confronto" fianco a fianco tra due persone.
- Onboarding con import diretto da codice condiviso.

---

## Log giornaliero

Una riga per giornata di lavoro: `AAAA-MM-GG — task completati / note`.

- 2026-07-22 — Creata la roadmap; analisi stato del progetto. Individuato bug: `shareId`
  non incluso nel backup ZIP (vedi Epica 1).
- 2026-07-22 — Fix bug backup `shareId` (`data_backup.dart`) + test di regressione
  `test/domain/sharing/data_backup_test.dart` (2 test, verdi). `flutter analyze` pulito.
- 2026-07-22 — Aggiunta CI GitHub Actions (`.github/workflows/ci.yml`). Pipeline verificata
  in locale: `flutter analyze` pulito, 35 test verdi.
