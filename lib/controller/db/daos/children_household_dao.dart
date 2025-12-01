import 'dart:convert';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:sqflite/sqflite.dart';

class ChildrenHouseholdDao {
  final HouseholdDBHelper dbHelper;

  ChildrenHouseholdDao({required this.dbHelper});

  /// Saves a children household record (inserts or updates)
  Future<int> save(ChildrenHouseholdModel model, int farmIdentificationId) async {
    if (model.id == null) {
      return await insert(model, farmIdentificationId);
    } else {
      return await update(model);
    }
  }

  /// Inserts a new children household record
  Future<int> insert(ChildrenHouseholdModel model, int farmIdentificationId) async {
    try {
      final db = await dbHelper.database;
      
      final now = DateTime.now().toIso8601String();
      final data = {
        'farm_identification_id': farmIdentificationId,
        'has_children_in_household': model.hasChildrenInHousehold,
        'number_of_children': model.numberOfChildren,
        'children_5_to_17': model.children5To17,
        'children_details': jsonEncode(model.childrenDetails ?? []),
        'created_at': now,
        'updated_at': now,
        'is_synced': 0,
        'sync_status': 0,
      };
      
      print('📝 Inserting children household data: $data');

      final id = await db.insert(
        'children_household',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      print('✅ Inserted children household with ID: $id');
      return id;
    } catch (e) {
      print('❌ Error in ChildrenHouseholdDao.insert: $e');
      rethrow;
    }
  }

  /// Updates an existing children household record
  Future<int> update(ChildrenHouseholdModel model) async {
    if (model.id == null) {
      throw ArgumentError('Cannot update a model without an ID');
    }

    try {
      final db = await dbHelper.database;
      
      final data = {
        'farm_identification_id': model.coverPageId,
        'has_children_in_household': model.hasChildrenInHousehold,
        'number_of_children': model.numberOfChildren,
        'children_5_to_17': model.children5To17,
        'children_details': jsonEncode(model.childrenDetails ?? []),
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 0,  // Reset sync status on update
      };

      print('🔄 Updating children household ID ${model.id} with data: $data');
      
      final count = await db.update(
        'children_household',
        data,
        where: 'id = ?',
        whereArgs: [model.id],
      );
      
      print('✅ Updated $count record(s) in children_household');
      return count;
    } catch (e) {
      print('❌ Error in ChildrenHouseholdDao.update: $e');
      rethrow;
    }
  }

  /// Gets a children household record by ID
  Future<ChildrenHouseholdModel?> getById(int id) async {
    try {
      final db = await dbHelper.database;
      print('🔍 Querying children_household for ID: $id');
      
      final List<Map<String, dynamic>> maps = await db.query(
        'children_household',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        print('ℹ️ No record found for ID: $id');
        return null;
      }
      
      final record = _fromMap(maps.first);
      print('✅ Found record: ${record.toString()}');
      return record;
    } catch (e) {
      print('❌ Error in getById: $e');
      rethrow;
    }
  }

  /// Gets a children household record by farm identification ID
  Future<ChildrenHouseholdModel?> getByFarmIdentificationId(int farmId) async {
    try {
      final db = await dbHelper.database;
      print('🔍 Querying children_household for farm_identification_id: $farmId');
      
      final List<Map<String, dynamic>> maps = await db.query(
        'children_household',
        where: 'farm_identification_id = ?',
        whereArgs: [farmId],
        orderBy: 'id DESC',
        limit: 1,
      );

      print('ℹ️ Found ${maps.length} records for farm_identification_id: $farmId');
      if (maps.isEmpty) return null;
      
      final record = _fromMap(maps.first);
      print('✅ Mapped record: ${record.toString()}');
      return record;
    } catch (e) {
      print('❌ Error in getByFarmIdentificationId: $e');
      rethrow;
    }
  }

  /// Gets all children household records
  Future<List<ChildrenHouseholdModel>> getAll() async {
    try {
      final db = await dbHelper.database;
      print('🔍 Fetching all children household records');
      
      final List<Map<String, dynamic>> maps = await db.query(
        'children_household',
        orderBy: 'created_at DESC',
      );
      
      print('ℹ️ Found ${maps.length} records');
      return List.generate(maps.length, (i) => _fromMap(maps[i]));
    } catch (e) {
      print('❌ Error in getAll: $e');
      rethrow;
    }
  }

  /// Deletes a children household record by ID
  Future<int> delete(int id) async {
    try {
      final db = await dbHelper.database;
      print('🗑️ Deleting children household record with ID: $id');
      
      final count = await db.delete(
        'children_household',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      print('✅ Deleted $count record(s)');
      return count;
    } catch (e) {
      print('❌ Error in delete: $e');
      rethrow;
    }
  }

  /// Converts a database map to a ChildrenHouseholdModel
  ChildrenHouseholdModel _fromMap(Map<String, dynamic> map) {
    try {
      return ChildrenHouseholdModel(
        id: map['id'] as int?,
        coverPageId: map['farm_identification_id'] as int?,
        hasChildrenInHousehold: map['has_children_in_household']?.toString() ?? 'No',
        numberOfChildren: map['number_of_children'] as int? ?? 0,
        children5To17: map['children_5_to_17'] as int? ?? 0,
        childrenDetails: map['children_details'] != null
            ? List<Map<String, dynamic>>.from(
                jsonDecode(map['children_details']))
            : [],
        timestamp: map['created_at'] != null
            ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      print('❌ Error in _fromMap: $e');
      print('Problematic map data: $map');
      rethrow;
    }
  }

  /// Gets the count of unsynced children household records
  Future<int> getUnsyncedCount() async {
    final db = await dbHelper.database;
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM children_household WHERE is_synced = 0',
    );
    return count.first['count'] as int;
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      'children_household',
      {
        'is_synced': 1,
        'sync_status': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
