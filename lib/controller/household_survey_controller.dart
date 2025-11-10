import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:human_rights_monitor/controller/models/cover_model.dart';
import 'package:human_rights_monitor/controller/models/consent_model.dart';
import 'package:human_rights_monitor/controller/models/farmeridentification_model.dart';
import 'package:human_rights_monitor/controller/models/sensitization_model.dart';

class HouseholdSurveyController extends GetxController {
  // Page Controller
  final PageController pageController = PageController();
  
  // Controllers for text fields
  final TextEditingController otherSpecController = TextEditingController();
  final TextEditingController otherCommunityController = TextEditingController();
  final TextEditingController refusalReasonController = TextEditingController();
  
  // Reactive state variables
  final RxBool isLoading = false.obs;
  final RxBool isSensitizationChecked = false.obs;
  final coverData = CoverPageData.empty().obs;
  final consentData = ConsentData(
    otherSpecController: TextEditingController(),
    otherCommunityController: TextEditingController(),
    refusalReasonController: TextEditingController(),
  ).obs;
  final farmerData = FarmerIdentificationData(
    ghanaCardNumberController: TextEditingController(),
    idNumberController: TextEditingController(),
    contactNumberController: TextEditingController(),
    childrenCountController: TextEditingController(),
    noConsentReasonController: TextEditingController(),
  ).obs;
  final sensitizationData = SensitizationData().obs;
  
  // Form state
  final RxInt currentPageIndex = 0.obs;
  final RxInt combinedPageSubIndex = 0.obs;
  final totalPages = 10.obs; // Fixed: Should be observable and correct count
  final totalCombinedSubPages = 4.obs;
  
  // Child details state
  final RxInt currentChildNumber = 1.obs;
  final RxInt totalChildren5To17 = 0.obs;
  final RxList<Map<String, dynamic>> childrenDetails = <Map<String, dynamic>>[].obs;

  // Getters
  bool get isLoadingValue => isLoading.value;
  double get progress => (currentPageIndex.value + 1) / totalPages.value;
  bool get isOnCombinedPage => currentPageIndex.value == 3; // Combined page is index 3
  
  @override
  void onInit() {
    super.onInit();
    // Initialize page controller listener
    pageController.addListener(() {
      currentPageIndex.value = pageController.page?.round() ?? 0;
    });
  }

  // Navigation methods
  void navigateToNextPage() {
    if (currentPageIndex.value < totalPages.value - 1) {
      currentPageIndex.value++;
      if (pageController.hasClients) {
        pageController.animateToPage(
          currentPageIndex.value,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void navigateToPreviousPage() {
    if (currentPageIndex.value > 0) {
      currentPageIndex.value--;
      if (pageController.hasClients) {
        pageController.animateToPage(
          currentPageIndex.value,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void navigateToPage(int page) {
    if (page >= 0 && page < totalPages.value) {
      currentPageIndex.value = page;
      if (pageController.hasClients) {
        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // Combined page navigation
  void navigateToCombinedSubPage(int index) {
    if (index >= 0 && index < totalCombinedSubPages.value) {
      combinedPageSubIndex.value = index;
    }
  }

  void nextCombinedSubPage() {
    if (combinedPageSubIndex.value < totalCombinedSubPages.value - 1) {
      combinedPageSubIndex.value++;
    } else {
      // Move to next main page when last sub-page is reached
      navigateToPage(4); // Children Household page
    }
  }

  void previousCombinedSubPage() {
    if (combinedPageSubIndex.value > 0) {
      combinedPageSubIndex.value--;
    } else {
      // Move to previous main page when first sub-page is reached
      navigateToPreviousPage();
    }
  }

  // Child management
  void updateChildrenCount(int count) {
    totalChildren5To17.value = count;
    currentChildNumber.value = 1;
    childrenDetails.clear();
    
    // Update farmer data
    farmerData.update((val) {
      val?.childrenCountController.text = count.toString();
    });
  }

  void handleChildDetailsComplete(dynamic childData) {
    if (childData is Map<String, dynamic>) {
      childrenDetails.add(childData);
      if (currentChildNumber.value < totalChildren5To17.value) {
        currentChildNumber.value++;
      } else {
        // Move to sensitization page when all children are processed
        navigateToPage(6);
      }
    }
  }

  // Record interview time
 void recordInterviewTime() {
  final now = DateTime.now();
  consentData.update((val) {
    if (val != null) {
      consentData.value = val.copyWith(
        interviewStartTime: now,
        timeStatus: 'Started at ${_formatTime(now)}',
      );
    }
  });
}

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      consentData.update((val) => val?.updateSurveyState(isGettingLocation: true));
      
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
       consentData.update((val) {
  val = val?.copyWith(
    locationStatus: 'Location services are disabled',
    isGettingLocation: false,
  );
});
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
         consentData.update((val) {
  val = val?.copyWith(
    locationStatus: 'Location permissions denied',
    isGettingLocation: false,
  );
});
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
       consentData.update((val) {
  val = val?.copyWith(
    locationStatus: 'Location permissions permanently denied',
    isGettingLocation: false,
  );
});
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      consentData.update((val) {
  val = val?.copyWith(
    currentPosition: position,
    locationStatus: 'Location captured (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})',
    isGettingLocation: false,
  );
});
    } catch (e) {
      consentData.update((val) {
  val = val?.copyWith(
    locationStatus: 'Error: ${e.toString()}',
    isGettingLocation: false,
  );
});
    }
  }
  
  // Data handling
  void updateCoverData(CoverPageData newData) {
    coverData.value = newData;
  }
  
  void updateConsentData(ConsentData newData) {
    consentData.value = newData;
  }
  
  void updateFarmerData(FarmerIdentificationData newData) {
    farmerData.value = newData;
  }
  
  void updateSensitizationData(SensitizationData newData) {
    sensitizationData.value = newData;
    isSensitizationChecked.value = newData.isAcknowledged;
  }

  // Form submission
  Future<void> submitSurvey() async {
    try {
      isLoading.value = true;
      
      // Validate all data
      if (!_validateForm()) {
        Get.snackbar(
          'Validation Error', 
          'Please fill in all required fields',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // On success
      Get.snackbar(
        'Success', 
        'Survey submitted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Reset form after successful submission
      resetFormData();
      
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to submit survey: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  bool _validateForm() {
    final cover = coverData.value;
    final consent = consentData.value;
    
    // Basic validation - check if all required fields are filled
    if (cover.selectedTownCode == null || cover.selectedTownCode!.isEmpty) {
      return false;
    }
    if (cover.selectedFarmerCode == null || cover.selectedFarmerCode!.isEmpty) {
      return false;
    }
    if (consent.consentGiven != true) {
      return false;
    }
    return true;
  }
  
  // Reset form data
  void resetFormData() {
    coverData.value = CoverPageData.empty();
    consentData.value = ConsentData(
      otherSpecController: TextEditingController(),
      otherCommunityController: TextEditingController(),
      refusalReasonController: TextEditingController(),
    );
    farmerData.value = FarmerIdentificationData(
      ghanaCardNumberController: TextEditingController(),
      idNumberController: TextEditingController(),
      contactNumberController: TextEditingController(),
      childrenCountController: TextEditingController(),
      noConsentReasonController: TextEditingController(),
    );
    sensitizationData.value = SensitizationData(isAcknowledged: false);
    currentPageIndex.value = 0;
    combinedPageSubIndex.value = 0;
    currentChildNumber.value = 1;
    totalChildren5To17.value = 0;
    childrenDetails.clear();
    isSensitizationChecked.value = false;
    
    // Clear text controllers
    otherSpecController.clear();
    otherCommunityController.clear();
    refusalReasonController.clear();
  }
  
  @override
  void onClose() {
    pageController.dispose();
    otherSpecController.dispose();
    otherCommunityController.dispose();
    refusalReasonController.dispose();
    
    // Dispose farmer data controllers
    farmerData.value.ghanaCardNumberController.dispose();
    farmerData.value.idNumberController.dispose();
    farmerData.value.contactNumberController.dispose();
    farmerData.value.childrenCountController.dispose();
    farmerData.value.noConsentReasonController.dispose();
    
    super.onClose();
  }
}