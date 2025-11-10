import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';

class ChildrenHouseholdTable {
  static const String tableName = TableNames.childrenHouseholdTBL;
  
  // Primary key
  static const String id = 'id';
  
  // Foreign keys
  static const String farmIdentificationId = 'farm_identification_id';
  
  // Fields
  static const String hasChildrenInHousehold = 'has_children_in_household';
  static const String numberOfChildren = 'number_of_children';
  static const String children5To17 = 'children_5_to_17';
  static const String childrenDetails = 'children_details'; // JSON string
  
  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the children household table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $farmIdentificationId INTEGER NOT NULL,
        $hasChildrenInHousehold TEXT,
        $numberOfChildren INTEGER DEFAULT 0,
        $children5To17 INTEGER DEFAULT 0,
        $childrenDetails TEXT,
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        $syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY ($farmIdentificationId) REFERENCES ${TableNames.combinedFarmIdentificationTBL}(id) ON DELETE CASCADE
      )
    ''');

    await _createTriggers(db);
  }

  /// Creates database triggers for the table
  static Future<void> _createTriggers(Database db) async {
    // Create trigger to update timestamps and sync status
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_timestamps
      AFTER UPDATE ON $tableName
      FOR EACH ROW
      BEGIN
        UPDATE $tableName 
        SET $updatedAt = datetime('now'),
            $isSynced = 0,
            $syncStatus = 0
        WHERE $id = NEW.$id;
      END;
    ''');

    // Create trigger for insert to set created_at and updated_at
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS set_${tableName}_timestamps
      AFTER INSERT ON $tableName
      BEGIN
        UPDATE $tableName 
        SET $createdAt = datetime('now'),
            $updatedAt = datetime('now')
        WHERE $id = NEW.$id;
      END;
    ''');
  }

  /// Drops the table
  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Returns a map of all columns and their types
  static Map<String, String> get columns => {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        farmIdentificationId: 'INTEGER NOT NULL',
        hasChildrenInHousehold: 'TEXT',
        numberOfChildren: 'INTEGER DEFAULT 0',
        children5To17: 'INTEGER DEFAULT 0',
        childrenDetails: 'TEXT',
        createdAt: 'TEXT NOT NULL',
        updatedAt: 'TEXT NOT NULL',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        farmIdentificationId,
        hasChildrenInHousehold,
        numberOfChildren,
        children5To17,
        childrenDetails,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        farmIdentificationId,
        hasChildrenInHousehold,
        numberOfChildren,
        children5To17,
        childrenDetails,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        hasChildrenInHousehold,
        numberOfChildren,
        children5To17,
        childrenDetails,
        updatedAt,
        isSynced,
        syncStatus,
      ];
}

/// Extension to convert model to database map
extension ChildrenHouseholdTableExt on Map<String, dynamic> {
  Map<String, dynamic> toChildrenHouseholdMap() {
    return {
      ChildrenHouseholdTable.id: this['id'],
      ChildrenHouseholdTable.farmIdentificationId: this['farm_identification_id'],
      ChildrenHouseholdTable.hasChildrenInHousehold: this['has_children_in_household'],
      ChildrenHouseholdTable.numberOfChildren: this['number_of_children'] ?? 0,
      ChildrenHouseholdTable.children5To17: this['children_5_to_17'] ?? 0,
      ChildrenHouseholdTable.childrenDetails: this['children_details'],
      ChildrenHouseholdTable.createdAt: this['created_at'],
      ChildrenHouseholdTable.updatedAt: this['updated_at'],
      ChildrenHouseholdTable.isSynced: this['is_synced'] ?? 0,
      ChildrenHouseholdTable.syncStatus: this['sync_status'] ?? 0,
    }..removeWhere((key, value) => value == null);
  }
}
