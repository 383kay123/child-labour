import 'package:flutter/material.dart';

class VisitInformationData {
  // Basic visit information
  final String? location;
  final String? gpsCoordinates;
  
  // Respondent information
  final bool? respondentNameCorrect;
  final String? correctedRespondentName;
  final String? respondentOtherNames;
  final String? respondentNationality;
  final String? countryOfOrigin;
  final String? otherCountry;
  
  // Farm ownership information
  final bool? isFarmOwner;
  final String? farmOwnershipType;

  const VisitInformationData({
    this.location,
    this.gpsCoordinates,
    this.respondentNameCorrect,
    this.correctedRespondentName,
    this.respondentOtherNames,
    this.respondentNationality,
    this.countryOfOrigin,
    this.otherCountry,
    this.isFarmOwner,
    this.farmOwnershipType,
  });

  // Empty instance
  static const VisitInformationData empty = VisitInformationData();

  // Check if the instance has valid data (not empty)
  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  // Validate all required fields (adjust based on your requirements)
  bool get isValid => location?.isNotEmpty == true;

  // Factory method to create from TimeOfDay
  factory VisitInformationData.withTime({
    String? visitDate,
    TimeOfDay? visitTime,
    String? interviewerName,
    String? interviewerId,
    String? supervisorName,
    String? supervisorId,
    String? location,
    String? gpsCoordinates,
    bool? respondentNameCorrect,
    String? correctedRespondentName,
    String? respondentOtherNames,
    String? respondentNationality,
    String? countryOfOrigin,
    String? otherCountry,
    bool? isFarmOwner,
    String? farmOwnershipType,
  }) {
    return VisitInformationData(
     
      location: location,
      gpsCoordinates: gpsCoordinates,
      respondentNameCorrect: respondentNameCorrect,
      correctedRespondentName: correctedRespondentName,
      respondentOtherNames: respondentOtherNames,
      respondentNationality: respondentNationality,
      countryOfOrigin: countryOfOrigin,
      otherCountry: otherCountry,
      isFarmOwner: isFarmOwner,
      farmOwnershipType: farmOwnershipType,
    );
  }

  
  VisitInformationData copyWith({
    String? location,
    String? gpsCoordinates,
    bool? respondentNameCorrect,
    String? correctedRespondentName,
    String? respondentOtherNames,
    String? respondentNationality,
    String? countryOfOrigin,
    String? otherCountry,
    bool? isFarmOwner,
    String? farmOwnershipType,
  }) {
    return VisitInformationData(
      location: location ?? this.location,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      respondentNameCorrect: respondentNameCorrect ?? this.respondentNameCorrect,
      correctedRespondentName: correctedRespondentName ?? this.correctedRespondentName,
      respondentOtherNames: respondentOtherNames ?? this.respondentOtherNames,
      respondentNationality: respondentNationality ?? this.respondentNationality,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      otherCountry: otherCountry ?? this.otherCountry,
      isFarmOwner: isFarmOwner ?? this.isFarmOwner,
      farmOwnershipType: farmOwnershipType ?? this.farmOwnershipType,
    );
  }
  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'gpsCoordinates': gpsCoordinates,
      'respondentNameCorrect': respondentNameCorrect == true ? 1 : 0,
      'correctedRespondentName': correctedRespondentName,
      'respondentOtherNames': respondentOtherNames,
      'respondentNationality': respondentNationality,
      'countryOfOrigin': countryOfOrigin,
      'otherCountry': otherCountry,
      'isFarmOwner': isFarmOwner == true ? 1 : 0,
      'farmOwnershipType': farmOwnershipType,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  // Create from Map for database operations
  factory VisitInformationData.fromMap(Map<String, dynamic> map) {
    return VisitInformationData(
      location: map['location']?.toString(),
      gpsCoordinates: map['gpsCoordinates']?.toString(),
      respondentNameCorrect: map['respondentNameCorrect'] == 1,
      correctedRespondentName: map['correctedRespondentName']?.toString(),
      respondentOtherNames: map['respondentOtherNames']?.toString(),
      respondentNationality: map['respondentNationality']?.toString(),
      countryOfOrigin: map['countryOfOrigin']?.toString(),
      otherCountry: map['otherCountry']?.toString(),
      isFarmOwner: map['isFarmOwner'] == 1,
      farmOwnershipType: map['farmOwnershipType']?.toString(),
    );
  }

  // Create from JSON
  factory VisitInformationData.fromJson(Map<String, dynamic> json) => 
      VisitInformationData.fromMap(json);

  @override
  String toString() {
    return 'VisitInformationData('
     
        'location: $location, '
        'gpsCoordinates: $gpsCoordinates, '
        'respondentNameCorrect: $respondentNameCorrect, '
        'correctedRespondentName: $correctedRespondentName, '
        'respondentOtherNames: $respondentOtherNames, '
        'respondentNationality: $respondentNationality, '
        'countryOfOrigin: $countryOfOrigin, '
        'otherCountry: $otherCountry, '
        'isFarmOwner: $isFarmOwner, '
        'farmOwnershipType: $farmOwnershipType'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VisitInformationData &&
        other.location == location &&
        other.gpsCoordinates == gpsCoordinates &&
        other.respondentNameCorrect == respondentNameCorrect &&
        other.correctedRespondentName == correctedRespondentName &&
        other.respondentOtherNames == respondentOtherNames &&
        other.respondentNationality == respondentNationality &&
        other.countryOfOrigin == countryOfOrigin &&
        other.otherCountry == otherCountry &&
        other.isFarmOwner == isFarmOwner &&
        other.farmOwnershipType == farmOwnershipType;
  }

  @override
  int get hashCode {
    return Object.hash(
      location,
      gpsCoordinates,
      respondentNameCorrect,
      correctedRespondentName,
      respondentOtherNames,
      respondentNationality,
      countryOfOrigin,
      otherCountry,
      isFarmOwner,
      farmOwnershipType,
    );
  }
}