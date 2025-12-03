// auth_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:human_rights_monitor/controller/cache/cache_service.dart';
import 'package:human_rights_monitor/controller/models/auth/user_model.dart';

class AuthService {
  static const String _baseUrl = 'http://childlabourmonitor.afarinick.com';
  static const String url = "$_baseUrl/api/v1/auth/login/";
  // Login method
  static Future<UserModel?> login({
    required String staffId,
    required String password,
  }) async {
    try {
      // Prepare request body
      final requestBody = {
        'contact': staffId,
        'password': password,
      };

      debugPrint("THE URLS FOR LOGIN ::::::::::::: $url");

      // Make POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // Check response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response
        final responseData = json.decode(response.body);

        // Create LoginResponse from JSON
        final loginResponse = UserModel.fromJson(responseData["staff"]);

        // Save staff data to cache
        await StaffCache.saveStaff(loginResponse);

        return loginResponse;
      } else if (response.statusCode == 401) {
        // Unauthorized - invalid credentials
        throw Exception('Invalid staff ID or password');
      } else if (response.statusCode == 400) {
        // Bad request
        throw Exception('Please check your credentials and try again');
      } else {
        // Other server errors
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      // Network errors
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      // JSON parsing errors
      throw Exception('Invalid response from server: $e');
    } catch (e) {
      // Any other errors
      throw Exception('An error occurred: $e');
    }
  }

  // Logout method
  static Future<void> logout() async {
    // Clear cached staff data
    await StaffCache.clearStaff();
  }

  // Check if user is already logged in (has cached data)
  static Future<bool> isLoggedIn() async {
    final staff = await StaffCache.getStaff();
    debugPrint("THE STAFF IS ::::::::::::: $staff");
    return staff != null;
  }

  // Get current staff from cache
  static Future<UserModel?> getCurrentStaff() async {
    return await StaffCache.getStaff();
  }
}
