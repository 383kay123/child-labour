import 'dart:convert';
import 'package:flutter/material.dart' show Colors, PageController, Curves;
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/adult_info_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/visit_information_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/identification_of_owner_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/workers_in_farm_model.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';

class CombinedFarmController extends GetxController {
  // Page Controller for managing the page view
  late final PageController pageController;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // ==================== REACTIVE STATE ====================

  // Visit Information
  final RxBool respondentNameCorrect = RxBool(true);
  final RxString respondentNationality = RxString('');
  final RxString countryOfOrigin = RxString('');
  final RxString otherCountry = RxString('');
  final RxBool isFarmOwner = RxBool(true);
  final RxString farmOwnershipType = RxString('');
  final RxString correctedRespondentName = RxString('');
  final RxString respondentOtherNames = RxString('');

  // Owner Information
  final RxString ownerName = RxString('');
  final RxString ownerFirstName = RxString('');
  final RxString ownerNationality = RxString('');
  final RxString specificNationality = RxString('');
  final RxString otherNationality = RxString('');
  final RxString yearsWithOwner = RxString('');

  // Workers Information
  final RxString hasRecruitedWorker = RxString('');
  final RxBool permanentLabor = RxBool(false);
  final RxBool casualLabor = RxBool(false);
  final RxString everRecruitedWorker = RxString('');
  final RxString workerAgreementType = RxString('');
  final RxString otherAgreement = RxString('');
  final RxString tasksClarified = RxString('');
  final RxString additionalTasks = RxString('');
  final RxString refusalAction = RxString('');
  final RxString salaryPaymentFrequency = RxString('');
  final RxMap<String, String?> agreementResponses = <String, String?>{}.obs;

  // Adults Information
  final RxInt numberOfAdults = RxInt(0);
  final RxList<HouseholdMember> members = <HouseholdMember>[].obs;

  // Page Management
  final RxInt currentPageIndex = RxInt(0);
  final RxBool isLoading = RxBool(false);

  // Validation Errors
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  final RxMap<int, List<String>> pageErrors = RxMap<int, List<String>>();

  // External Data
  final RxInt coverPageId = RxInt(0);

  // ==================== CONSTANTS ====================

  static const List<String> countryOptions = [
    'Burkina Faso', 'Mali', 'Guinea', 'Ivory Coast',
    'Liberia', 'Togo', 'Benin', 'Niger', 'Nigeria', 'Other'
  ];

  static const List<String> farmOwnershipOptions = [
    'Complete Owner',
    'Sharecropper',
    'Owner/Sharecropper',
    'Caretaker/Manager of the Farm',
  ];

  static const List<String> workerAgreementOptions = [
    'Verbal agreement without witness',
    'Verbal agreement with witness',
    'Written agreement without witness',
    'Written contract with witness',
    'Other (specify)'
  ];

  static const List<String> refusalActionOptions = [
    'I find a compromise',
    'I withdraw part of their salary',
    'I issue a warning',
    'Other',
    'Not applicable'
  ];

  static const List<String> salaryPaymentOptions = [
    'Always', 'Sometimes', 'Rarely', 'Never'
  ];

  static const List<String> agreementStatementIds = [
    'salary_workers', 'recruit_1', 'recruit_2', 'recruit_3',
    'conditions_1', 'conditions_2', 'conditions_3', 'conditions_4', 'conditions_5',
    'leaving_1', 'leaving_2'
  ];

  // ==================== INITIALIZATION ====================

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    // Initialize page errors
    for (int i = 0; i < 4; i++) {
      pageErrors[i] = [];
    }
  }

  // ==================== PAGE NAVIGATION ====================

  void goToPage(int index) {
    if (index >= 0 && index < 4) {
      currentPageIndex.value = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      pageErrors[index]?.clear();
      update();
    }
  }

  void nextPage() {
    if (currentPageIndex.value < 3) {
      if (validateCurrentPage()) {
        goToPage(currentPageIndex.value + 1);
      }
    }
  }

  void previousPage() {
    if (currentPageIndex.value > 0) {
      goToPage(currentPageIndex.value - 1);
    }
  }

  // ==================== VALIDATION METHODS ====================

  bool validateCurrentPage() {
    final errors = <String>[];
    fieldErrors.clear();

    switch (currentPageIndex.value) {
      case 0: // Visit Information
        errors.addAll(_validateVisitInformation());
        break;
      case 1: // Owner Identification
        errors.addAll(_validateOwnerIdentification());
        break;
      case 2: // Workers in Farm
        errors.addAll(_validateWorkersInFarm());
        break;
      case 3: // Adults Information
        errors.addAll(_validateAdultsInformation());
        break;
    }

    pageErrors[currentPageIndex.value] = errors;
    update();

    if (errors.isNotEmpty) {
      Get.snackbar(
        'Validation Error',
        errors.first,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  List<String> _validateVisitInformation() {
    final errors = <String>[];

    // Validate respondent name
    if (respondentNameCorrect.value == false) {
      if (correctedRespondentName.value.isEmpty) {
        errors.add('Please provide corrected respondent name');
      }
    }

    // Validate nationality
    if (respondentNationality.value.isEmpty) {
      errors.add('Please select respondent nationality');
    } else if (respondentNationality.value == 'Non-Ghanaian') {
      if (countryOfOrigin.value.isEmpty) {
        errors.add('Please specify country of origin');
      } else if (countryOfOrigin.value == 'Other' && otherCountry.value.isEmpty) {
        errors.add('Please specify other country');
      }
    }

    // Validate farm ownership
    if (isFarmOwner.value == false && farmOwnershipType.value.isEmpty) {
      errors.add('Please specify farm ownership type');
    }

    return errors;
  }

  List<String> _validateOwnerIdentification() {
    final errors = <String>[];

    // Validate owner name
    if (ownerName.value.isEmpty) {
      errors.add('Please enter owner name');
    }
    if (ownerFirstName.value.isEmpty) {
      errors.add('Please enter owner first name');
    }

    // Validate nationality
    if (ownerNationality.value.isEmpty) {
      errors.add('Please select owner nationality');
    } else if (ownerNationality.value == 'Non-Ghanaian') {
      if (specificNationality.value.isEmpty) {
        errors.add('Please specify country of origin');
      } else if (specificNationality.value == 'other' && otherNationality.value.isEmpty) {
        errors.add('Please specify other country');
      }
    }

    // Validate years with owner
    if (yearsWithOwner.value.isEmpty) {
      errors.add('Please enter years with owner');
    } else {
      final years = int.tryParse(yearsWithOwner.value);
      if (years == null || years < 0) {
        errors.add('Please enter valid number of years');
      }
    }

    return errors;
  }

  List<String> _validateWorkersInFarm() {
    final errors = <String>[];

    // Validate recruitment
    if (hasRecruitedWorker.value.isEmpty) {
      errors.add('Please answer recruitment question');
      return errors;
    }

    if (hasRecruitedWorker.value == '1') {
      // Validate labor types
      if (!permanentLabor.value && !casualLabor.value) {
        errors.add('Please select at least one labor type');
      }

      // Validate agreement
      if (workerAgreementType.value.isEmpty) {
        errors.add('Please select worker agreement type');
      } else if (workerAgreementType.value == 'Other (specify)' &&
          otherAgreement.value.isEmpty) {
        errors.add('Please specify other agreement type');
      }

      // Validate task questions
      if (tasksClarified.value.isEmpty) {
        errors.add('Please answer task clarification question');
      }
      if (additionalTasks.value.isEmpty) {
        errors.add('Please answer additional tasks question');
      }
      if (refusalAction.value.isEmpty) {
        errors.add('Please select refusal action');
      }
      if (salaryPaymentFrequency.value.isEmpty) {
        errors.add('Please select salary payment frequency');
      }

      // Validate agreement responses
      for (final statementId in agreementStatementIds) {
        if (agreementResponses[statementId] == null) {
          errors.add('Please respond to all agreement statements');
          break;
        }
      }
    } else if (hasRecruitedWorker.value == '0') {
      // Validate past recruitment
      if (everRecruitedWorker.value.isEmpty) {
        errors.add('Please answer past recruitment question');
      } else if (everRecruitedWorker.value == 'Yes') {
        // Validate agreement responses for past recruitment
        for (final statementId in agreementStatementIds) {
          if (agreementResponses[statementId] == null) {
            errors.add('Please respond to all agreement statements');
            break;
          }
        }
      }
    }

    return errors;
  }

  List<String> _validateAdultsInformation() {
    final errors = <String>[];

    // Validate number of adults
    if (numberOfAdults.value < 0) {
      errors.add('Number of adults cannot be negative');
      return errors;
    }

    // If no adults, no validation needed for members
    if (numberOfAdults.value == 0) {
      return errors;
    }

    // Validate member count matches
    if (members.length != numberOfAdults.value) {
      errors.add('Please provide information for all household members');
      return errors;
    }

    // Validate each member
    for (int i = 0; i < members.length; i++) {
      final member = members[i];
      final memberNumber = i + 1;
      final memberErrors = <String>[];

      // Validate name
      if (member.name.trim().isEmpty) {
        memberErrors.add('Full name is required');
      }

      // Validate producer details
      final details = member.producerDetails;

      if (details.gender == null) {
        memberErrors.add('Gender is required');
      }

      if (details.nationality == null) {
        memberErrors.add('Nationality is required');
      } else if (details.nationality == 'non_ghanaian') {
        if (details.selectedCountry == null) {
          memberErrors.add('Country of origin is required');
        } else if (details.selectedCountry == 'Other' &&
            (details.otherCountry == null || details.otherCountry!.isEmpty)) {
          memberErrors.add('Please specify other country');
        }
      }

      if (details.yearOfBirth == null) {
        memberErrors.add('Year of birth is required');
      } else {
        final currentYear = DateTime.now().year;
        if (details.yearOfBirth! < 1900 || details.yearOfBirth! > currentYear) {
          memberErrors.add('Please enter valid year of birth (1900-$currentYear)');
        }
      }

      if (details.relationshipToRespondent == null) {
        memberErrors.add('Relationship to respondent is required');
      } else if (details.relationshipToRespondent == 'other' &&
          (details.otherRelationship == null || details.otherRelationship!.isEmpty)) {
        memberErrors.add('Please specify relationship');
      }

      if (details.hasBirthCertificate == null) {
        memberErrors.add('Birth certificate information is required');
      }

      if (details.occupation == null) {
        memberErrors.add('Occupation is required');
      } else if (details.occupation == 'other' &&
          (details.otherOccupation == null || details.otherOccupation!.isEmpty)) {
        memberErrors.add('Please specify other occupation');
      }

      // Add member errors to main errors list
      if (memberErrors.isNotEmpty) {
        errors.add('Household Member $memberNumber:');
        errors.addAll(memberErrors.map((e) => '  • $e'));
      }
    }

    return errors;
  }

  // ==================== DATA COLLECTION ====================

  VisitInformationData getVisitInformationData() {
    return VisitInformationData(
      respondentNameCorrect: respondentNameCorrect.value,
      respondentNationality: respondentNationality.value,
      countryOfOrigin: countryOfOrigin.value,
      otherCountry: otherCountry.value,
      isFarmOwner: isFarmOwner.value,
      farmOwnershipType: farmOwnershipType.value,
      correctedRespondentName: correctedRespondentName.value,
      respondentOtherNames: respondentOtherNames.value,
    );
  }

  IdentificationOfOwnerData getOwnerIdentificationData() {
    return IdentificationOfOwnerData(
      ownerName: ownerName.value,
      ownerFirstName: ownerFirstName.value,
      nationality: ownerNationality.value,
      specificNationality: specificNationality.value,
      otherNationality: otherNationality.value,
      yearsWithOwner: yearsWithOwner.value,
    );
  }

  WorkersInFarmData getWorkersInFarmData() {
    return WorkersInFarmData(
      hasRecruitedWorker: hasRecruitedWorker.value,
      permanentLabor: permanentLabor.value,
      casualLabor: casualLabor.value,
      everRecruitedWorker: everRecruitedWorker.value,
      workerAgreementType: workerAgreementType.value,
      otherAgreement: otherAgreement.value,
      tasksClarified: tasksClarified.value,
      additionalTasks: additionalTasks.value,
      refusalAction: refusalAction.value,
      salaryPaymentFrequency: salaryPaymentFrequency.value,
      agreementResponses: Map<String, String?>.from(agreementResponses),
    );
  }

  AdultsInformationData getAdultsInformationData() {
    return AdultsInformationData(
      numberOfAdults: numberOfAdults.value,
      members: List<HouseholdMember>.from(members),
    );
  }

  // ==================== DATABASE OPERATIONS ====================

  Future<bool> saveAllData() async {
    try {
      isLoading.value = true;

      // Validate all pages first
      // bool allValid = true;
      // for (int i = 0; i < 4; i++) {
      //   currentPageIndex.value = i;
      //   if (!validateCurrentPage()) {
      //     allValid = false;
      //     break;
      //   }
      // }
      //
      // if (!allValid) {
      //   Get.snackbar(
      //     'Validation Error',
      //     'Please complete all required fields',
      //     backgroundColor: Colors.orange,
      //     colorText: Colors.white,
      //   );
      //   return false;
      // }

      // Prepare data for saving
      final visitInfoData = getVisitInformationData();
      final ownerData = getOwnerIdentificationData();
      final workersData = getWorkersInFarmData();
      final adultsData = getAdultsInformationData();

      final db = await HouseholdDBHelper.instance.database;
      final now = DateTime.now().toIso8601String();

      // Helper function to safely convert data to JSON
      String safeJsonEncode(dynamic data) {
        try {
          return jsonEncode(data?.toMap() ?? {});
        } catch (e) {
          return '{}';
        }
      }

      // Prepare the complete data map
      final data = <String, dynamic>{
        'cover_page_id': coverPageId.value,
        'visit_information': safeJsonEncode(visitInfoData),
        'owner_information': safeJsonEncode(ownerData),
        'workers_in_farm': safeJsonEncode(workersData),
        'adults_information': safeJsonEncode(adultsData),
        'created_at': now,
        'updated_at': now,
        'is_synced': 0,
        'sync_status': 0,
      };

      // Save to database
      final updated = await db.update(
        TableNames.combinedFarmIdentificationTBL,
        data,
        where: 'cover_page_id = ?',
        whereArgs: [coverPageId.value],
      );

      if (updated == 0) {
        await db.insert(
          TableNames.combinedFarmIdentificationTBL,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== RESET METHODS ====================

  void resetAllForms() {
    // Reset visit information
    respondentNameCorrect.value = true;
    respondentNationality.value = '';
    countryOfOrigin.value = '';
    otherCountry.value = '';
    isFarmOwner.value = true;
    farmOwnershipType.value = '';
    correctedRespondentName.value = '';
    respondentOtherNames.value = '';

    // Reset owner information
    ownerName.value = '';
    ownerFirstName.value = '';
    ownerNationality.value = '';
    specificNationality.value = '';
    otherNationality.value = '';
    yearsWithOwner.value = '';

    // Reset workers information
    hasRecruitedWorker.value = '';
    permanentLabor.value = false;
    casualLabor.value = false;
    everRecruitedWorker.value = '';
    workerAgreementType.value = '';
    otherAgreement.value = '';
    tasksClarified.value = '';
    additionalTasks.value = '';
    refusalAction.value = '';
    salaryPaymentFrequency.value = '';
    agreementResponses.clear();

    // Reset adults information
    numberOfAdults.value = 0;
    members.clear();

    // Reset errors
    fieldErrors.clear();
    pageErrors.clear();
    for (int i = 0; i < 4; i++) {
      pageErrors[i] = [];
    }

    // Reset to first page
    currentPageIndex.value = 0;

    update();
  }

  // ==================== MEMBER MANAGEMENT ====================

  void updateNumberOfAdults(int count) {
    numberOfAdults.value = count;

    if (count > members.length) {
      // Add new members
      for (int i = members.length; i < count; i++) {
        members.add(HouseholdMember(
          name: '',
          producerDetails: ProducerDetailsModel(
            gender: null,
            nationality: null,
            selectedCountry: null,
            otherCountry: null,
            yearOfBirth: null,
            relationshipToRespondent: null,
            otherRelationship: null,
            hasBirthCertificate: null,
            occupation: null,
            otherOccupation: null,
          ),
        ));
      }
    } else if (count < members.length) {
      // Remove extra members
      members.removeRange(count, members.length);
    }
    members.refresh();
  }

  void updateMember(int index, HouseholdMember member) {
    if (index < members.length) {
      members[index] = member;
      members.refresh();
    }
  }

  // ==================== AGREEMENT RESPONSES ====================

  void updateAgreementResponse(String statementId, String? response) {
    agreementResponses[statementId] = response;
    agreementResponses.refresh();
  }
}