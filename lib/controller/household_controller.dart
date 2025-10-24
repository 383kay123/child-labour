import 'package:get/get.dart';

/// Controller for managing household-related state and logic
class HouseHoldController extends GetxController {
  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Add your household-related state variables here
  final RxString selectedCommunity = ''.obs;
  final RxBool consentGiven = false.obs;
  final RxString householdHeadName = ''.obs;
  final RxString contactNumber = ''.obs;
  final RxString address = ''.obs;

  // Add your methods here
  void setConsent(bool value) {
    consentGiven.value = value;
  }

  void setCommunity(String community) {
    selectedCommunity.value = community;
  }

  // Example method to submit household data
  Future<void> submitHouseholdData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // TODO: Implement your data submission logic here
      // For example:
      // await _apiService.submitHouseholdData(...);
      
      Get.snackbar('Success', 'Household data saved successfully');
    } catch (e) {
      errorMessage.value = 'Failed to save household data: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Reset form
  void resetForm() {
    consentGiven.value = false;
    selectedCommunity.value = '';
    householdHeadName.value = '';
    contactNumber.value = '';
    address.value = '';
    errorMessage.value = '';
  }
}
