import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/childrenhouseholdmodel.dart';

class ChildrenHouseholdDao {
  final LocalDBHelper dbHelper;

  ChildrenHouseholdDao({required this.dbHelper});

  /// Inserts a new children household record
  Future<int> insert(ChildrenHouseholdModel model, int farmIdentificationId) async {
    final db = await dbHelper.database;
    
    final data = {
      'farm_identification_id': farmIdentificationId,
      'has_children_in_household': model.hasChildrenInHousehold,
      'number_of_children': model.numberOfChildren,
      'children_5_to_17': model.children5To17,
      'children_details': jsonEncode(model.childrenDetails),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
      'sync_status': 0,
    };

    return await db.insert(
      'children_household',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing children household record
  Future<int> update(ChildrenHouseholdModel model) async {
    if (model.id == null) {
      throw ArgumentError('Cannot update a model without an ID');
    }

    final db = await dbHelper.database;
    
    final data = {
      'has_children_in_household': model.hasChildrenInHousehold,
      'number_of_children': model.numberOfChildren,
      'children_5_to_17': model.children5To17,
      'children_details': jsonEncode(model.childrenDetails),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': model.timestamp != null ? 1 : 0,
    };

    return await db.update(
      'children_household',
      data,
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  /// Gets a children household record by ID
  Future<ChildrenHouseholdModel?> getById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'children_household',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets a children household record by farm identification ID
  Future<ChildrenHouseholdModel?> getByFarmIdentificationId(int farmId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'children_household',
      where: 'farm_identification_id = ?',
      whereArgs: [farmId],
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets all children household records
  Future<List<ChildrenHouseholdModel>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('children_household');
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Deletes a children household record by ID
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'children_household',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Converts a database map to a ChildrenHouseholdModel
  ChildrenHouseholdModel _fromMap(Map<String, dynamic> map) {
    return ChildrenHouseholdModel(
      id: map['id'],
      hasChildrenInHousehold: map['has_children_in_household'],
      numberOfChildren: map['number_of_children'] ?? 0,
      children5To17: map['children_5_to_17'] ?? 0,
      childrenDetails: map['children_details'] != null
          ? List<Map<String, dynamic>>.from(
              jsonDecode(map['children_details']))
          : [],
      timestamp: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  /// Saves a children household record (inserts or updates)
  Future<int> save(ChildrenHouseholdModel model, int farmIdentificationId) async {
    if (model.id == null) {
      return await insert(model, farmIdentificationId);
    } else {
      return await update(model);
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
