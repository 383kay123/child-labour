import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/societies/societies_model.dart';
import 'package:sqflite/sqflite.dart';

class SocietyRepository {
  final LocalDBHelper databaseHelper = LocalDBHelper.instance;

  // Table name from table_names.dart - using 'societies' table instead of 'society_data'
  static const String tableName = TableNames.society;

  // Create - Insert a single society
  Future<int> insertSociety(Society society) async {
    final db = await databaseHelper.database;
    
    try {
      final id = await db.insert(
        tableName,
        society.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      throw Exception('Failed to insert society: $e');
    }
  }

  // Bulk Insert - Insert multiple societies using Batch
  Future<List<int>> insertSocieties(List<Society> societies) async {
    final db = await databaseHelper.database;
    final batch = db.batch();
    
    try {
      for (final society in societies) {
        batch.insert(
          tableName,
          society.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      final results = await batch.commit();
      return results.cast<int>();
    } catch (e) {
      throw Exception('Failed to insert societies in bulk: $e');
    }
  }

  // Bulk Insert with Transaction (More efficient for large datasets)
  Future<List<int>> insertSocietiesTransaction(List<Society> societies) async {
    final db = await databaseHelper.database;
    
    return await db.transaction((txn) async {
      final List<int> ids = [];
      
      for (final society in societies) {
        final id = await txn.insert(
          tableName,
          society.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        ids.add(id);
      }
      
      return ids;
    });
  }

  // Read - Get a single society by ID
  Future<Society?> getSocietyById(int id) async {
    final db = await databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Society.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get society by ID: $e');
    }
  }

  // Read - Get all societies
  Future<List<Society>> getAllSocieties() async {
    final db = await databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(tableName);
      return List.generate(maps.length, (i) => Society.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Failed to get all societies: $e');
    }
  }

  // Read - Get societies by district ID
  Future<List<Society>> getSocietiesByDistrict(int districtId) async {
    final db = await databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'districtTbl_foreignkey = ?',
        whereArgs: [districtId],
      );
      return List.generate(maps.length, (i) => Society.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Failed to get societies by district: $e');
    }
  }

  // Update - Update a society
  Future<int> updateSociety(Society society) async {
    final db = await databaseHelper.database;
    
    try {
      return await db.update(
        tableName,
        society.toJson(),
        where: 'id = ?',
        whereArgs: [society.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to update society: $e');
    }
  }

  // Delete - Delete a society
  Future<int> deleteSociety(int id) async {
    final db = await databaseHelper.database;
    
    try {
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete society: $e');
    }
  }

  // Delete - Delete all societies
  Future<int> deleteAllSocieties() async {
    final db = await databaseHelper.database;
    
    try {
      return await db.delete(tableName);
    } catch (e) {
      throw Exception('Failed to delete all societies: $e');
    }
  }

  // Search societies by name
  Future<List<Society>> searchSocieties(String query) async {
    final db = await databaseHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'society LIKE ?',
        whereArgs: ['%$query%'],
      );
      return List.generate(maps.length, (i) => Society.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Failed to search societies: $e');
    }
  }

  // Get count of all societies
  Future<int> getSocietiesCount() async {
    final db = await databaseHelper.database;
    
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName')
      );
      return count ?? 0;
    } catch (e) {
      throw Exception('Failed to get societies count: $e');
    }
  }

  // Get count of societies in a district
  Future<int> getSocietiesCountByDistrict(int districtId) async {
    final db = await databaseHelper.database;
    
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM $tableName WHERE districtTbl_foreignkey = ?',
          [districtId],
        )
      );
      return count ?? 0;
    } catch (e) {
      throw Exception('Failed to get societies count by district: $e');
    }
  }
}