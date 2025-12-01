class MonitoringModel {
  // Copy with method to create a new instance with updated fields
  MonitoringModel copyWith({
    int? id,
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
    String? hazardousWorkDetails,
    String? reducedWorkHoursDetails,
    String? lightWorkDetails,
    String? hazardousWorkFreePeriodDetails,
    String? birthCertificateStatus,
    String? ongoingBirthCertProcess,
    // Section 2: Education Progress
    bool? isEnrolledInSchool,
    bool? attendanceImproved,
    bool? receivedSchoolMaterials,
    bool? canReadBasicText,
    bool? canWriteBasicText,
    bool? advancedToNextGrade,
    String? classAtRemediation,
    bool? academicYearEnded,
    bool? promoted,
    String? promotedGrade,
    bool? improvementInSkills,
    String? recommendations,
    String? remediationClass,
    String? academicYearStatus,
    // Section 3: Child Labour Risk
    bool? engagedInHazardousWork,
    bool? reducedWorkHours,
    bool? involvedInLightWork,
    bool? outOfHazardousWork,
  }) {
    return MonitoringModel(
      id: id ?? this.id,
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
      hazardousWorkDetails: hazardousWorkDetails ?? this.hazardousWorkDetails,
      reducedWorkHoursDetails: reducedWorkHoursDetails ?? this.reducedWorkHoursDetails,
      lightWorkDetails: lightWorkDetails ?? this.lightWorkDetails,
      hazardousWorkFreePeriodDetails: hazardousWorkFreePeriodDetails ?? this.hazardousWorkFreePeriodDetails,
      birthCertificateStatus: birthCertificateStatus ?? this.birthCertificateStatus,
      ongoingBirthCertProcess: ongoingBirthCertProcess ?? this.ongoingBirthCertProcess,
      // Section 2: Education Progress
      isEnrolledInSchool: isEnrolledInSchool ?? this.isEnrolledInSchool,
      attendanceImproved: attendanceImproved ?? this.attendanceImproved,
      receivedSchoolMaterials: receivedSchoolMaterials ?? this.receivedSchoolMaterials,
      canReadBasicText: canReadBasicText ?? this.canReadBasicText,
      canWriteBasicText: canWriteBasicText ?? this.canWriteBasicText,
      advancedToNextGrade: advancedToNextGrade ?? this.advancedToNextGrade,
      classAtRemediation: classAtRemediation ?? this.classAtRemediation,
      academicYearEnded: academicYearEnded ?? this.academicYearEnded,
      promoted: promoted ?? this.promoted,
      promotedGrade: promotedGrade ?? this.promotedGrade,
      improvementInSkills: improvementInSkills ?? this.improvementInSkills,
      recommendations: recommendations ?? this.recommendations,
      remediationClass: remediationClass ?? this.remediationClass,
      academicYearStatus: academicYearStatus ?? this.academicYearStatus,
      // Section 3: Child Labour Risk
      engagedInHazardousWork: engagedInHazardousWork ?? this.engagedInHazardousWork,
      reducedWorkHours: reducedWorkHours ?? this.reducedWorkHours,
      involvedInLightWork: involvedInLightWork ?? this.involvedInLightWork,
      outOfHazardousWork: outOfHazardousWork ?? this.outOfHazardousWork,
    );
  }
  int? id;
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
  String? hazardousWorkDetails;
  String? reducedWorkHoursDetails;
  String? lightWorkDetails;
  String? hazardousWorkFreePeriodDetails;
  String? birthCertificateStatus;
  String? ongoingBirthCertProcess;

  // Section 2: Education Progress
  bool? isEnrolledInSchool;
  bool? attendanceImproved;
  bool? receivedSchoolMaterials;
  bool? canReadBasicText;
  bool? canWriteBasicText;
  bool? advancedToNextGrade;
  String classAtRemediation;
  bool academicYearEnded;
  bool? promoted;
  String? promotedGrade;
  bool? improvementInSkills;
  String? recommendations;
  String? remediationClass;
  String? academicYearStatus;

  // Section 3: Child Labour Risk
  bool engagedInHazardousWork;
  bool reducedWorkHours;
  bool involvedInLightWork;
  bool outOfHazardousWork;

  // Section 4: Legal Documentation
  bool hasBirthCertificate;
  bool? birthCertificateProcess;
  String? noBirthCertificateReason;

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

  // Status field
  int status;

  MonitoringModel({
    this.id,
    // Section 1
    this.childId = '',
    this.childName = '',
    this.age = '',
    this.sex = '',
    this.community = '',
    this.farmerId = '',
    this.firstRemediationDate = '',
    this.remediationFormProvided = '',
    this.followUpVisitsCount = '',
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
    this.hazardousWorkDetails,
    this.reducedWorkHoursDetails,
    this.lightWorkDetails,
    this.hazardousWorkFreePeriodDetails,
    this.birthCertificateStatus,
    this.ongoingBirthCertProcess,

    // Section 2
    this.isEnrolledInSchool = false,
    this.attendanceImproved = false,
    this.receivedSchoolMaterials = false,
    this.canReadBasicText = false,
    this.canWriteBasicText = false,
    this.advancedToNextGrade = false,
    this.classAtRemediation = '',
    this.academicYearEnded = false,
    this.promoted,
    this.promotedGrade,
    this.improvementInSkills,
    this.recommendations,
    this.remediationClass,
    this.academicYearStatus,

    // Section 3
    this.engagedInHazardousWork = false,
    this.reducedWorkHours = false,
    this.involvedInLightWork = false,
    this.outOfHazardousWork = false,

    // Section 4
    this.hasBirthCertificate = false,
    this.birthCertificateProcess,
    this.noBirthCertificateReason,

    // Section 5
    this.receivedAwarenessSessions = false,
    this.improvedUnderstanding = false,
    this.caregiversSupportSchool = false,
    this.awarenessSessionsDetails,
    this.understandingImprovementDetails,
    this.caregiverSupportDetails,

    // Section 6
    this.receivedFinancialSupport = false,
    this.referralsMade = false,
    this.ongoingFollowUpPlanned = false,
    this.financialSupportDetails,
    this.referralsDetails,
    this.followUpPlanDetails,

    // Section 7
    this.consideredRemediated = false,
    this.additionalComments = '',

    // Section 8
    this.followUpVisitsCountSinceIdentification = '',
    this.visitsSpacedCorrectly = false,
    this.confirmedNotInChildLabour = false,
    this.followUpCycleComplete = false,

    // Status (0: Draft, 1: Submitted, etc.)
    this.status = 0,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // Section 1
      'childId': childId,
      'childName': childName,
      'age': age,
      'sex': sex,
      'community': community,
      'farmerId': farmerId,
      'firstRemediationDate': firstRemediationDate,
      'remediationFormProvided': remediationFormProvided,
      'followUpVisitsCount': followUpVisitsCount,
      'currentSchool': currentSchool,
      'currentGrade': currentGrade,
      'attendanceRate': attendanceRate,
      'schoolPerformance': schoolPerformance,
      'challengesFaced': challengesFaced,
      'supportNeeded': supportNeeded,
      'attendanceNotes': attendanceNotes,
      'performanceNotes': performanceNotes,
      'supportNotes': supportNotes,
      'otherNotes': otherNotes,
      'hazardousWorkDetails': hazardousWorkDetails,
      'reducedWorkHoursDetails': reducedWorkHoursDetails,
      'lightWorkDetails': lightWorkDetails,
      'hazardousWorkFreePeriodDetails': hazardousWorkFreePeriodDetails,
      'birthCertificateStatus': birthCertificateStatus,
      'ongoingBirthCertProcess': ongoingBirthCertProcess,

      // Section 2
      'is_enrolled_in_school': isEnrolledInSchool! ? 1 : 0,
      'attendance_improved': attendanceImproved! ? 1 : 0,
      'received_school_materials': receivedSchoolMaterials! ? 1 : 0,
      'can_read_basic_text': canReadBasicText! ? 1 : 0,
      'can_write_basic_text': canWriteBasicText! ? 1 : 0,
      'advanced_to_next_grade': advancedToNextGrade! ? 1 : 0,
      'classAtRemediation': classAtRemediation,
      'academicYearEnded': academicYearEnded,
      'promoted': promoted,
      'promotedGrade': promotedGrade,
      'improvementInSkills': improvementInSkills,
      'recommendations': recommendations,
      'remediationClass': remediationClass,
      'academicYearStatus': academicYearStatus,

      // Section 3
      'engagedInHazardousWork': engagedInHazardousWork,
      'reducedWorkHours': reducedWorkHours,
      'involvedInLightWork': involvedInLightWork,
      'outOfHazardousWork': outOfHazardousWork,

      // Section 4
      'hasBirthCertificate': hasBirthCertificate,
      'birthCertificateProcess': birthCertificateProcess,
      'noBirthCertificateReason': noBirthCertificateReason,

      // Section 5
      'receivedAwarenessSessions': receivedAwarenessSessions,
      'improvedUnderstanding': improvedUnderstanding,
      'caregiversSupportSchool': caregiversSupportSchool,
      'awarenessSessionsDetails': awarenessSessionsDetails,
      'understandingImprovementDetails': understandingImprovementDetails,
      'caregiverSupportDetails': caregiverSupportDetails,

      // Section 6
      'receivedFinancialSupport': receivedFinancialSupport,
      'referralsMade': referralsMade,
      'ongoingFollowUpPlanned': ongoingFollowUpPlanned,
      'financialSupportDetails': financialSupportDetails,
      'referralsDetails': referralsDetails,
      'followUpPlanDetails': followUpPlanDetails,

      // Section 7
      'consideredRemediated': consideredRemediated,
      'additionalComments': additionalComments,

      // Section 8
      'followUpVisitsCountSinceIdentification': followUpVisitsCountSinceIdentification,
      'visitsSpacedCorrectly': visitsSpacedCorrectly,
      'confirmedNotInChildLabour': confirmedNotInChildLabour,
      'followUpCycleComplete': followUpCycleComplete,

      'status': status,
    };
  }

  // Create from Map for retrieval
  factory MonitoringModel.fromMap(Map<String, dynamic> map) {
    return MonitoringModel(
      id: map['id'],
      // Section 1
      childId: map['childId'] ?? '',
      childName: map['childName'] ?? '',
      age: map['age'] ?? '',
      sex: map['sex'] ?? '',
      community: map['community'] ?? '',
      farmerId: map['farmerId'] ?? '',
      firstRemediationDate: map['firstRemediationDate'] ?? '',
      remediationFormProvided: map['remediationFormProvided'] ?? '',
      followUpVisitsCount: map['followUpVisitsCount'] ?? '',
      currentSchool: map['currentSchool'],
      currentGrade: map['currentGrade'],
      attendanceRate: map['attendanceRate'],
      schoolPerformance: map['schoolPerformance'],
      challengesFaced: map['challengesFaced'],
      supportNeeded: map['supportNeeded'],
      attendanceNotes: map['attendanceNotes'],
      performanceNotes: map['performanceNotes'],
      supportNotes: map['supportNotes'],
      otherNotes: map['otherNotes'],
      hazardousWorkDetails: map['hazardousWorkDetails'],
      reducedWorkHoursDetails: map['reducedWorkHoursDetails'],
      lightWorkDetails: map['lightWorkDetails'],
      hazardousWorkFreePeriodDetails: map['hazardousWorkFreePeriodDetails'],
      birthCertificateStatus: map['birthCertificateStatus'],
      ongoingBirthCertProcess: map['ongoingBirthCertProcess'],

      // Section 2
      isEnrolledInSchool: map['is_enrolled_in_school'] == 1,
      attendanceImproved: map['attendance_improved'] == 1,
      receivedSchoolMaterials: map['received_school_materials'] == 1,
      canReadBasicText: map['can_read_basic_text'] == 1,
      canWriteBasicText: map['can_write_basic_text'] == 1,
      advancedToNextGrade: map['advanced_to_next_grade'] == 1,
      classAtRemediation: map['classAtRemediation'] ?? '',
      academicYearEnded: map['academicYearEnded'] ?? false,
      promoted: map['promoted'],
      promotedGrade: map['promotedGrade'],
      improvementInSkills: map['improvementInSkills'],
      recommendations: map['recommendations'],
      remediationClass: map['remediationClass'],
      academicYearStatus: map['academicYearStatus'],

      // Section 3
      engagedInHazardousWork: map['engagedInHazardousWork'] ?? false,
      reducedWorkHours: map['reducedWorkHours'] ?? false,
      involvedInLightWork: map['involvedInLightWork'] ?? false,
      outOfHazardousWork: map['outOfHazardousWork'] ?? false,

      // Section 4
      hasBirthCertificate: map['hasBirthCertificate'] ?? false,
      birthCertificateProcess: map['birthCertificateProcess'],
      noBirthCertificateReason: map['noBirthCertificateReason'],

      // Section 5
      receivedAwarenessSessions: map['receivedAwarenessSessions'] ?? false,
      improvedUnderstanding: map['improvedUnderstanding'] ?? false,
      caregiversSupportSchool: map['caregiversSupportSchool'] ?? false,
      awarenessSessionsDetails: map['awarenessSessionsDetails'],
      understandingImprovementDetails: map['understandingImprovementDetails'],
      caregiverSupportDetails: map['caregiverSupportDetails'],

      // Section 6
      receivedFinancialSupport: map['receivedFinancialSupport'] ?? false,
      referralsMade: map['referralsMade'] ?? false,
      ongoingFollowUpPlanned: map['ongoingFollowUpPlanned'] ?? false,
      financialSupportDetails: map['financialSupportDetails'],
      referralsDetails: map['referralsDetails'],
      followUpPlanDetails: map['followUpPlanDetails'],

      // Section 7
      consideredRemediated: map['consideredRemediated'] ?? false,
      additionalComments: map['additionalComments'] ?? '',

      // Section 8
      followUpVisitsCountSinceIdentification: map['followUpVisitsCountSinceIdentification'] ?? '',
      visitsSpacedCorrectly: map['visitsSpacedCorrectly'] ?? false,
      confirmedNotInChildLabour: map['confirmedNotInChildLabour'] ?? false,
      followUpCycleComplete: map['followUpCycleComplete'] ?? false,

      status: map['status'] ?? 0,
    );
  }
}