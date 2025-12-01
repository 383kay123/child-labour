import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:human_rights_monitor/controller/api/get_methods.dart';

import 'package:human_rights_monitor/controller/db/db_tables/helpers/community_db_helper.dart';
import 'package:human_rights_monitor/controller/models/community-assessment-model.dart';
import 'package:human_rights_monitor/controller/models/pci/pci.dart';
import 'package:intl/intl.dart';

class CommunityAssessmentController extends GetxController {
  BuildContext? communityAssessmentContext;
  final GetService _api = GetService();

  var communityId = 0.obs;  // Added communityId observable
  var communityName = ''.obs;
  var communityScore = 0.obs;

  // Observable variables for all questions
  var q1 = ''.obs;
  var q2 = ''.obs;
  var q3 = ''.obs;
  var q4 = ''.obs;
  var q5 = ''.obs;
  var q6 = ''.obs;
  var q7a = 0.obs;
  var q7b = ''.obs;
  var q7c = ''.obs;
  var q8 = ''.obs;
  var q9 = ''.obs;
  var q10 = ''.obs;

  // Method to update score based on answer
  void updateScore(String questionKey, dynamic answer) {
    // Update the specific question value
    switch (questionKey) {
      case 'q1':
        q1.value = answer;
        break;
      case 'q2':
        q2.value = answer;
        break;
      case 'q3':
        q3.value = answer;
        break;
      case 'q4':
        q4.value = answer;
        break;
      case 'q5':
        q5.value = answer;
        break;
      case 'q6':
        q6.value = answer;
        break;
      case 'q7a':
        q7a.value = answer == 'Yes' ? 1 : 0;
        break;
      case 'q8':
        q8.value = answer;
        break;
      case 'q9':
        q9.value = answer;
        break;
      case 'q10':
        q10.value = answer;
        break;
    }
    
    // Calculate total score
    _calculateTotalScore();
  }

  void _calculateTotalScore() {
    int newScore = 0;
    if (q1.value == 'Yes') newScore++;
    if (q2.value == 'Yes') newScore++;
    if (q3.value == 'Yes') newScore++;
    if (q4.value == 'Yes') newScore++;
    if (q5.value == 'Yes') newScore++;
    if (q6.value == 'Yes') newScore++;
    if (q7a.value == 1) newScore++;
    if (q8.value == 'Yes') newScore++;
    if (q9.value == 'Yes') newScore++;
    if (q10.value == 'Yes') newScore++;
    
    communityScore.value = newScore;
  }

  /// Submit form online, fallback to offline if network fails
  Future<bool> submit(Map<String, dynamic> answers) async {
    try {
      // Convert answers to SocietyData
      final societyData = SocietyData(
        enumerator: int.tryParse(answers['enumerator_id']?.toString() ?? '0') ?? 0,
        society: int.tryParse(answers['society_id']?.toString() ?? '0') ?? 0,
        accessToProtectedWater: (answers['access_to_protected_water'] as num?)?.toDouble() ?? 0.0,
        hireAdultLabourers: (answers['hire_adult_labourers'] as num?)?.toDouble() ?? 0.0,
        awarenessRaisingSession: (answers['awareness_raising_session'] as num?)?.toDouble() ?? 0.0,
        womenLeaders: (answers['women_leaders'] as num?)?.toDouble() ?? 0.0,
        preSchool: (answers['pre_school'] as num?)?.toDouble() ?? 0.0,
        primarySchool: (answers['primary_school'] as num?)?.toDouble() ?? 0.0,
        separateToilets: (answers['separate_toilets'] as num?)?.toDouble() ?? 0.0,
        provideFood: (answers['provide_food'] as num?)?.toDouble() ?? 0.0,
        scholarships: (answers['scholarships'] as num?)?.toDouble() ?? 0.0,
        corporalPunishment: (answers['corporal_punishment'] as num?)?.toDouble() ?? 0.0,
      );

      // Get the API instance
      final api = Get.find<GetService>();
      
      // Submit the data online
      final success = await api.postPCIData(societyData.toJson());
      
      if (success) {
        await saveFormOffline(answers, status: 1);
        _showSnackBar('Form submitted successfully');
        return true;
      } else {
        await saveFormOffline(answers, status: 0);
        _showSnackBar('Form saved as draft (offline)');
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting form: $e');
      // Save offline if there's an error
      await saveFormOffline(answers, status: 0);
      _showSnackBar('Error submitting form. Saved as draft.');
      return false;
    }
  }
  
  /// Submit Post-Collection Information (PCI) data to the server
Future<void> _submitPCIData(Map<String, dynamic> answers) async {
  try {
    // Create SocietyData from answers
    final societyData = SocietyData(
      enumerator: int.tryParse(answers['enumerator_id']?.toString() ?? '0') ?? 0,
      society: int.tryParse(answers['society_id']?.toString() ?? '0') ?? 0,
      accessToProtectedWater: (answers['access_to_protected_water'] as num?)?.toDouble() ?? 0.0,
      hireAdultLabourers: (answers['hire_adult_labourers'] as num?)?.toDouble() ?? 0.0,
      awarenessRaisingSession: (answers['awareness_raising_session'] as num?)?.toDouble() ?? 0.0,
      womenLeaders: (answers['women_leaders'] as num?)?.toDouble() ?? 0.0,
      preSchool: (answers['pre_school'] as num?)?.toDouble() ?? 0.0,
      primarySchool: (answers['primary_school'] as num?)?.toDouble() ?? 0.0,
      separateToilets: (answers['separate_toilets'] as num?)?.toDouble() ?? 0.0,
      provideFood: (answers['provide_food'] as num?)?.toDouble() ?? 0.0,
      scholarships: (answers['scholarships'] as num?)?.toDouble() ?? 0.0,
      corporalPunishment: (answers['corporal_punishment'] as num?)?.toDouble() ?? 0.0,
    );

    // Convert to PCI format
    final pciData = {
      'enumerator': societyData.enumerator,
      'society': societyData.society,
      'access_to_protected_water': societyData.accessToProtectedWater,
      'hire_adult_labourers': societyData.hireAdultLabourers,
      'awareness_raising_session': societyData.awarenessRaisingSession,
      'women_leaders': societyData.womenLeaders,
      'pre_school': societyData.preSchool,
      'primary_school': societyData.primarySchool,
      'separate_toilets': societyData.separateToilets,
      'provide_food': societyData.provideFood,
      'scholarships': societyData.scholarships,
      'corporal_punishment': societyData.corporalPunishment,
      'submission_date': DateTime.now().toIso8601String(),
    };
    
    // Submit PCI data
    final api = Get.find<GetService>();
    await api.postPCIData(pciData);
    
    debugPrint('✅ PCI data submitted successfully');
  } catch (e) {
    debugPrint('❌ Error submitting PCI data: $e');
    // Don't throw error here to not affect the main form submission
  }
}
  /// Save form to local database
  /// [status] 0 = draft, 1 = submitted, 2 = synced
  Future<bool> saveFormOffline(Map<String, dynamic> answers, {int status = 0}) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      
      // Create the assessment model
      final model = _createAssessmentModel(answers);
      
      // Prepare the data to be saved
      final assessmentData = model.toDatabaseMap()
        ..addAll({
          'date_created': formattedDate,
          'date_modified': formattedDate,
          'status': status,
        });

      // Save to database
      final dbHelper = CommunityDBHelper.instance;
      final id = await dbHelper.insertCommunityAssessment(assessmentData);
      
      if (id > 0) {
        _showSnackBar('Form saved successfully');
        return true;
      } else {
        _showSnackBar('Failed to save form');
        return false;
      }
    } catch (e) {
      debugPrint('Error saving form: $e');
      _showSnackBar('Error saving form: ${e.toString()}');
      return false;
    }
  }

  /// Update the status of an existing assessment
  Future<bool> updateStatus(int id, int status) async {
    try {
      final db = CommunityDBHelper.instance;
      return await db.updateAssessmentStatus(id, status);
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  /// Create CommunityAssessmentModel from answers
  CommunityAssessmentModel _createAssessmentModel(Map<String, dynamic> answers) {
    // Parse school count
    final schoolCount = int.tryParse(answers['q7a']?.toString() ?? '0') ?? 0;
    
    // Parse school lists
    final schoolsList = answers['q7b']?.toString().split(',') ?? [];
    final schoolsWithToilets = answers['q7c']?.toString().split(',') ?? [];
    final schoolsWithFood = answers['q8']?.toString().split(',') ?? [];
    final schoolsNoCorporalPunishment = answers['q10']?.toString().split(',') ?? [];

    return CommunityAssessmentModel(
      communityName: answers['community'] ?? answers['communityName'],
      region: answers['region'],
      district: answers['district'],
      subCounty: answers['sub_county'] ?? answers['subCounty'],
      parish: answers['parish'],
      village: answers['village'],
      gpsCoordinates: answers['gps_coordinates'] ?? answers['gpsCoordinates'],
      totalHouseholds: int.tryParse(answers['total_households']?.toString() ?? '0') ?? 0,
      totalPopulation: int.tryParse(answers['total_population']?.toString() ?? '0') ?? 0,
      totalChildren: int.tryParse(answers['total_children']?.toString() ?? '0') ?? 0,
      primarySchoolsCount: schoolCount,
      schools: schoolsList.join(';'),
      schoolsWithToilets: schoolsWithToilets.join(';'),
      schoolsWithFood: schoolsWithFood.join(';'),
      schoolsNoCorporalPunishment: schoolsNoCorporalPunishment.join(';'),
      notes: answers['notes'],
      rawData: jsonEncode(answers),
      communityScore: communityScore.value,
      q1: answers['q1'],
      q2: answers['q2'],
      q3: answers['q3'],
      q4: answers['q4'],
      q5: answers['q5'],
      q6: answers['q6'],
      q7a: schoolCount,
      q7b: schoolsList.join(';'),
      q7c: schoolsWithToilets.join(';'),
      q8: schoolsWithFood.join(';'),
      q9: answers['q9'],
      q10: schoolsNoCorporalPunishment.join(';'),
      status: answers['status'] ?? 0,
    );
  }

  // /// Sync all pending forms (status = 0 or 1) when online
  // Future<void> syncPendingForms() async {
  //   try {
  //     final dbHelper = CommunityDBHelper.instance;
  //     final pendingForms = await dbHelper.getAllCommunityAssessments();
      
  //     for (final form in pendingForms) {
  //       try {
  //         // Skip already synced forms
  //         if (form['status'] == 2) continue;
          
  //         // Convert to CommunityAssessmentModel
  //         final model = CommunityAssessmentModel.fromMap(form);
  //         final success = await _api.submitCommunityAssessment(model);
          
  //         if (success) {
  //           // Mark as synced in DB
  //           await dbHelper.updateCommunityAssessment({
  //             ...form,
  //             'status': 2, // Mark as synced
  //             'date_modified': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
  //           });
  //         }
  //       } catch (e) {
  //         debugPrint('Error syncing form ${form['id']}: $e');
  //         continue;
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error in syncPendingForms: $e');
  //     rethrow;
  //   }
  // }

  void _showSnackBar(String message) {
    if (communityAssessmentContext != null && communityAssessmentContext!.mounted) {
      ScaffoldMessenger.of(communityAssessmentContext!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}