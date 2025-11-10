import 'dart:convert';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart' show required;

import '../../data/dummy_data/cover_dummy_data.dart';
import 'dropdown_item_model.dart';

export 'dropdown_item_model.dart';

class CoverPageData {
  /// Database ID
  final int? id;

  /// Creates an empty CoverPageData instance with default values
  factory CoverPageData.empty() => CoverPageData(
        id: null,
        selectedTownCode: null,
        selectedFarmerCode: null,
        towns: CoverDummyData.dummyTowns, // Use dummy towns data
        farmers: CoverDummyData.getDummyFarmers(
            'T001'), // Use dummy farmers data for first town
        townError: null,
        farmerError: null,
        isLoadingTowns: false,
        isLoadingFarmers: false,
        hasUnsavedChanges: false,
        member: null,
      );
      
  /// Creates a CoverPageData from a database map
  factory CoverPageData.fromMap(Map<String, dynamic> map) {
    return CoverPageData(
      id: map['id'],
      selectedTownCode: map['selectedTownCode'],
      selectedFarmerCode: map['selectedFarmerCode'],
      towns: (map['towns'] as List<dynamic>?)?.map((item) => DropdownItem.fromMap(Map<String, dynamic>.from(item))).toList() ?? [],
      farmers: (map['farmers'] as List<dynamic>?)?.map((item) => DropdownItem.fromMap(Map<String, dynamic>.from(item))).toList() ?? [],
      townError: map['townError'],
      farmerError: map['farmerError'],
      isLoadingTowns: map['isLoadingTowns'] == 1,
      isLoadingFarmers: map['isLoadingFarmers'] == 1,
      hasUnsavedChanges: map['hasUnsavedChanges'] == 1,
      member: map['member'] != null ? Map<String, dynamic>.from(map['member']) : null,
    );
  }

  /// Creates a CoverPageData instance with test data
  factory CoverPageData.test() {
    return CoverDummyData.testCoverData;
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
  bool get isComplete =>
      _selectedTownCode != null && _selectedFarmerCode != null;

  /// Converts the object to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'selectedTownCode': selectedTownCode,
      'selectedFarmerCode': selectedFarmerCode,
      'towns': towns.map((item) => item.toMap()).toList(),
      'farmers': farmers.map((item) => item.toMap()).toList(),
      'townError': townError,
      'farmerError': farmerError,
      'isLoadingTowns': isLoadingTowns ? 1 : 0,
      'isLoadingFarmers': isLoadingFarmers ? 1 : 0,
      'hasUnsavedChanges': hasUnsavedChanges ? 1 : 0,
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
  })  : _selectedTownCode = selectedTownCode,
        _selectedFarmerCode = selectedFarmerCode,
        _towns = towns ?? [],
        _farmers = farmers ?? [],
        _townError = townError,
        _farmerError = farmerError,
        _isLoadingTowns = isLoadingTowns ?? false,
        _isLoadingFarmers = isLoadingFarmers ?? false,
        hasUnsavedChanges = hasUnsavedChanges ?? false;

  /// Update town selection
  CoverPageData selectTown(String? townCode) {
    return copyWith(
      selectedTownCode: townCode,
      hasUnsavedChanges: true,
    );
  }

  /// Update farmer selection
  CoverPageData selectFarmer(String? farmerCode) {
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
      'consentGiven': consentGiven == true ? 1 : 0,
      'declinedConsent': declinedConsent == true ? 1 : 0,
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
      'isGettingLocation': isGettingLocation == true ? 1 : 0,
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
      consentGiven: map['consentGiven'] == 1,
      declinedConsent: map['declinedConsent'] == 1,
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
      isGettingLocation: map['isGettingLocation'] == 1,
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

/// Model for Farmer Child data
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

/// Main model for Farmer Identification Page data
class FarmerIdentificationData {
  final int? id;
  final int? coverPageId;
  final int hasGhanaCard; // 0 or 1
  final String? ghanaCardNumber;
  final String? selectedIdType;
  final String? idNumber;
  final int idPictureConsent; // 0 or 1
  final String? noConsentReason;
  final String? idImagePath;
  final String? contactNumber;
  final int childrenCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isSynced;
  final int syncStatus;
  final List<FarmerChild> children;

  // Controllers for form fields
  final TextEditingController ghanaCardNumberController;
  final TextEditingController idNumberController;
  final TextEditingController contactNumberController;
  final TextEditingController childrenCountController;
  final TextEditingController noConsentReasonController;

  FarmerIdentificationData({
    this.id,
    this.coverPageId,
    this.hasGhanaCard = 0,
    this.ghanaCardNumber,
    this.selectedIdType,
    this.idNumber,
    this.idPictureConsent = 0,
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
    TextEditingController? childrenCountController,
    TextEditingController? noConsentReasonController,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        children = children ?? [],
        ghanaCardNumberController = ghanaCardNumberController ?? TextEditingController(),
        idNumberController = idNumberController ?? TextEditingController(),
        contactNumberController = contactNumberController ?? TextEditingController(),
        childrenCountController = childrenCountController ?? TextEditingController(),
        noConsentReasonController = noConsentReasonController ?? TextEditingController() {
    _initializeControllers();
  }

  void _initializeControllers() {
    // Only initialize if controller is empty to preserve user input
    if (ghanaCardNumberController.text.isEmpty && ghanaCardNumber != null) {
      ghanaCardNumberController.text = ghanaCardNumber!;
    }
    if (idNumberController.text.isEmpty && idNumber != null) {
      idNumberController.text = idNumber!;
    }
    if (contactNumberController.text.isEmpty && contactNumber != null) {
      contactNumberController.text = contactNumber!;
    }
    if (childrenCountController.text.isEmpty && childrenCount > 0) {
      childrenCountController.text = childrenCount.toString();
    }
    if (noConsentReasonController.text.isEmpty && noConsentReason != null) {
      noConsentReasonController.text = noConsentReason!;
    }
  }

  /// Convert to Map for storage/API
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cover_page_id': coverPageId,
      'has_ghana_card': hasGhanaCard,
      'ghana_card_number': ghanaCardNumberController.text.isNotEmpty ? ghanaCardNumberController.text : ghanaCardNumber,
      'selected_id_type': selectedIdType,
      'id_number': idNumberController.text.isNotEmpty ? idNumberController.text : idNumber,
      'id_picture_consent': idPictureConsent,
      'no_consent_reason': noConsentReasonController.text.isNotEmpty ? noConsentReasonController.text : noConsentReason,
      'id_image_path': idImagePath,
      'contact_number': contactNumberController.text.isNotEmpty ? contactNumberController.text : contactNumber,
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
      hasGhanaCard: map['has_ghana_card'] as int? ?? 0,
      ghanaCardNumber: map['ghana_card_number']?.toString(),
      selectedIdType: map['selected_id_type']?.toString(),
      idNumber: map['id_number']?.toString(),
      idPictureConsent: map['id_picture_consent'] as int? ?? 0,
      noConsentReason: map['no_consent_reason']?.toString(),
      idImagePath: map['id_image_path']?.toString(),
      contactNumber: map['contact_number']?.toString(),
      childrenCount: map['children_count'] as int? ?? 0,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isSynced: map['is_synced'] as int? ?? 0,
      syncStatus: map['sync_status'] as int? ?? 0,
    );
  }

  /// Create empty instance
  factory FarmerIdentificationData.empty() {
    return FarmerIdentificationData();
  }

  /// Update methods that return new instances
  FarmerIdentificationData updateGhanaCard(int value) {
    return copyWith(
      hasGhanaCard: value,
      selectedIdType: value == 1 ? null : selectedIdType,
      idPictureConsent: 0,
      idImagePath: null,
      preserveControllers: true,
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
    final consentValue = value == 'Yes' ? 1 : 0;
    return copyWith(
      idPictureConsent: consentValue,
      idImagePath: consentValue == 0 ? null : idImagePath,
      preserveControllers: true,
    );
  }

  FarmerIdentificationData updateGhanaCardNumber(String value) {
    ghanaCardNumberController.text = value;
    return copyWith(
      ghanaCardNumber: value,
      preserveControllers: true,
    );
  }

  FarmerIdentificationData updateIdNumber(String value) {
    idNumberController.text = value;
    return copyWith(
      idNumber: value,
      preserveControllers: true,
    );
  }

  FarmerIdentificationData updateNoConsentReason(String value) {
    noConsentReasonController.text = value;
    return copyWith(
      noConsentReason: value,
      preserveControllers: true,
    );
  }

  FarmerIdentificationData updateContactNumber(String value) {
    contactNumberController.text = value;
    return copyWith(
      contactNumber: value,
      preserveControllers: true,
    );
  }

  FarmerIdentificationData updateChildrenCount(String value) {
    final count = int.tryParse(value) ?? 0;
    childrenCountController.text = value;
    return copyWith(
      childrenCount: count,
      preserveControllers: true,
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
    
    final cardNumber = ghanaCardNumberController.text.trim();
    
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
    
    final idNumber = idNumberController.text.trim();
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
    final contactNumber = contactNumberController.text.trim();
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
    final childrenCountText = childrenCountController.text.trim();
    final count = int.tryParse(childrenCountText) ?? 0;
    
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
    
    final reason = noConsentReasonController.text.trim();
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
    List<FarmerChild>? children,
    bool preserveControllers = false,
  }) {
    if (preserveControllers) {
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
        children: children ?? List.from(this.children),
        ghanaCardNumberController: this.ghanaCardNumberController,
        idNumberController: this.idNumberController,
        contactNumberController: this.contactNumberController,
        childrenCountController: this.childrenCountController,
        noConsentReasonController: this.noConsentReasonController,
      );
    } else {
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
        children: children ?? List.from(this.children),
      );
    }
  }

  /// Prepares the data for submission by ensuring all fields are properly formatted
  Map<String, dynamic> prepareSubmissionData() {
    return {
      'hasGhanaCard': hasGhanaCard,
      'selectedIdType': selectedIdType,
      'idPictureConsent': idPictureConsent,
      'ghanaCardNumber': ghanaCardNumberController.text,
      'idNumber': idNumberController.text,
      'noConsentReason': noConsentReasonController.text,
      'idImagePath': idImagePath,
      'contactNumber': contactNumberController.text,
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

// Extension for firstOrNull on List
extension FirstWhereOrNullExtension<T> on List<T> {
  T? firstOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

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
      if (id != null) 'id': id,
      
      // Nested models
      'visitInformation': visitInformation?.toMap(),
      'ownerInformation': ownerInformation?.toMap(),
      'workersInFarm': workersInFarm?.toMap(),
      'adultsInformation': adultsInformation?.toMap(),
      
      // Metadata
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Create from Map (for database retrieval)
  factory CombinedFarmerIdentificationModel.fromMap(Map<String, dynamic> map) {
    return CombinedFarmerIdentificationModel(
      id: map['id'],
      
      // Nested models
      visitInformation: map['visitInformation'] != null 
          ? VisitInformationData.fromMap(Map<String, dynamic>.from(map['visitInformation']))
          : null,
      ownerInformation: map['ownerInformation'] != null
          ? IdentificationOfOwnerData.fromMap(Map<String, dynamic>.from(map['ownerInformation']))
          : null,
      workersInFarm: map['workersInFarm'] != null
          ? WorkersInFarmData.fromMap(Map<String, dynamic>.from(map['workersInFarm']))
          : null,
      adultsInformation: map['adultsInformation'] != null
          ? AdultsInformationData.fromMap(Map<String, dynamic>.from(map['adultsInformation']))
          : null,
      
      // Metadata
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isSynced: map['isSynced'] == 1,
    );
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
