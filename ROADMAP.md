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
  PersonGroups, EventEntries), schema **v3** con migration (`shareId`, `avatarBytes`).
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
- [x] Pulire i commenti-appunto lasciati in `data_backup.dart`
  ("Remove the check if analyzer says...", "Use Companion...") — rimossi riscrivendo la
  gestione avatar (ora base64 nel `data.json`).
- [x] **CI GitHub Actions**: `.github/workflows/ci.yml` gira su push/PR verso `main`:
  `flutter pub get` → `dart run build_runner build` → `flutter gen-l10n` →
  `flutter analyze` → `flutter test`. Flutter fissato a 3.41.9, cache abilitata.
  (Da attivare: commit + push su GitHub.)
- [ ] Aumentare copertura test: `QuizEngine.calculateBreakdown`, `CareerFit.calculateAll`,
  `TeamOptimizer` con `must_include`, `ChatToolExecutor` (con repo in-memory).
- [x] Test di `DataBackupService`: oltre al round-trip di serializzazione
  (`BackupData.toJson`/`fromJson`, incl. `shareId` e `avatarBytes` base64) in
  `data_backup_test.dart`, ora c'è il test end-to-end sul ZIP reale
  (`data_backup_service_test.dart`: `exportToBytes` → `importFromBytes` → confronto DB su
  2 DB in-memory, + verifica del `replace`). Reso banale dal fix Epica 9: l'I/O è ora byte
  puri, niente più `path_provider`/`dart:io` da stubbare.
- [ ] **Test della migrazione DB v2→v3** (`avatarBytes`): oggi è verificato solo il
  round-trip base64 a livello di serializzazione, non l'`addColumn` reale. Usare il
  tooling schema-test di drift (dump dello schema + `verifySelfIntegrity`) per confermare
  che aprendo un DB v2 esistente la colonna venga aggiunta senza perdere dati. Vale anche
  per il passo v1→v2 (`shareId`), mai testato.
- [ ] Verificare il **primo run** di CI e del deploy Pages su GitHub; se il pin
  `flutter-version: 3.41.9` non si risolve nell'action, allentare a solo `channel: stable`.
- [ ] **Aggiornamento dipendenze controllato**: `flutter pub outdated` (2026-07-23) segnala
  molti pacchetti major indietro (`share_plus` 12→13, `riverpod`/`riverpod_annotation` 2→3+
  con generator, `file_picker` 8→10, `drift` minori) e due transitive **dismesse**
  (`build_resolvers`, `build_runner_core`, catena `build_runner`). Pianificare un giro di
  update a scaglioni con CI verde ad ogni passo (riverpod 3 è breaking → valutarlo a parte).

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
- [ ] Verificare che il nodo "io" venga renderizzato nel grafo dopo l'onboarding: nella
  walkthrough di questa sessione il grafo appariva vuoto con il solo profilo self.

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

Canale primario scelto: **PWA su GitHub Pages** con auto-update (niente APK da inviare
a ogni update).

- [x] **Web + PWA deploy automatico su GitHub Pages** (`.github/workflows/deploy-web.yml`):
  ogni push su `main` builda e pubblica l'app; update automatico per tutti al reload,
  installabile sulla home (manifest + service worker). Build verificato in locale con
  `--base-href "/Archetypes/"`.
  - [ ] **Setup una tantum su GitHub**: Settings → Pages → Source = "GitHub Actions",
    poi push del workflow su `main`. URL: `https://ventus2202.github.io/Archetypes/`.
- [ ] **Valutare build web `--wasm`**: il build (2026-07-23) segnala "Wasm dry run succeeded"
  e suggerisce `flutter build web --wasm` per performance. Da valutare per la PWA, tenendo
  presente che richiede cross-origin isolation (header COOP/COEP) — vedi la nota correlata nel
  backlog: GitHub Pages non imposta quegli header, quindi servirebbe un hosting alternativo.
- [ ] Build **release Android** firmata + istruzioni keystore (canale secondario).
- [ ] Setup **iOS / TestFlight** (canale secondario).
- [ ] Icona app e branding coerenti su tutte le piattaforme.

### 8. Documentazione

- [ ] Aggiornare `README.md`: la sezione "Da implementare" è obsoleta (condivisione,
  quiz JSON, chatbot e backup sono già fatti).
- [ ] Aggiungere screenshot delle schermate principali.
- [ ] Allineare `README` e `CLAUDE.md` quando cambia l'architettura.

### 9. Compatibilità web (PWA) — priorità alta

Con la PWA come **canale primario**, va sistemato il codice che usa `dart:io` / percorsi su
filesystem, non disponibili su web. Scoperto ispezionando il codice in questa sessione.

- [x] **Backup/restore su web**: `DataBackupService` riscritto in byte puri
  (`exportToBytes()` → `Uint8List`, `importFromBytes(Uint8List)`); rimossi
  `dart:io`/`path`/`path_provider`, `archive_io` → `archive` (web-safe). Export in
  `settings_screen.dart` ora fa branch: web → download del browser via helper a import
  condizionale (`lib/core/platform/file_download.dart` con Blob + anchor su `package:web`,
  perché `file_picker.saveFile` **non è implementato su web**); nativo → share sheet con
  `XFile.fromData` (niente più file temporaneo). Import usa `pickFiles(withData: true)` +
  `.bytes` (il `.path` è sempre `null` su web). `web` promosso a dipendenza diretta. Build
  web di release OK (`--base-href "/Archetypes/"`, wasm dry-run OK), analyze pulito, 39 test.
- [x] **Avatar su web**: gli avatar ora si salvano come **bytes nel DB** (nuova colonna
  `Persons.avatarBytes`, schema v2→v3 con `addColumn`). `person_edit_screen.dart` legge i
  bytes con `image.readAsBytes()` e li renderizza con `MemoryImage`; `graph_screen.dart` usa
  `MemoryImage(avatarBytes)`. Rimosso ogni `import 'dart:io'` / `FileImage` dalle due
  schermate → funzionano su web. La vecchia colonna `avatarPath` resta per gli avatar legacy
  mobile (non renderizzati finché non li si ri-seleziona). Backup: avatar serializzati base64
  in `data.json`. Test: round-trip base64 in `data_backup_test.dart`.
- [ ] **Compressione/limite peso avatar**: ora ogni avatar vive come bytes nel DB e, in
  base64, dentro **ogni** backup ZIP. `image_picker` limita solo le dimensioni a 512px, non
  l'encoding → un PNG può pesare centinaia di KB. Ricomprimere in JPEG (o cap sui byte)
  prima di salvare, per non gonfiare DB e backup.
- [ ] **Migrazione avatar legacy** `avatarPath` → `avatarBytes`: al primo avvio su mobile,
  leggere il file puntato da `avatarPath` e salvarne i bytes (gli avatar vecchi ora non si
  renderizzano più finché non li si ri-seleziona). Fatto questo, valutare la rimozione della
  colonna `avatarPath` ormai morta.
- [x] Audit di tutti gli `import 'dart:io'` nei layer presentation/data: l'unico rimasto è
  `data/database/connection/native.dart`, già correttamente isolato dietro import
  condizionale (`connection.dart`: `dart.library.io` → native, `dart.library.js_interop` →
  `web.dart`, fallback `unsupported.dart`). Confermato dal build web che compila senza errori.
- [ ] **Feedback UX export su web**: nel branch `kIsWeb`, `downloadBytes()` avvia il
  download del browser in modo silenzioso, senza conferma (sul nativo la share sheet è già
  feedback visibile). Mostrare uno snackbar tipo "Backup scaricato" dopo il download in
  `settings_screen._exportData`.
- [ ] **Prompt di aggiornamento in-app**: ascoltare l'update del service worker e mostrare
  "nuova versione disponibile, ricarica" (senza, l'auto-update PWA scatta solo al
  caricamento successivo).
- [ ] **Icone/branding PWA**: `web/icons/` e il manifest usano ancora le icone di default
  di Flutter → icone + favicon personalizzate.

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
- `.gitattributes` per normalizzare i fine-riga (LF nel repo) ed evitare gli avvisi
  LF→CRLF su Windows.
- Cross-origin isolation su GitHub Pages: senza header COOP/COEP, drift wasm usa il
  fallback IndexedDB invece di OPFS. Valutare un hosting che imposti gli header se
  servono performance/OPFS.
- Verifica manuale end-to-end del fix avatar su web (dev server `web` su :8080): aggiungi
  persona → scegli immagine → controlla che compaia nel grafo e nel dettaglio, e che
  sopravviva a un export/import di backup.
- Verifica manuale del **backup a runtime** (il round-trip byte/ZIP è coperto dai test, ma
  la UI no): su **web** esporta → controlla che il browser scarichi lo `.zip` → reimportalo;
  su **mobile** verifica la share sheet (`XFile.fromData`) in export e `pickFiles(withData:
  true)` in import. È il caveat lasciato aperto dal fix del 2026-07-23.
- Layout repo: il progetto Flutter è annidato in `Archetypes/` sotto una cartella che
  contiene `.claude` e `GEMINI.md`. Questo crea attrito coi tool (es. `.claude/launch.json`
  deve usare un wrapper `cmd /c "cd /d ... && flutter run"` per entrare nella sottocartella).
  Valutare se appiattire la struttura o spostare `.claude` dentro `Archetypes/`.

---

## Log giornaliero

Una riga per giornata di lavoro: `AAAA-MM-GG — task completati / note`.

- 2026-07-22 — Creata la roadmap; analisi stato del progetto. Individuato bug: `shareId`
  non incluso nel backup ZIP (vedi Epica 1).
- 2026-07-22 — Fix bug backup `shareId` (`data_backup.dart`) + test di regressione
  `test/domain/sharing/data_backup_test.dart` (2 test, verdi). `flutter analyze` pulito.
- 2026-07-22 — Aggiunta CI GitHub Actions (`.github/workflows/ci.yml`). Pipeline verificata
  in locale: `flutter analyze` pulito, 35 test verdi.
- 2026-07-22 — Verificato che l'app gira (preview web via `flutter run -d web-server`,
  onboarding + shell navigati). Aggiunto `.mcp.json` con 3 server MCP: dart (`dart
  mcp-server`), context7 (docs via npx), github (remoto HTTP+OAuth). Wrapper `cmd /c`
  per compatibilita Windows. Da attivare in sessione interattiva (approvazione + OAuth).
- 2026-07-22 — Distribuzione PWA: workflow `deploy-web.yml` per GitHub Pages + manifest/
  index PWA aggiornati (nome, descrizione, colori tema). Build web di release verificato
  in locale (`base-href`, `sqlite3.wasm`, service worker OK). Manca solo il setup Pages
  lato GitHub.
- 2026-07-22 — Aggiunti item emersi dalla scelta PWA: Epica 9 "Compatibilità web" (backup
  e avatar usano `dart:io` → rotti su web; prompt update service worker; icone PWA),
  verifica primo run CI/deploy, verifica nodo self nel grafo, nota COOP/COEP nel backlog.
- 2026-07-23 — Epica 9: **avatar web-safe**. Storage avatar spostato a bytes nel DB
  (`Persons.avatarBytes`, migration v2→v3), render `MemoryImage` in person_edit + graph,
  rimosso `dart:io`/`FileImage` dalle schermate; backup avatar via base64 in `data.json`
  (eliminato il ramo file `avatars/` nello ZIP + commenti-appunto). build_runner + gen-l10n
  rigenerati, `flutter analyze` pulito, 37 test verdi (2 nuovi round-trip avatar).
- 2026-07-23 — Epica 9 `[!]`: **backup/restore ora funziona nella PWA**. `DataBackupService`
  passa a byte puri (`exportToBytes`/`importFromBytes`), niente più `dart:io`/`path_provider`,
  `archive_io` → `archive`. Nuovo helper download browser a import condizionale
  (`core/platform/file_download*.dart`, Blob+anchor su `package:web`), perché
  `file_picker.saveFile` non esiste su web. `settings_screen` fa branch web/nativo per export
  e usa `withData:true` + `.bytes` per import. `web` promosso a dep diretta. Chiusi anche il
  test end-to-end di `DataBackupService` (Epica 1) e l'audit `dart:io` (Epica 9). Verifiche:
  analyze pulito, 39 test verdi (2 nuovi), **build web release OK** (wasm dry-run OK).
