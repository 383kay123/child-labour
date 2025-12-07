import 'dart:io';
import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart' show FarmerChild, FarmerIdentificationData;
import 'package:image_picker/image_picker.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart'
    show FarmerChild;

class FarmerIdController extends GetxController {
  // ID Card Information
  final RxBool hasGhanaCard = false.obs;
  final RxString selectedIdType = RxString('');
  final RxString idPictureConsent = RxString('');
  final RxString ghanaCardNumber = RxString('');
  final RxString alternativeIdNumber = RxString('');
  final RxString noConsentReason = RxString('');
  final Rx<String?> idImagePath = Rx<String?>(null);

  // Contact Information
  final RxString contactNumber = RxString('');

  // Children Information
  final RxInt childrenCount = RxInt(0);
  final RxList<FarmerChild> children = <FarmerChild>[].obs;

  // UI State
  final RxBool isLoading = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // Available ID Types
  static const List<Map<String, String>> idTypes = [
    {'value': 'voter_id', 'label': 'Voter ID'},
    {'value': 'drivers_license', 'label': 'Driver\'s License'},
    {'value': 'nhis_card', 'label': 'NHIS Card'},
    {'value': 'passport', 'label': 'Passport'},
    {'value': 'ssnit', 'label': 'SSNIT'},
    {'value': 'birth_certificate', 'label': 'Birth Certificate'},
  ];

  // Validations
  String? validateGhanaCardNumber(String? value) {
    if (hasGhanaCard.value && idPictureConsent.value == '1') {
      if (value == null || value.isEmpty) {
        return 'Ghana Card number is required';
      }
      if (!RegExp(r'^GHA-\d{9}-\d$').hasMatch(value)) {
        return 'Invalid format (GHA-XXXXXXXXX-X)';
      }
    }
    return null;
  }

  String? validateAlternativeIdNumber(String? value) {
    if (!hasGhanaCard.value &&
        selectedIdType.value.isNotEmpty &&
        idPictureConsent.value == '1') {
      if (value == null || value.isEmpty) {
        return 'ID number is required';
      }
    }
    return null;
  }

  String? validateContactNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact number is required';
    }
    if (!RegExp(r'^0[2345]\d{8}$').hasMatch(value)) {
      return 'Enter valid 10-digit number (e.g., 0241234567)';
    }
    return null;
  }

  String? validateChildrenCount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number of children is required';
    }
    final count = int.tryParse(value);
    if (count == null) {
      return 'Enter a valid number';
    }
    if (count < 0) {
      return 'Cannot be negative';
    }
    return null;
  }

  String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName[0].toUpperCase()}${fieldName.substring(1)} is required';
    }
    if (value.trim().length < 2) {
      return 'Must be at least 2 characters';
    }
    return null;
  }

  String? validateNoConsentReason() {
    if (idPictureConsent.value == '0' && noConsentReason.value.isEmpty) {
      return 'Please provide a reason';
    }
    return null;
  }

  bool get isFormValid {
    final errors = [
      // Ghana Card validation
      if (hasGhanaCard.value) validateGhanaCardNumber(ghanaCardNumber.value),
      if (!hasGhanaCard.value && idPictureConsent.value == '1')
        validateAlternativeIdNumber(alternativeIdNumber.value),

      // Contact validation
      validateContactNumber(contactNumber.value),

      // Children validation
      validateChildrenCount(childrenCount.value.toString()),

      // Consent validation
      validateNoConsentReason(),
    ];

    return errors.every((error) => error == null);
  }

  // Child management
  void updateChild(int index, String firstName, String surname) {
    if (index < children.length) {
      children[index] = FarmerChild(
        childNumber: index + 1,
        firstName: firstName,
        surname: surname,
      );
    } else {
      children.add(FarmerChild(
        childNumber: index + 1,
        firstName: firstName,
        surname: surname,
      ));
    }
    children.refresh();
  }

  void updateChildrenCount(int count) {
    childrenCount.value = count;

    if (count > children.length) {
      // Add new children
      for (int i = children.length; i < count; i++) {
        children.add(FarmerChild(
          childNumber: i + 1,
          firstName: '',
          surname: '',
        ));
      }
    } else if (count < children.length) {
      // Remove extra children
      children.removeRange(count, children.length);
    }
  }

  // ID Picture capture
  Future<void> captureIdPicture() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        idImagePath.value = image.path;
        fieldErrors.remove('idImage');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Collect form data
  Map<String, dynamic> collectFormData() {
    return {
      'hasGhanaCard': hasGhanaCard.value,
      'selectedIdType': selectedIdType.value,
      'idPictureConsent': idPictureConsent.value,
      'ghanaCardNumber': ghanaCardNumber.value,
      'alternativeIdNumber': alternativeIdNumber.value,
      'noConsentReason': noConsentReason.value,
      'idImagePath': idImagePath.value,
      'contactNumber': contactNumber.value,
      'childrenCount': childrenCount.value,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }

  // Save form data
  Future<bool> saveData({required coverId}) async {
    try {

      final farmerModel = FarmerIdentificationData(
        coverPageId: coverId,
        hasGhanaCard: hasGhanaCard.value ? 1 : 0,
        selectedIdType: selectedIdType.value,
        idPictureConsent: idPictureConsent.value.isNotEmpty ? 1 : 0,
        ghanaCardNumber: hasGhanaCard.value ? ghanaCardNumber.value : null,
        idNumber: !hasGhanaCard.value ? alternativeIdNumber.value : null,
        noConsentReason: noConsentReason.value,
        idImagePath: idImagePath.value,
        contactNumber: contactNumber.value,
        childrenCount: childrenCount.value,
        children: children,
        isSynced: 0, // Default to not synced
        syncStatus: 0, // Default status
      );

      final db = HouseholdDBHelper.instance;

      final int rowsAffected = await db.insertFarmerIdentification(farmerModel);

      if(rowsAffected > 0){
        return true;
      }
      return false;

    } catch (e) {
      // Log the error
      print('Error saving farmer data: $e');
      
      // Show error to user
      Get.snackbar(
        'Error',
        'Failed to save data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      return false;
    }
  }

  // Reset form
  void resetForm() {
    hasGhanaCard.value = false;
    selectedIdType.value = '';
    idPictureConsent.value = '';
    ghanaCardNumber.value = '';
    alternativeIdNumber.value = '';
    noConsentReason.value = '';
    idImagePath.value = null;
    contactNumber.value = '';
    childrenCount.value = 0;
    children.clear();
    fieldErrors.clear();
  }
}