import 'dart:convert';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/adult_info_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/identification_of_owner_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/visit_information_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/workers_in_farm_model.dart';
import 'package:meta/meta.dart' show required;

import '../../data/dummy_data/cover_dummy_data.dart';
import 'dropdown_item_model.dart';

export 'dropdown_item_model.dart';

class CoverPageData {
  /// Database ID
  final int? id;
  
  /// Sync status (0 = not synced, 1 = synced)
  final int isSynced;
  
  /// Last update timestamp
  final DateTime? updatedAt;

  /// Creates an empty CoverPageData instance with default values
  factory CoverPageData.empty() => CoverPageData(
        id: null,
        selectedTownCode: null,
        selectedFarmerCode: null,
        towns: CoverDummyData.dummyTowns, // Use dummy towns data
        farmers: const [], // Start with empty farmers list
        townError: null,
        farmerError: null,
        isLoadingTowns: false,
        isLoadingFarmers: false,
        hasUnsavedChanges: false,
        member: null,
        isSynced: 0, // Default to not synced
        updatedAt: null,
      );
      
  /// Creates a CoverPageData from a database map
  factory CoverPageData.fromMap(Map<String, dynamic> map) {
    List<DropdownItem> parseTowns(String? jsonString) {
      if (jsonString == null || jsonString.isEmpty) return [];
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((item) => DropdownItem.fromMap(Map<String, dynamic>.from(item))).toList();
      } catch (e) {
        debugPrint('Error parsing towns: $e');
        return [];
      }
    }

    List<DropdownItem> parseFarmers(String? jsonString) {
      if (jsonString == null || jsonString.isEmpty) return [];
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((item) => DropdownItem.fromMap(Map<String, dynamic>.from(item))).toList();
      } catch (e) {
        debugPrint('Error parsing farmers: $e');
        return [];
      }
    }

    return CoverPageData(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? '0'),
      selectedTownCode: map['selectedTownCode']?.toString(),
      selectedFarmerCode: map['selectedFarmerCode']?.toString(),
      towns: map['towns'] is String ? parseTowns(map['towns']) : 
             (map['towns'] is List ? (map['towns'] as List).map((item) => DropdownItem.fromMap(Map<String, dynamic>.from(item))).toList() : []),
      farmers: map['farmers'] is String ? parseFarmers(map['farmers']) : 
              (map['farmers'] is List ? (map['farmers'] as List).map((item) => DropdownItem.fromMap(Map<String, dynamic>.from(item))).toList() : []),
      townError: map['townError']?.toString(),
      farmerError: map['farmerError']?.toString(),
      isLoadingTowns: map['isLoadingTowns'] == 1 || map['isLoadingTowns'] == true,
      isLoadingFarmers: map['isLoadingFarmers'] == 1 || map['isLoadingFarmers'] == true,
      hasUnsavedChanges: map['hasUnsavedChanges'] == 1 || map['hasUnsavedChanges'] == true,
      member: map['member'] != null ? (map['member'] is Map ? Map<String, dynamic>.from(map['member']) : null) : null,
    );
  }

  /// Creates a CoverPageData instance with empty data
  factory CoverPageData.test() {
    return CoverPageData.empty();
  }

  String? _selectedTownCode;
  String? _selectedFarmerCode;
  List<DropdownItem> _towns;
  List<DropdownItem> _farmers;
  String? _townError;
  String? _farmerError;
  bool _isLoadingTowns;
  bool _isLoadingFarmers;
  bool hasUnsavedChanges;

  /// Household member information
  final Map<String, dynamic>? member;

  String? get selectedTownCode => _selectedTownCode;
  String? get selectedFarmerCode => _selectedFarmerCode;
  List<DropdownItem> get towns => List.unmodifiable(_towns);
  List<DropdownItem> get farmers => List.unmodifiable(_farmers);
  String? get townError => _townError;
  String? get farmerError => _farmerError;
  bool get isLoadingTowns => _isLoadingTowns;
  bool get isLoadingFarmers => _isLoadingFarmers;
  bool get isComplete {
    final complete = _selectedTownCode != null && _selectedFarmerCode != null;
    if (!complete) {
      debugPrint('❌ Validation failed:');
      debugPrint('  - selectedTownCode: $_selectedTownCode');
      debugPrint('  - selectedFarmerCode: $_selectedFarmerCode');
    } else {
      debugPrint('✅ All required fields are complete');
    }
    return complete;
  }

  /// Converts the object to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'selectedTownCode': selectedTownCode,
      'selectedFarmerCode': selectedFarmerCode,
      'towns': jsonEncode(towns.map((item) => item.toMap()).toList()),
      'farmers': jsonEncode(farmers.map((item) => item.toMap()).toList()),
      'townError': townError,
      'farmerError': farmerError,
      'isLoadingTowns': isLoadingTowns ? 1 : 0,
      'isLoadingFarmers': isLoadingFarmers ? 1 : 0,
      'hasUnsavedChanges': hasUnsavedChanges ? 1 : 0,
      'is_synced': isSynced,
      'updated_at': updatedAt?.toIso8601String(),
      'member': member,
    };
  }

  CoverPageData({
    this.id,
    String? selectedTownCode,
    String? selectedFarmerCode,
    List<DropdownItem>? towns,
    List<DropdownItem>? farmers,
    String? townError,
    String? farmerError,
    bool? isLoadingTowns,
    this.member,
    bool? isLoadingFarmers,
    bool? hasUnsavedChanges,
    int? isSynced,
    this.updatedAt,
  })  : _selectedTownCode = selectedTownCode,
        _selectedFarmerCode = selectedFarmerCode,
        _towns = towns ?? [],
        _farmers = farmers ?? [],
        _townError = townError,
        _farmerError = farmerError,
        _isLoadingTowns = isLoadingTowns ?? false,
        _isLoadingFarmers = isLoadingFarmers ?? false,
        hasUnsavedChanges = hasUnsavedChanges ?? false,
        isSynced = isSynced ?? 0;

  /// Update town selection
  CoverPageData selectTown(String? townCode) {
    debugPrint('🔵 selectTown called with: $townCode');
    return copyWith(
      selectedTownCode: townCode,
      selectedFarmerCode: null, // Clear selected farmer when town changes
      hasUnsavedChanges: true,
    );
  }

  /// Update farmer selection
  CoverPageData selectFarmer(String? farmerCode) {
    debugPrint('🟢 selectFarmer called with: $farmerCode');
    return copyWith(
      selectedFarmerCode: farmerCode,
      hasUnsavedChanges: true,
    );
  }

  /// Marks the data as having unsaved changes
  void markAsChanged(bool changed) {
    hasUnsavedChanges = changed;
  }

  /// Create a copy of this CoverPageData with the given fields replaced with the new values
  CoverPageData copyWith({
    int? id,
    String? selectedTownCode,
    String? selectedFarmerCode,
    List<DropdownItem>? towns,
    List<DropdownItem>? farmers,
    String? townError,
    String? farmerError,
    bool? isLoadingTowns,
    bool? isLoadingFarmers,
    bool? hasUnsavedChanges,
    int? isSynced,
    DateTime? updatedAt,
    Map<String, dynamic>? member,
  }) {
    return CoverPageData(
      id: id ?? this.id,
      selectedTownCode: selectedTownCode ?? _selectedTownCode,
      selectedFarmerCode: selectedFarmerCode ?? _selectedFarmerCode,
      towns: towns ?? _towns,
      farmers: farmers ?? _farmers,
      townError: townError ?? _townError,
      farmerError: farmerError ?? _farmerError,
      isLoadingTowns: isLoadingTowns ?? _isLoadingTowns,
      isLoadingFarmers: isLoadingFarmers ?? _isLoadingFarmers,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
      member: member ?? this.member,
    );
  }

  @override
  String toString() {
    return 'CoverPageData(town: $_selectedTownCode, farmer: $_selectedFarmerCode, hasUnsavedChanges: $hasUnsavedChanges)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoverPageData &&
        other._selectedTownCode == _selectedTownCode &&
        other._selectedFarmerCode == _selectedFarmerCode &&
        listEquals(other._towns, _towns) &&
        listEquals(other._farmers, _farmers) &&
        other._townError == _townError &&
        other._farmerError == _farmerError &&
        other._isLoadingTowns == _isLoadingTowns &&
        other._isLoadingFarmers == _isLoadingFarmers &&
        other.hasUnsavedChanges == hasUnsavedChanges;
  }

  @override
  int get hashCode {
    return Object.hash(
      _selectedTownCode,
      _selectedFarmerCode,
      Object.hashAll(_towns),
      Object.hashAll(_farmers),
      _townError,
      _farmerError,
      _isLoadingTowns,
      _isLoadingFarmers,
      hasUnsavedChanges,
    );
  }
}

/// Model for Consent Page data
class ConsentData {
  final int? id;
  final int? coverPageId;
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
    this.coverPageId,
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
    int? coverPageId,
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
      coverPageId: coverPageId ?? this.coverPageId,
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
    final map = <String, dynamic>{
      'id': id,
      'cover_page_id': coverPageId,
      'consent_given': consentGiven == true ? 1 : 0,
      'declined_consent': declinedConsent == true ? 1 : 0,
      'refusal_reason': refusalReason,
      'consent_timestamp': consentTimestamp?.toIso8601String(),
      'community_type': communityType,
      'resides_in_community_consent': residesInCommunityConsent,
      'other_community_name': otherCommunityName,
      'farmer_available': farmerAvailable,
      'farmer_status': farmerStatus,
      'available_person': availablePerson,
      'other_specification': otherSpecification,
      'interview_start_time': interviewStartTime?.toIso8601String(),
      'time_status': timeStatus,
      'current_position_lat': currentPosition?.latitude,
      'current_position_lng': currentPosition?.longitude,
      'location_status': locationStatus,
      'is_getting_location': isGettingLocation == true ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };
    
    // Remove null values to prevent SQL errors
    map.removeWhere((key, value) => value == null);
    return map;
  }

  /// Create from Map from storage
  factory ConsentData.fromMap(Map<String, dynamic> map) {
    try {
      debugPrint('🔍 Parsing ConsentData from map: $map');
      
      // Parse cover page ID if it exists
      final int? coverPageId = map['cover_page_id'] is int 
          ? map['cover_page_id'] 
          : int.tryParse(map['cover_page_id']?.toString() ?? '');
      
      // Parse position if latitude and longitude exist
      Position? position;
      final lat = map['current_position_lat'];
      final lng = map['current_position_lng'];
      
      if (lat != null && lng != null) {
        try {
          position = Position(
            latitude: lat is double ? lat : double.tryParse(lat.toString()) ?? 0.0,
            longitude: lng is double ? lng : double.tryParse(lng.toString()) ?? 0.0,
            timestamp: map['interview_start_time'] != null 
                ? DateTime.tryParse(map['interview_start_time'].toString()) ?? DateTime.now()
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
          debugPrint('❌ Error parsing position data: $e');
        }
      }

      final consent = ConsentData(
        id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
        coverPageId: coverPageId,
        communityType: map['community_type']?.toString(),
        residesInCommunityConsent: map['resides_in_community_consent']?.toString(),
        farmerAvailable: map['farmer_available']?.toString(),
        farmerStatus: map['farmer_status']?.toString(),
        availablePerson: map['available_person']?.toString(),
        otherSpecification: map['other_specification']?.toString(),
        otherCommunityName: map['other_community_name']?.toString(),
        consentGiven: map['consent_given'] == 1 || map['consent_given'] == true,
        declinedConsent: map['declined_consent'] == 1 || map['declined_consent'] == true,
        refusalReason: map['refusal_reason']?.toString(),
        consentTimestamp: map['consent_timestamp'] != null 
            ? DateTime.tryParse(map['consent_timestamp'].toString())
            : null,
        otherSpecController: TextEditingController(
          text: map['other_specification']?.toString() ?? '',
        ),
        otherCommunityController: TextEditingController(
          text: map['other_community_name']?.toString() ?? '',
        ),
        refusalReasonController: TextEditingController(
          text: map['refusal_reason']?.toString() ?? '',
        ),
        interviewStartTime: map['interview_start_time'] != null
            ? DateTime.tryParse(map['interview_start_time'].toString())
            : null,
        timeStatus: map['time_status']?.toString() ?? 'Not recorded',
        currentPosition: position,
        locationStatus: map['location_status']?.toString() ?? 'Not recorded',
        isGettingLocation: map['is_getting_location'] == 1 || map['is_getting_location'] == true,
      );
      
      debugPrint('✅ Successfully parsed ConsentData: ${consent.toMap()}');
      return consent;
      
    } catch (e) {
      debugPrint('❌ Error in ConsentData.fromMap: $e');
      rethrow;
    }
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
      declinedConsent: value ? false : declinedConsent,
    );
  }

  /// Update declined consent
  ConsentData updateDeclinedConsent(bool value) {
    return copyWith(
      declinedConsent: value,
      consentGiven: value ? false : consentGiven,
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
    return consentGiven != true ||
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

/// Model for storing detailed information about a child in the household
class FarmerChild {
  final int childNumber;
  final String firstName;
  final String surname;

  FarmerChild({
    required this.childNumber,
    required this.firstName,
    required this.surname,
  });

  Map<String, dynamic> toJson() => {
        'child_number': childNumber,
        'first_name': firstName,
        'surname': surname,
      };

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'childNumber': childNumber,
      'firstName': firstName,
      'surname': surname,
    };
  }

  /// Create from Map from storage
  factory FarmerChild.fromMap(Map<String, dynamic> map) {
    return FarmerChild(
      childNumber: map['childNumber'] ?? 0,
      firstName: map['firstName'] ?? '',
      surname: map['surname'] ?? '',
    );
  }

  /// Copy with method for immutability
  FarmerChild copyWith({
    int? childNumber,
    String? firstName,
    String? surname,
  }) {
    return FarmerChild(
      childNumber: childNumber ?? this.childNumber,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
    );
  }

  /// Check if child data is complete
  bool get isComplete {
    return firstName.trim().isNotEmpty && surname.trim().isNotEmpty;
  }

  @override
  String toString() {
    return 'FarmerChild(childNumber: $childNumber, firstName: $firstName, surname: $surname)';
  }
}

class FarmerIdentificationData {
  final int? id;
  final int? coverPageId;
  final int? hasGhanaCard; 
  final String? ghanaCardNumber;
  final String? selectedIdType;
  final String? idNumber;
  final int? idPictureConsent; // null (not answered), 0 (No), or 1 (Yes)
  final String? noConsentReason;
  final String? idImagePath;
  final String? contactNumber;
  final int childrenCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isSynced;
  final int syncStatus;
  final List<FarmerChild> children;
  
  // Controllers
  final TextEditingController ghanaCardNumberController;
  final TextEditingController idNumberController;
  final TextEditingController contactNumberController;
  final TextEditingController noConsentReasonController;
  final TextEditingController childrenCountController;

  FarmerIdentificationData({
    this.id,
    this.coverPageId,
    this.hasGhanaCard,
    this.ghanaCardNumber,
    this.selectedIdType,
    this.idNumber,
    this.idPictureConsent,
    this.noConsentReason,
    this.idImagePath,
    this.contactNumber,
    this.childrenCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = 0,
    this.syncStatus = 0,
    List<FarmerChild>? children,
    TextEditingController? ghanaCardNumberController,
    TextEditingController? idNumberController,
    TextEditingController? contactNumberController,
    TextEditingController? noConsentReasonController,
    TextEditingController? childrenCountController,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        children = children ?? [],
        ghanaCardNumberController = ghanaCardNumberController ?? TextEditingController(text: ghanaCardNumber ?? ''),
        idNumberController = idNumberController ?? TextEditingController(text: idNumber ?? ''),
        contactNumberController = contactNumberController ?? TextEditingController(text: contactNumber ?? ''),
        noConsentReasonController = noConsentReasonController ?? TextEditingController(text: noConsentReason ?? ''),
        childrenCountController = childrenCountController ?? TextEditingController(text: childrenCount.toString());


  /// Convert to Map for storage/API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cover_page_id': coverPageId,
      'has_ghana_card': hasGhanaCard,
      'ghana_card_number': ghanaCardNumber,
      'selected_id_type': selectedIdType,
      'id_number': idNumber,
      'id_picture_consent': idPictureConsent,
      'no_consent_reason': noConsentReason,
      'id_image_path': idImagePath,
      'contact_number': contactNumber,
      'children_count': childrenCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced,
      'sync_status': syncStatus,
    };
  }

  /// Create from Map from storage/API
  factory FarmerIdentificationData.fromMap(Map<String, dynamic> map) {
    return FarmerIdentificationData(
      id: map['id'] as int?,
      coverPageId: map['cover_page_id'] as int?,
      hasGhanaCard: map['has_ghana_card'] as int?,
      ghanaCardNumber: map['ghana_card_number']?.toString(),
      selectedIdType: map['selected_id_type']?.toString(),
      idNumber: map['id_number']?.toString(),
      idPictureConsent: map['id_picture_consent'] as int?,
      noConsentReason: map['no_consent_reason']?.toString(),
      idImagePath: map['id_image_path']?.toString(),
      contactNumber: map['contact_number']?.toString(),
      childrenCount: map['children_count'] as int? ?? 0,
      childrenCountController: TextEditingController(text: (map['children_count'] ?? '0').toString()),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isSynced: map['is_synced'] as int? ?? 0,
      syncStatus: map['sync_status'] as int? ?? 0,
      // Controllers will be initialized with the values from the map
      ghanaCardNumberController: TextEditingController(text: map['ghana_card_number']?.toString() ?? ''),
      idNumberController: TextEditingController(text: map['id_number']?.toString() ?? ''),
      contactNumberController: TextEditingController(text: map['contact_number']?.toString() ?? ''),
      noConsentReasonController: TextEditingController(text: map['no_consent_reason']?.toString() ?? ''),
    );
  }

  /// Create empty instance
  factory FarmerIdentificationData.empty() {
    return FarmerIdentificationData(
      id: null,
      coverPageId: null,
      hasGhanaCard: null,
      ghanaCardNumber: null,
      selectedIdType: null,
      idNumber: null,
      idPictureConsent: null,
      noConsentReason: null,
      idImagePath: null,
      contactNumber: null,
      childrenCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: 0,
      syncStatus: 0,
      children: const [],
    );
  }
  /// Update Ghana Card selection and clear related fields when needed
  FarmerIdentificationData updateGhanaCard(int? value) {
    return copyWith(
      hasGhanaCard: value,
      ghanaCardNumber: value == 1 ? ghanaCardNumber : null,
      selectedIdType: value == 1 ? selectedIdType : null,
      idNumber: value == 1 ? idNumber : null,
      idImagePath: value == 1 ? idImagePath : null,
    );
  }

  FarmerIdentificationData updateIdType(String? value) {
    return copyWith(
      selectedIdType: value,
      idPictureConsent: null,
      idImagePath: null,
      preserveControllers: true,
    );
  }

  FarmerIdentificationData updatePictureConsent(String? value) {
    // If value is null, set consent to null (not answered)
    // If value is 'Yes', set consent to 1
    // If value is 'No', set consent to 0
    final consentValue = value == null ? null : (value == 'Yes' ? 1 : 0);
    return copyWith(
      idPictureConsent: consentValue,
      // Only clear the image path if consent is explicitly 'No'
      idImagePath: consentValue == 0 ? null : idImagePath,
      // Clear no consent reason if consent is not 'No'
      noConsentReason: consentValue != 0 ? null : noConsentReason,
      preserveControllers: true,
    );
  }

  FarmerIdentificationData updateGhanaCardNumber(String value) {
    return copyWith(
      ghanaCardNumber: value,
    );
  }

  FarmerIdentificationData updateIdNumber(String value) {
    return copyWith(
      idNumber: value,
    );
  }

  FarmerIdentificationData updateNoConsentReason(String value) {
    return copyWith(
      noConsentReason: value,
    );
  }

  FarmerIdentificationData updateContactNumber(String value) {
    return copyWith(
      contactNumber: value,
    );
  }

  FarmerIdentificationData updateChildrenCount(String value) {
    final count = int.tryParse(value) ?? 0;
    return copyWith(
      childrenCount: count,
    );
  }

  FarmerIdentificationData updateChildName(int index, String field, String value) {
    if (index < 0 || index >= children.length) return this;
    
    final updatedChildren = List<FarmerChild>.from(children);
    final child = updatedChildren[index];
    
    updatedChildren[index] = child.copyWith(
      firstName: field == 'firstName' ? value : child.firstName,
      surname: field == 'surname' ? value : child.surname,
    );
    
    return copyWith(
      children: updatedChildren,
      preserveControllers: true,
    );
  }

  FarmerIdentificationData updateIdImagePath(String? path) {
    return copyWith(
      idImagePath: path,
      preserveControllers: true,
    );
  }

  // Validation methods
  String? validateGhanaCardNumber() {
    if (hasGhanaCard != 1) {
      return null;
    }
    
    final cardNumber = ghanaCardNumber?.trim() ?? '';
    
    if (cardNumber.isEmpty) {
      return 'Ghana Card number is required';
    }
    
    final ghanaCardRegex = RegExp(r'^GHA-\d{9}-\d$');
    if (!ghanaCardRegex.hasMatch(cardNumber)) {
      return 'Enter a valid Ghana Card number (GHA-XXXXXXXXX-X)';
    }
    
    return null;
  }
  
  String? validateIdNumber() {
    if (hasGhanaCard == 1 || selectedIdType == null) return null;
    
    final idNumber = this.idNumber?.trim() ?? '';
    if (idNumber.isEmpty) {
      return 'ID number is required';
    }
    
    switch (selectedIdType) {
      case 'voter_id':
        if (!RegExp(r'^\d{10,12}$').hasMatch(idNumber)) {
          return 'Voter ID must be 10-12 digits';
        }
        break;
      case 'passport':
        if (!RegExp(r'^[A-Z0-9]{6,9}$').hasMatch(idNumber)) {
          return 'Enter a valid passport number';
        }
        break;
      case 'drivers_license':
        if (!RegExp(r'^[A-Z0-9]{8,15}$').hasMatch(idNumber)) {
          return 'Enter a valid driver\'s license number';
        }
        break;
      default:
        if (idNumber.length < 4) {
          return 'ID number is too short';
        }
    }
    
    return null;
  }

  String? validateContactNumber() {
    final contactNumber = this.contactNumber?.trim() ?? '';
    if (contactNumber.isEmpty) {
      return 'Contact number is required';
    }
    
    final phoneRegex = RegExp(r'^(?:\+?233|0)?[23579]\d{8}$');
    final normalizedNumber = contactNumber.replaceAll(RegExp(r'[\s\-]'), '');
    
    if (!phoneRegex.hasMatch(normalizedNumber)) {
      return 'Enter a valid Ghanaian phone number (e.g., 0244123456, 233244123456)';
    }
    
    return null;
  }

  String? validateChildrenCount() {
    final count = childrenCount;
    
    if (count < 0) {
      return 'Number of children cannot be negative';
    }
    
    if (count > 20) {
      return 'Number of children seems too high. Please verify.';
    }
    
    return null;
  }

  String? validateNoConsentReason() {
    if (idPictureConsent != 0) return null;
    
    final reason = noConsentReason?.trim() ?? '';
    if (reason.isEmpty) {
      return 'Please provide a reason for not providing ID picture';
    }
    
    if (reason.length < 10) {
      return 'Please provide a more detailed reason';
    }
    
    return null;
  }

  Map<String, String> validateChildren() {
    final errors = <String, String>{};
    
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final prefix = 'child_${i + 1}';
      
      if (child.firstName.trim().isEmpty) {
        errors['${prefix}_firstName'] = 'First name is required';
      } else if (!RegExp(r'^[a-zA-Z\s-]{2,50}$').hasMatch(child.firstName)) {
        errors['${prefix}_firstName'] = 'Enter a valid first name';
      }
      
      if (child.surname.trim().isEmpty) {
        errors['${prefix}_surname'] = 'Surname is required';
      } else if (!RegExp(r'^[a-zA-Z\s-]{2,50}$').hasMatch(child.surname)) {
        errors['${prefix}_surname'] = 'Enter a valid surname';
      }
    }
    
    return errors;
  }

  String? validateIdImage() {
    if (idPictureConsent != 1) return null;
    
    if (idImagePath == null || idImagePath!.trim().isEmpty) {
      return 'Please capture a picture of the ID';
    }
    
    return null;
  }

  Map<String, String> validateForm() {
    final errors = <String, String>{};
    
    if (hasGhanaCard == 0 && selectedIdType == null) {
      errors['idType'] = 'Please select an ID type';
    }
    
    final ghanaCardError = validateGhanaCardNumber();
    if (ghanaCardError != null) {
      errors['ghanaCardNumber'] = ghanaCardError;
    }
    
    final idNumberError = validateIdNumber();
    if (idNumberError != null) {
      errors['idNumber'] = idNumberError;
    }
    
    final contactError = validateContactNumber();
    if (contactError != null) {
      errors['contactNumber'] = contactError;
    }
    
    final childrenCountError = validateChildrenCount();
    if (childrenCountError != null) {
      errors['childrenCount'] = childrenCountError;
    }
    
    final childrenErrors = validateChildren();
    errors.addAll(childrenErrors);
    
    final idImageError = validateIdImage();
    if (idImageError != null) {
      errors['idImage'] = idImageError;
    }
    
    final noConsentReasonError = validateNoConsentReason();
    if (noConsentReasonError != null) {
      errors['noConsentReason'] = noConsentReasonError;
    }
    
    return errors;
  }

  /// Enhanced copyWith that can preserve existing controllers
  FarmerIdentificationData copyWith({
    int? id,
    int? coverPageId,
    int? hasGhanaCard,
    String? ghanaCardNumber,
    String? selectedIdType,
    String? idNumber,
    int? idPictureConsent,
    String? noConsentReason,
    String? idImagePath,
    String? contactNumber,
    int? childrenCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? isSynced,
    int? syncStatus,
    List<FarmerChild>? children,
    bool preserveControllers = false,
  }) {
    return FarmerIdentificationData(
      id: id ?? this.id,
      coverPageId: coverPageId ?? this.coverPageId,
      hasGhanaCard: hasGhanaCard ?? this.hasGhanaCard,
      ghanaCardNumber: ghanaCardNumber ?? this.ghanaCardNumber,
      selectedIdType: selectedIdType ?? this.selectedIdType,
      idNumber: idNumber ?? this.idNumber,
      idPictureConsent: idPictureConsent ?? this.idPictureConsent,
      noConsentReason: noConsentReason ?? this.noConsentReason,
      idImagePath: idImagePath ?? this.idImagePath,
      contactNumber: contactNumber ?? this.contactNumber,
      childrenCount: childrenCount ?? this.childrenCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
      children: children ?? (preserveControllers ? this.children : List.from(this.children)),
    );
  }

  /// Prepares the data for submission by ensuring all fields are properly formatted
  Map<String, dynamic> prepareSubmissionData() {
    return {
      'hasGhanaCard': hasGhanaCard,
      'selectedIdType': selectedIdType,
      'idPictureConsent': idPictureConsent,
      'ghanaCardNumber': ghanaCardNumber ?? '',
      'idNumber': idNumber ?? '',
      'noConsentReason': noConsentReason ?? '',
      'idImagePath': idImagePath ?? '',
      'contactNumber': contactNumber ?? '',
      'childrenCount': childrenCount,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'FarmerIdentificationData('
        'hasGhanaCard: $hasGhanaCard, '
        'selectedIdType: $selectedIdType, '
        'ghanaCardNumber: ${ghanaCardNumberController.text}, '
        'contactNumber: ${contactNumberController.text}, '
        'childrenCount: $childrenCount'
        ')';
  }

  /// Dispose controllers when done
  void dispose() {
    ghanaCardNumberController.dispose();
    idNumberController.dispose();
    contactNumberController.dispose();
    childrenCountController.dispose();
    noConsentReasonController.dispose();
  }
}

/// Model for storing detailed information about a child in the household
class ChildrenHouseholdModel {
  final int? id;
  final int? coverPageId;
  final String? hasChildrenInHousehold;
  final int numberOfChildren;
  final int children5To17;
  final List<Map<String, dynamic>> childrenDetails;
  final DateTime? timestamp;

  ChildrenHouseholdModel({
    this.id,
    this.coverPageId,
    this.hasChildrenInHousehold,
    this.numberOfChildren = 0,
    this.children5To17 = 0,
    List<Map<String, dynamic>>? childrenDetails,
    this.timestamp,
  }) : childrenDetails = childrenDetails ?? [];

  factory ChildrenHouseholdModel.empty() {
    return ChildrenHouseholdModel(
      hasChildrenInHousehold: null,
      numberOfChildren: 0,
      children5To17 : 0,
      childrenDetails: [],
      timestamp: DateTime.now(),
    );
  }

  factory ChildrenHouseholdModel.fromJson(Map<String, dynamic> json) {
    return ChildrenHouseholdModel(
      id: json['id'],
      coverPageId: json['coverPageId'],
      hasChildrenInHousehold: json['hasChildrenInHousehold'],
      numberOfChildren: json['numberOfChildren'] ?? 0,
      children5To17: json['children5To17'] ?? 0,
      childrenDetails:
          List<Map<String, dynamic>>.from(json['childrenDetails'] ?? []),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  factory ChildrenHouseholdModel.fromMap(Map<String, dynamic> map) {
    return ChildrenHouseholdModel(
      id: map['id'],
      coverPageId: map['cover_page_id'],
      hasChildrenInHousehold: map['has_children_in_household'],
      numberOfChildren: map['number_of_children'] ?? 0,
      children5To17: map['children_5_to_17'] ?? 0,
      childrenDetails: map['children_details'] != null
          ? List<Map<String, dynamic>>.from(
              jsonDecode(map['children_details']))
          : [],
      timestamp: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coverPageId': coverPageId,
      'hasChildrenInHousehold': hasChildrenInHousehold,
      'numberOfChildren': numberOfChildren,
      'children5To17': children5To17,
      'childrenDetails': childrenDetails,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    final now = DateTime.now().toIso8601String();
    return {
      'id': id,
      'cover_page_id': coverPageId,
      'has_children_in_household': hasChildrenInHousehold,
      'number_of_children': numberOfChildren,
      'children_5_to_17': children5To17,
      'children_details': jsonEncode(childrenDetails),
      'created_at': timestamp?.toIso8601String() ?? now,
      'updated_at': now,
      'is_synced': 0,
      'sync_status': 0,
    };
  }

  ChildrenHouseholdModel copyWith({
    int? id,
    int? coverPageId,
    String? hasChildrenInHousehold,
    int? numberOfChildren,
    int? children5To17,
    List<Map<String, dynamic>>? childrenDetails,
    DateTime? timestamp,
  }) {
    return ChildrenHouseholdModel(
      id: id ?? this.id,
      coverPageId: coverPageId ?? this.coverPageId,
      hasChildrenInHousehold: hasChildrenInHousehold ?? this.hasChildrenInHousehold,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      children5To17: children5To17 ?? this.children5To17,
      childrenDetails: childrenDetails ?? this.childrenDetails,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  bool get hasChildren => hasChildrenInHousehold == 'Yes';
  bool get hasChildren5To17 => hasChildren && children5To17 > 0;
  bool get allChildrenDetailsCollected => childrenDetails.length >= children5To17;

  bool get isValid {
    if (hasChildrenInHousehold == null) return false;
    if (!hasChildren) return true;
    if (numberOfChildren <= 0) return false;
    if (children5To17 < 0) return false;
    if (children5To17 > numberOfChildren) return false;
    return true;
  }

  @override
  String toString() {
    return 'ChildrenHouseholdModel(' +
        'id: $id, ' +
        'coverPageId: $coverPageId, ' +
        'hasChildrenInHousehold: $hasChildrenInHousehold, ' +
        'numberOfChildren: $numberOfChildren, ' +
        'children5To17: $children5To17, ' +
        'childrenDetails: ${childrenDetails.length} children, ' +
        'timestamp: $timestamp' +
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildrenHouseholdModel &&
        other.id == id &&
        other.coverPageId == coverPageId &&
        other.hasChildrenInHousehold == hasChildrenInHousehold &&
        other.numberOfChildren == numberOfChildren &&
        other.children5To17 == children5To17 &&
        other.childrenDetails.length == childrenDetails.length &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      coverPageId,
      hasChildrenInHousehold,
      numberOfChildren,
      children5To17,
      childrenDetails.length,
      timestamp,
    );
  }
}

/// Main model for Farmer Identification Page data
class CombinedFarmerIdentificationModel {
  final int? id; // For database primary key
  final int? coverPageId; // Reference to the cover page

  // Visit Information
  final VisitInformationData? visitInformation;
  
  // Owner Identification
  final IdentificationOfOwnerData? ownerInformation;
  
  // Workers in Farm
  final WorkersInFarmData? workersInFarm;
  
  // Adults Information
  final AdultsInformationData? adultsInformation;

  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced; // Track if synced with server
  final int? syncStatus; // Sync status code

  const CombinedFarmerIdentificationModel({
    this.id,
    this.coverPageId,
    
    // Visit Information
    this.visitInformation,
    
    // Owner Identification
    this.ownerInformation,
    
    // Workers in Farm
    this.workersInFarm,
    
    // Adults Information
    this.adultsInformation,
    
    // Metadata
    this.createdAt,
    this.updatedAt,
    this.isSynced = false,
    this.syncStatus = 0,
  });
  
  // Create an empty instance
  factory CombinedFarmerIdentificationModel.empty() {
    return CombinedFarmerIdentificationModel(
      visitInformation: VisitInformationData(),
      ownerInformation: IdentificationOfOwnerData(),
      workersInFarm: WorkersInFarmData(),
      adultsInformation: AdultsInformationData(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cover_page_id': coverPageId,
      'visit_information': visitInformation?.toMap(),
      'owner_information': ownerInformation?.toMap(),
      'workers_in_farm': workersInFarm?.toMap(),
      'adults_information': adultsInformation?.toMap(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'sync_status': syncStatus ?? 0,
    };
  }

  // Create from Map (for database retrieval)
  factory CombinedFarmerIdentificationModel.fromMap(Map<String, dynamic> map) {
    // Helper function to safely parse JSON strings to maps
    Map<String, dynamic>? parseJsonField(dynamic value) {
      if (value == null) return null;
      
      // If it's already a Map, return it directly
      if (value is Map) return Map<String, dynamic>.from(value);
      
      // If it's a String, try to parse it as JSON
      if (value is String) {
        try {
          // First, try to parse as JSON
          final parsed = jsonDecode(value);
          // If the parsed result is a Map, return it
          if (parsed is Map) {
            return Map<String, dynamic>.from(parsed);
          }
          return {'value': parsed}; // Wrap non-map values in a map
        } catch (e) {
          debugPrint('Error parsing JSON field: $e');
          // If parsing fails, try to handle the string as a raw value
          return {'value': value};
        }
      }
      
      // For any other type, try to convert to a map
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        debugPrint('Error converting to map: $e');
        return null;
      }
    }

    // Debug print the incoming map
    debugPrint('🔍 [CombinedFarm] Raw map data: $map');

    try {
      // Debug print the type of each field
      map.forEach((key, value) {
        if (value != null) {
          debugPrint('🔍 [CombinedFarm] Field $key has type: ${value.runtimeType}');
          if (value is String) {
            debugPrint('🔍 [CombinedFarm] Field $key value: $value');
          }
        }
      });

      final result = CombinedFarmerIdentificationModel(
        id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
        coverPageId: map['cover_page_id'] is int 
            ? map['cover_page_id'] 
            : int.tryParse(map['cover_page_id']?.toString() ?? ''),
        
        // Nested models with JSON parsing
        visitInformation: map['visit_information'] != null 
            ? VisitInformationData.fromMap(parseJsonField(map['visit_information']) ?? {})
            : null,
        ownerInformation: map['owner_information'] != null
            ? IdentificationOfOwnerData.fromMap(parseJsonField(map['owner_information']) ?? {})
            : null,
        workersInFarm: map['workers_in_farm'] != null
            ? WorkersInFarmData.fromMap(parseJsonField(map['workers_in_farm']) ?? {})
            : null,
        adultsInformation: map['adults_information'] != null
            ? AdultsInformationData.fromMap(parseJsonField(map['adults_information']) ?? {})
            : null,
        
        // Metadata
        createdAt: map['created_at'] != null 
            ? (map['created_at'] is DateTime 
                ? map['created_at'] 
                : DateTime.tryParse(map['created_at'].toString()))
            : null,
        updatedAt: map['updated_at'] != null 
            ? (map['updated_at'] is DateTime 
                ? map['updated_at'] 
                : DateTime.tryParse(map['updated_at'].toString()))
            : null,
        isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
        syncStatus: map['sync_status'] is int 
            ? map['sync_status'] 
            : int.tryParse(map['sync_status']?.toString() ?? '0'),
      );
      
      debugPrint('✅ [CombinedFarm] Successfully parsed model: $result');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ [CombinedFarm] Error creating CombinedFarmerIdentificationModel: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      // Return an empty model with default values
      return CombinedFarmerIdentificationModel.empty();
    }
  }

  // Create a copy with updated fields
  CombinedFarmerIdentificationModel copyWith({
    int? id,
    int? coverPageId,
    
    // Nested models
    VisitInformationData? visitInformation,
    IdentificationOfOwnerData? ownerInformation,
    WorkersInFarmData? workersInFarm,
    AdultsInformationData? adultsInformation,
    
    // Metadata
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    int? syncStatus,
  }) {
    return CombinedFarmerIdentificationModel(
      id: id ?? this.id,
      coverPageId: coverPageId ?? this.coverPageId,
      
      // Nested models
      visitInformation: visitInformation ?? this.visitInformation,
      ownerInformation: ownerInformation ?? this.ownerInformation,
      workersInFarm: workersInFarm ?? this.workersInFarm,
      adultsInformation: adultsInformation ?? this.adultsInformation,
      
      // Metadata
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  String toString() {
    return 'CombinedFarmerIdentificationModel{'
        'id: $id, '
        'visitInformation: $visitInformation, '
        'ownerInformation: $ownerInformation, '
        'workersInFarm: $workersInFarm, '
        'adultsInformation: $adultsInformation, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'isSynced: $isSynced, '
        'syncStatus: $syncStatus}';
  }
}

/// Model for storing detailed information about a child in the household
class ChildDetailsModel {
  // Basic Information
  final String? name;
  final String? surname;
  final String? childNumber;
  final int? birthYear;
  final String? gender;
  final bool? isFarmerChild;
  final bool? canBeSurveyedNow;
  final DateTime? interviewDate;

  // Survey Availability
  final List<String> surveyNotPossibleReasons;
  final String? otherSurveyNotPossibleReason;
  final String? respondentType;
  final String? otherRespondentType;
  final String? respondentName;
  final String? otherRespondentSpecify;

  // Birth and Documentation
  final bool? hasBirthCertificate;
  final String? noBirthCertificateReason;
  final bool? bornInCommunity;
  final String? birthCountry;

  // Household Relationship
  final String? relationshipToHead;
  final String? otherRelationship;
  final Map<String, bool> notLivingWithFamilyReasons;
  final String? otherNotLivingWithFamilyReason;

  // Family Decision Information
  final String? whoDecidedChildJoin;
  final String? otherPersonDecided;
  final bool? childAgreedWithDecision;
  final bool? hasSpokenWithParents;
  final String? lastContactWithParents;
  final String? timeInHousehold;
  final String? whoAccompaniedChild;
  final String? otherAccompaniedPerson;

  // Parent Residence Information
  final String? fatherResidence;
  final String? fatherCountry;
  final String? otherFatherCountry;
  final String? motherResidence;
  final String? motherCountry;
  final String? otherMotherCountry;

  // Education Information
  final bool? isCurrentlyEnrolled;
  final bool? hasEverBeenToSchool;
  final String? schoolName;
  final String? schoolType;
  final String? gradeLevel;
  final String? schoolAttendanceFrequency;
  final Set<String> availableSchoolSupplies;
  
  // School Leaving Information
  final String? leftSchoolYear;
  final DateTime? leftSchoolDate;
  final String? educationLevel;
  final String? childLeaveSchoolReason;
  final String? otherLeaveReason;
  final String? neverBeenToSchoolReason;
  final String? otherNeverSchoolReason;

  // School Attendance
  final bool? attendedSchoolLast7Days;
  final String? selectedLeaveReason;
  final String? otherAbsenceReason;

  // Constructor
  ChildDetailsModel({
    // Basic Information
    this.name,
    this.surname,
    this.childNumber,
    this.birthYear,
    this.gender,
    this.isFarmerChild,
    this.canBeSurveyedNow,
    this.interviewDate,
    
    // Survey Availability
    List<String>? surveyNotPossibleReasons,
    this.otherSurveyNotPossibleReason,
    this.respondentType,
    this.otherRespondentType,
    this.respondentName,
    this.otherRespondentSpecify,
    
    // Birth and Documentation
    this.hasBirthCertificate,
    this.noBirthCertificateReason,
    this.bornInCommunity,
    this.birthCountry,
    
    // Household Relationship
    this.relationshipToHead,
    this.otherRelationship,
    Map<String, bool>? notLivingWithFamilyReasons,
    this.otherNotLivingWithFamilyReason,
    
    // Family Decision Information
    this.whoDecidedChildJoin,
    this.otherPersonDecided,
    this.childAgreedWithDecision,
    this.hasSpokenWithParents,
    this.lastContactWithParents,
    this.timeInHousehold,
    this.whoAccompaniedChild,
    this.otherAccompaniedPerson,
    
    // Parent Residence Information
    this.fatherResidence,
    this.fatherCountry,
    this.otherFatherCountry,
    this.motherResidence,
    this.motherCountry,
    this.otherMotherCountry,
    
    // Education Information
    this.isCurrentlyEnrolled,
    this.hasEverBeenToSchool,
    this.schoolName,
    this.schoolType,
    this.gradeLevel,
    this.schoolAttendanceFrequency,
    Set<String>? availableSchoolSupplies,
    
    // School Leaving Information
    this.leftSchoolYear,
    this.leftSchoolDate,
    this.educationLevel,
    this.childLeaveSchoolReason,
    this.otherLeaveReason,
    this.neverBeenToSchoolReason,
    this.otherNeverSchoolReason,
    
    // School Attendance
    this.attendedSchoolLast7Days,
    this.selectedLeaveReason,
    this.otherAbsenceReason,
  }) : surveyNotPossibleReasons = surveyNotPossibleReasons ?? [],
       notLivingWithFamilyReasons = notLivingWithFamilyReasons ?? {},
       availableSchoolSupplies = availableSchoolSupplies ?? {};

  // Create a copyWith method for immutability
  ChildDetailsModel copyWith({
    String? name,
    String? surname,
    String? childNumber,
    int? birthYear,
    String? gender,
    bool? isFarmerChild,
    bool? canBeSurveyedNow,
    DateTime? interviewDate,
    
    // Survey Availability
    List<String>? surveyNotPossibleReasons,
    String? otherSurveyNotPossibleReason,
    String? respondentType,
    String? otherRespondentType,
    String? respondentName,
    String? otherRespondentSpecify,
    
    // Birth and Documentation
    bool? hasBirthCertificate,
    String? noBirthCertificateReason,
    bool? bornInCommunity,
    String? birthCountry,
    
    // Household Relationship
    String? relationshipToHead,
    String? otherRelationship,
    Map<String, bool>? notLivingWithFamilyReasons,
    String? otherNotLivingWithFamilyReason,
    
    // Family Decision Information
    String? whoDecidedChildJoin,
    String? otherPersonDecided,
    bool? childAgreedWithDecision,
    bool? hasSpokenWithParents,
    String? lastContactWithParents,
    String? timeInHousehold,
    String? whoAccompaniedChild,
    String? otherAccompaniedPerson,
    
    // Parent Residence Information
    String? fatherResidence,
    String? fatherCountry,
    String? otherFatherCountry,
    String? motherResidence,
    String? motherCountry,
    String? otherMotherCountry,
    
    // Education Information
    bool? isCurrentlyEnrolled,
    bool? hasEverBeenToSchool,
    String? schoolName,
    String? schoolType,
    String? gradeLevel,
    String? schoolAttendanceFrequency,
    Set<String>? availableSchoolSupplies,
    
    // School Leaving Information
    String? leftSchoolYear,
    DateTime? leftSchoolDate,
    String? educationLevel,
    String? childLeaveSchoolReason,
    String? otherLeaveReason,
    String? neverBeenToSchoolReason,
    String? otherNeverSchoolReason,
    
    // School Attendance
    bool? attendedSchoolLast7Days,
    String? selectedLeaveReason,
    String? otherAbsenceReason,
  }) {
    // Create a map of the current instance's data
    final map = this.toMap();
    
    // Update the map with non-null values from parameters
    if (name != null) map['name'] = name;
    if (surname != null) map['surname'] = surname;
    if (childNumber != null) map['childNumber'] = childNumber;
    if (birthYear != null) map['birthYear'] = birthYear;
    if (gender != null) map['gender'] = gender;
    if (isFarmerChild != null) map['isFarmerChild'] = isFarmerChild;
    if (canBeSurveyedNow != null) map['canBeSurveyedNow'] = canBeSurveyedNow;
    if (interviewDate != null) map['interviewDate'] = interviewDate.toIso8601String();
    if (surveyNotPossibleReasons != null) map['surveyNotPossibleReasons'] = surveyNotPossibleReasons.join('|');
    if (otherSurveyNotPossibleReason != null) map['otherSurveyNotPossibleReason'] = otherSurveyNotPossibleReason;
    if (respondentType != null) map['respondentType'] = respondentType;
    if (otherRespondentType != null) map['otherRespondentType'] = otherRespondentType;
    if (respondentName != null) map['respondentName'] = respondentName;
    if (otherRespondentSpecify != null) map['otherRespondentSpecify'] = otherRespondentSpecify;
    if (hasBirthCertificate != null) map['hasBirthCertificate'] = hasBirthCertificate ? 1 : 0;
    if (noBirthCertificateReason != null) map['noBirthCertificateReason'] = noBirthCertificateReason;
    if (bornInCommunity != null) map['bornInCommunity'] = bornInCommunity ? 1 : 0;
    if (birthCountry != null) map['birthCountry'] = birthCountry;
    if (relationshipToHead != null) map['relationshipToHead'] = relationshipToHead;
    if (otherRelationship != null) map['otherRelationship'] = otherRelationship;
    if (notLivingWithFamilyReasons != null) {
      map['notLivingWithFamilyReasons'] = notLivingWithFamilyReasons.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .join('|');
    }
    if (otherNotLivingWithFamilyReason != null) map['otherNotLivingWithFamilyReason'] = otherNotLivingWithFamilyReason;
    if (whoDecidedChildJoin != null) map['whoDecidedChildJoin'] = whoDecidedChildJoin;
    if (otherPersonDecided != null) map['otherPersonDecided'] = otherPersonDecided;
    if (childAgreedWithDecision != null) map['childAgreedWithDecision'] = childAgreedWithDecision ? 1 : 0;
    if (hasSpokenWithParents != null) map['hasSpokenWithParents'] = hasSpokenWithParents ? 1 : 0;
    if (lastContactWithParents != null) map['lastContactWithParents'] = lastContactWithParents;
    if (timeInHousehold != null) map['timeInHousehold'] = timeInHousehold;
    if (whoAccompaniedChild != null) map['whoAccompaniedChild'] = whoAccompaniedChild;
    if (otherAccompaniedPerson != null) map['otherAccompaniedPerson'] = otherAccompaniedPerson;
    if (fatherResidence != null) map['fatherResidence'] = fatherResidence;
    if (fatherCountry != null) map['fatherCountry'] = fatherCountry;
    if (otherFatherCountry != null) map['otherFatherCountry'] = otherFatherCountry;
    if (motherResidence != null) map['motherResidence'] = motherResidence;
    if (motherCountry != null) map['motherCountry'] = motherCountry;
    if (otherMotherCountry != null) map['otherMotherCountry'] = otherMotherCountry;
    if (isCurrentlyEnrolled != null) map['isCurrentlyEnrolled'] = isCurrentlyEnrolled ? 1 : 0;
    if (hasEverBeenToSchool != null) map['hasEverBeenToSchool'] = hasEverBeenToSchool ? 1 : 0;
    if (schoolName != null) map['schoolName'] = schoolName;
    if (schoolType != null) map['schoolType'] = schoolType;
    if (gradeLevel != null) map['gradeLevel'] = gradeLevel;
    if (schoolAttendanceFrequency != null) map['schoolAttendanceFrequency'] = schoolAttendanceFrequency;
    if (availableSchoolSupplies != null) map['availableSchoolSupplies'] = availableSchoolSupplies.join('|');
    if (leftSchoolYear != null) map['leftSchoolYear'] = leftSchoolYear;
    if (leftSchoolDate != null) map['leftSchoolDate'] = leftSchoolDate.toIso8601String();
    if (educationLevel != null) map['educationLevel'] = educationLevel;
    if (childLeaveSchoolReason != null) map['childLeaveSchoolReason'] = childLeaveSchoolReason;
    if (otherLeaveReason != null) map['otherLeaveReason'] = otherLeaveReason;
    if (neverBeenToSchoolReason != null) map['neverBeenToSchoolReason'] = neverBeenToSchoolReason;
    if (otherNeverSchoolReason != null) map['otherNeverSchoolReason'] = otherNeverSchoolReason;
    if (attendedSchoolLast7Days != null) map['attendedSchoolLast7Days'] = attendedSchoolLast7Days ? 1 : 0;
    if (selectedLeaveReason != null) map['selectedLeaveReason'] = selectedLeaveReason;
    if (otherAbsenceReason != null) map['otherAbsenceReason'] = otherAbsenceReason;

    // Create and return a new instance with the updated data
    return ChildDetailsModel.fromMap(map);
  }

  // Convert to map for database operations
  Map<String, dynamic> toMap() {
    return {
      // Basic Information
      'name': name,
      'surname': surname,
      'childNumber': childNumber,
      'birthYear': birthYear,
      'gender': gender,
      'isFarmerChild': isFarmerChild ?? false ? 1 : 0,
      'canBeSurveyedNow': canBeSurveyedNow ?? false ? 1 : 0,
      'interviewDate': interviewDate?.toIso8601String(),
      
      // Survey Availability
      'surveyNotPossibleReasons': surveyNotPossibleReasons.join('|'),
      'otherSurveyNotPossibleReason': otherSurveyNotPossibleReason,
      'respondentType': respondentType,
      'otherRespondentType': otherRespondentType,
      'respondentName': respondentName,
      'otherRespondentSpecify': otherRespondentSpecify,
      
      // Birth and Documentation
      'hasBirthCertificate': (hasBirthCertificate ?? false) ? 1 : 0,
      'noBirthCertificateReason': noBirthCertificateReason,
      'bornInCommunity': (bornInCommunity ?? false) ? 1 : 0,
      'birthCountry': birthCountry,
      
      // Household Relationship
      'relationshipToHead': relationshipToHead,
      'otherRelationship': otherRelationship,
      'notLivingWithFamilyReasons': notLivingWithFamilyReasons.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .join('|'),
      'otherNotLivingWithFamilyReason': otherNotLivingWithFamilyReason,
      
      // Family Decision Information
      'whoDecidedChildJoin': whoDecidedChildJoin,
      'otherPersonDecided': otherPersonDecided,
      'childAgreedWithDecision': childAgreedWithDecision == true ? 1 : 0,
      'hasSpokenWithParents': hasSpokenWithParents == true ? 1 : 0,
      'lastContactWithParents': lastContactWithParents,
      'timeInHousehold': timeInHousehold,
      'whoAccompaniedChild': whoAccompaniedChild,
      'otherAccompaniedPerson': otherAccompaniedPerson,
      
      // Parent Residence Information
      'fatherResidence': fatherResidence,
      'fatherCountry': fatherCountry,
      'otherFatherCountry': otherFatherCountry,
      'motherResidence': motherResidence,
      'motherCountry': motherCountry,
      'otherMotherCountry': otherMotherCountry,
      
      // Education Information
      'isCurrentlyEnrolled': isCurrentlyEnrolled == true ? 1 : 0,
      'hasEverBeenToSchool': hasEverBeenToSchool == true ? 1 : 0,
      'schoolName': schoolName,
      'schoolType': schoolType,
      'gradeLevel': gradeLevel,
      'schoolAttendanceFrequency': schoolAttendanceFrequency,
      'availableSchoolSupplies': availableSchoolSupplies.join('|'),
      
      // School Leaving Information
      'leftSchoolYear': leftSchoolYear,
      'leftSchoolDate': leftSchoolDate?.toIso8601String(),
      'educationLevel': educationLevel,
      'childLeaveSchoolReason': childLeaveSchoolReason,
      'otherLeaveReason': otherLeaveReason,
      'neverBeenToSchoolReason': neverBeenToSchoolReason,
      'otherNeverSchoolReason': otherNeverSchoolReason,
      
      // School Attendance
      'attendedSchoolLast7Days': (attendedSchoolLast7Days ?? false) ? 1 : 0,
      'selectedLeaveReason': selectedLeaveReason,
      'otherAbsenceReason': otherAbsenceReason,
    };
  }

  // Create from map (for database retrieval)
  factory ChildDetailsModel.fromMap(Map<String, dynamic> map) {
    return ChildDetailsModel(
      // Basic Information
      name: map['name'],
      surname: map['surname'],
      childNumber: map['childNumber'],
      birthYear: map['birthYear'],
      gender: map['gender'],
      isFarmerChild: map['isFarmerChild'] == 1,
      canBeSurveyedNow: map['canBeSurveyedNow'] == 1,
      interviewDate: map['interviewDate'] != null ? DateTime.parse(map['interviewDate']) : null,
      
      // Survey Availability
      surveyNotPossibleReasons: (map['surveyNotPossibleReasons'] as String?)?.split('|').where((s) => s.isNotEmpty).toList() ?? [],
      otherSurveyNotPossibleReason: map['otherSurveyNotPossibleReason'],
      respondentType: map['respondentType'],
      otherRespondentType: map['otherRespondentType'],
      respondentName: map['respondentName'],
      otherRespondentSpecify: map['otherRespondentSpecify'],
      
      // Birth and Documentation
      hasBirthCertificate: map['hasBirthCertificate'] == 1,
      noBirthCertificateReason: map['noBirthCertificateReason'],
      bornInCommunity: map['bornInCommunity'] == 1,
      birthCountry: map['birthCountry'],
      
      // Household Relationship
      relationshipToHead: map['relationshipToHead'],
      otherRelationship: map['otherRelationship'],
      notLivingWithFamilyReasons: {
        for (var reason in (map['notLivingWithFamilyReasons'] as String?)?.split('|') ?? [])
          reason: true
      },
      otherNotLivingWithFamilyReason: map['otherNotLivingWithFamilyReason'],
      
      // Family Decision Information
      whoDecidedChildJoin: map['whoDecidedChildJoin'],
      otherPersonDecided: map['otherPersonDecided'],
      childAgreedWithDecision: map['childAgreedWithDecision'] == 1,
      hasSpokenWithParents: map['hasSpokenWithParents'] == 1,
      lastContactWithParents: map['lastContactWithParents'],
      timeInHousehold: map['timeInHousehold'],
      whoAccompaniedChild: map['whoAccompaniedChild'],
      otherAccompaniedPerson: map['otherAccompaniedPerson'],
      
      // Parent Residence Information
      fatherResidence: map['fatherResidence'],
      fatherCountry: map['fatherCountry'],
      otherFatherCountry: map['otherFatherCountry'],
      motherResidence: map['motherResidence'],
      motherCountry: map['motherCountry'],
      otherMotherCountry: map['otherMotherCountry'],
      
      // Education Information
      isCurrentlyEnrolled: map['isCurrentlyEnrolled'] == 1,
      hasEverBeenToSchool: map['hasEverBeenToSchool'] == 1,
      schoolName: map['schoolName'],
      schoolType: map['schoolType'],
      gradeLevel: map['gradeLevel'],
      schoolAttendanceFrequency: map['schoolAttendanceFrequency'],
      availableSchoolSupplies: (map['availableSchoolSupplies'] as String?)?.split('|').where((s) => s.isNotEmpty).toSet() ?? {},
      
      // School Leaving Information
      leftSchoolYear: map['leftSchoolYear'],
      leftSchoolDate: map['leftSchoolDate'] != null ? DateTime.parse(map['leftSchoolDate']) : null,
      educationLevel: map['educationLevel'],
      childLeaveSchoolReason: map['childLeaveSchoolReason'],
      otherLeaveReason: map['otherLeaveReason'],
      neverBeenToSchoolReason: map['neverBeenToSchoolReason'],
      otherNeverSchoolReason: map['otherNeverSchoolReason'],
      
      // School Attendance
      attendedSchoolLast7Days: map['attendedSchoolLast7Days'] == 1,
      selectedLeaveReason: map['selectedLeaveReason'],
      otherAbsenceReason: map['otherAbsenceReason'],
    );
  }
}

/// Model for remediation information
class RemediationModel {
  final int? id;
  final int? coverPageId;
  
  // School Fees Information
  final bool? hasSchoolFees;
  
  // Support Options
  final bool childProtectionEducation;
  final bool schoolKitsSupport;
  final bool igaSupport;
  final bool otherSupport;
  final String? otherSupportDetails;
  
  // Community Action
  final String? communityAction;
  final String? otherCommunityActionDetails;

  const RemediationModel({
    this.id,
    this.coverPageId,
    this.hasSchoolFees,
    this.childProtectionEducation = false,
    this.schoolKitsSupport = false,
    this.igaSupport = false,
    this.otherSupport = false,
    this.otherSupportDetails,
    this.communityAction,
    this.otherCommunityActionDetails,
  });

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'cover_page_id': coverPageId,
      'has_school_fees': hasSchoolFees == null ? null : (hasSchoolFees! ? 1 : 0),
      'child_protection_education': childProtectionEducation ? 1 : 0,
      'school_kits_support': schoolKitsSupport ? 1 : 0,
      'iga_support': igaSupport ? 1 : 0,
      'other_support': otherSupport ? 1 : 0,
      'other_support_details': otherSupportDetails,
      'community_action': communityAction,
      'other_community_action_details': otherCommunityActionDetails,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
      'sync_status': 0,
    };
    
    // Add ID if it exists
    if (id != null) {
      map['id'] = id;
    }
    
    // Remove null values to prevent SQL errors
    map.removeWhere((key, value) => value == null);
    
    return map;
  }

  // Create from Map (for database retrieval)
  factory RemediationModel.fromMap(Map<String, dynamic> map) {
    return RemediationModel(
      id: map['id'] as int?,
      coverPageId: map['cover_page_id'] as int?,
      hasSchoolFees: map['has_school_fees'] == null 
          ? null 
          : (map['has_school_fees'] == 1 || map['has_school_fees'] == true),
      childProtectionEducation: (map['child_protection_education'] == 1 || map['child_protection_education'] == true),
      schoolKitsSupport: (map['school_kits_support'] == 1 || map['school_kits_support'] == true),
      igaSupport: (map['iga_support'] == 1 || map['iga_support'] == true),
      otherSupport: (map['other_support'] == 1 || map['other_support'] == true),
      otherSupportDetails: map['other_support_details'],
      communityAction: map['community_action'],
      otherCommunityActionDetails: map['other_community_action_details'],
    );
  }

  // Create a copy with some fields updated
  RemediationModel copyWith({
    int? id,
    int? coverPageId,
    bool? hasSchoolFees,
    bool? childProtectionEducation,
    bool? schoolKitsSupport,
    bool? igaSupport,
    bool? otherSupport,
    String? otherSupportDetails,
    String? communityAction,
    String? otherCommunityActionDetails,
  }) {
    return RemediationModel(
      id: id ?? this.id,
      coverPageId: coverPageId ?? this.coverPageId,
      hasSchoolFees: hasSchoolFees ?? this.hasSchoolFees,
      childProtectionEducation: childProtectionEducation ?? this.childProtectionEducation,
      schoolKitsSupport: schoolKitsSupport ?? this.schoolKitsSupport,
      igaSupport: igaSupport ?? this.igaSupport,
      otherSupport: otherSupport ?? this.otherSupport,
      otherSupportDetails: otherSupportDetails ?? this.otherSupportDetails,
      communityAction: communityAction ?? this.communityAction,
      otherCommunityActionDetails: otherCommunityActionDetails ?? this.otherCommunityActionDetails,
    );
  }

  // Create an empty instance
  static RemediationModel empty() => const RemediationModel();

  // Check if the model is empty
  bool get isEmpty => this == empty();

  // Check if the model is not empty
  bool get isNotEmpty => this != empty();

  // Check if the model has a valid ID
  bool get hasId => id != null && id! > 0;

  @override
  String toString() {
    return 'RemediationModel(id: $id, coverPageId: $coverPageId, hasSchoolFees: $hasSchoolFees, childProtectionEducation: $childProtectionEducation, schoolKitsSupport: $schoolKitsSupport, igaSupport: $igaSupport, otherSupport: $otherSupport, otherSupportDetails: $otherSupportDetails, communityAction: $communityAction, otherCommunityActionDetails: $otherCommunityActionDetails)';
  }
}

/// Represents the user's acknowledgment of sensitization information.
class SensitizationData {
  final int? id;
  final int? coverPageId;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final int? syncStatus;

  /// Creates a new [SensitizationData] instance.
  const SensitizationData({
    this.id,
    this.coverPageId,
    this.isAcknowledged = false,
    this.acknowledgedAt,
    this.createdAt,
    this.updatedAt,
    this.isSynced = false,
    this.syncStatus = 0,
  });

  /// Creates a [SensitizationData] from a database map.
  factory SensitizationData.fromMap(Map<String, dynamic> map) {
    return SensitizationData(
      id: map['id'],
      coverPageId: map['cover_page_id'],
      isAcknowledged: map['is_acknowledged'] == 1 || map['is_acknowledged'] == true,
      acknowledgedAt: map['acknowledged_at'] is String 
          ? DateTime.tryParse(map['acknowledged_at']) 
          : map['acknowledged_at'],
      createdAt: map['created_at'] is String 
          ? DateTime.tryParse(map['created_at'])
          : map['created_at'],
      updatedAt: map['updated_at'] is String 
          ? DateTime.tryParse(map['updated_at'])
          : map['updated_at'],
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
      syncStatus: map['sync_status'] is int ? map['sync_status'] : 0,
    );
  }

  /// Creates a copy of this [SensitizationData] with the given fields replaced.
  SensitizationData copyWith({
    int? id,
    int? coverPageId,
    bool? isAcknowledged,
    DateTime? acknowledgedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    int? syncStatus,
  }) {
    return SensitizationData(
      id: id ?? this.id,
      coverPageId: coverPageId ?? this.coverPageId,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Converts the [SensitizationData] to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cover_page_id': coverPageId,
      'is_acknowledged': isAcknowledged ? 1 : 0,
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'sync_status': syncStatus,
    };
  }

  @override
  String toString() {
    return 'SensitizationData(' 
        'id: $id, '
        'coverPageId: $coverPageId, '
        'isAcknowledged: $isAcknowledged, '
        'acknowledgedAt: $acknowledgedAt, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'isSynced: $isSynced, '
        'syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensitizationData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          coverPageId == other.coverPageId &&
          isAcknowledged == other.isAcknowledged &&
          acknowledgedAt == other.acknowledgedAt &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isSynced == other.isSynced &&
          syncStatus == other.syncStatus;

  @override
  int get hashCode => Object.hash(
        id,
        coverPageId,
        isAcknowledged,
        acknowledgedAt,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      );
}

/// A class containing all the sensitization content for the application.
class SensitizationContent {
  /// Title for the Good Parenting section.
  static const String goodParentingTitle = 'GOOD PARENTING';

  /// Bullet points for the Good Parenting section.
  static const List<String> goodParentingBullets = [
    'Every parent is responsible for loving, protecting, training and discipling their children.',
    'Good parenting begins from inception. It is cheaper to get things right during early childhood than trying to fix it later.',
    'Good parenting nurtures innovation and creative thinking in children.',
    'Parenting a child is a one-time opportunity; there is no do-over.',
  ];

  /// Title for the Child Protection section.
  static const String childProtectionTitle = 'CHILD PROTECTION';

  /// Bullet points for the Child Protection section.
  static const List<String> childProtectionBullets = [
    'Children\'s rights are all about the needs of a child, all the care and the protection a child must enjoy to guarantee his/her development and full growth.',
    'Child labour is mentally, physically, socially, morally dangerous and detrimental to children\'s development.',
    'Socialization of children must not be an excuse for exploitation or compromise their education.',
    'Children are more likely to have occupational accidents because they are less experienced, less aware of the risks and means to prevent them.',
    'Child labour can have tragic consequences at individual, family, community and national levels.',
  ];

  /// Title for the Safe Labour Practices section.
  static const String safeLabourPracticesTitle = 'SAFE LABOUR PRACTICES';

  /// Bullet points for the Safe Labour Practices section.
  static const List<String> safeLabourPracticesBullets = [
    'Carefully read the instructions provided for the use of the chemical product before application.',
    'Wear the appropriate protective clothing and footwear before setting off to the farm.',
    'Wear protective clothing during spraying of agrochemical products, fertilizer application and pruning.',
    'Threats, harassment, assault and deprivations of all kinds are all characteristics of forced labour.',
    'Forced/compulsory labour is an affront to children\'s rights and development.',
    'Promote safe labour practices in cocoa cultivation among adults.',
  ];

  /// The main description text shown at the top of the sensitization page.
  static const String description =
      'Please take a moment to understand the dangers and impact of child labour and to promote child protection and education.';
}

/// Represents the data collected from the Sensitization Questions form.
class SensitizationQuestionsData {
  /// Database primary key
  final int? id;
  
  /// Reference to the cover page record
  final int? coverPageId;

  /// Whether the household has been sensitized
  final bool? hasSensitizedHousehold;

  /// Whether sensitization on protection was conducted
  final bool? hasSensitizedOnProtection;

  /// Whether sensitization on safe labor was conducted
  final bool? hasSensitizedOnSafeLabour;

  /// Number of female adults present during sensitization
  final String femaleAdultsCount;

  /// Number of male adults present during sensitization
  final String maleAdultsCount;

  /// Whether consent was given for taking pictures
  final bool? consentForPicture;

  /// Reason for not giving consent (if applicable)
  final String consentReason;

  /// Path to the sensitization session image
  final String? sensitizationImagePath;

  /// Path to the household with user image
  final String? householdWithUserImagePath;

  /// Observations about parents' reaction to sensitization
  final String parentsReaction;

  /// Timestamp when the form was submitted
  final DateTime submittedAt;
  
  /// Timestamp when the record was created
  final DateTime? createdAt;
  
  /// Timestamp when the record was last updated
  final DateTime? updatedAt;
  
  /// Whether the record has been synced with the server
  final bool? isSynced;
  
  /// Sync status (0 = not synced, 1 = synced, 2 = sync failed)
  final int? syncStatus;

  /// Creates a new instance of [SensitizationQuestionsData].
  SensitizationQuestionsData({
    this.id,
    this.coverPageId,
    this.hasSensitizedHousehold,
    this.hasSensitizedOnProtection,
    this.hasSensitizedOnSafeLabour,
    this.femaleAdultsCount = '',
    this.maleAdultsCount = '',
    this.consentForPicture,
    this.consentReason = '',
    this.sensitizationImagePath,
    this.householdWithUserImagePath,
    this.parentsReaction = '',
    DateTime? submittedAt,
    this.createdAt,
    this.updatedAt,
    this.isSynced = false,
    this.syncStatus = 0,
  }) : submittedAt = submittedAt ?? DateTime.now();

  /// Creates an empty instance with default values.
  factory SensitizationQuestionsData.empty() {
    return SensitizationQuestionsData();
  }

  /// Creates a copy of this [SensitizationQuestionsData] with the given fields replaced.
  SensitizationQuestionsData copyWith({
    int? id,
    int? coverPageId,
    bool? hasSensitizedHousehold,
    bool? hasSensitizedOnProtection,
    bool? hasSensitizedOnSafeLabour,
    String? femaleAdultsCount,
    String? maleAdultsCount,
    bool? consentForPicture,
    String? consentReason,
    String? sensitizationImagePath,
    String? householdWithUserImagePath,
    String? parentsReaction,
    DateTime? submittedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    int? syncStatus,
  }) {
    return SensitizationQuestionsData(
      id: id ?? this.id,
      coverPageId: coverPageId ?? this.coverPageId,
      hasSensitizedHousehold: hasSensitizedHousehold ?? this.hasSensitizedHousehold,
      hasSensitizedOnProtection: hasSensitizedOnProtection ?? this.hasSensitizedOnProtection,
      hasSensitizedOnSafeLabour: hasSensitizedOnSafeLabour ?? this.hasSensitizedOnSafeLabour,
      femaleAdultsCount: femaleAdultsCount ?? this.femaleAdultsCount,
      maleAdultsCount: maleAdultsCount ?? this.maleAdultsCount,
      consentForPicture: consentForPicture ?? this.consentForPicture,
      consentReason: consentReason ?? this.consentReason,
      sensitizationImagePath: sensitizationImagePath ?? this.sensitizationImagePath,
      householdWithUserImagePath: householdWithUserImagePath ?? this.householdWithUserImagePath,
      parentsReaction: parentsReaction ?? this.parentsReaction,
      submittedAt: submittedAt ?? this.submittedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Converts this [SensitizationQuestionsData] to a Map for database storage.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    
    // Only include non-null values
    if (id != null) map['id'] = id;
    if (coverPageId != null) map['cover_page_id'] = coverPageId;
    
    if (hasSensitizedHousehold != null) {
      map['has_sensitized_household'] = hasSensitizedHousehold! ? 1 : 0;
    }
    
    if (hasSensitizedOnProtection != null) {
      map['has_sensitized_on_protection'] = hasSensitizedOnProtection! ? 1 : 0;
    }
    
    if (hasSensitizedOnSafeLabour != null) {
      map['has_sensitized_on_safe_labour'] = hasSensitizedOnSafeLabour! ? 1 : 0;
    }
    
    map['female_adults_count'] = femaleAdultsCount;
    map['male_adults_count'] = maleAdultsCount;
    
    if (consentForPicture != null) {
      map['consent_for_picture'] = consentForPicture! ? 1 : 0;
    }
    
    map['consent_reason'] = consentReason;
    
    if (sensitizationImagePath != null) {
      map['sensitization_image_path'] = sensitizationImagePath;
    }
    
    if (householdWithUserImagePath != null) {
      map['household_with_user_image_path'] = householdWithUserImagePath;
    }
    
    map['parents_reaction'] = parentsReaction;
    map['submitted_at'] = submittedAt.toIso8601String();
    
    // Ensure these fields are always included
    map['created_at'] = (createdAt ?? DateTime.now()).toIso8601String();
    map['updated_at'] = (updatedAt ?? DateTime.now()).toIso8601String();
    map['is_synced'] = (isSynced ?? false) ? 1 : 0;
    map['sync_status'] = syncStatus ?? 0;
    
    return map;
  }

  /// Converts this [SensitizationQuestionsData] to a JSON map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  /// Creates a SensitizationQuestionsData from a Map (e.g., from database).
  factory SensitizationQuestionsData.fromMap(Map<String, dynamic> map) {
    return SensitizationQuestionsData(
      id: map['id'],
      coverPageId: map['cover_page_id'],
      hasSensitizedHousehold: map['has_sensitized_household'] == 1 || map['has_sensitized_household'] == true,
      hasSensitizedOnProtection: map['has_sensitized_on_protection'] == 1 || map['has_sensitized_on_protection'] == true,
      hasSensitizedOnSafeLabour: map['has_sensitized_on_safe_labour'] == 1 || map['has_sensitized_on_safe_labour'] == true,
      femaleAdultsCount: map['female_adults_count']?.toString() ?? '',
      maleAdultsCount: map['male_adults_count']?.toString() ?? '',
      consentForPicture: map['consent_for_picture'] == 1 || map['consent_for_picture'] == true,
      consentReason: map['consent_reason']?.toString() ?? '',
      sensitizationImagePath: map['sensitization_image_path']?.toString(),
      householdWithUserImagePath: map['household_with_user_image_path']?.toString(),
      parentsReaction: map['parents_reaction']?.toString() ?? '',
      submittedAt: map['submitted_at'] is String 
          ? DateTime.tryParse(map['submitted_at']) ?? DateTime.now()
          : map['submitted_at'] ?? DateTime.now(),
      createdAt: map['created_at'] is String 
          ? DateTime.tryParse(map['created_at'])
          : map['created_at'],
      updatedAt: map['updated_at'] is String 
          ? DateTime.tryParse(map['updated_at'])
          : map['updated_at'],
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
      syncStatus: map['sync_status'] is int ? map['sync_status'] : 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SensitizationQuestionsData &&
        other.hasSensitizedHousehold == hasSensitizedHousehold &&
        other.hasSensitizedOnProtection == hasSensitizedOnProtection &&
        other.hasSensitizedOnSafeLabour == hasSensitizedOnSafeLabour &&
        other.femaleAdultsCount == femaleAdultsCount &&
        other.maleAdultsCount == maleAdultsCount &&
        other.consentForPicture == consentForPicture &&
        other.consentReason == consentReason &&
        other.sensitizationImagePath == sensitizationImagePath &&
        other.householdWithUserImagePath == householdWithUserImagePath &&
        other.parentsReaction == parentsReaction;
  }

  @override
  int get hashCode {
    return Object.hash(
      hasSensitizedHousehold,
      hasSensitizedOnProtection,
      hasSensitizedOnSafeLabour,
      femaleAdultsCount,
      maleAdultsCount,
      consentForPicture,
      consentReason,
      sensitizationImagePath,
      householdWithUserImagePath,
      parentsReaction,
    );
  }

  @override
  String toString() {
    return 'SensitizationQuestionsData(' +
        'id: $id, ' +
        'coverPageId: $coverPageId, ' +
        'hasSensitizedHousehold: $hasSensitizedHousehold, ' +
        'hasSensitizedOnProtection: $hasSensitizedOnProtection, ' +
        'hasSensitizedOnSafeLabour: $hasSensitizedOnSafeLabour, ' +
        'femaleAdultsCount: $femaleAdultsCount, ' +
        'maleAdultsCount: $maleAdultsCount, ' +
        'consentForPicture: $consentForPicture, ' +
        'consentReason: $consentReason, ' +
        'sensitizationImagePath: $sensitizationImagePath, ' +
        'householdWithUserImagePath: $householdWithUserImagePath, ' +
        'parentsReaction: $parentsReaction, ' +
        'submittedAt: $submittedAt, ' +
        'createdAt: $createdAt, ' +
        'updatedAt: $updatedAt, ' +
        'isSynced: $isSynced, ' +
        'syncStatus: $syncStatus' +
        ')';
  }
}

class EndOfCollectionModel {
  final int? id;
  final int? coverPageId;
  
  // Image paths (stored as file paths in local storage)
  final String? respondentImagePath;
  final String? producerSignaturePath;
  
  // Location data
  final double? latitude;
  final double? longitude;
  final String? gpsCoordinates; // Formatted as "latitude,longitude"
  
  // Timestamps
  final DateTime? endTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Additional information
  final String? remarks;
  final bool isSynced; // Track if synced with server
  final int syncStatus;

  const EndOfCollectionModel({
    this.id,
    this.coverPageId,
    this.respondentImagePath, 
    this.producerSignaturePath,
    this.latitude,
    this.longitude,
    this.gpsCoordinates,
    this.endTime,
    this.createdAt,
    this.updatedAt,
    this.remarks,
    this.isSynced = false,
    this.syncStatus = 0,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    
    if (id != null) map['id'] = id;
    map['cover_page_id'] = coverPageId;
    map['respondent_image_path'] = respondentImagePath;
    map['producer_signature_path'] = producerSignaturePath;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['gps_coordinates'] = gpsCoordinates;
    map['end_time'] = endTime?.toIso8601String();
    map['remarks'] = remarks;
    map['created_at'] = createdAt?.toIso8601String() ?? DateTime.now().toIso8601String();
    map['updated_at'] = updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String();
    map['is_synced'] = isSynced ? 1 : 0;
    map['sync_status'] = syncStatus;
    
    // Remove null values to prevent SQL errors
    map.removeWhere((key, value) => value == null);
    
    return map;
  }

  // Create from Map (for database retrieval) - IMPROVED VERSION
  factory EndOfCollectionModel.fromMap(Map<String, dynamic> map) {
    try {
      debugPrint('🔍 [EndOfCollection] Parsing from map: $map');
      
      // Parse coordinates with better error handling
      double? parseCoordinate(dynamic value) {
        if (value == null) return null;
        try {
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) {
            final parsed = double.tryParse(value);
            if (parsed != null) return parsed;
          }
          return null;
        } catch (e) {
          debugPrint('❌ Error parsing coordinate: $value, error: $e');
          return null;
        }
      }

      // Parse DateTime with better error handling
      DateTime? parseDateTime(dynamic value) {
        if (value == null) return null;
        try {
          if (value is DateTime) return value;
          if (value is String) return DateTime.tryParse(value);
          return null;
        } catch (e) {
          debugPrint('❌ Error parsing datetime: $value, error: $e');
          return null;
        }
      }

      // Parse GPS coordinates - handle both string and direct lat/lng
      String? gpsCoordinates = map['gps_coordinates']?.toString();
      double? latitude = parseCoordinate(map['latitude']);
      double? longitude = parseCoordinate(map['longitude']);
      
      // If we have lat/lng but no gps_coordinates string, create one
      if (gpsCoordinates == null && latitude != null && longitude != null) {
        gpsCoordinates = '$latitude, $longitude';
      }
      // If we have gps_coordinates string but no lat/lng, parse them
      else if (gpsCoordinates != null && (latitude == null || longitude == null)) {
        try {
          final parts = gpsCoordinates.split(',');
          if (parts.length == 2) {
            latitude = double.tryParse(parts[0].trim());
            longitude = double.tryParse(parts[1].trim());
          }
        } catch (e) {
          debugPrint('❌ Error parsing GPS coordinates: $gpsCoordinates, error: $e');
        }
      }

      final model = EndOfCollectionModel(
        id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
        coverPageId: map['cover_page_id'] is int 
            ? map['cover_page_id'] 
            : int.tryParse(map['cover_page_id']?.toString() ?? ''),
        respondentImagePath: map['respondent_image_path']?.toString(),
        producerSignaturePath: map['producer_signature_path']?.toString(),
        latitude: latitude,
        longitude: longitude,
        gpsCoordinates: gpsCoordinates,
        endTime: parseDateTime(map['end_time']),
        remarks: map['remarks']?.toString(),
        createdAt: parseDateTime(map['created_at']),
        updatedAt: parseDateTime(map['updated_at']),
        isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
        syncStatus: map['sync_status'] is int 
            ? map['sync_status'] 
            : int.tryParse(map['sync_status']?.toString() ?? '0') ?? 0,
      );

      debugPrint('✅ [EndOfCollection] Successfully parsed model:');
      debugPrint('   - Respondent Image: ${model.respondentImagePath}');
      debugPrint('   - Signature: ${model.producerSignaturePath}');
      debugPrint('   - GPS: ${model.gpsCoordinates}');
      debugPrint('   - Lat/Lng: ${model.latitude}, ${model.longitude}');
      debugPrint('   - End Time: ${model.endTime}');
      
      return model;
    } catch (e, stackTrace) {
      debugPrint('❌ [EndOfCollection] Error creating EndOfCollectionModel: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      // Return a default model instead of throwing
      return EndOfCollectionModel(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Create a copy with some fields updated
  EndOfCollectionModel copyWith({
    int? id,
    int? coverPageId,
    String? respondentImagePath,
    String? producerSignaturePath,
    double? latitude,
    double? longitude,
    String? gpsCoordinates,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? remarks,
    bool? isSynced,
    int? syncStatus,
  }) {
    return EndOfCollectionModel(
      id: id ?? this.id,
      coverPageId: coverPageId ?? this.coverPageId,
      respondentImagePath: respondentImagePath ?? this.respondentImagePath,
      producerSignaturePath: producerSignaturePath ?? this.producerSignaturePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remarks: remarks ?? this.remarks,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  // Create an empty instance
  factory EndOfCollectionModel.empty() => EndOfCollectionModel(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  // Check if the model has any data
  bool get hasData {
    return respondentImagePath != null ||
        producerSignaturePath != null ||
        gpsCoordinates != null ||
        endTime != null ||
        remarks != null;
  }

  // Check if images are available
  bool get hasImages {
    return (respondentImagePath?.isNotEmpty == true) ||
        (producerSignaturePath?.isNotEmpty == true);
  }

  // Check if location data is available
  bool get hasLocation {
    return gpsCoordinates?.isNotEmpty == true ||
        (latitude != null && longitude != null);
  }

  @override
  String toString() {
    return 'EndOfCollectionModel{\n'
           '  id: $id,\n'
           '  coverPageId: $coverPageId,\n'
           '  respondentImagePath: $respondentImagePath,\n'
           '  producerSignaturePath: $producerSignaturePath,\n'
           '  latitude: $latitude,\n'
           '  longitude: $longitude,\n'
           '  gpsCoordinates: $gpsCoordinates,\n'
           '  endTime: $endTime,\n'
           '  remarks: $remarks,\n'
           '  createdAt: $createdAt,\n'
           '  updatedAt: $updatedAt,\n'
           '  isSynced: $isSynced,\n'
           '  syncStatus: $syncStatus\n'
           '}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EndOfCollectionModel &&
        other.id == id &&
        other.coverPageId == coverPageId &&
        other.respondentImagePath == respondentImagePath &&
        other.producerSignaturePath == producerSignaturePath &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.gpsCoordinates == gpsCoordinates &&
        other.endTime == endTime &&
        other.remarks == remarks &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      coverPageId,
      respondentImagePath,
      producerSignaturePath,
      latitude,
      longitude,
      gpsCoordinates,
      endTime,
      remarks,
      isSynced,
    );
  }
}