import 'package:sqflite/sqflite.dart';
import '../table_names.dart';

class MonitoringTable {
  static const String tableName = TableNames.monitoringTBL;

  // Column names
  static const String id = 'id';
  static const String dateCreated = 'date_created';
  static const String dateModified = 'date_modified';
  static const String status = 'status';
  static const String communityId = 'community_id';
  static const String visitDate = 'visit_date';
  static const String notes = 'notes';
  static const String rawData = 'raw_data';
  
  // Section 1: Child Identification
  static const String childId = 'child_id';
  static const String childName = 'child_name';
  static const String age = 'age';
  static const String sex = 'sex';
  static const String community = 'community';
  static const String farmerId = 'farmer_id';
  static const String firstRemediationDate = 'first_remediation_date';
  static const String remediationFormProvided = 'remediation_form_provided';
  static const String followUpVisitsCount = 'follow_up_visits_count';
  
  // Section 2: Education Progress
  static const String classAtRemediation = 'class_at_remediation';
  static const String isEnrolledInSchool = 'is_enrolled_in_school';
  static const String attendanceImproved = 'attendance_improved';
  static const String receivedSchoolMaterials = 'received_school_materials';
  static const String canReadBasicText = 'can_read_basic_text';
  static const String canWriteBasicText = 'can_write_basic_text';
  static const String canDoCalculations = 'can_do_calculations';
  static const String advancedToNextGrade = 'advanced_to_next_grade';
  static const String academicYearEnded = 'academic_year_ended';
  static const String promoted = 'promoted';
  static const String academicImprovement = 'academic_improvement';
  static const String promotedGrade = 'promoted_grade';
  static const String recommendations = 'recommendations';
  
  // Section 3: Child Labour Risk
  static const String engagedInHazardousWork = 'engaged_in_hazardous_work';
  static const String reducedWorkHours = 'reduced_work_hours';
  static const String involvedInLightWork = 'involved_in_light_work';
  static const String outOfHazardousWork = 'out_of_hazardous_work';
  static const String hazardousWorkDetails = 'hazardous_work_details';
  static const String reducedWorkHoursDetails = 'reduced_work_hours_details';
  static const String lightWorkDetails = 'light_work_details';
  static const String hazardousWorkFreePeriodDetails = 'hazardous_work_free_period_details';
  
  // Section 4: Legal Documentation
  static const String hasBirthCertificate = 'has_birth_certificate';
  static const String ongoingBirthCertProcess = 'ongoing_birth_cert_process';
  static const String noBirthCertificateReason = 'no_birth_certificate_reason';
  static const String birthCertificateStatus = 'birth_certificate_status';
  static const String ongoingBirthCertProcessDetails = 'ongoing_birth_cert_process_details';
  
  // Section 5: Family & Caregiver Engagement
  static const String receivedAwarenessSessions = 'received_awareness_sessions';
  static const String improvedUnderstanding = 'improved_understanding';
  static const String caregiversSupportSchool = 'caregivers_support_school';
  static const String awarenessSessionsDetails = 'awareness_sessions_details';
  static const String understandingImprovementDetails = 'understanding_improvement_details';
  static const String caregiverSupportDetails = 'caregiver_support_details';
  
  // Section 6: Additional Support Provided
  static const String receivedFinancialSupport = 'received_financial_support';
  static const String referralsMade = 'referrals_made';
  static const String ongoingFollowUpPlanned = 'ongoing_follow_up_planned';
  static const String financialSupportDetails = 'financial_support_details';
  static const String referralsDetails = 'referrals_details';
  static const String followUpPlanDetails = 'follow_up_plan_details';
  
  // Section 7: Overall Assessment
  static const String consideredRemediated = 'considered_remediated';
  static const String additionalComments = 'additional_comments';
  
  // Section 8: Follow-up Cycle Completion
  static const String followUpVisitsSinceIdentification = 'follow_up_visits_since_identification';
  static const String visitsSpacedCorrectly = 'visits_spaced_correctly';
  static const String confirmedNotInChildLabour = 'confirmed_not_in_child_labour';
  static const String followUpCycleComplete = 'follow_up_cycle_complete';
  
  // Additional fields
  static const String currentSchool = 'current_school';
  static const String currentGrade = 'current_grade';
  static const String attendanceRate = 'attendance_rate';
  static const String schoolPerformance = 'school_performance';
  static const String challengesFaced = 'challenges_faced';
  static const String supportNeeded = 'support_needed';
  static const String attendanceNotes = 'attendance_notes';
  static const String performanceNotes = 'performance_notes';
  static const String supportNotes = 'support_notes';
  static const String otherNotes = 'other_notes';

  // Make this class non-instantiable
  MonitoringTable._();

  /// Creates the monitoring table with all necessary columns
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $dateCreated TEXT NOT NULL,
        $dateModified TEXT,
        $status INTEGER DEFAULT 0,
        $communityId INTEGER,
        $visitDate TEXT,
        $notes TEXT,
        $rawData TEXT,
        
        /* Section 1: Child Identification */
        $childId TEXT,
        $childName TEXT,
        $age TEXT,
        $sex TEXT,
        $community TEXT,
        $farmerId TEXT,
        $firstRemediationDate TEXT,
        $remediationFormProvided TEXT,
        $followUpVisitsCount TEXT,
        
        /* Section 2: Education Progress */
        $classAtRemediation TEXT,
        $isEnrolledInSchool INTEGER,
        $attendanceImproved INTEGER,
        $receivedSchoolMaterials INTEGER,
        $canReadBasicText INTEGER,
        $canWriteBasicText INTEGER,
        $canDoCalculations INTEGER,
        $advancedToNextGrade INTEGER,
        $academicYearEnded INTEGER,
        $promoted INTEGER,
        $academicImprovement INTEGER,
        $promotedGrade TEXT,
        $recommendations TEXT,
        
        /* Section 3: Child Labour Risk */
        $engagedInHazardousWork INTEGER,
        $reducedWorkHours INTEGER,
        $involvedInLightWork INTEGER,
        $outOfHazardousWork INTEGER,
        $hazardousWorkDetails TEXT,
        $reducedWorkHoursDetails TEXT,
        $lightWorkDetails TEXT,
        $hazardousWorkFreePeriodDetails TEXT,
        
        /* Section 4: Legal Documentation */
        $hasBirthCertificate INTEGER,
        $ongoingBirthCertProcess INTEGER,
        $noBirthCertificateReason TEXT,
        $birthCertificateStatus TEXT,
        $ongoingBirthCertProcessDetails TEXT,
        
        /* Section 5: Family & Caregiver Engagement */
        $receivedAwarenessSessions INTEGER,
        $improvedUnderstanding INTEGER,
        $caregiversSupportSchool INTEGER,
        $awarenessSessionsDetails TEXT,
        $understandingImprovementDetails TEXT,
        $caregiverSupportDetails TEXT,
        
        /* Section 6: Additional Support Provided */
        $receivedFinancialSupport INTEGER,
        $referralsMade INTEGER,
        $ongoingFollowUpPlanned INTEGER,
        $financialSupportDetails TEXT,
        $referralsDetails TEXT,
        $followUpPlanDetails TEXT,
        
        /* Section 7: Overall Assessment */
        $consideredRemediated INTEGER,
        $additionalComments TEXT,
        
        /* Section 8: Follow-up Cycle Completion */
        $followUpVisitsSinceIdentification TEXT,
        $visitsSpacedCorrectly INTEGER,
        $confirmedNotInChildLabour INTEGER,
        $followUpCycleComplete INTEGER,
        
        /* Additional fields */
        $currentSchool TEXT,
        $currentGrade TEXT,
        $attendanceRate TEXT,
        $schoolPerformance TEXT,
        $challengesFaced TEXT,
        $supportNeeded TEXT,
        $attendanceNotes TEXT,
        $performanceNotes TEXT,
        $supportNotes TEXT,
        $otherNotes TEXT,
        
        FOREIGN KEY ($communityId) REFERENCES ${TableNames.communityAssessmentTBL} (id) ON DELETE SET NULL
      )
    ''');
  }

  /// Creates any necessary indexes
  static Future<void> createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_community_id 
      ON $tableName($communityId);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_status 
      ON $tableName($status);
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_child_id 
      ON $tableName($childId);
    ''');
  }

  /// Drops the monitoring table
  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Handles database upgrades
  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        // Add missing columns for version 2
        await _addColumnIfNotExists(db, canDoCalculations, 'INTEGER');
        await _addColumnIfNotExists(db, academicYearEnded, 'INTEGER');
        await _addColumnIfNotExists(db, academicImprovement, 'INTEGER');
        await _addColumnIfNotExists(db, engagedInHazardousWork, 'INTEGER');
        await _addColumnIfNotExists(db, reducedWorkHours, 'INTEGER');
        await _addColumnIfNotExists(db, involvedInLightWork, 'INTEGER');
        await _addColumnIfNotExists(db, outOfHazardousWork, 'INTEGER');
        await _addColumnIfNotExists(db, hasBirthCertificate, 'INTEGER');
        await _addColumnIfNotExists(db, ongoingBirthCertProcess, 'INTEGER');
        await _addColumnIfNotExists(db, receivedAwarenessSessions, 'INTEGER');
        await _addColumnIfNotExists(db, improvedUnderstanding, 'INTEGER');
        await _addColumnIfNotExists(db, caregiversSupportSchool, 'INTEGER');
        await _addColumnIfNotExists(db, receivedFinancialSupport, 'INTEGER');
        await _addColumnIfNotExists(db, referralsMade, 'INTEGER');
        await _addColumnIfNotExists(db, ongoingFollowUpPlanned, 'INTEGER');
        await _addColumnIfNotExists(db, consideredRemediated, 'INTEGER');
        await _addColumnIfNotExists(db, visitsSpacedCorrectly, 'INTEGER');
        await _addColumnIfNotExists(db, confirmedNotInChildLabour, 'INTEGER');
        await _addColumnIfNotExists(db, followUpCycleComplete, 'INTEGER');
        
        // Add text columns
        await _addColumnIfNotExists(db, hazardousWorkDetails, 'TEXT');
        await _addColumnIfNotExists(db, reducedWorkHoursDetails, 'TEXT');
        await _addColumnIfNotExists(db, lightWorkDetails, 'TEXT');
        await _addColumnIfNotExists(db, hazardousWorkFreePeriodDetails, 'TEXT');
        await _addColumnIfNotExists(db, birthCertificateStatus, 'TEXT');
        await _addColumnIfNotExists(db, ongoingBirthCertProcessDetails, 'TEXT');
        await _addColumnIfNotExists(db, awarenessSessionsDetails, 'TEXT');
        await _addColumnIfNotExists(db, understandingImprovementDetails, 'TEXT');
        await _addColumnIfNotExists(db, caregiverSupportDetails, 'TEXT');
        await _addColumnIfNotExists(db, financialSupportDetails, 'TEXT');
        await _addColumnIfNotExists(db, referralsDetails, 'TEXT');
        await _addColumnIfNotExists(db, followUpPlanDetails, 'TEXT');
        
        print('Database migrated from version $oldVersion to $newVersion successfully');
      } catch (e) {
        print('Error during database migration: $e');
        // If migration fails, try recreating the table as a fallback
        try {
          await dropTable(db);
          await createTable(db);
        } catch (e2) {
          print('Failed to recreate table: $e2');
          rethrow;
        }
      }
    }
    
    // Version 3: Add ongoing_birth_cert_process_details column
    if (oldVersion < 3) {
      try {
        await _addColumnIfNotExists(db, ongoingBirthCertProcessDetails, 'TEXT');
        print('Added $ongoingBirthCertProcessDetails column in version 3');
        print('Database migrated from version $oldVersion to $newVersion successfully');
      } catch (e) {
        print('Error during migration to version 3: $e');
        rethrow;
      }
    }
  }

  /// Helper method to safely add a column if it doesn't exist
  static Future<void> _addColumnIfNotExists(Database db, String columnName, String columnType) async {
    try {
      // Check if column exists
      final result = await db.rawQuery(
        "PRAGMA table_info($tableName) WHERE name = ?",
        [columnName]
      );
      
      if (result.isEmpty) {
        await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnType');
        print('Added column: $columnName');
      }
    } catch (e) {
      print('Error adding column $columnName: $e');
      rethrow;
    }
  }

  /// Returns a list of all column names for queries
  static List<String> get allColumns => [
    id,
    dateCreated,
    dateModified,
    status,
    communityId,
    visitDate,
    notes,
    rawData,
    
    // Section 1
    childId,
    childName,
    age,
    sex,
    community,
    farmerId,
    firstRemediationDate,
    remediationFormProvided,
    followUpVisitsCount,
    
    // Section 2
    classAtRemediation,
    isEnrolledInSchool,
    attendanceImproved,
    receivedSchoolMaterials,
    canReadBasicText,
    canWriteBasicText,
    canDoCalculations,
    advancedToNextGrade,
    academicYearEnded,
    promoted,
    academicImprovement,
    promotedGrade,
    recommendations,
    
    // Section 3
    engagedInHazardousWork,
    reducedWorkHours,
    involvedInLightWork,
    outOfHazardousWork,
    hazardousWorkDetails,
    reducedWorkHoursDetails,
    lightWorkDetails,
    hazardousWorkFreePeriodDetails,
    
    // Section 4
    hasBirthCertificate,
    ongoingBirthCertProcess,
    noBirthCertificateReason,
    birthCertificateStatus,
    ongoingBirthCertProcessDetails,
    
    // Section 5
    receivedAwarenessSessions,
    improvedUnderstanding,
    caregiversSupportSchool,
    awarenessSessionsDetails,
    understandingImprovementDetails,
    caregiverSupportDetails,
    
    // Section 6
    receivedFinancialSupport,
    referralsMade,
    ongoingFollowUpPlanned,
    financialSupportDetails,
    referralsDetails,
    followUpPlanDetails,
    
    // Section 7
    consideredRemediated,
    additionalComments,
    
    // Section 8
    followUpVisitsSinceIdentification,
    visitsSpacedCorrectly,
    confirmedNotInChildLabour,
    followUpCycleComplete,
    
    // Additional fields
    currentSchool,
    currentGrade,
    attendanceRate,
    schoolPerformance,
    challengesFaced,
    supportNeeded,
    attendanceNotes,
    performanceNotes,
    supportNotes,
    otherNotes,
  ];
}