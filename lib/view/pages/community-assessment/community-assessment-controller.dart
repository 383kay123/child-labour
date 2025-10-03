// import 'package:surveyflow/controller/api/api.dart';
//
// import '../../controller/db/db.dart';
// import '../../controller/models/community-assessment-model.dart';
// import '../../globals/globals.dart';
//       Globals.showSuccess("Form saved successfully");
//     } else {
//       Globals.showError("Failed to save form");
//     }
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:surveyflow/controller/api/api.dart';
import '../../../controller/db/db.dart';
import '../../../controller/models/community-assessment-model.dart';
import '../../globals/globals.dart';
import 'package:get/get.dart';

class CommunityAssessmentController {

  BuildContext? communityAssessmentContext;
  final ApiService _api = ApiService();

  var communityName = ''.obs;
  var communityScore = 0.obs;
  
  // Method to update score based on answer
  void updateScore(String questionKey, String answer) {
    if (answer == 'Yes') {
      communityScore++;
    } else if (answer == 'No' && communityScore > 0) {
      // If changing from Yes to No, decrement if score is above 0
      communityScore--;
    }
    // else {
    //   communityScore.value = score;
    // }
  }
  var q1 = ''.obs;
  var q2 = ''.obs;
  var q3 = ''.obs;
  var q4 = ''.obs;
  var q5 = ''.obs;
  var q6 = ''.obs;
  var q7 = ''.obs;
  var q8 = ''.obs;
  var q9 = ''.obs;
  var q10 = ''.obs;

  /// Submit form online, fallback to offline if network fails
  Future<bool> submit(Map<String, dynamic> answers) async {
    var response = CommunityAssessmentModel.fromMap(answers).copyWith(
      communityScore: communityScore.value,
      communityName: communityName.value,
    );

    try {
      final success = await _api.submitCommunityAssessment(response);
      if (success) {
        // mark as synced
        response = response.copyWith(status: 1);
        ScaffoldMessenger.of(communityAssessmentContext!).showSnackBar(
          SnackBar(content: Text("Form submitted successfully")),
        );
        return true;
      } else {
        // fallback: save offline
        await saveFormOffline(answers);
        ScaffoldMessenger.of(communityAssessmentContext!).showSnackBar(
          SnackBar(content: Text("Form saved offline")),
        );
        return false;
      }
    } catch (e) {
      // fallback: save offline if API call failed
      // await saveFormOffline(answers);
      ScaffoldMessenger.of(communityAssessmentContext!).showSnackBar(
        SnackBar(content: Text("Form saved offline")),
      );
      Get.back();
      return false;
    }
  }
  

  /// Save form only offline
  Future<bool> saveFormOffline(Map<String, dynamic> answers) async {

    // print the runtime type of all the answers
    // answers.forEach((key, value) {
    //   debugPrint("Key: $key, Value: $value, Type: ${value.runtimeType}");
    // });

    var response = CommunityAssessmentModel.fromMap(answers).copyWith(
      communityScore: communityScore.value,
      communityName: communityName.value,
      q7a: int.tryParse(answers["q7a"]),
    );

    debugPrint("Form saved offline: ${response.toMap()}");

    try {
      final int id = await LocalDBHelper.instance.insertCommunityAssessment(response);
      if (id > 0) {
        Navigator.pop(communityAssessmentContext!);
        ScaffoldMessenger.of(communityAssessmentContext!).showSnackBar(
          SnackBar(content: Text("Form saved offline")));
        return true;
      } else {
        ScaffoldMessenger.of(communityAssessmentContext!).showSnackBar(
            SnackBar(content: Text("Failed to save form offline")));
        return false;
      }
    } catch (e) {
      debugPrint("DB error: ${e.toString()}");
      ScaffoldMessenger.of(communityAssessmentContext!).showSnackBar(
        SnackBar(content: Text("DB error: ${e.toString()}")));
      return false;
    }
  }

  /// Sync all pending forms (status = 0) when online
  // Future<void> syncPendingForms() async {
  //   final pending = await LocalDBHelper.instance.getResponsesByStatus(status: 0);
  //
  //   for (var form in pending) {
  //     try {
  //       final success = await _api.submitCommunityAssessment(form);
  //       if (success) {
  //         // mark as synced in DB
  //         final updated = form.copyWith(status: 1);
  //         await LocalDBHelper.instance.updateResponse(updated);
  //       }
  //     } catch (_) {
  //       // if one fails, continue with next
  //       continue;
  //     }
  //   }
  // }
}
