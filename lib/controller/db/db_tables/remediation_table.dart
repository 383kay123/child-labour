import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';

class RemediationTable {
  static const String tableName = TableNames.remediationTBL;
  
  // Primary key
  static const String id = 'id';
  
  // Foreign keys
  static const String farmIdentificationId = 'farm_identification_id';
  
  // School Fees Information
  static const String hasSchoolFees = 'has_school_fees';
  
  // Support Options
  static const String childProtectionEducation = 'child_protection_education';
  static const String schoolKitsSupport = 'school_kits_support';
  static const String igaSupport = 'iga_support';
  static const String otherSupport = 'other_support';
  static const String otherSupportDetails = 'other_support_details';
  
  // Community Action
  static const String communityAction = 'community_action';
  static const String otherCommunityActionDetails = 'other_community_action_details';
  
  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the remediation table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $farmIdentificationId INTEGER NOT NULL,
        $hasSchoolFees INTEGER,
        $childProtectionEducation INTEGER DEFAULT 0,
        $schoolKitsSupport INTEGER DEFAULT 0,
        $igaSupport INTEGER DEFAULT 0,
        $otherSupport INTEGER DEFAULT 0,
        $otherSupportDetails TEXT,
        $communityAction TEXT,
        $otherCommunityActionDetails TEXT,
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
        hasSchoolFees: 'INTEGER',
        childProtectionEducation: 'INTEGER DEFAULT 0',
        schoolKitsSupport: 'INTEGER DEFAULT 0',
        igaSupport: 'INTEGER DEFAULT 0',
        otherSupport: 'INTEGER DEFAULT 0',
        otherSupportDetails: 'TEXT',
        communityAction: 'TEXT',
        otherCommunityActionDetails: 'TEXT',
        createdAt: 'TEXT NOT NULL',
        updatedAt: 'TEXT NOT NULL',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        farmIdentificationId,
        hasSchoolFees,
        childProtectionEducation,
        schoolKitsSupport,
        igaSupport,
        otherSupport,
        otherSupportDetails,
        communityAction,
        otherCommunityActionDetails,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        farmIdentificationId,
        hasSchoolFees,
        childProtectionEducation,
        schoolKitsSupport,
        igaSupport,
        otherSupport,
        otherSupportDetails,
        communityAction,
        otherCommunityActionDetails,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        hasSchoolFees,
        childProtectionEducation,
        schoolKitsSupport,
        igaSupport,
        otherSupport,
        otherSupportDetails,
        communityAction,
        otherCommunityActionDetails,
        updatedAt,
        isSynced,
        syncStatus,
      ];
}

/// Extension to convert model to database map
extension RemediationTableExt on Map<String, dynamic> {
  Map<String, dynamic> toRemediationMap() {
    return {
      RemediationTable.id: this['id'],
      RemediationTable.farmIdentificationId: this['farm_identification_id'],
      RemediationTable.hasSchoolFees: this['has_school_fees'],
      RemediationTable.childProtectionEducation: this['child_protection_education'] ?? 0,
      RemediationTable.schoolKitsSupport: this['school_kits_support'] ?? 0,
      RemediationTable.igaSupport: this['iga_support'] ?? 0,
      RemediationTable.otherSupport: this['other_support'] ?? 0,
      RemediationTable.otherSupportDetails: this['other_support_details'],
      RemediationTable.communityAction: this['community_action'],
      RemediationTable.otherCommunityActionDetails: this['other_community_action_details'],
      RemediationTable.createdAt: this['created_at'],
      RemediationTable.updatedAt: this['updated_at'],
      RemediationTable.isSynced: this['is_synced'] ?? 0,
      RemediationTable.syncStatus: this['sync_status'] ?? 0,
    }..removeWhere((key, value) => value == null);
  }
}
