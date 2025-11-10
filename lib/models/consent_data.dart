import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Unified ConsentData model for the application
class ConsentData {
  // Survey timing
  final DateTime? interviewStartTime;
  final String? timeStatus;
  
  // Location data
  final Position? currentPosition;
  final String? locationStatus;
  final bool isGettingLocation;
  
  // Community information
  final String? communityType;
  final String? residesInCommunityConsent;
  final String? otherCommunityName;
  
  // Farmer information
  final String? farmerAvailable;
  final String? farmerStatus;
  final String? availablePerson;
  final String? otherSpecification;
  
  // Consent information
  final bool consentGiven;
  final bool declinedConsent;
  final String? refusalReason;
  final DateTime? consentTimestamp;

  // Controllers (for form handling)
  final TextEditingController? otherSpecController;
  final TextEditingController? otherCommunityController;
  final TextEditingController? refusalReasonController;

  const ConsentData({
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
    this.otherSpecController,
    this.otherCommunityController,
    this.refusalReasonController,
  });

  // Copy with method for immutable updates
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
    TextEditingController? otherSpecController,
    TextEditingController? otherCommunityController,
    TextEditingController? refusalReasonController,
  }) {
    return ConsentData(
      interviewStartTime: interviewStartTime ?? this.interviewStartTime,
      timeStatus: timeStatus ?? this.timeStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      locationStatus: locationStatus ?? this.locationStatus,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      communityType: communityType ?? this.communityType,
      residesInCommunityConsent: residesInCommunityConsent ?? this.residesInCommunityConsent,
      otherCommunityName: otherCommunityName ?? this.otherCommunityName,
      farmerAvailable: farmerAvailable ?? this.farmerAvailable,
      farmerStatus: farmerStatus ?? this.farmerStatus,
      availablePerson: availablePerson ?? this.availablePerson,
      otherSpecification: otherSpecification ?? this.otherSpecification,
      consentGiven: consentGiven ?? this.consentGiven,
      declinedConsent: declinedConsent ?? this.declinedConsent,
      refusalReason: refusalReason ?? this.refusalReason,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,
      otherSpecController: otherSpecController ?? this.otherSpecController,
      otherCommunityController: otherCommunityController ?? this.otherCommunityController,
      refusalReasonController: refusalReasonController ?? this.refusalReasonController,
    );
  }

  // Convert to map for database operations
  Map<String, dynamic> toMap() {
    final now = DateTime.now().toIso8601String();
    return {
      'interview_start_time': interviewStartTime?.toIso8601String(),
      'time_status': timeStatus,
      'current_position_lat': currentPosition?.latitude,
      'current_position_lng': currentPosition?.longitude,
      'location_status': locationStatus,
      'is_getting_location': isGettingLocation ? 1 : 0,
      'community_type': communityType,
      'resides_in_community_consent': residesInCommunityConsent,
      'other_community_name': otherCommunityName,
      'farmer_available': farmerAvailable,
      'farmer_status': farmerStatus,
      'available_person': availablePerson,
      'other_specification': otherSpecification,
      'consent_given': consentGiven ? 1 : 0,
      'declined_consent': declinedConsent ? 1 : 0,
      'refusal_reason': refusalReason,
      'consent_timestamp': consentTimestamp?.toIso8601String(),
      // Add required timestamp fields
      'created_at': now,
      'updated_at': now,
      'is_synced': 0,
    };
  }

  // Create from map (from database)
  factory ConsentData.fromMap(Map<String, dynamic> map) {
    return ConsentData(
      interviewStartTime: map['interview_start_time'] != null 
          ? DateTime.parse(map['interview_start_time']) 
          : null,
      timeStatus: map['time_status'],
      currentPosition: map['current_position_lat'] != null && map['current_position_lng'] != null
          ? Position(
              latitude: map['current_position_lat'],
              longitude: map['current_position_lng'],
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            )
          : null,
      locationStatus: map['location_status'],
      isGettingLocation: map['is_getting_location'] == 1,
      communityType: map['community_type'],
      residesInCommunityConsent: map['resides_in_community_consent'],
      otherCommunityName: map['other_community_name'],
      farmerAvailable: map['farmer_available'],
      farmerStatus: map['farmer_status'],
      availablePerson: map['available_person'],
      otherSpecification: map['other_specification'],
      consentGiven: map['consent_given'] == 1,
      declinedConsent: map['declined_consent'] == 1,
      refusalReason: map['refusal_reason'],
      consentTimestamp: map['consent_timestamp'] != null 
          ? DateTime.parse(map['consent_timestamp']) 
          : null,
      // Controllers are typically not stored in the database
      otherSpecController: null,
      otherCommunityController: null,
      refusalReasonController: null,
    );
  }
}
