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
- [x] `_AppGate` (`app.dart`) ingoiava l'errore di `hasOnboardedProvider` mostrando comunque
  la HomeShell (utente in un'app rotta, senza feedback). Ora il ramo `error:` mostra una
  schermata dedicata (`_GateError`: icona, messaggio, dettaglio errore) con un pulsante
  **Riprova** che fa `ref.invalidate(hasOnboardedProvider)`. Nuova stringa l10n `retry`
  (IT/EN). Widget test di regressione (`test/widgets/app_gate_widget_test.dart`) che pompa il
  vero `ArchetypesApp` e verifica: errore → schermata errore (no HomeShell), non-onboardato →
  OnboardingScreen.
- [x] Pulire i commenti-appunto lasciati in `data_backup.dart`
  ("Remove the check if analyzer says...", "Use Companion...") — rimossi riscrivendo la
  gestione avatar (ora base64 nel `data.json`).
- [x] **CI GitHub Actions**: `.github/workflows/ci.yml` gira su push/PR verso `main`:
  `flutter pub get` → `dart run build_runner build` → `flutter gen-l10n` →
  `flutter analyze` → `flutter test`. Flutter fissato a 3.41.9, cache abilitata.
  (Da attivare: commit + push su GitHub.)
- [x] Aumentare copertura test: `QuizEngine.calculateBreakdown` (era già coperto),
  `CareerFit.calculateAll` (catalogo completo, ordinamento decrescente, clamp 0–100 su tutti
  e 16 i tipi, coerenza con `calculate()`), `TeamOptimizer` (teamSize > candidati, max 3
  composizioni ordinate, must-include su entrambi i percorsi), `ChatToolExecutor`
  (14 test su DB in-memory + repo reali, tutti e 7 i tool + path d'errore).
  45 → 67 test. Emerso e corretto il bug `must_include_id` (sotto).
- [x] **Bug `must_include_id` del chatbot**: `ChatToolExecutor._optimizeTeam` filtrava le
  top-3 composizioni *dopo* `findBest`, con `orElse: () => comps.first` → se la persona
  richiesta non capitava nelle prime 3 il vincolo spariva in silenzio e l'utente riceveva un
  team senza di sé ("un team con me"). Sul percorso greedy (>12 candidati) `findBest`
  restituisce una sola composizione, quindi il vincolo saltava quasi sempre. Ora
  `TeamOptimizer.findBest` accetta `mustIncludePersonId` e lo applica come vincolo vero
  (filtro delle combinazioni sul percorso esaustivo, seed del greedy sull'altro); se la
  persona non è tra i candidati restituisce lista vuota e il tool risponde con un errore
  esplicito invece di un fallback muto.
- [ ] **Testabilità delle schermate con stream drift**: `PeopleListScreen` (e potenzialmente
  il grafo) si sottoscrivono a un `.watch()` drift che sotto il fake clock di `flutter_test`
  non va mai idle → `pumpAndSettle` va in hang (vedi nota in `share_import_widget_test.dart`).
  È un blocco reale all'aumento di copertura widget: introdurre un helper/pattern per pompare
  quelle schermate (o disaccoppiare lo stream in test) prima di poterle coprire.
  Perimetro chiarito il 2026-07-27: riguarda **solo** le schermate sottoscritte a `.watch()`.
  `OnboardingScreen` e `QuizScreen`, che leggono su tap, pompano senza problemi con
  `pumpAndSettle` (4 widget test girano su di esse). La lista bloccata è quindi più corta del
  temuto: `PeopleListScreen` e il grafo.
- [x] **Cleanup analyze**: rimosso l'`unnecessary_import` `dart:typed_data` in
  `test/domain/sharing/data_backup_service_test.dart:1` (`Uint8List` arriva già da
  `drift/drift.dart`, riga 5). `flutter analyze` di nuovo pulito ("No issues found").
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
- [ ] **Il codice generato è committato e la CI lo rigenera: nessuno può accorgersi se è
  stale.** Scoperto il 2026-07-27: `git ls-files` mostra che `app_database.g.dart` e i tre
  `app_localizations*.dart` sono **tracciati**, e `ci.yml` esegue `build_runner` +
  `gen-l10n` *prima* di `analyze`/`test`, sovrascrivendoli. Quindi un `.arb` (o
  `app_database.dart`) modificato e committato **senza** i file rigenerati passa la CI
  verde, e il repo può portarsi dietro codice generato che non corrisponde alla sua
  sorgente. Effetto collaterale minore: ogni sessione che tocca l10n o schema sporca il
  commit con i diff dei generati (questa sessione: 3 file). Scegliere una politica:
  (a) tenerli committati e aggiungere `git diff --exit-code` dopo i due generatori in CI,
  così una rigenerazione dimenticata rompe la build; (b) metterli in `.gitignore` e
  affidarsi ai generatori in setup/CI. Vedi la voce collegata in Epica 8.
- [ ] **Nessun test legge un profilo dal DB dopo un quiz**: il fix del 2026-07-27
  (confidence/source reali) è coperto solo a livello di engine — `QuizEngine.evaluate` e la
  formula della confidence. I due percorsi che *scrivono* il profilo,
  `QuizScreen._saveAndExit` e `onboarding._save`, non hanno test: nulla impedisce a un
  refactor di rimettere una costante nell'`upsert`. Serve un test che simuli un quiz e
  rilegga `source`/`confidence` dal DB in-memory (il pattern dei repo reali di
  `chat_tool_executor_test.dart` funziona già).
- [ ] **`_save()` senza gestione errori nell'onboarding e in `person_edit`**: se
  `personRepo.insert` o l'`upsert` lanciano, l'eccezione async resta non gestita e `_saving`
  non torna mai `false` → spinner infinito, pulsante disabilitato, utente bloccato
  nell'onboarding senza alcun messaggio. Stessa classe del bug `_AppGate` già chiuso:
  `try/catch` + snackbar e `_saving = false` nel `finally`.
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

Le prime cinque voci (emerse leggendo `onboarding_screen.dart` il 2026-07-26, mentre si
rendeva il test in-app il metodo consigliato) sono state chiuse il **2026-07-27**: il
profilo salvato dal quiz ora registra confidence e sorgente reali.

- [x] **`confidence` non è più hardcoded a 80**: nuovo modulo di dominio
  `lib/domain/personality_systems/mbti/mbti_confidence.dart`
  (`confidenceFromAxisBalance`) che misura quanto sono **netti** gli assi — media della
  distanza dal 50/50, mappata su 50..100: questionario tutto in bilico → 50, tutto deciso
  → 100. Usato dal quiz (breakdown normalizzato) e, tramite
  `confidenceFromDichotomySliders`, dal percorso granulare (slider -100..100). Il tipo
  autodichiarato prende `kSelfDeclaredConfidence = 45`, **sotto** il pavimento
  axis-based: un quiz batte sempre una scelta a occhio, e le tre sorgenti sono finalmente
  distinguibili nel DB.
- [x] **`source` riflette il quiz svolto**: `QuizLength.source` mappa short/medium/long su
  `quizShort`/`quizMedium`/`quizLong`; nuovo `QuizResult` (tipo + lunghezza + breakdown +
  confidence) prodotto da `QuizEngine.evaluate(...)` e restituito da `QuizScreen` al posto
  del solo `MbtiType`. `_saveAndExit` salva `result.confidence`/`result.source` (prima:
  `90` e `quizMedium` fissi, con il commento "Could be more specific").
- [x] **Via d'uscita dalla pagina di avvio del quiz**: `_StartQuizPage` ha un proprio
  pulsante **Indietro** (`l10n.actionBack`) che riporta alla scelta del metodo, dato che la
  bottom bar condivisa è nascosta su quella pagina. Widget test di regressione.
- [x] **Pareggi del `QuizEngine`**: il tie-break resta `>= 0` (ENFP) ma non è più muto —
  `evaluate` su un questionario tutto neutro restituisce confidence 50, il minimo, e il
  comportamento è documentato nel codice e coperto da test.
- [x] **Bug trovato lavorando sul quiz**: `_startQuiz` non azzerava `_isComplete`, quindi
  "Annulla" sui risultati + un nuovo test riportava subito alla pagina risultati con zero
  risposte → profilo ENFP finto a confidence minima. Una riga.
- [!] **`person_edit` riscrive ogni profilo come `manual` e disfa il fix di oggi**:
  `person_edit_screen.dart:160` passa `source: ProfileSource.manual` fisso e
  `confidence: _mbtiConfidence` (il valore *caricato* dal profilo esistente), e il blocco
  gira a ogni salvataggio perché la guardia è solo `if (_mbtiType != null)` e `_mbtiType`
  viene inizializzato dal profilo esistente. Quindi: fai il test lungo (`quizLong`,
  confidence 93) → apri la scheda per cambiare il **nickname** → salvi → il profilo diventa
  `manual` con confidence 93, cioè un tipo "autodichiarato" che millanta la certezza di un
  quiz. Al secondo salvataggio la provenienza del quiz è persa per sempre. Riscrivere
  `source`/`confidence` solo se il tipo è stato davvero cambiato a mano.
- [ ] **La fedeltà dell'evidenza si ferma alla confidence**: `MbtiProfile.fromType` fissa
  `dichotomies` a ±70 e i pesi funzione a `[90,70,45,25]` per **ogni** sorgente, quindi il
  breakdown del quiz e la posizione reale degli slider granulari vengono buttati via nel
  campo `data`. Un J/P al 51/49 e uno al 95/5 sono indistinguibili in DB, e la confidence
  (2026-07-27) è oggi l'unica traccia di quell'evidenza. Salvare le dicotomie reali quando
  il metodo le conosce. È il prerequisito della schermata di confronto e del livello
  per-funzione qui sotto.
- [ ] **Copy sbagliata sulla scelta della lunghezza del quiz** (`quiz_screen.dart:73-81`):
  l'AppBar usa `mbtiSourceQuizShort` ("Test breve") — con il commento-appunto
  `// Or a generic title` — su una pagina che offre tutte e tre le lunghezze, e il titolo
  interno riusa `onboardingChooseMethod` ("Come vuoi inserire la tua personalità?"), che
  parla del metodo, non della durata. Servono due stringhe l10n nuove (IT+EN).
- [ ] Implementare la sorgente `ProfileSource.granular` (assessment per funzione, non solo
  per asse). Nota: il percorso granulare **funziona già** a livello di asse
  (`_deriveTypeFromDichotomies` deriva il tipo dai 4 slider); manca solo il livello per
  singola funzione cognitiva.
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

- [x] **Blocco risolto (2026-07-26): la PWA è online.** Scelta la via (a): repo reso
  **pubblico**, poi Settings → Pages → Source = "GitHub Actions" (`has_pages: true`) e
  deploy lanciato a mano con `workflow_dispatch`. Run verde (build 1m58s + deploy 10s).
  Verificato lato server: `index.html` 200 con `<base href="/Archetypes/">` corretto,
  `main.dart.js` 3.98 MB, `sqlite3.wasm` 731 KB, `manifest.json` + service worker, asset di
  contenuto e quiz tutti 200. **URL: https://ventus2202.github.io/Archetypes/**
  (Nota: `assets/AssetManifest.json` dà 404 ma è atteso, Flutter recente usa
  `AssetManifest.bin.json`.) Testo storico del blocco:
- [ ] ~~**Blocco: la PWA dà 404 perché il repo è privato**~~. Scoperto in sessione (2026-07-25):
  `https://ventus2202.github.io/Archetypes/` risponde "There isn't a GitHub Pages site here"
  perché `Ventus2202/Archetypes` è **privato** e GitHub Pages sul piano gratuito pubblica
  solo da repo **pubblici** (confermato: la pagina del repo dà 404 anche senza login → il
  deploy step del workflow fallisce). Prima del setup Pages va **decisa** una via:
  - **(a) rendere il repo pubblico** — sicuro: audit in sessione, nessun segreto committato
    (le credenziali Cloudflare vivono solo nei `wrangler secret`, nessun `.env`/token nei
    file). Poi Settings → Pages → Source = "GitHub Actions".
  - **(b) hosting alternativo** compatibile con repo privati (Cloudflare Pages / Netlify /
    Vercel; build `flutter build web --release`, output `build/web`). Cloudflare Pages
    chiuderebbe anche la nota COOP/COEP del backlog (header per wasm/OPFS).
- [x] **Web + PWA deploy automatico su GitHub Pages** (`.github/workflows/deploy-web.yml`):
  ogni push su `main` builda e pubblica l'app; update automatico per tutti al reload,
  installabile sulla home (manifest + service worker). Build verificato in locale con
  `--base-href "/Archetypes/"`.
  - [x] **Setup una tantum su GitHub**: fatto il 2026-07-26. Source = "GitHub Actions",
    primo deploy verde. URL: `https://ventus2202.github.io/Archetypes/`.
- [ ] **La chat è disattivata nel build web pubblicato**: `CHAT_PROXY_URL` si passa via
  `--dart-define` a build time e `deploy-web.yml:49` non lo fa, quindi
  `ChatClient.isConfigured` è `false` sulla PWA. Aggiungere il define al workflow (URL del
  Worker da GitHub secret/variable) oppure documentare che la chat è solo su build locali.
- [ ] **Action GitHub su Node 20 deprecato**: i run segnalano che `actions/checkout@v4`,
  `actions/upload-artifact@v4` e `actions/deploy-pages@v4` girano forzate su Node 24.
  Non rompe nulla ora; alzare a `@v5` prima che la forzatura sparisca.
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
- [ ] **`CLAUDE.md` e `README` sbagliano sul perché i generatori sono obbligatori**: dicono
  "Steps 3-4 are **mandatory** — the project will not compile without the generated
  `.g.dart` and `app_localizations.dart` files", ma quei file sono committati (verificato il
  2026-07-27), quindi un clone fresco compila anche senza eseguirli. Il motivo vero è
  restare in pari con le sorgenti dopo aver toccato `.arb`/schema. Correggere il testo — o,
  se si sceglie la via (b) della voce in Epica 1 (generati in `.gitignore`), la frase
  diventa vera e non serve toccarla.
- [ ] Allineare `README` e `CLAUDE.md` quando cambia l'architettura.
- [x] **`CLAUDE.md` disallineato sullo schema DB**: diceva `schemaVersion` "currently `2`"
  e citava solo la migration v1→v2 (`shareId`), ma lo schema reale è **v3**
  (`app_database.dart:96`). Aggiornato a v3 con entrambi gli step (v1→v2 `shareId`,
  v2→v3 `avatarBytes`) e la nota che `persons.avatarPath` è legacy.

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
- [x] **Compressione/limite peso avatar**: nuovo helper Dart puro
  `lib/core/media/avatar_codec.dart` (`compressAvatar`, `package:image` ^4.9.1) che
  ridimensiona a 512px il lato lungo (aspect ratio preservato) e ricomprime in JPEG q80;
  chiamato in `person_edit_screen._pickAvatar` dopo `readAsBytes()`. Web-safe (niente
  `dart:io`), robusto (decode in `try/catch` → su byte corrotti/indecodificabili restituisce
  l'input invariato; tiene il più piccolo tra JPEG e originale). Test
  `test/core/media/avatar_codec_test.dart` (4: JPEG+cap landscape, cap portrait, no-op su
  immagine già piccola, input non decodificabile). Un PNG da centinaia di KB scende a decine.
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

- Messaggi d'errore user-friendly + logging/crash-reporting: la schermata `_GateError`
  (`app.dart`) stampa la stringa d'eccezione grezza all'utente e nessun errore viene loggato.
  Valutare copy amichevole + un minimo di observability.
- Ricerca/filtro persone nella lista.
- Statistiche aggregate (distribuzione tipi nella propria rete).
- Note vocali / allegati sugli eventi.
- Export PDF di un profilo o di un team.
- Sincronizzazione cloud opzionale (E2E) al posto del solo backup ZIP.
- Widget home / quick actions.
- Modalità "confronto" fianco a fianco tra due persone.
- Onboarding con import diretto da codice condiviso.
- `.gitattributes` per normalizzare i fine-riga (LF nel repo) ed evitare gli avvisi
  LF→CRLF su Windows. (Confermato il 2026-07-26: l'avviso è comparso su **ogni** file di
  **ogni** commit della sessione. È rumore costante, non un caso isolato.)
- **Walkthrough end-to-end sulla PWA da telefono**, ora che è online: onboarding completo →
  aggiungi persona → grafo → quiz → export/import del backup. Finora la PWA è verificata
  solo lato server (HTTP 200 sui file giusti + stringhe presenti nel bundle); nessuno ha
  mai percorso l'app intera su un dispositivo reale.
- **Documentare il setup di sviluppo** in `CLAUDE.md` (sezione "Fresh PC Setup"): aprire
  Claude Code su `Archetypes/` (non sulla cartella genitore) perché è lì che stanno
  `.claude/` e `.mcp.json`, e fare `gh auth login` — senza, le query sulle GitHub Actions
  ricadono sull'API pubblica e si vedono solo gli esiti degli step, non i log dei job.
- Verifica su come i widget test possono sostituire lo screenshot: in questa sessione la
  pane del browser non era visibile, quindi il compositing non partiva e gli screenshot
  andavano in timeout. Il ripiego (`onboarding_method_widget_test.dart`) asserisce sulla
  **geometria renderizzata** — `tester.getCenter(...)` per verificare che un badge stia
  sulla card giusta e che l'ordine verticale sia quello atteso. Vale la pena adottarlo come
  pattern per le verifiche UI: è più solido di uno screenshot e non richiede la pane.
- **Il profilo MBTI si scrive in tre posti diversi**, ognuno con le sue regole su
  `confidence` e `source`: `onboarding._save`, `QuizScreen._saveAndExit` e
  `person_edit._save`. È la causa diretta delle divergenze trovate (i due `[!]` chiusi il
  2026-07-27 più quello nuovo su `person_edit`). Nell'onboarding i primi due si coordinano
  per un dettaglio implicito: `QuizScreen` non salva perché `getSelf()` è ancora `null`, e
  se un giorno l'onboarding creasse la persona *prima* del quiz si otterrebbero due
  scritture. Valutare un unico punto che scriva un profilo MBTI (repo o funzione di dominio)
  con le regole di confidence/source in un posto solo.
- **Mostrare la confidence all'utente**: ora che è un numero reale (2026-07-27) e non 80
  fisso, vale mostrarla dove conta — sulla schermata risultati del quiz ("tipo netto" vs
  "in bilico su J/P") e nel dettaglio persona. Oggi la si vede solo nel dialog di import di
  un codice condiviso e nello slider di `person_edit`. Da fine sessione 2026-07-27 la cosa
  pesa di più: il badge "Più accurato" sul test completo **promette** una precisione
  maggiore che poi nessuna schermata mostra all'utente.
- **Il badge a pillola è duplicato**: stesso `Container` (alpha 38, radius 999, `labelSmall`
  w600) in `_MethodCard` (`onboarding_screen.dart`) e in `_LengthCard`
  (`quiz_screen.dart`). Due copie si tollerano; alla terza estrarre un piccolo widget
  condiviso invece di ricopiarlo.
- **`confidenceFromAxisBalance` usa la media, non l'asse peggiore**: 3 assi netti + 1 in
  perfetto pareggio danno 88, mentre la lettera in bilico resta un lancio di monetina. È
  documentato come "quanto sono netti gli assi", non come probabilità che il tipo sia
  esatto. Se serve la seconda semantica, passare al prodotto delle certezze per asse.
- **Default `confidence` a 80 nel DB**: `app_database.dart:31` ha ancora
  `withDefault(const Constant(80))`, ereditato da quando tutto era 80. Nessuno scrive più
  profili senza confidence esplicita, quindi è solo un valore fantasma: valutare se
  abbassarlo o togliere il default.
- `CareerFit.calculate` fa `.clamp(0.0, 100.0)` su un punteggio che può essere negativo
  (le preferenze di dicotomia non soddisfatte sottraggono). Più ruoli pessimi possono
  quindi appiattirsi tutti su 0.0 e diventare indistinguibili nel ranking. Da verificare
  con dati reali se succede davvero, e in caso normalizzare invece di troncare.
- Cross-origin isolation su GitHub Pages: senza header COOP/COEP, drift wasm usa il
  fallback IndexedDB invece di OPFS. Valutare un hosting che imposti gli header se
  servono performance/OPFS.
- Verifica manuale end-to-end del fix avatar su web (dev server `web` su :8080): aggiungi
  persona → scegli immagine → controlla che compaia nel grafo e nel dettaglio, e che
  sopravviva a un export/import di backup.
- Compressione avatar off-thread: `compressAvatar` (`core/media/avatar_codec.dart`, sessione
  2026-07-25) decodifica + ridimensiona sul **main isolate**. Su mobile il picker pre-riduce
  a 512px quindi è rapido, ma su web `image_picker_for_web` non ridimensiona in modo
  affidabile → una foto full-res arriva intera a `decodeImage`+resize sul main thread,
  possibile jank sul pick. Valutare un cap dimensionale prima del decode (o `compute`, che su
  web resta comunque sul main). Collegato: `package:image` include tutti i decoder (li prova
  in `decodeImage`), quindi non è tree-shakeable → verificare l'impatto sul bundle web della PWA.
- Verifica manuale del **backup a runtime** (il round-trip byte/ZIP è coperto dai test, ma
  la UI no): su **web** esporta → controlla che il browser scarichi lo `.zip` → reimportalo;
  su **mobile** verifica la share sheet (`XFile.fromData`) in export e `pickFiles(withData:
  true)` in import. È il caveat lasciato aperto dal fix del 2026-07-23.
- ~~Layout repo~~ **risolto il 2026-07-26**: `.claude/` spostata dentro `Archetypes/`, che
  ora è la root da aprire in Claude Code. Conseguenze: (1) i 3 server MCP in `.mcp.json`
  (dart, context7, github) finalmente si caricano — stavano un livello sotto la root e non
  venivano mai letti, non era un problema di approvazione come annotato il 22/07;
  (2) `launch.json` non ha più il wrapper `cmd /c "cd /d ..."`, chiama `flutter` diretto;
  (3) `.claude/launch.json` e `.mcp.json` sono versionati, `settings.local.json` è in
  `.gitignore` perché è per-macchina. Resta fuori dal repo solo `GEMINI.md` (vuoto) nella
  cartella genitore.

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
- 2026-07-24 — Epica 1: fix `_AppGate` (`app.dart`). Il ramo `error:` non mostra più
  silenziosamente la HomeShell su errore reale di `getSelf()`; nuova `_GateError` con
  messaggio + **Riprova** (`ref.invalidate`), stringa l10n `retry` IT/EN, `flutter gen-l10n`
  rigenerato. Widget test `test/widgets/app_gate_widget_test.dart` (2 test) sul vero
  `ArchetypesApp`. `flutter analyze` pulito sul codice toccato (resta 1 `info`
  `unnecessary_import` preesistente in `data_backup_service_test.dart`), 41 test verdi (39→41).
- 2026-07-25 — Epica 9: **compressione avatar**. Aggiunto `package:image` (^4.9.1) e helper
  Dart puro `core/media/avatar_codec.dart` (`compressAvatar`): resize a 512px + JPEG q80,
  web-safe, decode in `try/catch`. Collegato in `person_edit_screen._pickAvatar`. Warm-up
  Epica 1: rimosso l'`unnecessary_import` in `data_backup_service_test.dart` → analyze di
  nuovo pulito. Verifiche: `flutter analyze` pulito, 45 test verdi (41→45, +4 avatar codec).
- 2026-07-26 — Epica 1: **copertura test dei motori + bug del chatbot**. Nuovo
  `test/data/chat/chat_tool_executor_test.dart` (14 test su DB in-memory con repo reali:
  tutti e 7 i tool, id come stringa, path d'errore); estesi `career_fit_test` (invarianti di
  `calculateAll` su tutti e 16 i tipi) e `team_optimizer_test` (limiti, ordinamento,
  must-include). Il test must-include ha scoperto un bug reale: `must_include_id` era
  applicato come filtro *post* `findBest` sulle sole top-3, con fallback muto → "un team con
  me" restituiva team senza l'utente (sempre, sul percorso greedy >12 candidati). Fix: il
  vincolo è ora dentro `TeamOptimizer.findBest` (`mustIncludePersonId`), con errore esplicito
  se la persona non è tra i candidati. Epica 8: `CLAUDE.md` allineato allo schema DB v3.
  Verifiche: `flutter analyze` pulito, 67 test verdi (45→67).
- 2026-07-26 — Epica 7 `[!]` **chiusa: la PWA è online**. Repo reso pubblico, Pages abilitato
  con Source = "GitHub Actions", primo deploy verde su
  https://ventus2202.github.io/Archetypes/ (verificato via HTTP: index + base-href,
  `main.dart.js`, `sqlite3.wasm`, manifest, service worker, asset di contenuto). Emersi due
  item nuovi: chat disattivata nel build web (manca `--dart-define` nel workflow) e action
  su Node 20 deprecato. Epica 5 (UI): l'onboarding ora **consiglia il test in-app** — card
  in cima, badge "Consigliato", preselezionata; gli altri metodi restano a un tap. Nuova
  stringa `onboardingMethodRecommended` IT/EN + widget test sulla geometria renderizzata
  (3 test). Verifiche: analyze pulito, 70 test verdi (67→70). Pushate su `main` tutte le
  sessioni arretrate (24/07, 25/07, 26/07), che erano rimaste solo in locale. CI e deploy
  verdi sul push; verificato che il bundle pubblicato contenga la stringa "Consigliato".
- 2026-07-26 — Backlog: **layout repo sistemato**. `.claude/` spostata in `Archetypes/`,
  che diventa la root di lavoro. Sblocca i 3 server MCP di `.mcp.json` (mai caricati finora
  perché stavano sotto la root), toglie il wrapper `cmd /c` da `launch.json` e mette la
  config di sviluppo sotto version control. Serve riaprire Claude Code su `Archetypes/`.
- 2026-07-26 — Chiusura sessione: aggiunte alla roadmap le voci emerse leggendo il codice
  durante il lavoro sull'onboarding. Due `[!]` in Epica 5 (`confidence` hardcoded a 80 per
  ogni sorgente, `source` sempre `quizMedium`) che svuotano di significato la scelta appena
  fatta di consigliare il quiz; più il vicolo cieco della pagina di avvio quiz e il
  tie-break implicito verso ENFP. Nel backlog: walkthrough reale da telefono, setup di
  sviluppo da documentare, pattern dei widget test sulla geometria, dubbio sul clamp di
  `CareerFit`.
- 2026-07-27 — Epica 5: **chiusi i due `[!]`, il profilo salvato dal quiz ora dice la
  verità**. Nuovo `domain/personality_systems/mbti/mbti_confidence.dart`
  (`confidenceFromAxisBalance` + `confidenceFromDichotomySliders`,
  `kSelfDeclaredConfidence = 45`); `QuizLength.source` + `QuizResult` +
  `QuizEngine.evaluate(...)`, restituito da `QuizScreen` al posto del solo `MbtiType`;
  `onboarding._save` calcola confidence e source dal metodo che ha davvero prodotto il tipo
  (prima: `80` e `quizMedium` fissi). Chiusi nello stesso giro il tie-break muto (ora
  confidence 50 = segnale) e il vicolo cieco della pagina di avvio quiz (pulsante
  **Indietro**). Trovato e corretto un bug non in roadmap: `_startQuiz` non azzerava
  `_isComplete` → retake dopo "Annulla" mostrava risultati vuoti. Verifiche: `flutter
  analyze` pulito, 83 test verdi (70→83, +13: 9 su `mbti_confidence`, 3 su
  `QuizEngine.evaluate`/source, 1 widget test sull'uscita dal quiz).
- 2026-07-27 — Epica 5 (UI): badge **"Più accurato"** (`quizMostAccurate` IT/EN) sulla card
  del test completo nella scelta della lunghezza del quiz — è l'unica lunghezza che può
  arrivare in cima al range di confidence introdotto oggi, e prima l'utente doveva dedurlo
  dal numero di domande. `_LengthCard` accetta un `badge` opzionale come `_MethodCard`.
  Nuovo `test/widgets/quiz_length_widget_test.dart` sulla geometria renderizzata.
  Verifiche: analyze pulito, 84 test verdi (83→84).
- 2026-07-27 — Chiusura sessione: aggiunte le voci emerse leggendo il codice attorno al
  quiz. Un `[!]` nuovo in Epica 5 — `person_edit` riscrive **ogni** profilo come `manual`
  tenendo la confidence del quiz, quindi al primo salvataggio della scheda persona il fix di
  oggi è già disfatto; più la fedeltà dell'evidenza (`MbtiProfile.fromType` appiattisce
  dicotomie e pesi funzione a valori fissi) e la copy sbagliata sulla scelta della lunghezza
  del quiz. In Epica 1: nessun test rilegge un profilo dal DB dopo un quiz (il fix di oggi è
  coperto solo a livello di engine) e `_save()` senza `try/catch` lascia lo spinner infinito.
  Nel backlog: il profilo MBTI si scrive in tre posti diversi con tre regole diverse, che è
  la causa comune di tutte queste divergenze. Dopo il badge, verificato con `git ls-files`
  che il **codice generato è committato** mentre la CI lo rigenera: una rigenerazione
  dimenticata passa verde (Epica 1) e la frase "the project will not compile without" in
  `CLAUDE.md`/`README` è falsa (Epica 8). Chiarito anche il perimetro del blocco sui test
  widget: solo le schermate con `.watch()`, non tutte.
- 2026-07-23 — Epica 9 `[!]`: **backup/restore ora funziona nella PWA**. `DataBackupService`
  passa a byte puri (`exportToBytes`/`importFromBytes`), niente più `dart:io`/`path_provider`,
  `archive_io` → `archive`. Nuovo helper download browser a import condizionale
  (`core/platform/file_download*.dart`, Blob+anchor su `package:web`), perché
  `file_picker.saveFile` non esiste su web. `settings_screen` fa branch web/nativo per export
  e usa `withData:true` + `.bytes` per import. `web` promosso a dep diretta. Chiusi anche il
  test end-to-end di `DataBackupService` (Epica 1) e l'audit `dart:io` (Epica 9). Verifiche:
  analyze pulito, 39 test verdi (2 nuovi), **build web release OK** (wasm dry-run OK).
