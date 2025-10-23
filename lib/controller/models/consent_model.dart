import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Model for Consent Page data
class ConsentData {
  final String? communityType;
  final String? residesInCommunityConsent;
  final String? farmerAvailable;
  final String? farmerStatus;
  final String? availablePerson;
  final String? otherSpecification;
  final String? otherCommunityName;
  final bool consentGiven;
  final TextEditingController otherSpecController;
  final TextEditingController otherCommunityController;

  // Survey state fields
  final DateTime? interviewStartTime;
  final String timeStatus;
  final Position? currentPosition;
  final String locationStatus;
  final bool isGettingLocation;

  const ConsentData({
    this.communityType,
    this.residesInCommunityConsent,
    this.farmerAvailable,
    this.farmerStatus,
    this.availablePerson,
    this.otherSpecification,
    this.otherCommunityName,
    this.consentGiven = false,
    required this.otherSpecController,
    required this.otherCommunityController,
    this.interviewStartTime,
    this.timeStatus = 'Not recorded',
    this.currentPosition,
    this.locationStatus = 'Not recorded',
    this.isGettingLocation = false,
  });

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'communityType': communityType,
      'residesInCommunityConsent': residesInCommunityConsent,
      'farmerAvailable': farmerAvailable,
      'farmerStatus': farmerStatus,
      'availablePerson': availablePerson,
      'otherSpecification': otherSpecification,
      'otherCommunityName': otherCommunityName,
      'consentGiven': consentGiven,
      'interviewStartTime': interviewStartTime?.toIso8601String(),
      'timeStatus': timeStatus,
      'currentPosition': currentPosition != null
          ? {
              'latitude': currentPosition!.latitude,
              'longitude': currentPosition!.longitude,
            }
          : null,
      'locationStatus': locationStatus,
      'isGettingLocation': isGettingLocation,
    };
  }

  /// Create from Map from storage
  factory ConsentData.fromMap(Map<String, dynamic> map) {
    return ConsentData(
      communityType: map['communityType']?.toString(),
      residesInCommunityConsent: map['residesInCommunityConsent']?.toString(),
      farmerAvailable: map['farmerAvailable']?.toString(),
      farmerStatus: map['farmerStatus']?.toString(),
      availablePerson: map['availablePerson']?.toString(),
      otherSpecification: map['otherSpecification']?.toString(),
      otherCommunityName: map['otherCommunityName']?.toString(),
      consentGiven: map['consentGiven'] == true,
      otherSpecController: TextEditingController(
        text: map['otherSpecification']?.toString() ?? '',
      ),
      otherCommunityController: TextEditingController(
        text: map['otherCommunityName']?.toString() ?? '',
      ),
      interviewStartTime: map['interviewStartTime'] != null
          ? DateTime.parse(map['interviewStartTime'] as String)
          : null,
      timeStatus: map['timeStatus']?.toString() ?? 'Not recorded',
      currentPosition: map['currentPosition'] != null
          ? Position(
              longitude: (map['currentPosition'] as Map)['longitude'] ?? 0.0,
              latitude: (map['currentPosition'] as Map)['latitude'] ?? 0.0,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0,
            )
          : null,
      locationStatus: map['locationStatus']?.toString() ?? 'Not recorded',
      isGettingLocation: map['isGettingLocation'] == true,
    );
  }

  /// Create empty instance
  factory ConsentData.empty() {
    return ConsentData(
      otherSpecController: TextEditingController(),
      otherCommunityController: TextEditingController(),
    );
  }

  /// Copy with method for immutability
  ConsentData copyWith({
    String? communityType,
    String? residesInCommunityConsent,
    String? farmerAvailable,
    String? farmerStatus,
    String? availablePerson,
    String? otherSpecification,
    String? otherCommunityName,
    bool? consentGiven,
    TextEditingController? otherSpecController,
    TextEditingController? otherCommunityController,
    DateTime? interviewStartTime,
    String? timeStatus,
    Position? currentPosition,
    String? locationStatus,
    bool? isGettingLocation,
  }) {
    return ConsentData(
      communityType: communityType ?? this.communityType,
      residesInCommunityConsent:
          residesInCommunityConsent ?? this.residesInCommunityConsent,
      farmerAvailable: farmerAvailable ?? this.farmerAvailable,
      farmerStatus: farmerStatus ?? this.farmerStatus,
      availablePerson: availablePerson ?? this.availablePerson,
      otherSpecification: otherSpecification ?? this.otherSpecification,
      otherCommunityName: otherCommunityName ?? this.otherCommunityName,
      consentGiven: consentGiven ?? this.consentGiven,
      otherSpecController: otherSpecController ?? this.otherSpecController,
      otherCommunityController:
          otherCommunityController ?? this.otherCommunityController,
      interviewStartTime: interviewStartTime ?? this.interviewStartTime,
      timeStatus: timeStatus ?? this.timeStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      locationStatus: locationStatus ?? this.locationStatus,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
    );
  }

  /// Update community type
  ConsentData updateCommunityType(String? value) {
    return copyWith(communityType: value);
  }

  /// Update resides in community consent
  ConsentData updateResidesInCommunity(String? value) {
    return copyWith(residesInCommunityConsent: value);
  }

  /// Update farmer availability
  ConsentData updateFarmerAvailable(String? value) {
    return copyWith(farmerAvailable: value);
  }

  /// Update farmer status
  ConsentData updateFarmerStatus(String? value) {
    return copyWith(farmerStatus: value);
  }

  /// Update available person
  ConsentData updateAvailablePerson(String? value) {
    return copyWith(availablePerson: value);
  }

  /// Update consent
  ConsentData updateConsent(bool value) {
    return copyWith(consentGiven: value);
  }

  /// Update other specification
  ConsentData updateOtherSpecification(String value) {
    return copyWith(
      otherSpecification: value,
      otherSpecController: TextEditingController(text: value),
    );
  }

  /// Update other community name
  ConsentData updateOtherCommunityName(String value) {
    return copyWith(
      otherCommunityName: value,
      otherCommunityController: TextEditingController(text: value),
    );
  }

  /// Update survey state
  ConsentData updateSurveyState({
    DateTime? interviewStartTime,
    String? timeStatus,
    Position? currentPosition,
    String? locationStatus,
    bool? isGettingLocation,
  }) {
    return copyWith(
      interviewStartTime: interviewStartTime,
      timeStatus: timeStatus,
      currentPosition: currentPosition,
      locationStatus: locationStatus,
      isGettingLocation: isGettingLocation,
    );
  }

  /// Check if consent section should be shown
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

  /// Check if survey should end
  bool get shouldEndSurvey {
    return !consentGiven ||
        farmerStatus == 'Deceased' ||
        farmerStatus == 'Doesn\'t work with TOUTON anymore' ||
        availablePerson == 'Nobody';
  }

  /// Validate required fields
  Map<String, String> validate() {
    final errors = <String, String>{};

    if (communityType == null) {
      errors['communityType'] = 'Please select community type';
    }

    if (residesInCommunityConsent == null) {
      errors['residesInCommunity'] =
          'Please specify if farmer resides in community';
    }

    if (farmerAvailable == null) {
      errors['farmerAvailable'] = 'Please specify if farmer is available';
    }

    if (farmerAvailable == 'No' && farmerStatus == null) {
      errors['farmerStatus'] = 'Please specify farmer status';
    }

    if (farmerStatus == 'Other' &&
        (otherSpecification == null || otherSpecification!.isEmpty)) {
      errors['otherSpecification'] = 'Please specify farmer status';
    }

    if ((farmerStatus == 'Non-resident' || farmerStatus == 'Other') &&
        availablePerson == null) {
      errors['availablePerson'] = 'Please specify available person';
    }

    if (residesInCommunityConsent == 'No' &&
        (otherCommunityName == null || otherCommunityName!.isEmpty)) {
      errors['otherCommunity'] = 'Please specify community name';
    }

    if (shouldShowConsentSection) {
      if (!consentGiven && (otherSpecification?.isEmpty ?? true)) {
        errors['consent'] = 'Please provide reason for refusal';
      }
    }

    return errors;
  }

  /// Check if form is complete
  bool get isComplete {
    return validate().isEmpty;
  }

  /// Get summary for display
  Map<String, String> get summary {
    return {
      'Community Type': communityType ?? 'Not selected',
      'Resides in Community': residesInCommunityConsent ?? 'Not selected',
      'Farmer Available': farmerAvailable ?? 'Not selected',
      'Farmer Status': farmerStatus ?? 'Not selected',
      'Available Person': availablePerson ?? 'Not selected',
      'Consent Given': consentGiven ? 'Yes' : 'No',
      'Other Community': otherCommunityName ?? 'Not specified',
      'Interview Time': timeStatus,
      'Location': locationStatus,
    };
  }

  /// Dispose controllers
  void dispose() {
    otherSpecController.dispose();
    otherCommunityController.dispose();
  }

  @override
  String toString() {
    return 'ConsentData(communityType: $communityType, consentGiven: $consentGiven, farmerAvailable: $farmerAvailable)';
  }
}
