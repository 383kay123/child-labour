import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:human_rights_monitor/controller/db/db_tables/repositories/farmers_repo.dart';
import 'package:human_rights_monitor/controller/models/farmers/farmers_model.dart';

class GetService {
  static const String baseUrl = 'http://childlabourmonitor.afarinick.com/api/v1';

  List<Farmer> farmers = [];

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
}
