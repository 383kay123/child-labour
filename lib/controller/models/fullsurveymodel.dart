// models/full_survey_model.dart
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/models/survey_summary.dart';

class FullSurveyModel {
  final CoverPageData cover;
  final ConsentData? consent;
  final FarmerIdentificationData? farmer;
  final CombinedFarmerIdentificationModel? combinedFarm;
  final ChildrenHouseholdModel? childrenHousehold;
  final RemediationModel? remediation;
  final SensitizationData? sensitization;
  final List<SensitizationQuestionsData>? sensitizationQuestions;
  final EndOfCollectionModel? endOfCollection;

  final DateTime createdAt;
  final String surveyId;

  FullSurveyModel({
    required this.cover,
    this.consent,
    this.farmer,
    this.combinedFarm,
    this.childrenHousehold,
    this.remediation,
    this.sensitization,
    this.sensitizationQuestions = const [],
    this.endOfCollection,
    required this.createdAt,
    required this.surveyId,
  });

  // Optional: from raw data map
  factory FullSurveyModel.fromMap(Map<String, dynamic> data) {
    return FullSurveyModel(
      cover: CoverPageData.fromMap(data['cover_page']),
      consent: data['consent'] != null ? ConsentData.fromMap(data['consent']) : null,
      farmer: data['farmer_identification'] != null
          ? FarmerIdentificationData.fromMap(data['farmer_identification'])
          : null,
      combinedFarm: data['combined_farm'] != null
          ? CombinedFarmerIdentificationModel.fromMap(data['combined_farm'])
          : null,
      childrenHousehold: data['children_household'] != null
          ? ChildrenHouseholdModel.fromMap(data['children_household'])
          : null,
      remediation: data['remediation'] != null
          ? RemediationModel.fromMap(data['remediation'])
          : null,
      sensitization: data['sensitization'] != null
          ? SensitizationData.fromMap(data['sensitization'])
          : null,
      sensitizationQuestions: (data['sensitization_questions'] as List<dynamic>?)
              ?.map((e) => SensitizationQuestionsData.fromMap(e))
              .toList() ??
          [],
      endOfCollection: data['end_of_collection'] != null
          ? EndOfCollectionModel.fromMap(data['end_of_collection'])
          : null,
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
      surveyId: data['id'].toString(),
    );
  }
}