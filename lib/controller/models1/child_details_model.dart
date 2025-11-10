class ChildDetailsModel {
  // Basic Information
  final String? name;
  final String? surname;
  final String? childNumber;
  final int? birthYear;
  final String? gender;
  final bool? isFarmerChild;
  final bool? canBeSurveyedNow;
  final DateTime? interviewDate;

  // Survey Availability
  final List<String> surveyNotPossibleReasons;
  final String? otherSurveyNotPossibleReason;
  final String? respondentType;
  final String? otherRespondentType;
  final String? respondentName;
  final String? otherRespondentSpecify;

  // Birth and Documentation
  final bool? hasBirthCertificate;
  final String? noBirthCertificateReason;
  final bool? bornInCommunity;
  final String? birthCountry;

  // Household Relationship
  final String? relationshipToHead;
  final String? otherRelationship;
  final Map<String, bool> notLivingWithFamilyReasons;
  final String? otherNotLivingWithFamilyReason;

  // Family Decision Information
  final String? whoDecidedChildJoin;
  final String? otherPersonDecided;
  final bool? childAgreedWithDecision;
  final bool? hasSpokenWithParents;
  final String? lastContactWithParents;
  final String? timeInHousehold;
  final String? whoAccompaniedChild;
  final String? otherAccompaniedPerson;

  // Parent Residence Information
  final String? fatherResidence;
  final String? fatherCountry;
  final String? otherFatherCountry;
  final String? motherResidence;
  final String? motherCountry;
  final String? otherMotherCountry;

  // Education Information
  final bool? isCurrentlyEnrolled;
  final bool? hasEverBeenToSchool;
  final String? schoolName;
  final String? schoolType;
  final String? gradeLevel;
  final String? schoolAttendanceFrequency;
  final Set<String> availableSchoolSupplies;
  
  // School Leaving Information
  final String? leftSchoolYear;
  final DateTime? leftSchoolDate;
  final String? educationLevel;
  final String? childLeaveSchoolReason;
  final String? otherLeaveReason;
  final String? neverBeenToSchoolReason;
  final String? otherNeverSchoolReason;

  // School Attendance
  final bool? attendedSchoolLast7Days;
  final String? selectedLeaveReason;
  final String? otherAbsenceReason;

  // Constructor
  ChildDetailsModel({
    // Basic Information
    this.name,
    this.surname,
    this.childNumber,
    this.birthYear,
    this.gender,
    this.isFarmerChild,
    this.canBeSurveyedNow,
    this.interviewDate,
    
    // Survey Availability
    List<String>? surveyNotPossibleReasons,
    this.otherSurveyNotPossibleReason,
    this.respondentType,
    this.otherRespondentType,
    this.respondentName,
    this.otherRespondentSpecify,
    
    // Birth and Documentation
    this.hasBirthCertificate,
    this.noBirthCertificateReason,
    this.bornInCommunity,
    this.birthCountry,
    
    // Household Relationship
    this.relationshipToHead,
    this.otherRelationship,
    Map<String, bool>? notLivingWithFamilyReasons,
    this.otherNotLivingWithFamilyReason,
    
    // Family Decision Information
    this.whoDecidedChildJoin,
    this.otherPersonDecided,
    this.childAgreedWithDecision,
    this.hasSpokenWithParents,
    this.lastContactWithParents,
    this.timeInHousehold,
    this.whoAccompaniedChild,
    this.otherAccompaniedPerson,
    
    // Parent Residence Information
    this.fatherResidence,
    this.fatherCountry,
    this.otherFatherCountry,
    this.motherResidence,
    this.motherCountry,
    this.otherMotherCountry,
    
    // Education Information
    this.isCurrentlyEnrolled,
    this.hasEverBeenToSchool,
    this.schoolName,
    this.schoolType,
    this.gradeLevel,
    this.schoolAttendanceFrequency,
    Set<String>? availableSchoolSupplies,
    
    // School Leaving Information
    this.leftSchoolYear,
    this.leftSchoolDate,
    this.educationLevel,
    this.childLeaveSchoolReason,
    this.otherLeaveReason,
    this.neverBeenToSchoolReason,
    this.otherNeverSchoolReason,
    
    // School Attendance
    this.attendedSchoolLast7Days,
    this.selectedLeaveReason,
    this.otherAbsenceReason,
  })  : surveyNotPossibleReasons = surveyNotPossibleReasons ?? [],
        notLivingWithFamilyReasons = notLivingWithFamilyReasons ?? {
          'Child lives with other relatives': false,
          'Child is an orphan': false,
          'For education purposes': false,
          'Family is too poor to take care of the child': false,
          'Child is working to support family': false,
          'Other (specify)': false,
        },
        availableSchoolSupplies = availableSchoolSupplies ?? {};

  // Create a copyWith method for immutability
  ChildDetailsModel copyWith({
    String? name,
    String? surname,
    String? childNumber,
    int? birthYear,
    String? gender,
    bool? isFarmerChild,
    bool? canBeSurveyedNow,
    DateTime? interviewDate,
    
    // Survey Availability
    List<String>? surveyNotPossibleReasons,
    String? otherSurveyNotPossibleReason,
    String? respondentType,
    String? otherRespondentType,
    String? respondentName,
    String? otherRespondentSpecify,
    
    // Birth and Documentation
    bool? hasBirthCertificate,
    String? noBirthCertificateReason,
    bool? bornInCommunity,
    String? birthCountry,
    
    // Household Relationship
    String? relationshipToHead,
    String? otherRelationship,
    Map<String, bool>? notLivingWithFamilyReasons,
    String? otherNotLivingWithFamilyReason,
    
    // Family Decision Information
    String? whoDecidedChildJoin,
    String? otherPersonDecided,
    bool? childAgreedWithDecision,
    bool? hasSpokenWithParents,
    String? lastContactWithParents,
    String? timeInHousehold,
    String? whoAccompaniedChild,
    String? otherAccompaniedPerson,
    
    // Parent Residence Information
    String? fatherResidence,
    String? fatherCountry,
    String? otherFatherCountry,
    String? motherResidence,
    String? motherCountry,
    String? otherMotherCountry,
    
    // Education Information
    bool? isCurrentlyEnrolled,
    bool? hasEverBeenToSchool,
    String? schoolName,
    String? schoolType,
    String? gradeLevel,
    String? schoolAttendanceFrequency,
    Set<String>? availableSchoolSupplies,
    
    // School Leaving Information
    String? leftSchoolYear,
    DateTime? leftSchoolDate,
    String? educationLevel,
    String? childLeaveSchoolReason,
    String? otherLeaveReason,
    String? neverBeenToSchoolReason,
    String? otherNeverSchoolReason,
    
    // School Attendance
    bool? attendedSchoolLast7Days,
    String? selectedLeaveReason,
    String? otherAbsenceReason,
  }) {
    return ChildDetailsModel(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      childNumber: childNumber ?? this.childNumber,
      birthYear: birthYear ?? this.birthYear,
      gender: gender ?? this.gender,
      isFarmerChild: isFarmerChild ?? this.isFarmerChild,
      canBeSurveyedNow: canBeSurveyedNow ?? this.canBeSurveyedNow,
      interviewDate: interviewDate ?? this.interviewDate,
      
      surveyNotPossibleReasons: surveyNotPossibleReasons ?? List.from(this.surveyNotPossibleReasons),
      otherSurveyNotPossibleReason: otherSurveyNotPossibleReason ?? this.otherSurveyNotPossibleReason,
      respondentType: respondentType ?? this.respondentType,
      otherRespondentType: otherRespondentType ?? this.otherRespondentType,
      respondentName: respondentName ?? this.respondentName,
      otherRespondentSpecify: otherRespondentSpecify ?? this.otherRespondentSpecify,
      
      hasBirthCertificate: hasBirthCertificate ?? this.hasBirthCertificate,
      noBirthCertificateReason: noBirthCertificateReason ?? this.noBirthCertificateReason,
      bornInCommunity: bornInCommunity ?? this.bornInCommunity,
      birthCountry: birthCountry ?? this.birthCountry,
      
      relationshipToHead: relationshipToHead ?? this.relationshipToHead,
      otherRelationship: otherRelationship ?? this.otherRelationship,
      notLivingWithFamilyReasons: notLivingWithFamilyReasons ?? Map.from(this.notLivingWithFamilyReasons),
      otherNotLivingWithFamilyReason: otherNotLivingWithFamilyReason ?? this.otherNotLivingWithFamilyReason,
      
      whoDecidedChildJoin: whoDecidedChildJoin ?? this.whoDecidedChildJoin,
      otherPersonDecided: otherPersonDecided ?? this.otherPersonDecided,
      childAgreedWithDecision: childAgreedWithDecision ?? this.childAgreedWithDecision,
      hasSpokenWithParents: hasSpokenWithParents ?? this.hasSpokenWithParents,
      lastContactWithParents: lastContactWithParents ?? this.lastContactWithParents,
      timeInHousehold: timeInHousehold ?? this.timeInHousehold,
      whoAccompaniedChild: whoAccompaniedChild ?? this.whoAccompaniedChild,
      otherAccompaniedPerson: otherAccompaniedPerson ?? this.otherAccompaniedPerson,
      
      fatherResidence: fatherResidence ?? this.fatherResidence,
      fatherCountry: fatherCountry ?? this.fatherCountry,
      otherFatherCountry: otherFatherCountry ?? this.otherFatherCountry,
      motherResidence: motherResidence ?? this.motherResidence,
      motherCountry: motherCountry ?? this.motherCountry,
      otherMotherCountry: otherMotherCountry ?? this.otherMotherCountry,
      
      isCurrentlyEnrolled: isCurrentlyEnrolled ?? this.isCurrentlyEnrolled,
      hasEverBeenToSchool: hasEverBeenToSchool ?? this.hasEverBeenToSchool,
      schoolName: schoolName ?? this.schoolName,
      schoolType: schoolType ?? this.schoolType,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      schoolAttendanceFrequency: schoolAttendanceFrequency ?? this.schoolAttendanceFrequency,
      availableSchoolSupplies: availableSchoolSupplies ?? Set.from(this.availableSchoolSupplies),
      
      leftSchoolYear: leftSchoolYear ?? this.leftSchoolYear,
      leftSchoolDate: leftSchoolDate ?? this.leftSchoolDate,
      educationLevel: educationLevel ?? this.educationLevel,
      childLeaveSchoolReason: childLeaveSchoolReason ?? this.childLeaveSchoolReason,
      otherLeaveReason: otherLeaveReason ?? this.otherLeaveReason,
      neverBeenToSchoolReason: neverBeenToSchoolReason ?? this.neverBeenToSchoolReason,
      otherNeverSchoolReason: otherNeverSchoolReason ?? this.otherNeverSchoolReason,
      
      attendedSchoolLast7Days: attendedSchoolLast7Days ?? this.attendedSchoolLast7Days,
      selectedLeaveReason: selectedLeaveReason ?? this.selectedLeaveReason,
      otherAbsenceReason: otherAbsenceReason ?? this.otherAbsenceReason,
    );
  }

  // Convert to map for database operations
  Map<String, dynamic> toMap() {
    return {
      // Basic Information
      'name': name,
      'surname': surname,
      'childNumber': childNumber,
      'birthYear': birthYear,
      'gender': gender,
      'isFarmerChild': isFarmerChild ?? false ? 1 : 0,
      'canBeSurveyedNow': canBeSurveyedNow ?? false ? 1 : 0,
      'interviewDate': interviewDate?.toIso8601String(),
      
      // Survey Availability
      'surveyNotPossibleReasons': surveyNotPossibleReasons.join('|'),
      'otherSurveyNotPossibleReason': otherSurveyNotPossibleReason,
      'respondentType': respondentType,
      'otherRespondentType': otherRespondentType,
      'respondentName': respondentName,
      'otherRespondentSpecify': otherRespondentSpecify,
      
      // Birth and Documentation
      'hasBirthCertificate': (hasBirthCertificate ?? false) ? 1 : 0,
      'noBirthCertificateReason': noBirthCertificateReason,
      'bornInCommunity': (bornInCommunity ?? false) ? 1 : 0,
      'birthCountry': birthCountry,
      
      // Household Relationship
      'relationshipToHead': relationshipToHead,
      'otherRelationship': otherRelationship,
      'notLivingWithFamilyReasons': notLivingWithFamilyReasons.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .join('|'),
      'otherNotLivingWithFamilyReason': otherNotLivingWithFamilyReason,
      
      // Family Decision Information
      'whoDecidedChildJoin': whoDecidedChildJoin,
      'otherPersonDecided': otherPersonDecided,
      'childAgreedWithDecision': childAgreedWithDecision == true ? 1 : 0,
      'hasSpokenWithParents': hasSpokenWithParents == true ? 1 : 0,
      'lastContactWithParents': lastContactWithParents,
      'timeInHousehold': timeInHousehold,
      'whoAccompaniedChild': whoAccompaniedChild,
      'otherAccompaniedPerson': otherAccompaniedPerson,
      
      // Parent Residence Information
      'fatherResidence': fatherResidence,
      'fatherCountry': fatherCountry,
      'otherFatherCountry': otherFatherCountry,
      'motherResidence': motherResidence,
      'motherCountry': motherCountry,
      'otherMotherCountry': otherMotherCountry,
      
      // Education Information
      'isCurrentlyEnrolled': isCurrentlyEnrolled == true ? 1 : 0,
      'hasEverBeenToSchool': hasEverBeenToSchool == true ? 1 : 0,
      'schoolName': schoolName,
      'schoolType': schoolType,
      'gradeLevel': gradeLevel,
      'schoolAttendanceFrequency': schoolAttendanceFrequency,
      'availableSchoolSupplies': availableSchoolSupplies.join('|'),
      
      // School Leaving Information
      'leftSchoolYear': leftSchoolYear,
      'leftSchoolDate': leftSchoolDate?.toIso8601String(),
      'educationLevel': educationLevel,
      'childLeaveSchoolReason': childLeaveSchoolReason,
      'otherLeaveReason': otherLeaveReason,
      'neverBeenToSchoolReason': neverBeenToSchoolReason,
      'otherNeverSchoolReason': otherNeverSchoolReason,
      
      // School Attendance
      'attendedSchoolLast7Days': (attendedSchoolLast7Days ?? false) ? 1 : 0,
      'selectedLeaveReason': selectedLeaveReason,
      'otherAbsenceReason': otherAbsenceReason,
    };
  }

  // Create from map (for database retrieval)
  factory ChildDetailsModel.fromMap(Map<String, dynamic> map) {
    return ChildDetailsModel(
      // Basic Information
      name: map['name'],
      surname: map['surname'],
      childNumber: map['childNumber'],
      birthYear: map['birthYear'],
      gender: map['gender'],
      isFarmerChild: map['isFarmerChild'] == 1,
      canBeSurveyedNow: map['canBeSurveyedNow'] == 1,
      interviewDate: map['interviewDate'] != null ? DateTime.parse(map['interviewDate']) : null,
      
      // Survey Availability
      surveyNotPossibleReasons: (map['surveyNotPossibleReasons'] as String?)?.split('|').where((s) => s.isNotEmpty).toList() ?? [],
      otherSurveyNotPossibleReason: map['otherSurveyNotPossibleReason'],
      respondentType: map['respondentType'],
      otherRespondentType: map['otherRespondentType'],
      respondentName: map['respondentName'],
      otherRespondentSpecify: map['otherRespondentSpecify'],
      
      // Birth and Documentation
      hasBirthCertificate: map['hasBirthCertificate'] == 1,
      noBirthCertificateReason: map['noBirthCertificateReason'],
      bornInCommunity: map['bornInCommunity'] == 1,
      birthCountry: map['birthCountry'],
      
      // Household Relationship
      relationshipToHead: map['relationshipToHead'],
      otherRelationship: map['otherRelationship'],
      notLivingWithFamilyReasons: {
        for (var reason in (map['notLivingWithFamilyReasons'] as String?)?.split('|') ?? [])
          reason: true
      },
      otherNotLivingWithFamilyReason: map['otherNotLivingWithFamilyReason'],
      
      // Family Decision Information
      whoDecidedChildJoin: map['whoDecidedChildJoin'],
      otherPersonDecided: map['otherPersonDecided'],
      childAgreedWithDecision: map['childAgreedWithDecision'] == 1,
      hasSpokenWithParents: map['hasSpokenWithParents'] == 1,
      lastContactWithParents: map['lastContactWithParents'],
      timeInHousehold: map['timeInHousehold'],
      whoAccompaniedChild: map['whoAccompaniedChild'],
      otherAccompaniedPerson: map['otherAccompaniedPerson'],
      
      // Parent Residence Information
      fatherResidence: map['fatherResidence'],
      fatherCountry: map['fatherCountry'],
      otherFatherCountry: map['otherFatherCountry'],
      motherResidence: map['motherResidence'],
      motherCountry: map['motherCountry'],
      otherMotherCountry: map['otherMotherCountry'],
      
      // Education Information
      isCurrentlyEnrolled: map['isCurrentlyEnrolled'] == 1,
      hasEverBeenToSchool: map['hasEverBeenToSchool'] == 1,
      schoolName: map['schoolName'],
      schoolType: map['schoolType'],
      gradeLevel: map['gradeLevel'],
      schoolAttendanceFrequency: map['schoolAttendanceFrequency'],
      availableSchoolSupplies: (map['availableSchoolSupplies'] as String?)?.split('|').where((s) => s.isNotEmpty).toSet() ?? {},
      
      // School Leaving Information
      leftSchoolYear: map['leftSchoolYear'],
      leftSchoolDate: map['leftSchoolDate'] != null ? DateTime.parse(map['leftSchoolDate']) : null,
      educationLevel: map['educationLevel'],
      childLeaveSchoolReason: map['childLeaveSchoolReason'],
      otherLeaveReason: map['otherLeaveReason'],
      neverBeenToSchoolReason: map['neverBeenToSchoolReason'],
      otherNeverSchoolReason: map['otherNeverSchoolReason'],
      
      // School Attendance
      attendedSchoolLast7Days: map['attendedSchoolLast7Days'] == 1,
      selectedLeaveReason: map['selectedLeaveReason'],
      otherAbsenceReason: map['otherAbsenceReason'],
    );
  }
}
