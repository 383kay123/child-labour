import 'package:flutter/foundation.dart';

class District {
  final int id;
  final DateTime createdDate;
  final String deleteField;
  final String district;
  final String districtCode;
  final int regionTblForeignkey;

  District({
    required this.id,
    required this.createdDate,
    required this.deleteField,
    required this.district,
    required this.districtCode,
    required this.regionTblForeignkey,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('Parsing district JSON: $json');
      
      // Check for required fields
      final requiredFields = ['id', 'created_date', 'delete_field', 'district', 'district_code', 'regionTbl_foreignkey'];
      for (var field in requiredFields) {
        if (json[field] == null) {
          debugPrint('⚠️ Missing or null field in district data: $field');
        }
      }

      return District(
        id: json['id'] as int? ?? 0,
        createdDate: json['created_date'] != null 
            ? DateTime.tryParse(json['created_date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        deleteField: json['delete_field']?.toString() ?? 'no',
        district: json['district']?.toString() ?? 'Unknown District',
        districtCode: json['district_code']?.toString() ?? 'UNKNOWN',
        regionTblForeignkey: (json['regionTbl_foreignkey'] as num?)?.toInt() ?? 0,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing district: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate.toIso8601String(),
      'delete_field': deleteField,
      'district': district,
      'district_code': districtCode,
      'regionTbl_foreignkey': regionTblForeignkey,
    };
  }

  @override
  String toString() {
    return 'District(id: $id, district: $district, code: $districtCode)';
  }
}