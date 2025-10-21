import 'package:geolocator/geolocator.dart';

/// Model class representing the consent data collected in the consent page.
class ConsentModel {
  final DateTime? interviewStartTime;
  final String timeStatus;
  final Position? currentPosition;
  final String locationStatus;
  final bool isGettingLocation;
  final String? communityType;
  final String? residesInCommunityConsent;
  final String? farmerAvailable;
  final String? farmerStatus;
  final String? availablePerson;
  final String? otherSpecification;
  final String? otherCommunityName;
  final bool consentGiven;
  final String? refusalReason;
  final DateTime? consentTimestamp;

  /// Private constructor for the model
  const ConsentModel({
    this.interviewStartTime,
    this.timeStatus = '',
    this.currentPosition,
    this.locationStatus = '',
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
  });

  /// Creates a copy of the model with the given fields replaced with the new values.
  ConsentModel copyWith({
    DateTime? interviewStartTime,
    String? timeStatus,
    Position? currentPosition,
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
  }) {
    return ConsentModel(
      interviewStartTime: interviewStartTime ?? this.interviewStartTime,
      timeStatus: timeStatus ?? this.timeStatus,
      currentPosition: currentPosition ?? this.currentPosition,
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
    );
  }

  /// Creates a map from the model for JSON serialization.
  Map<String, dynamic> toMap() {
    return {
      'interviewStartTime': interviewStartTime?.toIso8601String(),
      'timeStatus': timeStatus,
      'latitude': currentPosition?.latitude,
      'longitude': currentPosition?.longitude,
      'locationStatus': locationStatus,
      'isGettingLocation': isGettingLocation,
      'communityType': communityType,
      'residesInCommunityConsent': residesInCommunityConsent,
      'farmerAvailable': farmerAvailable,
      'farmerStatus': farmerStatus,
      'availablePerson': availablePerson,
      'otherSpecification': otherSpecification,
      'otherCommunityName': otherCommunityName,
      'consentGiven': consentGiven,
      'refusalReason': refusalReason,
      'consentTimestamp': consentTimestamp?.toIso8601String(),
    };
  }

  /// Creates a model from a map (for JSON deserialization).
  factory ConsentModel.fromMap(Map<String, dynamic> map) {
    return ConsentModel(
      interviewStartTime: map['interviewStartTime'] != null
          ? DateTime.parse(map['interviewStartTime'])
          : null,
      timeStatus: map['timeStatus'] ?? '',
      currentPosition: (map['latitude'] != null && map['longitude'] != null)
          ? Position(
              latitude: map['latitude'],
              longitude: map['longitude'],
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
      locationStatus: map['locationStatus'] ?? '',
      isGettingLocation: map['isGettingLocation'] ?? false,
      communityType: map['communityType'],
      residesInCommunityConsent: map['residesInCommunityConsent'],
      farmerAvailable: map['farmerAvailable'],
      farmerStatus: map['farmerStatus'],
      availablePerson: map['availablePerson'],
      otherSpecification: map['otherSpecification'],
      otherCommunityName: map['otherCommunityName'],
      consentGiven: map['consentGiven'] ?? false,
      refusalReason: map['refusalReason'],
      consentTimestamp: map['consentTimestamp'] != null
          ? DateTime.parse(map['consentTimestamp'])
          : null,
    );
  }
}
