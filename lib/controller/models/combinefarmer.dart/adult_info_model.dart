class AdultsInformationData {
  final int? numberOfAdults;
  final List<HouseholdMember> members;

  const AdultsInformationData({
    this.numberOfAdults,
    this.members = const [],
  });

  AdultsInformationData copyWith({
    int? numberOfAdults,
    List<HouseholdMember>? members,
  }) {
    return AdultsInformationData(
      numberOfAdults: numberOfAdults ?? this.numberOfAdults,
      members: members ?? this.members,
    );
  }

  /// Converts the model to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'numberOfAdults': numberOfAdults,
      'members': members.map((member) => member.toMap()).toList(),
    };
  }
  
  /// For backward compatibility
  Map<String, dynamic> toMap() => toJson();

  /// Creates an AdultsInformationData from a JSON map
  factory AdultsInformationData.fromJson(Map<String, dynamic> json) {
    return AdultsInformationData(
      numberOfAdults: json['numberOfAdults'],
      members: List<HouseholdMember>.from(
        (json['members'] ?? []).map((x) => HouseholdMember.fromMap(x)),
      ),
    );
  }
  
  /// For backward compatibility
  factory AdultsInformationData.fromMap(Map<String, dynamic> map) => 
      AdultsInformationData.fromJson(map);

  static AdultsInformationData empty() {
    return const AdultsInformationData();
  }

  bool get isFormComplete {
    if (numberOfAdults == null || numberOfAdults == 0) return false;

    // Check all members have valid names and complete producer details
    for (final member in members) {
      if (!member.isNameValid || !member.producerDetails.isComplete) {
        return false;
      }
    }

    return true;
  }

  @override
  String toString() {
    return 'AdultsInformationData(numberOfAdults: $numberOfAdults, members: $members)';
  }
}

class HouseholdMember {
  final String name;
  final ProducerDetailsModel producerDetails;

  const HouseholdMember({
    this.name = '',
    this.producerDetails = const ProducerDetailsModel(),
  });

  HouseholdMember copyWith({
    String? name,
    ProducerDetailsModel? producerDetails,
  }) {
    return HouseholdMember(
      name: name ?? this.name,
      producerDetails: producerDetails ?? this.producerDetails,
    );
  }

  /// Converts the model to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'producerDetails': producerDetails.toMap(),
    };
  }
  
  /// For backward compatibility
  Map<String, dynamic> toMap() => toJson();

  /// Creates a HouseholdMember from a JSON map
  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      name: json['name'] ?? '',
      producerDetails: ProducerDetailsModel.fromMap(json['producerDetails'] ?? {}),
    );
  }
  
  /// For backward compatibility
  factory HouseholdMember.fromMap(Map<String, dynamic> map) => 
      HouseholdMember.fromJson(map);

  bool get isNameValid {
    return name.trim().isNotEmpty && name.trim().split(' ').length >= 2;
  }

  @override
  String toString() {
    return 'HouseholdMember(name: $name, producerDetails: $producerDetails)';
  }
}

class ProducerDetailsModel {
  final String? gender;
  final String? nationality;
  final int? yearOfBirth;
  final String? selectedCountry;
  final String? ghanaCardId;
  final String? otherIdType;
  final String? otherIdNumber;
  final bool? consentToTakePhoto;
  final String? noConsentReason;
  final String? idPhotoPath;
  final String? relationshipToRespondent;
  final String? otherRelationship;
  final String? hasBirthCertificate;
  final String? occupation;
  final String? otherOccupation;
  final String? otherCountry;

  const ProducerDetailsModel({
    this.gender,
    this.nationality,
    this.yearOfBirth,
    this.selectedCountry,
    this.ghanaCardId,
    this.otherIdType,
    this.otherIdNumber,
    this.consentToTakePhoto,
    this.noConsentReason,
    this.idPhotoPath,
    this.relationshipToRespondent,
    this.otherRelationship,
    this.hasBirthCertificate,
    this.occupation,
    this.otherOccupation,
    this.otherCountry,
  });

  ProducerDetailsModel copyWith({
    String? gender,
    String? nationality,
    int? yearOfBirth,
    String? selectedCountry,
    String? ghanaCardId,
    String? otherIdType,
    String? otherIdNumber,
    bool? consentToTakePhoto,
    String? noConsentReason,
    String? idPhotoPath,
    String? relationshipToRespondent,
    String? otherRelationship,
    String? hasBirthCertificate,
    String? occupation,
    String? otherOccupation,
    String? otherCountry,
  }) {
    return ProducerDetailsModel(
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      yearOfBirth: yearOfBirth ?? this.yearOfBirth,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      ghanaCardId: ghanaCardId ?? this.ghanaCardId,
      otherIdType: otherIdType ?? this.otherIdType,
      otherIdNumber: otherIdNumber ?? this.otherIdNumber,
      consentToTakePhoto: consentToTakePhoto ?? this.consentToTakePhoto,
      noConsentReason: noConsentReason ?? this.noConsentReason,
      idPhotoPath: idPhotoPath ?? this.idPhotoPath,
      relationshipToRespondent:
          relationshipToRespondent ?? this.relationshipToRespondent,
      otherRelationship: otherRelationship ?? this.otherRelationship,
      hasBirthCertificate: hasBirthCertificate ?? this.hasBirthCertificate,
      occupation: occupation ?? this.occupation,
      otherOccupation: otherOccupation ?? this.otherOccupation,
      otherCountry: otherCountry ?? this.otherCountry,
    );
  }

  /// Converts the model to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'nationality': nationality,
      'yearOfBirth': yearOfBirth,
      'selectedCountry': selectedCountry,
      'ghanaCardId': ghanaCardId,
      'otherIdType': otherIdType,
      'otherIdNumber': otherIdNumber,
      'consentToTakePhoto': consentToTakePhoto,
      'noConsentReason': noConsentReason,
      'idPhotoPath': idPhotoPath,
      'relationshipToRespondent': relationshipToRespondent,
      'otherRelationship': otherRelationship,
      'hasBirthCertificate': hasBirthCertificate,
      'occupation': occupation,
      'otherOccupation': otherOccupation,
      'otherCountry': otherCountry,
    };
  }

  /// Creates a ProducerDetailsModel from a JSON map
  factory ProducerDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProducerDetailsModel(
      gender: json['gender'],
      nationality: json['nationality'],
      yearOfBirth: json['yearOfBirth'],
      selectedCountry: json['selectedCountry'],
      ghanaCardId: json['ghanaCardId'],
      otherIdType: json['otherIdType'],
      otherIdNumber: json['otherIdNumber'],
      consentToTakePhoto: json['consentToTakePhoto'] == true || json['consentToTakePhoto'] == 1,
      noConsentReason: json['noConsentReason'],
      idPhotoPath: json['idPhotoPath'],
      relationshipToRespondent: json['relationshipToRespondent'],
      otherRelationship: json['otherRelationship'],
      hasBirthCertificate: json['hasBirthCertificate'],
      occupation: json['occupation'],
      otherOccupation: json['otherOccupation'],
      otherCountry: json['otherCountry'],
    );
  }
  
  /// For backward compatibility
  factory ProducerDetailsModel.fromMap(Map<String, dynamic> map) => 
      ProducerDetailsModel.fromJson(map);
      
  /// For backward compatibility
  Map<String, dynamic> toMap() => toJson();

  bool get isComplete {
    // Check all required fields are filled
    return gender != null &&
        nationality != null &&
        yearOfBirth != null &&
        relationshipToRespondent != null &&
        hasBirthCertificate != null &&
        occupation != null &&
        // If non-Ghanaian, country must be specified
        (nationality != 'non_ghanaian' || selectedCountry != null) &&
        // Ghana card question must be answered
        _isGhanaCardComplete &&
        // Consent question must be answered if applicable
        _isConsentComplete;
  }

  bool get _isGhanaCardComplete {
    // Either has Ghana card with ID, or has other ID type specified
    if (ghanaCardId != null && ghanaCardId!.isNotEmpty) {
      return true; // Has Ghana card with ID
    }
    if (otherIdType != null && otherIdType != 'none') {
      return otherIdNumber != null && otherIdNumber!.isNotEmpty;
    }
    if (otherIdType == 'none') {
      return true; // Explicitly selected "None"
    }
    return false; // Ghana card question not properly answered
  }

  bool get _isConsentComplete {
    // Consent question only required if they have an ID type (not 'none')
    final hasValidId = (ghanaCardId != null && ghanaCardId!.isNotEmpty) ||
        (otherIdType != null && otherIdType != 'none');

    if (!hasValidId) {
      return true; // No ID required, so consent not needed
    }

    // If they have a valid ID, consent must be specified
    if (consentToTakePhoto == true) {
      return true; // Consent given
    }
    if (consentToTakePhoto == false) {
      return noConsentReason != null && noConsentReason!.isNotEmpty;
    }
    return false; // Consent question not answered
  }

  @override
  String toString() {
    return 'ProducerDetailsModel(gender: $gender, nationality: $nationality, yearOfBirth: $yearOfBirth, selectedCountry: $selectedCountry, ghanaCardId: $ghanaCardId, otherIdType: $otherIdType, otherIdNumber: $otherIdNumber, consentToTakePhoto: $consentToTakePhoto, noConsentReason: $noConsentReason, idPhotoPath: $idPhotoPath, relationshipToRespondent: $relationshipToRespondent, otherRelationship: $otherRelationship, hasBirthCertificate: $hasBirthCertificate, occupation: $occupation, otherOccupation: $otherOccupation, otherCountry: $otherCountry)';
  }
}
