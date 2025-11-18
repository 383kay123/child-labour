import 'dart:developer' as developer;
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';

class SensitizationQuestionsDao {
  static const String _logTag = 'SensitizationQuestionsDao';
  final LocalDBHelper dbHelper;

  SensitizationQuestionsDao({required this.dbHelper});

  /// Ensures the sensitization_questions table exists
  Future<void> _ensureTableExists() async {
    try {
      final db = await dbHelper.database;
      
      // First check if table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [TableNames.sensitizationQuestionsTBL],
      );
      
      if (tables.isEmpty) {
        developer.log('🔄 Sensitization questions table not found, creating...', name: _logTag);
        await _createTableDirectly(db);
      } else {
        // Verify we can query the table
        try {
          await db.rawQuery('SELECT 1 FROM ${TableNames.sensitizationQuestionsTBL} LIMIT 1');
          developer.log('✅ Sensitization questions table verified', name: _logTag);
        } catch (e) {
          developer.log('❌ Sensitization questions table exists but is not accessible, recreating...', name: _logTag);
          await _createTableDirectly(db);
        }
      }
    } catch (e, stackTrace) {
      developer.log('❌ Error ensuring sensitization questions table exists: $e', 
          name: _logTag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Creates the sensitization_questions table directly
  Future<void> _createTableDirectly(Database db) async {
    try {
      // Drop table if it exists
      await db.execute('DROP TABLE IF EXISTS ${TableNames.sensitizationQuestionsTBL}');
      
      // Create the table with proper schema
      await db.execute('''
        CREATE TABLE ${TableNames.sensitizationQuestionsTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          farm_identification_id INTEGER NOT NULL,
          has_sensitized_household INTEGER,
          has_sensitized_on_protection INTEGER,
          has_sensitized_on_safe_labour INTEGER,
          female_adults_count TEXT,
          male_adults_count TEXT,
          consent_for_picture INTEGER,
          consent_reason TEXT,
          sensitization_image_path TEXT,
          household_with_user_image_path TEXT,
          parents_reaction TEXT,
          submitted_at TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (farm_identification_id) 
            REFERENCES ${TableNames.combinedFarmIdentificationTBL} (id) ON DELETE CASCADE
        )
      ''');
      
      // Create index for better performance
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_sensitization_questions_farm_id 
        ON ${TableNames.sensitizationQuestionsTBL} (farm_identification_id)
      ''');
      
      developer.log('✅ Sensitization questions table created successfully', name: _logTag);
    } catch (e, stackTrace) {
      developer.log('❌ Error creating sensitization questions table: $e', 
          name: _logTag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Inserts a new sensitization questions record
  Future<int> insert(SensitizationQuestionsData model, int coverPageId) async {
    try {
      developer.log('🔄 Starting to insert sensitization questions data...', name: _logTag);
      await _ensureTableExists();
      final db = await dbHelper.database;
      
      final data = {
        'farm_identification_id': coverPageId,
        'has_sensitized_household': model.hasSensitizedHousehold == true ? 1 : 0,
        'has_sensitized_on_protection': model.hasSensitizedOnProtection == true ? 1 : 0,
        'has_sensitized_on_safe_labour': model.hasSensitizedOnSafeLabour == true ? 1 : 0,
        'female_adults_count': model.femaleAdultsCount,
        'male_adults_count': model.maleAdultsCount,
        'consent_for_picture': model.consentForPicture == true ? 1 : 0,
        'consent_reason': model.consentReason,
        'sensitization_image_path': model.sensitizationImagePath,
        'household_with_user_image_path': model.householdWithUserImagePath,
        'parents_reaction': model.parentsReaction,
        'submitted_at': model.submittedAt.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
        'sync_status': 0,
      };

      developer.log('📝 Prepared data for insert: $data', name: _logTag);
      
      try {
        final id = await db.insert(
          TableNames.sensitizationQuestionsTBL,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        if (id <= 0) {
          throw Exception('Insert operation failed, invalid ID returned: $id');
        }
        
        developer.log('✅ Successfully inserted sensitization questions with ID: $id', name: _logTag);
        return id;
      } catch (insertError, stackTrace) {
        developer.log('❌ Error during database insert: $insertError', 
            name: _logTag, error: insertError, stackTrace: stackTrace);
            
        // Check if table exists
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [TableNames.sensitizationQuestionsTBL],
        );
        
        if (tables.isEmpty) {
          developer.log('🔄 Table does not exist, recreating...', name: _logTag);
          await _createTableDirectly(db);
          
          // Retry the insert after recreating the table
          final retryId = await db.insert(
            TableNames.sensitizationQuestionsTBL,
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          
          if (retryId <= 0) {
            throw Exception('Insert operation failed after table recreation, invalid ID: $retryId');
          }
          
          developer.log('✅ Successfully inserted after table recreation with ID: $retryId', name: _logTag);
          return retryId;
        }
        
        rethrow;
      }
    } catch (e, stackTrace) {
      developer.log('❌ Error inserting sensitization questions: $e', 
          name: _logTag, error: e, stackTrace: stackTrace);
          
      // If insert fails due to missing table, recreate and retry once
      if (e.toString().contains('no such table')) {
        developer.log('🔄 Table missing, recreating and retrying...', name: _logTag);
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return await insert(model, coverPageId); // Retry
      }
      
      rethrow;
    }
  }

  /// Updates an existing sensitization questions record
  Future<int> update(SensitizationQuestionsData model, int coverPageId) async {
    try {
      developer.log('🔄 Starting to update sensitization questions data for cover page ID: $coverPageId', name: _logTag);
      await _ensureTableExists();
      final db = await dbHelper.database;
      
      final data = {
        'has_sensitized_household': model.hasSensitizedHousehold == true ? 1 : 0,
        'has_sensitized_on_protection': model.hasSensitizedOnProtection == true ? 1 : 0,
        'has_sensitized_on_safe_labour': model.hasSensitizedOnSafeLabour == true ? 1 : 0,
        'female_adults_count': model.femaleAdultsCount,
        'male_adults_count': model.maleAdultsCount,
        'consent_for_picture': model.consentForPicture == true ? 1 : 0,
        'consent_reason': model.consentReason,
        'sensitization_image_path': model.sensitizationImagePath,
        'household_with_user_image_path': model.householdWithUserImagePath,
        'parents_reaction': model.parentsReaction,
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
        'sync_status': 0,
      };

      developer.log('📝 Prepared data for update: $data', name: _logTag);
      
      try {
        final count = await db.update(
          TableNames.sensitizationQuestionsTBL,
          data,
          where: 'farm_identification_id = ?',
          whereArgs: [coverPageId],
        );
        
        developer.log('✅ Successfully updated $count record(s) for farm ID: $coverPageId', name: _logTag);
        
        if (count == 0) {
          developer.log('ℹ️ No records were updated, will attempt to insert instead', name: _logTag);
          // Try to insert if update didn't affect any rows (record might not exist)
          try {
            final id = await insert(model, coverPageId);
            developer.log('✅ Inserted new record with ID: $id', name: _logTag);
            return 1; // Return 1 to indicate success
          } catch (insertError) {
            developer.log('❌ Failed to insert new record: $insertError', name: _logTag);
            return 0;
          }
        }
        
        return count;
      } catch (updateError, stackTrace) {
        developer.log('❌ Error during database update: $updateError', 
            name: _logTag, error: updateError, stackTrace: stackTrace);
            
        // Check if table exists
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [TableNames.sensitizationQuestionsTBL],
        );
        
        if (tables.isEmpty) {
          developer.log('🔄 Table does not exist, recreating...', name: _logTag);
          await _createTableDirectly(db);
          
          // Retry the update after recreating the table
          final retryCount = await db.update(
            TableNames.sensitizationQuestionsTBL,
            data,
            where: 'farm_identification_id = ?',
            whereArgs: [coverPageId],
          );
          
          developer.log('✅ Successfully updated $retryCount record(s) after table recreation', name: _logTag);
          return retryCount;
        }
        
        rethrow;
      }
    } catch (e, stackTrace) {
      developer.log('❌ Error updating sensitization questions: $e', 
          name: _logTag, error: e, stackTrace: stackTrace);
          
      // If update fails due to missing table, recreate and return 0
      if (e.toString().contains('no such table')) {
        developer.log('🔄 Table missing, recreating...', name: _logTag);
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return 0;
      }
      
      rethrow;
    }
  }

  /// Gets a sensitization questions record by ID
  Future<SensitizationQuestionsData?> getById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.sensitizationQuestionsTBL,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets a sensitization questions record by cover page ID
  Future<SensitizationQuestionsData?> getByCoverPageId(int coverPageId) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.sensitizationQuestionsTBL,
        where: 'farm_identification_id = ?',
        whereArgs: [coverPageId],
        orderBy: 'id DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        developer.log('ℹ️ No sensitization questions found for cover page ID: $coverPageId', name: _logTag);
        return null;
      }
      
      return _fromMap(maps.first);
    } catch (e, stackTrace) {
      developer.log('❌ Error getting sensitization questions for cover page ID: $coverPageId', 
          name: _logTag, error: e, stackTrace: stackTrace);
          
      // If query fails due to missing table, recreate and return null
      if (e.toString().contains('no such table')) {
        developer.log('🔄 Table missing, recreating...', name: _logTag);
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return null;
      }
      
      rethrow;
    }
  }

  /// Gets all sensitization questions records
  Future<List<SensitizationQuestionsData>> getAll() async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(TableNames.sensitizationQuestionsTBL);
      
      developer.log('✅ Retrieved ${maps.length} sensitization questions records', name: _logTag);
      return List.generate(maps.length, (i) => _fromMap(maps[i]));
    } catch (e, stackTrace) {
      developer.log('❌ Error getting all sensitization questions: $e', 
          name: _logTag, error: e, stackTrace: stackTrace);
          
      // If query fails due to missing table, recreate and return empty list
      if (e.toString().contains('no such table')) {
        developer.log('🔄 Table missing, recreating...', name: _logTag);
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return [];
      }
      
      rethrow;
    }
  }

  /// Gets all unsynced sensitization questions records
  Future<List<SensitizationQuestionsData>> getUnsynced() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.sensitizationQuestionsTBL,
      where: 'is_synced = 0',
    );
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Deletes a sensitization questions record by ID
  Future<int> delete(int id) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      
      final count = await db.delete(
        TableNames.sensitizationQuestionsTBL,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      developer.log('🗑️ Deleted $count sensitization questions record(s) with ID: $id', name: _logTag);
      return count;
    } catch (e, stackTrace) {
      developer.log('❌ Error deleting sensitization questions with ID: $id', 
          name: _logTag, error: e, stackTrace: stackTrace);
          
      // If delete fails due to missing table, recreate and return 0
      if (e.toString().contains('no such table')) {
        developer.log('🔄 Table missing, recreating...', name: _logTag);
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return 0;
      }
      
      rethrow;
    }
  }

  /// Converts a database map to a SensitizationQuestionsData object
  SensitizationQuestionsData _fromMap(Map<String, dynamic> map) {
    return SensitizationQuestionsData(
      id: map['id'],
      coverPageId: map['farm_identification_id'],
      hasSensitizedHousehold: map['has_sensitized_household'] == 1,
      hasSensitizedOnProtection: map['has_sensitized_on_protection'] == 1,
      hasSensitizedOnSafeLabour: map['has_sensitized_on_safe_labour'] == 1,
      femaleAdultsCount: map['female_adults_count'] ?? '',
      maleAdultsCount: map['male_adults_count'] ?? '',
      consentForPicture: map['consent_for_picture'] == 1,
      consentReason: map['consent_reason'] ?? '',
      sensitizationImagePath: map['sensitization_image_path'],
      householdWithUserImagePath: map['household_with_user_image_path'],
      parentsReaction: map['parents_reaction'] ?? '',
      submittedAt: map['submitted_at'] != null ? DateTime.parse(map['submitted_at']) : DateTime.now(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isSynced: map['is_synced'] == 1,
      syncStatus: map['sync_status'] ?? 0,
    );
  }

  /// Checks if a cover page has any sensitization records
  Future<bool> hasSensitizationRecord(int coverPageId) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${TableNames.sensitizationQuestionsTBL} WHERE farm_identification_id = ?',
        [coverPageId],
      ));
      
      return count != null && count > 0;
    } catch (e, stackTrace) {
      developer.log('❌ Error checking for sensitization records for cover page ID: $coverPageId', 
          name: _logTag, error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
