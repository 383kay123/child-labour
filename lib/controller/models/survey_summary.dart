import 'package:flutter/foundation.dart';

class SurveySummary {
  final int? id;
  final String farmerName;
  final String ghanaCardNumber;
  final String contactNumber;
  final String community;
  final DateTime submissionDate;
  final bool isSynced;
  final bool hasCoverData;
  final bool hasConsentData;
  final bool hasFarmerData;
  final bool hasCombinedData;
  final bool hasRemediationData;
  final bool hasSensitizationData;
  final bool hasSensitizationQuestionsData;
  final bool hasEndOfCollectionData;
  final String? surveyType;
  final Map<String, dynamic>? additionalData;

  const SurveySummary({
    this.id,
    required this.farmerName,
    required this.ghanaCardNumber,
    required this.contactNumber,
    required this.community,
    required this.submissionDate,
    required this.isSynced,
    required this.hasCoverData,
    required this.hasConsentData,
    required this.hasFarmerData,
    required this.hasCombinedData,
    required this.hasRemediationData,
    required this.hasSensitizationData,
    required this.hasSensitizationQuestionsData,
    required this.hasEndOfCollectionData,
    this.surveyType = 'Survey',
    this.additionalData,
  });

  factory SurveySummary.fromMap(Map<String, dynamic> map) {
    return SurveySummary(
      id: map['id'] as int?,
      farmerName: map['farmer_name'] as String? ?? 'Unknown Farmer',
      ghanaCardNumber: map['ghana_card_number'] as String? ?? 'N/A',
      contactNumber: map['contact_number'] as String? ?? '',
      community: map['community'] as String? ?? '',
      submissionDate: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
      hasCoverData: map['has_cover_data'] == 1 || map['has_cover_data'] == true,
      hasConsentData: map['has_consent_data'] == 1 || map['has_consent_data'] == true,
      hasFarmerData: map['has_farmer_data'] == 1 || map['has_farmer_data'] == true,
      hasCombinedData: map['has_combined_data'] == 1 || map['has_combined_data'] == true,
      hasRemediationData: map['has_remediation_data'] == 1 || map['has_remediation_data'] == true,
      hasSensitizationData: map['has_sensitization_data'] == 1 || map['has_sensitization_data'] == true,
      hasSensitizationQuestionsData: map['has_sensitization_questions_data'] == 1 || map['has_sensitization_questions_data'] == true,
      hasEndOfCollectionData: map['has_end_of_collection_data'] == 1 || map['has_end_of_collection_data'] == true,
      surveyType: map['survey_type'] as String?,
      additionalData: map,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmer_name': farmerName,
      'ghana_card_number': ghanaCardNumber,
      'contact_number': contactNumber,
      'community': community,
      'created_at': submissionDate.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'has_cover_data': hasCoverData ? 1 : 0,
      'has_consent_data': hasConsentData ? 1 : 0,
      'has_farmer_data': hasFarmerData ? 1 : 0,
      'has_combined_data': hasCombinedData ? 1 : 0,
      'has_remediation_data': hasRemediationData ? 1 : 0,
      'has_sensitization_data': hasSensitizationData ? 1 : 0,
      'has_sensitization_questions_data': hasSensitizationQuestionsData ? 1 : 0,
      'has_end_of_collection_data': hasEndOfCollectionData ? 1 : 0,
      'survey_type': surveyType,
      ...?additionalData,
    };
  }

  @override
  String toString() => 'SurveySummary(farmerName: $farmerName, submissionDate: $submissionDate, ghanaCard: $ghanaCardNumber)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurveySummary &&
        other.id == id &&
        other.farmerName == farmerName &&
        other.ghanaCardNumber == ghanaCardNumber;
  }

  @override
  int get hashCode => Object.hash(id, farmerName, ghanaCardNumber);
}
