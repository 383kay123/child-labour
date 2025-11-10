import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart' show required;

/// Model for Consent Page data
class ConsentData {
  final int? id;
  String? communityType;
  final String? residesInCommunityConsent;
  final String? farmerAvailable;
  final String? farmerStatus;
  final String? availablePerson;
  final String? otherSpecification;
  final String? otherCommunityName;
  final String? refusalReason;
  final bool? consentGiven;
  final bool? declinedConsent;
  final DateTime? consentTimestamp;
  final TextEditingController otherSpecController;
  final TextEditingController otherCommunityController;
  final TextEditingController refusalReasonController;

  // Survey state fields
  final DateTime? interviewStartTime;
  final String? timeStatus;
  final Position? currentPosition;
  final String? locationStatus;
  final bool? isGettingLocation;

  ConsentData({
    this.id,
    this.communityType,
    this.residesInCommunityConsent,
    this.farmerAvailable,
    this.farmerStatus,
    this.availablePerson,
    this.otherSpecification,
    this.otherCommunityName,
    this.consentGiven,
    this.declinedConsent,
    this.refusalReason,
    this.consentTimestamp,
    required this.otherSpecController,
    required this.otherCommunityController,
    required this.refusalReasonController,
    this.interviewStartTime,
    this.timeStatus,
    this.currentPosition,
    this.locationStatus,
    this.isGettingLocation,
  });

  // Create a copyWith method to update fields
  ConsentData copyWith({
    int? id,
    String? communityType,
    String? residesInCommunityConsent,
    String? farmerAvailable,
    String? farmerStatus,
    String? availablePerson,
    String? otherSpecification,
    String? otherCommunityName,
    bool? consentGiven,
    bool? declinedConsent,
    String? refusalReason,
    DateTime? consentTimestamp,
    TextEditingController? otherSpecController,
    TextEditingController? otherCommunityController,
    TextEditingController? refusalReasonController,
    DateTime? interviewStartTime,
    String? timeStatus,
    Position? currentPosition,
    String? locationStatus,
    bool? isGettingLocation,
  }) {
    return ConsentData(
      id: id ?? this.id,
      communityType: communityType ?? this.communityType,
      residesInCommunityConsent: residesInCommunityConsent ?? this.residesInCommunityConsent,
      farmerAvailable: farmerAvailable ?? this.farmerAvailable,
      farmerStatus: farmerStatus ?? this.farmerStatus,
      availablePerson: availablePerson ?? this.availablePerson,
      otherSpecification: otherSpecification ?? this.otherSpecification,
      otherCommunityName: otherCommunityName ?? this.otherCommunityName,
      consentGiven: consentGiven ?? this.consentGiven,
      declinedConsent: declinedConsent ?? this.declinedConsent,
      refusalReason: refusalReason ?? this.refusalReason,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,
      otherSpecController: otherSpecController ?? this.otherSpecController,
      otherCommunityController: otherCommunityController ?? this.otherCommunityController,
      refusalReasonController: refusalReasonController ?? this.refusalReasonController,
      interviewStartTime: interviewStartTime ?? this.interviewStartTime,
      timeStatus: timeStatus ?? this.timeStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      locationStatus: locationStatus ?? this.locationStatus,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'communityType': communityType,
      'residesInCommunityConsent': residesInCommunityConsent,
      'farmerAvailable': farmerAvailable,
      'farmerStatus': farmerStatus,
      'availablePerson': availablePerson,
      'otherSpecification': otherSpecification,
      'otherCommunityName': otherCommunityName,
      'refusalReason': refusalReason,
      'consentGiven': consentGiven == true ? 1 : 0, // Convert bool to int for SQLite
      'declinedConsent': declinedConsent == true ? 1 : 0, // Convert bool to int for SQLite
      'consentTimestamp': consentTimestamp?.toIso8601String(),
      'interviewStartTime': interviewStartTime?.toIso8601String(),
      'timeStatus': timeStatus,
      'currentPosition': currentPosition != null
          ? jsonEncode({
              'latitude': currentPosition!.latitude,
              'longitude': currentPosition!.longitude,
              'timestamp': currentPosition!.timestamp?.toIso8601String(),
            })
          : null,
      'locationStatus': locationStatus,
      'isGettingLocation': isGettingLocation == true ? 1 : 0, // Convert bool to int for SQLite
    };
  }

  /// Create from Map from storage
  factory ConsentData.fromMap(Map<String, dynamic> map) {
    // Parse position if it exists
    Position? position;
    if (map['currentPosition'] != null) {
      try {
        final positionData = jsonDecode(map['currentPosition']);
        position = Position(
          latitude: positionData['latitude'] ?? 0.0,
          longitude: positionData['longitude'] ?? 0.0,
          timestamp: positionData['timestamp'] != null 
              ? DateTime.parse(positionData['timestamp']) 
              : DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      } catch (e) {
        debugPrint('Error parsing position data: $e');
      }
    }

    return ConsentData(
      id: map['id'] as int?,
      communityType: map['communityType']?.toString(),
      residesInCommunityConsent: map['residesInCommunityConsent']?.toString(),
      farmerAvailable: map['farmerAvailable']?.toString(),
      farmerStatus: map['farmerStatus']?.toString(),
      availablePerson: map['availablePerson']?.toString(),
      otherSpecification: map['otherSpecification']?.toString(),
      otherCommunityName: map['otherCommunityName']?.toString(),
      consentGiven: map['consentGiven'] == 1, // Convert int back to bool
      declinedConsent: map['declinedConsent'] == 1, // Convert int back to bool
      refusalReason: map['refusalReason']?.toString(),
      consentTimestamp: map['consentTimestamp'] != null 
          ? DateTime.tryParse(map['consentTimestamp'] as String)
          : null,
      otherSpecController: TextEditingController(
        text: map['otherSpecification']?.toString() ?? '',
      ),
      otherCommunityController: TextEditingController(
        text: map['otherCommunityName']?.toString() ?? '',
      ),
      refusalReasonController: TextEditingController(
        text: map['refusalReason']?.toString() ?? '',
      ),
      interviewStartTime: map['interviewStartTime'] != null
          ? DateTime.tryParse(map['interviewStartTime'] as String)
          : null,
      timeStatus: map['timeStatus']?.toString() ?? 'Not recorded',
      currentPosition: position,
      locationStatus: map['locationStatus']?.toString() ?? 'Not recorded',
      isGettingLocation: map['isGettingLocation'] == 1, // Convert int back to bool
    );
  }

  /// Create empty instance
  factory ConsentData.empty() {
    return ConsentData(
      id: null,
      otherSpecController: TextEditingController(),
      otherCommunityController: TextEditingController(),
      refusalReasonController: TextEditingController(),
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
    return copyWith(
      consentGiven: value,
      declinedConsent: value ? false : declinedConsent, // Reset declinedConsent if giving consent
    );
  }

  /// Update declined consent
  ConsentData updateDeclinedConsent(bool value) {
    return copyWith(
      declinedConsent: value,
      consentGiven: value ? false : consentGiven, // Reset consentGiven if declining
    );
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
    return consentGiven != true ||  // Handles null by treating it as false
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
      if (consentGiven == false && (otherSpecification?.isEmpty ?? true)) {
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
      'Consent Given': consentGiven == true ? 'Yes' : 'No',
      'Other Community': otherCommunityName ?? 'Not specified',
      'Interview Time': timeStatus ?? 'Not available',
      'Location': locationStatus ?? 'Not available',
    };
  }

  /// Dispose controllers
  void dispose() {
    otherSpecController.dispose();
    otherCommunityController.dispose();
    refusalReasonController.dispose();
  }

  @override
  String toString() {
    return 'ConsentData(communityType: $communityType, consentGiven: $consentGiven, declinedConsent: $declinedConsent, farmerAvailable: $farmerAvailable, refusalReason: $refusalReason)';
  }
}
