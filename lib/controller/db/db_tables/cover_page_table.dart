import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';

class CoverPageTable {
  static const String tableName = TableNames.coverPageTBL;
  
  // Column names as static constants
  static const String id = 'id';
  static const String selected_town = 'selected_town';
  static const String selected_town_name = 'selected_town_name';
  static const String selected_farmer = 'selected_farmer';
  static const String selected_farmer_name = 'selected_farmer_name';
  static const String status = 'status';
  static const String sync_status = 'sync_status';
  static const String created_at = 'created_at';
  static const String updated_at = 'updated_at';
  static const String is_synced = 'is_synced';

  /// Creates the cover page table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $selected_town TEXT NOT NULL,
        $selected_town_name TEXT NOT NULL,
        $selected_farmer TEXT NOT NULL,
        $selected_farmer_name TEXT NOT NULL,
        $status INTEGER DEFAULT 0,
        $sync_status INTEGER DEFAULT 0,
        $created_at TEXT NOT NULL,
        $updated_at TEXT NOT NULL,
        $is_synced INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_sync 
      ON $tableName($sync_status, $is_synced)
    ''');
  }

  /// Creates the necessary triggers for the table
  static Future<void> createTriggers(Database db) async {
    // Create trigger to update timestamps and sync status
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_trigger
      AFTER UPDATE ON $tableName
      BEGIN
          UPDATE $tableName 
          SET 
              $updated_at = datetime('now'),
              $is_synced = 0,
              $sync_status = 0
          WHERE $id = NEW.$id;
      END;
    ''');
  }

  /// Handles database upgrades for this table
  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await createTable(db);
      await createTriggers(db);
    }
  }

  /// Prepares cover page data for insertion
  static Map<String, dynamic> prepareCoverPageData({
    required String selectedTown,
    required String selectedTownName,
    required String selectedFarmer,
    required String selectedFarmerName,
    int status = 0,
    int syncStatus = 0,
  }) {
    final now = DateTime.now().toIso8601String();
    return {
      CoverPageTable.selected_town: selectedTown,
      CoverPageTable.selected_town_name: selectedTownName,
      CoverPageTable.selected_farmer: selectedFarmer,
      CoverPageTable.selected_farmer_name: selectedFarmerName,
      CoverPageTable.status: status,
      CoverPageTable.sync_status: syncStatus,
      CoverPageTable.created_at: now,
      CoverPageTable.updated_at: now,
      CoverPageTable.is_synced: 0,
    };
  }

  /// Validates cover page data before saving
  static bool validateCoverPageData(Map<String, dynamic> data) {
    return data[selected_town] != null &&
        data[selected_town_name] != null &&
        data[selected_farmer] != null &&
        data[selected_farmer_name] != null;
  }
}
