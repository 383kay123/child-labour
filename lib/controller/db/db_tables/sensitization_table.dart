import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';

class SensitizationTable {
  static const String tableName = TableNames.sensitizationTBL;
  
  // Primary key
  static const String id = 'id';
  
  // Foreign keys
  static const String farmIdentificationId = 'farm_identification_id';
  
  // Fields
  static const String isAcknowledged = 'is_acknowledged';
  static const String acknowledgedAt = 'acknowledged_at';
  
  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the sensitization table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $farmIdentificationId INTEGER NOT NULL,
        $isAcknowledged INTEGER DEFAULT 0,
        $acknowledgedAt TEXT,
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
        isAcknowledged: 'INTEGER DEFAULT 0',
        acknowledgedAt: 'TEXT',
        createdAt: 'TEXT NOT NULL',
        updatedAt: 'TEXT NOT NULL',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        farmIdentificationId,
        isAcknowledged,
        acknowledgedAt,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        farmIdentificationId,
        isAcknowledged,
        acknowledgedAt,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        isAcknowledged,
        acknowledgedAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];
}

/// Extension to convert model to database map
extension SensitizationTableExt on Map<String, dynamic> {
  Map<String, dynamic> toSensitizationMap() {
    return {
      SensitizationTable.id: this['id'],
      SensitizationTable.farmIdentificationId: this['farm_identification_id'],
      SensitizationTable.isAcknowledged: this['is_acknowledged'] ?? 0,
      SensitizationTable.acknowledgedAt: this['acknowledged_at'],
      SensitizationTable.createdAt: this['created_at'],
      SensitizationTable.updatedAt: this['updated_at'],
      SensitizationTable.isSynced: this['is_synced'] ?? 0,
      SensitizationTable.syncStatus: this['sync_status'] ?? 0,
    }..removeWhere((key, value) => value == null);
  }
}
