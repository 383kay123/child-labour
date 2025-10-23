import 'package:flutter/material.dart';

/// Model for Farmer Child data
class FarmerChild {
  final int childNumber;
  String firstName;
  String surname;

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
  final TextEditingController reasonController;
  final TextEditingController idNumberController;
  final TextEditingController contactNumberController;
  final TextEditingController childrenCountController;

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
    required this.ghanaCardNumberController,
    required this.reasonController,
    required this.idNumberController,
    required this.contactNumberController,
    required this.childrenCountController,
  }) : children = children ?? [];

  /// Convert to Map for storage/API
  Map<String, dynamic> toMap() {
    return {
      'hasGhanaCard': hasGhanaCard,
      'selectedIdType': selectedIdType,
      'idPictureConsent': idPictureConsent,
      'ghanaCardNumber': ghanaCardNumber,
      'idNumber': idNumber,
      'noConsentReason': noConsentReason,
      'idImagePath': idImagePath,
      'contactNumber': contactNumber,
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
          .map((childMap) => FarmerChild.fromMap(childMap))
          .toList(),
      ghanaCardNumberController: TextEditingController(
        text: map['ghanaCardNumber']?.toString() ?? '',
      ),
      reasonController: TextEditingController(
        text: map['noConsentReason']?.toString() ?? '',
      ),
      idNumberController: TextEditingController(
        text: map['idNumber']?.toString() ?? '',
      ),
      contactNumberController: TextEditingController(
        text: map['contactNumber']?.toString() ?? '',
      ),
      childrenCountController: TextEditingController(
        text: (map['childrenCount'] as int? ?? 0).toString(),
      ),
    );
  }

  /// Create empty instance
  factory FarmerIdentificationData.empty() {
    return FarmerIdentificationData(
      ghanaCardNumberController: TextEditingController(),
      reasonController: TextEditingController(),
      idNumberController: TextEditingController(),
      contactNumberController: TextEditingController(),
      childrenCountController: TextEditingController(),
    );
  }

  /// Copy with method for immutability
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
    TextEditingController? ghanaCardNumberController,
    TextEditingController? reasonController,
    TextEditingController? idNumberController,
    TextEditingController? contactNumberController,
    TextEditingController? childrenCountController,
  }) {
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
      children: children ?? this.children,
      ghanaCardNumberController:
          ghanaCardNumberController ?? this.ghanaCardNumberController,
      reasonController: reasonController ?? this.reasonController,
      idNumberController: idNumberController ?? this.idNumberController,
      contactNumberController:
          contactNumberController ?? this.contactNumberController,
      childrenCountController:
          childrenCountController ?? this.childrenCountController,
    );
  }

  /// Update Ghana Card selection
  FarmerIdentificationData updateGhanaCard(String? value) {
    return copyWith(
      hasGhanaCard: value,
      selectedIdType: value == 'Yes' ? null : selectedIdType,
      idPictureConsent: null,
      idImagePath: null,
    );
  }

  /// Update ID type selection
  FarmerIdentificationData updateIdType(String? value) {
    return copyWith(
      selectedIdType: value,
      idPictureConsent: null,
      idImagePath: null,
    );
  }

  /// Update picture consent
  FarmerIdentificationData updatePictureConsent(String? value) {
    return copyWith(
      idPictureConsent: value,
      idImagePath: value == 'No' ? null : idImagePath,
    );
  }

  /// Update Ghana Card number
  FarmerIdentificationData updateGhanaCardNumber(String value) {
    return copyWith(
      ghanaCardNumber: value,
      ghanaCardNumberController: TextEditingController(text: value),
    );
  }

  /// Update ID number
  FarmerIdentificationData updateIdNumber(String value) {
    return copyWith(
      idNumber: value,
      idNumberController: TextEditingController(text: value),
    );
  }

  /// Update no consent reason
  FarmerIdentificationData updateNoConsentReason(String value) {
    return copyWith(
      noConsentReason: value,
      reasonController: TextEditingController(text: value),
    );
  }

  /// Update contact number
  FarmerIdentificationData updateContactNumber(String value) {
    return copyWith(
      contactNumber: value,
      contactNumberController: TextEditingController(text: value),
    );
  }

  /// Update children count
  FarmerIdentificationData updateChildrenCount(String value) {
    final count = int.tryParse(value) ?? 0;
    final updatedChildren = _updateChildrenList(count, children);

    return copyWith(
      childrenCount: count,
      childrenCountController: TextEditingController(text: value),
      children: updatedChildren,
    );
  }

  /// Update child name
  FarmerIdentificationData updateChildName(
      int index, String field, String value) {
    final updatedChildren = List<FarmerChild>.from(children);

    // Ensure list is long enough
    while (index >= updatedChildren.length) {
      updatedChildren.add(FarmerChild(
        childNumber: updatedChildren.length + 1,
        firstName: '',
        surname: '',
      ));
    }

    // Update the specific field
    final child = updatedChildren[index];
    updatedChildren[index] = child.copyWith(
      firstName: field == 'firstName' ? value : child.firstName,
      surname: field == 'surname' ? value : child.surname,
    );

    return copyWith(children: updatedChildren);
  }

  /// Update ID image path
  FarmerIdentificationData updateIdImagePath(String? path) {
    return copyWith(idImagePath: path);
  }

  /// Helper method to update children list
  List<FarmerChild> _updateChildrenList(
      int count, List<FarmerChild> currentChildren) {
    final updatedChildren = List<FarmerChild>.from(currentChildren);

    if (count > updatedChildren.length) {
      for (int i = updatedChildren.length; i < count; i++) {
        updatedChildren.add(FarmerChild(
          childNumber: i + 1,
          firstName: '',
          surname: '',
        ));
      }
    } else if (count < updatedChildren.length) {
      updatedChildren.removeRange(count, updatedChildren.length);
    }

    return updatedChildren;
  }

  /// Get selected ID type display name
  String get selectedIdTypeDisplayName {
    switch (selectedIdType) {
      case 'voter_id':
        return 'Voter ID';
      case 'nhis_card':
        return 'NHIS Card';
      case 'passport':
        return 'Passport';
      case 'drivers_license':
        return "Driver's License";
      case 'ssnit':
        return 'SSNIT';
      case 'birth_certificate':
        return 'Birth Certificate';
      default:
        return 'ID';
    }
  }

  /// Get selected ID type value for API
  String get selectedIdTypeValue {
    if (selectedIdType == null) return '';

    switch (selectedIdType) {
      case 'voter_id':
        return 'voter';
      case 'nhis_card':
        return 'nhis';
      case 'passport':
        return 'passport';
      case 'drivers_license':
        return 'driver';
      case 'ssnit':
        return 'ssnit';
      case 'birth_certificate':
        return 'birth';
      default:
        return 'other';
    }
  }

  /// Check if form is complete
  bool get isComplete {
    return hasGhanaCard != null &&
        ((hasGhanaCard == 'Yes') ||
            (hasGhanaCard == 'No' && selectedIdType != null)) &&
        idPictureConsent != null &&
        contactNumber != null &&
        contactNumber!.isNotEmpty &&
        childrenCountController.text.isNotEmpty;
  }

  /// Validate Ghana Card number
  String? validateGhanaCardNumber() {
    if (hasGhanaCard == 'Yes' && idPictureConsent == 'Yes') {
      if (ghanaCardNumber == null || ghanaCardNumber!.isEmpty) {
        return 'Please enter your Ghana Card number';
      }
      if (ghanaCardNumber!.trim().length < 6) {
        return 'Please enter a valid Ghana Card number';
      }
    }
    return null;
  }

  /// Validate ID number
  String? validateIdNumber() {
    if (hasGhanaCard == 'No' && idPictureConsent == 'Yes') {
      if (idNumber == null || idNumber!.isEmpty) {
        return 'Please enter your ${selectedIdTypeDisplayName} number';
      }
    }
    return null;
  }

  /// Validate contact number
  String? validateContactNumber() {
    if (contactNumber == null || contactNumber!.isEmpty) {
      return 'Please enter contact number';
    }
    if (contactNumber!.length != 10) {
      return 'Please enter a valid 10-digit number';
    }
    return null;
  }

  /// Validate children count
  String? validateChildrenCount() {
    if (childrenCountController.text.isEmpty) {
      return 'Please enter number of children';
    }
    final number = int.tryParse(childrenCountController.text);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 0) {
      return 'Number cannot be negative';
    }
    if (number > 20) {
      return 'Please enter a reasonable number';
    }
    return null;
  }

  /// Validate ID picture
  String? validateIdPicture() {
    if (idPictureConsent == 'Yes' && idImagePath == null) {
      return 'Please take a picture of the ID';
    }
    return null;
  }

  /// Validate no consent reason
  String? validateNoConsentReason() {
    if (idPictureConsent == 'No' &&
        (noConsentReason == null || noConsentReason!.isEmpty)) {
      return 'Please specify a reason';
    }
    return null;
  }

  /// Get all validation errors
  Map<String, String> validate() {
    final errors = <String, String>{};

    if (hasGhanaCard == null) {
      errors['ghanaCard'] = 'Please select if farmer has Ghana Card';
    }

    if (hasGhanaCard == 'No' && selectedIdType == null) {
      errors['idType'] = 'Please select an ID type';
    }

    if (idPictureConsent == null) {
      errors['consent'] = 'Please provide consent for ID picture';
    }

    final ghanaCardError = validateGhanaCardNumber();
    if (ghanaCardError != null) errors['ghanaCardNumber'] = ghanaCardError;

    final idNumberError = validateIdNumber();
    if (idNumberError != null) errors['idNumber'] = idNumberError;

    final contactError = validateContactNumber();
    if (contactError != null) errors['contactNumber'] = contactError;

    final childrenError = validateChildrenCount();
    if (childrenError != null) errors['childrenCount'] = childrenError;

    final pictureError = validateIdPicture();
    if (pictureError != null) errors['idPicture'] = pictureError;

    final reasonError = validateNoConsentReason();
    if (reasonError != null) errors['noConsentReason'] = reasonError;

    return errors;
  }

  /// Prepare data for submission
  Map<String, dynamic> prepareSubmissionData() {
    return {
      'farmer_gh_card_available': hasGhanaCard == 'Yes' ? 'yes' : 'no',
      'farmer_nat_id_available':
          hasGhanaCard == 'Yes' ? 'ghana_card' : selectedIdTypeValue,
      'id_picture_consent': idPictureConsent,
      'id_image_path': idImagePath,
      'ghana_card_number': hasGhanaCard == 'Yes' && idPictureConsent == 'Yes'
          ? ghanaCardNumber
          : null,
      'id_number':
          hasGhanaCard == 'No' && idPictureConsent == 'Yes' ? idNumber : null,
      'id_rejection_reason': idPictureConsent == 'No' ? noConsentReason : null,
      'contact_number': contactNumber,
      'children_5_17_count': childrenCount,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  /// Dispose controllers
  void dispose() {
    ghanaCardNumberController.dispose();
    reasonController.dispose();
    idNumberController.dispose();
    contactNumberController.dispose();
    childrenCountController.dispose();
  }

  @override
  String toString() {
    return 'FarmerIdentificationData(hasGhanaCard: $hasGhanaCard, selectedIdType: $selectedIdType, consent: $idPictureConsent, childrenCount: $childrenCount)';
  }
}
