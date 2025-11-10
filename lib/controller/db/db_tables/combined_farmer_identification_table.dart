import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/visit_information_model.dart';
import 'package:human_rights_monitor/controller/models/identification_of_owner_model.dart';
import 'package:human_rights_monitor/controller/models/workers_in_farm_model.dart';
import 'package:human_rights_monitor/controller/models/adult_info_model.dart';
import 'package:human_rights_monitor/controller/models/combined_farmer_identification_model.dart';

class CombinedFarmerIdentificationTable {
  static const String tableName = TableNames.combinedFarmIdentificationTBL;
  
  // Primary key
  static const String id = 'id';
  
  // Foreign keys
  static const String coverPageId = 'cover_page_id';
  
  // Form data columns
  static const String visitInformation = 'visit_information';
  static const String ownerInformation = 'owner_information';
  static const String workersInFarm = 'workers_in_farm';
  static const String adultsInformation = 'adults_information';
  
  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the combined farmer identification table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $coverPageId INTEGER,
        $visitInformation TEXT,
        $ownerInformation TEXT,
        $workersInFarm TEXT,
        $adultsInformation TEXT,
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        $syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY ($coverPageId) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
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
        coverPageId: 'INTEGER',
        visitInformation: 'TEXT',
        ownerInformation: 'TEXT',
        workersInFarm: 'TEXT',
        adultsInformation: 'TEXT',
        createdAt: 'TEXT NOT NULL',
        updatedAt: 'TEXT NOT NULL',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        coverPageId,
        visitInformation,
        ownerInformation,
        workersInFarm,
        adultsInformation,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        coverPageId,
        visitInformation,
        ownerInformation,
        workersInFarm,
        adultsInformation,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        visitInformation,
        ownerInformation,
        workersInFarm,
        adultsInformation,
        coverPageId,
        updatedAt,
        isSynced,
        syncStatus,
      ];
}

/// Extension to convert between model and database map
extension CombinedFarmerIdentificationTableExt on Map<String, dynamic> {
  /// Converts a CombinedFarmerIdentificationModel to a database map
  Map<String, dynamic> toCombinedFarmIdentificationMap() {
    final model = this['model'] as CombinedFarmerIdentificationModel;
    
    return {
      CombinedFarmerIdentificationTable.id: model.id,
      CombinedFarmerIdentificationTable.coverPageId: model.coverPageId,
      CombinedFarmerIdentificationTable.visitInformation: 
          model.visitInformation != null ? jsonEncode(model.visitInformation!.toJson()) : null,
      CombinedFarmerIdentificationTable.ownerInformation: 
          model.ownerInformation != null ? jsonEncode(model.ownerInformation!.toJson()) : null,
      CombinedFarmerIdentificationTable.workersInFarm: 
          model.workersInFarm != null ? jsonEncode(model.workersInFarm!.toJson()) : null,
      CombinedFarmerIdentificationTable.adultsInformation: 
          model.adultsInformation != null ? jsonEncode(model.adultsInformation!.toJson()) : null,
      CombinedFarmerIdentificationTable.createdAt: model.createdAt?.toIso8601String(),
      CombinedFarmerIdentificationTable.updatedAt: model.updatedAt?.toIso8601String(),
      CombinedFarmerIdentificationTable.isSynced: model.isSynced ? 1 : 0,
      CombinedFarmerIdentificationTable.syncStatus: model.syncStatus ?? 0,
    }..removeWhere((key, value) => value == null);
  }

  /// Creates a CombinedFarmerIdentificationModel from a database row
  CombinedFarmerIdentificationModel toCombinedFarmIdentificationModel() {
    return CombinedFarmerIdentificationModel(
      id: this[CombinedFarmerIdentificationTable.id],
      coverPageId: this[CombinedFarmerIdentificationTable.coverPageId],
      visitInformation: this[CombinedFarmerIdentificationTable.visitInformation] != null
          ? VisitInformationData.fromJson(
              jsonDecode(this[CombinedFarmerIdentificationTable.visitInformation])
                  as Map<String, dynamic>)
          : null,
      ownerInformation: this[CombinedFarmerIdentificationTable.ownerInformation] != null
          ? IdentificationOfOwnerData.fromJson(
              jsonDecode(this[CombinedFarmerIdentificationTable.ownerInformation])
                  as Map<String, dynamic>)
          : null,
      workersInFarm: this[CombinedFarmerIdentificationTable.workersInFarm] != null
          ? WorkersInFarmData.fromJson(
              jsonDecode(this[CombinedFarmerIdentificationTable.workersInFarm])
                  as Map<String, dynamic>)
          : null,
      adultsInformation: this[CombinedFarmerIdentificationTable.adultsInformation] != null
          ? AdultsInformationData.fromJson(
              jsonDecode(this[CombinedFarmerIdentificationTable.adultsInformation])
                  as Map<String, dynamic>)
          : null,
      createdAt: this[CombinedFarmerIdentificationTable.createdAt] != null
          ? DateTime.parse(this[CombinedFarmerIdentificationTable.createdAt])
          : null,
      updatedAt: this[CombinedFarmerIdentificationTable.updatedAt] != null
          ? DateTime.parse(this[CombinedFarmerIdentificationTable.updatedAt])
          : null,
      isSynced: this[CombinedFarmerIdentificationTable.isSynced] == 1,
      syncStatus: this[CombinedFarmerIdentificationTable.syncStatus],
    );
  }
}
