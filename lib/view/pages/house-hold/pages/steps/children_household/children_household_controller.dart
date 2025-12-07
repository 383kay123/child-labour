import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';

class ChildrenHouseholdController extends GetxController {
  // Form State
  final RxString hasChildrenInHousehold = RxString('');
  final RxInt numberOfChildren = RxInt(0);
  final RxInt children5To17 = RxInt(0);
  final RxList<Map<String, dynamic>> childrenDetails =
      <Map<String, dynamic>>[].obs;

  // UI State
  final RxBool isLoading = RxBool(false);
  final RxBool isSubmitting = RxBool(false);

  // Validation Errors
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // Methods
  void updateHasChildren(String value) {
    hasChildrenInHousehold.value = value;
    if (value == 'No') {
      numberOfChildren.value = 0;
      children5To17.value = 0;
      childrenDetails.clear();
    }
    fieldErrors.remove('hasChildren');
    update(); // This triggers a rebuild of the widget
  }

  void updateNumberOfChildren(int count) {
    numberOfChildren.value = count;
    if (children5To17.value > count) {
      children5To17.value = 0;
    }
    fieldErrors.remove('numberOfChildren');
  }

  void updateChildren5To17(int count) {
    if (count <= numberOfChildren.value && count >= 0 && count <= 19) {
      children5To17.value = count;
      fieldErrors.remove('children5To17');
    }
  }

  void addChildDetail(Map<String, dynamic> childData) {
    childrenDetails.add(childData);
    childrenDetails.refresh();
  }

  void updateChildDetail(int index, Map<String, dynamic> childData) {
    if (index < childrenDetails.length) {
      childrenDetails[index] = childData;
      childrenDetails.refresh();
    }
  }

  void removeChildDetail(int index) {
    if (index < childrenDetails.length) {
      childrenDetails.removeAt(index);
      childrenDetails.refresh();
    }
  }

  // Validation
  String? validateHasChildren() {
    if (hasChildrenInHousehold.value.isEmpty) {
      return 'Please indicate if there are children in the household';
    }
    return null;
  }

  String? validateNumberOfChildren() {
    if (hasChildrenInHousehold.value == 'Yes') {
      if (numberOfChildren.value <= 0) {
        return 'Please enter a valid number of children (greater than 0)';
      }
    }
    return null;
  }

  String? validateChildren5To17() {
    if (hasChildrenInHousehold.value == 'Yes' && numberOfChildren.value > 0) {
      if (children5To17.value < 0) {
        return 'Number of children aged 5-17 cannot be negative';
      }
      if (children5To17.value > numberOfChildren.value) {
        return 'Cannot exceed total number of children';
      }
      if (children5To17.value > 19) {
        return 'Maximum 19 children allowed in this age range';
      }
    }
    return null;
  }

  bool get isFormValid {
    final errors = [
      validateHasChildren(),
      validateNumberOfChildren(),
      validateChildren5To17(),
    ];
    return errors.every((error) => error == null);
  }

  bool get shouldCollectChildDetails {
    return hasChildrenInHousehold.value == 'Yes' && children5To17.value > 0;
  }

  // Data Collection
  Map<String, dynamic> collectFormData(coverPageId) {
    return {
      'coverPageId': coverPageId,
      'hasChildrenInHousehold': hasChildrenInHousehold.value,
      'numberOfChildren': numberOfChildren.value,
      'children5To17': children5To17.value,
      'childrenDetails': List<Map<String, dynamic>>.from(childrenDetails),
      'progress': childrenDetails.length /
          (children5To17.value > 0 ? children5To17.value : 1),
      'isComplete': childrenDetails.length >= children5To17.value,
    };
  }

  // Reset Form
  void resetForm() {
    hasChildrenInHousehold.value = '';
    numberOfChildren.value = 0;
    children5To17.value = 0;
    childrenDetails.clear();
    fieldErrors.clear();
    isLoading.value = false;
    isSubmitting.value = false;
  }

  saveHouseHoldChild({required int coverPageId}) async {
    try {
      final data = collectFormData(coverPageId);

      final rows =  await HouseholdDBHelper.instance.insertChildrenHousehold(data);

      if(rows > 0){
        return true;
      }
      return false;

    } catch (e, stackTrace) {
      debugPrint('Error saving children household data: $e');
      debugPrint('Error saving children household data: $stackTrace');
    }
  }
}
