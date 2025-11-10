// import 'dart:convert';
// import 'package:sqflite/sqflite.dart';
// import '../table_names.dart';

// class UnifiedSurveyTable {
//   static const String tableName = 'unified_survey';
  
//   // Common fields
//   static const String id = 'id';
//   static const String formType = 'form_type'; // 'cover', 'consent', 'farmer', 'children', etc.
//   static const String formData = 'form_data'; // JSON string of the form data
//   static const String createdAt = 'created_at';
//   static const String updatedAt = 'updated_at';
//   static const String isSynced = 'is_synced';
  
//   // Create table SQL
//   static const String createTableSQL = '''
//     CREATE TABLE IF NOT EXISTS $tableName (
//       $id INTEGER PRIMARY KEY AUTOINCREMENT,
//       $formType TEXT NOT NULL,
//       $formData TEXT NOT NULL,
//       $createdAt TEXT NOT NULL,
//       $updatedAt TEXT NOT NULL,
//       $isSynced INTEGER DEFAULT 0
//     )
//   ''';

//   static Future<void> createTable(Database db) async {
//     await db.execute(createTableSQL);
    
//     // Create indexes for better query performance
//     await db.execute('''
//       CREATE INDEX IF NOT EXISTS idx_${tableName}_form_type ON $tableName ($formType);
//     ''');
    
//     await db.execute('''
//       CREATE INDEX IF NOT EXISTS idx_${tableName}_is_synced ON $tableName ($isSynced);
//     ''');
//   }
  
//   // Helper method to convert a map to JSON string
//   static String toJsonString(Map<String, dynamic> data) {
//     return jsonEncode(data);
//   }
  
//   // Helper method to parse JSON string back to map
//   static Map<String, dynamic> fromJsonString(String jsonString) {
//     return jsonDecode(jsonString) as Map<String, dynamic>;
//   }
// }
