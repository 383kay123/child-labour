import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';



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
  final farmerData = FarmerIdentificationData().obs;
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
      if (val != null) {
        farmerData.value = val.copyWith(childrenCount: count);
      }
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

  // Location handling is now managed by house_hold.dart
  // This method is kept for backward compatibility but will be removed in future versions
  @Deprecated('Use the location handling from house_hold.dart instead')
  Future<void> getCurrentLocation() async {
    debugPrint('getCurrentLocation() is deprecated. Use the implementation from house_hold.dart');
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

  // Form submission - Commented out to prevent duplicate saves
  // The survey is now saved using the transaction-based approach in saveCompleteSurvey()
  /*
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
      
      // Get the database helper instance
      final dbHelper = HouseholdDBHelper.instance;
      
      // Save cover page data
      debugPrint('🔄 Saving cover page data...');
      final coverPageId = await dbHelper.insertCoverPage(coverData.value);
      debugPrint('✅ Cover page saved with ID: $coverPageId');
      
      // Save consent data with the cover page ID
      debugPrint('🔄 Saving consent data...');
      final consent = consentData.value.copyWith(
        id: null, // Ensure we're inserting a new record
        coverPageId: coverPageId,
      );
      final consentId = await dbHelper.insertConsent(consent);
      debugPrint('✅ Consent saved with ID: $consentId (linked to cover page ID: $coverPageId)');
      
      // Save farmer identification data if available
      if (farmerData.value.ghanaCardNumber?.isNotEmpty == true) {
        final farmerId = await dbHelper.insertFarmerIdentification(farmerData.value);
        debugPrint('✅ Farmer identification saved with ID: $farmerId');
      }
      
      // Save children household data if available
      for (var child in childrenDetails) {
        final childId = await dbHelper.insertChildrenHousehold(ChildrenHouseholdModel.fromMap(child));
        debugPrint('✅ Child data saved with ID: $childId');
      }
      
      // Save sensitization data if available
      if (sensitizationData.value.isAcknowledged) {
        final sensitizationId = await dbHelper.insertSensitization(sensitizationData.value);
        debugPrint('✅ Sensitization data saved with ID: $sensitizationId');
      }
      
      // On success
      Get.snackbar(
        'Success', 
        'Survey submitted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Reset form after successful submission
      resetFormData();
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error submitting survey: $e');
      debugPrint('Stack trace: $stackTrace');
      
      Get.snackbar(
        'Error', 
        'Failed to submit survey: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  */
  
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
    farmerData.value = FarmerIdentificationData();
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
    
    // No need to dispose controllers as they are now managed by their respective widgets
    
    super.onClose();
  }
}