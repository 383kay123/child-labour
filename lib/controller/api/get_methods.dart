import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:human_rights_monitor/controller/cache/cache_service.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/districts_repo.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/farmers_repo.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/society_repo.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/staff_repo.dart';
import 'package:human_rights_monitor/controller/models/farmers/farmers_model.dart';
import 'package:human_rights_monitor/controller/models/districts/districts_model.dart';
import 'package:human_rights_monitor/controller/models/societies/societies_model.dart';
import 'package:human_rights_monitor/controller/models/staff/staff_model.dart';
import 'package:human_rights_monitor/controller/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class GetService {
  static const String baseUrl = 'http://childlabourmonitor.afarinick.com/api/v1';

  List<Farmer> farmers = [];
  List<District> districts = [];  
  
  
  


 
  Future<bool> postPCIData(Map<String, dynamic> pciData) async {
  try {
    const String apiUrl = 'http://childlabourmonitor.afarinick.com/api/v1/pci/';
    
    debugPrint('🚀 Sending PCI data to server...');
    
    // Get the current user's ID from AuthProvider
    final authProvider = Provider.of<AuthProvider>(Get.context!, listen: false);
    final currentUserId = authProvider.user?.id;
    
    if (currentUserId == null) {
      throw Exception('No user is currently logged in');
    }
    
    // Update the enumerator ID with the current user's ID
    pciData['enumerator'] = currentUserId;
    
    // Ensure society is valid
    if (pciData['society'] == null || pciData['society'] == 0) {
      // Try to get the society ID from the assessment data if available
      if (pciData['assessment'] != null && pciData['assessment']['society_id'] != null) {
        pciData['society'] = pciData['assessment']['society_id'];
        debugPrint('ℹ️ Using society ID from assessment data: ${pciData['society']}');
      } else {
        throw Exception('Society ID is required and cannot be 0');
      }
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    debugPrint('Request headers: $headers');
    debugPrint('Request body: ${jsonEncode(pciData)}');
    
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(pciData),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('✅ Successfully posted PCI data to server');
      debugPrint('Response: ${response.body}');
      return true;
    } else {
      debugPrint('❌ Failed to post PCI data. Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      throw Exception('Failed to post PCI data: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error in postPCIData: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}


  // Simple GET all farmers
  Future<bool> fetchFarmers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/farmers'));
      debugPrint("Raw Results from Server============${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle both array and object responses
        List<dynamic> data = [];
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'] ?? [];
        } else {
          data = [responseData];
        }
        
        farmers = data.map((json) => Farmer.fromJson(json)).toList();
        debugPrint("Converted Farmers: ${farmers.length} items");

        await FarmerRepository().deleteAllFarmers();
        await FarmerRepository().insertFarmersTransaction(farmers);

        return true;
      } else {
        throw Exception('Failed to load farmers: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint("Error from fetching farmers======$e");
      debugPrint(stackTrace.toString());
      return false;
    }
  }

   Future<bool> fetchSocieties() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/societies'));
      debugPrint("Raw Results from Server============${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle both array and object responses
        List<dynamic> data = [];
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'] ?? [];
        } else {
          data = [responseData];
        }
        
        final societies = data.map((json) => Society.fromJson(json)).toList();
        debugPrint("Converted Societies: ${societies.length} items");

        final societyRepo = SocietyRepository();
        await societyRepo.deleteAllSocieties();
        await societyRepo.insertSocietiesTransaction(societies);

        return true;
      } else {
        throw Exception('Failed to load societies: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint("Error from fetching societies======$e");
      debugPrint(stackTrace.toString());
      return false;
    }
  }

  Future<bool> fetchStaff() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/staff'));
      debugPrint("Raw Staff Data from Server: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle both array and object responses
        List<dynamic> data = [];
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'] ?? [];
        } else {
          data = [responseData];
        }
        
        final staffList = data.map((json) => StaffModel.fromJson(json)).toList();
        debugPrint("Converted Staff: ${staffList.length} items");

        final staffRepo = StaffRepository();
        await staffRepo.deleteAllStaff();
        
        // Insert staff in batches to handle large datasets
        for (var i = 0; i < staffList.length; i += 50) {
          final end = (i + 50 < staffList.length) ? i + 50 : staffList.length;
          final batch = staffList.sublist(i, end);
          await staffRepo.insertStaffList(batch);
        }

        return true;
      } else {
        throw Exception('Failed to load staff: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint("Error fetching staff: $e");
      debugPrint("Stack trace: $stackTrace");
      return false;
    }
  }

  Future<bool> fetchDistricts() async {
    try {
      debugPrint('🔍 Fetching districts from: $baseUrl/districts');
      final response = await http.get(
        Uri.parse('$baseUrl/districts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        dynamic responseData;
        try {
          responseData = json.decode(response.body);
        } catch (e) {
          debugPrint('❌ Error decoding JSON: $e');
          throw Exception('Invalid JSON response from server');
        }

        List<dynamic> data = [];
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map) {
          if (responseData.containsKey('data')) {
            data = responseData['data'] is List ? responseData['data'] : [];
          } else {
            data = [responseData]; // Handle single district response
          }
        }

        debugPrint('📊 Found ${data.length} districts in response');

        if (data.isEmpty) {
          debugPrint('⚠️ No districts data found in the response');
          return false;
        }

        final districts = <District>[];
        for (var item in data) {
          try {
            if (item is Map<String, dynamic>) {
              final district = District.fromJson(item);
              districts.add(district);
            }
          } catch (e) {
            debugPrint('⚠️ Error parsing district: $e');
            debugPrint('Problematic data: $item');
            continue; // Skip invalid items but continue with the rest
          }
        }

        if (districts.isEmpty) {
          debugPrint('❌ No valid districts could be parsed from the response');
          return false;
        }

        debugPrint('✅ Successfully parsed ${districts.length} districts');
        
        final repo = DistrictRepository();
        await repo.deleteAllDistricts();
        await repo.insertDistrictsTransaction(districts);

        debugPrint('💾 Successfully saved ${districts.length} districts to local database');
        return true;
      } else {
        throw Exception('Failed to load districts: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in fetchDistricts: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
