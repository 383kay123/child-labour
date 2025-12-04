import 'dart:convert';

class FarmerInterview {
  int? enumerator;
  int? farmer;
  String? interviewStartTime;
  String? gpsPoint;
  String? communityType;
  String? farmerResidesInCommunity;
  String? latitude;
  String? longitude;
  String? farmerResidingCommunity;
  String? farmerAvailable;
  String? reasonUnavailable;
  String? reasonUnavailableOther;
  String? availableAnswerBy;
  String? refusalToaParticipateReasonSurvey;
  int? totalAdults;
  String? isNameCorrect;
  String? exactName;
  String? nationality;
  String? countryOrigin;
  String? countryOriginOther;
  String? isOwner;
  String? ownerStatus01;
  String? ownerStatus00;
  String? childrenPresent;
  int? numChildren5To17;
  String? feedbackEnum;
  String? pictureOfRespondent;
  String? signatureProducer;
  String? endGps;
  String? endTime;
  String? sensitizedGoodParenting;
  String? sensitizedChildProtection;
  String? sensitizedSafeLabour;
  int? numberOfFemaleAdults;
  int? numberOfMaleAdults;
  String? pictureSensitization;
  String? feedbackObservations;
  String? schoolFeesOwed;
  String? parentRemediation;
  String? parentRemediationOther;
  String? communityRemediation;
  String? communityRemediationOther;
  String? nameOwner;
  String? firstNameOwner;
  String? nationalityOwner;
  String? countryOriginOwner;
  String? countryOriginOwnerOther;
  int? managerWorkLength;
  String? recruitedWorkers;
  String? workerRecruitmentType;
  String? workerAgreementType;
  String? workerAgreementOther;
  String? tasksClarified;
  String? additionalTasks;
  String? refusalAction;
  String? refusalActionOther;
  String? salaryStatus;
  String? recruit1;
  String? recruit2;
  String? recruit3;
  String? conditions1;
  String? conditions2;
  String? conditions3;
  String? conditions4;
  String? conditions5;
  String? leaving1;
  String? leaving2;
  String? consentRecruitment;

  FarmerInterview({
    this.enumerator,
    this.farmer,
    this.interviewStartTime,
    this.gpsPoint,
    this.communityType,
    this.farmerResidesInCommunity,
    this.latitude,
    this.longitude,
    this.farmerResidingCommunity,
    this.farmerAvailable,
    this.reasonUnavailable,
    this.reasonUnavailableOther,
    this.availableAnswerBy,
    this.refusalToaParticipateReasonSurvey,
    this.totalAdults,
    this.isNameCorrect,
    this.exactName,
    this.nationality,
    this.countryOrigin,
    this.countryOriginOther,
    this.isOwner,
    this.ownerStatus01,
    this.ownerStatus00,
    this.childrenPresent,
    this.numChildren5To17,
    this.feedbackEnum,
    this.pictureOfRespondent,
    this.signatureProducer,
    this.endGps,
    this.endTime,
    this.sensitizedGoodParenting,
    this.sensitizedChildProtection,
    this.sensitizedSafeLabour,
    this.numberOfFemaleAdults,
    this.numberOfMaleAdults,
    this.pictureSensitization,
    this.feedbackObservations,
    this.schoolFeesOwed,
    this.parentRemediation,
    this.parentRemediationOther,
    this.communityRemediation,
    this.communityRemediationOther,
    this.nameOwner,
    this.firstNameOwner,
    this.nationalityOwner,
    this.countryOriginOwner,
    this.countryOriginOwnerOther,
    this.managerWorkLength,
    this.recruitedWorkers,
    this.workerRecruitmentType,
    this.workerAgreementType,
    this.workerAgreementOther,
    this.tasksClarified,
    this.additionalTasks,
    this.refusalAction,
    this.refusalActionOther,
    this.salaryStatus,
    this.recruit1,
    this.recruit2,
    this.recruit3,
    this.conditions1,
    this.conditions2,
    this.conditions3,
    this.conditions4,
    this.conditions5,
    this.leaving1,
    this.leaving2,
    this.consentRecruitment,
  });

  factory FarmerInterview.fromJson(Map<String, dynamic> json) {
    return FarmerInterview(
      enumerator: json['enumerator'] as int?,
      farmer: json['farmer'] as int?,
      interviewStartTime: json['interview_start_time'] as String?,
      gpsPoint: json['gps_point'] as String?,
      communityType: json['community_type'] as String?,
      farmerResidesInCommunity: json['farmer_resides_in_community'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      farmerResidingCommunity: json['farmer_residing_community'] as String?,
      farmerAvailable: json['farmer_available'] as String?,
      reasonUnavailable: json['reason_unavailable'] as String?,
      reasonUnavailableOther: json['reason_unavailable_other'] as String?,
      availableAnswerBy: json['available_answer_by'] as String?,
      refusalToaParticipateReasonSurvey: json['refusal_toa_participate_reason_survey'] as String?,
      totalAdults: json['total_adults'] as int?,
      isNameCorrect: json['is_name_correct'] as String?,
      exactName: json['exact_name'] as String?,
      nationality: json['nationality'] as String?,
      countryOrigin: json['country_origin'] as String?,
      countryOriginOther: json['country_origin_other'] as String?,
      isOwner: json['is_owner'] as String?,
      ownerStatus01: json['owner_status_01'] as String?,
      ownerStatus00: json['owner_status_00'] as String?,
      childrenPresent: json['children_present'] as String?,
      numChildren5To17: json['num_children_5_to_17'] as int?,
      feedbackEnum: json['feedback_enum'] as String?,
      pictureOfRespondent: json['picture_of_respondent'] as String?,
      signatureProducer: json['signature_producer'] as String?,
      endGps: json['end_gps'] as String?,
      endTime: json['end_time'] as String?,
      sensitizedGoodParenting: json['sensitized_good_parenting'] as String?,
      sensitizedChildProtection: json['sensitized_child_protection'] as String?,
      sensitizedSafeLabour: json['sensitized_safe_labour'] as String?,
      numberOfFemaleAdults: json['number_of_female_adults'] as int?,
      numberOfMaleAdults: json['number_of_male_adults'] as int?,
      pictureSensitization: json['picture_sensitization'] as String?,
      feedbackObservations: json['feedback_observations'] as String?,
      schoolFeesOwed: json['school_fees_owed'] as String?,
      parentRemediation: json['parent_remediation'] as String?,
      parentRemediationOther: json['parent_remediation_other'] as String?,
      communityRemediation: json['community_remediation'] as String?,
      communityRemediationOther: json['community_remediation_other'] as String?,
      nameOwner: json['name_owner'] as String?,
      firstNameOwner: json['first_name_owner'] as String?,
      nationalityOwner: json['nationality_owner'] as String?,
      countryOriginOwner: json['country_origin_owner'] as String?,
      countryOriginOwnerOther: json['country_origin_owner_other'] as String?,
      managerWorkLength: json['manager_work_length'] as int?,
      recruitedWorkers: json['recruited_workers'] as String?,
      workerRecruitmentType: json['worker_recruitment_type'] as String?,
      workerAgreementType: json['worker_agreement_type'] as String?,
      workerAgreementOther: json['worker_agreement_other'] as String?,
      tasksClarified: json['tasks_clarified'] as String?,
      additionalTasks: json['additional_tasks'] as String?,
      refusalAction: json['refusal_action'] as String?,
      refusalActionOther: json['refusal_action_other'] as String?,
      salaryStatus: json['salary_status'] as String?,
      recruit1: json['recruit_1'] as String?,
      recruit2: json['recruit_2'] as String?,
      recruit3: json['recruit_3'] as String?,
      conditions1: json['conditions_1'] as String?,
      conditions2: json['conditions_2'] as String?,
      conditions3: json['conditions_3'] as String?,
      conditions4: json['conditions_4'] as String?,
      conditions5: json['conditions_5'] as String?,
      leaving1: json['leaving_1'] as String?,
      leaving2: json['leaving_2'] as String?,
      consentRecruitment: json['consent_recruitment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enumerator': enumerator,
      'farmer': farmer,
      'interview_start_time': interviewStartTime,
      'gps_point': gpsPoint,
      'community_type': communityType,
      'farmer_resides_in_community': farmerResidesInCommunity,
      'latitude': latitude,
      'longitude': longitude,
      'farmer_residing_community': farmerResidingCommunity,
      'farmer_available': farmerAvailable,
      'reason_unavailable': reasonUnavailable,
      'reason_unavailable_other': reasonUnavailableOther,
      'available_answer_by': availableAnswerBy,
      'refusal_toa_participate_reason_survey': refusalToaParticipateReasonSurvey,
      'total_adults': totalAdults,
      'is_name_correct': isNameCorrect,
      'exact_name': exactName,
      'nationality': nationality,
      'country_origin': countryOrigin,
      'country_origin_other': countryOriginOther,
      'is_owner': isOwner,
      'owner_status_01': ownerStatus01,
      'owner_status_00': ownerStatus00,
      'children_present': childrenPresent,
      'num_children_5_to_17': numChildren5To17,
      'feedback_enum': feedbackEnum,
      'picture_of_respondent': pictureOfRespondent,
      'signature_producer': signatureProducer,
      'end_gps': endGps,
      'end_time': endTime,
      'sensitized_good_parenting': sensitizedGoodParenting,
      'sensitized_child_protection': sensitizedChildProtection,
      'sensitized_safe_labour': sensitizedSafeLabour,
      'number_of_female_adults': numberOfFemaleAdults,
      'number_of_male_adults': numberOfMaleAdults,
      'picture_sensitization': pictureSensitization,
      'feedback_observations': feedbackObservations,
      'school_fees_owed': schoolFeesOwed,
      'parent_remediation': parentRemediation,
      'parent_remediation_other': parentRemediationOther,
      'community_remediation': communityRemediation,
      'community_remediation_other': communityRemediationOther,
      'name_owner': nameOwner,
      'first_name_owner': firstNameOwner,
      'nationality_owner': nationalityOwner,
      'country_origin_owner': countryOriginOwner,
      'country_origin_owner_other': countryOriginOwnerOther,
      'manager_work_length': managerWorkLength,
      'recruited_workers': recruitedWorkers,
      'worker_recruitment_type': workerRecruitmentType,
      'worker_agreement_type': workerAgreementType,
      'worker_agreement_other': workerAgreementOther,
      'tasks_clarified': tasksClarified,
      'additional_tasks': additionalTasks,
      'refusal_action': refusalAction,
      'refusal_action_other': refusalActionOther,
      'salary_status': salaryStatus,
      'recruit_1': recruit1,
      'recruit_2': recruit2,
      'recruit_3': recruit3,
      'conditions_1': conditions1,
      'conditions_2': conditions2,
      'conditions_3': conditions3,
      'conditions_4': conditions4,
      'conditions_5': conditions5,
      'leaving_1': leaving1,
      'leaving_2': leaving2,
      'consent_recruitment': consentRecruitment,
    };
  }

  String toJsonString() => json.encode(toJson());

  static FarmerInterview fromJsonString(String jsonString) =>
      FarmerInterview.fromJson(json.decode(jsonString));
}