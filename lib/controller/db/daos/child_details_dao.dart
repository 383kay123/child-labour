// lib/controller/db/daos/child_details_dao.dart
import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/models/chilld_details_model.dart';

import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';


class ChildDetailsDao {
  final HouseholdDBHelper dbHelper;

  ChildDetailsDao({required this.dbHelper});

  /// Saves a child details record
  Future<int> save(ChildDetailsModel child) async {
    try {
      final db = await dbHelper.database;
      final now = DateTime.now().toIso8601String();
      
      // Convert the child details to a map
      final data = child.toMap()
        ..addAll({
          'created_at': now,
          'updated_at': now,
          'is_synced': 0,
          'sync_status': 0,
        });

      // If child has an ID, update existing record, otherwise insert new
      if (child.id != null) {
        return await db.update(
          'child_details',
          data,
          where: 'id = ?',
          whereArgs: [child.id],
        );
      } else {
        return await db.insert('child_details', data);
      }
    } catch (e) {
      debugPrint('❌ Error saving child details: $e');
      rethrow;
    }
  }

  /// Gets a child details record by ID
  Future<ChildDetailsModel?> getById(int id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'child_details',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return ChildDetailsModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting child details: $e');
      rethrow;
    }
  }

  /// Gets all child details for a specific household
  Future<List<ChildDetailsModel>> getByHouseholdId(int householdId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'child_details',
        where: 'household_id = ?',
        whereArgs: [householdId],
      );

      return List.generate(maps.length, (i) => ChildDetailsModel.fromMap(maps[i]));
    } catch (e) {
      debugPrint('❌ Error getting child details by household: $e');
      rethrow;
    }
  }

  /// Deletes a child details record
  Future<int> delete(int id) async {
    try {
      final db = await dbHelper.database;
      return await db.delete(
        'child_details',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('❌ Error deleting child details: $e');
      rethrow;
    }
  }
}