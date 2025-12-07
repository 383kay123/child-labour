import 'package:flutter/material.dart'
    show Colors, AlertDialog, Text, TextButton, ElevatedButton, debugPrint;
import 'package:get/get.dart';
import 'package:human_rights_monitor/controller/db/daos/cover_page_dao.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/farmers_repo.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/society_repo.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart'
    show CoverPageData, DropdownItem;
import 'package:human_rights_monitor/data/dummy_data/cover_dummy_data.dart';

class CoverPageController extends GetxController {
  // Reactive state
  final RxList<DropdownItem> towns = <DropdownItem>[].obs;
  final RxList<DropdownItem> farmers = <DropdownItem>[].obs;
  final RxString selectedTownCode = RxString('');
  final RxString selectedFarmerCode = RxString('');
  final RxBool isLoadingTowns = false.obs;
  final RxBool isLoadingFarmers = false.obs;
  final RxString townError = RxString('');
  final RxString farmerError = RxString('');
  final RxBool hasUnsavedChanges = false.obs;
  final RxInt coverPageId = RxInt(0);

  // DAO instance
  late final CoverPageDao _coverPageDao;

  @override
  void onInit() {
    super.onInit();
    _coverPageDao = CoverPageDao(dbHelper: HouseholdDBHelper.instance);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await loadFarmers();
    await loadTowns();
  }

  Future<void> loadFarmers() async {
    try {
      isLoadingFarmers.value = true;
      farmerError.value = '';

      final farmerRepo = FarmerRepository();
      final farmersList = await farmerRepo.getFirst10Farmers();

      farmers.value = farmersList
          .map((farmer) => DropdownItem(
                code: farmer.farmerCode,
                name: '${farmer.firstName} ${farmer.lastName}'.trim(),
              ))
          .toList();
    } catch (e) {
      farmerError.value = 'Failed to load farmers: $e';
      farmers.value = [];
    } finally {
      isLoadingFarmers.value = false;
    }
  }

  Future<void> loadTowns() async {
    try {
      isLoadingTowns.value = true;
      townError.value = '';

      final farmerRepo = SocietyRepository();
      final farmersList = await farmerRepo.getFirst10Societies();

      towns.value = farmersList
          .map((farmer) => DropdownItem(
                code: farmer.societyCode ?? "0",
                name: farmer.society ?? "0",
              ))
          .toList();
    } catch (e) {
      townError.value = 'Failed to load towns: $e';
      towns.value = [];
    } finally {
      isLoadingTowns.value = false;
    }
  }

  selectTown(String? code) {
    if (code == null) return;
    selectedTownCode.value = code;
    hasUnsavedChanges.value = true;
    townError.value = '';
  }

  selectFarmer(String? code) {
    if (code == null) return;
    selectedFarmerCode.value = code;
    hasUnsavedChanges.value = true;
    farmerError.value = '';
  }

  bool get isFormValid {
    return selectedTownCode.value.isNotEmpty &&
        selectedFarmerCode.value.isNotEmpty;
  }

  Future<bool> saveData() async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Confirm Save'),
            content:
                const Text('Are you sure you want to save this information?'),
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
        ) ??
        false;

    if (!confirmed) return false;

    if (!isFormValid) {
      // Highlight errors
      if (selectedTownCode.value.isEmpty) {
        townError.value = 'Please select a society';
      }
      if (selectedFarmerCode.value.isEmpty) {
        farmerError.value = 'Please select a farmer';
      }
      return false;
    }

    try {
      final coverPageData = CoverPageData(
        id: coverPageId.value > 0 ? coverPageId.value : null,
        selectedTownCode: selectedTownCode.value,
        selectedFarmerCode: selectedFarmerCode.value,
        towns: towns,
        farmers: farmers,
        hasUnsavedChanges: false,
        isLoadingTowns: false,
        isLoadingFarmers: false,
        townError: '',
        farmerError: '',
      );

      final id = await _coverPageDao.insert(coverPageData);
      coverPageId.value = id;

      debugPrint("THE COVER ID:::::::::::::::: $id");
      debugPrint("THE COVER ID:::::::::::::::: ${coverPageId.value}");
      hasUnsavedChanges.value = false;

      // Get.snackbar(
      //   'Success',
      //   'Cover page saved successfully',
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save cover page: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Map<String, dynamic> collectFormData() {
    return {
      'selectedTownCode': selectedTownCode.value,
      'selectedFarmerCode': selectedFarmerCode.value,
      'coverPageId': coverPageId.value,
    };
  }

  void resetForm() {
    selectedTownCode.value = '';
    selectedFarmerCode.value = '';
    coverPageId.value = 0;
    hasUnsavedChanges.value = false;
    townError.value = '';
    farmerError.value = '';
  }
}
