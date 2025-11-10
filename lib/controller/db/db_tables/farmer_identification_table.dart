import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';

class FarmerIdentificationTable {
  static const String tableName = TableNames.farmerIdentificationTBL;
  
  // Column names in snake_case for SQLite
  static const String id = 'id';
  static const String coverPageId = 'cover_page_id';
  static const String hasGhanaCard = 'has_ghana_card';
  static const String ghanaCardNumber = 'ghana_card_number';
  static const String selectedIdType = 'selected_id_type';
  static const String idNumber = 'id_number';
  static const String idPictureConsent = 'id_picture_consent';
  static const String noConsentReason = 'no_consent_reason';
  static const String idImagePath = 'id_image_path';
  static const String contactNumber = 'contact_number';
  static const String childrenCount = 'children_count';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $coverPageId INTEGER,
        $hasGhanaCard INTEGER DEFAULT 0,
        $ghanaCardNumber TEXT,
        $selectedIdType TEXT,
        $idNumber TEXT,
        $idPictureConsent INTEGER DEFAULT 0,
        $noConsentReason TEXT,
        $idImagePath TEXT,
        $contactNumber TEXT,
        $childrenCount INTEGER DEFAULT 0,
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        $syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY ($coverPageId) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
      )
    ''');

    await _createTriggers(db);
  }

  static Future<void> _createTriggers(Database db) async {
    // Create trigger to update timestamps and sync status
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_trigger
      AFTER UPDATE ON $tableName
      BEGIN
          UPDATE $tableName 
          SET 
              $updatedAt = datetime('now'),
              $isSynced = 0,
              $syncStatus = 0
          WHERE $id = NEW.$id;
      END;
    ''');
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      try {
        // Drop any existing triggers first
        await db.execute('DROP TRIGGER IF EXISTS update_${tableName}_trigger');
        
        // Check if we need to migrate from old schema
        final oldTableInfo = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='farmer_identification_table'"
        );
        
        if (oldTableInfo.isNotEmpty) {
          // Get all columns from old table
          final oldColumns = await db.rawQuery('PRAGMA table_info(farmer_identification_table)');
          final columnMap = <String, String>{};
          
          // Map column names to their types for the migration
          for (var column in oldColumns) {
            final name = column['name'] as String;
            columnMap[name.toLowerCase()] = name; // Store original case for reference
          }
          
          // Create a safe column reference
          String safeColumn(String name, {String defaultValue = 'NULL'}) {
            final lowerName = name.toLowerCase();
            if (columnMap.containsKey(lowerName)) {
              return '"' + columnMap[lowerName]! + '"'; // Use original case in quotes
            }
            return defaultValue;
          }
          
          // Create a new temporary table with the new schema
          await db.execute('''
            CREATE TABLE ${tableName}_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cover_page_id INTEGER,
              has_ghana_card INTEGER DEFAULT 0,
              ghana_card_number TEXT,
              selected_id_type TEXT,
              id_number TEXT,
              id_picture_consent INTEGER DEFAULT 0,
              no_consent_reason TEXT,
              id_image_path TEXT,
              contact_number TEXT,
              children_count INTEGER DEFAULT 0,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              is_synced INTEGER DEFAULT 0,
              sync_status INTEGER DEFAULT 0
            )
          ''');
          
          // Migrate data with safe column references
          await db.execute('''
            INSERT INTO ${tableName}_new (
              id,
              cover_page_id,
              has_ghana_card,
              ghana_card_number,
              selected_id_type,
              id_number,
              id_picture_consent,
              no_consent_reason,
              id_image_path,
              contact_number,
              children_count,
              created_at,
              updated_at,
              is_synced,
              sync_status
            )
            SELECT 
              id,
              ${safeColumn('cover_page_id', defaultValue: 'NULL')},
              COALESCE(${safeColumn('has_ghana_card')}, 0) as has_ghana_card,
              ${safeColumn('ghana_card_number')} as ghana_card_number,
              ${safeColumn('selected_id_type')} as selected_id_type,
              ${safeColumn('id_number')} as id_number,
              COALESCE(${safeColumn('id_picture_consent')}, 0) as id_picture_consent,
              ${safeColumn('no_consent_reason')} as no_consent_reason,
              ${safeColumn('id_image_path')} as id_image_path,
              ${safeColumn('contact_number')} as contact_number,
              COALESCE(${safeColumn('children_count')}, 0) as children_count,
              COALESCE(${safeColumn('created_at')}, datetime('now')) as created_at,
              COALESCE(${safeColumn('updated_at')}, datetime('now')) as updated_at,
              COALESCE(${safeColumn('is_synced')}, 0) as is_synced,
              COALESCE(${safeColumn('sync_status')}, 0) as sync_status
            FROM farmer_identification_table
          ''');
          
          // Drop old table and rename new one
          await db.execute('DROP TABLE IF EXISTS farmer_identification_table');
          await db.execute('ALTER TABLE ${tableName}_new RENAME TO farmer_identification_table');
          
          // Recreate indexes and triggers
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_farmer_identification_sync 
            ON farmer_identification_table(sync_status, is_synced)
          ''');
          
          await _createTriggers(db);
        } else {
          // No old table exists, just create a new one
          await createTable(db);
        }
      } catch (e, stackTrace) {
        print('Error during migration: $e\n$stackTrace');
        // If migration fails, ensure we have a valid table structure
        await db.execute('DROP TABLE IF EXISTS farmer_identification_table');
        await createTable(db);
      }
    }
  }
}
