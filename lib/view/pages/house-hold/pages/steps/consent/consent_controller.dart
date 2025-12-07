import 'package:flutter/material.dart' show Colors, AlertDialog, Text, TextButton, ElevatedButton, TextEditingController, debugPrint;
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:human_rights_monitor/controller/db/daos/consent_dao.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';

class ConsentController extends GetxController {
  // Form fields as reactive variables
  final RxString communityType = RxString('');
  final RxString residesInCommunity = RxString('');
  final RxString otherCommunityName = RxString('');
  final RxString farmerAvailable = RxString('');
  final RxString farmerStatus = RxString('');
  final RxString availablePerson = RxString('');
  final RxString otherSpecification = RxString('');
  final RxString refusalReason = RxString('');

  ConsentDao? _consentDao;
  int? coverPageId;

  // Consent status
  final RxBool consentGiven = false.obs;
  final RxBool declinedConsent = false.obs;

  // Interview info
  final Rx<DateTime?> interviewStartTime = Rx<DateTime?>(null);
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxString locationStatus = RxString('Not captured');

  // UI state
  final RxBool isGettingLocation = false.obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  
  // Text editing controllers
  // final TextEditingController otherSpecController = TextEditingController();
  // final TextEditingController otherCommunityController = TextEditingController();
  // final TextEditingController refusalReasonController = TextEditingController();

  bool get isFormValid {
    return communityType.value.isNotEmpty &&
        residesInCommunity.value.isNotEmpty &&
        (residesInCommunity.value != 'Yes' || farmerAvailable.value.isNotEmpty) &&
        consentGiven.value;
  }

  Future<bool> saveData({required int coverId}) async {

    debugPrint("THE ID FOR COVER:::::::: $coverId");
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Continue'),
        content: const Text('Are you sure you want to continue with these responses?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
      barrierDismissible: false,
    ) ?? false;

    if (!confirmed) return false;

    // Create and save the consent data
    final consentModel = ConsentData(
      id: null, // Will be set by the database
      communityType: communityType.value,
      coverPageId: coverId,
      residesInCommunityConsent: residesInCommunity.value,
      farmerAvailable: farmerAvailable.value,
      farmerStatus: farmerStatus.value,
      availablePerson: availablePerson.value,
      otherSpecification: otherSpecification.value,
      otherCommunityName: otherCommunityName.value,
      consentGiven: consentGiven.value,
      declinedConsent: declinedConsent.value,
      refusalReason: refusalReason.value,
      consentTimestamp: DateTime.now(),
      interviewStartTime: interviewStartTime.value,
      timeStatus: 'Completed',
      currentPosition: currentPosition.value,
      locationStatus: locationStatus.value,
      isGettingLocation: isGettingLocation.value,
    );

    try {
      await _consentDao!.insert(consentModel);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error saving consent data: $e');
      debugPrint('Error saving consent data: $stackTrace');
      return false;
    }
  }

  // Constants
  static const List<String> communityTypes = ['Rural', 'Urban', 'Semi-Urban', 'Other'];
  static const List<String> yesNoOptions = ['Yes', 'No'];
  static const List<String> farmerStatusOptions = [
    'Non-resident',
    'Deceased',
    'Doesn\'t work with TOUTON anymore',
    'Other'
  ];
  static const List<String> availablePersonOptions = [
    'Caretaker',
    'Spouse',
    'Nobody',
    'Other'
  ];

  @override
  void onInit() {
    super.onInit();
    _consentDao = ConsentDao(dbHelper: HouseholdDBHelper.instance);
    _initializeInterviewTime();
  }

  void _initializeInterviewTime() {
    if (interviewStartTime.value == null) {
      interviewStartTime.value = DateTime.now();
    }
  }

  // Field validations
  String? validateCommunityType() {
    if (communityType.value.isEmpty) {
      return 'Please select community type';
    }
    if (communityType.value == 'Other' && otherCommunityName.value.isEmpty) {
      return 'Please specify community name';
    }
    return null;
  }

  String? validateResidence() {
    if (residesInCommunity.value.isEmpty) {
      return 'Please specify if farmer resides in community';
    }
    if (residesInCommunity.value == 'No' && otherCommunityName.value.isEmpty) {
      return 'Please specify the community';
    }
    return null;
  }

  String? validateFarmerAvailability() {
    if (farmerAvailable.value.isEmpty) {
      return 'Please specify farmer availability';
    }

    if (farmerAvailable.value == 'No') {
      if (farmerStatus.value.isEmpty) {
        return 'Please specify reason';
      }

      if (farmerStatus.value == 'Other' && otherSpecification.value.isEmpty) {
        return 'Please provide specification';
      }

      if ((farmerStatus.value == 'Non-resident' || farmerStatus.value == 'Other') &&
          availablePerson.value.isEmpty) {
        return 'Please specify available person';
      }
    }

    return null;
  }

  String? validateConsent() {
    if (!consentGiven.value && !declinedConsent.value) {
      return 'Please either accept or decline consent';
    }

    if (declinedConsent.value && refusalReason.value.isEmpty) {
      return 'Please provide reason for declining';
    }

    return null;
  }


  // Update methods
  void updateCommunityType(String value) {
    communityType.value = value;
    if (value != 'Other') {
      otherCommunityName.value = '';
    }
    _clearFieldError('communityType');
    _clearFieldError('otherCommunityName');
  }

  void updateResidesInCommunity(String value) {
    residesInCommunity.value = value;
    if (value == 'Yes') {
      otherCommunityName.value = '';
    }
    _clearFieldError('residesInCommunity');
    _clearFieldError('otherCommunityName');
  }

  void updateFarmerAvailable(String value) {
    farmerAvailable.value = value;
    if (value == 'Yes') {
      farmerStatus.value = '';
      availablePerson.value = '';
      otherSpecification.value = '';
    }
    _clearFieldError('farmerAvailable');
  }

  void updateFarmerStatus(String value) {
    farmerStatus.value = value;
    if (value != 'Other') {
      otherSpecification.value = '';
    }
    _clearFieldError('farmerStatus');
  }

  void updateAvailablePerson(String value) {
    availablePerson.value = value;
    _clearFieldError('availablePerson');
  }

  void toggleConsent() {
    if (consentGiven.value) {
      consentGiven.value = false;
    } else {
      consentGiven.value = true;
      declinedConsent.value = false;
      refusalReason.value = '';
    }
    _clearFieldError('consent');
  }

  void toggleDeclinedConsent() {
    if (declinedConsent.value) {
      declinedConsent.value = false;
      refusalReason.value = '';
    } else {
      declinedConsent.value = true;
      consentGiven.value = false;
    }
    _clearFieldError('consent');
  }

  // Location methods
  Future<void> getLocation() async {
    try {
      isGettingLocation.value = true;
      fieldErrors.remove('location');

      final hasPermission = await _handlePermission();
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      currentPosition.value = position;
      locationStatus.value = 'Captured';

      Get.snackbar(
        'Success',
        'Location captured successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );


    } on TimeoutException {
      fieldErrors['location'] = 'Location request timed out';
      Get.snackbar(
        'Timeout',
        'Location request timed out. Please try again.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      fieldErrors['location'] = 'Failed to get location: $e';
      Get.snackbar(
        'Error',
        'Failed to get location. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGettingLocation.value = false;
    }
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      fieldErrors['location'] = 'Location services are disabled';
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        fieldErrors['location'] = 'Location permissions are denied';
        await Geolocator.openAppSettings();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      fieldErrors['location'] = 'Location permissions are permanently denied';
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  void recordInterviewTime() {
    interviewStartTime.value = DateTime.now();
    Get.snackbar(
      'Success',
      'Interview time recorded',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Data collection method
  Map<String, dynamic> collectFormData() {
    return {
      'communityType': communityType.value,
      'residesInCommunity': residesInCommunity.value,
      'otherCommunityName': otherCommunityName.value,
      'farmerAvailable': farmerAvailable.value,
      'farmerStatus': farmerStatus.value,
      'availablePerson': availablePerson.value,
      'otherSpecification': otherSpecification.value,
      'consentGiven': consentGiven.value,
      'declinedConsent': declinedConsent.value,
      'refusalReason': refusalReason.value,
      'interviewStartTime': interviewStartTime.value?.toIso8601String(),
      'currentPosition': currentPosition.value?.toJson(),
      'locationStatus': locationStatus.value,
    };
  }

  // Reset form
  void resetForm() {
    communityType.value = '';
    residesInCommunity.value = '';
    otherCommunityName.value = '';
    farmerAvailable.value = '';
    farmerStatus.value = '';
    availablePerson.value = '';
    otherSpecification.value = '';
    refusalReason.value = '';
    consentGiven.value = false;
    declinedConsent.value = false;
    interviewStartTime.value = DateTime.now();
    currentPosition.value = null;
    locationStatus.value = 'Not captured';
    fieldErrors.clear();
  }

  // Helper method to clear field errors
  void _clearFieldError(String field) {
    fieldErrors.remove(field);
  }
}