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
  Precisato ancora il 2026-07-28: a bloccare è **sottoscriversi** allo stream, non toccarlo.
  `PersonEditScreen` fa `ref.invalidate(allPersonsProvider)` (uno `StreamProvider` su
  `watchAll()`) e pompa lo stesso senza problemi, perché in test nessuno lo ascolta. Quindi il
  criterio per sapere se una schermata è testabile è "la watcha nel `build`?", non "la nomina?".
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
  commit con i diff dei generati (3 file il 2026-07-27, di nuovo gli stessi 3 il 2026-07-29 e
  ancora il 2026-08-02: è un costo ricorrente, non un caso isolato). Quantificato il 2026-08-02
  con `git log --name-only` su `app_localizations.dart`: compare in **ogni** commit che abbia mai
  toccato una `.arb`, cioè il churn non è un effetto delle sessioni recenti ma la norma da sempre.
  Scegliere una politica:
  (a) tenerli committati e aggiungere `git diff --exit-code` dopo i due generatori in CI,
  così una rigenerazione dimenticata rompe la build; (b) metterli in `.gitignore` e
  affidarsi ai generatori in setup/CI. Vedi la voce collegata in Epica 8.
- [x] **Nessun test legge un profilo dal DB dopo un quiz** — chiuso il 2026-07-28. Nuovo
  `test/widgets/profile_provenance_widget_test.dart`: pompa il vero `QuizScreen` su un DB
  in-memory, risponde a tutte le domande del test breve *contro* la `direction` di ciascuna
  (metà sono reverse-scored: rispondere "5" a tutto è un pareggio perfetto su ogni asse) e
  rilegge la riga dal DB → tipo `ISTJ`, `source = quizShort`, `confidence = 100`. Il tipo
  atteso è volutamente diverso dall'ENFP del tie-break, così un engine che degenera non passa.
- [x] **`_save()` senza gestione errori nell'onboarding e in `person_edit`** — chiuso il
  2026-07-28: entrambi ora avvolgono il corpo in `try/catch` con snackbar `errorGeneric`
  (stringa già esistente, niente nuova l10n). `person_edit` rimette `_loading = false` nel
  `finally`; l'onboarding lo fa solo nel `catch`, perché in caso di successo è il gate a
  smontare la schermata e riabilitare il pulsante nel frattempo sarebbe sbagliato.
- [x] **La cache di `ContentRepository` serviva il contenuto nella lingua sbagliata dopo un
  cambio di lingua** — chiuso il 2026-07-29. I quattro contenuti (`_cache` mbti,
  `_dynamicsCache`, `_careerCache`, `_teamCache`) avevano cache separate ma **un solo**
  `_loadedLocale` condiviso, sovrascritto da ogni loader con la propria lingua: bastava che un
  loader girasse in EN perché la guardia `_cache != null && _loadedLocale == languageCode`
  diventasse vera anche per una cache riempita in IT (app in IT → schede MBTI → passa a EN →
  Career fit → riapri le schede MBTI e ricevi il testo italiano). Fix: `_loadedLocale` sparisce
  e ogni contenuto ha una `Map<String, T>` **indicizzata per locale risolto**, quindi la lingua
  è parte della chiave e non uno stato globale; come effetto collaterale alternare due lingue
  non ricarica più nulla, e le lingue non supportate condividono la voce `en`. Rimosso
  `invalidateCache()`, che era codice morto (mai chiamato in `lib/`) e ora è anche inutile.
- [x] **I loader di contenuto inghiottivano ogni errore, e non in modo coerente** — chiuso il
  2026-07-29 insieme al punto sopra. `loadDynamicsContent`, `loadCareerRolesContent`,
  `loadTeamObjectivesContent` e `loadQuizQuestions` avevano un `catch (_)` che restituiva
  contenuto vuoto, mentre `loadMbtiContent` lasciava propagare. Politica scelta: **il
  repository propaga**, i chiamanti mostrano un errore esplicito — la stessa linea di
  `_AppGate`, della schermata quiz e di `content_viewer` (l'unico consumatore già corretto).
  Chiamanti adeguati: Career fit passa da `!snap.hasData` (che con la propagazione avrebbe
  girato all'infinito) a `connectionState`/`hasError` → `errorNotFound`; `person_detail` non
  avvolge più il caricamento nel `catch` che faceva sparire in silenzio l'intera sezione
  affinità, e mostra una riga d'errore (il `catch` resta solo sul profilo self illeggibile);
  `QuizScreen._startQuiz` converte l'eccezione nella lista vuota che la schermata già sa
  renderizzare come errore. In Team builder il `FutureBuilder` su `loadTeamObjectivesContent`
  è stato **rimosso**: il contenuto caricato non veniva mai letto (tutte le etichette vengono
  da `l10n`), quindi bloccava i risultati su un asset che non usa. Nuovo
  `test/data/repositories/content_repository_test.dart` (11 test, con un `AssetBundle` finto:
  4 sulla cache per locale — incluso il sequenza esatta del bug — e 7 sulla propagazione).
- [x] **Tre dei quattro asset di contenuto non erano nel bundle: in app costruita non
  esistevano** — trovato e chiuso il 2026-07-30 lavorando sul Team builder. `pubspec.yaml`
  elencava `assets/content/it/mbti.json` e `assets/content/en/mbti.json` **file per file**,
  quindi `career_roles.json`, `relationship_dynamics.json` e `team_objectives.json` — presenti
  nel repo, letti dal repository, citati in `CLAUDE.md` — non venivano mai copiati nel bundle.
  Verificato su `build/web` prima del fix: sotto `assets/assets/content/it/` c'era **solo**
  `mbti.json`. Effetto in produzione: `loadCareerRolesContent` e `loadDynamicsContent`
  falliscono sempre, quindi dal 2026-07-29 (loader che propagano) **Career fit mostra
  "Contenuto non trovato" e la sezione affinità di `person_detail` una riga d'errore, sulla PWA
  live**; prima di quel cambio degradavano in silenzio (chiavi grezze e descrizioni vuote), che
  è il motivo per cui nessuno se n'era accorto. Fix: `pubspec.yaml` dichiara le **directory**
  `assets/content/it/` e `assets/content/en/`, come già faceva per il quiz. Verificato con
  `flutter build web --release`: gli otto file ora sono in `build/web`. Nuovo
  `test/assets/content_assets_test.dart` (8 test): carica tutti e quattro i contenuti in IT e
  EN **attraverso `rootBundle`** — è l'unico modo di accorgersi di un asset non dichiarato, un
  test sui file JSON non lo vedrebbe — e verifica che le chiavi combacino con quelle che i
  motori emettono (16 tipi, 8 funzioni, 6 obiettivi con `title`/`description`/`ideal_profile`,
  8 `strength_*` + 8 `blindspot_*`). Nota: la verifica del 2026-07-26 sulla PWA ("asset di
  contenuto e quiz tutti 200") aveva evidentemente toccato solo `mbti.json`.
- [x] **La lista candidati del Team builder crashava a runtime** — trovato il 2026-07-30 dal
  primo widget test sulla schermata, chiuso subito. `_CandidateList.persons` era dichiarata
  `List<dynamic>`, quindi `p.displayName.characters.first` era una chiamata **dinamica** a un
  metodo di estensione: le estensioni si risolvono solo staticamente, quindi a runtime è
  `NoSuchMethodError: Class 'String' has no instance getter 'characters'`. Con una persona in
  rubrica la lista era un riquadro d'errore, sempre, anche in release — e `flutter analyze`
  non può vederlo perché su `dynamic` non c'è niente da controllare. Fix: tipizzare
  `List<Person>` (il chiamante già passava un `List<Person>`). Le altre tre schermate che usano
  `.characters` (graph, people_list, person_detail) hanno il ricevitore tipizzato e sono sane.
- [ ] Verificare il **primo run** di CI e del deploy Pages su GitHub; se il pin
  `flutter-version: 3.41.9` non si risolve nell'action, allentare a solo `channel: stable`.
- [x] **Attivato il lint `avoid_dynamic_calls`** — chiuso il 2026-07-31. Era l'unica difesa
  automatica contro la classe di bug trovata il 2026-07-30 (`List<dynamic>` + metodo di
  estensione = crash a runtime con `analyze` verde). Le 22 violazioni misurate erano tutte
  indicizzazioni con ricevitore `dynamic`, quindi innocue oggi ma indistinguibili da quella
  fatale: azzerate **tipizzando**, non con un `ignore_for_file`. In `lib/`: `career_fit_screen`
  legge la voce del ruolo come `Map<String, dynamic>?` invece che come `dynamic`;
  `person_detail` passa da sei letture dinamiche a un helper `_entry(section, key)` che fa il
  cast una volta sola (le sei `replaceAll('_title','')` sono sparite con il fix del contratto
  qui sotto). In `test/data/chat/chat_tool_executor_test.dart` le tredici violazioni erano tutte
  elementi di liste uscite da `jsonDecode`: un helper `rows(value)` che fa
  `.cast<Map<String, dynamic>>()` una volta le chiude tutte. Regola accesa in
  `analysis_options.yaml` con il commento che spiega da quale bug arriva; `flutter analyze`
  pulito.
- [x] **Il contratto delle chiavi di `relationship_dynamics` è uno solo** (voce arrivata dal
  backlog, chiusa nello stesso giro il 2026-07-31). Il motore emetteva `conflict_ne_si_title` e
  `conflict_ne_si_desc` mentre il JSON è indicizzato `conflict_ne_si` con dentro `title` e
  `description`: `person_detail` ricuciva i due contratti con sei `replaceAll('_title', '')`.
  Scelto il lato del motore: `FrictionPoint`, `GrowthArea` e `CommunicationTip` hanno ora un
  solo campo `contentKey` con la chiave nuda (prima due campi, di cui `descriptionKey` mai
  usato dalla UI). Sei `replaceAll` in meno e sei delle nove violazioni di `avoid_dynamic_calls`
  in `lib/` sparite di conseguenza.
- [x] **`content_assets_test` esteso alle chiavi di career e dynamics** — chiuso il 2026-07-31.
  Il test del 2026-07-30 verificava riga per riga solo `mbti.json` e `team_objectives.json`; per
  gli altri due si fermava a "non vuoto", mentre entrambe le schermate risolvono con
  `?? key`/`?? ''`, quindi un id rinominato ricompare a schermo come chiave grezza o come
  descrizione vuota, in silenzio. Ora il test parte dalle **sorgenti delle chiavi**, non da una
  lista copiata: i 16 `id` di `kCareerRoles` (con `title`/`description`/`why_fit`), i valori di
  `RelationshipDynamics.kFunctionConflicts`, gli 8 `growth_<funzione>` costruiti da
  `CognitiveFunction.values` e i valori di `kCommunicationPatterns` più `comm_default`. Nuovo
  helper `expectEntry` che pretende anche stringhe **non vuote** — una voce presente ma vuota si
  legge a schermo esattamente come una mancante — usato anche dal test degli obiettivi, che
  prima controllava solo il tipo. Verificato con una sonda usa-e-getta (rimosso `comm_default` e
  svuotato una `description` nell'asset IT): il test fallisce con il nome della chiave rotta.
- [x] **`data_backup.dart` passava `dynamic` dritto dentro i costruttori tipizzati: 44 errori su
  81 di tutto il repo** — chiuso il 2026-07-31. Misurato il giorno prima accendendo in via
  temporanea `strict-casts` + `strict-raw-types` + `strict-inference` (la difesa che sta un
  gradino sopra `avoid_dynamic_calls`: quella scatta al **punto di chiamata**, queste al punto di
  assegnazione): 81 diagnostiche in tutto, ma **44 tutte nello stesso file**, tutte
  `argument_type_not_assignable`, cioè ogni campo letto dal JSON di un backup entrava in un
  parametro `int`/`String`/`bool` senza un cast che lo verificasse. In pratica il **restore non
  validava niente**: un backup vecchio o manomesso esplodeva in `TypeError` a metà import senza
  dire quale campo — ed è lo stesso file che portava il primo bug della roadmap. Fix: la
  deserializzazione passa per un gruppo di lettori tipizzati (`_int`, `_string`, `_bool`, `_date`,
  `_bytesOrNull`, `_object`, `_rows`) che controllano il tipo e sollevano una
  `BackupFormatException` con il **percorso** del valore rotto — `persons[2].createdAt is
  missing`, `profiles[0].confidence expected a number, found String` — e l'indice della riga viene
  dal loop, quindi indica davvero quale. Stesso trattamento per i tre punti che prima
  propagavano eccezioni grezze (ZIP illeggibile, `data.json` assente, JSON non valido) e per il
  controllo di `schemaVersion`, che ora dice quale versione ha trovato. Trovato lavorandoci e
  corretto: con `replace: true` la cancellazione stava in una **transazione separata** da quella
  degli insert, quindi un errore a metà scrittura lasciava il DB vuoto senza nulla dentro; ora
  cancellazione e inserimento sono un'unica transazione. 13 test nuovi: sette sui lettori
  (`data_backup_test.dart`: campo mancante, tipo sbagliato, data non parsabile, base64 corrotto,
  riga non-oggetto, sezione top-level assente, indice della riga rotta) e cinque sul servizio
  (`data_backup_service_test.dart`: byte non-ZIP, ZIP senza `data.json`, JSON invalido, backup più
  nuovo dell'app, e quello che conta davvero — `replace: true` su un backup malformato **non**
  svuota il DB esistente).
- [x] **`strict-casts` acceso stabilmente** — conseguenza diretta della voce sopra, stesso giorno.
  Tolti i 44 cast del backup, le tre opzioni `strict-*` scendono da 81 a 50 diagnostiche e
  **`strict-casts` da solo dà "No issues found"** su tutto il repo: quindi non è più una misura
  temporanea, è in `analysis_options.yaml` con il commento che spiega da quale bug arriva. È la
  difesa al punto di **assegnazione**, il gradino sopra `avoid_dynamic_calls` che scatta solo al
  punto di chiamata. Le 50 restanti vengono tutte dalle altre due opzioni e sono rumore, non
  rischio: 30 letterali di collezione senza tipo (quasi tutti nei test), 15 `new` senza argomenti
  di tipo, 3 tipi raw, 2 invocazioni — nessuna `argument_type_not_assignable` rimasta. Quelle due
  restano spente.
- [ ] **Il restore ignora il `schemaVersion` che il backup si porta dietro.** Emerso il
  2026-07-31 scrivendo i lettori tipizzati: il campo viene letto solo per rifiutare un backup
  **più nuovo** dell'app, mentre il parsing è uno solo, con un'unica lista di campi obbligatori,
  identico per un backup v1 e per uno v3. Che i backup vecchi si aprano ancora è un accidente
  fortunato: le due colonne aggiunte da allora (`shareId` in v2, `avatarBytes` in v3) sono
  entrambe **nullable**, quindi i lettori `*OrNull` restituiscono `null` e nessuno se ne accorge.
  Dal momento in cui una migration aggiungerà una colonna **non** nullable, restaurare un backup
  precedente fallirà con `Invalid backup: persons[0].<campo> is missing` — cioè il fix di oggi,
  che rende esplicito il rifiuto, rende anche esplicito questo limite invece di lasciarlo
  degradare a caso. Stessa cosa per una sezione top-level: `_rows` pretende che `events`,
  `groups`, ecc. ci siano tutte. Da decidere: (a) far guidare i default dal `schemaVersion` letto
  (campo assente + backup più vecchio della colonna → default della colonna, non errore), oppure
  (b) dichiarare la politica "si restaurano solo backup dello schema corrente" e fissarla con un
  test su un fixture d'epoca. Oggi in `data_backup_test.dart` esiste un solo fixture del genere
  (il backup pre-`shareId`), scritto a mano e senza ZIP.
- [x] **Le foreign key non sono attive: `onDelete: KeyAction.cascade` non fa niente** — chiuso il
  2026-08-02. Misurato il 2026-07-31 con una sonda usa-e-getta: `PRAGMA foreign_keys` valeva **0**
  (SQLite le disattiva di default e il progetto non aveva un `beforeOpen` che le accendesse),
  quindi cancellare una persona lasciava in DB il suo profilo, le sue relazioni, le sue
  appartenenze ai gruppi e i suoi eventi, e si poteva inserire un profilo con un `personId`
  inesistente senza errore. Scelto di **accenderle**, non di togliere le `references`: lo schema
  dichiara cinque cascade e l'unico percorso di cancellazione dell'app
  (`person_edit_screen.dart:223`) ci conta sopra. Fix in tre pezzi: (1) `beforeOpen` con
  `PRAGMA foreign_keys = ON` — gira **dopo** `onCreate`/`onUpgrade`, quindi le migration
  continuano a eseguire con i controlli spenti, che è il comportamento voluto; (2) `_purgeOrphans`,
  quattro DELETE idempotenti che spazzano le righe già rimaste orfane — senza, i DB esistenti non
  avrebbero altro modo di ripulirsi, e gli orfani continuerebbero a viaggiare in ogni backup;
  (3) l'import del backup passa da `InsertMode.insertOrReplace` a `insertOnConflictUpdate`.
  Il punto (3) è una **regressione che il fix stesso introduceva**, misurata con una seconda sonda:
  SQLite implementa REPLACE come DELETE + INSERT, quindi con le FK attive un import **in merge** di
  una persona già presente in locale ne cancellava per cascade profilo, relazioni, appartenenze ed
  eventi prima di reinserire solo ciò che il backup si porta dietro (sonda: 1 profilo prima, 0
  dopo). `ON CONFLICT DO UPDATE` riscrive la riga sul posto e non fa scattare niente.
  L'ordine di insert dell'import era già FK-safe (gruppi → persone → profili → relazioni →
  personGroups → eventi) e ora un ordine sbagliato darebbe errore invece di scrivere un orfano.
  Nuovo `test/data/database/foreign_keys_test.dart` (6 test: pragma a 1, cascade su tutte e cinque
  le tabelle figlie, `personId` inesistente rifiutato, ordine di insert dell'import, purge degli
  orfani su DB **file-backed** chiuso e riaperto, e che il purge non tocchi le righe sane) più un
  test di regressione sul merge in `data_backup_service_test.dart`. Entrambi verificati con una
  sonda: senza `beforeOpen` 4 dei 6 falliscono, con `insertOrReplace` il test del merge fallisce.
  Verificato su native (`NativeDatabase`); su web il pragma è quello standard di `sqlite3.wasm` ma
  non è stato eseguito in un browser.
- [x] **I backup esportati finora potevano non essere più importabili, e l'errore era opaco** —
  chiuso il 2026-08-02, la sessione dopo averlo aperto. Il problema, misurato con una sonda subito
  dopo aver acceso le foreign key: un `data.json` che contiene una riga orfana — un profilo il cui
  `personId` non esiste fra le persone del backup — faceva fallire l'import con
  `SqliteException(787): FOREIGN KEY constraint failed`, un codice che non nomina né tabella né
  riga. Non era un caso di laboratorio ma **la conseguenza diretta del bug chiuso lo stesso
  giorno**, che per definizione faceva viaggiare gli orfani in ogni backup: qualsiasi ZIP esportato
  da un DB in cui era stata cancellata una persona ricadeva lì. Scelta la via **(b)**, scartare le
  righe orfane invece di rifiutare l'archivio: è l'unica che rende di nuovo importabili i backup
  già in mano alle persone, ed è la stessa decisione che `_purgeOrphans` prende già all'apertura
  del DB, quindi le due sponde del confine adesso dicono la stessa cosa. Nuovo
  `BackupData.withoutOrphans()` (Dart puro, sul dominio): calcola gli id di persone e gruppi
  presenti **nel backup** e lascia fuori i figli che puntano altrove — profili, entrambi i capi di
  una relazione, entrambi i genitori di un `personGroups`, eventi. Il criterio è "il genitore è in
  questo archivio", non "è nel DB", e vale anche in merge: gli id sono `autoIncrement` **locali**,
  quindi un genitore che esiste già sul dispositivo con lo stesso numero sarebbe una coincidenza
  che attacca la riga a una persona estranea (è la stessa radice della voce di backlog sull'import
  in merge). Della via (a) resta il **vocabolario**: ogni riga scartata è descritta con il percorso
  della politica del 31/07 — `profiles[1].personId points to person 7, missing from this backup` —
  quindi il 787 muto è sostituito da una frase che nomina riga e campo. La via (c) (ripulire in
  `exportToBytes`) è stata scartata perché irraggiungibile: con `_purgeOrphans` a ogni apertura e
  le FK attive, un DB non ha più modo di produrre gli orfani che l'export dovrebbe filtrare.
  Le righe scartate non spariscono in silenzio: `importFromBytes` restituisce un
  `BackupImportReport` e `settings_screen` mostra "Dati importati. Scartate N righe incoerenti"
  invece del solo messaggio di successo (due chiavi ARB nuove IT+EN, `backupImportSuccess` e
  `backupImportSkipped` con plurale ICU; la prima toglie una delle tre stringhe italiane hardcoded
  annotate nel backlog — le altre due, sui percorsi d'errore, restano). 8 test nuovi: 5 su
  `withoutOrphans` (backup sano invariato, profilo orfano scartato e nominato, relazione scartata
  da entrambi i capi, `personGroups` controllato su tutti e due i genitori, i genitori non si
  scartano mai) e 3 sul servizio end-to-end (ZIP con orfani → importa il resto e li elenca, stesso
  ZIP in merge su un DB che ha davvero una persona 7 → li scarta lo stesso, backup sano → report
  pulito). Verificati con una sonda: disattivando `withoutOrphans` i due test sugli orfani
  falliscono, il primo con esattamente `SqliteException(787)`.
- [x] **Scartare le righe orfane aveva un lato tagliente: con "Sostituisci", un archivio senza
  genitori svuotava il DB e la app diceva che era andata bene** — trovato, misurato e chiuso il
  2026-08-02, nella stessa giornata del fix che lo aveva introdotto. La politica "scarta e conta"
  non aveva una soglia,
  quindi è identica che si scarti 1 riga su 100 o il 100% dell'archivio. Il caso peggiore è
  `replace: true` su un `data.json` con la sezione `persons` vuota e i figli popolati (archivio
  troncato o manomesso, non un backup sano): la transazione cancella tutto, non ha genitori da
  reinserire, scarta tutti i figli e **committa** — sonda: 1 persona e 1 profilo prima, 0 e 0 dopo,
  con la snackbar "Dati importati. Scartata 1 riga incoerente". Prima del fix di oggi lo stesso
  archivio dava `SqliteException(787)`, quindi rollback e dati salvi: la via (b) ha **convertito un
  fallimento sicuro in una perdita silenziosa** in questo caso. Sul caso reale — il backup pieno di
  orfani lasciati dalle cascade inerti — la (b) resta giusta, quindi il rimedio non è tornare a
  rifiutare tutto ma mettere una soglia. Delle due candidate è stata scelta **la regola netta**, non
  il rapporto: `BackupData.checkParentSectionsPresent()` rifiuta con `BackupFormatException` — prima
  che la transazione si apra — l'archivio in cui una **intera** sezione genitore è assente mentre
  esistono righe che la richiedono (`persons` vuota con profili/relazioni/appartenenze/eventi
  dentro, oppure `groups` vuota con `personGroups` dentro). L'errore nomina quante righe e in quali
  sezioni: `persons is empty but 3 rows in profiles, events still need a person: the backup looks
  truncated, not merely inconsistent`. Un rapporto (`>50% scartato`) sarebbe stato un numero
  arbitrario da tarare senza dati, e il progetto ne ha già abbastanza; la regola netta non ha
  costanti, non ha falsi positivi e copre il caso misurato. Ha però un buco dichiarato: un archivio
  **parzialmente** troncato (1 persona su 50 e 200 figli) passa e scarta quasi tutto, quindi se un
  giorno emergerà un caso reale di quel tipo il rapporto tornerà sul tavolo con dei dati sotto.
  Confine tenuto esplicito da un test: un backup **completamente** vuoto non è troncato ma
  legittimo, e restaurarlo con `replace` per azzerare l'app continua a funzionare. 7 test nuovi
  (5 di dominio: rifiuto con la sezione persone assente, conteggio su più sezioni, `groups` colto
  per conto suo, backup vuoto che passa, orfani sparsi che restano materia di pruning; 2 sul
  servizio: il caso misurato — `replace: true` + archivio senza genitori → eccezione e le righe
  esistenti ancora lì — e l'azzeramento con backup vuoto che non deve essere inghiottito dal
  rifiuto). Verificato con una sonda: commentando la chiamata, il test del caso misurato torna a
  passare l'import e a svuotare il DB.
- [ ] **Il report dell'import è dettagliato e l'utente ne vede solo il numero.**
  `BackupImportReport.skippedRows` contiene una riga per scarto, con il percorso e il campo
  (`profiles[1].personId points to person 7, missing from this backup`) — cioè esattamente il
  vocabolario che la politica del 2026-07-31 ha introdotto perché un errore dicesse *dove*. Poi
  `settings_screen` ne mostra solo `.length`: "Scartate 2 righe incoerenti", che non permette di
  capire cosa si è perso. Pesa di più dal fix della voce qui sopra: l'archivio *interamente* senza
  genitori ora viene rifiutato con un messaggio esplicito, ma quello **parzialmente** troncato passa
  ancora, e per l'utente è indistinguibile da due orfani innocui — è esattamente il caso in cui il
  dettaglio servirebbe. Il dettaglio esiste già ed è buttato via al confine con la UI. Da decidere dove
  metterlo: un dialog espandibile dopo l'import, oppure il primo consumatore vero della voce di
  backlog sul logging (che oggi non esiste in nessuna forma), dato che è informazione diagnostica
  più che copy per l'utente.
- [x] **`mbti.json` era il contenuto meno verificato dei quattro, e sotto c'erano due bug** —
  chiuso il 2026-08-03. Il test si fermava a "i 16 tipi e le 8 funzioni esistono"; ora
  `content_assets_test` verifica per ogni lingua **i campi che le schede leggono davvero** —
  9 per tipo, 7 per funzione, i 4 assi con i due poli, i marker comportamentali e i miti — con
  la regola del 2026-07-31 (stringhe e liste **non vuote**, perché una voce presente ma vuota si
  legge a schermo come una mancante), e **deriva da `kMbtiStacks`** tutto ciò che il JSON ripete
  del motore (`stack` dei 16 tipi, le quattro liste `*_in` delle 8 funzioni) invece di fissarne
  una copia. **Primo bug, nel contenuto**: `Si.tertiary_in` diceva `[ENTP, ENFP]` invece di
  `[INTP, INFP]` e `Si.inferior_in` diceva `[ENTJ, ENFJ]` invece di `[ENTP, ENFP]`, cioè
  attribuiva Si a due tipi che non ce l'hanno affatto nello stack. **Secondo bug, nel lettore, ed
  è il più grosso**: `content_viewer_screen` leggeva `description` come **lista** mentre l'asset
  la scrive come una stringa con i paragrafi separati da riga vuota, e `poles` come lista mentre
  è un **oggetto** indicizzato per lettera dell'asse → `TypeError` in `build` su **tutte e tre**
  le schede. Due sono raggiungibili da `person_detail` (il badge del tipo e le chip delle
  funzioni cognitive), quindi la scheda MBTI — il contenuto più grosso e più visibile dell'app —
  era rotta in produzione sulla PWA, e `flutter analyze` non poteva vederlo perché il valore esce
  da `jsonDecode` come `dynamic`: è la stessa famiglia del crash del 2026-07-30, con la stessa
  radice (un cast su un `dynamic` che nessuna difesa statica controlla). Misurato **prima** del
  fix con il nuovo `test/widgets/content_viewer_widget_test.dart`, che pompa la schermata vera
  sull'asset vero: `String is not a subtype of List<dynamic>?` per tipo e funzione,
  `_Map<String, dynamic> is not a subtype of List<dynamic>?` per la dicotomia. È il complemento
  necessario del test sull'asset — `content_assets_test` fissa il contenuto, ma solo pompare la
  schermata prende un lettore che si aspetta una forma diversa da quella scritta.
  Verifiche: 171 test verdi (159→171, +12), `flutter analyze` pulito.
- [ ] **Il contenuto arriva alle schermate come `Map<String, dynamic>` e ogni schermata se lo
  casta da sé.** È la lezione strutturale del 2026-08-03 e vale la pena scriverla perché il bug di
  oggi è il **terzo** della stessa famiglia in cinque settimane: 2026-07-30 una chiamata dinamica
  su `List<dynamic>` (crash del Team builder), 2026-07-31 quarantaquattro campi di backup infilati
  nei costruttori senza verifica, 2026-08-03 due cast di forma sbagliata in `content_viewer`. Ogni
  volta la radice è la stessa: un valore che esce da `jsonDecode` come `dynamic` e viene castato
  **al punto d'uso**, dentro un `build`, dove nessuna difesa statica arriva — `avoid_dynamic_calls`
  scatta sulle chiamate, `strict-casts` sulle assegnazioni, ma `data['x'] as List?` è un cast
  esplicito e legittimo per entrambe. Oggi i quattro modelli di `ContentRepository`
  (`MbtiContent`, `RelationshipDynamicsContent`, `CareerRolesContent`, `TeamObjectivesContent`)
  sono involucri attorno a mappe grezze, e le schermate castano: `career_fit_screen:75-83`,
  `person_detail_screen:689-701`, tutto `content_viewer_screen`. Il fix del backup ha già mostrato
  la forma della risposta — lettori tipizzati in **un** posto, che falliscono nominando il percorso
  del campo rotto — e lì ha chiuso la classe intera. Da valutare la stessa cosa per il contenuto:
  parsing in modelli tipizzati nel repository, schermate che ricevono oggetti Dart. Costo da
  soppesare: sono quattro asset con forme diverse e il contenuto cambia più spesso del codice.
- [ ] **Cinque schermate su dodici non sono mai state pompate da un test**: verificato il
  2026-08-03 con un grep sul nome della classe — `GraphScreen`, `PeopleListScreen`,
  `CareerFitScreen`, `SettingsScreen` e `ShareScreen` non compaiono in **nessun** file di `test/`.
  Pesa più di ieri: oggi si è visto che una schermata mai pompata può essere rotta in **ogni** suo
  ramo senza che niente lo dica, e `career_fit` è quella che assomiglia di più al caso di oggi
  (legge il contenuto JSON e lo casta al punto d'uso, `career_fit_screen:75-83`). `settings`
  contiene tutta la UI di backup, che il backlog annota come mai verificata a runtime. L'alibi
  ormai è corto: per le due schermate con `.watch()` c'è il pattern dello `Stream.value`
  (2026-07-30) e per quelle con `FutureBuilder` + spinner quello del repository scaldato sotto
  `runAsync` (2026-08-03), quindi restano da scrivere, non da sbloccare.
- [ ] **Dieci dei diciassette campi per funzione non li legge nessuno**: emerso il 2026-08-03
  cercando quali campi valesse la pena fissare. `content_viewer` usa `title`, `full_name`,
  `description` e le quattro `as_*`; restano fuori `label_short`, `axis`, `direction`,
  `dominant_in`/`auxiliary_in`/`tertiary_in`/`inferior_in`, `shadow_function`, `axis_partner` e
  `examples_behavior`. Le quattro `*_in` sono ora tenute in riga dalla derivazione da
  `kMbtiStacks` (è così che è saltato fuori l'errore su Si), ma le altre sei sono contenuto
  scritto in due lingue che nessuno mostra e niente verifica. Da decidere per gruppi: `axis` e
  `axis_partner` duplicano `kComplementaryFunctions` (derivabili come le `*_in`),
  `shadow_function` ed `examples_behavior` sono materiale per la scheda funzione, `label_short` e
  `direction` sono probabilmente residui. Stessa domanda del `title` degli obiettivi: o si mostra
  o si toglie.
- [ ] **Aggiornamento dipendenze controllato**: `flutter pub outdated` (2026-07-23) segnala
  molti pacchetti major indietro (`share_plus` 12→13, `riverpod`/`riverpod_annotation` 2→3+
  con generator, `file_picker` 8→10, `drift` minori) e due transitive **dismesse**
  (`build_resolvers`, `build_runner_core`, catena `build_runner`). Pianificare un giro di
  update a scaglioni con CI verde ad ogni passo (riverpod 3 è breaking → valutarlo a parte).

### 2. Profilo ibrido multi-sistema

**Obiettivo.** Il profilo finale di una persona non è "il suo MBTI": è una **sintesi di tutta
l'evidenza disponibile** — MBTI, Big Five, Enneagramma, DISC, CliftonStrengths — pesata per
quanto ciascuna misura è affidabile. Più strumenti una persona ha svolto, più il profilo è
accurato e completo. L'enum `PersonalitySystem` prevede già i cinque valori; solo MBTI è
implementato.

**Decisione di architettura (2026-07-29): l'ibrido è derivato al volo, non materializzato.**
I profili per-sistema restano la sorgente di verità in `PersonalityProfiles` (una riga per
`(persona, system)`, ciascuna con `confidence`, `source`, `updatedAt`); il profilo ibrido si
calcola **su lettura** da quelle righe e non viene mai scritto in DB. Conseguenze: nessun
cambio di schema, nessuna migration, nessuna cache da invalidare quando arriva un test nuovo —
il profilo si aggiorna da sé. In cambio il calcolo va tenuto economico ed esposto da un
provider derivato (`hybridProfileProvider(personId)`), con la logica in `domain/` in Dart puro
come gli altri motori.

**Prerequisito bloccante.** Oggi `MbtiProfile.fromType` appiattisce le dicotomie a `±70` e i
pesi funzione a `[90,70,45,25]` per **ogni** sorgente, e tutti i percorsi di scrittura passano
di lì: in DB le dicotomie sono identiche per tutte le persone, e l'unica variazione è quale
dei 16 tipi più `confidence`/`source`. Non si fonde una misura continua con un flag: senza
evidenza graduata non c'è niente da fondere, si può solo sovrascrivere. Vedi la voce
**"La fedeltà dell'evidenza si ferma alla confidence"** in Epica 5 — è il primo passo di
questa epica, non un miglioramento cosmetico. Nota: il dato serve già esiste ed è buttato via,
`QuizResult.breakdown` è la posizione normalizzata 0..1 per asse e sopravvive solo come
`confidence`; col test lungo (20 item per asse, dal 2026-07-29) è una misura fine.

- [ ] **Salvare l'evidenza graduata** (prerequisito, vedi Epica 5): dicotomie reali quando il
  metodo le conosce, così MBTI contribuisce posizioni e non flag.
- [ ] **Spazio latente comune**: definire le dimensioni su cui i sistemi confluiscono. Proposta:
  backbone in stile Big Five (continuo, il più fondato empiricamente e con la sovrapposizione
  più ampia) più i tratti che non si riducono a fattori — tipo core/ali dell'Enneagramma,
  talenti CliftonStrengths — trasportati a parte invece che schiacciati dentro. Le mappature
  note collegano E↔Estroversione, N↔Apertura, F↔Gradevolezza, J↔Coscienziosità: il
  **Nevroticismo non ha corrispettivo MBTI**, quindi resta non misurato finché non c'è il
  Big Five. La fusione non è "media ciò che si sovrappone": è dimensioni condivise da
  riconciliare più dimensioni che un solo strumento copre, da propagare intatte.
- [ ] **Calibrazione delle scale**: prima di combinare, i contributi vanno portati su una scala
  comune. Oggi ogni motore normalizza a 0–100 a modo suo (`CognitiveFunctionAffinity` divide
  per `_maxRaw = 6.0`, tetto teorico MBTI-specifico; `CareerFit` tronca con `.clamp`). Mediare
  0–100 provenienti da strumenti diversi senza calibrare dà un numero che sembra preciso e non
  significa niente.
- [ ] **Motore di fusione** (`domain/`, Dart puro, statico come gli altri): dai profili
  per-sistema di una persona produce il profilo ibrido, pesando ogni contributo per
  `confidence`, `source` e `updatedAt` (un `quizLong` recente pesa più di un `manual` di due
  anni fa). È qui che il lavoro su confidence/source delle sessioni 27–29/07 diventa
  infrastruttura e non un dettaglio di visualizzazione.
- [ ] **Copertura del profilo**: l'ibrido deve dichiarare **quanto è completo** — quali sistemi
  hanno contribuito, quali dimensioni restano non misurate. È il contraltare onesto della
  promessa "più accurato e completo": senza, un profilo da un solo test breve si presenta come
  uno costruito su quattro strumenti.
- [ ] **Big Five (OCEAN)**: 5 tratti continui + quiz + contenuti. **Da fare per primo** fra i
  nuovi sistemi: è continuo per natura (quindi è il candidato naturale a fare da backbone) ed
  è l'unico che copre il Nevroticismo.
- [ ] **Enneagramma**: 9 tipi + ali + tritype, modello + contenuti + mappatura nello spazio comune.
- [ ] **DISC**: 4 dimensioni + contenuti + mappatura.
- [ ] **CliftonStrengths**: 34 talenti (fase 1: solo storage + schede), trasportati come tratti
  a sé.
- [ ] **Consumatori a valle**: `CognitiveFunctionAffinity`, `CareerFit`, `TeamOptimizer`
  (`kTeamObjectiveWeights` è indicizzato per funzione cognitiva) e i 7 tool "thick" del chatbot
  oggi consumano tutti `MbtiProfile`. Decidere se passano all'ibrido o restano MBTI-only: è il
  bivio architetturale vero di questa epica, molto più grosso di "aggiungere un calcolatore".
- [ ] **UI**: mostrare l'ibrido come *il* profilo della persona, con l'evidenza per-sistema
  navigabile sotto (quale test ha detto cosa, con che confidence). Sostituisce l'idea
  precedente di un selettore di "sistema attivo".
- [ ] **Condivisione**: `ShareCode` è un layout fisso da 15 byte con *un* tipo MBTI, *una*
  confidence, *una* source. Un profilo ibrido non ci sta: non è un bump di `version`, serve un
  payload a lunghezza variabile (o si condivide solo una sintesi).
- [ ] **Allineare `CLAUDE.md`**: la sezione "Adding a new personality system" descrive ancora
  il modello a coesistenza ("implement an affinity calculator and register it **alongside**
  `CognitiveFunctionAffinity`"), che questa epica supera.

> Voci superate da questa riscrittura, tenute per memoria: ~~"Registro affinità multi-sistema
> (selezione del calcolatore in base a `system`)"~~ e ~~"UI: selezione sistema attivo per
> persona e nel grafo"~~. Descrivevano un centralino — un sistema alla volta, profili in
> parallelo — non una sintesi.

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
- [x] **`person_edit` riscriveva ogni profilo come `manual` e disfaceva il fix del 27/07** —
  chiuso il 2026-07-28. Il blocco girava a ogni salvataggio (guardia solo
  `if (_mbtiType != null)`, con `_mbtiType` inizializzato dal profilo esistente) scrivendo
  `source: manual` fisso e la confidence *caricata*: bastava aprire la scheda per cambiare il
  nickname perché un `quizLong` a 93 diventasse un "autodichiarato" che millantava la
  certezza di un quiz. Fix: la schermata tiene ora uno snapshot di com'era il profilo al
  caricamento (`_loadedType` / `_loadedConfidence`) e `_save` scrive `manual` **solo** se il
  tipo è diverso da quello caricato; altrimenti conserva il `source` già in DB. In più il
  `_TypeSelector` riporta lo slider a `kSelfDeclaredConfidence` appena il tipo cambia (e lo
  ripristina se si ritorna sull'originale), così un tipo scelto a occhio non eredita più la
  certezza di un quiz nemmeno a schermo. Il default del campo passa da `80` a
  `kSelfDeclaredConfidence`. Due widget test di regressione in
  `test/widgets/profile_provenance_widget_test.dart`.
- [x] **I tre "test" del quiz erano lo stesso identico file da 16 domande** — chiuso il
  2026-07-29 scrivendo il contenuto vero. Scoperto il 2026-07-28: i tre asset avevano lo
  **stesso hash SHA256** (idem per `en/`) mentre la UI prometteva "~20 / ~50 / ~80 domande" e
  bollava il completo come "Più accurato" — affermazioni false, allora live sulla PWA. Ora la
  banca è di **80 item per lingua** (20 per asse, 10 diretti + 10 reverse-scored) e i tre file
  sono **annidati**: short 16 (4/asse), medium 48 (12/asse), long 80 (20/asse), con gli assi
  interlacciati e la direzione alternata, così nessuna sequenza di domande consecutive spinge
  lo stesso polo. Le 16 domande del breve sono esattamente quelle già pubblicate, quindi
  nessuna regressione di contenuto. Copy allineata ai numeri reali (niente più "~"):
  16·4 min, 48·10 min, 80·16 min. Nuovo `test/assets/quiz_assets_test.dart` (15 test) che
  asserisce conteggi, unicità di id e testo, assi/direzioni valide, bilanciamento per asse,
  annidamento e parità di struttura IT/EN: è la rete che impedisce il ritorno del bug.
  Nota emersa chiudendola: il badge **"Più accurato"** ora è vero nel senso ordinario
  (20 item per asse contro 4 → una risposta anomala sposta molto meno il risultato), ma **non**
  perché produca una `confidence` più alta — quella metrica è normalizzata per asse, quindi chi
  risponde in modo coerente la satura su qualsiasi lunghezza. Il commento nel codice che
  affermava il contrario è stato corretto.
- [ ] **Uscire dal quiz a metà butta via tutte le risposte senza chiedere niente.**
  `QuizScreen` è sempre spinta con `MaterialPageRoute` (da `onboarding._openQuiz` e da due
  punti di `person_detail`), quindi l'AppBar della pagina domanda ha la freccia indietro
  automatica: un tap fa `pop()` della route e `_answers` sparisce, senza conferma e senza
  salvataggio parziale. Con 16 domande era una seccatura; dal 2026-07-29 il test completo ne
  ha **80**, quindi si possono perdere venti minuti di lavoro con un tap involontario (su
  mobile anche solo una gesture di swipe-back). Serve almeno un dialog di conferma sull'uscita
  a quiz iniziato; la persistenza delle risposte parziali è il passo successivo.
- [ ] **La fedeltà dell'evidenza si ferma alla confidence**: `MbtiProfile.fromType` fissa
  `dichotomies` a ±70 e i pesi funzione a `[90,70,45,25]` per **ogni** sorgente, quindi il
  breakdown del quiz e la posizione reale degli slider granulari vengono buttati via nel
  campo `data`. Un J/P al 51/49 e uno al 95/5 sono indistinguibili in DB, e la confidence
  (2026-07-27) è oggi l'unica traccia di quell'evidenza. Salvare le dicotomie reali quando
  il metodo le conosce. È il prerequisito della schermata di confronto e del livello
  per-funzione qui sotto — e, dal 2026-07-29, **il primo passo di Epica 2**: senza evidenza
  graduata il profilo ibrido multi-sistema non ha niente da fondere, perché una misura continua
  (Big Five) non si combina con un flag `±70`. Da qui in poi vale come blocco, non come
  rifinitura.
- [x] **Un asset del quiz illeggibile faceva crashare la schermata invece di dare un errore**
  — chiuso il 2026-07-29. `ContentRepository.loadQuizQuestions` inghiotte qualsiasi errore e
  restituisce `[]`; `_startQuiz` salvava quella lista vuota e impostava `_selectedLength`,
  quindi `build` scivolava fino a `_buildQuestion` → `RangeError` su lista vuota, schermo rosso
  senza via d'uscita (verificato con una sonda il 2026-07-28). Ora `build` ha un ramo esplicito
  su `_questions!.isEmpty` → `_buildLoadError`: icona, messaggio (`quizLoadError` IT/EN) e
  pulsante **Indietro** che azzera `_selectedLength`/`_questions` e riporta alla scelta della
  lunghezza, perché gli altri due file possono benissimo caricarsi. Widget test di regressione
  `test/widgets/quiz_load_error_widget_test.dart` (override del repo con uno che ritorna `[]`):
  nessuna eccezione, messaggio a schermo, ritorno alla scelta funzionante.
- [x] **Copy sbagliata sulla scelta della lunghezza del quiz** — chiusa il 2026-07-29.
  L'AppBar usava `mbtiSourceQuizShort` ("Test breve") su una pagina che offre tutte e tre le
  lunghezze (di qui la disambiguazione che il widget test del 28/07 aveva dovuto fare) e il
  titolo interno riusava `onboardingChooseMethod`, che parla del metodo e non della durata.
  Due stringhe nuove IT+EN: `quizChooseLengthAppBar` ("Test della personalità") e
  `quizChooseLengthTitle` ("Quanto vuoi che sia lungo il test?").
- [ ] **Stringa italiana hardcoded in `person_edit`**: `person_edit_screen.dart` mostra
  `'Inserisci un nome'` come snackbar di validazione invece di una chiave l10n, quindi in EN
  esce in italiano. Notato il 2026-07-28 lavorando sullo stesso `_save`; lasciato fuori
  perché richiede una nuova chiave ARB + `gen-l10n`.
- [ ] Implementare la sorgente `ProfileSource.granular` (assessment per funzione, non solo
  per asse). Nota: il percorso granulare **funziona già** a livello di asse
  (`_deriveTypeFromDichotomies` deriva il tipo dai 4 slider); manca solo il livello per
  singola funzione cognitiva.
- [ ] Schermata di confronto: profilo manuale vs risultato quiz, con ricalcolo `confidence`.
- [ ] Retake del quiz con storicizzazione dei risultati.

### 6. Contenuti

- [x] **Il Team builder non ha mai mostrato il suo contenuto tradotto: l'utente legge chiavi
  grezze** — chiuso il 2026-07-30. Ora la schermata risolve tutte le chiavi che il motore
  emette: gli obiettivi prendono il nome dalle **sei stringhe ARB `teamObj*`**, che esistevano
  già in IT+EN e non erano usate da nessuno (`_objectiveTitle`, switch esaustivo: un obiettivo
  nuovo non può più uscire senza nome); descrizione e `ideal_profile` dell'obiettivo scelto
  arrivano da `team_objectives.json` (la prima sotto il menu a tendina, il secondo in testa alla
  lista dei risultati, dove è il metro con cui si leggono i team proposti); punti di forza e
  blind spot si risolvono su due sezioni **nuove** dello stesso asset (`strengths`,
  `blind_spots`: 8+8 voci per lingua, una per funzione cognitiva, esattamente le chiavi
  `strength_*`/`blindspot_*` di `TeamOptimizer`). Rimossa l'estensione stub con i tre
  commenti-appunto. Scelta di design: il **nome** dell'obiettivo resta in ARB perché etichetta
  un controllo (il menu deve funzionare anche con l'asset rotto), il **contenuto** sta nel JSON;
  se l'asset manca, la descrizione lascia il posto a `errorNotFound` e il resto della schermata
  continua a funzionare. `_ConfigurationPanel` non è più un `ConsumerWidget` che non usa `ref`
  (riceve il contenuto dall'alto, quindi è uno `StatelessWidget`). Nuovo
  `test/widgets/team_builder_content_widget_test.dart` (2 test, IT e EN, sul vero asset e con un
  trio ENFP/ESTJ/ISTJ scelto per produrre due strength e un blind spot deterministici).
  Testo storico:
- [ ] ~~**Il Team builder non ha mai mostrato il suo contenuto tradotto: l'utente legge chiavi
  grezze**~~. Trovato il 2026-07-29 rimuovendo il `FutureBuilder` che caricava
  `team_objectives.json` senza leggerlo. I due asset (IT + EN, ~2 KB l'uno) hanno `title`,
  `description` e `ideal_profile` per ogni obiettivo, ma la schermata non li tocca: il menu a
  tendina usa `l10n.getTeamObjectiveTitle(obj.name)` e strengths/blind spot usano
  `getStrengthTitle`/`getBlindSpotTitle`, che sono tre **stub** in fondo a
  `team_builder_screen.dart` (`=> key`, `key.replaceAll('strength_','').toUpperCase()`) con i
  commenti-appunto "Will implement properly via JSON/arb". Risultato a schermo: gli obiettivi
  appaiono come i nomi dell'enum Dart (`creative`, `execution`, …) **identici in IT e EN**,
  perché `obj.name` non passa da nessuna traduzione, e i punti di forza come `NI, TE` (le
  sigle delle funzioni cognitive, da `strength_${label.toLowerCase()}` in
  `team_optimizer.dart:224`). Dopo la rimozione di oggi `loadTeamObjectivesContent` non ha
  **nessun** chiamante in `lib/`: il contenuto è formalmente morto finché qualcuno non lo
  collega. È la schermata più indietro del progetto ed è raggiungibile dalla home. Fix:
  cablare `TeamObjectivesContent` nella schermata (titolo + descrizione dell'obiettivo
  scelto) e risolvere le chiavi strength/blindspot via ARB o via JSON, togliendo l'estensione
  stub. (Nota minore stessa schermata: `_ConfigurationPanel` è un `ConsumerWidget` che non usa
  mai `ref`.)
- [ ] **Il `title` degli obiettivi ora ha due sorgenti e una è morta**: dopo il fix del
  2026-07-30 il nome dell'obiettivo viene dall'ARB (`teamObjCreative`…), quindi i sei campi
  `title` di `team_objectives.json` non sono letti da nessuno — e `content_assets_test` li
  pretende, cioè fissa contenuto che nessuno mostra. Erano identici alle stringhe ARB, quindi
  nessuno se ne accorge finché non divergono. Decidere: togliere `title` dal JSON (l'ARB resta
  padrone del nome, il JSON di descrizione e `ideal_profile`) oppure il contrario. La ragione
  per cui il nome sta in ARB è che etichetta un controllo: il menu a tendina deve funzionare
  anche con l'asset rotto.
- [ ] **`CareerRole.titleKey` non risolve da nessuna parte**: è il gemello rovesciato della voce
  qui sopra sui `title` degli obiettivi (là due sorgenti, qui zero). Verificato il 2026-07-31:
  `career_catalog.dart` dà a ogni ruolo un `titleKey` tipo `career_researcher`, ma
  `career_roles.json` è indicizzato per **`id`** (`researcher`) e nelle ARB non esiste
  **nessuna** chiave `career_*` (solo `careerFitTitle` e `careerDisclaimer`). Quindi quel campo
  nomina una traduzione che non esiste, e i suoi due unici usi lo mostrano: il fallback di
  `career_fit_screen` (`?? res.role.titleKey`), che in caso di asset rotto stampa a schermo
  `career_researcher`, e `chat_tools.dart:185`, che lo manda al modello come `'key'` — vedi la
  voce di backlog sulle chiavi grezze spedite al chatbot. Decidere: togliere `titleKey` da
  `CareerRole` (l'`id` è già la chiave del contenuto, e il fallback diventa l'`id`) oppure
  farlo puntare a qualcosa che esiste.
- [x] **Tre sezioni della scheda MBTI erano scritte, etichettate e mai renderizzate** — chiuso il
  2026-08-03 nello stesso giro del test su `mbti.json`. (1) `famous_examples_fictional` e
  (2) `compatibility_notes` (tre liste di tipi: alta affinità, buona collaborazione, crescita
  stimolante) stavano nell'asset per tutti e 16 i tipi in IT+EN, e le **cinque** stringhe ARB che
  le etichettano — `contentSectionExamples`, `contentSectionCompatibility`,
  `contentHighAffinity`, `contentGoodWorking`, `contentChallengingGrowth` — esistevano da sempre
  senza un solo lettore in `lib/`, esattamente come le `teamObj*` del 2026-07-30. Ora la scheda
  le mostra (le tre liste come chip di tipo), quindi non serve nessuna stringa nuova.
  (3) Le **4 dicotomie** erano il caso limite: contenuto completo in due lingue (due poli con
  descrizione e marker comportamentali, nota sullo spettro, miti comuni), un ramo dedicato in
  `ContentViewerScreen`, `getDichotomyContent` nel repository — e **nessuna schermata che ci
  navigasse**, quindi il ramo non era mai stato eseguito e nessuno si era accorto che leggeva
  `poles` come lista (vedi Epica 1). Punto d'ingresso scelto: le quattro barre degli assi nella
  pagina risultati del quiz, che è dove l'utente sta già guardando I/E, N/S, T/F e J/P; ogni riga
  è ora toccabile con un'icona informativa. Unica stringa nuova, `contentSectionMyths` (IT+EN),
  che sostituisce il `'Miti comuni'` italiano hardcoded nel widget. Coperto da
  `content_viewer_widget_test.dart`, incluso un test che percorre il test breve dall'inizio e
  apre la scheda I/E dai risultati.
- [ ] **Le dicotomie si aprono solo dai risultati del quiz**: coda diretta del fix del
  2026-08-03. L'unico punto d'ingresso è la pagina risultati, quindi chi non fa il test — tipo
  scelto a mano in `person_edit`, oppure importato da un codice condiviso — non vede **mai** quel
  contenuto, e chi il test l'ha fatto lo raggiunge solo finché resta su quella pagina: dopo il
  salvataggio non c'è più modo di tornarci. `person_detail` ha già gli ingressi per il tipo (il
  badge) e per le funzioni cognitive (le chip), e le manca solo quello per i quattro assi.
- [ ] **`growth_areas` resta l'unico campo del tipo senza lettore**: un paragrafo per ciascuno dei
  16 tipi, in IT+EN, che nessuna schermata mostra e per cui — a differenza di esempi e
  compatibilità, chiusi il 2026-08-03 — **non** esiste un'etichetta ARB pronta. Attenzione al
  nome se lo si mostra: `contentSectionWeaknesses` in italiano è già "Aree di crescita" e sta
  sopra `weaknesses`, quindi servono due etichette distinguibili o una fusione delle due sezioni.
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
- [ ] **La PWA online è ancora quella con i contenuti mancanti**: il fix di `pubspec.yaml` del
  2026-07-30 è verificato solo in locale (`flutter build web --release` → gli otto file in
  `build/web`). Finché non si pusha, `https://ventus2202.github.io/Archetypes/` continua a
  mostrare "Contenuto non trovato" in Career fit e la riga d'errore nella sezione affinità di
  `person_detail`. Dopo il deploy, verificare **sul sito** — non solo che i JSON rispondano 200,
  che è l'errore di verifica del 2026-07-26, ma che le tre schermate mostrino il testo: Career
  fit con i 16 ruoli, `person_detail` con la sezione affinità, Team builder con obiettivi e
  punti di forza in chiaro.
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
- [ ] **`CLAUDE.md` non dice che un asset va dichiarato in `pubspec.yaml`**: è esattamente il
  genere di trappola che quel file serve a evitare, e il 2026-07-30 è costata tre contenuti mai
  spediti (con l'aggravante che i file c'erano, il repository li leggeva e `CLAUDE.md` li
  elencava). Aggiungere alla sezione "Educational content": gli asset si dichiarano **per
  directory**, un file nuovo in `assets/content/<locale>/` non arriva nell'app se la directory
  non è elencata, e `test/assets/content_assets_test.dart` è la rete che lo verifica. Nella
  stessa sezione, annotare che `team_objectives.json` risolve anche le chiavi
  `strength_*`/`blindspot_*` emesse da `TeamOptimizer`, mentre i **nomi** degli obiettivi
  stanno nell'ARB.
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
  Il 2026-07-28 è emerso il caso che rende la mancanza concreta: il questionario è ben
  costruito, metà delle domande sono reverse-scored, quindi **rispondere "5" a tutto dà un
  pareggio perfetto su ogni asse** → ENFP a confidence 50, il minimo (scoperto perché il primo
  tentativo di widget test faceva esattamente così). Chi risponde in automatico — acquiescence
  bias, un comportamento reale sui questionari — vede una pagina risultati che annuncia "Sei
  ENFP" a caratteri grandi, identica in tutto a quella di un profilo netto. La confidence 50 è
  già il segnale giusto e viene salvata in DB, ma nessuna schermata la legge: la pagina
  risultati dovrebbe dire che il risultato è in bilico, non solo mostrare un numero.
- **Pattern: le schermate che si chiudono da sole vanno pompate sopra una route host.**
  `QuizScreen` e `PersonEditScreen` finiscono con `Navigator.pop()`, quindi montarle come
  `home:` di `MaterialApp` significa far poppare la route radice. In
  `profile_provenance_widget_test.dart` (2026-07-28) sono spinte su una `Scaffold` host con un
  pulsante "apri": il pop torna a una route vera e il test può proseguire. Vale come pattern
  accanto a quello sulla geometria renderizzata, per le prossime schermate con `pop()` finale.
- **`_loadExisting` di `person_edit` nasconde un profilo illeggibile**: il
  `catch (_) {}` attorno a `MbtiProfile.fromJson` (`person_edit_screen.dart`) fa sparire il
  tipo dal form senza dire nulla, e la persona sembra semplicemente senza MBTI. Il dato in DB
  non viene distrutto (con `_mbtiType` nullo il blocco di scrittura non parte, e dopo il fix di
  oggi nemmeno il `source` verrebbe toccato), quindi non è urgente — ma è un fallimento muto
  della stessa famiglia di quelli già chiusi in `_AppGate` e nel backup.
- **`person_detail` ha la stessa copy sbagliata appena tolta dal quiz**:
  `person_detail_screen.dart:280` usa `l10n.mbtiSourceQuizShort` ("Test breve") come titolo
  della voce che **apre il quiz**, con il commento-appunto `// Or a "Retry quiz" label`. Da
  quando il quiz offre davvero tre lunghezze diverse (2026-07-29) è sbagliata in due modi:
  nomina una sola lunghezza per un ingresso che le offre tutte, e riusa una stringa che
  descrive la *sorgente* di un profilo. Riusare `quizChooseLengthAppBar` o una stringa
  dedicata tipo "Rifai il test".
- **`QuizQuestion.weight` è flessibilità mai usata**: tutti e 144 gli item degli asset (e i 16
  di prima) hanno `"weight": 1.0`, mentre engine e modello supportano pesi per domanda. O si
  usa — pesando di più gli item che discriminano meglio, cosa che avrebbe senso ora che la
  banca è di 80 — o è un campo che complica il formato senza dare niente. Da decidere quando
  si rimetterà mano al contenuto.
- **La banca del quiz va tenuta bilanciata a mano**: gli asset in `assets/quiz/` restano la
  sorgente di verità (nessun generatore committato), quindi aggiungere item significa
  rispettare gli invarianti che `test/assets/quiz_assets_test.dart` verifica — pari numero di
  domande per asse, metà reverse-scored, annidamento short ⊂ medium ⊂ long, stessa struttura
  IT/EN. Se la banca crescerà ancora, valutare di committare il generatore in `tool/`.
- **I `FutureBuilder` creano il future dentro `build`**: `career_fit_screen.dart:52`,
  `person_detail_screen.dart:79` e `:249`, `content_viewer_screen.dart:28`. Ogni rebuild
  (cambio tab, `setState`, rotazione, comparsa della tastiera) costruisce un Future nuovo,
  quindi rifà il lavoro e rimostra lo spinner. Per i contenuti il costo è basso — la cache per
  locale del 2026-07-29 fa sì che il secondo giro non rilegga l'asset — ma
  `_computeAffinityWithSelf` fa **due query DB più il calcolo di affinità e dinamiche** a ogni
  rebuild. Memoizzare il future (campo in uno `State`, o un `FutureProvider`, stile già usato
  altrove nel progetto).
- ~~**Il motore aggiunge un suffisso `_title` che il contenuto non ha**~~ — chiuso il
  2026-07-31 insieme ad `avoid_dynamic_calls`, vedi Epica 1. Il motore emette la chiave nuda
  (`contentKey`), le sei `replaceAll` in `person_detail` sono sparite.
- **`withoutOrphans` e `_purgeOrphans` fanno lo stesso lavoro in due linguaggi diversi**: notato
  chiudendo il `[!]` degli orfani il 2026-08-02. Il DB li spazza con quattro DELETE SQL in
  `AppDatabase`, il backup li filtra in Dart puro su `BackupData`; la regola è la stessa ("un figlio
  senza genitore non vale"), ma le due liste di colonne vanno tenute allineate a mano e nessun test
  le confronta. Se domani una tabella figlia nuova entra nello schema, dimenticarne una delle due
  non rompe niente subito — riappare come un 787 all'import o come una riga orfana che sopravvive.
  Il dominio non può importare drift, quindi non è una funzione sola: al massimo un test che
  verifichi che entrambe coprano tutte e cinque le foreign key dello schema.
- **L'import in merge sovrascrive per id locale, quindi può cancellare la persona sbagliata**:
  notato il 2026-08-02 sostituendo `insertOrReplace` con l'upsert (il problema precede il cambio,
  vale per entrambi). Gli id sono `autoIncrement` **locali**, quindi la persona 3 di un backup non
  è la persona 3 del dispositivo che lo importa: un merge di un backup preso da un altro telefono
  — o dallo stesso dopo un import con `replace`, che rinumera — riscrive nome, avatar e note di una
  persona del tutto estranea, in silenzio e senza conferma. Con `replace: true` la cosa non si pone
  (si azzera tutto), quindi il difetto sta solo nella modalità merge, che l'utente sceglie da un
  dialog in `settings_screen`. Chiudere la falla richiede una chiave stabile fra dispositivi:
  `PersonalityProfiles.shareId` è già un id casuale stabile, ma sta sul **profilo** e non sulla
  persona, e una persona senza profilo non ne ha nessuno. Da decidere insieme alla voce di Epica 1
  sull'integrità referenziale dei backup: sono la stessa domanda, "che cosa identifica una riga
  quando esce dal dispositivo che l'ha creata".
- **`_purgeOrphans` cancella righe senza dirlo a nessuno**: aggiunto il 2026-08-02 insieme al
  pragma sulle foreign key. Gira a ogni apertura del DB (quattro DELETE, idempotenti e rapidi su un
  DB di dimensioni personali) ed è **necessario** così, perché un database creato prima del pragma
  non ha altro momento in cui ripulirsi. Restano due code. La prima: è un fallimento muto della
  stessa famiglia che il progetto continua a chiudere altrove — se domani un percorso di scrittura
  producesse orfani, sparirebbero all'avvio successivo senza che nessuno se ne accorga — e da fine
  giornata l'asimmetria è più stridente, perché l'import degli stessi orfani ora **li elenca** in un
  `BackupImportReport` mentre la spazzata all'apertura resta muta: stessa regola, due sponde, una
  parla e l'altra no; almeno
  contarli e loggarli quando non sono zero. La seconda: passato il tempo in cui i DB pre-pragma
  esistono ancora, il purge diventa lavoro a vuoto a ogni avvio e si può legare a un marker o
  togliere.
- **Le foreign key non sono mai state esercitate su web**: il `beforeOpen` del 2026-08-02 è
  verificato solo su `NativeDatabase`. `PRAGMA foreign_keys` è SQLite standard e `sqlite3.wasm` lo
  supporta, quindi non c'è motivo di dubitarne — ma il progetto ha già pagato una volta (2026-07-30,
  gli asset mai messi nel bundle) il prezzo di dare per scontato che ciò che funziona in locale
  arrivi nella PWA. Da mettere nel walkthrough end-to-end già in backlog: cancellare una persona
  dalla PWA e controllare che il grafo non conservi i suoi archi.
- **Il chatbot manda al modello le chiavi grezze di strength/blind spot**: `_optimizeTeam`
  (`chat_tools.dart:255`) serializza `chosen.strengths`/`blindSpots` così come sono, quindi il
  modello riceve `strength_ne` e `blindspot_ni` e deve indovinare cosa significano. È la stessa
  radice del `[!]` chiuso il 2026-07-30 sul Team builder, ma sul lato tool: `ChatToolExecutor`
  non ha né locale né `ContentRepository`, quindi risolverle richiede di passarglieli. Vale
  anche per gli altri tool che restituiscono chiavi (`titleKey` dei ruoli in `list_roles`).
- **Un widget test può pompare una schermata con `.watch()` se lo stream viene sostituito**:
  il 2026-07-30 `TeamBuilderScreen` (che watcha `allPersonsProvider`) è stata testata
  sovrascrivendo il provider con `Stream.value(persons)`, cioè uno stream che si chiude, e
  `pumpAndSettle` non va in hang. È una via d'uscita concreta dal blocco annotato in Epica 1:
  il DB in-memory resta per i repository (serve a `calculate()`), solo la sottoscrizione viene
  aggirata. Da provare su `PeopleListScreen` e sul grafo, gli altri due casi elencati.
- **Il repo non è `dart format` clean, e il 2026-07-31 si è capito perché**: non è deriva, è un
  **cambio di formatter**. Il 2026-07-29 la verifica su due file non toccati
  (`graph_screen.dart`, `person_detail_screen.dart`) diceva "Changed"; oggi lo dicono anche i tre
  file della sessione, **compreso il codice scritto oggi da zero**. Guardando il diff proposto
  (`dart format -o show | diff`) non si tratta di indentazione sciatta: il formatter dell'SDK
  3.11.5 è quello "tall style" introdotto da Dart 3.7, e riscrive costrutti che erano
  perfettamente convenzionali quando il repo è stato scritto — corpi `=> { ... }`, catene
  `db.into(x).insert(...)`, il rientro delle funzioni a freccia. Conseguenza sulla decisione già
  annotata: il "commit dedicato solo-formato" non tocca qualche punto stantio, **rifà praticamente
  ogni file Dart del repo**, quindi va fatto quando non c'è altro lavoro in volo e va messo in un
  commit isolato, altrimenti seppellisce ogni diff successivo. Le due opzioni restano quelle:
  adottare il tall style in un colpo solo + `dart format --set-exit-if-changed` in CI perché non
  ricominci, oppure dichiarare che il formato è libero e smettere di verificarlo (nel frattempo il
  codice nuovo si scrive nello stile dei file attorno, che è quello che si è fatto oggi).
  Collegato alla voce `.gitattributes` (stessa famiglia: igiene del diff).
- **Pattern: un test sul contenuto deriva le chiavi attese dal motore, non da una lista
  copiata.** Aggiunto il 2026-07-31 estendendo `content_assets_test`: le chiavi attese si
  ottengono da `kCareerRoles`, `RelationshipDynamics.kFunctionConflicts`,
  `kCommunicationPatterns` e `CognitiveFunction.values`, così se domani il motore ne emette una
  nuova il test la pretende **da solo**. Una lista di stringhe scritta a mano nel test fissa
  invece una fotografia, e diverge in silenzio esattamente come il contenuto che dovrebbe
  proteggere. Corollario dello stesso giro: pretendere stringhe **non vuote** e non solo
  `isA<String>()` — a schermo una voce presente ma vuota si legge come una mancante, quindi un
  test che guarda solo il tipo lascia passare metà del fallimento. Vale accanto agli altri tre
  pattern annotati (geometria renderizzata, route host, `AssetBundle` iniettabile).
- **L'output dei test è sporcato da un falso positivo di drift**: ogni file di test che apre più
  di un `AppDatabase` fa stampare `WARNING (drift): It looks like you've created the database
  class AppDatabase multiple times` **più uno stack trace completo**, una volta per istanza. È un
  falso positivo: il warning avverte del rischio quando due istanze condividono lo stesso
  `QueryExecutor`, mentre nei test ognuna ha il suo `NativeDatabase.memory()`; drift però conta le
  istanze della classe, non gli executor. Il costo è che un warning vero, in mezzo a quelle
  strofe, non lo nota nessuno. Si spegne con
  `driftRuntimeOptions.dontWarnAboutMultipleDatabases = true` in un helper condiviso dei test —
  da valutare insieme al fatto che oggi non esiste nessun helper comune per aprire un DB di test
  (ogni file ripete `AppDatabase(NativeDatabase.memory())` + `addTearDown`). Stessa famiglia,
  notata il 2026-08-02: non esiste nemmeno un costruttore condiviso di **fixture di backup**, e
  ormai sono tre le sessioni che ne scrivono a mano — `backupWith`/`person` in
  `data_backup_test.dart`, `_zipWith` più i `data.json` letterali in
  `data_backup_service_test.dart`, e oggi un terzo con le righe orfane. Sono mappe lunghe in cui
  ogni campo obbligatorio va ricopiato, quindi una colonna nuova nello schema le rompe tutte una
  per una.
- **Pattern: costruire a mano il contenitore per testare chi lo legge.** Aggiunto il 2026-07-31
  con `_zipWith(String dataJson)` in `data_backup_service_test.dart`: per verificare che l'import
  **rifiuti** un archivio rotto serve fabbricare un layout che `exportToBytes` non produrrebbe
  mai (ZIP senza `data.json`, `data.json` non JSON, campi del tipo sbagliato). Vale accanto agli
  altri pattern annotati (geometria renderizzata, route host, `AssetBundle` iniettabile, chiavi
  attese derivate dal motore): un round-trip export→import prova che il caso buono funziona e
  **nessun** caso cattivo, perché l'esportatore non sa produrne.
- **Pattern: per testare chi legge asset, iniettare l'`AssetBundle`.** Aggiunto il 2026-07-29
  a `ContentRepository({AssetBundle? bundle})` (default `rootBundle`): un bundle finto rende
  i test ermetici, indipendenti dal contenuto reale e capaci di simulare asset mancanti o
  JSON malformato — cose che con `rootBundle` non si riescono a provocare. Vale accanto agli
  altri due pattern annotati (geometria renderizzata, route host per le schermate che fanno
  `pop()`). Trappola da ricordare: `rootBundle` è un `CachingAssetBundle` e cachea già le
  stringhe per chiave, quindi un fake che voglia **contare** le letture deve sovrascrivere
  anche `loadString`, altrimenti misura la cache del bundle e non quella del repository.
- **Il separatore di paragrafo del contenuto è un contratto che nessuno scrive da nessuna parte**:
  emerso il 2026-08-03 sistemando `content_viewer`. La `description` di un tipo e di una funzione
  è **una** stringa in cui i paragrafi sono separati da una riga vuota, e la schermata la spezza
  su `\n\n` per rendere un `Text` per paragrafo. Il test pretende una stringa non vuota, non che
  contenga paragrafi: chi domani scrivesse una descrizione con un solo `\n` otterrebbe un blocco
  unico, corretto per il test e sbagliato a schermo. Vale come nota per `CLAUDE.md` (la sezione
  sugli asset didattici non dice niente sulla forma dei campi) più che come test.
- **Le chip di compatibilità non portano da nessuna parte**: dal 2026-08-03 la scheda del tipo
  mostra le tre liste di `compatibility_notes` come chip (`ENFP`, `ENTP`, …) e il test verifica
  che siano tipi MBTI veri, ma sono inerti. La rotta per aprire la scheda di un tipo esiste già ed
  è la stessa che usa `person_detail`: renderle toccabili è un `onTap` e trasforma la sezione in
  un modo di girare fra le 16 schede.
- **Pattern: una schermata con `FutureBuilder` + spinner non si pompa con `pumpAndSettle`.**
  Aggiunto il 2026-08-03 scrivendo `content_viewer_widget_test.dart`. Due trappole in fila.
  La prima: il ramo di caricamento è un `CircularProgressIndicator`, un'animazione infinita che
  continua a programmare frame, quindi `pumpAndSettle` va in timeout invece di stabilizzarsi —
  è una **seconda** famiglia di schermate non pompabili, accanto a quelle sottoscritte a un
  `.watch()` drift annotate in Epica 1, e si riconosce da "c'è uno spinner", non da "c'è uno
  stream". La seconda: sotto il clock finto l'I/O vero dell'asset non completa, quindi due
  `pump()` mostrano ancora lo spinner. La via d'uscita che funziona è iniettare un
  `ContentRepository` **già scaldato**: `await tester.runAsync(() => repo.loadMbtiContent('it'))`
  prima di `pumpWidget`, override di `contentRepositoryProvider`, poi due `pump()` — la cache per
  locale del 2026-07-29 fa sì che il future della schermata si chiuda in un microtask. Corollario
  per il quiz, che è l'unico loader **senza** cache (voce qui sotto): lì serve comunque un
  `runAsync` dopo il tap perché il caricamento reale possa completare.
- **Il quiz è l'unico contenuto non cachato**: dopo il fix del 2026-07-29 i quattro contenuti
  didattici stanno in cache per locale, mentre `loadQuizQuestions` rilegge e riparsa l'asset a
  ogni avvio del test (80 item nel completo). Non è un problema di prestazioni oggi — succede
  una volta per test — ma è l'unica eccezione rimasta alla regola del repository, quindi o si
  cacha anche quello o si scrive perché no.
- **La prima e unica stringa con plurale ICU**: `backupImportSkipped` (2026-08-02) è l'unica delle
  ARB che usa `{count, plural, ...}` — verificato, tutte le altre hanno solo placeholder semplici.
  Due code. La prima: è un costrutto che nessun test tocca e che si rompe in silenzio se un domani
  una traduzione sbaglia una graffa, dato che `gen-l10n` gira in CI *prima* di `analyze` e un ARB
  malformato fa fallire la build, ma una forma plurale sbagliata (non mancante) no. La seconda: se
  il costrutto vale la pena, ci sono altri conteggi che oggi sono cuciti a mano o evitati — la
  copy delle lunghezze del quiz ("16 domande · 4 min") e il numero di persone/gruppi nelle liste.
  O si adotta come regola per i conteggi, o resta un'eccezione da spiegare.
- **Il badge a pillola è duplicato**: stesso `Container` (alpha 38, radius 999, `labelSmall`
  w600) in `_MethodCard` (`onboarding_screen.dart`) e in `_LengthCard`
  (`quiz_screen.dart`). Due copie si tollerano; alla terza estrarre un piccolo widget
  condiviso invece di ricopiarlo.
- **Tre stringhe italiane hardcoded in `settings_screen`**: `'Errore esportazione: $e'`,
  `'Errore importazione: $e'` e `'Dati importati con successo'` (più il `text: 'Archetypes Backup'`
  della share sheet) non passano da `l10n`, quindi in EN escono in italiano; le prime due
  stampano anche l'eccezione grezza all'utente. Dal 2026-07-31 quell'eccezione è almeno leggibile
  (`Invalid backup: persons[2].createdAt is missing` invece di un `TypeError`), ma resta una frase
  inglese dentro una italiana. Stessa famiglia dell'`'Inserisci un nome'` di `person_edit`
  (Epica 5) e della voce sui messaggi d'errore user-friendly qui sopra: conviene chiuderle in un
  giro solo di ARB.
- **`confidenceFromAxisBalance` usa la media, non l'asse peggiore**: 3 assi netti + 1 in
  perfetto pareggio danno 88, mentre la lettera in bilico resta un lancio di monetina. È
  documentato come "quanto sono netti gli assi", non come probabilità che il tipo sia
  esatto. Se serve la seconda semantica, passare al prodotto delle certezze per asse.
- **Default `confidence` a 80 nel DB**: `app_database.dart:31` ha ancora
  `withDefault(const Constant(80))`, ereditato da quando tutto era 80. Nessuno scrive più
  profili senza confidence esplicita, quindi è solo un valore fantasma: valutare se
  abbassarlo o togliere il default. Dal 2026-07-28 è rimasto l'**ultimo** 80 hardcoded del
  percorso profili: anche `person_edit._mbtiConfidence` partiva da 80 e ora nasce a
  `kSelfDeclaredConfidence`.
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
- 2026-07-23 — Epica 9 `[!]`: **backup/restore ora funziona nella PWA**. `DataBackupService`
  passa a byte puri (`exportToBytes`/`importFromBytes`), niente più `dart:io`/`path_provider`,
  `archive_io` → `archive`. Nuovo helper download browser a import condizionale
  (`core/platform/file_download*.dart`, Blob+anchor su `package:web`), perché
  `file_picker.saveFile` non esiste su web. `settings_screen` fa branch web/nativo per export
  e usa `withData:true` + `.bytes` per import. `web` promosso a dep diretta. Chiusi anche il
  test end-to-end di `DataBackupService` (Epica 1) e l'audit `dart:io` (Epica 9). Verifiche:
  analyze pulito, 39 test verdi (2 nuovi), **build web release OK** (wasm dry-run OK).
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
- 2026-07-28 — Epica 5 `[!]` **chiuso: il percorso di scrittura del profilo MBTI non mente
  più**. `person_edit` non declassa più a `manual` ogni profilo a ogni salvataggio: la
  schermata confronta il tipo con uno snapshot di quello caricato e riscrive `source` solo se
  l'utente lo ha davvero ri-scelto, altrimenti conserva la provenienza in DB; lo slider della
  confidence scende a `kSelfDeclaredConfidence` nel momento in cui il tipo cambia, così il
  93 di un `quizLong` non finisce su una scelta a occhio. Epica 1: `_save()` di onboarding e
  `person_edit` ora hanno `try/catch` + snackbar (`errorGeneric`) e non lasciano più lo
  spinner infinito; nuovo `test/widgets/profile_provenance_widget_test.dart` (3 test) che
  pompa `QuizScreen` e `PersonEditScreen` su DB in-memory e **rilegge la riga dal DB** — era
  l'unico modo di coprire il fix del 27/07, invisibile ai test di engine. Trovato scrivendo
  quei test: **i tre file del quiz sono byte-identici, 16 domande**, mentre la UI promette
  20/50/80 e bolla il lungo come "Più accurato" (nuovo `[!]` in Epica 5). Verifiche: analyze
  pulito, 87 test verdi (84→87).
- 2026-07-28 — Chiusura sessione: registrate le voci emerse dal lavoro sui test. Un secondo
  `[!]` in Epica 5, **verificato con una sonda usa-e-getta** e non solo letto: se un asset del
  quiz non si carica, `loadQuizQuestions` ritorna `[]` e `_buildQuestion` va in `RangeError`
  su lista vuota → schermo rosso senza via d'uscita. Nel backlog: rispondere "5" a tutto dà un
  pareggio perfetto (il questionario ha metà domande reverse-scored) e quindi un ENFP a
  confidence 50 presentato con la stessa enfasi di un tipo netto — il che rende concreta la
  voce sul mostrare la confidence; il pattern della route host per le schermate che fanno
  `pop()`; il `catch (_) {}` muto in `_loadExisting`. Precisato il perimetro del blocco sui
  widget test: pesa **sottoscriversi** allo stream, non toccarlo — `PersonEditScreen`
  invalida `allPersonsProvider` e pompa lo stesso. Annotata la stringa italiana hardcoded in
  `person_edit` (Epica 5). Nessun commit: in working tree restano anche i 13 file del 27/07.
- 2026-07-29 — Epica 5: **chiusi entrambi i `[!]`, il quiz ora è quello che promette di
  essere**. Scritta la banca vera di item MBTI — 80 per lingua (20 per asse, 10 diretti e 10
  reverse-scored) — e generati i tre asset annidati: short 16, medium 48, long 80, assi
  interlacciati e direzione alternata, con le 16 domande del breve invariate rispetto a quelle
  già pubblicate. Prima i tre file erano **byte-identici** mentre la UI vendeva ~20/~50/~80
  domande e un badge "Più accurato": copy riallineata ai conteggi reali (16·4 min, 48·10 min,
  80·16 min). Chiuso nello stesso giro il secondo `[!]`: un asset che non si carica ora dà una
  schermata d'errore con ritorno alla scelta della lunghezza invece del `RangeError` su lista
  vuota. Sistemata anche la copy della pagina di scelta (`quizChooseLengthAppBar` /
  `quizChooseLengthTitle`, IT+EN), che usava "Test breve" come titolo di una pagina con tre
  lunghezze. Corretto il commento che giustificava il badge con una confidence più alta: la
  metrica è normalizzata per asse e non cresce col numero di domande — il test lungo è più
  *stabile*, non più "sicuro". Nuovi test: `test/assets/quiz_assets_test.dart` (15, sulla
  struttura dei sei asset: conteggi, unicità, bilanciamento per asse, annidamento, parità
  IT/EN) e `test/widgets/quiz_load_error_widget_test.dart` (1). Verifiche: `flutter analyze`
  pulito, 103 test verdi (87→103).
- 2026-07-29 — Chiusura sessione: registrate le voci emerse dal lavoro sul quiz. Un `[!]`
  nuovo in Epica 1, trovato verificando come i loader gestiscono gli errori: le quattro cache
  di `ContentRepository` condividono **un solo** `_loadedLocale`, quindi dopo un cambio di
  lingua una cache riempita in IT viene servita come se fosse EN — e `invalidateCache()`, la
  funzione scritta per evitarlo, non è chiamata da nessuna parte. Accanto, l'incoerenza dei
  loader (quattro inghiottono tutto, `loadMbtiContent` propaga) che lascia scoperti Career fit
  e Team builder ora che la schermata quiz è a posto. In Epica 5: uscire dal quiz a metà perde
  tutte le risposte senza conferma — con 80 domande non è più una seccatura. Nel backlog:
  `person_detail` ha la stessa copy sbagliata appena tolta dal quiz, `QuizQuestion.weight` è
  sempre 1.0 su tutti e 144 gli item, e la banca resta da tenere bilanciata a mano. Confermato
  che il churn dei file generati è ricorrente (stessi 3 file del 27/07).
- 2026-07-29 — **Epica 2 riscritta attorno al profilo ibrido.** Emerso a fine sessione che
  l'obiettivo non è affiancare più sistemi ma **fonderli**: il profilo finale è una sintesi di
  tutta l'evidenza disponibile, pesata per affidabilità. La vecchia Epica 2 descriveva il
  contrario — "selezione del calcolatore in base a `system`", "selezione sistema attivo" — cioè
  un centralino con un sistema alla volta; quelle due voci sono superate e restano annotate a
  fondo epica. Decisione presa: l'ibrido è **derivato al volo** dai profili per-sistema, mai
  materializzato (niente schema nuovo, niente migration, niente invalidazione: si aggiorna da
  sé). Ne discendono i punti nuovi dell'epica: spazio latente comune, calibrazione delle scale,
  motore di fusione pesato per `confidence`/`source`/`updatedAt`, dichiarazione di copertura del
  profilo, Big Five per primo (è continuo ed è l'unico che copre il Nevroticismo, che MBTI non
  misura), consumatori a valle e `ShareCode` da ripensare. La voce di Epica 5 sulla fedeltà
  dell'evidenza (`MbtiProfile.fromType` appiattisce tutto a `±70`) è promossa da rifinitura a
  **blocco**: verificata oggi nel codice, è il primo passo di tutta l'epica.
- 2026-07-29 — Epica 1: **chiuso il `[!]` sulla cache di `ContentRepository` e, con lo stesso
  giro, la politica sugli errori dei loader**. Il `_loadedLocale` unico è sostituito da una
  cache per contenuto **indicizzata per locale**, quindi la lingua è parte della chiave e non
  uno stato globale che l'ultimo loader vince; `invalidateCache()`, mai chiamato in `lib/`, è
  stato rimosso perché ora non serve. Politica sugli errori: il repository **propaga** e i
  chiamanti mostrano un errore esplicito (prima quattro loader su cinque restituivano contenuto
  vuoto, cioè schermate bianche senza spiegazione). Adeguati i chiamanti: Career fit aveva
  `!snap.hasData` e con la propagazione avrebbe girato all'infinito; `person_detail` non fa più
  sparire in silenzio la sezione affinità quando è l'asset a mancare; `QuizScreen` incanala
  l'eccezione nella lista vuota che già rendeva come errore. Rimosso da Team builder un
  `FutureBuilder` che caricava `team_objectives.json` senza **mai** leggerlo: era solo un modo
  per far bloccare i risultati da un asset non usato. Per rendere testabile tutto questo,
  `ContentRepository` accetta ora un `AssetBundle` opzionale (default `rootBundle`). Verifiche:
  `flutter analyze` pulito, 114 test verdi (103→114, +11 in
  `test/data/repositories/content_repository_test.dart`).
- 2026-07-29 — Chiusura sessione: registrate le voci emerse dal lavoro sui loader di
  contenuto. Un `[!]` nuovo in Epica 6, trovato rimuovendo il `FutureBuilder` inutile del Team
  builder: quella schermata non ha **mai** mostrato il suo contenuto tradotto: obiettivi,
  punti di forza e blind spot passano da tre stub che restituiscono la chiave, quindi
  l'utente legge `creative` / `NI, TE` uguali in IT e in EN mentre `team_objectives.json`
  (title + description + ideal_profile, in entrambe le lingue) non viene letto da nessuno.
  Nel backlog: i `FutureBuilder` costruiscono il future dentro `build` (e
  `_computeAffinityWithSelf` rifà due query DB più il calcolo a ogni rebuild); il repo non è
  `dart format` clean — verificato su file non toccati — quindi formattare un file solo
  produce un diff enorme e la CI non se ne accorge; il pattern dell'`AssetBundle` iniettabile
  per i test, con la trappola della cache interna di `rootBundle`; e il quiz come unico
  contenuto rimasto senza cache.
- 2026-07-30 — Epica 6 `[!]` **chiuso: il Team builder mostra finalmente testo, non chiavi** —
  e dietro c'erano due bug peggiori. Il lavoro previsto: obiettivi rinominati con le sei stringhe
  ARB `teamObj*` (esistevano da sempre, non usate da nessuno), descrizione e `ideal_profile`
  dell'obiettivo cablati da `team_objectives.json`, punti di forza e blind spot risolti su due
  sezioni nuove dello stesso asset (8+8 voci per lingua, una per funzione cognitiva), estensione
  stub con i tre commenti-appunto rimossa. Il contenuto arriva da un `FutureProvider.family` per
  lingua invece che da un `FutureBuilder` costruito in `build`, così la schermata non rilegge
  l'asset a ogni selezione. **Primo bug trovato dai test**: `_CandidateList.persons` era
  `List<dynamic>`, quindi `displayName.characters` era una chiamata dinamica a un metodo di
  estensione → `NoSuchMethodError` a runtime, anche in release: la lista candidati era un
  riquadro d'errore per chiunque avesse almeno una persona in rubrica, e `analyze` non poteva
  vederlo. **Secondo bug, più grosso**: `pubspec.yaml` dichiarava i contenuti file per file
  (`mbti.json`), quindi `career_roles.json`, `relationship_dynamics.json` e
  `team_objectives.json` non erano **mai** stati messi nel bundle — confermato ispezionando
  `build/web`. Dal cambio del 29/07 (loader che propagano) questo significa Career fit e la
  sezione affinità di `person_detail` rotti **sulla PWA live**; prima degradavano in silenzio, e
  per questo nessuno se n'era accorto. Fix: dichiarare le directory, come già per il quiz;
  verificato con un `flutter build web --release` che ora i file ci sono tutti e otto. Nuovi
  test: `test/assets/content_assets_test.dart` (8, caricano i quattro contenuti in IT+EN
  attraverso `rootBundle` e verificano che le chiavi combacino con quelle dei motori) e
  `test/widgets/team_builder_content_widget_test.dart` (2, IT ed EN sul vero asset). Il secondo
  ha richiesto di sostituire `allPersonsProvider` con uno `Stream.value`: è una via d'uscita dal
  blocco sui widget test delle schermate con `.watch()`, annotata nel backlog. Verifiche:
  `flutter analyze` pulito, 124 test verdi (114→124), build web di release OK.
- 2026-07-30 — Chiusura sessione: registrate le voci emerse dal lavoro sul Team builder, due
  delle quali **misurate** e non solo intuite. In Epica 1: attivare `avoid_dynamic_calls`, il
  lint che avrebbe preso a compile time il crash di oggi — provato in via temporanea, sono 22
  violazioni (9 in `lib/`, 13 in un solo file di test), tutte indicizzazioni innocue di
  `Map<String, dynamic>`, quindi il lavoro è tipizzare nove letture e accendere la regola; e
  estendere `content_assets_test` alle chiavi di `career_roles.json` e
  `relationship_dynamics.json`, che ho verificato allineate a mano ma che niente fissa (con il
  `?? key` a valle, un id rinominato torna a schermo come chiave grezza). In Epica 7: la PWA
  online è **ancora** quella senza contenuti finché non si pusha, e la verifica va fatta sulle
  schermate, non sull'HTTP 200 dei JSON. In Epica 8: `CLAUDE.md` non dice da nessuna parte che
  un asset non dichiarato in `pubspec.yaml` non viene spedito, che è la trappola di oggi. In
  Epica 6: il `title` degli obiettivi ora ha due sorgenti e quella nel JSON non è più letta (e
  il test nuovo la pretende, cioè fissa contenuto morto). Nel backlog: il suffisso `_title` che
  il motore delle dinamiche aggiunge e che il JSON non ha, ricucito da sei `replaceAll` in
  `person_detail`.
- 2026-07-31 — Epica 1: **accese le due difese automatiche mancanti**, entrambe nate dai bug
  muti del 30/07. (1) `avoid_dynamic_calls` è attivo: le 22 violazioni misurate ieri sono state
  **tipizzate**, non silenziate — voce del ruolo come `Map<String, dynamic>?` in `career_fit`,
  helper `_entry` in `person_detail`, helper `rows()` che fa un `.cast()` unico sulle liste
  uscite da `jsonDecode` nel test dei chat tool. È il lint che avrebbe preso a compile time il
  `NoSuchMethodError` del Team builder. (2) `content_assets_test` non si ferma più a "non
  vuoto" su `career_roles.json` e `relationship_dynamics.json`: parte dalle sorgenti delle
  chiavi (i 16 `id` di `kCareerRoles`, `kFunctionConflicts`, gli 8 `growth_<funzione>` da
  `CognitiveFunction.values`, `kCommunicationPatterns` + `comm_default`) e pretende stringhe
  non vuote, perché una voce vuota si legge come una mancante. Chiusa nello stesso giro la voce
  di backlog sul suffisso `_title`: il motore delle dinamiche emette ora la chiave nuda in un
  solo campo `contentKey` (prima `titleKey` + un `descriptionKey` che la UI non usava), e le sei
  `replaceAll('_title','')` di `person_detail` sono sparite — erano anche sei delle nove
  violazioni in `lib/`. `CLAUDE.md` allineato sul contratto delle chiavi. Verifiche: `flutter
  analyze` pulito **con la regola accesa**, 124 test verdi (invariati: sono le asserzioni
  esistenti a essere state rese esigenti), e una sonda usa-e-getta sull'asset IT a confermare
  che il test nuovo ha i denti.
- 2026-07-31 — Chiusura sessione: registrate le voci emerse dal lavoro sui lint e sugli asset,
  tre delle quattro **misurate o verificate nel codice**, non intuite. In Epica 1: accese in via
  temporanea le tre opzioni `strict-*` dell'analyzer — il gradino sopra `avoid_dynamic_calls`,
  perché scattano al punto di assegnazione e non solo a quello di chiamata — e la distribuzione
  delle 81 diagnostiche è la scoperta vera: **44 stanno tutte in `data_backup.dart`**, tutte
  `argument_type_not_assignable`, cioè il restore infila i campi del JSON dritti dentro
  parametri `int`/`String`/`bool` senza verificarli; un backup malformato non viene rifiutato,
  esplode a metà import. Sempre in Epica 1: dopo il giro di oggi `mbti.json` è rimasto il
  contenuto **meno** verificato dei quattro — il test controlla che i 16 tipi e le 8 funzioni
  esistano ma nessuno dei ~12 e ~17 campi che `content_viewer` legge, e le 4 dicotomie non le
  guarda affatto. In Epica 6: `CareerRole.titleKey` non risolve da nessuna parte (il JSON è
  indicizzato per `id`, e nelle ARB non c'è nessuna chiave `career_*` — verificato), quindi il
  fallback di `career_fit` può stampare `career_researcher` e il chatbot riceve quella stringa
  come `key`; è il gemello rovesciato del `title` degli obiettivi, che di sorgenti ne ha due.
  Nel backlog: il pattern per cui un test sul contenuto deve derivare le chiavi attese dalle
  costanti del motore invece di copiarle, con il corollario di pretendere stringhe non vuote.
- 2026-07-31 — Epica 1: **il restore di un backup ora valida quello che legge, e `strict-casts` è
  acceso**. La deserializzazione di `data_backup.dart` — 44 delle 81 diagnostiche `strict-*`
  misurate ieri, tutte nello stesso file — passa da campi `dynamic` infilati nei costruttori
  generati a lettori tipizzati che sollevano `BackupFormatException` con il percorso del valore
  rotto: un backup manomesso viene rifiutato con `persons[2].createdAt is missing` invece di
  esplodere in `TypeError` a metà import. Stesso trattamento per ZIP illeggibile, `data.json`
  mancante e JSON non valido, che prima uscivano come eccezioni grezze del pacchetto. Trovato
  lavorandoci e corretto: con `replace: true` la cancellazione stava in una transazione **separata**
  dagli insert, quindi un errore a metà scrittura lasciava il DB vuoto — ora è una transazione
  sola, e un test lo pinza (backup malformato + `replace` → l'errore arriva e le righe vecchie sono
  ancora lì). Conseguenza immediata: con quei 44 cast via, `strict-casts` da solo è pulito su tutto
  il repo, quindi da misura temporanea diventa regola in `analysis_options.yaml`; le altre due
  `strict-*` restano spente (50 diagnostiche residue, tutte letterali senza tipo, rumore).
  Verifiche: `flutter analyze` pulito **con la regola nuova**, 137 test verdi (124→137, +13).
  Emerso da una sonda usa-e-getta a margine: `PRAGMA foreign_keys` è **0**, quindi i
  `KeyAction.cascade` dello schema non fanno niente e cancellare una persona lascia orfani profilo,
  relazioni, gruppi ed eventi (nuova voce in Epica 1). Nel backlog: le tre stringhe italiane
  hardcoded di `settings_screen` sul percorso backup.
- 2026-07-31 — Chiusura sessione: registrate le voci emerse dal lavoro sul backup, tutte
  verificate mentre si scriveva. In Epica 1, accanto alle foreign key inerti: il restore **legge**
  il `schemaVersion` del backup solo per rifiutare quelli più nuovi, ma poi parsifica tutto con
  un'unica lista di campi obbligatori — che i backup v1/v2 si aprano ancora dipende solo dal fatto
  che le due colonne aggiunte da allora sono nullable, quindi la prima colonna NOT NULL romperà il
  restore dei backup vecchi, e ora lo dirà a voce alta invece di degradare a caso. Nel backlog:
  il warning `multiple databases` di drift sporca l'output dei test con uno stack trace per
  istanza ed è un falso positivo (ogni test ha il suo executor); e il pattern per cui bisogna
  fabbricare a mano l'archivio rotto, perché un round-trip export→import non può produrre nessun
  caso cattivo. Chiarita infine la voce sul `dart format`: i tre file di oggi risultano "Changed"
  **anche nel codice appena scritto**, e il diff mostra che a cambiare è lo stile — l'SDK 3.11.5
  ha il formatter "tall style" di Dart 3.7, quindi il commit solo-formato rifà l'intero repo e non
  qualche punto stantio.
- 2026-08-02 — Epica 1: **le foreign key sono attive, le cascade dello schema fanno finalmente
  qualcosa**. `beforeOpen` accende `PRAGMA foreign_keys` (gira dopo le migration, che restano
  quindi con i controlli spenti) e `_purgeOrphans` spazza le righe che le cascade inerti avevano
  già lasciato indietro — senza quel passaggio i DB esistenti non avrebbero modo di ripulirsi e gli
  orfani continuerebbero a finire in ogni backup. Trovato lavorandoci e corretto nello stesso giro:
  accendere le FK **introduceva** una perdita di dati sull'import in merge, perché SQLite esegue
  REPLACE come DELETE + INSERT e la cancellazione ora cascata — un backup che contiene una persona
  già in locale le portava via profilo, relazioni, appartenenze ed eventi (misurato con una sonda:
  1 profilo prima, 0 dopo). I sei insert dell'import passano a `insertOnConflictUpdate`, che
  riscrive la riga sul posto. Nuovi test: `test/data/database/foreign_keys_test.dart` (6, incluso
  il purge su un DB file-backed chiuso e riaperto, l'unico modo di riprodurre un DB pre-pragma) e
  uno di regressione sul merge in `data_backup_service_test.dart`. Entrambi provati con una sonda
  usa-e-getta: senza `beforeOpen` ne falliscono 4 su 6, con `insertOrReplace` fallisce quello del
  merge. Verifiche: `flutter analyze` pulito, 144 test verdi (137→144, +7).
- 2026-08-02 — Chiusura sessione: registrate le voci emerse dal lavoro sulle foreign key, tutte
  **misurate con una sonda** e non intuite. Un `[!]` nuovo in Epica 1, che è il rovescio della
  medaglia del fix di oggi: un backup che contiene una riga orfana — cioè, per definizione,
  qualsiasi backup esportato da un DB in cui era stata cancellata una persona, che è tutto il punto
  del bug appena chiuso — ora fallisce l'import con `SqliteException(787)`, un codice che non nomina
  né tabella né riga e che contraddice la politica degli errori del 31/07. La transazione fa
  rollback, quindi l'import è impossibile ma non distruttivo. Verificato anche che in `lib/` non
  resta **nessun** altro `insertOrReplace`, quindi la trappola del REPLACE che cascata è chiusa
  ovunque oggi ed è solo un rischio in avanti (annotata in `CLAUDE.md`). Nel backlog: l'import in
  merge sovrascrive per id **locale** e può quindi riscrivere una persona estranea (difetto che
  precede il cambio di oggi, e che pone la stessa domanda del `[!]` — cosa identifica una riga
  fuori dal dispositivo che l'ha creata); `_purgeOrphans` cancella righe senza dirlo a nessuno, che
  è un fallimento muto della famiglia che il progetto continua a chiudere altrove; e le FK non sono
  mai state esercitate su web, da aggiungere al walkthrough sulla PWA.
- 2026-08-02 — Epica 1 `[!]` **chiuso: i backup con righe orfane si importano di nuovo**. Era il
  rovescio del fix di stamattina: acceso il controllo delle foreign key, ogni ZIP esportato da un DB
  in cui era stata cancellata una persona — cioè, per definizione, ogni backup toccato dal bug
  appena chiuso — falliva l'import con `SqliteException(787)`, senza dire quale riga. Delle tre vie
  annotate è stata scelta la **(b)**: `BackupData.withoutOrphans()` scarta i figli che puntano a un
  genitore assente dall'archivio (profili, entrambi i capi delle relazioni, entrambi i genitori di
  `personGroups`, eventi) invece di rifiutare tutto, che è l'unica scelta che rende importabili gli
  archivi già in mano alle persone e la stessa che `_purgeOrphans` prende sul lato DB. Il criterio è
  "genitore presente **nel backup**" anche in merge, perché gli id sono `autoIncrement` locali e un
  numero che combacia sul dispositivo non è la stessa persona. Della via (a) è rimasto il
  vocabolario degli errori del 31/07: ogni riga scartata è nominata come
  `profiles[1].personId points to person 7, missing from this backup`. La (c) è stata scartata
  perché irraggiungibile — con il purge all'apertura, l'export non ha più orfani da filtrare. Niente
  perdita muta: `importFromBytes` restituisce un `BackupImportReport` e la snackbar di
  `settings_screen` dice quante righe sono state scartate (`backupImportSuccess` /
  `backupImportSkipped` con plurale ICU, IT+EN; la prima chiude una delle tre stringhe italiane
  hardcoded del backlog). Verifiche: `flutter analyze` pulito, 152 test verdi (144→152, +8), e una
  sonda usa-e-getta che disattiva `withoutOrphans` per confermare che i test nuovi cadono con
  esattamente il 787 di partenza. Nel backlog: le due spazzate di orfani (SQL nel DB, Dart nel
  backup) sono la stessa regola scritta due volte e nessun test le tiene allineate.
- 2026-08-02 — Chiusura sessione: registrate le voci emerse dal lavoro sugli orfani nei backup. Un
  `[!]` nuovo in Epica 1, **misurato con una sonda** e non dedotto, ed è un lato tagliente del fix
  di poche ore prima: la politica "scarta e conta" non ha soglia, quindi con `replace: true` un
  archivio che dichiara figli e **nessun** genitore cancella il DB, non ha niente da reinserire e
  committa, con la snackbar che dice "Dati importati" (sonda: 1 persona e 1 profilo prima, 0 e 0
  dopo). Lo stesso archivio, prima del fix, dava 787 e rollback: la via (b) ha convertito un
  fallimento sicuro in una perdita silenziosa nel caso patologico, quindi il rimedio non è tornare
  a rifiutare tutto ma mettere una soglia. Accanto, sempre in Epica 1: il `BackupImportReport`
  contiene il percorso di ogni riga scartata e la UI ne mostra solo il conteggio, cioè il
  vocabolario introdotto dalla politica del 31/07 si ferma al confine con la schermata. Rafforzate
  quattro voci esistenti invece di duplicarle: `_purgeOrphans` resta muto mentre l'import degli
  stessi orfani ora li elenca (stessa regola, una sponda parla e l'altra no); il churn dei file
  generati è stato quantificato con `git log --name-only` e compare in **ogni** commit che abbia
  mai toccato una `.arb`, quindi è la norma da sempre e non un effetto delle sessioni recenti; le
  fixture di backup sono scritte a mano in tre punti e nessun helper le condivide; e nel backlog la
  nota che `backupImportSkipped` è l'unico plurale ICU del progetto. Nessun commit: le modifiche
  della giornata (fix + roadmap) restano in working tree.
- 2026-08-02 — Epica 1 `[!]` **chiuso in giornata: il lato tagliente del fix sugli orfani non c'è
  più**. `BackupData.checkParentSectionsPresent()` gira **prima** che la transazione si apra e
  rifiuta l'archivio in cui una intera sezione genitore è assente mentre esistono righe che la
  richiedono, con un errore che dice quante righe e in quali sezioni (`persons is empty but 3 rows
  in profiles, events still need a person: the backup looks truncated, not merely inconsistent`).
  Scelta la regola netta invece del rapporto: nessuna costante da tarare, nessun falso positivo, e
  copre il caso misurato poche ore prima. Il buco che resta è dichiarato, non nascosto — un archivio
  **parzialmente** troncato passa ancora e scarta quasi tutto, e il rapporto tornerà sul tavolo se
  emergerà un caso reale con dei dati sotto. Tenuto esplicito da un test il confine con il backup
  legittimamente vuoto, che deve continuare ad azzerare l'app con `replace`. Verifiche: `flutter
  analyze` pulito, 159 test verdi (152→159, +7), e una sonda che commenta la chiamata per
  confermare che il test del caso misurato torna a svuotare il DB senza il controllo. Resta aperta
  in Epica 1 la voce sul dettaglio del report che non arriva all'utente, che questo fix rende più
  pesante: ora il caso netto è rifiutato a voce alta, quello parziale no.
- 2026-08-03 — Epica 1: **`mbti.json` verificato, e la scheda MBTI non crasha più**. Il lavoro
  previsto era la rete mancante sul contenuto più grosso dell'app: `content_assets_test` ora
  verifica per lingua i campi che le schede leggono davvero (9 per tipo, 7 per funzione, i 4 assi
  con poli, marker e miti) pretendendo stringhe e liste non vuote, e **deriva da `kMbtiStacks`**
  ciò che il JSON ripete del motore invece di fissarne una copia. Da lì sono usciti due bug.
  Nel contenuto: `Si.tertiary_in` e `Si.inferior_in` attribuivano Si a quattro tipi sbagliati,
  fra cui ENFJ ed ENTJ che nello stack non ce l'hanno. Nel lettore, ed è quello grosso:
  `content_viewer_screen` leggeva `description` come lista (l'asset la scrive come una stringa a
  paragrafi) e `poles` come lista (è un oggetto per lettera dell'asse) → `TypeError` in `build`
  su **tutte e tre** le schede, due delle quali si aprono da `person_detail`: la scheda del tipo
  e quella della funzione cognitiva erano rotte in produzione sulla PWA, e `analyze` non poteva
  vederlo (cast su `dynamic` uscito da `jsonDecode`, stessa famiglia del 2026-07-30). Misurato
  prima del fix con il nuovo `content_viewer_widget_test.dart`, che pompa la schermata vera
  sull'asset vero. Epica 6, stesso giro: rese visibili tre sezioni scritte e mai renderizzate —
  esempi celebri e compatibilità (le cinque etichette ARB esistevano già senza lettori) e le
  **4 dicotomie**, che non avevano alcun punto d'ingresso in tutta l'app e ora si aprono dalle
  quattro barre degli assi nella pagina risultati del quiz; unica stringa nuova
  `contentSectionMyths` (IT+EN), che toglie il `'Miti comuni'` hardcoded. Verifiche: `flutter
  analyze` pulito, 171 test verdi (159→171, +12: 8 sull'asset, 6 sul lettore, di cui uno percorre
  il test breve e apre la scheda I/E dai risultati). Registrate le voci emerse: dieci dei
  diciassette campi per funzione non li legge nessuno (Epica 1), `growth_areas` è l'unico campo
  del tipo rimasto senza lettore né etichetta (Epica 6), e nel backlog il pattern per pompare una
  schermata con `FutureBuilder` + spinner, che `pumpAndSettle` non riesce a stabilizzare.
- 2026-08-03 — Chiusura sessione: registrate le voci emerse dal lavoro sul contenuto MBTI, tutte
  verificate nel codice. Due in Epica 1. La prima è la lezione strutturale della giornata: il
  contenuto arriva alle schermate come `Map<String, dynamic>` e **ogni schermata se lo casta da
  sé**, che è la radice comune dei tre bug della stessa famiglia in cinque settimane (30/07 la
  chiamata dinamica, 31/07 i 44 campi del backup, oggi le due forme sbagliate) — e il fix del
  backup ha già mostrato la risposta, lettori tipizzati in un posto solo. La seconda, contata con
  un grep: `GraphScreen`, `PeopleListScreen`, `CareerFitScreen`, `SettingsScreen` e `ShareScreen`
  non compaiono in nessun test, e oggi si è visto cosa può nascondere una schermata mai pompata;
  i due pattern noti (`Stream.value` per il `.watch()`, repository scaldato per lo spinner)
  tolgono l'alibi tecnico. In Epica 6: le dicotomie hanno un solo ingresso, la pagina risultati
  del quiz, quindi chi imposta il tipo a mano non le vede mai e chi fa il test le perde dopo il
  salvataggio. Nel backlog: il separatore `\n\n` dei paragrafi è un contratto che nessun test e
  nessun documento scrive, e le chip di compatibilità appena mostrate sono inerti mentre la rotta
  per aprire la scheda di un tipo esiste già. Nessun commit: le modifiche della giornata (fix,
  test e roadmap) restano in working tree.
