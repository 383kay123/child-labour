class MonitoringModel {
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

  // Section 2: Education Progress
  bool isEnrolledInSchool;
  bool attendanceImproved;
  bool receivedSchoolMaterials;
  bool canReadWriteBasicText;
  bool advancedToNextGrade;
  String classAtRemediation;
  bool academicYearEnded;
  bool? promoted;
  String? promotedGrade;
  bool? improvementInSkills;
  String? recommendations;

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

  // Section 6: Additional Support Provided
  bool receivedFinancialSupport;
  bool referralsMade;
  bool ongoingFollowUpPlanned;

  // Section 7: Overall Assessment
  bool consideredRemediated;
  String additionalComments;

  // Section 8: Follow-up Cycle Completion
  String followUpVisitsCountSinceIdentification;
  bool visitsSpacedCorrectly;
  bool confirmedNotInChildLabour;
  bool followUpCycleComplete;

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

    // Section 2
    this.isEnrolledInSchool = false,
    this.attendanceImproved = false,
    this.receivedSchoolMaterials = false,
    this.canReadWriteBasicText = false,
    this.advancedToNextGrade = false,
    this.classAtRemediation = '',
    this.academicYearEnded = false,
    this.promoted,
    this.promotedGrade,
    this.improvementInSkills,
    this.recommendations,

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

    // Section 6
    this.receivedFinancialSupport = false,
    this.referralsMade = false,
    this.ongoingFollowUpPlanned = false,

    // Section 7
    this.consideredRemediated = false,
    this.additionalComments = '',

    // Section 8
    this.followUpVisitsCountSinceIdentification = '',
    this.visitsSpacedCorrectly = false,
    this.confirmedNotInChildLabour = false,
    this.followUpCycleComplete = false,
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

      // Section 2
      'isEnrolledInSchool': isEnrolledInSchool,
      'attendanceImproved': attendanceImproved,
      'receivedSchoolMaterials': receivedSchoolMaterials,
      'canReadWriteBasicText': canReadWriteBasicText,
      'advancedToNextGrade': advancedToNextGrade,
      'classAtRemediation': classAtRemediation,
      'academicYearEnded': academicYearEnded,
      'promoted': promoted,
      'promotedGrade': promotedGrade,
      'improvementInSkills': improvementInSkills,
      'recommendations': recommendations,

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

      // Section 6
      'receivedFinancialSupport': receivedFinancialSupport,
      'referralsMade': referralsMade,
      'ongoingFollowUpPlanned': ongoingFollowUpPlanned,

      // Section 7
      'consideredRemediated': consideredRemediated,
      'additionalComments': additionalComments,

      // Section 8
      'followUpVisitsCountSinceIdentification': followUpVisitsCountSinceIdentification,
      'visitsSpacedCorrectly': visitsSpacedCorrectly,
      'confirmedNotInChildLabour': confirmedNotInChildLabour,
      'followUpCycleComplete': followUpCycleComplete,
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

      // Section 2
      isEnrolledInSchool: map['isEnrolledInSchool'] ?? false,
      attendanceImproved: map['attendanceImproved'] ?? false,
      receivedSchoolMaterials: map['receivedSchoolMaterials'] ?? false,
      canReadWriteBasicText: map['canReadWriteBasicText'] ?? false,
      advancedToNextGrade: map['advancedToNextGrade'] ?? false,
      classAtRemediation: map['classAtRemediation'] ?? '',
      academicYearEnded: map['academicYearEnded'] ?? false,
      promoted: map['promoted'],
      promotedGrade: map['promotedGrade'],
      improvementInSkills: map['improvementInSkills'],
      recommendations: map['recommendations'],

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

      // Section 6
      receivedFinancialSupport: map['receivedFinancialSupport'] ?? false,
      referralsMade: map['referralsMade'] ?? false,
      ongoingFollowUpPlanned: map['ongoingFollowUpPlanned'] ?? false,

      // Section 7
      consideredRemediated: map['consideredRemediated'] ?? false,
      additionalComments: map['additionalComments'] ?? '',

      // Section 8
      followUpVisitsCountSinceIdentification: map['followUpVisitsCountSinceIdentification'] ?? '',
      visitsSpacedCorrectly: map['visitsSpacedCorrectly'] ?? false,
      confirmedNotInChildLabour: map['confirmedNotInChildLabour'] ?? false,
      followUpCycleComplete: map['followUpCycleComplete'] ?? false,
    );
  }
}