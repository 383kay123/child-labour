import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';

class SensitizationDao {
  final LocalDBHelper dbHelper;
  final HouseholdDBHelper _householdDbHelper = HouseholdDBHelper.instance;

  SensitizationDao({required this.dbHelper});

  /// Ensures the sensitization table exists before any operation
  Future<void> _ensureTableExists() async {
    try {
      final db = await dbHelper.database;
      
      // First check if table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [TableNames.sensitizationTBL],
      );
      
      if (tables.isEmpty) {
        debugPrint('🔄 Sensitization table not found, creating...');
        
        // Try to create the table directly
        try {
          await _createTableDirectly(db);
          debugPrint('✅ Sensitization table created successfully');
        } catch (e) {
          debugPrint('❌ Failed to create sensitization table: $e');
          // Try the household helper as fallback
          await _householdDbHelper.diagnoseAndFixSensitizationTable();
        }
      } else {
        debugPrint('✅ Sensitization table exists');
        
        // Verify we can actually query the table
        try {
          await db.rawQuery('SELECT 1 FROM ${TableNames.sensitizationTBL} LIMIT 1');
          debugPrint('✅ Sensitization table is accessible');
        } catch (e) {
          debugPrint('❌ Sensitization table exists but is not accessible: $e');
          await _createTableDirectly(db);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error ensuring sensitization table exists: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Creates the sensitization table directly
  Future<void> _createTableDirectly(Database db) async {
    try {
      debugPrint('🔄 Creating sensitization table directly...');
      
      // Drop table if it exists (in case it's corrupted)
      await db.execute('DROP TABLE IF EXISTS ${TableNames.sensitizationTBL}');
      
      // Create the table with proper schema
      await db.execute('''
        CREATE TABLE ${TableNames.sensitizationTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cover_page_id INTEGER NOT NULL,
          farm_identification_id INTEGER NOT NULL,
          is_acknowledged INTEGER DEFAULT 0,
          acknowledged_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (cover_page_id) REFERENCES ${TableNames.coverPageTBL} (id) ON DELETE CASCADE,
          FOREIGN KEY (farm_identification_id) REFERENCES ${TableNames.combinedFarmIdentificationTBL} (id) ON DELETE CASCADE
        )
      ''');
      
      // Create index for better performance
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_sensitization_farm_identification_id 
        ON ${TableNames.sensitizationTBL} (farm_identification_id)
      ''');
      debugPrint('✅ Sensitization table created with proper schema');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating sensitization table directly: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Inserts a new sensitization record
  Future<int> insert(SensitizationData model, int coverPageId, {int? farmIdentificationId}) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      
      if (farmIdentificationId == null) {
        throw ArgumentError('farmIdentificationId is required for sensitization record');
      }
      
      final data = model.copyWith(
        updatedAt: DateTime.now(),
        isSynced: false,
      ).toMap()
      ..addAll({
        'cover_page_id': coverPageId,
        'farm_identification_id': farmIdentificationId,
        'created_at': DateTime.now().toIso8601String(),
      });

      final id = await db.insert(
        TableNames.sensitizationTBL,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      if (kDebugMode) {
        log('✅ Inserted sensitization record with ID: $id');
      }
      
      return id;
    } catch (e, stackTrace) {
      log('❌ Error inserting sensitization record', error: e, stackTrace: stackTrace);
      
      // If insert fails, try to recreate the table and retry once
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating and retrying...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return await insert(model, coverPageId); // Retry
      }
      
      rethrow;
    }
  }

  /// Updates an existing sensitization record
  Future<int> update(SensitizationData model, int id) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      
      final data = model.copyWith(
        updatedAt: DateTime.now(),
        isSynced: false,
      ).toMap();
      
      // Remove fields that shouldn't be updated
      data.remove('id');
      data.remove('created_at');
      data.remove('farm_identification_id');

      final count = await db.update(
        TableNames.sensitizationTBL,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (kDebugMode) {
        log('✅ Updated $count sensitization record(s) with ID: $id');
      }
      
      return count;
    } catch (e, stackTrace) {
      log('❌ Error updating sensitization record', error: e, stackTrace: stackTrace);
      
      // If update fails due to missing table, recreate and return 0 (no records updated)
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return 0;
      }
      
      rethrow;
    }
  }

  /// Gets a sensitization record by ID
  Future<SensitizationData?> getById(int id) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.sensitizationTBL,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        if (kDebugMode) {
          log('ℹ️ No sensitization record found with ID: $id');
        }
        return null;
      }
      
      return _fromMap(maps.first);
    } catch (e, stackTrace) {
      log('❌ Error getting sensitization record by ID: $id', error: e, stackTrace: stackTrace);
      
      // If query fails due to missing table, recreate and return null
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return null;
      }
      
      rethrow;
    }
  }

  /// Gets a sensitization record by farm identification ID
  Future<SensitizationData?> getByFarmIdentificationId(int farmId) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.sensitizationTBL,
        where: 'farm_identification_id = ?',
        whereArgs: [farmId],
        orderBy: 'id DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        if (kDebugMode) {
          log('ℹ️ No sensitization record found for farm ID: $farmId');
        }
        return null;
      }
      
      return _fromMap(maps.first);
    } catch (e, stackTrace) {
      log('❌ Error getting sensitization record by farm ID: $farmId', 
          error: e, 
          stackTrace: stackTrace);
          
      // If query fails due to missing table, recreate and return null
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return null;
      }
      
      rethrow;
    }
  }

  /// Gets all sensitization records
  Future<List<SensitizationData>> getAll() async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(TableNames.sensitizationTBL);
      
      if (kDebugMode) {
        log('ℹ️ Found ${maps.length} sensitization records');
      }
      
      return List.generate(maps.length, (i) => _fromMap(maps[i]));
    } catch (e, stackTrace) {
      log('❌ Error getting all sensitization records', error: e, stackTrace: stackTrace);
      
      // If query fails due to missing table, recreate and return empty list
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return [];
      }
      
      rethrow;
    }
  }

  /// Deletes a sensitization record by ID
  Future<int> delete(int id) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      final count = await db.delete(
        TableNames.sensitizationTBL,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (kDebugMode) {
        log('🗑️ Deleted $count sensitization record(s) with ID: $id');
      }
      
      return count;
    } catch (e, stackTrace) {
      log('❌ Error deleting sensitization record with ID: $id', 
          error: e, 
          stackTrace: stackTrace);
          
      // If delete fails due to missing table, recreate and return 0
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return 0;
      }
      
      rethrow;
    }
  }

  /// Acknowledges sensitization for a farm identification
  /// This will create a new record if none exists, or update the existing one
  /// Returns true if successful, false otherwise
  Future<bool> acknowledge(int farmIdentificationId) async {
    try {
      await _ensureTableExists();
      final existing = await getByFarmIdentificationId(farmIdentificationId);
      final now = DateTime.now();
      
      if (kDebugMode) {
        log('🔄 Acknowledging sensitization for farm ID: $farmIdentificationId');
        log(existing == null 
            ? 'No existing record found, creating new one' 
            : 'Updating existing record ID: ${existing.id}');
      }
      
      final data = SensitizationData(
        id: existing?.id,
        isAcknowledged: true,
        acknowledgedAt: now,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        isSynced: existing?.isSynced ?? false,
      );

      if (existing == null) {
        await insert(data, farmIdentificationId);
      } else {
        await update(data, existing.id!);
      }
      
      if (kDebugMode) {
        log('✅ Successfully acknowledged sensitization for farm ID: $farmIdentificationId');
      }
      
      return true;
    } catch (e, stackTrace) {
      log('❌ Error acknowledging sensitization for farm ID: $farmIdentificationId',
          error: e,
          stackTrace: stackTrace);
          
      // If acknowledge fails due to missing table, recreate and retry once
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating and retrying...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return await acknowledge(farmIdentificationId); // Retry
      }
      
      rethrow;
    }
  }

  /// Converts a database map to a SensitizationData
  SensitizationData _fromMap(Map<String, dynamic> map) {
    return SensitizationData.fromMap(map);
  }

  /// Saves a sensitization record (inserts or updates)
  Future<int> save(SensitizationData model, int farmIdentificationId, {int? id}) async {
    if (id == null) {
      return await insert(model, farmIdentificationId);
    } else {
      return await update(model, id);
    }
  }

  /// Checks if sensitization is acknowledged for a farm
  Future<bool> isAcknowledged(int farmIdentificationId) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      final result = await db.rawQuery('''
        SELECT * FROM ${TableNames.sensitizationTBL}
        WHERE farm_identification_id = ? 
        ORDER BY id DESC 
        LIMIT 1
      ''', [farmIdentificationId]);
      
      if (result.isEmpty) {
        return false;
      }
      
      return (result.first['is_acknowledged'] as int) == 1;
    } catch (e, stackTrace) {
      log('❌ Error checking if sensitization is acknowledged for farm ID: $farmIdentificationId',
          error: e,
          stackTrace: stackTrace);
          
      // If query fails due to missing table, recreate and return false
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return false;
      }
      
      return false;
    }
  }

  /// Gets the count of unsynced sensitization records
  Future<int> getUnsyncedCount() async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      final count = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${TableNames.sensitizationTBL} WHERE is_synced = 0',
      );
      return count.first['count'] as int;
    } catch (e, stackTrace) {
      log('❌ Error getting unsynced sensitization count', error: e, stackTrace: stackTrace);
      
      // If query fails due to missing table, recreate and return 0
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return 0;
      }
      
      return 0;
    }
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      return await db.update(
        TableNames.sensitizationTBL,
        {
          'is_synced': 1,
          'sync_status': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      log('❌ Error marking sensitization record as synced for ID: $id',
          error: e,
          stackTrace: stackTrace);
          
      // If update fails due to missing table, recreate and return 0
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return 0;
      }
      
      rethrow;
    }
  }

  /// Gets all unsynced sensitization records
  Future<List<SensitizationData>> getUnsyncedRecords() async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.sensitizationTBL,
        where: 'is_synced = 0',
      );
      
      return List.generate(maps.length, (i) => _fromMap(maps[i]));
    } catch (e, stackTrace) {
      log('❌ Error getting unsynced sensitization records', error: e, stackTrace: stackTrace);
      
      // If query fails due to missing table, recreate and return empty list
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return [];
      }
      
      rethrow;
    }
  }

  /// Deletes all sensitization records for a farm
  Future<int> deleteByFarmId(int farmIdentificationId) async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      final count = await db.delete(
        TableNames.sensitizationTBL,
        where: 'farm_identification_id = ?',
        whereArgs: [farmIdentificationId],
      );
      
      if (kDebugMode) {
        log('🗑️ Deleted $count sensitization record(s) for farm ID: $farmIdentificationId');
      }
      
      return count;
    } catch (e, stackTrace) {
      log('❌ Error deleting sensitization records for farm ID: $farmIdentificationId',
          error: e,
          stackTrace: stackTrace);
          
      // If delete fails due to missing table, recreate and return 0
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return 0;
      }
      
      rethrow;
    }
  }

  /// Gets the total count of sensitization records
  Future<int> getTotalCount() async {
    try {
      await _ensureTableExists();
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${TableNames.sensitizationTBL}',
      );
      return result.first['count'] as int;
    } catch (e, stackTrace) {
      log('❌ Error getting total sensitization count', error: e, stackTrace: stackTrace);
      
      // If query fails due to missing table, recreate and return 0
      if (e.toString().contains('no such table')) {
        debugPrint('🔄 Table missing, recreating...');
        final db = await dbHelper.database;
        await _createTableDirectly(db);
        return 0;
      }
      
      return 0;
    }
  }
}