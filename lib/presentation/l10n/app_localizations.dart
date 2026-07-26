import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Nome dell'applicazione
  ///
  /// In it, this message translates to:
  /// **'Archetypes'**
  String get appName;

  /// No description provided for @navGraph.
  ///
  /// In it, this message translates to:
  /// **'Grafo'**
  String get navGraph;

  /// No description provided for @navPeople.
  ///
  /// In it, this message translates to:
  /// **'Persone'**
  String get navPeople;

  /// No description provided for @navSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get navSettings;

  /// No description provided for @navTeamBuilder.
  ///
  /// In it, this message translates to:
  /// **'Team Builder'**
  String get navTeamBuilder;

  /// No description provided for @actionAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get actionAdd;

  /// No description provided for @actionCalculate.
  ///
  /// In it, this message translates to:
  /// **'Calcola'**
  String get actionCalculate;

  /// No description provided for @teamDisclaimer.
  ///
  /// In it, this message translates to:
  /// **'Suggerimenti basati su modello teorico — non sostituiscono valutazione professionale'**
  String get teamDisclaimer;

  /// No description provided for @teamObjectiveLabel.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo del Team'**
  String get teamObjectiveLabel;

  /// No description provided for @teamSizeLabel.
  ///
  /// In it, this message translates to:
  /// **'Dimensione'**
  String get teamSizeLabel;

  /// No description provided for @teamEditSelection.
  ///
  /// In it, this message translates to:
  /// **'Modifica selezione'**
  String get teamEditSelection;

  /// No description provided for @teamSelectCandidates.
  ///
  /// In it, this message translates to:
  /// **'Seleziona candidati ({selected}/{size})'**
  String teamSelectCandidates(Object selected, Object size);

  /// No description provided for @teamNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun risultato disponibile'**
  String get teamNoResults;

  /// No description provided for @teamBestMatch.
  ///
  /// In it, this message translates to:
  /// **'Miglior Match'**
  String get teamBestMatch;

  /// No description provided for @teamAlternative.
  ///
  /// In it, this message translates to:
  /// **'Alternativa'**
  String get teamAlternative;

  /// No description provided for @teamMembers.
  ///
  /// In it, this message translates to:
  /// **'Membri'**
  String get teamMembers;

  /// No description provided for @teamObjCreative.
  ///
  /// In it, this message translates to:
  /// **'Ideazione e Creatività'**
  String get teamObjCreative;

  /// No description provided for @teamObjExecution.
  ///
  /// In it, this message translates to:
  /// **'Esecuzione e Consegna'**
  String get teamObjExecution;

  /// No description provided for @teamObjCrisis.
  ///
  /// In it, this message translates to:
  /// **'Gestione Crisi'**
  String get teamObjCrisis;

  /// No description provided for @teamObjInnovation.
  ///
  /// In it, this message translates to:
  /// **'Innovazione Sistemica'**
  String get teamObjInnovation;

  /// No description provided for @teamObjSupport.
  ///
  /// In it, this message translates to:
  /// **'Cura e Supporto'**
  String get teamObjSupport;

  /// No description provided for @teamObjStrategy.
  ///
  /// In it, this message translates to:
  /// **'Pianificazione Strategica'**
  String get teamObjStrategy;

  /// No description provided for @actionSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get actionEdit;

  /// No description provided for @actionBack.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get actionBack;

  /// No description provided for @actionClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get actionClose;

  /// No description provided for @actionNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get actionNext;

  /// No description provided for @actionPrevious.
  ///
  /// In it, this message translates to:
  /// **'Precedente'**
  String get actionPrevious;

  /// No description provided for @actionFinish.
  ///
  /// In it, this message translates to:
  /// **'Completa'**
  String get actionFinish;

  /// No description provided for @actionSearch.
  ///
  /// In it, this message translates to:
  /// **'Cerca'**
  String get actionSearch;

  /// No description provided for @actionFilter.
  ///
  /// In it, this message translates to:
  /// **'Filtra'**
  String get actionFilter;

  /// No description provided for @actionExport.
  ///
  /// In it, this message translates to:
  /// **'Esporta'**
  String get actionExport;

  /// No description provided for @actionImport.
  ///
  /// In it, this message translates to:
  /// **'Importa'**
  String get actionImport;

  /// No description provided for @actionLearnMore.
  ///
  /// In it, this message translates to:
  /// **'Approfondisci'**
  String get actionLearnMore;

  /// No description provided for @actionConfirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get actionConfirm;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto in Archetypes'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Esplora le tue relazioni attraverso le funzioni cognitive jungiane'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingYourName.
  ///
  /// In it, this message translates to:
  /// **'Come ti chiami?'**
  String get onboardingYourName;

  /// No description provided for @onboardingNameHint.
  ///
  /// In it, this message translates to:
  /// **'Il tuo nome'**
  String get onboardingNameHint;

  /// No description provided for @onboardingChooseMethod.
  ///
  /// In it, this message translates to:
  /// **'Come vuoi inserire la tua personalità?'**
  String get onboardingChooseMethod;

  /// No description provided for @onboardingMethodManual.
  ///
  /// In it, this message translates to:
  /// **'Selezione manuale'**
  String get onboardingMethodManual;

  /// No description provided for @onboardingMethodManualDesc.
  ///
  /// In it, this message translates to:
  /// **'Scegli direttamente il tuo tipo MBTI'**
  String get onboardingMethodManualDesc;

  /// No description provided for @onboardingMethodTest.
  ///
  /// In it, this message translates to:
  /// **'Test in-app'**
  String get onboardingMethodTest;

  /// No description provided for @onboardingMethodTestDesc.
  ///
  /// In it, this message translates to:
  /// **'Rispondi a un questionario per scoprire il tuo tipo'**
  String get onboardingMethodTestDesc;

  /// No description provided for @onboardingMethodRecommended.
  ///
  /// In it, this message translates to:
  /// **'Consigliato'**
  String get onboardingMethodRecommended;

  /// No description provided for @onboardingMethodGranular.
  ///
  /// In it, this message translates to:
  /// **'Inserimento granulare'**
  String get onboardingMethodGranular;

  /// No description provided for @onboardingMethodGranularDesc.
  ///
  /// In it, this message translates to:
  /// **'Specifica i valori delle dicotomie e funzioni cognitive'**
  String get onboardingMethodGranularDesc;

  /// No description provided for @onboardingSelectType.
  ///
  /// In it, this message translates to:
  /// **'Seleziona il tuo tipo MBTI'**
  String get onboardingSelectType;

  /// No description provided for @onboardingComplete.
  ///
  /// In it, this message translates to:
  /// **'Inizia l\'esplorazione!'**
  String get onboardingComplete;

  /// No description provided for @onboardingStep.
  ///
  /// In it, this message translates to:
  /// **'Passo {current} di {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @personName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get personName;

  /// No description provided for @personNickname.
  ///
  /// In it, this message translates to:
  /// **'Soprannome'**
  String get personNickname;

  /// No description provided for @personRole.
  ///
  /// In it, this message translates to:
  /// **'Ruolo'**
  String get personRole;

  /// No description provided for @personBirthday.
  ///
  /// In it, this message translates to:
  /// **'Data di nascita'**
  String get personBirthday;

  /// No description provided for @personGender.
  ///
  /// In it, this message translates to:
  /// **'Genere'**
  String get personGender;

  /// No description provided for @personNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get personNotes;

  /// No description provided for @personFirstMet.
  ///
  /// In it, this message translates to:
  /// **'Data di conoscenza'**
  String get personFirstMet;

  /// No description provided for @personAvatar.
  ///
  /// In it, this message translates to:
  /// **'Foto'**
  String get personAvatar;

  /// No description provided for @personPersonality.
  ///
  /// In it, this message translates to:
  /// **'Personalità'**
  String get personPersonality;

  /// No description provided for @personRelationship.
  ///
  /// In it, this message translates to:
  /// **'Relazione con te'**
  String get personRelationship;

  /// No description provided for @personAddNew.
  ///
  /// In it, this message translates to:
  /// **'Nuova persona'**
  String get personAddNew;

  /// No description provided for @personEditTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica persona'**
  String get personEditTitle;

  /// No description provided for @personDetailTitle.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get personDetailTitle;

  /// No description provided for @personSelf.
  ///
  /// In it, this message translates to:
  /// **'Io'**
  String get personSelf;

  /// No description provided for @personDisplayName.
  ///
  /// In it, this message translates to:
  /// **'{name}'**
  String personDisplayName(String name);

  /// No description provided for @roleFamily.
  ///
  /// In it, this message translates to:
  /// **'Famiglia'**
  String get roleFamily;

  /// No description provided for @roleFriend.
  ///
  /// In it, this message translates to:
  /// **'Amico/a'**
  String get roleFriend;

  /// No description provided for @rolePartner.
  ///
  /// In it, this message translates to:
  /// **'Partner'**
  String get rolePartner;

  /// No description provided for @roleColleague.
  ///
  /// In it, this message translates to:
  /// **'Collega'**
  String get roleColleague;

  /// No description provided for @roleAcquaintance.
  ///
  /// In it, this message translates to:
  /// **'Conoscente'**
  String get roleAcquaintance;

  /// No description provided for @roleOther.
  ///
  /// In it, this message translates to:
  /// **'Altro'**
  String get roleOther;

  /// No description provided for @mbtiTypeLabel.
  ///
  /// In it, this message translates to:
  /// **'Tipo MBTI'**
  String get mbtiTypeLabel;

  /// No description provided for @mbtiSelectType.
  ///
  /// In it, this message translates to:
  /// **'Seleziona tipo'**
  String get mbtiSelectType;

  /// No description provided for @mbtiConfidence.
  ///
  /// In it, this message translates to:
  /// **'Certezza'**
  String get mbtiConfidence;

  /// No description provided for @mbtiConfidenceHint.
  ///
  /// In it, this message translates to:
  /// **'Quanto sei sicuro di questo tipo? ({value}%)'**
  String mbtiConfidenceHint(int value);

  /// No description provided for @mbtiSourceManual.
  ///
  /// In it, this message translates to:
  /// **'Selezione manuale'**
  String get mbtiSourceManual;

  /// No description provided for @mbtiSourceQuizShort.
  ///
  /// In it, this message translates to:
  /// **'Test breve'**
  String get mbtiSourceQuizShort;

  /// No description provided for @mbtiSourceQuizMedium.
  ///
  /// In it, this message translates to:
  /// **'Test medio'**
  String get mbtiSourceQuizMedium;

  /// No description provided for @mbtiSourceQuizLong.
  ///
  /// In it, this message translates to:
  /// **'Test completo'**
  String get mbtiSourceQuizLong;

  /// No description provided for @mbtiSourceGranular.
  ///
  /// In it, this message translates to:
  /// **'Inserimento granulare'**
  String get mbtiSourceGranular;

  /// No description provided for @mbtiDominant.
  ///
  /// In it, this message translates to:
  /// **'Dominante'**
  String get mbtiDominant;

  /// No description provided for @mbtiAuxiliary.
  ///
  /// In it, this message translates to:
  /// **'Ausiliare'**
  String get mbtiAuxiliary;

  /// No description provided for @mbtiTertiary.
  ///
  /// In it, this message translates to:
  /// **'Terziaria'**
  String get mbtiTertiary;

  /// No description provided for @mbtiInferior.
  ///
  /// In it, this message translates to:
  /// **'Inferiore'**
  String get mbtiInferior;

  /// No description provided for @mbtiLearnAboutType.
  ///
  /// In it, this message translates to:
  /// **'Scopri il tipo {type}'**
  String mbtiLearnAboutType(String type);

  /// No description provided for @mbtiLearnAboutFunction.
  ///
  /// In it, this message translates to:
  /// **'Scopri la funzione {function}'**
  String mbtiLearnAboutFunction(String function);

  /// No description provided for @mbtiGranularTitle.
  ///
  /// In it, this message translates to:
  /// **'Imposta dicotomie'**
  String get mbtiGranularTitle;

  /// No description provided for @mbtiDichotomyIE.
  ///
  /// In it, this message translates to:
  /// **'Introversione / Estroversione'**
  String get mbtiDichotomyIE;

  /// No description provided for @mbtiDichotomyNS.
  ///
  /// In it, this message translates to:
  /// **'Intuizione / Sensazione'**
  String get mbtiDichotomyNS;

  /// No description provided for @mbtiDichotomyTF.
  ///
  /// In it, this message translates to:
  /// **'Pensiero / Sentimento'**
  String get mbtiDichotomyTF;

  /// No description provided for @mbtiDichotomyJP.
  ///
  /// In it, this message translates to:
  /// **'Giudizio / Percezione'**
  String get mbtiDichotomyJP;

  /// No description provided for @relationshipKind.
  ///
  /// In it, this message translates to:
  /// **'Tipo di relazione'**
  String get relationshipKind;

  /// No description provided for @relationshipStrength.
  ///
  /// In it, this message translates to:
  /// **'Intensità percepita'**
  String get relationshipStrength;

  /// No description provided for @relationshipNote.
  ///
  /// In it, this message translates to:
  /// **'Note sulla relazione'**
  String get relationshipNote;

  /// No description provided for @relationshipStartDate.
  ///
  /// In it, this message translates to:
  /// **'Data inizio'**
  String get relationshipStartDate;

  /// No description provided for @relationKindFriendship.
  ///
  /// In it, this message translates to:
  /// **'Amicizia'**
  String get relationKindFriendship;

  /// No description provided for @relationKindRomantic.
  ///
  /// In it, this message translates to:
  /// **'Romantica'**
  String get relationKindRomantic;

  /// No description provided for @relationKindFamily.
  ///
  /// In it, this message translates to:
  /// **'Familiare'**
  String get relationKindFamily;

  /// No description provided for @relationKindProfessional.
  ///
  /// In it, this message translates to:
  /// **'Professionale'**
  String get relationKindProfessional;

  /// No description provided for @relationKindAcquaintance.
  ///
  /// In it, this message translates to:
  /// **'Conoscenza'**
  String get relationKindAcquaintance;

  /// No description provided for @relationKindConflict.
  ///
  /// In it, this message translates to:
  /// **'Conflitto'**
  String get relationKindConflict;

  /// No description provided for @affinityTitle.
  ///
  /// In it, this message translates to:
  /// **'Affinità'**
  String get affinityTitle;

  /// No description provided for @affinityScore.
  ///
  /// In it, this message translates to:
  /// **'Punteggio: {score}/100'**
  String affinityScore(int score);

  /// No description provided for @affinityHigh.
  ///
  /// In it, this message translates to:
  /// **'Alta affinità'**
  String get affinityHigh;

  /// No description provided for @affinityMedium.
  ///
  /// In it, this message translates to:
  /// **'Buona affinità'**
  String get affinityMedium;

  /// No description provided for @affinityLow.
  ///
  /// In it, this message translates to:
  /// **'Affinità moderata'**
  String get affinityLow;

  /// No description provided for @affinityBreakdown.
  ///
  /// In it, this message translates to:
  /// **'Dettaglio funzioni'**
  String get affinityBreakdown;

  /// No description provided for @affinityWith.
  ///
  /// In it, this message translates to:
  /// **'Affinità con {name}'**
  String affinityWith(String name);

  /// No description provided for @affinityNoProfile.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un profilo MBTI per calcolare l\'affinità'**
  String get affinityNoProfile;

  /// No description provided for @affinityDominantComplement.
  ///
  /// In it, this message translates to:
  /// **'Funzioni dominanti complementari'**
  String get affinityDominantComplement;

  /// No description provided for @affinityCoreComplement.
  ///
  /// In it, this message translates to:
  /// **'Complementarità nel nucleo'**
  String get affinityCoreComplement;

  /// No description provided for @affinityComplement.
  ///
  /// In it, this message translates to:
  /// **'Funzioni complementari'**
  String get affinityComplement;

  /// No description provided for @affinitySimilarFunction.
  ///
  /// In it, this message translates to:
  /// **'Funzioni condivise'**
  String get affinitySimilarFunction;

  /// No description provided for @reportFrictionPoints.
  ///
  /// In it, this message translates to:
  /// **'Punti di attrito prevedibili'**
  String get reportFrictionPoints;

  /// No description provided for @reportGrowthAreas.
  ///
  /// In it, this message translates to:
  /// **'Aree di crescita reciproca'**
  String get reportGrowthAreas;

  /// No description provided for @reportCommunication.
  ///
  /// In it, this message translates to:
  /// **'Dinamiche di comunicazione'**
  String get reportCommunication;

  /// No description provided for @reportAxisAnalysis.
  ///
  /// In it, this message translates to:
  /// **'Analisi per asse'**
  String get reportAxisAnalysis;

  /// No description provided for @reportAxisAligned.
  ///
  /// In it, this message translates to:
  /// **'Allineati'**
  String get reportAxisAligned;

  /// No description provided for @reportAxisComplementary.
  ///
  /// In it, this message translates to:
  /// **'Complementari'**
  String get reportAxisComplementary;

  /// No description provided for @reportAxisTension.
  ///
  /// In it, this message translates to:
  /// **'In tensione'**
  String get reportAxisTension;

  /// No description provided for @axisIE.
  ///
  /// In it, this message translates to:
  /// **'Introversione / Estroversione'**
  String get axisIE;

  /// No description provided for @axisNS.
  ///
  /// In it, this message translates to:
  /// **'Intuizione / Sensazione'**
  String get axisNS;

  /// No description provided for @axisTF.
  ///
  /// In it, this message translates to:
  /// **'Pensiero / Sentimento'**
  String get axisTF;

  /// No description provided for @axisJP.
  ///
  /// In it, this message translates to:
  /// **'Giudizio / Percezione'**
  String get axisJP;

  /// No description provided for @careerFitTitle.
  ///
  /// In it, this message translates to:
  /// **'Ruoli ideali'**
  String get careerFitTitle;

  /// No description provided for @careerDisclaimer.
  ///
  /// In it, this message translates to:
  /// **'Suggerimenti basati sulla teoria delle funzioni cognitive — non sostituiscono un orientamento professionale qualificato.'**
  String get careerDisclaimer;

  /// No description provided for @graphTitle.
  ///
  /// In it, this message translates to:
  /// **'Grafo relazioni'**
  String get graphTitle;

  /// No description provided for @graphModeFree.
  ///
  /// In it, this message translates to:
  /// **'Libero'**
  String get graphModeFree;

  /// No description provided for @graphModeCluster.
  ///
  /// In it, this message translates to:
  /// **'Per tipo'**
  String get graphModeCluster;

  /// No description provided for @graphModeTimeline.
  ///
  /// In it, this message translates to:
  /// **'Cronologico'**
  String get graphModeTimeline;

  /// No description provided for @graphNoConnections.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi persone per visualizzare le relazioni'**
  String get graphNoConnections;

  /// No description provided for @graphTapPerson.
  ///
  /// In it, this message translates to:
  /// **'Tocca una persona per i dettagli'**
  String get graphTapPerson;

  /// No description provided for @graphFilterGroups.
  ///
  /// In it, this message translates to:
  /// **'Filtra per gruppo'**
  String get graphFilterGroups;

  /// No description provided for @graphFilterTypes.
  ///
  /// In it, this message translates to:
  /// **'Filtra per tipo MBTI'**
  String get graphFilterTypes;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In it, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsExportData.
  ///
  /// In it, this message translates to:
  /// **'Esporta dati'**
  String get settingsExportData;

  /// No description provided for @settingsImportData.
  ///
  /// In it, this message translates to:
  /// **'Importa dati'**
  String get settingsImportData;

  /// No description provided for @settingsExportDesc.
  ///
  /// In it, this message translates to:
  /// **'Salva tutti i tuoi dati come file ZIP'**
  String get settingsExportDesc;

  /// No description provided for @settingsImportDesc.
  ///
  /// In it, this message translates to:
  /// **'Ripristina dati da un file ZIP'**
  String get settingsImportDesc;

  /// No description provided for @settingsShareProfile.
  ///
  /// In it, this message translates to:
  /// **'Condividi il mio profilo'**
  String get settingsShareProfile;

  /// No description provided for @settingsImportText.
  ///
  /// In it, this message translates to:
  /// **'Importa da testo'**
  String get settingsImportText;

  /// No description provided for @settingsImportTextDesc.
  ///
  /// In it, this message translates to:
  /// **'Incolla un codice profilo per aggiungere una persona'**
  String get settingsImportTextDesc;

  /// No description provided for @settingsAbout.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get settingsAbout;

  /// No description provided for @importDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Importa profilo'**
  String get importDialogTitle;

  /// No description provided for @importDialogHint.
  ///
  /// In it, this message translates to:
  /// **'Incolla il codice qui...'**
  String get importDialogHint;

  /// No description provided for @importDialogError.
  ///
  /// In it, this message translates to:
  /// **'Codice non valido o versione non supportata'**
  String get importDialogError;

  /// No description provided for @importPreviewTitle.
  ///
  /// In it, this message translates to:
  /// **'Anteprima importazione'**
  String get importPreviewTitle;

  /// No description provided for @shareProfileText.
  ///
  /// In it, this message translates to:
  /// **'Ecco il mio profilo Archetypes:\n\n{payload}'**
  String shareProfileText(String payload);

  /// No description provided for @settingsVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione {version}'**
  String settingsVersion(String version);

  /// No description provided for @quizShort.
  ///
  /// In it, this message translates to:
  /// **'Test breve'**
  String get quizShort;

  /// No description provided for @quizShortDesc.
  ///
  /// In it, this message translates to:
  /// **'~20 domande · 5 min'**
  String get quizShortDesc;

  /// No description provided for @quizMedium.
  ///
  /// In it, this message translates to:
  /// **'Test medio'**
  String get quizMedium;

  /// No description provided for @quizMediumDesc.
  ///
  /// In it, this message translates to:
  /// **'~50 domande · 12 min'**
  String get quizMediumDesc;

  /// No description provided for @quizLong.
  ///
  /// In it, this message translates to:
  /// **'Test completo'**
  String get quizLong;

  /// No description provided for @quizLongDesc.
  ///
  /// In it, this message translates to:
  /// **'~80 domande · 20 min'**
  String get quizLongDesc;

  /// No description provided for @quizStart.
  ///
  /// In it, this message translates to:
  /// **'Inizia il test'**
  String get quizStart;

  /// No description provided for @quizQuestion.
  ///
  /// In it, this message translates to:
  /// **'Domanda {current} di {total}'**
  String quizQuestion(int current, int total);

  /// No description provided for @quizResults.
  ///
  /// In it, this message translates to:
  /// **'Risultati'**
  String get quizResults;

  /// No description provided for @quizResultType.
  ///
  /// In it, this message translates to:
  /// **'Il tuo tipo è {type}'**
  String quizResultType(String type);

  /// No description provided for @quizAgree.
  ///
  /// In it, this message translates to:
  /// **'Concordo'**
  String get quizAgree;

  /// No description provided for @quizDisagree.
  ///
  /// In it, this message translates to:
  /// **'Non concordo'**
  String get quizDisagree;

  /// No description provided for @contentSectionStrengths.
  ///
  /// In it, this message translates to:
  /// **'Punti di forza'**
  String get contentSectionStrengths;

  /// No description provided for @contentSectionWeaknesses.
  ///
  /// In it, this message translates to:
  /// **'Aree di crescita'**
  String get contentSectionWeaknesses;

  /// No description provided for @contentSectionRelationships.
  ///
  /// In it, this message translates to:
  /// **'Nelle relazioni'**
  String get contentSectionRelationships;

  /// No description provided for @contentSectionWork.
  ///
  /// In it, this message translates to:
  /// **'Nel lavoro'**
  String get contentSectionWork;

  /// No description provided for @contentSectionStack.
  ///
  /// In it, this message translates to:
  /// **'Stack funzionale'**
  String get contentSectionStack;

  /// No description provided for @contentSectionCompatibility.
  ///
  /// In it, this message translates to:
  /// **'Compatibilità'**
  String get contentSectionCompatibility;

  /// No description provided for @contentSectionBehaviors.
  ///
  /// In it, this message translates to:
  /// **'Comportamenti tipici'**
  String get contentSectionBehaviors;

  /// No description provided for @contentSectionExamples.
  ///
  /// In it, this message translates to:
  /// **'Esempi celebri'**
  String get contentSectionExamples;

  /// No description provided for @contentHighAffinity.
  ///
  /// In it, this message translates to:
  /// **'Alta affinità'**
  String get contentHighAffinity;

  /// No description provided for @contentGoodWorking.
  ///
  /// In it, this message translates to:
  /// **'Buona collaborazione'**
  String get contentGoodWorking;

  /// No description provided for @contentChallengingGrowth.
  ///
  /// In it, this message translates to:
  /// **'Crescita stimolante'**
  String get contentChallengingGrowth;

  /// No description provided for @errorGeneric.
  ///
  /// In it, this message translates to:
  /// **'Si è verificato un errore'**
  String get errorGeneric;

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// No description provided for @errorNotFound.
  ///
  /// In it, this message translates to:
  /// **'Contenuto non trovato'**
  String get errorNotFound;

  /// No description provided for @errorImportFailed.
  ///
  /// In it, this message translates to:
  /// **'Importazione fallita'**
  String get errorImportFailed;

  /// No description provided for @errorExportFailed.
  ///
  /// In it, this message translates to:
  /// **'Esportazione fallita'**
  String get errorExportFailed;

  /// No description provided for @emptyPeopleList.
  ///
  /// In it, this message translates to:
  /// **'Nessuna persona aggiunta ancora'**
  String get emptyPeopleList;

  /// No description provided for @emptyPeopleListAction.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi la tua prima persona'**
  String get emptyPeopleListAction;

  /// No description provided for @emptyGraph.
  ///
  /// In it, this message translates to:
  /// **'Il grafo è vuoto'**
  String get emptyGraph;

  /// No description provided for @confirmDelete.
  ///
  /// In it, this message translates to:
  /// **'Eliminare questa persona?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteBody.
  ///
  /// In it, this message translates to:
  /// **'Tutti i dati relativi a questa persona verranno eliminati. Questa azione non può essere annullata.'**
  String get confirmDeleteBody;

  /// No description provided for @confirmDeleteAction.
  ///
  /// In it, this message translates to:
  /// **'Elimina definitivamente'**
  String get confirmDeleteAction;

  /// No description provided for @languageIt.
  ///
  /// In it, this message translates to:
  /// **'Italiano'**
  String get languageIt;

  /// No description provided for @languageEn.
  ///
  /// In it, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @tabPersonality.
  ///
  /// In it, this message translates to:
  /// **'Personalità'**
  String get tabPersonality;

  /// No description provided for @tabRelationship.
  ///
  /// In it, this message translates to:
  /// **'Relazione'**
  String get tabRelationship;

  /// No description provided for @tabNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get tabNotes;

  /// No description provided for @tabTimeline.
  ///
  /// In it, this message translates to:
  /// **'Timeline'**
  String get tabTimeline;

  /// No description provided for @groupLabel.
  ///
  /// In it, this message translates to:
  /// **'Gruppo'**
  String get groupLabel;

  /// No description provided for @groupAdd.
  ///
  /// In it, this message translates to:
  /// **'Nuovo gruppo'**
  String get groupAdd;

  /// No description provided for @groupColor.
  ///
  /// In it, this message translates to:
  /// **'Colore'**
  String get groupColor;

  /// No description provided for @groupName.
  ///
  /// In it, this message translates to:
  /// **'Nome gruppo'**
  String get groupName;

  /// No description provided for @groupNoGroups.
  ///
  /// In it, this message translates to:
  /// **'Nessun gruppo'**
  String get groupNoGroups;

  /// No description provided for @contentTypeMbti.
  ///
  /// In it, this message translates to:
  /// **'Tipo MBTI'**
  String get contentTypeMbti;

  /// No description provided for @contentTypeFunction.
  ///
  /// In it, this message translates to:
  /// **'Funzione cognitiva'**
  String get contentTypeFunction;

  /// No description provided for @contentTypeDichotomy.
  ///
  /// In it, this message translates to:
  /// **'Dicotomia'**
  String get contentTypeDichotomy;

  /// No description provided for @contentTypeAffinity.
  ///
  /// In it, this message translates to:
  /// **'Affinità'**
  String get contentTypeAffinity;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
