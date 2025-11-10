import 'adult_info_model.dart';

class FarmerIdentificationModel {
  final int? id; // For database primary key

  // Visit Information
  final String? respondentNameCorrect;
  final String? respondentNationality;
  final String? countryOfOrigin;
  final String? isFarmOwner;
  final String? farmOwnershipType;
  final String correctedRespondentName;
  final String respondentOtherNames;
  final String otherCountry;

  // Workers in Farm
  final String? hasRecruitedWorker;
  final String? everRecruitedWorker;
  final String? workerAgreementType;
  final String? tasksClarified;
  final String? additionalTasks;
  final String? refusalAction;
  final String? salaryPaymentFrequency;
  final bool? permanentLabor;
  final bool? casualLabor;
  final String? otherAgreement;
  final Map<String, String?>? agreementResponses;

  // Adults Information
  final int? numberOfAdults;
  final List<HouseholdMember>? householdMembers;

  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced; // Track if synced with server

  const FarmerIdentificationModel({
    this.id,

    // Visit Information
    this.respondentNameCorrect,
    this.respondentNationality,
    this.countryOfOrigin,
    this.isFarmOwner,
    this.farmOwnershipType,
    this.correctedRespondentName = '',
    this.respondentOtherNames = '',
    this.otherCountry = '',

    // Workers in Farm
    this.hasRecruitedWorker,
    this.everRecruitedWorker,
    this.workerAgreementType,
    this.tasksClarified,
    this.additionalTasks,
    this.refusalAction,
    this.salaryPaymentFrequency,
    this.permanentLabor,
    this.casualLabor,
    this.otherAgreement,
    this.agreementResponses,

    // Adults Information
    this.numberOfAdults,
    this.householdMembers,

    // Metadata
    this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,

      // Visit Information
      'respondentNameCorrect': respondentNameCorrect,
      'respondentNationality': respondentNationality,
      'countryOfOrigin': countryOfOrigin,
      'isFarmOwner': isFarmOwner,
      'farmOwnershipType': farmOwnershipType,
      'correctedRespondentName': correctedRespondentName,
      'respondentOtherNames': respondentOtherNames,
      'otherCountry': otherCountry,

      // Workers in Farm
      'hasRecruitedWorker': hasRecruitedWorker,
      'everRecruitedWorker': everRecruitedWorker,
      'workerAgreementType': workerAgreementType,
      'tasksClarified': tasksClarified,
      'additionalTasks': additionalTasks,
      'refusalAction': refusalAction,
      'salaryPaymentFrequency': salaryPaymentFrequency,
      'permanentLabor':
          permanentLabor == null ? null : (permanentLabor! ? 1 : 0),
      'casualLabor': casualLabor == null ? null : (casualLabor! ? 1 : 0),
      'otherAgreement': otherAgreement,
      'agreementResponses':
          agreementResponses != null ? _encodeMap(agreementResponses!) : null,

      // Adults Information
      'numberOfAdults': numberOfAdults,
      'householdMembers': householdMembers?.map((m) => m.toMap()).toList(),

      // Metadata
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Create from Map (for database retrieval)
  factory FarmerIdentificationModel.fromMap(Map<String, dynamic> map) {
    return FarmerIdentificationModel(
      id: map['id'],

      // Visit Information
      respondentNameCorrect: map['respondentNameCorrect'],
      respondentNationality: map['respondentNationality'],
      countryOfOrigin: map['countryOfOrigin'],
      isFarmOwner: map['isFarmOwner'],
      farmOwnershipType: map['farmOwnershipType'],
      correctedRespondentName: map['correctedRespondentName'] ?? '',
      respondentOtherNames: map['respondentOtherNames'] ?? '',
      otherCountry: map['otherCountry'] ?? '',

      // Workers in Farm
      hasRecruitedWorker: map['hasRecruitedWorker'],
      everRecruitedWorker: map['everRecruitedWorker'],
      workerAgreementType: map['workerAgreementType'],
      tasksClarified: map['tasksClarified'],
      additionalTasks: map['additionalTasks'],
      refusalAction: map['refusalAction'],
      salaryPaymentFrequency: map['salaryPaymentFrequency'],
      permanentLabor: map['permanentLabor'] == 1,
      casualLabor: map['casualLabor'] == 1,
      otherAgreement: map['otherAgreement'],
      agreementResponses: map['agreementResponses'] != null
          ? _decodeMap(map['agreementResponses'])
          : null,

      // Adults Information
      numberOfAdults: map['numberOfAdults'],
      householdMembers: map['householdMembers'] != null
          ? List<Map<String, dynamic>>.from(map['householdMembers'])
              .map((m) => HouseholdMember.fromMap(m))
              .toList()
          : null,

      // Metadata
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isSynced: map['isSynced'] == 1,
    );
  }

  // Create a copy with some fields updated
  FarmerIdentificationModel copyWith({
    int? id,

    // Visit Information
    String? respondentNameCorrect,
    String? respondentNationality,
    String? countryOfOrigin,
    String? isFarmOwner,
    String? farmOwnershipType,
    String? correctedRespondentName,
    String? respondentOtherNames,
    String? otherCountry,

    // Workers in Farm
    String? hasRecruitedWorker,
    String? everRecruitedWorker,
    String? workerAgreementType,
    String? tasksClarified,
    String? additionalTasks,
    String? refusalAction,
    String? salaryPaymentFrequency,
    bool? permanentLabor,
    bool? casualLabor,
    String? otherAgreement,
    Map<String, String?>? agreementResponses,

    // Adults Information
    int? numberOfAdults,
    List<HouseholdMember>? householdMembers,

    // Metadata
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return FarmerIdentificationModel(
      id: id ?? this.id,

      // Visit Information
      respondentNameCorrect:
          respondentNameCorrect ?? this.respondentNameCorrect,
      respondentNationality:
          respondentNationality ?? this.respondentNationality,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      isFarmOwner: isFarmOwner ?? this.isFarmOwner,
      farmOwnershipType: farmOwnershipType ?? this.farmOwnershipType,
      correctedRespondentName:
          correctedRespondentName ?? this.correctedRespondentName,
      respondentOtherNames: respondentOtherNames ?? this.respondentOtherNames,
      otherCountry: otherCountry ?? this.otherCountry,

      // Workers in Farm
      hasRecruitedWorker: hasRecruitedWorker ?? this.hasRecruitedWorker,
      everRecruitedWorker: everRecruitedWorker ?? this.everRecruitedWorker,
      workerAgreementType: workerAgreementType ?? this.workerAgreementType,
      tasksClarified: tasksClarified ?? this.tasksClarified,
      additionalTasks: additionalTasks ?? this.additionalTasks,
      refusalAction: refusalAction ?? this.refusalAction,
      salaryPaymentFrequency:
          salaryPaymentFrequency ?? this.salaryPaymentFrequency,
      permanentLabor: permanentLabor ?? this.permanentLabor,
      casualLabor: casualLabor ?? this.casualLabor,
      otherAgreement: otherAgreement ?? this.otherAgreement,
      agreementResponses: agreementResponses ?? this.agreementResponses,

      // Adults Information
      numberOfAdults: numberOfAdults ?? this.numberOfAdults,
      householdMembers: householdMembers ?? this.householdMembers,

      // Metadata
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // Helper methods for map serialization
  static Map<String, dynamic> _encodeMap(Map<String, String?> map) {
    return Map<String, dynamic>.from(map);
  }

  static Map<String, String?> _decodeMap(dynamic data) {
    if (data == null) return {};
    return Map<String, String?>.from(data);
  }

  // Create an empty instance
  static FarmerIdentificationModel empty() => const FarmerIdentificationModel();

  // Check if the model is empty
  bool get isEmpty => this == empty();

  // Check if the model is not empty
  bool get isNotEmpty => this != empty();

  @override
  String toString() {
    return 'FarmerIdentificationModel{\n'
        '  id: $id,\n'
        '  // Visit Information\n'
        '  respondentNameCorrect: $respondentNameCorrect,\n'
        '  respondentNationality: $respondentNationality,\n'
        '  countryOfOrigin: $countryOfOrigin,\n'
        '  isFarmOwner: $isFarmOwner,\n'
        '  farmOwnershipType: $farmOwnershipType,\n'
        '  correctedRespondentName: $correctedRespondentName,\n'
        '  respondentOtherNames: $respondentOtherNames,\n'
        '  otherCountry: $otherCountry,\n'
        '  // Workers in Farm\n'
        '  hasRecruitedWorker: $hasRecruitedWorker,\n'
        '  everRecruitedWorker: $everRecruitedWorker,\n'
        '  workerAgreementType: $workerAgreementType,\n'
        '  tasksClarified: $tasksClarified,\n'
        '  additionalTasks: $additionalTasks,\n'
        '  refusalAction: $refusalAction,\n'
        '  salaryPaymentFrequency: $salaryPaymentFrequency,\n'
        '  permanentLabor: $permanentLabor,\n'
        '  casualLabor: $casualLabor,\n'
        '  otherAgreement: $otherAgreement,\n'
        '  agreementResponses: $agreementResponses,\n'
        '  // Adults Information\n'
        '  numberOfAdults: $numberOfAdults,\n'
        '  householdMembers: $householdMembers,\n'
        '  // Metadata\n'
        '  createdAt: $createdAt,\n'
        '  updatedAt: $updatedAt,\n'
        '  isSynced: $isSynced\n'
        '}';
  }
}
