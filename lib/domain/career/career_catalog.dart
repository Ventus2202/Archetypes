import '../personality_systems/mbti/mbti_types.dart';
import 'career_role.dart';

const List<CareerRole> kCareerRoles = [
  CareerRole(
    id: 'researcher',
    titleKey: 'career_researcher',
    functionWeights: {
      CognitiveFunction.ti: 1.0,
      CognitiveFunction.ni: 0.9,
      CognitiveFunction.te: 0.8,
      CognitiveFunction.ne: 0.7,
      CognitiveFunction.se: 0.2,
      CognitiveFunction.fe: 0.1,
    },
    preferences: [
      DichotomyPreference(axis: 'ie', preferred: 'I', weight: 1.0),
      DichotomyPreference(axis: 'tf', preferred: 'T', weight: 0.5),
    ],
  ),
  CareerRole(
    id: 'project_manager',
    titleKey: 'career_project_manager',
    functionWeights: {
      CognitiveFunction.te: 1.0,
      CognitiveFunction.si: 0.8,
      CognitiveFunction.fe: 0.7,
      CognitiveFunction.ni: 0.6,
      CognitiveFunction.fi: 0.3,
      CognitiveFunction.ne: 0.2,
    },
    preferences: [
      DichotomyPreference(axis: 'jp', preferred: 'J', weight: 1.0),
      DichotomyPreference(axis: 'ie', preferred: 'E', weight: 0.5),
    ],
  ),
  CareerRole(
    id: 'software_engineer',
    titleKey: 'career_software_engineer',
    functionWeights: {
      CognitiveFunction.ti: 1.0,
      CognitiveFunction.te: 0.9,
      CognitiveFunction.ni: 0.8,
      CognitiveFunction.si: 0.7,
      CognitiveFunction.fe: 0.2,
      CognitiveFunction.se: 0.3,
    },
    preferences: [
      DichotomyPreference(axis: 'ie', preferred: 'I', weight: 0.8),
      DichotomyPreference(axis: 'tf', preferred: 'T', weight: 0.8),
    ],
  ),
  CareerRole(
    id: 'designer_ux',
    titleKey: 'career_designer_ux',
    functionWeights: {
      CognitiveFunction.fi: 0.9,
      CognitiveFunction.ne: 0.9,
      CognitiveFunction.ni: 0.8,
      CognitiveFunction.fe: 0.7,
      CognitiveFunction.te: 0.4,
      CognitiveFunction.ti: 0.3,
    },
    preferences: [
      DichotomyPreference(axis: 'ns', preferred: 'N', weight: 0.8),
    ],
  ),
  CareerRole(
    id: 'product_manager',
    titleKey: 'career_product_manager',
    functionWeights: {
      CognitiveFunction.ne: 1.0,
      CognitiveFunction.te: 0.9,
      CognitiveFunction.ni: 0.8,
      CognitiveFunction.fe: 0.7,
      CognitiveFunction.si: 0.3,
      CognitiveFunction.fi: 0.2,
    },
    preferences: [
      DichotomyPreference(axis: 'ns', preferred: 'N', weight: 0.7),
      DichotomyPreference(axis: 'tf', preferred: 'T', weight: 0.4),
    ],
  ),
  CareerRole(
    id: 'sales',
    titleKey: 'career_sales',
    functionWeights: {
      CognitiveFunction.fe: 1.0,
      CognitiveFunction.se: 0.9,
      CognitiveFunction.te: 0.8,
      CognitiveFunction.ne: 0.7,
      CognitiveFunction.ni: 0.3,
      CognitiveFunction.ti: 0.2,
    },
    preferences: [
      DichotomyPreference(axis: 'ie', preferred: 'E', weight: 1.0),
    ],
  ),
  CareerRole(
    id: 'therapist',
    titleKey: 'career_therapist',
    functionWeights: {
      CognitiveFunction.fi: 1.0,
      CognitiveFunction.fe: 0.9,
      CognitiveFunction.ni: 0.8,
      CognitiveFunction.ne: 0.7,
      CognitiveFunction.te: 0.2,
      CognitiveFunction.se: 0.3,
    },
    preferences: [
      DichotomyPreference(axis: 'tf', preferred: 'F', weight: 1.0),
      DichotomyPreference(axis: 'ns', preferred: 'N', weight: 0.5),
    ],
  ),
  CareerRole(
    id: 'teacher',
    titleKey: 'career_teacher',
    functionWeights: {
      CognitiveFunction.fe: 1.0,
      CognitiveFunction.si: 0.9,
      CognitiveFunction.ne: 0.7,
      CognitiveFunction.ni: 0.6,
      CognitiveFunction.ti: 0.3,
      CognitiveFunction.se: 0.3,
    },
    preferences: [
      DichotomyPreference(axis: 'tf', preferred: 'F', weight: 0.8),
      DichotomyPreference(axis: 'jp', preferred: 'J', weight: 0.6),
    ],
  ),
  CareerRole(
    id: 'surgeon',
    titleKey: 'career_surgeon',
    functionWeights: {
      CognitiveFunction.se: 1.0,
      CognitiveFunction.ti: 0.9,
      CognitiveFunction.te: 0.8,
      CognitiveFunction.si: 0.7,
      CognitiveFunction.fe: 0.2,
      CognitiveFunction.ne: 0.1,
    },
    preferences: [
      DichotomyPreference(axis: 'ns', preferred: 'S', weight: 0.8),
      DichotomyPreference(axis: 'tf', preferred: 'T', weight: 0.8),
    ],
  ),
  CareerRole(
    id: 'journalist',
    titleKey: 'career_journalist',
    functionWeights: {
      CognitiveFunction.ne: 1.0,
      CognitiveFunction.se: 0.8,
      CognitiveFunction.fe: 0.7,
      CognitiveFunction.ti: 0.7,
      CognitiveFunction.si: 0.3,
      CognitiveFunction.ni: 0.4,
    },
    preferences: [
      DichotomyPreference(axis: 'ie', preferred: 'E', weight: 0.6),
      DichotomyPreference(axis: 'jp', preferred: 'P', weight: 0.5),
    ],
  ),
  CareerRole(
    id: 'entrepreneur',
    titleKey: 'career_entrepreneur',
    functionWeights: {
      CognitiveFunction.te: 1.0,
      CognitiveFunction.ne: 0.9,
      CognitiveFunction.se: 0.8,
      CognitiveFunction.ni: 0.8,
      CognitiveFunction.si: 0.2,
      CognitiveFunction.fi: 0.3,
    },
    preferences: [
      DichotomyPreference(axis: 'ie', preferred: 'E', weight: 0.5),
      DichotomyPreference(axis: 'jp', preferred: 'P', weight: 0.4),
    ],
  ),
  CareerRole(
    id: 'accountant',
    titleKey: 'career_accountant',
    functionWeights: {
      CognitiveFunction.si: 1.0,
      CognitiveFunction.te: 0.9,
      CognitiveFunction.ti: 0.7,
      CognitiveFunction.ni: 0.4,
      CognitiveFunction.ne: 0.1,
      CognitiveFunction.se: 0.2,
    },
    preferences: [
      DichotomyPreference(axis: 'ns', preferred: 'S', weight: 1.0),
      DichotomyPreference(axis: 'jp', preferred: 'J', weight: 0.8),
    ],
  ),
  CareerRole(
    id: 'social_worker',
    titleKey: 'career_social_worker',
    functionWeights: {
      CognitiveFunction.fe: 1.0,
      CognitiveFunction.fi: 0.8,
      CognitiveFunction.si: 0.7,
      CognitiveFunction.se: 0.6,
      CognitiveFunction.ti: 0.2,
      CognitiveFunction.te: 0.3,
    },
    preferences: [
      DichotomyPreference(axis: 'tf', preferred: 'F', weight: 1.0),
      DichotomyPreference(axis: 'ie', preferred: 'E', weight: 0.4),
    ],
  ),
  CareerRole(
    id: 'data_analyst',
    titleKey: 'career_data_analyst',
    functionWeights: {
      CognitiveFunction.ti: 1.0,
      CognitiveFunction.te: 0.9,
      CognitiveFunction.si: 0.8,
      CognitiveFunction.ni: 0.7,
      CognitiveFunction.fe: 0.1,
      CognitiveFunction.se: 0.3,
    },
    preferences: [
      DichotomyPreference(axis: 'ie', preferred: 'I', weight: 0.8),
      DichotomyPreference(axis: 'tf', preferred: 'T', weight: 0.9),
    ],
  ),
  CareerRole(
    id: 'creative_director',
    titleKey: 'career_creative_director',
    functionWeights: {
      CognitiveFunction.ne: 1.0,
      CognitiveFunction.ni: 0.9,
      CognitiveFunction.fi: 0.8,
      CognitiveFunction.fe: 0.7,
      CognitiveFunction.si: 0.2,
      CognitiveFunction.ti: 0.3,
    },
    preferences: [
      DichotomyPreference(axis: 'ns', preferred: 'N', weight: 0.9),
      DichotomyPreference(axis: 'jp', preferred: 'P', weight: 0.5),
    ],
  ),
  CareerRole(
    id: 'operations_manager',
    titleKey: 'career_operations_manager',
    functionWeights: {
      CognitiveFunction.te: 1.0,
      CognitiveFunction.si: 0.9,
      CognitiveFunction.se: 0.7,
      CognitiveFunction.ti: 0.6,
      CognitiveFunction.ne: 0.2,
      CognitiveFunction.fi: 0.3,
    },
    preferences: [
      DichotomyPreference(axis: 'ns', preferred: 'S', weight: 0.7),
      DichotomyPreference(axis: 'jp', preferred: 'J', weight: 0.9),
    ],
  ),
];
