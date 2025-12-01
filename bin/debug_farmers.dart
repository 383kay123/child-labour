import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  print('🔍 Starting farmer data debug...');
  
  try {
    final dbHelper = LocalDBHelper.instance;
    final db = await dbHelper.database;
    
    // Get all unique society names
    final societies = await db.rawQuery('''
      SELECT DISTINCT society_name, COUNT(*) as farmer_count 
      FROM ${TableNames.farmersTBL}
      GROUP BY society_name
      ORDER BY society_name
    ''');
    
    print('\n📊 Unique societies in farmers table:');
    for (var society in societies) {
      print('  - Society: ${society['society_name']} (${society['farmer_count']} farmers)');
    }
    
    // Get first 10 farmers for reference
    final farmers = await db.query(
      TableNames.farmersTBL,
      columns: ['first_name', 'last_name', 'farmer_code', 'society_name'],
      limit: 10,
    );
    
    print('\n👥 First 10 farmers:');
    for (var farmer in farmers) {
      print('  - ${farmer['first_name']} ${farmer['last_name']} (${farmer['farmer_code']}) - Society: ${farmer['society_name']}');
    }
    
    print('\n✅ Debug complete');
  } catch (e) {
    print('❌ Error: $e');
  }
}
