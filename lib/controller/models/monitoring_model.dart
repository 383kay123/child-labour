import 'dart:convert';
import 'package:intl/intl.dart';

class MonitoringModel {
  int? id;
  DateTime dateCreated;
  DateTime? dateModified;
  int status; // 0 = draft, 1 = submitted, 2 = synced
  int? communityId;
  
  // Section 1: Child Identification
  String childId;
  String childName;
  String age;
  String sex;
  String community;
  String farmerId;
  String firstRemediationDate;
  String remediationFormProvided;
  String followUpVisitsCount;
  
  // Section 2: Education Progress
  String classAtRemediation;
  bool isEnrolledInSchool;
  bool attendanceImproved;
  bool receivedSchoolMaterials;
  bool canReadBasicText;
  bool canWriteBasicText;
  bool canDoCalculations;
  bool advancedToNextGrade;
  bool academicYearEnded;
  bool? promoted;
  bool? academicImprovement;
  String? promotedGrade;
  String? recommendations;
  
  // Section 3: Child Labour Risk
  bool engagedInHazardousWork;
  bool reducedWorkHours;
  bool involvedInLightWork;
  bool outOfHazardousWork;
  String? hazardousWorkDetails;
  String? reducedWorkHoursDetails;
  String? lightWorkDetails;
  String? hazardousWorkFreePeriodDetails;
  
  // Section 4: Legal Documentation
  bool hasBirthCertificate;
  bool? ongoingBirthCertProcess;
  String? noBirthCertificateReason;
  String? birthCertificateStatus;
  String? ongoingBirthCertProcessDetails;
  
  // Section 5: Family & Caregiver Engagement
  bool receivedAwarenessSessions;
  bool improvedUnderstanding;
  bool caregiversSupportSchool;
  String? awarenessSessionsDetails;
  String? understandingImprovementDetails;
  String? caregiverSupportDetails;
  
  // Section 6: Additional Support Provided
  bool receivedFinancialSupport;
  bool referralsMade;
  bool ongoingFollowUpPlanned;
  String? financialSupportDetails;
  String? referralsDetails;
  String? followUpPlanDetails;
  
  // Section 7: Overall Assessment
  bool consideredRemediated;
  String additionalComments;
  
  // Section 8: Follow-up Cycle Completion
  String followUpVisitsCountSinceIdentification;
  bool visitsSpacedCorrectly;
  bool confirmedNotInChildLabour;
  bool followUpCycleComplete;
  
  // Additional fields
  String? currentSchool;
  String? currentGrade;
  String? attendanceRate;
  String? schoolPerformance;
  String? challengesFaced;
  String? supportNeeded;
  String? attendanceNotes;
  String? performanceNotes;
  String? supportNotes;
  String? otherNotes;
  
  // Metadata
  DateTime visitDate;
  String? notes;
  Map<String, dynamic>? rawData;

  MonitoringModel({
    this.id,
    DateTime? dateCreated,
    this.dateModified,
    this.status = 0,
    this.communityId,
    required this.visitDate,
    this.notes,
    this.rawData = const {},
    
    // Section 1: Child Identification
    this.childId = '',
    this.childName = '',
    this.age = '',
    this.sex = '',
    this.community = '',
    this.farmerId = '',
    this.firstRemediationDate = '',
    this.remediationFormProvided = '',
    this.followUpVisitsCount = '',
    
    // Section 2: Education Progress
    this.classAtRemediation = '',
    this.isEnrolledInSchool = false,
    this.attendanceImproved = false,
    this.receivedSchoolMaterials = false,
    this.canReadBasicText = false,
    this.canWriteBasicText = false,
    this.canDoCalculations = false,
    this.advancedToNextGrade = false,
    this.academicYearEnded = false,
    this.promoted,
    this.academicImprovement,
    this.promotedGrade,
    this.recommendations,
    
    // Section 3: Child Labour Risk
    this.engagedInHazardousWork = false,
    this.reducedWorkHours = false,
    this.involvedInLightWork = false,
    this.outOfHazardousWork = false,
    this.hazardousWorkDetails,
    this.reducedWorkHoursDetails,
    this.lightWorkDetails,
    this.hazardousWorkFreePeriodDetails,
    
    // Section 4: Legal Documentation
    this.hasBirthCertificate = false,
    this.ongoingBirthCertProcess,
    this.noBirthCertificateReason,
    this.birthCertificateStatus,
    this.ongoingBirthCertProcessDetails,
    
    // Section 5: Family & Caregiver Engagement
    this.receivedAwarenessSessions = false,
    this.improvedUnderstanding = false,
    this.caregiversSupportSchool = false,
    this.awarenessSessionsDetails,
    this.understandingImprovementDetails,
    this.caregiverSupportDetails,
    
    // Section 6: Additional Support Provided
    this.receivedFinancialSupport = false,
    this.referralsMade = false,
    this.ongoingFollowUpPlanned = false,
    this.financialSupportDetails,
    this.referralsDetails,
    this.followUpPlanDetails,
    
    // Section 7: Overall Assessment
    this.consideredRemediated = false,
    this.additionalComments = '',
    
    // Section 8: Follow-up Cycle Completion
    this.followUpVisitsCountSinceIdentification = '',
    this.visitsSpacedCorrectly = false,
    this.confirmedNotInChildLabour = false,
    this.followUpCycleComplete = false,
    
    // Additional fields
    this.currentSchool,
    this.currentGrade,
    this.attendanceRate,
    this.schoolPerformance,
    this.challengesFaced,
    this.supportNeeded,
    this.attendanceNotes,
    this.performanceNotes,
    this.supportNotes,
    this.otherNotes,
  }) : dateCreated = dateCreated ?? DateTime.now();

  // Create a copy of the model with updated fields
  MonitoringModel copyWith({
    int? id,
    DateTime? dateCreated,
    DateTime? dateModified,
    int? status,
    int? communityId,
    DateTime? visitDate,
    String? notes,
    Map<String, dynamic>? rawData,
    
    // Section 1: Child Identification
    String? childId,
    String? childName,
    String? age,
    String? sex,
    String? community,
    String? farmerId,
    String? firstRemediationDate,
    String? remediationFormProvided,
    String? followUpVisitsCount,
    
    // Section 2: Education Progress
    String? classAtRemediation,
    bool? isEnrolledInSchool,
    bool? attendanceImproved,
    bool? receivedSchoolMaterials,
    bool? canReadBasicText,
    bool? canWriteBasicText,
    bool? canDoCalculations,
    bool? advancedToNextGrade,
    bool? academicYearEnded,
    bool? promoted,
    bool? academicImprovement,
    String? promotedGrade,
    String? recommendations,
    
    // Section 3: Child Labour Risk
    bool? engagedInHazardousWork,
    bool? reducedWorkHours,
    bool? involvedInLightWork,
    bool? outOfHazardousWork,
    String? hazardousWorkDetails,
    String? reducedWorkHoursDetails,
    String? lightWorkDetails,
    String? hazardousWorkFreePeriodDetails,
    
    // Section 4: Legal Documentation
    bool? hasBirthCertificate,
    bool? ongoingBirthCertProcess,
    String? noBirthCertificateReason,
    String? birthCertificateStatus,
    String? ongoingBirthCertProcessDetails,
    
    // Section 5: Family & Caregiver Engagement
    bool? receivedAwarenessSessions,
    bool? improvedUnderstanding,
    bool? caregiversSupportSchool,
    String? awarenessSessionsDetails,
    String? understandingImprovementDetails,
    String? caregiverSupportDetails,
    
    // Section 6: Additional Support Provided
    bool? receivedFinancialSupport,
    bool? referralsMade,
    bool? ongoingFollowUpPlanned,
    String? financialSupportDetails,
    String? referralsDetails,
    String? followUpPlanDetails,
    
    // Section 7: Overall Assessment
    bool? consideredRemediated,
    String? additionalComments,
    
    // Section 8: Follow-up Cycle Completion
    String? followUpVisitsCountSinceIdentification,
    bool? visitsSpacedCorrectly,
    bool? confirmedNotInChildLabour,
    bool? followUpCycleComplete,
    
    // Additional fields
    String? currentSchool,
    String? currentGrade,
    String? attendanceRate,
    String? schoolPerformance,
    String? challengesFaced,
    String? supportNeeded,
    String? attendanceNotes,
    String? performanceNotes,
    String? supportNotes,
    String? otherNotes,
  }) {
    return MonitoringModel(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      status: status ?? this.status,
      communityId: communityId ?? this.communityId,
      visitDate: visitDate ?? this.visitDate,
      notes: notes ?? this.notes,
      rawData: rawData ?? this.rawData,
      
      // Section 1: Child Identification
      childId: childId ?? this.childId,
      childName: childName ?? this.childName,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      community: community ?? this.community,
      farmerId: farmerId ?? this.farmerId,
      firstRemediationDate: firstRemediationDate ?? this.firstRemediationDate,
      remediationFormProvided: remediationFormProvided ?? this.remediationFormProvided,
      followUpVisitsCount: followUpVisitsCount ?? this.followUpVisitsCount,
      
      // Section 2: Education Progress
      classAtRemediation: classAtRemediation ?? this.classAtRemediation,
      isEnrolledInSchool: isEnrolledInSchool ?? this.isEnrolledInSchool,
      attendanceImproved: attendanceImproved ?? this.attendanceImproved,
      receivedSchoolMaterials: receivedSchoolMaterials ?? this.receivedSchoolMaterials,
      canReadBasicText: canReadBasicText ?? this.canReadBasicText,
      canWriteBasicText: canWriteBasicText ?? this.canWriteBasicText,
      canDoCalculations: canDoCalculations ?? this.canDoCalculations,
      advancedToNextGrade: advancedToNextGrade ?? this.advancedToNextGrade,
      academicYearEnded: academicYearEnded ?? this.academicYearEnded,
      promoted: promoted ?? this.promoted,
      academicImprovement: academicImprovement ?? this.academicImprovement,
      promotedGrade: promotedGrade ?? this.promotedGrade,
      recommendations: recommendations ?? this.recommendations,
      
      // Section 3: Child Labour Risk
      engagedInHazardousWork: engagedInHazardousWork ?? this.engagedInHazardousWork,
      reducedWorkHours: reducedWorkHours ?? this.reducedWorkHours,
      involvedInLightWork: involvedInLightWork ?? this.involvedInLightWork,
      outOfHazardousWork: outOfHazardousWork ?? this.outOfHazardousWork,
      hazardousWorkDetails: hazardousWorkDetails ?? this.hazardousWorkDetails,
      reducedWorkHoursDetails: reducedWorkHoursDetails ?? this.reducedWorkHoursDetails,
      lightWorkDetails: lightWorkDetails ?? this.lightWorkDetails,
      hazardousWorkFreePeriodDetails: hazardousWorkFreePeriodDetails ?? this.hazardousWorkFreePeriodDetails,
      
      // Section 4: Legal Documentation
      hasBirthCertificate: hasBirthCertificate ?? this.hasBirthCertificate,
      ongoingBirthCertProcess: ongoingBirthCertProcess ?? this.ongoingBirthCertProcess,
      noBirthCertificateReason: noBirthCertificateReason ?? this.noBirthCertificateReason,
      birthCertificateStatus: birthCertificateStatus ?? this.birthCertificateStatus,
      ongoingBirthCertProcessDetails: ongoingBirthCertProcessDetails ?? this.ongoingBirthCertProcessDetails,
      
      // Section 5: Family & Caregiver Engagement
      receivedAwarenessSessions: receivedAwarenessSessions ?? this.receivedAwarenessSessions,
      improvedUnderstanding: improvedUnderstanding ?? this.improvedUnderstanding,
      caregiversSupportSchool: caregiversSupportSchool ?? this.caregiversSupportSchool,
      awarenessSessionsDetails: awarenessSessionsDetails ?? this.awarenessSessionsDetails,
      understandingImprovementDetails: understandingImprovementDetails ?? this.understandingImprovementDetails,
      caregiverSupportDetails: caregiverSupportDetails ?? this.caregiverSupportDetails,
      
      // Section 6: Additional Support Provided
      receivedFinancialSupport: receivedFinancialSupport ?? this.receivedFinancialSupport,
      referralsMade: referralsMade ?? this.referralsMade,
      ongoingFollowUpPlanned: ongoingFollowUpPlanned ?? this.ongoingFollowUpPlanned,
      financialSupportDetails: financialSupportDetails ?? this.financialSupportDetails,
      referralsDetails: referralsDetails ?? this.referralsDetails,
      followUpPlanDetails: followUpPlanDetails ?? this.followUpPlanDetails,
      
      // Section 7: Overall Assessment
      consideredRemediated: consideredRemediated ?? this.consideredRemediated,
      additionalComments: additionalComments ?? this.additionalComments,
      
      // Section 8: Follow-up Cycle Completion
      followUpVisitsCountSinceIdentification: followUpVisitsCountSinceIdentification ?? this.followUpVisitsCountSinceIdentification,
      visitsSpacedCorrectly: visitsSpacedCorrectly ?? this.visitsSpacedCorrectly,
      confirmedNotInChildLabour: confirmedNotInChildLabour ?? this.confirmedNotInChildLabour,
      followUpCycleComplete: followUpCycleComplete ?? this.followUpCycleComplete,
      
      // Additional fields
      currentSchool: currentSchool ?? this.currentSchool,
      currentGrade: currentGrade ?? this.currentGrade,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      schoolPerformance: schoolPerformance ?? this.schoolPerformance,
      challengesFaced: challengesFaced ?? this.challengesFaced,
      supportNeeded: supportNeeded ?? this.supportNeeded,
      attendanceNotes: attendanceNotes ?? this.attendanceNotes,
      performanceNotes: performanceNotes ?? this.performanceNotes,
      supportNotes: supportNotes ?? this.supportNotes,
      otherNotes: otherNotes ?? this.otherNotes,
    );
  }

  // Convert a MonitoringModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_created': DateFormat('yyyy-MM-dd HH:mm:ss').format(dateCreated),
      'date_modified': dateModified != null 
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(dateModified!) 
          : null,
      'status': status,
      'community_id': communityId,
      'visit_date': DateFormat('yyyy-MM-dd').format(visitDate),
      'notes': notes,
      
      // Section 1: Child Identification
      'child_id': childId,
      'child_name': childName,
      'age': age,
      'sex': sex,
      'community': community,
      'farmer_id': farmerId,
      'first_remediation_date': firstRemediationDate,
      'remediation_form_provided': remediationFormProvided,
      'follow_up_visits_count': followUpVisitsCount,
      
      // Section 2: Education Progress
      'class_at_remediation': classAtRemediation,
      'is_enrolled_in_school': isEnrolledInSchool ? 1 : 0,
      'attendance_improved': attendanceImproved ? 1 : 0,
      'received_school_materials': receivedSchoolMaterials ? 1 : 0,
      'can_read_basic_text': canReadBasicText ? 1 : 0,
      'can_write_basic_text': canWriteBasicText ? 1 : 0,
      'can_do_calculations': canDoCalculations ? 1 : 0,
      'advanced_to_next_grade': advancedToNextGrade ? 1 : 0,
      'academic_year_ended': academicYearEnded ? 1 : 0,
      'promoted': promoted != null ? (promoted! ? 1 : 0) : null,
      'academic_improvement': academicImprovement != null ? (academicImprovement! ? 1 : 0) : null,
      'promoted_grade': promotedGrade,
      'recommendations': recommendations,
      
      // Section 3: Child Labour Risk
      'engaged_in_hazardous_work': engagedInHazardousWork ? 1 : 0,
      'reduced_work_hours': reducedWorkHours ? 1 : 0,
      'involved_in_light_work': involvedInLightWork ? 1 : 0,
      'out_of_hazardous_work': outOfHazardousWork ? 1 : 0,
      'hazardous_work_details': hazardousWorkDetails,
      'reduced_work_hours_details': reducedWorkHoursDetails,
      'light_work_details': lightWorkDetails,
      'hazardous_work_free_period_details': hazardousWorkFreePeriodDetails,
      
      // Section 4: Legal Documentation
      'has_birth_certificate': hasBirthCertificate ? 1 : 0,
      'ongoing_birth_cert_process': ongoingBirthCertProcess != null ? (ongoingBirthCertProcess! ? 1 : 0) : null,
      'no_birth_certificate_reason': noBirthCertificateReason,
      'birth_certificate_status': birthCertificateStatus,
      'ongoing_birth_cert_process_details': ongoingBirthCertProcessDetails,
      
      // Section 5: Family & Caregiver Engagement
      'received_awareness_sessions': receivedAwarenessSessions ? 1 : 0,
      'improved_understanding': improvedUnderstanding ? 1 : 0,
      'caregivers_support_school': caregiversSupportSchool ? 1 : 0,
      'awareness_sessions_details': awarenessSessionsDetails,
      'understanding_improvement_details': understandingImprovementDetails,
      'caregiver_support_details': caregiverSupportDetails,
      
      // Section 6: Additional Support Provided
      'received_financial_support': receivedFinancialSupport ? 1 : 0,
      'referrals_made': referralsMade ? 1 : 0,
      'ongoing_follow_up_planned': ongoingFollowUpPlanned ? 1 : 0,
      'financial_support_details': financialSupportDetails,
      'referrals_details': referralsDetails,
      'follow_up_plan_details': followUpPlanDetails,
      
      // Section 7: Overall Assessment
      'considered_remediated': consideredRemediated ? 1 : 0,
      'additional_comments': additionalComments,
      
      // Section 8: Follow-up Cycle Completion
      'follow_up_visits_since_identification': followUpVisitsCountSinceIdentification,
      'visits_spaced_correctly': visitsSpacedCorrectly ? 1 : 0,
      'confirmed_not_in_child_labour': confirmedNotInChildLabour ? 1 : 0,
      'follow_up_cycle_complete': followUpCycleComplete ? 1 : 0,
      
      // Additional fields
      'current_school': currentSchool,
      'current_grade': currentGrade,
      'attendance_rate': attendanceRate,
      'school_performance': schoolPerformance,
      'challenges_faced': challengesFaced,
      'support_needed': supportNeeded,
      'attendance_notes': attendanceNotes,
      'performance_notes': performanceNotes,
      'support_notes': supportNotes,
      'other_notes': otherNotes,
      
      'raw_data': rawData ?? {},
    };
  }

  // Create a MonitoringModel from a Map
  factory MonitoringModel.fromMap(Map<String, dynamic> map) {
    return MonitoringModel(
      id: map['id'],
      dateCreated: map['date_created'] != null 
          ? DateTime.parse(map['date_created']) 
          : null,
      dateModified: map['date_modified'] != null 
          ? DateTime.parse(map['date_modified']) 
          : null,
      status: map['status'] ?? 0,
      communityId: map['community_id'],
      visitDate: map['visit_date'] != null 
          ? DateTime.parse(map['visit_date']) 
          : DateTime.now(),
      notes: map['notes'],
      
      // Section 1: Child Identification
      childId: map['child_id'] ?? '',
      childName: map['child_name'] ?? '',
      age: map['age'] ?? '',
      sex: map['sex'] ?? '',
      community: map['community'] ?? '',
      farmerId: map['farmer_id'] ?? '',
      firstRemediationDate: map['first_remediation_date'] ?? '',
      remediationFormProvided: map['remediation_form_provided'] ?? '',
      followUpVisitsCount: map['follow_up_visits_count'] ?? '',
      
      // Section 2: Education Progress
      classAtRemediation: map['class_at_remediation'] ?? '',
      isEnrolledInSchool: map['is_enrolled_in_school'] == 1,
      attendanceImproved: map['attendance_improved'] == 1,
      receivedSchoolMaterials: map['received_school_materials'] == 1,
      canReadBasicText: map['can_read_basic_text'] == 1,
      canWriteBasicText: map['can_write_basic_text'] == 1,
      canDoCalculations: map['can_do_calculations'] == 1,
      advancedToNextGrade: map['advanced_to_next_grade'] == 1,
      academicYearEnded: map['academic_year_ended'] == 1,
      promoted: map['promoted'] != null ? map['promoted'] == 1 : null,
      academicImprovement: map['academic_improvement'] != null ? map['academic_improvement'] == 1 : null,
      promotedGrade: map['promoted_grade'],
      recommendations: map['recommendations'],
      
      // Section 3: Child Labour Risk
      engagedInHazardousWork: map['engaged_in_hazardous_work'] == 1,
      reducedWorkHours: map['reduced_work_hours'] == 1,
      involvedInLightWork: map['involved_in_light_work'] == 1,
      outOfHazardousWork: map['out_of_hazardous_work'] == 1,
      hazardousWorkDetails: map['hazardous_work_details'],
      reducedWorkHoursDetails: map['reduced_work_hours_details'],
      lightWorkDetails: map['light_work_details'],
      hazardousWorkFreePeriodDetails: map['hazardous_work_free_period_details'],
      
      // Section 4: Legal Documentation
      hasBirthCertificate: map['has_birth_certificate'] == 1,
      ongoingBirthCertProcess: map['ongoing_birth_cert_process'] != null ? map['ongoing_birth_cert_process'] == 1 : null,
      noBirthCertificateReason: map['no_birth_certificate_reason'],
      birthCertificateStatus: map['birth_certificate_status'],
      ongoingBirthCertProcessDetails: map['ongoing_birth_cert_process_details'],
      
      // Section 5: Family & Caregiver Engagement
      receivedAwarenessSessions: map['received_awareness_sessions'] == 1,
      improvedUnderstanding: map['improved_understanding'] == 1,
      caregiversSupportSchool: map['caregivers_support_school'] == 1,
      awarenessSessionsDetails: map['awareness_sessions_details'],
      understandingImprovementDetails: map['understanding_improvement_details'],
      caregiverSupportDetails: map['caregiver_support_details'],
      
      // Section 6: Additional Support Provided
      receivedFinancialSupport: map['received_financial_support'] == 1,
      referralsMade: map['referrals_made'] == 1,
      ongoingFollowUpPlanned: map['ongoing_follow_up_planned'] == 1,
      financialSupportDetails: map['financial_support_details'],
      referralsDetails: map['referrals_details'],
      followUpPlanDetails: map['follow_up_plan_details'],
      
      // Section 7: Overall Assessment
      consideredRemediated: map['considered_remediated'] == 1,
      additionalComments: map['additional_comments'] ?? '',
      
      // Section 8: Follow-up Cycle Completion
      followUpVisitsCountSinceIdentification: map['follow_up_visits_since_identification'] ?? '',
      visitsSpacedCorrectly: map['visits_spaced_correctly'] == 1,
      confirmedNotInChildLabour: map['confirmed_not_in_child_labour'] == 1,
      followUpCycleComplete: map['follow_up_cycle_complete'] == 1,
      
      // Additional fields
      currentSchool: map['current_school'],
      currentGrade: map['current_grade'],
      attendanceRate: map['attendance_rate'],
      schoolPerformance: map['school_performance'],
      challengesFaced: map['challenges_faced'],
      supportNeeded: map['support_needed'],
      attendanceNotes: map['attendance_notes'],
      performanceNotes: map['performance_notes'],
      supportNotes: map['support_notes'],
      otherNotes: map['other_notes'],
      
      rawData: map['raw_data'] is String 
          ? json.decode(map['raw_data']) 
          : map['raw_data'] ?? {},
    );
  }

  // Helper method to calculate monitoring score
  int calculateMonitoringScore() {
    int score = 0;
    
    // Education Progress (max 70 points)
    if (isEnrolledInSchool) score += 10;
    if (attendanceImproved) score += 10;
    if (receivedSchoolMaterials) score += 10;
    if (canReadBasicText) score += 10;
    if (canWriteBasicText) score += 10;
    if (canDoCalculations) score += 10;
    if (advancedToNextGrade) score += 10;
    
    // Child Labour Risk (max 35 points)
    if (!engagedInHazardousWork) score += 10;
    if (reducedWorkHours) score += 10;
    if (involvedInLightWork) score += 5;
    if (outOfHazardousWork) score += 10;
    
    // Legal Documentation (max 15 points)
    if (hasBirthCertificate) score += 10;
    if (ongoingBirthCertProcess == true) score += 5;
    
    return score;
  }

  // Helper method to check if form is complete
  bool isFormComplete() {
    return childId.isNotEmpty &&
        childName.isNotEmpty &&
        age.isNotEmpty &&
        sex.isNotEmpty &&
        community.isNotEmpty &&
        farmerId.isNotEmpty &&
        firstRemediationDate.isNotEmpty;
  }

  // Helper method to get form status as string
  String getStatusText() {
    switch (status) {
      case 0:
        return 'Draft';
      case 1:
        return 'Submitted';
      case 2:
        return 'Synced';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'MonitoringModel(id: $id, childName: $childName, community: $community, status: ${getStatusText()})';
  }
}