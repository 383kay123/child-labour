/// Contains all table names used in the database.
/// Follows the naming convention: [table_name]_TBL
class TableNames {
  // Existing tables
  static const String communityAssessmentTBL = 'community_assessment_table';
  static const String monitoringTBL = 'monitoring_table';
  static const String coverPageTBL = 'cover_page_table';
  static const String consentTBL = 'consent_table';
  static const String farmerChildrenTBL = 'farmer_children_table';
  static const String farmerIdentificationTBL = 'farmer_identification_table';
  static const String remediationTBL = 'remediation';
  
  // New tables
  static const String combinedFarmIdentificationTBL = 'combined_farm_identification';
  static const String householdMembersTBL = 'household_members';
  static const String childrenHouseholdTBL = 'children_household';
  static const String childDetailsTBL = 'child_details';
  static const String sensitizationTBL = 'sensitization';
  static const String sensitizationQuestionsTBL = 'sensitization_questions';
  static const String endOfCollectionTBL = 'end_of_collection';
  static const String farmersTBL = 'farmers_from_server';
  static const String districtsTBL = 'districts';
}
