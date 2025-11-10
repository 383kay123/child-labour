import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';

class SensitizationQuestionsTable {
  static const String tableName = TableNames.sensitizationQuestionsTBL;
  
  // Primary key
  static const String id = 'id';
  
  // Foreign keys
  static const String farmIdentificationId = 'farm_identification_id';
  
  // Sensitization status
  static const String hasSensitizedHousehold = 'has_sensitized_household';
  static const String hasSensitizedOnProtection = 'has_sensitized_on_protection';
  static const String hasSensitizedOnSafeLabour = 'has_sensitized_on_safe_labour';
  
  // Attendance
  static const String femaleAdultsCount = 'female_adults_count';
  static const String maleAdultsCount = 'male_adults_count';
  
  // Consent and media
  static const String consentForPicture = 'consent_for_picture';
  static const String consentReason = 'consent_reason';
  static const String sensitizationImagePath = 'sensitization_image_path';
  static const String householdWithUserImagePath = 'household_with_user_image_path';
  
  // Observations
  static const String parentsReaction = 'parents_reaction';
  
  // Timestamps and sync
  static const String submittedAt = 'submitted_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the sensitization questions table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $farmIdentificationId INTEGER NOT NULL,
        $hasSensitizedHousehold INTEGER,
        $hasSensitizedOnProtection INTEGER,
        $hasSensitizedOnSafeLabour INTEGER,
        $femaleAdultsCount TEXT,
        $maleAdultsCount TEXT,
        $consentForPicture INTEGER,
        $consentReason TEXT,
        $sensitizationImagePath TEXT,
        $householdWithUserImagePath TEXT,
        $parentsReaction TEXT,
        $submittedAt TEXT NOT NULL,
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
        SET $submittedAt = COALESCE($submittedAt, datetime('now')),
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
        hasSensitizedHousehold: 'INTEGER',
        hasSensitizedOnProtection: 'INTEGER',
        hasSensitizedOnSafeLabour: 'INTEGER',
        femaleAdultsCount: 'TEXT',
        maleAdultsCount: 'TEXT',
        consentForPicture: 'INTEGER',
        consentReason: 'TEXT',
        sensitizationImagePath: 'TEXT',
        householdWithUserImagePath: 'TEXT',
        parentsReaction: 'TEXT',
        submittedAt: 'TEXT NOT NULL',
        updatedAt: 'TEXT NOT NULL',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        farmIdentificationId,
        hasSensitizedHousehold,
        hasSensitizedOnProtection,
        hasSensitizedOnSafeLabour,
        femaleAdultsCount,
        maleAdultsCount,
        consentForPicture,
        consentReason,
        sensitizationImagePath,
        householdWithUserImagePath,
        parentsReaction,
        submittedAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        farmIdentificationId,
        hasSensitizedHousehold,
        hasSensitizedOnProtection,
        hasSensitizedOnSafeLabour,
        femaleAdultsCount,
        maleAdultsCount,
        consentForPicture,
        consentReason,
        sensitizationImagePath,
        householdWithUserImagePath,
        parentsReaction,
        submittedAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        hasSensitizedHousehold,
        hasSensitizedOnProtection,
        hasSensitizedOnSafeLabour,
        femaleAdultsCount,
        maleAdultsCount,
        consentForPicture,
        consentReason,
        sensitizationImagePath,
        householdWithUserImagePath,
        parentsReaction,
        updatedAt,
        isSynced,
        syncStatus,
      ];
}

/// Extension to convert model to database map
extension SensitizationQuestionsTableExt on Map<String, dynamic> {
  Map<String, dynamic> toSensitizationQuestionsMap() {
    return {
      SensitizationQuestionsTable.id: this['id'],
      SensitizationQuestionsTable.farmIdentificationId: this['farm_identification_id'],
      SensitizationQuestionsTable.hasSensitizedHousehold: this['has_sensitized_household'],
      SensitizationQuestionsTable.hasSensitizedOnProtection: this['has_sensitized_on_protection'],
      SensitizationQuestionsTable.hasSensitizedOnSafeLabour: this['has_sensitized_on_safe_labour'],
      SensitizationQuestionsTable.femaleAdultsCount: this['female_adults_count'],
      SensitizationQuestionsTable.maleAdultsCount: this['male_adults_count'],
      SensitizationQuestionsTable.consentForPicture: this['consent_for_picture'],
      SensitizationQuestionsTable.consentReason: this['consent_reason'],
      SensitizationQuestionsTable.sensitizationImagePath: this['sensitization_image_path'],
      SensitizationQuestionsTable.householdWithUserImagePath: this['household_with_user_image_path'],
      SensitizationQuestionsTable.parentsReaction: this['parents_reaction'],
      SensitizationQuestionsTable.submittedAt: this['submitted_at'],
      SensitizationQuestionsTable.updatedAt: this['updated_at'],
      SensitizationQuestionsTable.isSynced: this['is_synced'] ?? 0,
      SensitizationQuestionsTable.syncStatus: this['sync_status'] ?? 0,
    }..removeWhere((key, value) => value == null);
  }
}
