import 'package:flutter/material.dart';

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
  final String? hasGhanaCard; // 'Yes' or 'No'
  final String? selectedIdType;
  final String? idPictureConsent; // 'Yes' or 'No'
  final String? ghanaCardNumber;
  final String? idNumber;
  final String? noConsentReason;
  final String? idImagePath;
  final String? contactNumber;
  final int childrenCount;
  final List<FarmerChild> children;

  // Controllers for form fields
  final TextEditingController ghanaCardNumberController;
  final TextEditingController idNumberController;
  final TextEditingController contactNumberController;
  final TextEditingController childrenCountController;
  final TextEditingController noConsentReasonController;

  FarmerIdentificationData({
    this.hasGhanaCard,
    this.selectedIdType,
    this.idPictureConsent,
    this.ghanaCardNumber,
    this.idNumber,
    this.noConsentReason,
    this.idImagePath,
    this.contactNumber,
    this.childrenCount = 0,
    List<FarmerChild>? children,
    TextEditingController? ghanaCardNumberController,
    TextEditingController? idNumberController,
    TextEditingController? contactNumberController,
    TextEditingController? childrenCountController,
    TextEditingController? noConsentReasonController,
  })  : children = children ?? [],
        ghanaCardNumberController = ghanaCardNumberController ?? TextEditingController(),
        idNumberController = idNumberController ?? TextEditingController(),
        contactNumberController = contactNumberController ?? TextEditingController(),
        childrenCountController = childrenCountController ?? TextEditingController(),
        noConsentReasonController = noConsentReasonController ?? TextEditingController() {
    // Initialize controller texts from field values
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
      'hasGhanaCard': hasGhanaCard,
      'selectedIdType': selectedIdType,
      'idPictureConsent': idPictureConsent,
      'ghanaCardNumber': ghanaCardNumberController.text.isNotEmpty ? ghanaCardNumberController.text : ghanaCardNumber,
      'idNumber': idNumberController.text.isNotEmpty ? idNumberController.text : idNumber,
      'noConsentReason': noConsentReasonController.text.isNotEmpty ? noConsentReasonController.text : noConsentReason,
      'idImagePath': idImagePath,
      'contactNumber': contactNumberController.text.isNotEmpty ? contactNumberController.text : contactNumber,
      'childrenCount': childrenCount,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }

  /// Create from Map from storage/API
  factory FarmerIdentificationData.fromMap(Map<String, dynamic> map) {
    return FarmerIdentificationData(
      hasGhanaCard: map['hasGhanaCard']?.toString(),
      selectedIdType: map['selectedIdType']?.toString(),
      idPictureConsent: map['idPictureConsent']?.toString(),
      ghanaCardNumber: map['ghanaCardNumber']?.toString(),
      idNumber: map['idNumber']?.toString(),
      noConsentReason: map['noConsentReason']?.toString(),
      idImagePath: map['idImagePath']?.toString(),
      contactNumber: map['contactNumber']?.toString(),
      childrenCount: map['childrenCount'] as int? ?? 0,
      children: (map['children'] as List<dynamic>? ?? [])
          .map((childMap) => FarmerChild.fromMap(childMap as Map<String, dynamic>)).toList(),
    );
  }

  /// Create empty instance
  factory FarmerIdentificationData.empty() {
    return FarmerIdentificationData();
  }

  /// Update methods that return new instances - FIXED: Preserve existing controllers
  FarmerIdentificationData updateGhanaCard(String? value) {
    return copyWith(
      hasGhanaCard: value,
      selectedIdType: value == 'Yes' ? null : selectedIdType,
      idPictureConsent: null,
      idImagePath: null,
      // Preserve existing controllers
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
    return copyWith(
      idPictureConsent: value,
      idImagePath: value == 'No' ? null : idImagePath,
      preserveControllers: true,
    );
  }

  FarmerIdentificationData updateGhanaCardNumber(String value) {
    // Update the controller text immediately
    ghanaCardNumberController.text = value;
    return copyWith(
      ghanaCardNumber: value,
      preserveControllers: true, // Keep the same controller
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

  // Validation methods - FIXED: Use controller text for validation
  String? validateGhanaCardNumber() {
    // Only validate if hasGhanaCard is 'Yes'
    if (hasGhanaCard != 'Yes') {
      return null;
    }
    
    // Always use controller text for validation
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
    if (hasGhanaCard == 'Yes' || selectedIdType == null) return null;
    
    // Use controller text for validation
    final idNumber = idNumberController.text.trim();
    if (idNumber.isEmpty) {
      return 'ID number is required';
    }
    
    // Use the raw ID type values (voter_id, drivers_license, etc.)
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
    // Use controller text for validation
    final contactNumber = contactNumberController.text.trim();
    if (contactNumber.isEmpty) {
      return 'Contact number is required';
    }
    
    // More flexible Ghana phone number validation
    final phoneRegex = RegExp(r'^(?:\+?233|0)?[23579]\d{8}$');
    final normalizedNumber = contactNumber.replaceAll(RegExp(r'[\s\-]'), '');
    
    if (!phoneRegex.hasMatch(normalizedNumber)) {
      return 'Enter a valid Ghanaian phone number (e.g., 0244123456, 233244123456)';
    }
    
    return null;
  }

  String? validateChildrenCount() {
    // Use controller text for validation
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
    if (idPictureConsent != 'No') return null;
    
    // Use controller text for validation
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
    if (idPictureConsent != 'Yes') return null;
    
    if (idImagePath == null || idImagePath!.trim().isEmpty) {
      return 'Please capture a picture of the ID';
    }
    
    return null;
  }

  Map<String, String> validateForm() {
    final errors = <String, String>{};
    
    if (hasGhanaCard == null) {
      errors['ghanaCard'] = 'Please specify if you have a Ghana Card';
    }
    
    if (hasGhanaCard == 'No' && selectedIdType == null) {
      errors['idType'] = 'Please select an alternative ID type';
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
    String? hasGhanaCard,
    String? selectedIdType,
    String? idPictureConsent,
    String? ghanaCardNumber,
    String? idNumber,
    String? noConsentReason,
    String? idImagePath,
    String? contactNumber,
    int? childrenCount,
    List<FarmerChild>? children,
    bool preserveControllers = false,
  }) {
    if (preserveControllers) {
      // Preserve existing controllers - update their internal state if needed
      return FarmerIdentificationData(
        hasGhanaCard: hasGhanaCard ?? this.hasGhanaCard,
        selectedIdType: selectedIdType ?? this.selectedIdType,
        idPictureConsent: idPictureConsent ?? this.idPictureConsent,
        ghanaCardNumber: ghanaCardNumber ?? this.ghanaCardNumber,
        idNumber: idNumber ?? this.idNumber,
        noConsentReason: noConsentReason ?? this.noConsentReason,
        idImagePath: idImagePath ?? this.idImagePath,
        contactNumber: contactNumber ?? this.contactNumber,
        childrenCount: childrenCount ?? this.childrenCount,
        children: children ?? List.from(this.children),
        // Pass existing controllers to preserve text content
        ghanaCardNumberController: this.ghanaCardNumberController,
        idNumberController: this.idNumberController,
        contactNumberController: this.contactNumberController,
        childrenCountController: this.childrenCountController,
        noConsentReasonController: this.noConsentReasonController,
      );
    } else {
      // Create new instance with new controllers (for fresh starts)
      return FarmerIdentificationData(
        hasGhanaCard: hasGhanaCard ?? this.hasGhanaCard,
        selectedIdType: selectedIdType ?? this.selectedIdType,
        idPictureConsent: idPictureConsent ?? this.idPictureConsent,
        ghanaCardNumber: ghanaCardNumber ?? this.ghanaCardNumber,
        idNumber: idNumber ?? this.idNumber,
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