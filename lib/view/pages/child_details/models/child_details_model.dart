import 'package:image_picker/image_picker.dart';

class ChildDetailsModel {
  // ========== BASIC CHILD INFORMATION ==========
  String? name;
  String? childPhotoPath;  // Path to the child's photo
  String? surname;
  int? childNumber;
  int? birthYear;
  String? gender;
  bool? isFarmerChild;
  bool? canBeSurveyedNow;
  DateTime? selectedDate;

  // ========== SURVEY AVAILABILITY ==========
  List<String> surveyNotPossibleReasons = [];
  String? otherReason;
  String? respondentType;
  String? otherRespondentType;
  String? respondentName;
  String? otherRespondentSpecify;

  // ========== BIRTH AND DOCUMENTATION ==========
  bool? hasBirthCertificate;
  String? noBirthCertificateReason;
  bool? bornInCommunity;
  String? birthCountry;

  // ========== HOUSEHOLD RELATIONSHIP ==========
  String? relationshipToHead;
  String? otherRelationship;
  Map<String, bool> notLivingWithFamilyReasons = {
    'Child lives with other relatives': false,
    'Child is an orphan': false,
    'For education purposes': false,
    'Family is too poor to take care of the child': false,
    'Child is working to support family': false,
    'Other (specify)': false,
  };
  String? otherNotLivingWithFamilyReason;

  // ========== FAMILY DECISION INFORMATION ==========
  String? whoDecidedChildJoin;
  String? otherPersonDecided;
  bool? childAgreedWithDecision;
  bool? hasSpokenWithParents;
  String? lastContactWithParents;
  String? timeInHousehold;
  String? whoAccompaniedChild;
  String? otherAccompaniedPerson;

  // ========== PARENT RESIDENCE INFORMATION ==========
  String? fatherResidence;
  String? fatherCountry;
  String? otherFatherCountry;
  String? motherResidence;
  String? motherCountry;
  String? otherMotherCountry;

  // ========== EDUCATION INFORMATION ==========
  bool? isCurrentlyEnrolled;
  bool? hasEverBeenToSchool;
  String? schoolName;
  String? schoolType;
  String? gradeLevel;
  String? schoolAttendanceFrequency;
  Set<String> availableSchoolSupplies = {};
  int? leftSchoolYear;
  DateTime? leftSchoolDate;
  String? selectedEducationLevel;
  String? childLeaveSchoolReason;
  String? otherLeaveReason;
  String? neverBeenToSchoolReason;
  String? otherNeverSchoolReason;

  // ========== SCHOOL ATTENDANCE (7 DAYS) ==========
  bool? attendedSchoolLast7Days;
  String? selectedLeaveReason;
  String? otherAbsenceReason;
  bool? missedSchoolDays;
  String? selectedMissedReason;
  String? otherMissedReason;

  // ========== WORK INFORMATION (7 DAYS) ==========
  bool? workedInHouse;
  bool? workedOnCocoaFarm;
  String? workFrequency;
  bool? observedWorking;
  Set<String> cocoaFarmTasks = {};

  // ========== PHOTO CONSENT ==========
  bool? parentConsentPhoto;
  String? noConsentReason;

  // ========== LIGHT TASKS (7 DAYS) ==========
  bool? receivedRemuneration;
  String? longestLightDutyTime;
  String? longestNonSchoolDayTime;
  String? taskLocation;
  String? otherLocation;  // For work information
  String? otherTaskLocation;
  String? schoolDayTaskDuration;
  String? nonSchoolDayHours;  // Used for non-school day task duration
  bool? wasSupervisedByAdult;
  
  // ========== LIGHT TASKS (12 MONTHS) ==========
  Set<String> tasksLast12Months = {};
  bool? activityRemuneration;
  String? schoolDayTaskDuration12Months;
  String? nonSchoolDayTaskDuration12Months;  // Used in the model
  String? taskLocationType;
  String? totalSchoolDayHours;
  String? totalNonSchoolDayHours;
  bool? wasSupervisedDuringTask;
  
  // ========== ADDITIONAL WORK HOURS ==========
  String? totalHoursWorked;
  String? totalHoursWorkedDangerous;
  String? totalHoursWorkedNonSchoolDangerous;
  String? schoolDayHours;
  
  // ========== SCHOOL REASONS ==========
  String? otherReasonForSchool;

  // ========== DANGEROUS TASKS (7 DAYS) ==========
  Set<String> cocoaFarmTasksLast7DaysDangerous = {};
  bool? hasReceivedSalary;
  String? taskDangerousLocation;
  String? otherDangerousLocation;
  String? longestSchoolDayTimeDangerous;
  String? longestNonSchoolDayTimeDangerous;
  String? schoolDayHoursDangerous;
  String? nonSchoolDayDangerousHours;
  bool? wasSupervisedByAdultDangerous;

  // ========== DANGEROUS TASKS (12 MONTHS) ==========
  Set<String> cocoaFarmTasksLast12Months = {};
  bool? hasReceivedSalary12Months;
  String? taskDangerousLocation12Months;
  String? otherDangerousLocation12Months;
  String? longestSchoolDayTimeDangerous12Months;
  String? longestNonSchoolDayTimeDangerous12Months;
  String? schoolDayHoursDangerous12Months;
  String? nonSchoolDayDangerousHours12Months;
  bool? wasSupervisedByAdultDangerous12Months;

  // ========== WORK DETAILS ==========
  String? workForWhom;
  String? workForWhomOther;
  Set<String> whyWorkReasons = {};
  String? whyWorkOtherReason;
  
  // ========== HEALTH AND SAFETY ==========
  bool? appliedAgrochemicals;
  bool? onFarmDuringApplication;
  bool? sufferedInjury;
  String? howWounded;
  DateTime? whenWounded;
  bool? oftenFeelPains;
  Set<String> helpReceived = {};
  String? otherHelpReceived;
  
  // ========== PHOTO CONSENT ==========
  bool? photoConsentGiven;
  XFile? childPhoto;


  ChildDetailsModel({
    // Basic Information
    this.name,
    this.surname,
    this.childNumber,
    this.birthYear,
    this.gender,
    this.isFarmerChild,
    this.canBeSurveyedNow,
    this.selectedDate,
    
    // Survey Availability
    List<String>? surveyNotPossibleReasons,
    this.otherReason,
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
    this.leftSchoolYear,
    this.leftSchoolDate,
    this.selectedEducationLevel,
    this.childLeaveSchoolReason,
    this.otherLeaveReason,
    this.neverBeenToSchoolReason,
    this.otherNeverSchoolReason,
    
    // School Attendance (7 Days)
    this.attendedSchoolLast7Days,
    this.selectedLeaveReason,
    this.otherAbsenceReason,
    this.missedSchoolDays,
    this.selectedMissedReason,
    this.otherMissedReason,
    
    // Work Information (7 Days)
    this.workedInHouse,
    this.workedOnCocoaFarm,
    this.workFrequency,
    this.observedWorking,
    Set<String>? cocoaFarmTasks,
    
    // Light Tasks (7 Days)
    this.receivedRemuneration,
    this.longestLightDutyTime,
    this.longestNonSchoolDayTime,
    this.taskLocation,
    this.otherTaskLocation,
    this.schoolDayTaskDuration,
    this.nonSchoolDayHours,
    this.wasSupervisedByAdult,
    
    // Light Tasks (12 Months)
    Set<String>? tasksLast12Months,
    this.activityRemuneration,
    this.schoolDayTaskDuration12Months,
    this.nonSchoolDayTaskDuration12Months,
    this.taskLocationType,
    this.totalSchoolDayHours,
    this.totalNonSchoolDayHours,
    this.wasSupervisedDuringTask,
    
    // Dangerous Tasks (7 Days)
    Set<String>? cocoaFarmTasksLast7DaysDangerous,
    this.hasReceivedSalary,
    this.taskDangerousLocation,
    this.otherDangerousLocation,
    this.longestSchoolDayTimeDangerous,
    this.longestNonSchoolDayTimeDangerous,
    this.schoolDayHoursDangerous,
    this.nonSchoolDayDangerousHours,
    this.wasSupervisedByAdultDangerous,
    
    // Dangerous Tasks (12 Months)
    Set<String>? cocoaFarmTasksLast12Months,
    this.hasReceivedSalary12Months,
    this.taskDangerousLocation12Months,
    this.otherDangerousLocation12Months,
    this.longestSchoolDayTimeDangerous12Months,
    this.longestNonSchoolDayTimeDangerous12Months,
    this.schoolDayHoursDangerous12Months,
    this.nonSchoolDayDangerousHours12Months,
    this.wasSupervisedByAdultDangerous12Months,
    
    // Work Details
    this.workForWhom,
    this.workForWhomOther,
    Set<String>? whyWorkReasons,
    this.whyWorkOtherReason,
    
    // Health and Safety
    this.appliedAgrochemicals,
    this.onFarmDuringApplication,
    this.sufferedInjury,
    this.howWounded,
    this.whenWounded,
    this.oftenFeelPains,
    Set<String>? helpReceived,
    this.otherHelpReceived,
    
    // Photo Consent
    this.photoConsentGiven,
    this.childPhoto,
  }) : surveyNotPossibleReasons = surveyNotPossibleReasons ?? [],
       notLivingWithFamilyReasons = notLivingWithFamilyReasons ?? 
           {
             'Child lives with other relatives': false,
             'Child is an orphan': false,
             'For education purposes': false,
             'Family is too poor to take care of the child': false,
             'Child is working to support family': false,
             'Other (specify)': false,
           },
       availableSchoolSupplies = availableSchoolSupplies ?? {},
       cocoaFarmTasks = cocoaFarmTasks ?? {},
       tasksLast12Months = tasksLast12Months ?? {},
       cocoaFarmTasksLast7DaysDangerous = cocoaFarmTasksLast7DaysDangerous ?? {},
       cocoaFarmTasksLast12Months = cocoaFarmTasksLast12Months ?? {},
       whyWorkReasons = whyWorkReasons ?? {},
       helpReceived = helpReceived ?? {};

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      // Basic Information
      'name': name,
      'surname': surname,
      'childNumber': childNumber,
      'birthYear': birthYear,
      'gender': gender,
      'isFarmerChild': isFarmerChild,
      'canBeSurveyedNow': canBeSurveyedNow,
      'selectedDate': selectedDate?.toIso8601String(),
      
      // Survey Availability
      'surveyNotPossibleReasons': surveyNotPossibleReasons,
      'otherReason': otherReason,
      'respondentType': respondentType,
      'otherRespondentType': otherRespondentType,
      'respondentName': respondentName,
      'otherRespondentSpecify': otherRespondentSpecify,
      
      // Birth and Documentation
      'hasBirthCertificate': hasBirthCertificate,
      'noBirthCertificateReason': noBirthCertificateReason,
      'bornInCommunity': bornInCommunity,
      'birthCountry': birthCountry,
      
      // Household Relationship
      'relationshipToHead': relationshipToHead,
      'otherRelationship': otherRelationship,
      'notLivingWithFamilyReasons': notLivingWithFamilyReasons,
      'otherNotLivingWithFamilyReason': otherNotLivingWithFamilyReason,
      
      // Family Decision Information
      'whoDecidedChildJoin': whoDecidedChildJoin,
      'otherPersonDecided': otherPersonDecided,
      'childAgreedWithDecision': childAgreedWithDecision,
      'hasSpokenWithParents': hasSpokenWithParents,
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
      'isCurrentlyEnrolled': isCurrentlyEnrolled,
      'hasEverBeenToSchool': hasEverBeenToSchool,
      'schoolName': schoolName,
      'schoolType': schoolType,
      'gradeLevel': gradeLevel,
      'schoolAttendanceFrequency': schoolAttendanceFrequency,
      'availableSchoolSupplies': availableSchoolSupplies.toList(),
      'leftSchoolYear': leftSchoolYear,
      'leftSchoolDate': leftSchoolDate?.toIso8601String(),
      'selectedEducationLevel': selectedEducationLevel,
      'childLeaveSchoolReason': childLeaveSchoolReason,
      'otherLeaveReason': otherLeaveReason,
      'neverBeenToSchoolReason': neverBeenToSchoolReason,
      'otherNeverSchoolReason': otherNeverSchoolReason,
      
      // School Attendance (7 Days)
      'attendedSchoolLast7Days': attendedSchoolLast7Days,
      'selectedLeaveReason': selectedLeaveReason,
      'otherAbsenceReason': otherAbsenceReason,
      'missedSchoolDays': missedSchoolDays,
      'selectedMissedReason': selectedMissedReason,
      'otherMissedReason': otherMissedReason,
      
      // Work Information (7 Days)
      'workedInHouse': workedInHouse,
      'workedOnCocoaFarm': workedOnCocoaFarm,
      'workFrequency': workFrequency,
      'observedWorking': observedWorking,
      'cocoaFarmTasks': cocoaFarmTasks.toList(),
      
      // Light Tasks (7 Days)
      'receivedRemuneration': receivedRemuneration,
      'longestLightDutyTime': longestLightDutyTime,
      'longestNonSchoolDayTime': longestNonSchoolDayTime,
      'taskLocation': taskLocation,
      'otherTaskLocation': otherTaskLocation,
      'schoolDayTaskDuration': schoolDayTaskDuration,
      'nonSchoolDayHours': nonSchoolDayHours,
      'wasSupervisedByAdult': wasSupervisedByAdult,
      
      // Light Tasks (12 Months)
      'tasksLast12Months': tasksLast12Months.toList(),
      'activityRemuneration': activityRemuneration,
      'schoolDayTaskDuration12Months': schoolDayTaskDuration12Months,
      'nonSchoolDayHours12Months': nonSchoolDayTaskDuration12Months,
      'taskLocationType': taskLocationType,
      'totalSchoolDayHours': totalSchoolDayHours,
      'totalNonSchoolDayHours': totalNonSchoolDayHours,
      'wasSupervisedDuringTask': wasSupervisedDuringTask,
      
      // Dangerous Tasks (7 Days)
      'cocoaFarmTasksLast7DaysDangerous': cocoaFarmTasksLast7DaysDangerous.toList(),
      'hasReceivedSalary': hasReceivedSalary,
      'taskDangerousLocation': taskDangerousLocation,
      'otherDangerousLocation': otherDangerousLocation,
      'longestSchoolDayTimeDangerous': longestSchoolDayTimeDangerous,
      'longestNonSchoolDayTimeDangerous': longestNonSchoolDayTimeDangerous,
      'schoolDayHoursDangerous': schoolDayHoursDangerous,
      'nonSchoolDayDangerousHours': nonSchoolDayDangerousHours,
      'wasSupervisedByAdultDangerous': wasSupervisedByAdultDangerous,
      
      // Dangerous Tasks (12 Months)
      'cocoaFarmTasksLast12Months': cocoaFarmTasksLast12Months.toList(),
      'hasReceivedSalary12Months': hasReceivedSalary12Months,
      'taskDangerousLocation12Months': taskDangerousLocation12Months,
      'otherDangerousLocation12Months': otherDangerousLocation12Months,
      'longestSchoolDayTimeDangerous12Months': longestSchoolDayTimeDangerous12Months,
      'longestNonSchoolDayTimeDangerous12Months': longestNonSchoolDayTimeDangerous12Months,
      'schoolDayHoursDangerous12Months': schoolDayHoursDangerous12Months,
      'nonSchoolDayDangerousHours12Months': nonSchoolDayDangerousHours12Months,
      'wasSupervisedByAdultDangerous12Months': wasSupervisedByAdultDangerous12Months,
      
      // Work Details
      'workForWhom': workForWhom,
      'workForWhomOther': workForWhomOther,
      'whyWorkReasons': whyWorkReasons.toList(),
      'whyWorkOtherReason': whyWorkOtherReason,
      
      // Health and Safety
      'appliedAgrochemicals': appliedAgrochemicals,
      'onFarmDuringApplication': onFarmDuringApplication,
      'sufferedInjury': sufferedInjury,
      'howWounded': howWounded,
      'whenWounded': whenWounded?.toIso8601String(),
      'oftenFeelPains': oftenFeelPains,
      'helpReceived': helpReceived.toList(),
      'otherHelpReceived': otherHelpReceived,
      
      // Photo Consent
      'photoConsentGiven': photoConsentGiven,
      'childPhotoPath': childPhoto?.path,
    };
  }

  // Create from JSON
  factory ChildDetailsModel.fromJson(Map<String, dynamic> json) {
    return ChildDetailsModel(
      // Basic Information
      name: json['name'],
      surname: json['surname'],
      childNumber: json['childNumber'],
      birthYear: json['birthYear'],
      gender: json['gender'],
      isFarmerChild: json['isFarmerChild'],
      canBeSurveyedNow: json['canBeSurveyedNow'],
      selectedDate: json['selectedDate'] != null ? DateTime.parse(json['selectedDate']) : null,
      
      // Survey Availability
      surveyNotPossibleReasons: List<String>.from(json['surveyNotPossibleReasons'] ?? []),
      otherReason: json['otherReason'],
      respondentType: json['respondentType'],
      otherRespondentType: json['otherRespondentType'],
      respondentName: json['respondentName'],
      otherRespondentSpecify: json['otherRespondentSpecify'],
      
      // Birth and Documentation
      hasBirthCertificate: json['hasBirthCertificate'],
      noBirthCertificateReason: json['noBirthCertificateReason'],
      bornInCommunity: json['bornInCommunity'],
      birthCountry: json['birthCountry'],
      
      // Household Relationship
      relationshipToHead: json['relationshipToHead'],
      otherRelationship: json['otherRelationship'],
      notLivingWithFamilyReasons: json['notLivingWithFamilyReasons'] != null 
          ? Map<String, bool>.from(json['notLivingWithFamilyReasons'])
          : null,
      otherNotLivingWithFamilyReason: json['otherNotLivingWithFamilyReason'],
      
      // Family Decision Information
      whoDecidedChildJoin: json['whoDecidedChildJoin'],
      otherPersonDecided: json['otherPersonDecided'],
      childAgreedWithDecision: json['childAgreedWithDecision'],
      hasSpokenWithParents: json['hasSpokenWithParents'],
      lastContactWithParents: json['lastContactWithParents'],
      timeInHousehold: json['timeInHousehold'],
      whoAccompaniedChild: json['whoAccompaniedChild'],
      otherAccompaniedPerson: json['otherAccompaniedPerson'],
      
      // Parent Residence Information
      fatherResidence: json['fatherResidence'],
      fatherCountry: json['fatherCountry'],
      otherFatherCountry: json['otherFatherCountry'],
      motherResidence: json['motherResidence'],
      motherCountry: json['motherCountry'],
      otherMotherCountry: json['otherMotherCountry'],
      
      // Education Information
      isCurrentlyEnrolled: json['isCurrentlyEnrolled'],
      hasEverBeenToSchool: json['hasEverBeenToSchool'],
      schoolName: json['schoolName'],
      schoolType: json['schoolType'],
      gradeLevel: json['gradeLevel'],
      schoolAttendanceFrequency: json['schoolAttendanceFrequency'],
      availableSchoolSupplies: json['availableSchoolSupplies'] != null
          ? Set<String>.from(json['availableSchoolSupplies'])
          : null,
      leftSchoolYear: json['leftSchoolYear'] is int ? json['leftSchoolYear'] : (json['leftSchoolYear'] != null ? int.tryParse(json['leftSchoolYear'].toString()) : null),
      leftSchoolDate: json['leftSchoolDate'] != null 
          ? DateTime.parse(json['leftSchoolDate'])
          : null,
      selectedEducationLevel: json['selectedEducationLevel'],
      childLeaveSchoolReason: json['childLeaveSchoolReason'],
      otherLeaveReason: json['otherLeaveReason'],
      neverBeenToSchoolReason: json['neverBeenToSchoolReason'],
      otherNeverSchoolReason: json['otherNeverSchoolReason'],
      
      // School Attendance (7 Days)
      attendedSchoolLast7Days: json['attendedSchoolLast7Days'],
      selectedLeaveReason: json['selectedLeaveReason'],
      otherAbsenceReason: json['otherAbsenceReason'],
      missedSchoolDays: json['missedSchoolDays'],
      selectedMissedReason: json['selectedMissedReason'],
      otherMissedReason: json['otherMissedReason'],
      
      // Work Information (7 Days)
      workedInHouse: json['workedInHouse'],
      workedOnCocoaFarm: json['workedOnCocoaFarm'],
      workFrequency: json['workFrequency'],
      observedWorking: json['observedWorking'],
      cocoaFarmTasks: json['cocoaFarmTasks'] != null
          ? Set<String>.from(json['cocoaFarmTasks'])
          : null,
      
      // Light Tasks (7 Days)
      receivedRemuneration: json['receivedRemuneration'],
      longestLightDutyTime: json['longestLightDutyTime'],
      longestNonSchoolDayTime: json['longestNonSchoolDayTime'],
      taskLocation: json['taskLocation'],
      otherTaskLocation: json['otherTaskLocation'],
      schoolDayTaskDuration: json['schoolDayTaskDuration'],
      nonSchoolDayHours: json['nonSchoolDayTaskDuration'],
      wasSupervisedByAdult: json['wasSupervisedByAdult'],
      
      // Light Tasks (12 Months)
      tasksLast12Months: json['tasksLast12Months'] != null
          ? Set<String>.from(json['tasksLast12Months'])
          : null,
      activityRemuneration: json['activityRemuneration'],
      schoolDayTaskDuration12Months: json['schoolDayTaskDuration12Months'],
      nonSchoolDayTaskDuration12Months: json['nonSchoolDayTaskDuration12Months'],
      taskLocationType: json['taskLocationType'],
      totalSchoolDayHours: json['totalSchoolDayHours'],
      totalNonSchoolDayHours: json['totalNonSchoolDayHours'],
      wasSupervisedDuringTask: json['wasSupervisedDuringTask'],
      
      // Dangerous Tasks (7 Days)
      cocoaFarmTasksLast7DaysDangerous: json['cocoaFarmTasksLast7DaysDangerous'] != null
          ? Set<String>.from(json['cocoaFarmTasksLast7DaysDangerous'])
          : null,
      hasReceivedSalary: json['hasReceivedSalary'],
      taskDangerousLocation: json['taskDangerousLocation'],
      otherDangerousLocation: json['otherDangerousLocation'],
      longestSchoolDayTimeDangerous: json['longestSchoolDayTimeDangerous'],
      longestNonSchoolDayTimeDangerous: json['longestNonSchoolDayTimeDangerous'],
      schoolDayHoursDangerous: json['schoolDayHoursDangerous'],
      nonSchoolDayDangerousHours: json['nonSchoolDayDangerousHours'],
      wasSupervisedByAdultDangerous: json['wasSupervisedByAdultDangerous'],
      
      // Dangerous Tasks (12 Months)
      cocoaFarmTasksLast12Months: json['cocoaFarmTasksLast12Months'] != null
          ? Set<String>.from(json['cocoaFarmTasksLast12Months'])
          : null,
      hasReceivedSalary12Months: json['hasReceivedSalary12Months'],
      taskDangerousLocation12Months: json['taskDangerousLocation12Months'],
      otherDangerousLocation12Months: json['otherDangerousLocation12Months'],
      longestSchoolDayTimeDangerous12Months: json['longestSchoolDayTimeDangerous12Months'],
      longestNonSchoolDayTimeDangerous12Months: json['longestNonSchoolDayTimeDangerous12Months'],
      schoolDayHoursDangerous12Months: json['schoolDayHoursDangerous12Months'],
      nonSchoolDayDangerousHours12Months: json['nonSchoolDayDangerousHours12Months'],
      wasSupervisedByAdultDangerous12Months: json['wasSupervisedByAdultDangerous12Months'],
      
      // Work Details
      workForWhom: json['workForWhom'],
      workForWhomOther: json['workForWhomOther'],
      whyWorkReasons: json['whyWorkReasons'] != null
          ? Set<String>.from(json['whyWorkReasons'])
          : null,
      whyWorkOtherReason: json['whyWorkOtherReason'],
      
      // Health and Safety
      appliedAgrochemicals: json['appliedAgrochemicals'],
      onFarmDuringApplication: json['onFarmDuringApplication'],
      sufferedInjury: json['sufferedInjury'],
      howWounded: json['howWounded'],
      whenWounded: json['whenWounded'] != null
          ? DateTime.parse(json['whenWounded'])
          : null,
      oftenFeelPains: json['oftenFeelPains'],
      helpReceived: json['helpReceived'] != null
          ? Set<String>.from(json['helpReceived'])
          : null,
      otherHelpReceived: json['otherHelpReceived'],
      
      // Photo Consent
      photoConsentGiven: json['photoConsentGiven'],
      // Note: XFile needs to be handled separately as it can't be serialized directly
    )..childPhoto = json['childPhotoPath'] != null
        ? XFile(json['childPhotoPath'])
        : null;
  }
}
