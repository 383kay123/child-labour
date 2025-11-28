// models/full_survey_model.dart
import 'package:human_rights_monitor/controller/models/end_of_collection_data.dart';
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
    cover: data['cover_page'] is CoverPageData 
        ? data['cover_page'] 
        : CoverPageData.fromMap(data['cover_page']),
    consent: data['consent'] == null 
        ? null 
        : data['consent'] is ConsentData
            ? data['consent']
            : ConsentData.fromMap(data['consent']),
    farmer: data['farmer_identification'] == null
        ? null
        : data['farmer_identification'] is FarmerIdentificationData
            ? data['farmer_identification']
            : FarmerIdentificationData.fromMap(data['farmer_identification']),
    combinedFarm: data['combined_farm'] == null
        ? null
        : data['combined_farm'] is CombinedFarmerIdentificationModel
            ? data['combined_farm']
            : CombinedFarmerIdentificationModel.fromMap(data['combined_farm']),
    childrenHousehold: data['children_household'] == null
        ? null
        : data['children_household'] is ChildrenHouseholdModel
            ? data['children_household']
            : ChildrenHouseholdModel.fromMap(data['children_household']),
    remediation: data['remediation'] == null
        ? null
        : data['remediation'] is RemediationModel
            ? data['remediation']
            : RemediationModel.fromMap(data['remediation']),
    sensitization: data['sensitization'] == null
        ? null
        : data['sensitization'] is SensitizationData
            ? data['sensitization']
            : SensitizationData.fromMap(data['sensitization']),
    sensitizationQuestions: (data['sensitization_questions'] as List<dynamic>?)
        ?.map((q) => q is SensitizationQuestionsData 
            ? q 
            : SensitizationQuestionsData.fromMap(q))
        .toList() ?? const [],
    endOfCollection: data['end_of_collection'] == null
        ? null
        : data['end_of_collection'] is EndOfCollectionModel
            ? data['end_of_collection']
            : data['end_of_collection'] is EndOfCollectionData
                ? EndOfCollectionModel.fromMap((data['end_of_collection'] as EndOfCollectionData).toMap())
                : EndOfCollectionModel.fromMap(data['end_of_collection'] as Map<String, dynamic>),
    createdAt: data['created_at'] is DateTime 
        ? data['created_at'] 
        : DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
    surveyId: data['id'].toString(),
  );
}
}