// models/household_model.dart
import 'package:geolocator/geolocator.dart';

/// Comprehensive model representing a household assessment including cover page and consent data
class HouseholdModel {
  // Cover Page Fields
  int? id;
  String selectedTown;
  String selectedTownName;
  String selectedFarmer;
  String selectedFarmerName;

  // Consent Fields
  DateTime? interviewStartTime;
  String timeStatus;
  double? latitude;
  double? longitude;
  String locationStatus;
  bool isGettingLocation;
  String? communityType;
  String? residesInCommunityConsent;
  String? farmerAvailable;
  String? farmerStatus;
  String? availablePerson;
  String? otherSpecification;
  String? otherCommunityName;
  bool consentGiven;
  String? refusalReason;
  DateTime? consentTimestamp;

  // Farmer Identification Fields
  String? farmerGhCardAvailable; // 'yes' or 'no'
  String? farmerNatIdAvailable; // 'ghana_card', 'voter', 'nhis', etc.
  String? idPictureConsent; // 'Yes' or 'No'
  String? idImagePath;
  String? ghanaCardNumber;
  String? idNumber;
  String? idRejectionReason;
  String? contactNumber;
  int children5_17Count;
  List<Map<String, dynamic>> children;

  // Metadata
  String createdAt;
  String updatedAt;
  int status; // 0 = draft, 1 = completed, 2 = submitted, 3 = synced
  int syncStatus; // 0 = not synced, 1 = synced

  HouseholdModel({
    // Cover Page
    this.id,
    required this.selectedTown,
    required this.selectedTownName,
    required this.selectedFarmer,
    required this.selectedFarmerName,

    // Consent
    this.interviewStartTime,
    this.timeStatus = 'Not recorded',
    this.latitude,
    this.longitude,
    this.locationStatus = 'Not recorded',
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

    // Farmer Identification
    this.farmerGhCardAvailable,
    this.farmerNatIdAvailable,
    this.idPictureConsent,
    this.idImagePath,
    this.ghanaCardNumber,
    this.idNumber,
    this.idRejectionReason,
    this.contactNumber,
    this.children5_17Count = 0,
    List<Map<String, dynamic>>? children,

    // Metadata
    required this.createdAt,
    required this.updatedAt,
    this.status = 0,
    this.syncStatus = 0,
  }) : children = children ?? [];

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      // Cover Page Data
      'id': id,
      'selectedTown': selectedTown,
      'selectedTownName': selectedTownName,
      'selectedFarmer': selectedFarmer,
      'selectedFarmerName': selectedFarmerName,

      // Consent Data
      'interviewStartTime': interviewStartTime?.toIso8601String(),
      'timeStatus': timeStatus,
      'latitude': latitude,
      'longitude': longitude,
      'locationStatus': locationStatus,
      'isGettingLocation': isGettingLocation ? 1 : 0,
      'communityType': communityType,
      'residesInCommunityConsent': residesInCommunityConsent,
      'farmerAvailable': farmerAvailable,
      'farmerStatus': farmerStatus,
      'availablePerson': availablePerson,
      'otherSpecification': otherSpecification,
      'otherCommunityName': otherCommunityName,
      'consentGiven': consentGiven ? 1 : 0,
      'refusalReason': refusalReason,
      'consentTimestamp': consentTimestamp?.toIso8601String(),

      // Farmer Identification Data
      'farmer_gh_card_available': farmerGhCardAvailable,
      'farmer_nat_id_available': farmerNatIdAvailable,
      'id_picture_consent': idPictureConsent,
      'id_image_path': idImagePath,
      'ghana_card_number': ghanaCardNumber,
      'id_number': idNumber,
      'id_rejection_reason': idRejectionReason,
      'contact_number': contactNumber,
      'children_5_17_count': children5_17Count,
      'children': children,

      // Metadata
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      'syncStatus': syncStatus,
    };
  }

  /// Create from Map from database
  factory HouseholdModel.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> childrenList = [];

    if (map['children'] != null && map['children'] is List) {
      childrenList = List<Map<String, dynamic>>.from(map['children'] as List);
    }

    return HouseholdModel(
      // Cover Page
      id: map['id'] as int?,
      selectedTown: map['selectedTown'] ?? '',
      selectedTownName: map['selectedTownName'] ?? '',
      selectedFarmer: map['selectedFarmer'] ?? '',
      selectedFarmerName: map['selectedFarmerName'] ?? '',

      // Consent
      interviewStartTime: map['interviewStartTime'] != null
          ? DateTime.parse(map['interviewStartTime'] as String)
          : null,
      timeStatus: map['timeStatus'] as String? ?? 'Not recorded',
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      locationStatus: map['locationStatus'] as String? ?? 'Not recorded',
      isGettingLocation: (map['isGettingLocation'] as int?) == 1,
      communityType: map['communityType'] as String?,
      residesInCommunityConsent: map['residesInCommunityConsent'] as String?,
      farmerAvailable: map['farmerAvailable'] as String?,
      farmerStatus: map['farmerStatus'] as String?,
      availablePerson: map['availablePerson'] as String?,
      otherSpecification: map['otherSpecification'] as String?,
      otherCommunityName: map['otherCommunityName'] as String?,
      consentGiven: (map['consentGiven'] as int?) == 1,
      refusalReason: map['refusalReason'] as String?,
      consentTimestamp: map['consentTimestamp'] != null
          ? DateTime.parse(map['consentTimestamp'] as String)
          : null,

      // Farmer Identification
      farmerGhCardAvailable: map['farmer_gh_card_available'] as String?,
      farmerNatIdAvailable: map['farmer_nat_id_available'] as String?,
      idPictureConsent: map['id_picture_consent'] as String?,
      idImagePath: map['id_image_path'] as String?,
      ghanaCardNumber: map['ghana_card_number'] as String?,
      idNumber: map['id_number'] as String?,
      idRejectionReason: map['id_rejection_reason'] as String?,
      contactNumber: map['contact_number'] as String?,
      children5_17Count: map['children_5_17_count'] as int? ?? 0,
      children: childrenList,

      // Metadata
      createdAt: map['createdAt'] as String? ?? DateTime.now().toString(),
      updatedAt: map['updatedAt'] as String? ?? DateTime.now().toString(),
      status: map['status'] as int? ?? 0,
      syncStatus: map['syncStatus'] as int? ?? 0,
    );
  }

  /// Copy with method for immutability
  HouseholdModel copyWith({
    // Cover Page
    int? id,
    String? selectedTown,
    String? selectedTownName,
    String? selectedFarmer,
    String? selectedFarmerName,

    // Consent
    DateTime? interviewStartTime,
    String? timeStatus,
    double? latitude,
    double? longitude,
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

    // Farmer Identification
    String? farmerGhCardAvailable,
    String? farmerNatIdAvailable,
    String? idPictureConsent,
    String? idImagePath,
    String? ghanaCardNumber,
    String? idNumber,
    String? idRejectionReason,
    String? contactNumber,
    int? children5_17Count,
    List<Map<String, dynamic>>? children,

    // Metadata
    String? createdAt,
    String? updatedAt,
    int? status,
    int? syncStatus,
  }) {
    return HouseholdModel(
      id: id ?? this.id,
      selectedTown: selectedTown ?? this.selectedTown,
      selectedTownName: selectedTownName ?? this.selectedTownName,
      selectedFarmer: selectedFarmer ?? this.selectedFarmer,
      selectedFarmerName: selectedFarmerName ?? this.selectedFarmerName,
      interviewStartTime: interviewStartTime ?? this.interviewStartTime,
      timeStatus: timeStatus ?? this.timeStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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

      // Farmer Identification
      farmerGhCardAvailable: farmerGhCardAvailable ?? this.farmerGhCardAvailable,
      farmerNatIdAvailable: farmerNatIdAvailable ?? this.farmerNatIdAvailable,
      idPictureConsent: idPictureConsent ?? this.idPictureConsent,
      idImagePath: idImagePath ?? this.idImagePath,
      ghanaCardNumber: ghanaCardNumber ?? this.ghanaCardNumber,
      idNumber: idNumber ?? this.idNumber,
      idRejectionReason: idRejectionReason ?? this.idRejectionReason,
      contactNumber: contactNumber ?? this.contactNumber,
      children5_17Count: children5_17Count ?? this.children5_17Count,
      children: children ?? this.children,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Helper method to create from dropdown selections
  static HouseholdModel fromSelections({
    String? townCode,
    String? townName,
    String? farmerCode,
    String? farmerName,
  }) {
    return HouseholdModel(
      selectedTown: townCode ?? '',
      selectedTownName: townName ?? '',
      selectedFarmer: farmerCode ?? '',
      selectedFarmerName: farmerName ?? '',
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
    );
  }

  /// Update with GPS position
  HouseholdModel updateWithPosition(Position position) {
    return copyWith(
      latitude: position.latitude,
      longitude: position.longitude,
      locationStatus: 'Recorded',
      isGettingLocation: false,
      updatedAt: DateTime.now().toString(),
    );
  }

  /// Record interview start time
  HouseholdModel recordInterviewTime() {
    return copyWith(
      interviewStartTime: DateTime.now(),
      timeStatus: 'Recorded at ${DateTime.now().toIso8601String()}',
      updatedAt: DateTime.now().toString(),
    );
  }

  /// Update consent decision
  HouseholdModel updateConsent(bool given, {String? reason}) {
    return copyWith(
      consentGiven: given,
      refusalReason: reason,
      consentTimestamp: given ? DateTime.now() : null,
      updatedAt: DateTime.now().toString(),
      status: given ? 1 : 0,
    );
  }

  /// Update farmer identification data
  HouseholdModel updateFarmerIdentification({
    String? farmerGhCardAvailable,
    String? farmerNatIdAvailable,
    String? idPictureConsent,
    String? idImagePath,
    String? ghanaCardNumber,
    String? idNumber,
    String? idRejectionReason,
    String? contactNumber,
    int? children5_17Count,
    List<Map<String, dynamic>>? children,
  }) {
    return copyWith(
      farmerGhCardAvailable: farmerGhCardAvailable,
      farmerNatIdAvailable: farmerNatIdAvailable,
      idPictureConsent: idPictureConsent,
      idImagePath: idImagePath,
      ghanaCardNumber: ghanaCardNumber,
      idNumber: idNumber,
      idRejectionReason: idRejectionReason,
      contactNumber: contactNumber,
      children5_17Count: children5_17Count,
      children: children,
      updatedAt: DateTime.now().toString(),
    );
  }

  // ====================================================================
  // BUSINESS LOGIC AND VALIDATION METHODS
  // ====================================================================

  /// Check if cover page is complete (both town and farmer selected)
  bool get isCoverPageComplete =>
      selectedTown.isNotEmpty && selectedFarmer.isNotEmpty;

  /// Check if interview time is recorded
  bool get hasInterviewTime => interviewStartTime != null;

  /// Check if location is recorded
  bool get hasLocation => latitude != null && longitude != null;

  /// Get formatted interview time
  String get formattedInterviewTime => interviewStartTime != null
      ? '${interviewStartTime!.hour}:${interviewStartTime!.minute.toString().padLeft(2, '0')}'
      : 'Not recorded';

  /// Get formatted coordinates
  String get formattedCoordinates => hasLocation
      ? 'Lat: ${latitude!.toStringAsFixed(6)}, Lon: ${longitude!.toStringAsFixed(6)}'
      : 'No coordinates';

  /// Check if farmer identification section is complete
  bool get isFarmerIdentificationComplete {
    // Basic required fields
    if (farmerGhCardAvailable == null || contactNumber == null) {
      return false;
    }

    // Validate Ghana Card flow
    if (farmerGhCardAvailable == 'yes') {
      if (idPictureConsent == 'Yes') {
        return ghanaCardNumber != null &&
            ghanaCardNumber!.isNotEmpty &&
            idImagePath != null;
      } else if (idPictureConsent == 'No') {
        return idRejectionReason != null && idRejectionReason!.isNotEmpty;
      }
    }

    // Validate alternative ID flow
    if (farmerGhCardAvailable == 'no') {
      if (farmerNatIdAvailable == null) return false;

      if (idPictureConsent == 'Yes') {
        return idNumber != null &&
            idNumber!.isNotEmpty &&
            idImagePath != null;
      } else if (idPictureConsent == 'No') {
        return idRejectionReason != null && idRejectionReason!.isNotEmpty;
      }
    }

    return idPictureConsent != null;
  }

  /// Get display name for ID type
  String get idTypeDisplayName {
    switch (farmerNatIdAvailable) {
      case 'ghana_card':
        return 'Ghana Card';
      case 'voter':
        return 'Voter ID';
      case 'nhis':
        return 'NHIS Card';
      case 'passport':
        return 'Passport';
      case 'driver':
        return "Driver's License";
      case 'ssnit':
        return 'SSNIT';
      case 'birth':
        return 'Birth Certificate';
      default:
        return 'ID Card';
    }
  }

  /// Validate contact number format
  bool get isContactNumberValid {
    if (contactNumber == null || contactNumber!.isEmpty) return false;
    return contactNumber!.length == 10 &&
        int.tryParse(contactNumber!) != null;
  }

  /// Determine if consent section should be shown based on business logic
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

  /// Check if survey should end based on certain conditions
  bool get shouldEndSurvey {
    return !consentGiven ||
        farmerStatus == 'Deceased' ||
        farmerStatus == 'Doesn\'t work with TOUTON anymore' ||
        availablePerson == 'Nobody';
  }

  /// Validate if all required fields for submission are filled
  bool get isValidForSubmission {
    return isCoverPageComplete &&
        hasInterviewTime &&
        hasLocation &&
        communityType != null &&
        residesInCommunityConsent != null &&
        farmerAvailable != null &&
        _validateFarmerAvailability() &&
        _validateConsentSection() &&
        isFarmerIdentificationComplete;
  }

  bool _validateFarmerAvailability() {
    if (farmerAvailable == 'No') {
      if (farmerStatus == null) return false;

      if (farmerStatus == 'Other' &&
          (otherSpecification == null || otherSpecification!.isEmpty)) {
        return false;
      }

      if ((farmerStatus == 'Non-resident' || farmerStatus == 'Other') &&
          availablePerson == null) {
        return false;
      }

      if (residesInCommunityConsent == 'No' &&
          (otherCommunityName == null || otherCommunityName!.isEmpty)) {
        return false;
      }
    }
    return true;
  }

  bool _validateConsentSection() {
    if (!shouldShowConsentSection) return true;

    if (!consentGiven && refusalReason?.isEmpty != false) {
      return false;
    }

    return consentGiven || (!consentGiven && refusalReason?.isNotEmpty == true);
  }

  /// Check if can proceed to next section after consent
  bool get canProceedToNext {
    return isValidForSubmission && consentGiven;
  }

  /// Get current progress percentage (0-100)
  double get progressPercentage {
    int completedFields = 0;
    int totalFields = 0;

    // Cover page fields
    totalFields += 2;
    if (isCoverPageComplete) completedFields += 2;

    // Consent required fields
    totalFields += 4;
    if (hasInterviewTime) completedFields++;
    if (hasLocation) completedFields++;
    if (communityType != null) completedFields++;
    if (residesInCommunityConsent != null) completedFields++;

    // Farmer availability fields
    if (farmerAvailable != null) {
      completedFields++;
      if (farmerAvailable == 'No') {
        totalFields += 2;
        if (farmerStatus != null) completedFields++;
        if (_validateFarmerAvailability()) completedFields++;
      }
    } else {
      totalFields++;
    }

    // Consent section if applicable
    if (shouldShowConsentSection) {
      totalFields++;
      if (consentGiven || (refusalReason?.isNotEmpty == true))
        completedFields++;
    }

    // Farmer identification fields
    totalFields += 2;
    if (farmerGhCardAvailable != null) completedFields++;
    if (contactNumber != null && isContactNumberValid) completedFields++;

    if (farmerGhCardAvailable == 'yes') {
      totalFields += 1;
      if (idPictureConsent != null) completedFields++;

      if (idPictureConsent == 'Yes') {
        totalFields += 2;
        if (ghanaCardNumber != null && ghanaCardNumber!.isNotEmpty) completedFields++;
        if (idImagePath != null) completedFields++;
      } else if (idPictureConsent == 'No') {
        totalFields += 1;
        if (idRejectionReason != null && idRejectionReason!.isNotEmpty) completedFields++;
      }
    }

    if (farmerGhCardAvailable == 'no') {
      totalFields += 2;
      if (farmerNatIdAvailable != null) completedFields++;
      if (idPictureConsent != null) completedFields++;

      if (idPictureConsent == 'Yes') {
        totalFields += 2;
        if (idNumber != null && idNumber!.isNotEmpty) completedFields++;
        if (idImagePath != null) completedFields++;
      } else if (idPictureConsent == 'No') {
        totalFields += 1;
        if (idRejectionReason != null && idRejectionReason!.isNotEmpty) completedFields++;
      }
    }

    return totalFields > 0 ? (completedFields / totalFields) * 100 : 0;
  }

  /// Get a summary of the household data for display
  Map<String, String> get summary {
    return {
      'Town': selectedTownName,
      'Farmer': selectedFarmerName,
      'Interview Time': formattedInterviewTime,
      'Location': hasLocation ? 'Recorded' : 'Not recorded',
      'Community Type': communityType ?? 'Not selected',
      'Consent': consentGiven
          ? 'Given'
          : (refusalReason != null ? 'Declined' : 'Pending'),
      'Farmer ID': isFarmerIdentificationComplete ? 'Complete' : 'Incomplete',
      'Status': _getStatusText(),
    };
  }

  String _getStatusText() {
    switch (status) {
      case 0:
        return 'Draft';
      case 1:
        return 'Completed';
      case 2:
        return 'Submitted';
      case 3:
        return 'Synced';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'HouseholdModel{id: $id, town: $selectedTownName, farmer: $selectedFarmerName, consent: $consentGiven, farmerID: $isFarmerIdentificationComplete, status: $status, sync: $syncStatus}';
  }

  /// Debug method to print all fields
  void debugPrint() {
    print('=== HOUSEHOLD MODEL DEBUG INFO ===');
    print('Cover Page:');
    print('  - Town: $selectedTownName ($selectedTown)');
    print('  - Farmer: $selectedFarmerName ($selectedFarmer)');
    print('Consent Data:');
    print('  - Interview Time: $formattedInterviewTime');
    print('  - Location: $formattedCoordinates');
    print('  - Community Type: $communityType');
    print('  - Resides in Community: $residesInCommunityConsent');
    print('  - Farmer Available: $farmerAvailable');
    print('  - Farmer Status: $farmerStatus');
    print('  - Available Person: $availablePerson');
    print('  - Consent Given: $consentGiven');
    print('  - Refusal Reason: $refusalReason');
    print('Farmer Identification:');
    print('  - Ghana Card Available: $farmerGhCardAvailable');
    print('  - ID Type: $farmerNatIdAvailable');
    print('  - Picture Consent: $idPictureConsent');
    print('  - Contact Number: $contactNumber');
    print('  - Children Count: $children5_17Count');
    print('  - Children: $children');
    print('Metadata:');
    print('  - Status: ${_getStatusText()}');
    print('  - Sync Status: ${syncStatus == 1 ? "Synced" : "Not Synced"}');
    print('  - Created: $createdAt');
    print('  - Updated: $updatedAt');
    print('==================================');
  }
}