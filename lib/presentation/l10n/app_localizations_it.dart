// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Archetypes';

  @override
  String get navGraph => 'Grafo';

  @override
  String get navPeople => 'Persone';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get navTeamBuilder => 'Team Builder';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionCalculate => 'Calcola';

  @override
  String get teamDisclaimer =>
      'Suggerimenti basati su modello teorico — non sostituiscono valutazione professionale';

  @override
  String get teamObjectiveLabel => 'Obiettivo del Team';

  @override
  String get teamSizeLabel => 'Dimensione';

  @override
  String get teamEditSelection => 'Modifica selezione';

  @override
  String teamSelectCandidates(Object selected, Object size) {
    return 'Seleziona candidati ($selected/$size)';
  }

  @override
  String get teamNoResults => 'Nessun risultato disponibile';

  @override
  String get teamBestMatch => 'Miglior Match';

  @override
  String get teamAlternative => 'Alternativa';

  @override
  String get teamMembers => 'Membri';

  @override
  String get teamObjCreative => 'Ideazione e Creatività';

  @override
  String get teamObjExecution => 'Esecuzione e Consegna';

  @override
  String get teamObjCrisis => 'Gestione Crisi';

  @override
  String get teamObjInnovation => 'Innovazione Sistemica';

  @override
  String get teamObjSupport => 'Cura e Supporto';

  @override
  String get teamObjStrategy => 'Pianificazione Strategica';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionBack => 'Indietro';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionNext => 'Avanti';

  @override
  String get actionPrevious => 'Precedente';

  @override
  String get actionFinish => 'Completa';

  @override
  String get actionSearch => 'Cerca';

  @override
  String get actionFilter => 'Filtra';

  @override
  String get actionExport => 'Esporta';

  @override
  String get actionImport => 'Importa';

  @override
  String get actionLearnMore => 'Approfondisci';

  @override
  String get actionConfirm => 'Conferma';

  @override
  String get onboardingWelcomeTitle => 'Benvenuto in Archetypes';

  @override
  String get onboardingWelcomeSubtitle =>
      'Esplora le tue relazioni attraverso le funzioni cognitive jungiane';

  @override
  String get onboardingYourName => 'Come ti chiami?';

  @override
  String get onboardingNameHint => 'Il tuo nome';

  @override
  String get onboardingChooseMethod => 'Come vuoi inserire la tua personalità?';

  @override
  String get onboardingMethodManual => 'Selezione manuale';

  @override
  String get onboardingMethodManualDesc =>
      'Scegli direttamente il tuo tipo MBTI';

  @override
  String get onboardingMethodTest => 'Test in-app';

  @override
  String get onboardingMethodTestDesc =>
      'Rispondi a un questionario per scoprire il tuo tipo';

  @override
  String get onboardingMethodRecommended => 'Consigliato';

  @override
  String get onboardingMethodGranular => 'Inserimento granulare';

  @override
  String get onboardingMethodGranularDesc =>
      'Specifica i valori delle dicotomie e funzioni cognitive';

  @override
  String get onboardingSelectType => 'Seleziona il tuo tipo MBTI';

  @override
  String get onboardingComplete => 'Inizia l\'esplorazione!';

  @override
  String onboardingStep(int current, int total) {
    return 'Passo $current di $total';
  }

  @override
  String get personName => 'Nome';

  @override
  String get personNickname => 'Soprannome';

  @override
  String get personRole => 'Ruolo';

  @override
  String get personBirthday => 'Data di nascita';

  @override
  String get personGender => 'Genere';

  @override
  String get personNotes => 'Note';

  @override
  String get personFirstMet => 'Data di conoscenza';

  @override
  String get personAvatar => 'Foto';

  @override
  String get personPersonality => 'Personalità';

  @override
  String get personRelationship => 'Relazione con te';

  @override
  String get personAddNew => 'Nuova persona';

  @override
  String get personEditTitle => 'Modifica persona';

  @override
  String get personDetailTitle => 'Profilo';

  @override
  String get personSelf => 'Io';

  @override
  String personDisplayName(String name) {
    return '$name';
  }

  @override
  String get roleFamily => 'Famiglia';

  @override
  String get roleFriend => 'Amico/a';

  @override
  String get rolePartner => 'Partner';

  @override
  String get roleColleague => 'Collega';

  @override
  String get roleAcquaintance => 'Conoscente';

  @override
  String get roleOther => 'Altro';

  @override
  String get mbtiTypeLabel => 'Tipo MBTI';

  @override
  String get mbtiSelectType => 'Seleziona tipo';

  @override
  String get mbtiConfidence => 'Certezza';

  @override
  String mbtiConfidenceHint(int value) {
    return 'Quanto sei sicuro di questo tipo? ($value%)';
  }

  @override
  String get mbtiSourceManual => 'Selezione manuale';

  @override
  String get mbtiSourceQuizShort => 'Test breve';

  @override
  String get mbtiSourceQuizMedium => 'Test medio';

  @override
  String get mbtiSourceQuizLong => 'Test completo';

  @override
  String get mbtiSourceGranular => 'Inserimento granulare';

  @override
  String get mbtiDominant => 'Dominante';

  @override
  String get mbtiAuxiliary => 'Ausiliare';

  @override
  String get mbtiTertiary => 'Terziaria';

  @override
  String get mbtiInferior => 'Inferiore';

  @override
  String mbtiLearnAboutType(String type) {
    return 'Scopri il tipo $type';
  }

  @override
  String mbtiLearnAboutFunction(String function) {
    return 'Scopri la funzione $function';
  }

  @override
  String get mbtiGranularTitle => 'Imposta dicotomie';

  @override
  String get mbtiDichotomyIE => 'Introversione / Estroversione';

  @override
  String get mbtiDichotomyNS => 'Intuizione / Sensazione';

  @override
  String get mbtiDichotomyTF => 'Pensiero / Sentimento';

  @override
  String get mbtiDichotomyJP => 'Giudizio / Percezione';

  @override
  String get relationshipKind => 'Tipo di relazione';

  @override
  String get relationshipStrength => 'Intensità percepita';

  @override
  String get relationshipNote => 'Note sulla relazione';

  @override
  String get relationshipStartDate => 'Data inizio';

  @override
  String get relationKindFriendship => 'Amicizia';

  @override
  String get relationKindRomantic => 'Romantica';

  @override
  String get relationKindFamily => 'Familiare';

  @override
  String get relationKindProfessional => 'Professionale';

  @override
  String get relationKindAcquaintance => 'Conoscenza';

  @override
  String get relationKindConflict => 'Conflitto';

  @override
  String get affinityTitle => 'Affinità';

  @override
  String affinityScore(int score) {
    return 'Punteggio: $score/100';
  }

  @override
  String get affinityHigh => 'Alta affinità';

  @override
  String get affinityMedium => 'Buona affinità';

  @override
  String get affinityLow => 'Affinità moderata';

  @override
  String get affinityBreakdown => 'Dettaglio funzioni';

  @override
  String affinityWith(String name) {
    return 'Affinità con $name';
  }

  @override
  String get affinityNoProfile =>
      'Aggiungi un profilo MBTI per calcolare l\'affinità';

  @override
  String get affinityDominantComplement => 'Funzioni dominanti complementari';

  @override
  String get affinityCoreComplement => 'Complementarità nel nucleo';

  @override
  String get affinityComplement => 'Funzioni complementari';

  @override
  String get affinitySimilarFunction => 'Funzioni condivise';

  @override
  String get reportFrictionPoints => 'Punti di attrito prevedibili';

  @override
  String get reportGrowthAreas => 'Aree di crescita reciproca';

  @override
  String get reportCommunication => 'Dinamiche di comunicazione';

  @override
  String get reportAxisAnalysis => 'Analisi per asse';

  @override
  String get reportAxisAligned => 'Allineati';

  @override
  String get reportAxisComplementary => 'Complementari';

  @override
  String get reportAxisTension => 'In tensione';

  @override
  String get axisIE => 'Introversione / Estroversione';

  @override
  String get axisNS => 'Intuizione / Sensazione';

  @override
  String get axisTF => 'Pensiero / Sentimento';

  @override
  String get axisJP => 'Giudizio / Percezione';

  @override
  String get careerFitTitle => 'Ruoli ideali';

  @override
  String get careerDisclaimer =>
      'Suggerimenti basati sulla teoria delle funzioni cognitive — non sostituiscono un orientamento professionale qualificato.';

  @override
  String get graphTitle => 'Grafo relazioni';

  @override
  String get graphModeFree => 'Libero';

  @override
  String get graphModeCluster => 'Per tipo';

  @override
  String get graphModeTimeline => 'Cronologico';

  @override
  String get graphNoConnections =>
      'Aggiungi persone per visualizzare le relazioni';

  @override
  String get graphTapPerson => 'Tocca una persona per i dettagli';

  @override
  String get graphFilterGroups => 'Filtra per gruppo';

  @override
  String get graphFilterTypes => 'Filtra per tipo MBTI';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get settingsExportData => 'Esporta dati';

  @override
  String get settingsImportData => 'Importa dati';

  @override
  String get settingsExportDesc => 'Salva tutti i tuoi dati come file ZIP';

  @override
  String get settingsImportDesc => 'Ripristina dati da un file ZIP';

  @override
  String get settingsShareProfile => 'Condividi il mio profilo';

  @override
  String get settingsImportText => 'Importa da testo';

  @override
  String get settingsImportTextDesc =>
      'Incolla un codice profilo per aggiungere una persona';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get importDialogTitle => 'Importa profilo';

  @override
  String get importDialogHint => 'Incolla il codice qui...';

  @override
  String get importDialogError => 'Codice non valido o versione non supportata';

  @override
  String get importPreviewTitle => 'Anteprima importazione';

  @override
  String shareProfileText(String payload) {
    return 'Ecco il mio profilo Archetypes:\n\n$payload';
  }

  @override
  String settingsVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get quizShort => 'Test breve';

  @override
  String get quizShortDesc => '~20 domande · 5 min';

  @override
  String get quizMedium => 'Test medio';

  @override
  String get quizMediumDesc => '~50 domande · 12 min';

  @override
  String get quizLong => 'Test completo';

  @override
  String get quizLongDesc => '~80 domande · 20 min';

  @override
  String get quizMostAccurate => 'Più accurato';

  @override
  String get quizStart => 'Inizia il test';

  @override
  String quizQuestion(int current, int total) {
    return 'Domanda $current di $total';
  }

  @override
  String get quizResults => 'Risultati';

  @override
  String quizResultType(String type) {
    return 'Il tuo tipo è $type';
  }

  @override
  String get quizAgree => 'Concordo';

  @override
  String get quizDisagree => 'Non concordo';

  @override
  String get contentSectionStrengths => 'Punti di forza';

  @override
  String get contentSectionWeaknesses => 'Aree di crescita';

  @override
  String get contentSectionRelationships => 'Nelle relazioni';

  @override
  String get contentSectionWork => 'Nel lavoro';

  @override
  String get contentSectionStack => 'Stack funzionale';

  @override
  String get contentSectionCompatibility => 'Compatibilità';

  @override
  String get contentSectionBehaviors => 'Comportamenti tipici';

  @override
  String get contentSectionExamples => 'Esempi celebri';

  @override
  String get contentHighAffinity => 'Alta affinità';

  @override
  String get contentGoodWorking => 'Buona collaborazione';

  @override
  String get contentChallengingGrowth => 'Crescita stimolante';

  @override
  String get errorGeneric => 'Si è verificato un errore';

  @override
  String get retry => 'Riprova';

  @override
  String get errorNotFound => 'Contenuto non trovato';

  @override
  String get errorImportFailed => 'Importazione fallita';

  @override
  String get errorExportFailed => 'Esportazione fallita';

  @override
  String get emptyPeopleList => 'Nessuna persona aggiunta ancora';

  @override
  String get emptyPeopleListAction => 'Aggiungi la tua prima persona';

  @override
  String get emptyGraph => 'Il grafo è vuoto';

  @override
  String get confirmDelete => 'Eliminare questa persona?';

  @override
  String get confirmDeleteBody =>
      'Tutti i dati relativi a questa persona verranno eliminati. Questa azione non può essere annullata.';

  @override
  String get confirmDeleteAction => 'Elimina definitivamente';

  @override
  String get languageIt => 'Italiano';

  @override
  String get languageEn => 'English';

  @override
  String get tabPersonality => 'Personalità';

  @override
  String get tabRelationship => 'Relazione';

  @override
  String get tabNotes => 'Note';

  @override
  String get tabTimeline => 'Timeline';

  @override
  String get groupLabel => 'Gruppo';

  @override
  String get groupAdd => 'Nuovo gruppo';

  @override
  String get groupColor => 'Colore';

  @override
  String get groupName => 'Nome gruppo';

  @override
  String get groupNoGroups => 'Nessun gruppo';

  @override
  String get contentTypeMbti => 'Tipo MBTI';

  @override
  String get contentTypeFunction => 'Funzione cognitiva';

  @override
  String get contentTypeDichotomy => 'Dicotomia';

  @override
  String get contentTypeAffinity => 'Affinità';
}
