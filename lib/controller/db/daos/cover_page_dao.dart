import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/db/household_tables.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';

class CoverPageDao {
  final HouseholdDBHelper dbHelper;

  CoverPageDao({required this.dbHelper});

  /// Inserts a new cover page record
  Future<int> insert(CoverPageData model) async {
    final db = await dbHelper.database;
    
    try {
      final data = CoverPageTable.prepareCoverPageData(model);
      
      debugPrint('📝 Inserting cover page data: ${model.toString()}');
      
      final id = await db.insert(
        CoverPageTable.tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      debugPrint('✅ Cover page data inserted with ID: $id');
      return id;
    } on DatabaseException catch (e) {
      debugPrint('❌ Database error inserting cover page: $e');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error inserting cover page data: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Retrieves a cover page record by ID
  Future<CoverPageData?> getById(int id) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        CoverPageTable.tableName,
        where: '${CoverPageTable.id} = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        debugPrint('✅ Retrieved cover page with ID: $id');
        return CoverPageTable.fromMap(result.first);
      }
      debugPrint('ℹ️ No cover page found with ID: $id');
      return null;
    } on DatabaseException catch (e) {
      debugPrint('❌ Database error getting cover page by ID $id: $e');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting cover page by ID $id: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Updates an existing cover page record
  Future<int> update(CoverPageData model) async {
    if (model.id == null) {
      throw ArgumentError('Cannot update a model without an ID');
    }

    try {
      final db = await dbHelper.database;
      final data = CoverPageTable.prepareCoverPageData(model);
      
      debugPrint('📝 Updating cover page with ID: ${model.id}');
      
      final count = await db.update(
        CoverPageTable.tableName,
        data,
        where: '${CoverPageTable.id} = ?',
        whereArgs: [model.id],
      );
      
      debugPrint(count > 0 
          ? '✅ Updated $count cover page record(s)' 
          : 'ℹ️ No records updated for ID: ${model.id}');
          
      return count;
    } on DatabaseException catch (e) {
      debugPrint('❌ Database error updating cover page: $e');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating cover page: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Gets all cover page records
  Future<List<CoverPageData>> getAll() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> result = 
          await db.query(CoverPageTable.tableName);
          
      debugPrint('📝 Retrieved ${result.length} cover page records');
      return result.map((e) => CoverPageTable.fromMap(e)).toList();
    } on DatabaseException catch (e) {
      debugPrint('❌ Database error getting all cover pages: $e');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting all cover pages: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Gets unsynced cover page records
  Future<List<CoverPageData>> getUnsynced() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        CoverPageTable.tableName,
        where: '${CoverPageTable.is_synced} = ?',
        whereArgs: [0],
      );
      
      debugPrint('📝 Found ${maps.length} unsynced cover page records');
      return maps.map((map) => CoverPageTable.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      debugPrint('❌ Database error getting unsynced cover pages: $e');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting unsynced cover pages: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Deletes a cover page record by ID
  Future<int> delete(int id) async {
    try {
      final db = await dbHelper.database;
      debugPrint('🗑️ Deleting cover page with ID: $id');
      
      final count = await db.delete(
        CoverPageTable.tableName,
        where: '${CoverPageTable.id} = ?',
        whereArgs: [id],
      );
      
      debugPrint(count > 0 
          ? '✅ Deleted $count cover page record(s)' 
          : 'ℹ️ No records deleted for ID: $id');
          
      return count;
    } on DatabaseException catch (e) {
      debugPrint('❌ Database error deleting cover page: $e');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error deleting cover page: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    try {
      final db = await dbHelper.database;
      debugPrint('🔄 Marking cover page as synced - ID: $id');
      
      final count = await db.update(
        CoverPageTable.tableName,
        {
          CoverPageTable.is_synced: 1,
          CoverPageTable.updated_at: DateTime.now().toIso8601String(),
        },
        where: '${CoverPageTable.id} = ?',
        whereArgs: [id],
      );
      
      debugPrint(count > 0 
          ? '✅ Marked $count cover page record(s) as synced' 
          : 'ℹ️ No records updated for ID: $id');
          
      return count;
    } on DatabaseException catch (e) {
      debugPrint('❌ Database error marking cover page as synced: $e');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ Error marking cover page as synced: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
