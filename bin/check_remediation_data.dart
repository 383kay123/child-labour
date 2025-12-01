import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


Future<void> main() async {
  try {
    print('🔍 Checking remediation data in the database...');
    
    // Get the database path
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'household.db');
    
    print('📂 Database path: $path');
    
    // Check if database exists
    final dbExists = await File(path).exists();
    if (!dbExists) {
      print('❌ Database file not found at: $path');
      return;
    }
    
    // Open the database
    final db = await openDatabase(path);
    
    try {
      // Query the remediation table
      final List<Map<String, dynamic>> remediationData = await db.query(
        TableNames.remediationTBL,
        orderBy: 'id DESC',
      );
      
      print('\n📊 Found ${remediationData.length} remediation records:');
      print('─' * 80);
      
      if (remediationData.isEmpty) {
        print('No remediation records found in the database.');
      } else {
        for (var i = 0; i < remediationData.length; i++) {
          final record = remediationData[i];
          print('📝 Record #${i + 1}:');
          print('   ID: ${record['id']}');
          print('   Cover Page ID: ${record['cover_page_id']}');
          print('   Has School Fees: ${record['has_school_fees']}');
          print('   Child Protection Education: ${record['child_protection_education']}');
          print('   School Kits Support: ${record['school_kits_support']}');
          print('   IGA Support: ${record['iga_support']}');
          print('   Other Support: ${record['other_support']}');
          print('   Other Support Details: ${record['other_support_details']}');
          print('   Community Action: ${record['community_action']}');
          print('   Other Community Action Details: ${record['other_community_action_details']}');
          print('   Created At: ${record['created_at']}');
          print('   Updated At: ${record['updated_at']}');
          print('   Is Synced: ${record['is_synced']}');
          print('   Sync Status: ${record['sync_status']}');
          print('─' * 80);
        }
      }
    } catch (e) {
      print('❌ Error querying remediation table: $e');
      
      // If there's an error, try to list all tables to help with debugging
      try {
        print('\n🔍 Listing all tables in the database:');
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'"
        );
        
        for (var table in tables) {
          print('- ${table['name']}');
        }
      } catch (e) {
        print('❌ Error listing tables: $e');
      }
    } finally {
      await db.close();
    }
  } catch (e) {
    print('❌ An error occurred: $e');
  }
}
