// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Archetypes';

  @override
  String get navGraph => 'Graph';

  @override
  String get navPeople => 'People';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionBack => 'Back';

  @override
  String get actionClose => 'Close';

  @override
  String get actionNext => 'Next';

  @override
  String get actionPrevious => 'Previous';

  @override
  String get actionFinish => 'Finish';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionExport => 'Export';

  @override
  String get actionImport => 'Import';

  @override
  String get actionLearnMore => 'Learn more';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Archetypes';

  @override
  String get onboardingWelcomeSubtitle =>
      'Explore your relationships through Jungian cognitive functions';

  @override
  String get onboardingYourName => 'What\'s your name?';

  @override
  String get onboardingNameHint => 'Your name';

  @override
  String get onboardingChooseMethod =>
      'How do you want to enter your personality?';

  @override
  String get onboardingMethodManual => 'Manual selection';

  @override
  String get onboardingMethodManualDesc => 'Choose your MBTI type directly';

  @override
  String get onboardingMethodTest => 'In-app test';

  @override
  String get onboardingMethodTestDesc =>
      'Answer a questionnaire to discover your type';

  @override
  String get onboardingMethodGranular => 'Granular input';

  @override
  String get onboardingMethodGranularDesc =>
      'Specify dichotomy and cognitive function values directly';

  @override
  String get onboardingSelectType => 'Select your MBTI type';

  @override
  String get onboardingComplete => 'Start exploring!';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get personName => 'Name';

  @override
  String get personNickname => 'Nickname';

  @override
  String get personRole => 'Role';

  @override
  String get personBirthday => 'Date of birth';

  @override
  String get personGender => 'Gender';

  @override
  String get personNotes => 'Notes';

  @override
  String get personFirstMet => 'Date met';

  @override
  String get personAvatar => 'Photo';

  @override
  String get personPersonality => 'Personality';

  @override
  String get personRelationship => 'Your relationship';

  @override
  String get personAddNew => 'New person';

  @override
  String get personEditTitle => 'Edit person';

  @override
  String get personDetailTitle => 'Profile';

  @override
  String get personSelf => 'Me';

  @override
  String personDisplayName(String name) {
    return '$name';
  }

  @override
  String get roleFamily => 'Family';

  @override
  String get roleFriend => 'Friend';

  @override
  String get rolePartner => 'Partner';

  @override
  String get roleColleague => 'Colleague';

  @override
  String get roleAcquaintance => 'Acquaintance';

  @override
  String get roleOther => 'Other';

  @override
  String get mbtiTypeLabel => 'MBTI Type';

  @override
  String get mbtiSelectType => 'Select type';

  @override
  String get mbtiConfidence => 'Confidence';

  @override
  String mbtiConfidenceHint(int value) {
    return 'How confident are you about this type? ($value%)';
  }

  @override
  String get mbtiSourceManual => 'Manual selection';

  @override
  String get mbtiSourceQuizShort => 'Short test';

  @override
  String get mbtiSourceQuizMedium => 'Medium test';

  @override
  String get mbtiSourceQuizLong => 'Full test';

  @override
  String get mbtiSourceGranular => 'Granular input';

  @override
  String get mbtiDominant => 'Dominant';

  @override
  String get mbtiAuxiliary => 'Auxiliary';

  @override
  String get mbtiTertiary => 'Tertiary';

  @override
  String get mbtiInferior => 'Inferior';

  @override
  String mbtiLearnAboutType(String type) {
    return 'Learn about type $type';
  }

  @override
  String mbtiLearnAboutFunction(String function) {
    return 'Learn about function $function';
  }

  @override
  String get mbtiGranularTitle => 'Set dichotomies';

  @override
  String get mbtiDichotomyIE => 'Introversion / Extraversion';

  @override
  String get mbtiDichotomyNS => 'Intuition / Sensing';

  @override
  String get mbtiDichotomyTF => 'Thinking / Feeling';

  @override
  String get mbtiDichotomyJP => 'Judging / Perceiving';

  @override
  String get relationshipKind => 'Relationship type';

  @override
  String get relationshipStrength => 'Perceived intensity';

  @override
  String get relationshipNote => 'Relationship notes';

  @override
  String get relationshipStartDate => 'Start date';

  @override
  String get relationKindFriendship => 'Friendship';

  @override
  String get relationKindRomantic => 'Romantic';

  @override
  String get relationKindFamily => 'Family';

  @override
  String get relationKindProfessional => 'Professional';

  @override
  String get relationKindAcquaintance => 'Acquaintance';

  @override
  String get relationKindConflict => 'Conflict';

  @override
  String get affinityTitle => 'Affinity';

  @override
  String affinityScore(int score) {
    return 'Score: $score/100';
  }

  @override
  String get affinityHigh => 'High affinity';

  @override
  String get affinityMedium => 'Good affinity';

  @override
  String get affinityLow => 'Moderate affinity';

  @override
  String get affinityBreakdown => 'Function breakdown';

  @override
  String affinityWith(String name) {
    return 'Affinity with $name';
  }

  @override
  String get affinityNoProfile => 'Add an MBTI profile to calculate affinity';

  @override
  String get affinityDominantComplement => 'Complementary dominant functions';

  @override
  String get affinityCoreComplement => 'Core complementarity';

  @override
  String get affinityComplement => 'Complementary functions';

  @override
  String get affinitySimilarFunction => 'Shared functions';

  @override
  String get graphTitle => 'Relationship graph';

  @override
  String get graphModeFree => 'Free';

  @override
  String get graphModeCluster => 'By type';

  @override
  String get graphModeTimeline => 'Timeline';

  @override
  String get graphNoConnections => 'Add people to visualize relationships';

  @override
  String get graphTapPerson => 'Tap a person to see details';

  @override
  String get graphFilterGroups => 'Filter by group';

  @override
  String get graphFilterTypes => 'Filter by MBTI type';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsExportData => 'Export data';

  @override
  String get settingsImportData => 'Import data';

  @override
  String get settingsExportDesc => 'Save all your data as a ZIP file';

  @override
  String get settingsImportDesc => 'Restore data from a ZIP file';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get quizShort => 'Short test';

  @override
  String get quizShortDesc => '~20 questions · 5 min';

  @override
  String get quizMedium => 'Medium test';

  @override
  String get quizMediumDesc => '~50 questions · 12 min';

  @override
  String get quizLong => 'Full test';

  @override
  String get quizLongDesc => '~80 questions · 20 min';

  @override
  String get quizStart => 'Start the test';

  @override
  String quizQuestion(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizResults => 'Results';

  @override
  String quizResultType(String type) {
    return 'Your type is $type';
  }

  @override
  String get quizAgree => 'Agree';

  @override
  String get quizDisagree => 'Disagree';

  @override
  String get contentSectionStrengths => 'Strengths';

  @override
  String get contentSectionWeaknesses => 'Growth areas';

  @override
  String get contentSectionRelationships => 'In relationships';

  @override
  String get contentSectionWork => 'At work';

  @override
  String get contentSectionStack => 'Functional stack';

  @override
  String get contentSectionCompatibility => 'Compatibility';

  @override
  String get contentSectionBehaviors => 'Typical behaviors';

  @override
  String get contentSectionExamples => 'Famous examples';

  @override
  String get contentHighAffinity => 'High affinity';

  @override
  String get contentGoodWorking => 'Good collaboration';

  @override
  String get contentChallengingGrowth => 'Challenging growth';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorNotFound => 'Content not found';

  @override
  String get errorImportFailed => 'Import failed';

  @override
  String get errorExportFailed => 'Export failed';

  @override
  String get emptyPeopleList => 'No people added yet';

  @override
  String get emptyPeopleListAction => 'Add your first person';

  @override
  String get emptyGraph => 'The graph is empty';

  @override
  String get confirmDelete => 'Delete this person?';

  @override
  String get confirmDeleteBody =>
      'All data for this person will be permanently deleted. This action cannot be undone.';

  @override
  String get confirmDeleteAction => 'Delete permanently';

  @override
  String get languageIt => 'Italiano';

  @override
  String get languageEn => 'English';

  @override
  String get tabPersonality => 'Personality';

  @override
  String get tabRelationship => 'Relationship';

  @override
  String get tabNotes => 'Notes';

  @override
  String get tabTimeline => 'Timeline';

  @override
  String get groupLabel => 'Group';

  @override
  String get groupAdd => 'New group';

  @override
  String get groupColor => 'Color';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNoGroups => 'No groups';

  @override
  String get contentTypeMbti => 'MBTI Type';

  @override
  String get contentTypeFunction => 'Cognitive function';

  @override
  String get contentTypeDichotomy => 'Dichotomy';

  @override
  String get contentTypeAffinity => 'Affinity';
}
