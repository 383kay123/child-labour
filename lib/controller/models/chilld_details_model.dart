class ChildDetailsModel {
  // Identification
  int? id;
  int householdId;
  int? coverPageId;
  int childNumber;
  
  // Basic Information
  bool? isFarmerChild;
  String? childListNumber;
  DateTime? birthDate;
  int? birthYear;
  bool? canBeSurveyedNow;
  List<String>? surveyNotPossibleReasons;
  String? otherSurveyReason;
  String? respondentType;
  String? otherRespondentType;
  String? childName;
  String? childSurname;
  String? childGender;
  int? childAge;
  bool? hasBirthCertificate;
  String? noBirthCertificateReason;
  String? bornInCommunity;
  String? birthCountry;
  String? relationshipToHead;
  String? otherRelationship;
  List<String>? notWithFamilyReasons;
  String? otherNotWithFamilyReason;
  bool? childAgreedWithDecision;
  bool? hasSpokenWithParents;
  String? timeInHousehold;
  String? whoAccompaniedChild;
  String? otherAccompanied;
  String? fatherResidence;
  String? fatherCountry;
  String? otherFatherCountry;
  String? motherResidence;
  String? motherCountry;
  String? otherMotherCountry;
  
  // Education Information
  bool? isCurrentlyEnrolled;
  String? schoolName;
  String? schoolType;
  String? gradeLevel;
  String? schoolAttendanceFrequency;
  List<String>? availableSchoolSupplies;
  bool? hasEverBeenToSchool;
  String? leftSchoolYear;
  bool? attendedSchoolLast7Days;
  String? reasonNotAttendedSchool;
  String? otherReasonNotAttended;
  bool? missedSchoolDays;
  Map<String, bool>? absenceReasons;
  String? otherAbsenceReason;
  bool? workedInHouse;
  bool? workedOnCocoaFarm;
  List<String>? cocoaFarmTasks;
  String? workFrequency;
  bool? observedWorking;
  bool? receivedRemuneration;
  bool? wasSupervisedByAdultLighttasks7days;
  String? longestLightDutyTimeLighttasks7days;
  String? longestNonSchoolDayTimeLighttasks7days;
  List<String>? tasksLast12Months;
  String? taskLocationLighttasks7days;
  String? otherLocationLighttasks7days;
  String? schoolDayTaskHoursLighttasks7days;
  String? nonSchoolDayTaskHoursLighttasks7days;
  String? educationLevel;
  String? canWriteSentences;
  String? reasonForLeavingSchool;
  String? otherReasonForLeavingSchool;
  String? reasonNeverAttendedSchool;
  String? otherReasonNeverAttended;
  
  // Work Information
  String? workForWhom;
  String? otherWorkForWhom;
  List<String>? whyWorkReasons;
  String? otherWhyWorkReason;
  
  // Light Tasks 12 Months
  bool? receivedRemunerationLighttasks12months;
  String? longestSchoolDayTimeLighttasks12months;
  String? longestNonSchoolDayTimeLighttasks12months;
  String? taskLocationLighttasks12months;
  String? otherTaskLocationLighttasks12months;
  String? totalSchoolDayHoursLighttasks12months;
  String? totalNonSchoolDayHoursLighttasks12months;
  bool? wasSupervisedDuringTaskLighttasks12months;
  
  // Dangerous Tasks 7 Days
  bool? hasReceivedSalaryDangeroustask7days;
  String? taskLocationDangeroustask7days;
  String? otherLocationDangeroustask7days;
  String? longestSchoolDayTimeDangeroustask7days;
  String? longestNonSchoolDayTimeDangeroustask7days;
  String? schoolDayHoursDangeroustask7days;
  String? nonSchoolDayHoursDangeroustask7days;
  bool? wasSupervisedByAdultDangeroustask7days;
  
  // Dangerous Tasks 12 Months
  bool? hasReceivedSalaryDangeroustask12months;
  String? taskLocationDangeroustask12months;
  String? otherLocationDangeroustask12months;
  String? longestSchoolDayTimeDangeroustask12months;
  String? longestNonSchoolDayTimeDangeroustask12months;
  String? schoolDayHoursDangeroustask12months;
  String? nonSchoolDayHoursDangeroustask12months;
  bool? wasSupervisedByAdultDangeroustask12months;
  List<String>? dangerousTasks12Months;
  
  // Health and Safety
  bool? appliedAgrochemicals;
  bool? onFarmDuringApplication;
  bool? sufferedInjury;
  String? howWounded;
  String? whenWounded;
  bool? oftenFeelPains;
  List<String>? helpReceived;
  String? otherHelp;
  
  // Photo Consent
  bool? parentConsentPhoto;
  String? noConsentReason;
  String? childPhotoPath;
  
  // Metadata
  bool isSynced;
  int syncStatus;
  String? syncedAt;
  DateTime createdAt;
  DateTime updatedAt;
  bool isSurveyed;

  ChildDetailsModel({
    this.id,
    required this.householdId,
    this.coverPageId,
    required this.childNumber,
    
    // Basic Information
    this.isFarmerChild,
    this.childListNumber,
    this.birthDate,
    this.birthYear,
    this.canBeSurveyedNow,
    this.surveyNotPossibleReasons,
    this.otherSurveyReason,
    this.respondentType,
    this.otherRespondentType,
    this.childName,
    this.childSurname,
    this.childGender,
    this.childAge,
    this.hasBirthCertificate,
    this.noBirthCertificateReason,
    this.bornInCommunity,
    this.birthCountry,
    this.relationshipToHead,
    this.otherRelationship,
    this.notWithFamilyReasons,
    this.otherNotWithFamilyReason,
    this.childAgreedWithDecision,
    this.hasSpokenWithParents,
    this.timeInHousehold,
    this.whoAccompaniedChild,
    this.otherAccompanied,
    this.fatherResidence,
    this.fatherCountry,
    this.otherFatherCountry,
    this.motherResidence,
    this.motherCountry,
    this.otherMotherCountry,
    
    // Education Information
    this.isCurrentlyEnrolled,
    this.schoolName,
    this.schoolType,
    this.gradeLevel,
    this.schoolAttendanceFrequency,
    this.availableSchoolSupplies,
    this.hasEverBeenToSchool,
    this.leftSchoolYear,
    this.attendedSchoolLast7Days,
    this.reasonNotAttendedSchool,
    this.otherReasonNotAttended,
    this.missedSchoolDays,
    this.absenceReasons,
    this.otherAbsenceReason,
    this.workedInHouse,
    this.workedOnCocoaFarm,
    this.cocoaFarmTasks,
    this.workFrequency,
    this.observedWorking,
    this.receivedRemuneration,
    this.wasSupervisedByAdultLighttasks7days,
    this.longestLightDutyTimeLighttasks7days,
    this.longestNonSchoolDayTimeLighttasks7days,
    this.tasksLast12Months,
    this.taskLocationLighttasks7days,
    this.otherLocationLighttasks7days,
    this.schoolDayTaskHoursLighttasks7days,
    this.nonSchoolDayTaskHoursLighttasks7days,
    this.educationLevel,
    this.canWriteSentences,
    this.reasonForLeavingSchool,
    this.otherReasonForLeavingSchool,
    this.reasonNeverAttendedSchool,
    this.otherReasonNeverAttended,
    
    // Work Information
    this.workForWhom,
    this.otherWorkForWhom,
    this.whyWorkReasons,
    this.otherWhyWorkReason,
    
    // Light Tasks 12 Months
    this.receivedRemunerationLighttasks12months,
    this.longestSchoolDayTimeLighttasks12months,
    this.longestNonSchoolDayTimeLighttasks12months,
    this.taskLocationLighttasks12months,
    this.otherTaskLocationLighttasks12months,
    this.totalSchoolDayHoursLighttasks12months,
    this.totalNonSchoolDayHoursLighttasks12months,
    this.wasSupervisedDuringTaskLighttasks12months,
    
    // Dangerous Tasks 7 Days
    this.hasReceivedSalaryDangeroustask7days,
    this.taskLocationDangeroustask7days,
    this.otherLocationDangeroustask7days,
    this.longestSchoolDayTimeDangeroustask7days,
    this.longestNonSchoolDayTimeDangeroustask7days,
    this.schoolDayHoursDangeroustask7days,
    this.nonSchoolDayHoursDangeroustask7days,
    this.wasSupervisedByAdultDangeroustask7days,
    
    // Dangerous Tasks 12 Months
    this.hasReceivedSalaryDangeroustask12months,
    this.taskLocationDangeroustask12months,
    this.otherLocationDangeroustask12months,
    this.longestSchoolDayTimeDangeroustask12months,
    this.longestNonSchoolDayTimeDangeroustask12months,
    this.schoolDayHoursDangeroustask12months,
    this.nonSchoolDayHoursDangeroustask12months,
    this.wasSupervisedByAdultDangeroustask12months,
    this.dangerousTasks12Months,
    
    // Health and Safety
    this.appliedAgrochemicals,
    this.onFarmDuringApplication,
    this.sufferedInjury,
    this.howWounded,
    this.whenWounded,
    this.oftenFeelPains,
    this.helpReceived,
    this.otherHelp,
    
    // Photo Consent
    this.parentConsentPhoto,
    this.noConsentReason,
    this.childPhotoPath,
    
    // Metadata
    this.isSynced = false,
    this.syncStatus = 0,
    this.syncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSurveyed = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    // Helper function to convert bool? to int?
    int? boolToInt(bool? value) => value == null ? null : (value ? 1 : 0);

    final map = <String, dynamic>{
      'household_id': householdId,
      'cover_page_id': coverPageId,
      'child_number': childNumber,
      
      // Basic Information
      'is_farmer_child': boolToInt(isFarmerChild),
      'child_list_number': childListNumber,
      'birth_date': birthDate?.toIso8601String(),
      'birth_year': birthYear,
      'can_be_surveyed_now': boolToInt(canBeSurveyedNow),
      'survey_not_possible_reasons': surveyNotPossibleReasons?.join('|'),
      'other_survey_reason': otherSurveyReason,
      'respondent_type': respondentType,
      'other_respondent_type': otherRespondentType,
      'child_name': childName,
      'child_surname': childSurname,
      'child_gender': childGender,
      'child_age': childAge,
      'has_birth_certificate': boolToInt(hasBirthCertificate),
      'no_birth_certificate_reason': noBirthCertificateReason,
      'born_in_community': bornInCommunity,
      'birth_country': birthCountry,
      'relationship_to_head': relationshipToHead,
      'other_relationship': otherRelationship,
      'not_with_family_reasons': notWithFamilyReasons?.join('|'),
      'other_not_with_family_reason': otherNotWithFamilyReason,
      'child_agreed_with_decision': boolToInt(childAgreedWithDecision),
      'has_spoken_with_parents': boolToInt(hasSpokenWithParents),
      'time_in_household': timeInHousehold,
      'who_accompanied_child': whoAccompaniedChild,
      'other_accompanied': otherAccompanied,
      'father_residence': fatherResidence,
      'father_country': fatherCountry,
      'other_father_country': otherFatherCountry,
      'mother_residence': motherResidence,
      'mother_country': motherCountry,
      'other_mother_country': otherMotherCountry,
      
      // Education Information
      'is_currently_enrolled': boolToInt(isCurrentlyEnrolled),
      'school_name': schoolName,
      'school_type': schoolType,
      'grade_level': gradeLevel,
      'school_attendance_frequency': schoolAttendanceFrequency,
      'available_school_supplies': availableSchoolSupplies?.join('|'),
      'has_ever_been_to_school': boolToInt(hasEverBeenToSchool),
      'left_school_year': leftSchoolYear,
      'attended_school_last_7_days': boolToInt(attendedSchoolLast7Days),
      'reason_not_attended_school': reasonNotAttendedSchool,
      'other_reason_not_attended': otherReasonNotAttended,
      'missed_school_days': boolToInt(missedSchoolDays),
      'absence_reasons': absenceReasons != null ? 
          absenceReasons!.entries
              .where((e) => e.value == true)
              .map((e) => e.key)
              .join('|') : null,
      'other_absence_reason': otherAbsenceReason,
      'worked_in_house': boolToInt(workedInHouse),
      'worked_on_cocoa_farm': boolToInt(workedOnCocoaFarm),
      'cocoa_farm_tasks': cocoaFarmTasks?.join('|'),
      'work_frequency': workFrequency,
      'observed_working': boolToInt(observedWorking),
      'received_remuneration': boolToInt(receivedRemuneration),
      'was_supervised_by_adult_lighttasks7days': boolToInt(wasSupervisedByAdultLighttasks7days),
      'longest_light_duty_time_lighttasks7days': longestLightDutyTimeLighttasks7days,
      'longest_non_school_day_time_lighttasks7days': longestNonSchoolDayTimeLighttasks7days,
      'tasks_last_12_months': tasksLast12Months?.join('|'),
      'task_location_lighttasks7days': taskLocationLighttasks7days,
      'other_location_lighttasks7days': otherLocationLighttasks7days,
      'school_day_task_hours_lighttasks7days': schoolDayTaskHoursLighttasks7days,
      'non_school_day_task_hours_lighttasks7days': nonSchoolDayTaskHoursLighttasks7days,
      'education_level': educationLevel,
      'can_write_sentences': canWriteSentences,
      'reason_for_leaving_school': reasonForLeavingSchool,
      'other_reason_for_leaving_school': otherReasonForLeavingSchool,
      'reason_never_attended_school': reasonNeverAttendedSchool,
      'other_reason_never_attended': otherReasonNeverAttended,
      
      // Work Information
      'work_for_whom': workForWhom,
      'other_work_for_whom': otherWorkForWhom,
      'why_work_reasons': whyWorkReasons?.join('|'),
      'other_why_work_reason': otherWhyWorkReason,
      
      // Light Tasks 12 Months
      'received_remuneration_lighttasks12months': boolToInt(receivedRemunerationLighttasks12months),
      'longest_school_day_time_lighttasks12months': longestSchoolDayTimeLighttasks12months,
      'longest_non_school_day_time_lighttasks12months': longestNonSchoolDayTimeLighttasks12months,
      'task_location_lighttasks12months': taskLocationLighttasks12months,
      'other_task_location_lighttasks12months': otherTaskLocationLighttasks12months,
      'total_school_day_hours_lighttasks12months': totalSchoolDayHoursLighttasks12months,
      'total_non_school_day_hours_lighttasks12months': totalNonSchoolDayHoursLighttasks12months,
      'was_supervised_during_task_lighttasks12months': boolToInt(wasSupervisedDuringTaskLighttasks12months),
      
      // Dangerous Tasks 7 Days
      'has_received_salary_dangeroustask7days': boolToInt(hasReceivedSalaryDangeroustask7days),
      'task_location_dangeroustask7days': taskLocationDangeroustask7days,
      'other_location_dangeroustask7days': otherLocationDangeroustask7days,
      'longest_school_day_time_dangeroustask7days': longestSchoolDayTimeDangeroustask7days,
      'longest_non_school_day_time_dangeroustask7days': longestNonSchoolDayTimeDangeroustask7days,
      'school_day_hours_dangeroustask7days': schoolDayHoursDangeroustask7days,
      'non_school_day_hours_dangeroustask7days': nonSchoolDayHoursDangeroustask7days,
      'was_supervised_by_adult_dangeroustask7days': boolToInt(wasSupervisedByAdultDangeroustask7days),
      
      // Dangerous Tasks 12 Months
      'has_received_salary_dangeroustask12months': boolToInt(hasReceivedSalaryDangeroustask12months),
      'task_location_dangeroustask12months': taskLocationDangeroustask12months,
      'other_location_dangeroustask12months': otherLocationDangeroustask12months,
      'longest_school_day_time_dangeroustask12months': longestSchoolDayTimeDangeroustask12months,
      'longest_non_school_day_time_dangeroustask12months': longestNonSchoolDayTimeDangeroustask12months,
      'school_day_hours_dangeroustask12months': schoolDayHoursDangeroustask12months,
      'non_school_day_hours_dangeroustask12months': nonSchoolDayHoursDangeroustask12months,
      'was_supervised_by_adult_dangeroustask12months': boolToInt(wasSupervisedByAdultDangeroustask12months),
      'dangerous_tasks_12_months': dangerousTasks12Months?.join('|'),
      
      // Health and Safety
      'applied_agrochemicals': boolToInt(appliedAgrochemicals),
      'on_farm_during_application': boolToInt(onFarmDuringApplication),
      'suffered_injury': boolToInt(sufferedInjury),
      'how_wounded': howWounded,
      'when_wounded': whenWounded,
      'often_feel_pains': boolToInt(oftenFeelPains),
      'help_received': helpReceived?.join('|'),
      'other_help': otherHelp,
      
      // Photo Consent
      'parent_consent_photo': boolToInt(parentConsentPhoto),
      'no_consent_reason': noConsentReason,
      'child_photo_path': childPhotoPath,
      
      // Metadata
      'is_synced': boolToInt(isSynced),
      'sync_status': syncStatus,
      'synced_at': syncedAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_surveyed': boolToInt(isSurveyed),
    };
    
    // Add ID if it's not null (for updates)
    if (id != null) {
      map['id'] = id;
    }
    
    return map;
  }

  // Create from Map (from database)
  factory ChildDetailsModel.fromMap(Map<String, dynamic> map) {
    // Helper functions
    List<String>? parseStringList(String? value) {
      if (value == null || value.isEmpty) return null;
      return value.split('|');
    }

    Map<String, bool>? parseAbsenceReasons(String? value) {
      if (value == null || value.isEmpty) return null;
      final reasons = value.split('|');
      final result = <String, bool>{};
      for (final reason in reasons) {
        result[reason] = true;
      }
      return result;
    }

    // Helper for parsing boolean from int
    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return null;
    }

    // Helper for parsing int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return ChildDetailsModel(
      id: parseInt(map['id']),
      householdId: map['household_id'] as int,
      coverPageId: parseInt(map['cover_page_id']),
      childNumber: map['child_number'] as int,
      
      // Basic Information
      isFarmerChild: parseBool(map['is_farmer_child']),
      childListNumber: map['child_list_number']?.toString(),
      birthDate: map['birth_date'] != null ? DateTime.tryParse(map['birth_date']) : null,
      birthYear: parseInt(map['birth_year']),
      canBeSurveyedNow: parseBool(map['can_be_surveyed_now']),
      surveyNotPossibleReasons: parseStringList(map['survey_not_possible_reasons']),
      otherSurveyReason: map['other_survey_reason']?.toString(),
      respondentType: map['respondent_type']?.toString(),
      otherRespondentType: map['other_respondent_type']?.toString(),
      childName: map['child_name']?.toString(),
      childSurname: map['child_surname']?.toString(),
      childGender: map['child_gender']?.toString(),
      childAge: parseInt(map['child_age']),
      hasBirthCertificate: parseBool(map['has_birth_certificate']),
      noBirthCertificateReason: map['no_birth_certificate_reason']?.toString(),
      bornInCommunity: map['born_in_community']?.toString(),
      birthCountry: map['birth_country']?.toString(),
      relationshipToHead: map['relationship_to_head']?.toString(),
      otherRelationship: map['other_relationship']?.toString(),
      notWithFamilyReasons: parseStringList(map['not_with_family_reasons']),
      otherNotWithFamilyReason: map['other_not_with_family_reason']?.toString(),
      childAgreedWithDecision: parseBool(map['child_agreed_with_decision']),
      hasSpokenWithParents: parseBool(map['has_spoken_with_parents']),
      timeInHousehold: map['time_in_household']?.toString(),
      whoAccompaniedChild: map['who_accompanied_child']?.toString(),
      otherAccompanied: map['other_accompanied']?.toString(),
      fatherResidence: map['father_residence']?.toString(),
      fatherCountry: map['father_country']?.toString(),
      otherFatherCountry: map['other_father_country']?.toString(),
      motherResidence: map['mother_residence']?.toString(),
      motherCountry: map['mother_country']?.toString(),
      otherMotherCountry: map['other_mother_country']?.toString(),
      
      // Education Information
      isCurrentlyEnrolled: parseBool(map['is_currently_enrolled']),
      schoolName: map['school_name']?.toString(),
      schoolType: map['school_type']?.toString(),
      gradeLevel: map['grade_level']?.toString(),
      schoolAttendanceFrequency: map['school_attendance_frequency']?.toString(),
      availableSchoolSupplies: parseStringList(map['available_school_supplies']),
      hasEverBeenToSchool: parseBool(map['has_ever_been_to_school']),
      leftSchoolYear: map['left_school_year']?.toString(),
      attendedSchoolLast7Days: parseBool(map['attended_school_last_7_days']),
      reasonNotAttendedSchool: map['reason_not_attended_school']?.toString(),
      otherReasonNotAttended: map['other_reason_not_attended']?.toString(),
      missedSchoolDays: parseBool(map['missed_school_days']),
      absenceReasons: parseAbsenceReasons(map['absence_reasons']),
      otherAbsenceReason: map['other_absence_reason']?.toString(),
      workedInHouse: parseBool(map['worked_in_house']),
      workedOnCocoaFarm: parseBool(map['worked_on_cocoa_farm']),
      cocoaFarmTasks: parseStringList(map['cocoa_farm_tasks']),
      workFrequency: map['work_frequency']?.toString(),
      observedWorking: parseBool(map['observed_working']),
      receivedRemuneration: parseBool(map['received_remuneration']),
      wasSupervisedByAdultLighttasks7days: parseBool(map['was_supervised_by_adult_lighttasks7days']),
      longestLightDutyTimeLighttasks7days: map['longest_light_duty_time_lighttasks7days']?.toString(),
      longestNonSchoolDayTimeLighttasks7days: map['longest_non_school_day_time_lighttasks7days']?.toString(),
      tasksLast12Months: parseStringList(map['tasks_last_12_months']),
      taskLocationLighttasks7days: map['task_location_lighttasks7days']?.toString(),
      otherLocationLighttasks7days: map['other_location_lighttasks7days']?.toString(),
      schoolDayTaskHoursLighttasks7days: map['school_day_task_hours_lighttasks7days']?.toString(),
      nonSchoolDayTaskHoursLighttasks7days: map['non_school_day_task_hours_lighttasks7days']?.toString(),
      educationLevel: map['education_level']?.toString(),
      canWriteSentences: map['can_write_sentences']?.toString(),
      reasonForLeavingSchool: map['reason_for_leaving_school']?.toString(),
      otherReasonForLeavingSchool: map['other_reason_for_leaving_school']?.toString(),
      reasonNeverAttendedSchool: map['reason_never_attended_school']?.toString(),
      otherReasonNeverAttended: map['other_reason_never_attended']?.toString(),
      
      // Work Information
      workForWhom: map['work_for_whom']?.toString(),
      otherWorkForWhom: map['other_work_for_whom']?.toString(),
      whyWorkReasons: parseStringList(map['why_work_reasons']),
      otherWhyWorkReason: map['other_why_work_reason']?.toString(),
      
      // Light Tasks 12 Months
      receivedRemunerationLighttasks12months: parseBool(map['received_remuneration_lighttasks12months']),
      longestSchoolDayTimeLighttasks12months: map['longest_school_day_time_lighttasks12months']?.toString(),
      longestNonSchoolDayTimeLighttasks12months: map['longest_non_school_day_time_lighttasks12months']?.toString(),
      taskLocationLighttasks12months: map['task_location_lighttasks12months']?.toString(),
      otherTaskLocationLighttasks12months: map['other_task_location_lighttasks12months']?.toString(),
      totalSchoolDayHoursLighttasks12months: map['total_school_day_hours_lighttasks12months']?.toString(),
      totalNonSchoolDayHoursLighttasks12months: map['total_non_school_day_hours_lighttasks12months']?.toString(),
      wasSupervisedDuringTaskLighttasks12months: parseBool(map['was_supervised_during_task_lighttasks12months']),
      
      // Dangerous Tasks 7 Days
      hasReceivedSalaryDangeroustask7days: parseBool(map['has_received_salary_dangeroustask7days']),
      taskLocationDangeroustask7days: map['task_location_dangeroustask7days']?.toString(),
      otherLocationDangeroustask7days: map['other_location_dangeroustask7days']?.toString(),
      longestSchoolDayTimeDangeroustask7days: map['longest_school_day_time_dangeroustask7days']?.toString(),
      longestNonSchoolDayTimeDangeroustask7days: map['longest_non_school_day_time_dangeroustask7days']?.toString(),
      schoolDayHoursDangeroustask7days: map['school_day_hours_dangeroustask7days']?.toString(),
      nonSchoolDayHoursDangeroustask7days: map['non_school_day_hours_dangeroustask7days']?.toString(),
      wasSupervisedByAdultDangeroustask7days: parseBool(map['was_supervised_by_adult_dangeroustask7days']),
      
      // Dangerous Tasks 12 Months
      hasReceivedSalaryDangeroustask12months: parseBool(map['has_received_salary_dangeroustask12months']),
      taskLocationDangeroustask12months: map['task_location_dangeroustask12months']?.toString(),
      otherLocationDangeroustask12months: map['other_location_dangeroustask12months']?.toString(),
      longestSchoolDayTimeDangeroustask12months: map['longest_school_day_time_dangeroustask12months']?.toString(),
      longestNonSchoolDayTimeDangeroustask12months: map['longest_non_school_day_time_dangeroustask12months']?.toString(),
      schoolDayHoursDangeroustask12months: map['school_day_hours_dangeroustask12months']?.toString(),
      nonSchoolDayHoursDangeroustask12months: map['non_school_day_hours_dangeroustask12months']?.toString(),
      wasSupervisedByAdultDangeroustask12months: parseBool(map['was_supervised_by_adult_dangeroustask12months']),
      dangerousTasks12Months: parseStringList(map['dangerous_tasks_12_months']),
      
      // Health and Safety
      appliedAgrochemicals: parseBool(map['applied_agrochemicals']),
      onFarmDuringApplication: parseBool(map['on_farm_during_application']),
      sufferedInjury: parseBool(map['suffered_injury']),
      howWounded: map['how_wounded']?.toString(),
      whenWounded: map['when_wounded']?.toString(),
      oftenFeelPains: parseBool(map['often_feel_pains']),
      helpReceived: parseStringList(map['help_received']),
      otherHelp: map['other_help']?.toString(),
      
      // Photo Consent
      parentConsentPhoto: parseBool(map['parent_consent_photo']),
      noConsentReason: map['no_consent_reason']?.toString(),
      childPhotoPath: map['child_photo_path']?.toString(),
      
      // Metadata
      isSynced: parseBool(map['is_synced']) ?? false,
      syncStatus: parseInt(map['sync_status']) ?? 0,
      syncedAt: map['synced_at']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
      isSurveyed: parseBool(map['is_surveyed']) ?? false,
    );
  }

  // Create a copy with updated values
  ChildDetailsModel copyWith({
    int? id,
    int? householdId,
    int? coverPageId,
    int? childNumber,
    
    // Basic Information
    bool? isFarmerChild,
    String? childListNumber,
    DateTime? birthDate,
    int? birthYear,
    bool? canBeSurveyedNow,
    List<String>? surveyNotPossibleReasons,
    String? otherSurveyReason,
    String? respondentType,
    String? otherRespondentType,
    String? childName,
    String? childSurname,
    String? childGender,
    int? childAge,
    bool? hasBirthCertificate,
    String? noBirthCertificateReason,
    String? bornInCommunity,
    String? birthCountry,
    String? relationshipToHead,
    String? otherRelationship,
    List<String>? notWithFamilyReasons,
    String? otherNotWithFamilyReason,
    bool? childAgreedWithDecision,
    bool? hasSpokenWithParents,
    String? timeInHousehold,
    String? whoAccompaniedChild,
    String? otherAccompanied,
    String? fatherResidence,
    String? fatherCountry,
    String? otherFatherCountry,
    String? motherResidence,
    String? motherCountry,
    String? otherMotherCountry,
    
    // Education Information
    bool? isCurrentlyEnrolled,
    String? schoolName,
    String? schoolType,
    String? gradeLevel,
    String? schoolAttendanceFrequency,
    List<String>? availableSchoolSupplies,
    bool? hasEverBeenToSchool,
    String? leftSchoolYear,
    bool? attendedSchoolLast7Days,
    String? reasonNotAttendedSchool,
    String? otherReasonNotAttended,
    bool? missedSchoolDays,
    Map<String, bool>? absenceReasons,
    String? otherAbsenceReason,
    bool? workedInHouse,
    bool? workedOnCocoaFarm,
    List<String>? cocoaFarmTasks,
    String? workFrequency,
    bool? observedWorking,
    bool? receivedRemuneration,
    bool? wasSupervisedByAdultLighttasks7days,
    String? longestLightDutyTimeLighttasks7days,
    String? longestNonSchoolDayTimeLighttasks7days,
    List<String>? tasksLast12Months,
    String? taskLocationLighttasks7days,
    String? otherLocationLighttasks7days,
    String? schoolDayTaskHoursLighttasks7days,
    String? nonSchoolDayTaskHoursLighttasks7days,
    String? educationLevel,
    String? canWriteSentences,
    String? reasonForLeavingSchool,
    String? otherReasonForLeavingSchool,
    String? reasonNeverAttendedSchool,
    String? otherReasonNeverAttended,
    
    // Work Information
    String? workForWhom,
    String? otherWorkForWhom,
    List<String>? whyWorkReasons,
    String? otherWhyWorkReason,
    
    // Light Tasks 12 Months
    bool? receivedRemunerationLighttasks12months,
    String? longestSchoolDayTimeLighttasks12months,
    String? longestNonSchoolDayTimeLighttasks12months,
    String? taskLocationLighttasks12months,
    String? otherTaskLocationLighttasks12months,
    String? totalSchoolDayHoursLighttasks12months,
    String? totalNonSchoolDayHoursLighttasks12months,
    bool? wasSupervisedDuringTaskLighttasks12months,
    
    // Dangerous Tasks 7 Days
    bool? hasReceivedSalaryDangeroustask7days,
    String? taskLocationDangeroustask7days,
    String? otherLocationDangeroustask7days,
    String? longestSchoolDayTimeDangeroustask7days,
    String? longestNonSchoolDayTimeDangeroustask7days,
    String? schoolDayHoursDangeroustask7days,
    String? nonSchoolDayHoursDangeroustask7days,
    bool? wasSupervisedByAdultDangeroustask7days,
    
    // Dangerous Tasks 12 Months
    bool? hasReceivedSalaryDangeroustask12months,
    String? taskLocationDangeroustask12months,
    String? otherLocationDangeroustask12months,
    String? longestSchoolDayTimeDangeroustask12months,
    String? longestNonSchoolDayTimeDangeroustask12months,
    String? schoolDayHoursDangeroustask12months,
    String? nonSchoolDayHoursDangeroustask12months,
    bool? wasSupervisedByAdultDangeroustask12months,
    List<String>? dangerousTasks12Months,
    
    // Health and Safety
    bool? appliedAgrochemicals,
    bool? onFarmDuringApplication,
    bool? sufferedInjury,
    String? howWounded,
    String? whenWounded,
    bool? oftenFeelPains,
    List<String>? helpReceived,
    String? otherHelp,
    
    // Photo Consent
    bool? parentConsentPhoto,
    String? noConsentReason,
    String? childPhotoPath,
    
    // Metadata
    bool? isSynced,
    int? syncStatus,
    String? syncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSurveyed,
  }) {
    return ChildDetailsModel(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      coverPageId: coverPageId ?? this.coverPageId,
      childNumber: childNumber ?? this.childNumber,
      
      // Basic Information
      isFarmerChild: isFarmerChild ?? this.isFarmerChild,
      childListNumber: childListNumber ?? this.childListNumber,
      birthDate: birthDate ?? this.birthDate,
      birthYear: birthYear ?? this.birthYear,
      canBeSurveyedNow: canBeSurveyedNow ?? this.canBeSurveyedNow,
      surveyNotPossibleReasons: surveyNotPossibleReasons ?? this.surveyNotPossibleReasons,
      otherSurveyReason: otherSurveyReason ?? this.otherSurveyReason,
      respondentType: respondentType ?? this.respondentType,
      otherRespondentType: otherRespondentType ?? this.otherRespondentType,
      childName: childName ?? this.childName,
      childSurname: childSurname ?? this.childSurname,
      childGender: childGender ?? this.childGender,
      childAge: childAge ?? this.childAge,
      hasBirthCertificate: hasBirthCertificate ?? this.hasBirthCertificate,
      noBirthCertificateReason: noBirthCertificateReason ?? this.noBirthCertificateReason,
      bornInCommunity: bornInCommunity ?? this.bornInCommunity,
      birthCountry: birthCountry ?? this.birthCountry,
      relationshipToHead: relationshipToHead ?? this.relationshipToHead,
      otherRelationship: otherRelationship ?? this.otherRelationship,
      notWithFamilyReasons: notWithFamilyReasons ?? this.notWithFamilyReasons,
      otherNotWithFamilyReason: otherNotWithFamilyReason ?? this.otherNotWithFamilyReason,
      childAgreedWithDecision: childAgreedWithDecision ?? this.childAgreedWithDecision,
      hasSpokenWithParents: hasSpokenWithParents ?? this.hasSpokenWithParents,
      timeInHousehold: timeInHousehold ?? this.timeInHousehold,
      whoAccompaniedChild: whoAccompaniedChild ?? this.whoAccompaniedChild,
      otherAccompanied: otherAccompanied ?? this.otherAccompanied,
      fatherResidence: fatherResidence ?? this.fatherResidence,
      fatherCountry: fatherCountry ?? this.fatherCountry,
      otherFatherCountry: otherFatherCountry ?? this.otherFatherCountry,
      motherResidence: motherResidence ?? this.motherResidence,
      motherCountry: motherCountry ?? this.motherCountry,
      otherMotherCountry: otherMotherCountry ?? this.otherMotherCountry,
      
      // Education Information
      isCurrentlyEnrolled: isCurrentlyEnrolled ?? this.isCurrentlyEnrolled,
      schoolName: schoolName ?? this.schoolName,
      schoolType: schoolType ?? this.schoolType,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      schoolAttendanceFrequency: schoolAttendanceFrequency ?? this.schoolAttendanceFrequency,
      availableSchoolSupplies: availableSchoolSupplies ?? this.availableSchoolSupplies,
      hasEverBeenToSchool: hasEverBeenToSchool ?? this.hasEverBeenToSchool,
      leftSchoolYear: leftSchoolYear ?? this.leftSchoolYear,
      attendedSchoolLast7Days: attendedSchoolLast7Days ?? this.attendedSchoolLast7Days,
      reasonNotAttendedSchool: reasonNotAttendedSchool ?? this.reasonNotAttendedSchool,
      otherReasonNotAttended: otherReasonNotAttended ?? this.otherReasonNotAttended,
      missedSchoolDays: missedSchoolDays ?? this.missedSchoolDays,
      absenceReasons: absenceReasons ?? this.absenceReasons,
      otherAbsenceReason: otherAbsenceReason ?? this.otherAbsenceReason,
      workedInHouse: workedInHouse ?? this.workedInHouse,
      workedOnCocoaFarm: workedOnCocoaFarm ?? this.workedOnCocoaFarm,
      cocoaFarmTasks: cocoaFarmTasks ?? this.cocoaFarmTasks,
      workFrequency: workFrequency ?? this.workFrequency,
      observedWorking: observedWorking ?? this.observedWorking,
      receivedRemuneration: receivedRemuneration ?? this.receivedRemuneration,
      wasSupervisedByAdultLighttasks7days: wasSupervisedByAdultLighttasks7days ?? this.wasSupervisedByAdultLighttasks7days,
      longestLightDutyTimeLighttasks7days: longestLightDutyTimeLighttasks7days ?? this.longestLightDutyTimeLighttasks7days,
      longestNonSchoolDayTimeLighttasks7days: longestNonSchoolDayTimeLighttasks7days ?? this.longestNonSchoolDayTimeLighttasks7days,
      tasksLast12Months: tasksLast12Months ?? this.tasksLast12Months,
      taskLocationLighttasks7days: taskLocationLighttasks7days ?? this.taskLocationLighttasks7days,
      otherLocationLighttasks7days: otherLocationLighttasks7days ?? this.otherLocationLighttasks7days,
      schoolDayTaskHoursLighttasks7days: schoolDayTaskHoursLighttasks7days ?? this.schoolDayTaskHoursLighttasks7days,
      nonSchoolDayTaskHoursLighttasks7days: nonSchoolDayTaskHoursLighttasks7days ?? this.nonSchoolDayTaskHoursLighttasks7days,
      educationLevel: educationLevel ?? this.educationLevel,
      canWriteSentences: canWriteSentences ?? this.canWriteSentences,
      reasonForLeavingSchool: reasonForLeavingSchool ?? this.reasonForLeavingSchool,
      otherReasonForLeavingSchool: otherReasonForLeavingSchool ?? this.otherReasonForLeavingSchool,
      reasonNeverAttendedSchool: reasonNeverAttendedSchool ?? this.reasonNeverAttendedSchool,
      otherReasonNeverAttended: otherReasonNeverAttended ?? this.otherReasonNeverAttended,
      
      // Work Information
      workForWhom: workForWhom ?? this.workForWhom,
      otherWorkForWhom: otherWorkForWhom ?? this.otherWorkForWhom,
      whyWorkReasons: whyWorkReasons ?? this.whyWorkReasons,
      otherWhyWorkReason: otherWhyWorkReason ?? this.otherWhyWorkReason,
      
      // Light Tasks 12 Months
      receivedRemunerationLighttasks12months: receivedRemunerationLighttasks12months ?? this.receivedRemunerationLighttasks12months,
      longestSchoolDayTimeLighttasks12months: longestSchoolDayTimeLighttasks12months ?? this.longestSchoolDayTimeLighttasks12months,
      longestNonSchoolDayTimeLighttasks12months: longestNonSchoolDayTimeLighttasks12months ?? this.longestNonSchoolDayTimeLighttasks12months,
      taskLocationLighttasks12months: taskLocationLighttasks12months ?? this.taskLocationLighttasks12months,
      otherTaskLocationLighttasks12months: otherTaskLocationLighttasks12months ?? this.otherTaskLocationLighttasks12months,
      totalSchoolDayHoursLighttasks12months: totalSchoolDayHoursLighttasks12months ?? this.totalSchoolDayHoursLighttasks12months,
      totalNonSchoolDayHoursLighttasks12months: totalNonSchoolDayHoursLighttasks12months ?? this.totalNonSchoolDayHoursLighttasks12months,
      wasSupervisedDuringTaskLighttasks12months: wasSupervisedDuringTaskLighttasks12months ?? this.wasSupervisedDuringTaskLighttasks12months,
      
      // Dangerous Tasks 7 Days
      hasReceivedSalaryDangeroustask7days: hasReceivedSalaryDangeroustask7days ?? this.hasReceivedSalaryDangeroustask7days,
      taskLocationDangeroustask7days: taskLocationDangeroustask7days ?? this.taskLocationDangeroustask7days,
      otherLocationDangeroustask7days: otherLocationDangeroustask7days ?? this.otherLocationDangeroustask7days,
      longestSchoolDayTimeDangeroustask7days: longestSchoolDayTimeDangeroustask7days ?? this.longestSchoolDayTimeDangeroustask7days,
      longestNonSchoolDayTimeDangeroustask7days: longestNonSchoolDayTimeDangeroustask7days ?? this.longestNonSchoolDayTimeDangeroustask7days,
      schoolDayHoursDangeroustask7days: schoolDayHoursDangeroustask7days ?? this.schoolDayHoursDangeroustask7days,
      nonSchoolDayHoursDangeroustask7days: nonSchoolDayHoursDangeroustask7days ?? this.nonSchoolDayHoursDangeroustask7days,
      wasSupervisedByAdultDangeroustask7days: wasSupervisedByAdultDangeroustask7days ?? this.wasSupervisedByAdultDangeroustask7days,
      
      // Dangerous Tasks 12 Months
      hasReceivedSalaryDangeroustask12months: hasReceivedSalaryDangeroustask12months ?? this.hasReceivedSalaryDangeroustask12months,
      taskLocationDangeroustask12months: taskLocationDangeroustask12months ?? this.taskLocationDangeroustask12months,
      otherLocationDangeroustask12months: otherLocationDangeroustask12months ?? this.otherLocationDangeroustask12months,
      longestSchoolDayTimeDangeroustask12months: longestSchoolDayTimeDangeroustask12months ?? this.longestSchoolDayTimeDangeroustask12months,
      longestNonSchoolDayTimeDangeroustask12months: longestNonSchoolDayTimeDangeroustask12months ?? this.longestNonSchoolDayTimeDangeroustask12months,
      schoolDayHoursDangeroustask12months: schoolDayHoursDangeroustask12months ?? this.schoolDayHoursDangeroustask12months,
      nonSchoolDayHoursDangeroustask12months: nonSchoolDayHoursDangeroustask12months ?? this.nonSchoolDayHoursDangeroustask12months,
      wasSupervisedByAdultDangeroustask12months: wasSupervisedByAdultDangeroustask12months ?? this.wasSupervisedByAdultDangeroustask12months,
      dangerousTasks12Months: dangerousTasks12Months ?? this.dangerousTasks12Months,
      
      // Health and Safety
      appliedAgrochemicals: appliedAgrochemicals ?? this.appliedAgrochemicals,
      onFarmDuringApplication: onFarmDuringApplication ?? this.onFarmDuringApplication,
      sufferedInjury: sufferedInjury ?? this.sufferedInjury,
      howWounded: howWounded ?? this.howWounded,
      whenWounded: whenWounded ?? this.whenWounded,
      oftenFeelPains: oftenFeelPains ?? this.oftenFeelPains,
      helpReceived: helpReceived ?? this.helpReceived,
      otherHelp: otherHelp ?? this.otherHelp,
      
      // Photo Consent
      parentConsentPhoto: parentConsentPhoto ?? this.parentConsentPhoto,
      noConsentReason: noConsentReason ?? this.noConsentReason,
      childPhotoPath: childPhotoPath ?? this.childPhotoPath,
      
      // Metadata
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSurveyed: isSurveyed ?? this.isSurveyed,
    );
  }

// Add these methods to the ChildDetailsModel class

// Convert to JSON
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'householdId': householdId,
    'coverPageId': coverPageId,
    'childNumber': childNumber,
    'isFarmerChild': isFarmerChild,
    'childListNumber': childListNumber,
    'birthDate': birthDate?.toIso8601String(),
    'birthYear': birthYear,
    // ... add all other fields
    'isSynced': isSynced,
    'syncStatus': syncStatus,
    'syncedAt': syncedAt,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isSurveyed': isSurveyed,
  };
}

// Create from JSON
factory ChildDetailsModel.fromJson(Map<String, dynamic> json) {
  return ChildDetailsModel(
    id: json['id'],
    householdId: json['householdId'],
    coverPageId: json['coverPageId'],
    childNumber: json['childNumber'],
    isFarmerChild: json['isFarmerChild'],
    childListNumber: json['childListNumber'],
    birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
    birthYear: json['birthYear'],
    // ... initialize all other fields
    isSynced: json['isSynced'],
    syncStatus: json['syncStatus'],
    syncedAt: json['syncedAt'],
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    isSurveyed: json['isSurveyed'],
  );
}
  @override
  String toString() {
    return 'ChildDetailsModel(id: $id, householdId: $householdId, childNumber: $childNumber, childName: $childName, childSurname: $childSurname, childGender: $childGender, isSurveyed: $isSurveyed)';
  }
}