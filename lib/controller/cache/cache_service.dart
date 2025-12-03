import 'dart:convert';
import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:human_rights_monitor/controller/models/auth/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffCache {
  static const String _staffKey = 'cached_staff_data';
  static const String _authTokenKey = 'auth_token';

  // Save staff data to cache
  static Future<void> saveStaff(UserModel staff, {String? authToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final staffJson = staff.toJson();
      final staffString = json.encode(staffJson);
      await prefs.setString(_staffKey, staffString);
      
      // Save auth token if provided
      if (authToken != null) {
        await prefs.setString(_authTokenKey, authToken);
      }
    } catch (e) {
      debugPrint('Error saving staff to cache: $e');
    }
  }
  
  // Get auth token
  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  // Get staff data from cache
  static Future<UserModel?> getStaff() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final staffString = prefs.getString(_staffKey);

      if (staffString == null) {
        return null;
      }

      final staffJson = json.decode(staffString) as Map<String, dynamic>;

      // Parse assigned_districts
      final assignedDistrictsJson = staffJson['assigned_districts'] as List;
      final assignedDistricts = assignedDistrictsJson
          .map((districtJson) => AssignedDistrict.fromJson(districtJson))
          .toList();

      return UserModel(
        id: staffJson['id'] as int,
        firstName: staffJson['first_name'] as String,
        lastName: staffJson['last_name'] as String,
        gender: staffJson['gender'] as String,
        contact: staffJson['contact'] as String,
        designation: staffJson['designation'] as int,
        emailAddress: staffJson['email_address'] as String,
        staffid: staffJson['staffid'] as String,
        district: staffJson['district'] as String?,
        assignedDistricts: assignedDistricts,
      );
    } catch (e) {
      debugPrint('Error getting staff from cache: $e');
      return null;
    }
  }

  // Clear staff data from cache
  static Future<void> clearStaff() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_staffKey);
      await prefs.remove(_authTokenKey);
    } catch (e) {
      debugPrint('Error clearing staff cache: $e');
    }
  }

  // Check if staff data exists in cache
  static Future<bool> hasCachedStaff() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_staffKey);
  }
}