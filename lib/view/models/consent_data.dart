import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Represents the consent data collected during the survey
class ConsentData {
  final DateTime? interviewStartTime;
  final String? timeStatus;
  final Position? currentPosition;
  final String? locationStatus;
  final bool isGettingLocation;
  final String? communityType;
  final String? residesInCommunityConsent;
  final String? otherCommunityName;
  final String? farmerAvailable;
  final String? farmerStatus;
  final String? availablePerson;
  final String? otherSpecification;
  final bool consentGiven;
  final bool declinedConsent;
  final String? refusalReason;
  final DateTime? consentTimestamp;
  final TextEditingController otherSpecController;
  final TextEditingController otherCommunityController;
  final TextEditingController refusalReasonController;

  ConsentData({
  this.interviewStartTime,
  this.timeStatus,
  this.currentPosition,
  this.locationStatus,
  this.isGettingLocation = false,
  this.communityType,
  this.residesInCommunityConsent,
  this.otherCommunityName,
  this.farmerAvailable,
  this.farmerStatus,
  this.availablePerson,
  this.otherSpecification,
  this.consentGiven = false,
  this.declinedConsent = false,
  this.refusalReason,
  this.consentTimestamp,
  TextEditingController? otherSpecController,
  TextEditingController? otherCommunityController,
  TextEditingController? refusalReasonController,
}) : 
  otherSpecController = otherSpecController ?? TextEditingController(text: otherSpecification),
  otherCommunityController = otherCommunityController ?? TextEditingController(text: otherCommunityName),
  refusalReasonController = refusalReasonController ?? TextEditingController(text: refusalReason);

  /// Creates a copy of this ConsentData with the given fields replaced by the new values
  ConsentData copyWith({
    DateTime? interviewStartTime,
    String? timeStatus,
    Position? currentPosition,
    String? locationStatus,
    bool? isGettingLocation,
    String? communityType,
    String? residesInCommunityConsent,
    String? otherCommunityName,
    String? farmerAvailable,
    String? farmerStatus,
    String? availablePerson,
    String? otherSpecification,
    bool? consentGiven,
    bool? declinedConsent,
    String? refusalReason,
    DateTime? consentTimestamp,
  }) {
    return ConsentData(
      interviewStartTime: interviewStartTime ?? this.interviewStartTime,
      timeStatus: timeStatus ?? this.timeStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      locationStatus: locationStatus ?? this.locationStatus,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      communityType: communityType ?? this.communityType,
      residesInCommunityConsent: 
          residesInCommunityConsent ?? this.residesInCommunityConsent,
      otherCommunityName: otherCommunityName ?? this.otherCommunityName,
      farmerAvailable: farmerAvailable ?? this.farmerAvailable,
      farmerStatus: farmerStatus ?? this.farmerStatus,
      availablePerson: availablePerson ?? this.availablePerson,
      otherSpecification: otherSpecification ?? this.otherSpecification,
      consentGiven: consentGiven ?? this.consentGiven,
      declinedConsent: declinedConsent ?? this.declinedConsent,
      refusalReason: refusalReason ?? this.refusalReason,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,
    );
  }

  @override
  String toString() {
    return 'ConsentData(\n'
        '  interviewStartTime: $interviewStartTime,\n'
        '  timeStatus: $timeStatus,\n'
        '  currentPosition: $currentPosition,\n'
        '  locationStatus: $locationStatus,\n'
        '  isGettingLocation: $isGettingLocation,\n'
        '  communityType: $communityType,\n'
        '  residesInCommunityConsent: $residesInCommunityConsent,\n'
        '  otherCommunityName: $otherCommunityName,\n'
        '  farmerAvailable: $farmerAvailable,\n'
        '  farmerStatus: $farmerStatus,\n'
        '  availablePerson: $availablePerson,\n'
        '  otherSpecification: $otherSpecification,\n'
        '  consentGiven: $consentGiven,\n'
        '  declinedConsent: $declinedConsent,\n'
        '  refusalReason: $refusalReason,\n'
        '  consentTimestamp: $consentTimestamp,\n'
        ')';
  }
}
