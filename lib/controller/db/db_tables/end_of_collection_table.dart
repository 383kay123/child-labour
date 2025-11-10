import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';

class EndOfCollectionTable {
  static const String tableName = TableNames.endOfCollectionTBL;
  
  // Primary key
  static const String id = 'id';
  
  // Foreign keys
  static const String farmIdentificationId = 'farm_identification_id';
  
  // Image paths
  static const String respondentImagePath = 'respondent_image_path';
  static const String producerSignaturePath = 'producer_signature_path';
  
  // Location data
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String gpsCoordinates = 'gps_coordinates';
  
  // Additional information
  static const String remarks = 'remarks';
  
  // Timestamps and sync
  static const String endTime = 'end_time';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the end of collection table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $farmIdentificationId INTEGER NOT NULL,
        $respondentImagePath TEXT,
        $producerSignaturePath TEXT,
        $latitude REAL,
        $longitude REAL,
        $gpsCoordinates TEXT,
        $endTime TEXT,
        $remarks TEXT,
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
        SET $createdAt = COALESCE($createdAt, datetime('now')),
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
        respondentImagePath: 'TEXT',
        producerSignaturePath: 'TEXT',
        latitude: 'REAL',
        longitude: 'REAL',
        gpsCoordinates: 'TEXT',
        endTime: 'TEXT',
        remarks: 'TEXT',
        createdAt: 'TEXT NOT NULL',
        updatedAt: 'TEXT NOT NULL',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        farmIdentificationId,
        respondentImagePath,
        producerSignaturePath,
        latitude,
        longitude,
        gpsCoordinates,
        endTime,
        remarks,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        farmIdentificationId,
        respondentImagePath,
        producerSignaturePath,
        latitude,
        longitude,
        gpsCoordinates,
        endTime,
        remarks,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        respondentImagePath,
        producerSignaturePath,
        latitude,
        longitude,
        gpsCoordinates,
        endTime,
        remarks,
        updatedAt,
        isSynced,
        syncStatus,
      ];
}

/// Extension to convert model to database map
extension EndOfCollectionTableExt on Map<String, dynamic> {
  Map<String, dynamic> toEndOfCollectionMap() {
    return {
      EndOfCollectionTable.id: this['id'],
      EndOfCollectionTable.farmIdentificationId: this['farm_identification_id'],
      EndOfCollectionTable.respondentImagePath: this['respondent_image_path'],
      EndOfCollectionTable.producerSignaturePath: this['producer_signature_path'],
      EndOfCollectionTable.latitude: this['latitude'],
      EndOfCollectionTable.longitude: this['longitude'],
      EndOfCollectionTable.gpsCoordinates: this['gps_coordinates'],
      EndOfCollectionTable.endTime: this['end_time'],
      EndOfCollectionTable.remarks: this['remarks'],
      EndOfCollectionTable.createdAt: this['created_at'],
      EndOfCollectionTable.updatedAt: this['updated_at'],
      EndOfCollectionTable.isSynced: this['is_synced'] ?? 0,
      EndOfCollectionTable.syncStatus: this['sync_status'] ?? 0,
    }..removeWhere((key, value) => value == null);
  }
}
