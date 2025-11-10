// models/household_model.dart
import 'package:geolocator/geolocator.dart';

/// Comprehensive model representing a household assessment including all sections
class HouseholdModel {
  // Cover Page Fields
  int? id;
  String selectedTown;
  String selectedTownName;
  String selectedFarmer;
  String selectedFarmerName;

  // Consent Fields
  DateTime? interviewStartTime;
  String timeStatus;
  double? latitude;
  double? longitude;
  String locationStatus;
  bool isGettingLocation;
  String? communityType;
  String? residesInCommunityConsent;
  String? farmerAvailable;
  String? farmerStatus;
  String? availablePerson;
  String? otherSpecification;
  String? otherCommunityName;
  bool consentGiven;
  String? refusalReason;
  DateTime? consentTimestamp;

  // Farmer Identification Fields
  String? farmerGhCardAvailable; // 'yes' or 'no'
  String? farmerNatIdAvailable; // 'ghana_card', 'voter', 'nhis', etc.
  String? idPictureConsent; // 'Yes' or 'No'
  String? idImagePath;
  String? ghanaCardNumber;
  String? idNumber;
  String? idRejectionReason;
  String? contactNumber;
  int children5_17Count;
  List<Map<String, dynamic>> children;

  // Visit Information Fields
  String? respondentNameCorrect; // 'Yes' or 'No'
  String? correctedRespondentName; // Surname when name is incorrect
  String?
      correctedRespondentOtherNames; // First and other names when name is incorrect
  String? respondentNationality; // 'Ghanaian' or 'Non-Ghanaian'
  String? countryOfOrigin; // Country if non-Ghanaian
  String? otherCountry; // Other country specification
  String? isFarmOwner; // 'Yes' or 'No'
  String?
      farmOwnershipType; // 'Complete Owner', 'Sharecropper', 'Owner/Sharecropper'

  // Owner Identification Fields
  String? ownerName; // Name of the owner
  String? ownerFirstName; // First name of the owner
  String? ownerNationality; // 'Ghanaian' or 'Non-Ghanaian'
  String? ownerSpecificNationality; // Specific country if non-Ghanaian
  String? ownerOtherNationality; // Other nationality specification
  String? yearsWithOwner; // Years working with owner

  // Workers in Farm Fields
  String? hasRecruitedWorker; // '1' for Yes, '0' for No
  String? everRecruitedWorker; // 'Yes' or 'No' for follow-up question
  bool permanentLabor; // true if permanent labor is selected
  bool casualLabor; // true if casual labor is selected
  String? workerAgreementType; // Type of agreement with workers
  String? otherAgreementType; // Other agreement specification
  String? tasksClarified; // 'Yes' or 'No' for task clarification
  String? additionalTasks; // 'Yes' or 'No' for additional tasks
  String? refusalAction; // Action when worker refuses tasks
  String? otherRefusalAction; // Other refusal action specification
  String? salaryPaymentFrequency; // 'Always', 'Sometimes', 'Rarely', 'Never'

  // Agreement responses
  Map<String, String?>
      agreementResponses; // Store all agreement statement responses

  // Metadata
  String createdAt;
  String updatedAt;
  int status; // 0 = draft, 1 = completed, 2 = submitted, 3 = synced
  int syncStatus; // 0 = not synced, 1 = synced

  HouseholdModel({
    // Cover Page
    this.id,
    required this.selectedTown,
    required this.selectedTownName,
    required this.selectedFarmer,
    required this.selectedFarmerName,

    // Consent
    this.interviewStartTime,
    this.timeStatus = 'Not recorded',
    this.latitude,
    this.longitude,
    this.locationStatus = 'Not recorded',
    this.isGettingLocation = false,
    this.communityType,
    this.residesInCommunityConsent,
    this.farmerAvailable,
    this.farmerStatus,
    this.availablePerson,
    this.otherSpecification,
    this.otherCommunityName,
    this.consentGiven = false,
    this.refusalReason,
    this.consentTimestamp,

    // Farmer Identification
    this.farmerGhCardAvailable,
    this.farmerNatIdAvailable,
    this.idPictureConsent,
    this.idImagePath,
    this.ghanaCardNumber,
    this.idNumber,
    this.idRejectionReason,
    this.contactNumber,
    this.children5_17Count = 0,
    List<Map<String, dynamic>>? children,

    // Visit Information
    this.respondentNameCorrect,
    this.correctedRespondentName,
    this.correctedRespondentOtherNames,
    this.respondentNationality,
    this.countryOfOrigin,
    this.otherCountry,
    this.isFarmOwner,
    this.farmOwnershipType,

    // Owner Identification
    this.ownerName,
    this.ownerFirstName,
    this.ownerNationality,
    this.ownerSpecificNationality,
    this.ownerOtherNationality,
    this.yearsWithOwner,

    // Workers in Farm
    this.hasRecruitedWorker = '0', // Default to 'No'
    this.everRecruitedWorker = 'No', // Default to 'No'
    this.permanentLabor = false,
    this.casualLabor = false,
    this.workerAgreementType,
    this.otherAgreementType,
    this.tasksClarified,
    this.additionalTasks,
    this.refusalAction,
    this.otherRefusalAction,
    this.salaryPaymentFrequency,
    Map<String, String?>? agreementResponses,

    // Metadata
    required this.createdAt,
    required this.updatedAt,
    this.status = 0,
    this.syncStatus = 0,
  })  : children = children ?? [],
        agreementResponses = agreementResponses ??
            {
              // Initialize all agreement responses as null
              'salary_workers': null,
              'recruit_1': null,
              'recruit_2': null,
              'recruit_3': null,
              'conditions_1': null,
              'conditions_2': null,
              'conditions_3': null,
              'conditions_4': null,
              'conditions_5': null,
              'leaving_1': null,
              'leaving_2': null,
            };

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      // Cover Page Data
      'id': id,
      'selectedTown': selectedTown,
      'selectedTownName': selectedTownName,
      'selectedFarmer': selectedFarmer,
      'selectedFarmerName': selectedFarmerName,

      // Consent Data
      'interviewStartTime': interviewStartTime?.toIso8601String(),
      'timeStatus': timeStatus,
      'latitude': latitude,
      'longitude': longitude,
      'locationStatus': locationStatus,
      'isGettingLocation': isGettingLocation ? 1 : 0,
      'communityType': communityType,
      'residesInCommunityConsent': residesInCommunityConsent,
      'farmerAvailable': farmerAvailable,
      'farmerStatus': farmerStatus,
      'availablePerson': availablePerson,
      'otherSpecification': otherSpecification,
      'otherCommunityName': otherCommunityName,
      'consentGiven': consentGiven ? 1 : 0,
      'refusalReason': refusalReason,
      'consentTimestamp': consentTimestamp?.toIso8601String(),

      // Farmer Identification Data
      'farmer_gh_card_available': farmerGhCardAvailable,
      'farmer_nat_id_available': farmerNatIdAvailable,
      'id_picture_consent': idPictureConsent,
      'id_image_path': idImagePath,
      'ghana_card_number': ghanaCardNumber,
      'id_number': idNumber,
      'id_rejection_reason': idRejectionReason,
      'contact_number': contactNumber,
      'children_5_17_count': children5_17Count,
      'children': children,

      // Visit Information Data
      'respondent_name_correct': respondentNameCorrect,
      'corrected_respondent_name': correctedRespondentName,
      'corrected_respondent_other_names': correctedRespondentOtherNames,
      'respondent_nationality': respondentNationality,
      'country_of_origin': countryOfOrigin,
      'other_country': otherCountry,
      'is_farm_owner': isFarmOwner,
      'farm_ownership_type': farmOwnershipType,

      // Owner Identification Data
      'owner_name': ownerName,
      'owner_first_name': ownerFirstName,
      'owner_nationality': ownerNationality,
      'owner_specific_nationality': ownerSpecificNationality,
      'owner_other_nationality': ownerOtherNationality,
      'years_with_owner': yearsWithOwner,

      // Workers in Farm Data
      'has_recruited_worker': hasRecruitedWorker,
      'ever_recruited_worker': everRecruitedWorker,
      'permanent_labor': permanentLabor ? 1 : 0,
      'casual_labor': casualLabor ? 1 : 0,
      'worker_agreement_type': workerAgreementType,
      'other_agreement_type': otherAgreementType,
      'tasks_clarified': tasksClarified,
      'additional_tasks': additionalTasks,
      'refusal_action': refusalAction,
      'other_refusal_action': otherRefusalAction,
      'salary_payment_frequency': salaryPaymentFrequency,
      'agreement_responses': agreementResponses,

      // Metadata
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      'syncStatus': syncStatus,
    };
  }

  /// Create from Map from database
  factory HouseholdModel.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> childrenList = [];

    if (map['children'] != null && map['children'] is List) {
      childrenList = List<Map<String, dynamic>>.from(map['children'] as List);
    }

    // Handle agreement responses
    Map<String, String?> agreementResponsesMap = {};
    if (map['agreement_responses'] != null &&
        map['agreement_responses'] is Map) {
      agreementResponsesMap =
          Map<String, String?>.from(map['agreement_responses'] as Map);
    } else {
      // Initialize with default structure if not present
      agreementResponsesMap = {
        'salary_workers': null,
        'recruit_1': null,
        'recruit_2': null,
        'recruit_3': null,
        'conditions_1': null,
        'conditions_2': null,
        'conditions_3': null,
        'conditions_4': null,
        'conditions_5': null,
        'leaving_1': null,
        'leaving_2': null,
      };
    }

    return HouseholdModel(
      // Cover Page
      id: map['id'] as int?,
      selectedTown: map['selectedTown'] ?? '',
      selectedTownName: map['selectedTownName'] ?? '',
      selectedFarmer: map['selectedFarmer'] ?? '',
      selectedFarmerName: map['selectedFarmerName'] ?? '',

      // Consent
      interviewStartTime: map['interviewStartTime'] != null
          ? DateTime.parse(map['interviewStartTime'] as String)
          : null,
      timeStatus: map['timeStatus'] as String? ?? 'Not recorded',
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      locationStatus: map['locationStatus'] as String? ?? 'Not recorded',
      isGettingLocation: (map['isGettingLocation'] as int?) == 1,
      communityType: map['communityType'] as String?,
      residesInCommunityConsent: map['residesInCommunityConsent'] as String?,
      farmerAvailable: map['farmerAvailable'] as String?,
      farmerStatus: map['farmerStatus'] as String?,
      availablePerson: map['availablePerson'] as String?,
      otherSpecification: map['otherSpecification'] as String?,
      otherCommunityName: map['otherCommunityName'] as String?,
      consentGiven: (map['consentGiven'] as int?) == 1,
      refusalReason: map['refusalReason'] as String?,
      consentTimestamp: map['consentTimestamp'] != null
          ? DateTime.parse(map['consentTimestamp'] as String)
          : null,

      // Farmer Identification
      farmerGhCardAvailable: map['farmer_gh_card_available'] as String?,
      farmerNatIdAvailable: map['farmer_nat_id_available'] as String?,
      idPictureConsent: map['id_picture_consent'] as String?,
      idImagePath: map['id_image_path'] as String?,
      ghanaCardNumber: map['ghana_card_number'] as String?,
      idNumber: map['id_number'] as String?,
      idRejectionReason: map['id_rejection_reason'] as String?,
      contactNumber: map['contact_number'] as String?,
      children5_17Count: map['children_5_17_count'] as int? ?? 0,
      children: childrenList,

      // Visit Information
      respondentNameCorrect: map['respondent_name_correct'] as String?,
      correctedRespondentName: map['corrected_respondent_name'] as String?,
      correctedRespondentOtherNames:
          map['corrected_respondent_other_names'] as String?,
      respondentNationality: map['respondent_nationality'] as String?,
      countryOfOrigin: map['country_of_origin'] as String?,
      otherCountry: map['other_country'] as String?,
      isFarmOwner: map['is_farm_owner'] as String?,
      farmOwnershipType: map['farm_ownership_type'] as String?,

      // Owner Identification
      ownerName: map['owner_name'] as String?,
      ownerFirstName: map['owner_first_name'] as String?,
      ownerNationality: map['owner_nationality'] as String?,
      ownerSpecificNationality: map['owner_specific_nationality'] as String?,
      ownerOtherNationality: map['owner_other_nationality'] as String?,
      yearsWithOwner: map['years_with_owner'] as String?,

      // Workers in Farm
      hasRecruitedWorker: map['has_recruited_worker'] as String? ?? '0',
      everRecruitedWorker: map['ever_recruited_worker'] as String? ?? 'No',
      permanentLabor: (map['permanent_labor'] as int?) == 1,
      casualLabor: (map['casual_labor'] as int?) == 1,
      workerAgreementType: map['worker_agreement_type'] as String?,
      otherAgreementType: map['other_agreement_type'] as String?,
      tasksClarified: map['tasks_clarified'] as String?,
      additionalTasks: map['additional_tasks'] as String?,
      refusalAction: map['refusal_action'] as String?,
      otherRefusalAction: map['other_refusal_action'] as String?,
      salaryPaymentFrequency: map['salary_payment_frequency'] as String?,
      agreementResponses: agreementResponsesMap,

      // Metadata
      createdAt: map['createdAt'] as String? ?? DateTime.now().toString(),
      updatedAt: map['updatedAt'] as String? ?? DateTime.now().toString(),
      status: map['status'] as int? ?? 0,
      syncStatus: map['syncStatus'] as int? ?? 0,
    );
  }

  /// Copy with method for immutability
  HouseholdModel copyWith({
    // Cover Page
    int? id,
    String? selectedTown,
    String? selectedTownName,
    String? selectedFarmer,
    String? selectedFarmerName,

    // Consent
    DateTime? interviewStartTime,
    String? timeStatus,
    double? latitude,
    double? longitude,
    String? locationStatus,
    bool? isGettingLocation,
    String? communityType,
    String? residesInCommunityConsent,
    String? farmerAvailable,
    String? farmerStatus,
    String? availablePerson,
    String? otherSpecification,
    String? otherCommunityName,
    bool? consentGiven,
    String? refusalReason,
    DateTime? consentTimestamp,

    // Farmer Identification
    String? farmerGhCardAvailable,
    String? farmerNatIdAvailable,
    String? idPictureConsent,
    String? idImagePath,
    String? ghanaCardNumber,
    String? idNumber,
    String? idRejectionReason,
    String? contactNumber,
    int? children5_17Count,
    List<Map<String, dynamic>>? children,

    // Visit Information
    String? respondentNameCorrect,
    String? correctedRespondentName,
    String? correctedRespondentOtherNames,
    String? respondentNationality,
    String? countryOfOrigin,
    String? otherCountry,
    String? isFarmOwner,
    String? farmOwnershipType,

    // Owner Identification
    String? ownerName,
    String? ownerFirstName,
    String? ownerNationality,
    String? ownerSpecificNationality,
    String? ownerOtherNationality,
    String? yearsWithOwner,

    // Workers in Farm
    String? hasRecruitedWorker,
    String? everRecruitedWorker,
    bool? permanentLabor,
    bool? casualLabor,
    String? workerAgreementType,
    String? otherAgreementType,
    String? tasksClarified,
    String? additionalTasks,
    String? refusalAction,
    String? otherRefusalAction,
    String? salaryPaymentFrequency,
    Map<String, String?>? agreementResponses,

    // Metadata
    String? createdAt,
    String? updatedAt,
    int? status,
    int? syncStatus,
  }) {
    return HouseholdModel(
      id: id ?? this.id,
      selectedTown: selectedTown ?? this.selectedTown,
      selectedTownName: selectedTownName ?? this.selectedTownName,
      selectedFarmer: selectedFarmer ?? this.selectedFarmer,
      selectedFarmerName: selectedFarmerName ?? this.selectedFarmerName,
      interviewStartTime: interviewStartTime ?? this.interviewStartTime,
      timeStatus: timeStatus ?? this.timeStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationStatus: locationStatus ?? this.locationStatus,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      communityType: communityType ?? this.communityType,
      residesInCommunityConsent:
          residesInCommunityConsent ?? this.residesInCommunityConsent,
      farmerAvailable: farmerAvailable ?? this.farmerAvailable,
      farmerStatus: farmerStatus ?? this.farmerStatus,
      availablePerson: availablePerson ?? this.availablePerson,
      otherSpecification: otherSpecification ?? this.otherSpecification,
      otherCommunityName: otherCommunityName ?? this.otherCommunityName,
      consentGiven: consentGiven ?? this.consentGiven,
      refusalReason: refusalReason ?? this.refusalReason,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,

      // Farmer Identification
      farmerGhCardAvailable:
          farmerGhCardAvailable ?? this.farmerGhCardAvailable,
      farmerNatIdAvailable: farmerNatIdAvailable ?? this.farmerNatIdAvailable,
      idPictureConsent: idPictureConsent ?? this.idPictureConsent,
      idImagePath: idImagePath ?? this.idImagePath,
      ghanaCardNumber: ghanaCardNumber ?? this.ghanaCardNumber,
      idNumber: idNumber ?? this.idNumber,
      idRejectionReason: idRejectionReason ?? this.idRejectionReason,
      contactNumber: contactNumber ?? this.contactNumber,
      children5_17Count: children5_17Count ?? this.children5_17Count,
      children: children ?? this.children,

      // Visit Information
      respondentNameCorrect:
          respondentNameCorrect ?? this.respondentNameCorrect,
      correctedRespondentName:
          correctedRespondentName ?? this.correctedRespondentName,
      correctedRespondentOtherNames:
          correctedRespondentOtherNames ?? this.correctedRespondentOtherNames,
      respondentNationality:
          respondentNationality ?? this.respondentNationality,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      otherCountry: otherCountry ?? this.otherCountry,
      isFarmOwner: isFarmOwner ?? this.isFarmOwner,
      farmOwnershipType: farmOwnershipType ?? this.farmOwnershipType,

      // Owner Identification
      ownerName: ownerName ?? this.ownerName,
      ownerFirstName: ownerFirstName ?? this.ownerFirstName,
      ownerNationality: ownerNationality ?? this.ownerNationality,
      ownerSpecificNationality:
          ownerSpecificNationality ?? this.ownerSpecificNationality,
      ownerOtherNationality:
          ownerOtherNationality ?? this.ownerOtherNationality,
      yearsWithOwner: yearsWithOwner ?? this.yearsWithOwner,

      // Workers in Farm
      hasRecruitedWorker: hasRecruitedWorker ?? this.hasRecruitedWorker,
      everRecruitedWorker: everRecruitedWorker ?? this.everRecruitedWorker,
      permanentLabor: permanentLabor ?? this.permanentLabor,
      casualLabor: casualLabor ?? this.casualLabor,
      workerAgreementType: workerAgreementType ?? this.workerAgreementType,
      otherAgreementType: otherAgreementType ?? this.otherAgreementType,
      tasksClarified: tasksClarified ?? this.tasksClarified,
      additionalTasks: additionalTasks ?? this.additionalTasks,
      refusalAction: refusalAction ?? this.refusalAction,
      otherRefusalAction: otherRefusalAction ?? this.otherRefusalAction,
      salaryPaymentFrequency:
          salaryPaymentFrequency ?? this.salaryPaymentFrequency,
      agreementResponses: agreementResponses ?? this.agreementResponses,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Helper method to create from dropdown selections
  static HouseholdModel fromSelections({
    String? townCode,
    String? townName,
    String? farmerCode,
    String? farmerName,
  }) {
    return HouseholdModel(
      selectedTown: townCode ?? '',
      selectedTownName: townName ?? '',
      selectedFarmer: farmerCode ?? '',
      selectedFarmerName: farmerName ?? '',
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
    );
  }

  /// Update with GPS position
  HouseholdModel updateWithPosition(Position position) {
    return copyWith(
      latitude: position.latitude,
      longitude: position.longitude,
      locationStatus: 'Recorded',
      isGettingLocation: false,
      updatedAt: DateTime.now().toString(),
    );
  }

  /// Record interview start time
  HouseholdModel recordInterviewTime() {
    return copyWith(
      interviewStartTime: DateTime.now(),
      timeStatus: 'Recorded at ${DateTime.now().toIso8601String()}',
      updatedAt: DateTime.now().toString(),
    );
  }

  /// Update consent decision
  HouseholdModel updateConsent(bool given, {String? refusalReason}) {
    return copyWith(
      consentGiven: given,
      refusalReason: refusalReason,
      consentTimestamp: given ? DateTime.now() : null,
      updatedAt: DateTime.now().toString(),
      status: given ? 1 : 0,
    );
  }

  /// Update farmer identification data
  HouseholdModel updateFarmerIdentification({
    String? farmerGhCardAvailable,
    String? farmerNatIdAvailable,
    String? idPictureConsent,
    String? idImagePath,
    String? ghanaCardNumber,
    String? idNumber,
    String? idRejectionReason,
    String? contactNumber,
    int? children5_17Count,
    List<Map<String, dynamic>>? children,
  }) {
    return copyWith(
      farmerGhCardAvailable: farmerGhCardAvailable,
      farmerNatIdAvailable: farmerNatIdAvailable,
      idPictureConsent: idPictureConsent,
      idImagePath: idImagePath,
      ghanaCardNumber: ghanaCardNumber,
      idNumber: idNumber,
      idRejectionReason: idRejectionReason,
      contactNumber: contactNumber,
      children5_17Count: children5_17Count,
      children: children,
      updatedAt: DateTime.now().toString(),
    );
  }

  /// Update visit information data
  HouseholdModel updateVisitInformation({
    String? respondentNameCorrect,
    String? correctedRespondentName,
    String? correctedRespondentOtherNames,
    String? respondentNationality,
    String? countryOfOrigin,
    String? otherCountry,
    String? isFarmOwner,
    String? farmOwnershipType,
  }) {
    return copyWith(
      respondentNameCorrect: respondentNameCorrect,
      correctedRespondentName: correctedRespondentName,
      correctedRespondentOtherNames: correctedRespondentOtherNames,
      respondentNationality: respondentNationality,
      countryOfOrigin: countryOfOrigin,
      otherCountry: otherCountry,
      isFarmOwner: isFarmOwner,
      farmOwnershipType: farmOwnershipType,
      updatedAt: DateTime.now().toString(),
    );
  }

  /// Update owner identification data
  HouseholdModel updateOwnerIdentification({
    String? ownerName,
    String? ownerFirstName,
    String? ownerNationality,
    String? ownerSpecificNationality,
    String? ownerOtherNationality,
    String? yearsWithOwner,
  }) {
    return copyWith(
      ownerName: ownerName,
      ownerFirstName: ownerFirstName,
      ownerNationality: ownerNationality,
      ownerSpecificNationality: ownerSpecificNationality,
      ownerOtherNationality: ownerOtherNationality,
      yearsWithOwner: yearsWithOwner,
      updatedAt: DateTime.now().toString(),
    );
  }

  /// Update workers in farm data
  HouseholdModel updateWorkersInFarm({
    String? hasRecruitedWorker,
    String? everRecruitedWorker,
    bool? permanentLabor,
    bool? casualLabor,
    String? workerAgreementType,
    String? otherAgreementType,
    String? tasksClarified,
    String? additionalTasks,
    String? refusalAction,
    String? otherRefusalAction,
    String? salaryPaymentFrequency,
    Map<String, String?>? agreementResponses,
  }) {
    return copyWith(
      hasRecruitedWorker: hasRecruitedWorker,
      everRecruitedWorker: everRecruitedWorker,
      permanentLabor: permanentLabor,
      casualLabor: casualLabor,
      workerAgreementType: workerAgreementType,
      otherAgreementType: otherAgreementType,
      tasksClarified: tasksClarified,
      additionalTasks: additionalTasks,
      refusalAction: refusalAction,
      otherRefusalAction: otherRefusalAction,
      salaryPaymentFrequency: salaryPaymentFrequency,
      agreementResponses: agreementResponses,
      updatedAt: DateTime.now().toString(),
    );
  }

  /// Update specific agreement response
  HouseholdModel updateAgreementResponse(String statementId, String response) {
    final updatedResponses = Map<String, String?>.from(agreementResponses);
    updatedResponses[statementId] = response;

    return copyWith(
      agreementResponses: updatedResponses,
      updatedAt: DateTime.now().toString(),
    );
  }

  // ====================================================================
  // BUSINESS LOGIC AND VALIDATION METHODS
  // ====================================================================

  /// Check if cover page is complete (both town and farmer selected)
  bool get isCoverPageComplete =>
      selectedTown.isNotEmpty && selectedFarmer.isNotEmpty;

  /// Check if interview time is recorded
  bool get hasInterviewTime => interviewStartTime != null;

  /// Check if location is recorded
  bool get hasLocation => latitude != null && longitude != null;

  /// Get formatted interview time
  String get formattedInterviewTime => interviewStartTime != null
      ? '${interviewStartTime!.hour}:${interviewStartTime!.minute.toString().padLeft(2, '0')}'
      : 'Not recorded';

  /// Get formatted coordinates
  String get formattedCoordinates => hasLocation
      ? 'Lat: ${latitude!.toStringAsFixed(6)}, Lon: ${longitude!.toStringAsFixed(6)}'
      : 'No coordinates';

  /// Check if farmer identification section is complete
  bool get isFarmerIdentificationComplete {
    // Basic required fields
    if (farmerGhCardAvailable == null || contactNumber == null) {
      return false;
    }

    // Validate Ghana Card flow
    if (farmerGhCardAvailable == 'yes') {
      if (idPictureConsent == 'Yes') {
        return ghanaCardNumber != null &&
            ghanaCardNumber!.isNotEmpty &&
            idImagePath != null;
      } else if (idPictureConsent == 'No') {
        return idRejectionReason != null && idRejectionReason!.isNotEmpty;
      }
    }

    // Validate alternative ID flow
    if (farmerGhCardAvailable == 'no') {
      if (farmerNatIdAvailable == null) return false;

      if (idPictureConsent == 'Yes') {
        return idNumber != null && idNumber!.isNotEmpty && idImagePath != null;
      } else if (idPictureConsent == 'No') {
        return idRejectionReason != null && idRejectionReason!.isNotEmpty;
      }
    }

    return idPictureConsent != null;
  }

  /// Check if visit information section is complete
  bool get isVisitInformationComplete {
    return respondentNameCorrect != null &&
        respondentNationality != null &&
        (respondentNationality != 'Non-Ghanaian' ||
            (countryOfOrigin != null &&
                (countryOfOrigin != 'Other' ||
                    (otherCountry != null && otherCountry!.isNotEmpty)))) &&
        isFarmOwner != null &&
        farmOwnershipType != null;
  }

  /// Check if owner identification section is complete
  bool get isOwnerIdentificationComplete {
    return ownerName != null &&
        ownerName!.isNotEmpty &&
        ownerFirstName != null &&
        ownerFirstName!.isNotEmpty &&
        ownerNationality != null &&
        (ownerNationality != 'Non-Ghanaian' ||
            (ownerSpecificNationality != null &&
                (ownerSpecificNationality != 'Other' ||
                    (ownerOtherNationality != null &&
                        ownerOtherNationality!.isNotEmpty)))) &&
        yearsWithOwner != null &&
        yearsWithOwner!.isNotEmpty;
  }

  /// Check if workers in farm section is complete
  bool get isWorkersInFarmComplete {
    // Check if the main recruitment question is answered
    if (hasRecruitedWorker == null) return false;

    // If recruited workers in past year, check if at least one type is selected
    if (hasRecruitedWorker == '1') {
      if (!permanentLabor && !casualLabor) return false;

      // Check if all required fields are filled
      if (workerAgreementType == null ||
          tasksClarified == null ||
          additionalTasks == null ||
          refusalAction == null ||
          salaryPaymentFrequency == null) {
        return false;
      }

      // Check if "Other" fields are specified when selected
      if (workerAgreementType == 'Other (specify)' &&
          (otherAgreementType == null || otherAgreementType!.isEmpty)) {
        return false;
      }

      if (refusalAction == 'Other' &&
          (otherRefusalAction == null || otherRefusalAction!.isEmpty)) {
        return false;
      }

      // Check if all agreement responses are filled
      if (agreementResponses.values.any((response) => response == null)) {
        return false;
      }
    }

    // If not recruited in past year, check if ever recruited question is answered
    if (hasRecruitedWorker == '0') {
      if (everRecruitedWorker == null) return false;

      // If they have recruited before, check agreement responses
      if (everRecruitedWorker == 'Yes' &&
          agreementResponses.values.any((response) => response == null)) {
        return false;
      }
    }

    return true;
  }

  /// Validate respondent name correction flow
  bool get isRespondentNameFlowValid {
    if (respondentNameCorrect == 'No') {
      return correctedRespondentName != null &&
          correctedRespondentName!.isNotEmpty &&
          correctedRespondentOtherNames != null &&
          correctedRespondentOtherNames!.isNotEmpty;
    }
    return true; // If 'Yes', no additional validation needed
  }

  /// Check if all agreement statements are answered
  bool get areAllAgreementsAnswered {
    return !agreementResponses.values.any((response) => response == null);
  }

  /// Get count of agreed statements
  int get agreedStatementsCount {
    return agreementResponses.values
        .where((response) => response == 'Agree')
        .length;
  }

  /// Get count of disagreed statements
  int get disagreedStatementsCount {
    return agreementResponses.values
        .where((response) => response == 'Disagree')
        .length;
  }

  /// Get display name for ID type
  String get idTypeDisplayName {
    switch (farmerNatIdAvailable) {
      case 'ghana_card':
        return 'Ghana Card';
      case 'voter':
        return 'Voter ID';
      case 'nhis':
        return 'NHIS Card';
      case 'passport':
        return 'Passport';
      case 'driver':
        return "Driver's License";
      case 'ssnit':
        return 'SSNIT';
      case 'birth':
        return 'Birth Certificate';
      default:
        return 'ID Card';
    }
  }

  /// Validate contact number format
  bool get isContactNumberValid {
    if (contactNumber == null || contactNumber!.isEmpty) return false;
    return contactNumber!.length == 10 && int.tryParse(contactNumber!) != null;
  }

  /// Determine if consent section should be shown based on business logic
  bool get shouldShowConsentSection {
    if (farmerAvailable == 'Yes') {
      return true;
    }

    if (farmerStatus == 'Non-resident' &&
        availablePerson != null &&
        availablePerson != 'Nobody') {
      return true;
    }

    if (farmerStatus == 'Other' &&
        availablePerson != null &&
        availablePerson != 'Nobody') {
      return true;
    }

    return false;
  }

  /// Check if survey should end based on certain conditions
  bool get shouldEndSurvey {
    return !consentGiven ||
        farmerStatus == 'Deceased' ||
        farmerStatus == 'Doesn\'t work with TOUTON anymore' ||
        availablePerson == 'Nobody';
  }

  /// Validate if all required fields for submission are filled
  bool get isValidForSubmission {
    return isCoverPageComplete &&
        hasInterviewTime &&
        hasLocation &&
        communityType != null &&
        residesInCommunityConsent != null &&
        farmerAvailable != null &&
        _validateFarmerAvailability() &&
        _validateConsentSection() &&
        isFarmerIdentificationComplete &&
        isVisitInformationComplete &&
        isOwnerIdentificationComplete &&
        isWorkersInFarmComplete &&
        isRespondentNameFlowValid;
  }

  bool _validateFarmerAvailability() {
    if (farmerAvailable == 'No') {
      if (farmerStatus == null) return false;

      if (farmerStatus == 'Other' &&
          (otherSpecification == null || otherSpecification!.isEmpty)) {
        return false;
      }

      if ((farmerStatus == 'Non-resident' || farmerStatus == 'Other') &&
          availablePerson == null) {
        return false;
      }

      if (residesInCommunityConsent == 'No' &&
          (otherCommunityName == null || otherCommunityName!.isEmpty)) {
        return false;
      }
    }
    return true;
  }

  bool _validateConsentSection() {
    if (!shouldShowConsentSection) return true;

    if (!consentGiven && refusalReason?.isEmpty != false) {
      return false;
    }

    return consentGiven || (!consentGiven && refusalReason?.isNotEmpty == true);
  }

  /// Check if can proceed to next section after consent
  bool get canProceedToNext {
    return isValidForSubmission && consentGiven;
  }

  /// Get current progress percentage (0-100)
  double get progressPercentage {
    int completedFields = 0;
    int totalFields = 0;

    // Cover page fields
    totalFields += 2;
    if (isCoverPageComplete) completedFields += 2;

    // Consent required fields
    totalFields += 4;
    if (hasInterviewTime) completedFields++;
    if (hasLocation) completedFields++;
    if (communityType != null) completedFields++;
    if (residesInCommunityConsent != null) completedFields++;

    // Farmer availability fields
    if (farmerAvailable != null) {
      completedFields++;
      if (farmerAvailable == 'No') {
        totalFields += 2;
        if (farmerStatus != null) completedFields++;
        if (_validateFarmerAvailability()) completedFields++;
      }
    } else {
      totalFields++;
    }

    // Consent section if applicable
    if (shouldShowConsentSection) {
      totalFields++;
      if (consentGiven || (refusalReason?.isNotEmpty == true))
        completedFields++;
    }

    // Farmer identification fields
    totalFields += 2;
    if (farmerGhCardAvailable != null) completedFields++;
    if (contactNumber != null && isContactNumberValid) completedFields++;

    if (farmerGhCardAvailable == 'yes') {
      totalFields += 1;
      if (idPictureConsent != null) completedFields++;

      if (idPictureConsent == 'Yes') {
        totalFields += 2;
        if (ghanaCardNumber != null && ghanaCardNumber!.isNotEmpty)
          completedFields++;
        if (idImagePath != null) completedFields++;
      } else if (idPictureConsent == 'No') {
        totalFields += 1;
        if (idRejectionReason != null && idRejectionReason!.isNotEmpty)
          completedFields++;
      }
    }

    if (farmerGhCardAvailable == 'no') {
      totalFields += 2;
      if (farmerNatIdAvailable != null) completedFields++;
      if (idPictureConsent != null) completedFields++;

      if (idPictureConsent == 'Yes') {
        totalFields += 2;
        if (idNumber != null && idNumber!.isNotEmpty) completedFields++;
        if (idImagePath != null) completedFields++;
      } else if (idPictureConsent == 'No') {
        totalFields += 1;
        if (idRejectionReason != null && idRejectionReason!.isNotEmpty)
          completedFields++;
      }
    }

    // Visit information fields
    totalFields += 2; // Basic required fields
    if (respondentNameCorrect != null) completedFields++;
    if (respondentNationality != null) completedFields++;

    if (respondentNameCorrect == 'No') {
      totalFields += 2;
      if (correctedRespondentName != null &&
          correctedRespondentName!.isNotEmpty) completedFields++;
      if (correctedRespondentOtherNames != null &&
          correctedRespondentOtherNames!.isNotEmpty) completedFields++;
    }

    if (respondentNationality == 'Non-Ghanaian') {
      totalFields += 1;
      if (countryOfOrigin != null) completedFields++;

      if (countryOfOrigin == 'Other') {
        totalFields += 1;
        if (otherCountry != null && otherCountry!.isNotEmpty) completedFields++;
      }
    }

    totalFields += 2; // Farm ownership fields
    if (isFarmOwner != null) completedFields++;
    if (farmOwnershipType != null) completedFields++;

    // Owner identification fields
    totalFields += 2; // Name fields
    if (ownerName != null && ownerName!.isNotEmpty) completedFields++;
    if (ownerFirstName != null && ownerFirstName!.isNotEmpty) completedFields++;

    totalFields += 1; // Nationality field
    if (ownerNationality != null) completedFields++;

    if (ownerNationality == 'Non-Ghanaian') {
      totalFields += 1;
      if (ownerSpecificNationality != null) completedFields++;

      if (ownerSpecificNationality == 'Other') {
        totalFields += 1;
        if (ownerOtherNationality != null && ownerOtherNationality!.isNotEmpty)
          completedFields++;
      }
    }

    totalFields += 1; // Years with owner field
    if (yearsWithOwner != null && yearsWithOwner!.isNotEmpty) completedFields++;

    // Workers in Farm fields
    totalFields += 1; // Main recruitment question
    if (hasRecruitedWorker != null) completedFields++;

    if (hasRecruitedWorker == '1') {
      totalFields += 2; // Labor types
      if (permanentLabor || casualLabor)
        completedFields += (permanentLabor ? 1 : 0) + (casualLabor ? 1 : 0);

      totalFields += 5; // Required fields
      if (workerAgreementType != null) completedFields++;
      if (tasksClarified != null) completedFields++;
      if (additionalTasks != null) completedFields++;
      if (refusalAction != null) completedFields++;
      if (salaryPaymentFrequency != null) completedFields++;

      // Other specification fields
      if (workerAgreementType == 'Other (specify)') {
        totalFields += 1;
        if (otherAgreementType != null && otherAgreementType!.isNotEmpty)
          completedFields++;
      }

      if (refusalAction == 'Other') {
        totalFields += 1;
        if (otherRefusalAction != null && otherRefusalAction!.isNotEmpty)
          completedFields++;
      }

      // Agreement responses
      totalFields += agreementResponses.length;
      completedFields += agreementResponses.values
          .where((response) => response != null)
          .length;
    }

    if (hasRecruitedWorker == '0') {
      totalFields += 1; // Ever recruited question
      if (everRecruitedWorker != null) completedFields++;

      if (everRecruitedWorker == 'Yes') {
        totalFields += agreementResponses.length;
        completedFields += agreementResponses.values
            .where((response) => response != null)
            .length;
      }
    }

    return totalFields > 0 ? (completedFields / totalFields) * 100 : 0;
  }

  /// Get a summary of the household data for display
  Map<String, String> get summary {
    return {
      'Town': selectedTownName,
      'Farmer': selectedFarmerName,
      'Interview Time': formattedInterviewTime,
      'Location': hasLocation ? 'Recorded' : 'Not recorded',
      'Community Type': communityType ?? 'Not selected',
      'Consent': consentGiven
          ? 'Given'
          : (refusalReason != null ? 'Declined' : 'Pending'),
      'Farmer ID': isFarmerIdentificationComplete ? 'Complete' : 'Incomplete',
      'Visit Info': isVisitInformationComplete ? 'Complete' : 'Incomplete',
      'Owner ID': isOwnerIdentificationComplete ? 'Complete' : 'Incomplete',
      'Workers Info': isWorkersInFarmComplete ? 'Complete' : 'Incomplete',
      'Status': _getStatusText(),
    };
  }

  String _getStatusText() {
    switch (status) {
      case 0:
        return 'Draft';
      case 1:
        return 'Completed';
      case 2:
        return 'Submitted';
      case 3:
        return 'Synced';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'HouseholdModel{id: $id, town: $selectedTownName, farmer: $selectedFarmerName, consent: $consentGiven, farmerID: $isFarmerIdentificationComplete, visitInfo: $isVisitInformationComplete, ownerID: $isOwnerIdentificationComplete, workersInfo: $isWorkersInFarmComplete, status: $status, sync: $syncStatus}';
  }

  /// Debug method to print all fields
  void debugPrint() {
    print('=== HOUSEHOLD MODEL DEBUG INFO ===');
    print('Cover Page:');
    print('  - Town: $selectedTownName ($selectedTown)');
    print('  - Farmer: $selectedFarmerName ($selectedFarmer)');
    print('Consent Data:');
    print('  - Interview Time: $formattedInterviewTime');
    print('  - Location: $formattedCoordinates');
    print('  - Community Type: $communityType');
    print('  - Resides in Community: $residesInCommunityConsent');
    print('  - Farmer Available: $farmerAvailable');
    print('  - Farmer Status: $farmerStatus');
    print('  - Available Person: $availablePerson');
    print('  - Consent Given: $consentGiven');
    print('  - Refusal Reason: $refusalReason');
    print('Farmer Identification:');
    print('  - Ghana Card Available: $farmerGhCardAvailable');
    print('  - ID Type: $farmerNatIdAvailable');
    print('  - Picture Consent: $idPictureConsent');
    print('  - Contact Number: $contactNumber');
    print('  - Children Count: $children5_17Count');
    print('  - Children: $children');
    print('Visit Information:');
    print('  - Respondent Name Correct: $respondentNameCorrect');
    print('  - Corrected Name: $correctedRespondentName');
    print('  - Corrected Other Names: $correctedRespondentOtherNames');
    print('  - Nationality: $respondentNationality');
    print('  - Country of Origin: $countryOfOrigin');
    print('  - Other Country: $otherCountry');
    print('  - Is Farm Owner: $isFarmOwner');
    print('  - Farm Ownership Type: $farmOwnershipType');
    print('Owner Identification:');
    print('  - Owner Name: $ownerName');
    print('  - Owner First Name: $ownerFirstName');
    print('  - Owner Nationality: $ownerNationality');
    print('  - Owner Specific Nationality: $ownerSpecificNationality');
    print('  - Owner Other Nationality: $ownerOtherNationality');
    print('  - Years With Owner: $yearsWithOwner');
    print('Workers in Farm:');
    print('  - Has Recruited Worker: $hasRecruitedWorker');
    print('  - Ever Recruited Worker: $everRecruitedWorker');
    print('  - Permanent Labor: $permanentLabor');
    print('  - Casual Labor: $casualLabor');
    print('  - Worker Agreement Type: $workerAgreementType');
    print('  - Other Agreement Type: $otherAgreementType');
    print('  - Tasks Clarified: $tasksClarified');
    print('  - Additional Tasks: $additionalTasks');
    print('  - Refusal Action: $refusalAction');
    print('  - Other Refusal Action: $otherRefusalAction');
    print('  - Salary Payment Frequency: $salaryPaymentFrequency');
    print('  - Agreement Responses: $agreementResponses');
    print('  - All Agreements Answered: $areAllAgreementsAnswered');
    print('  - Agreed Statements: $agreedStatementsCount');
    print('  - Disagreed Statements: $disagreedStatementsCount');
    print('Metadata:');
    print('  - Status: ${_getStatusText()}');
    print('  - Sync Status: ${syncStatus == 1 ? "Synced" : "Not Synced"}');
    print('  - Created: $createdAt');
    print('  - Updated: $updatedAt');
    print('==================================');
  }
}
