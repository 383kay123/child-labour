import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/farmers/farmers_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class FarmerRepository {
  final LocalDBHelper databaseHelper = LocalDBHelper.instance;

  // Create - Insert a single farmer
  Future<int> insertFarmer(Farmer farmer) async {
    final db = await databaseHelper.database;
    
    try {
      final id = await db.insert(
        TableNames.farmersTBL,
        farmer.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      throw Exception('Failed to insert farmer: $e');
    }
  }

  // Bulk Insert - Insert multiple farmers
  Future<List<int>> insertFarmers(List<Farmer> farmers) async {
    final db = await databaseHelper.database;
    final batch = db.batch();
    
    try {
      for (final farmer in farmers) {
        batch.insert(
          TableNames.farmersTBL,
          farmer.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      final results = await batch.commit();
      return results.cast<int>();
    } catch (e) {
      throw Exception('Failed to insert farmers in bulk: $e');
    }
  }

  // Bulk Insert with Transaction (More efficient for large datasets)
  Future<List<int>> insertFarmersTransaction(List<Farmer> farmers) async {
    final db = await databaseHelper.database;
    
    return await db.transaction((txn) async {
      final List<int> ids = [];
      
      for (final farmer in farmers) {
        final id = await txn.insert(
          TableNames.farmersTBL,
          farmer.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        ids.add(id);
      }
      
      return ids;
    });
  }

  // Read - Get all farmers
  Future<List<Farmer>> getAllFarmers() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(TableNames.farmersTBL);
    return List.generate(maps.length, (i) => Farmer.fromJson(maps[i]));
  }




    // Read - Get the first 10 farmers, ordered by farmerCode
    Future<List<Farmer>> getFirst10Farmers() async {
      try {
        final db = await databaseHelper.database;
        final List<Map<String, dynamic>> maps = await db.query(
          TableNames.farmersTBL,
          orderBy: 'farmer_code ASC',
          limit: 10,
        );
        debugPrint('Fetched ${maps.length} farmers');
        return List.generate(maps.length, (i) => Farmer.fromJson(maps[i]));
      } catch (e) {
        debugPrint('Error in getFirst10Farmers: $e');
        rethrow;
      }
    }

  // Read - Get farmer by ID
  Future<Farmer?> getFarmerById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.farmersTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Farmer.fromJson(maps.first);
    }
    return null;
  }

  // Read - Get farmer by farmer code
  Future<Farmer?> getFarmerByCode(String farmerCode) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.farmersTBL,
      where: 'farmer_code = ?',
      whereArgs: [farmerCode],
    );
    
    if (maps.isNotEmpty) {
      return Farmer.fromJson(maps.first);
    }
    return null;
  }

  
  // Update - Update a farmer
  // Future<int> updateFarmer(Farmer farmer) async {
  //   final db = await databaseHelper.database;
    
  //   return await db.update(
  //     TableNames.farmersTBL,
  //     farmer.toJson(),
  //     where: 'id = ?',
  //     whereArgs: [farmer.id], // You'll need to add an id field to your Farmer model
  //   );
  // }

  // Update - Update farmer by farmer code
  Future<int> updateFarmerByCode(Farmer farmer) async {
    final db = await databaseHelper.database;
    
    return await db.update(
      TableNames.farmersTBL,
      farmer.toJson(),
      where: 'farmer_code = ?',
      whereArgs: [farmer.farmerCode],
    );
  }

  // Delete - Delete a farmer by ID
  Future<int> deleteFarmer(int id) async {
    final db = await databaseHelper.database;
    return await db.delete(
      TableNames.farmersTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete - Delete a farmer by farmer code
  Future<int> deleteFarmerByCode(String farmerCode) async {
    final db = await databaseHelper.database;
    return await db.delete(
      TableNames.farmersTBL,
      where: 'farmer_code = ?',
      whereArgs: [farmerCode],
    );
  }

  // Delete all farmers
  Future<int> deleteAllFarmers() async {
    final db = await databaseHelper.database;
    return await db.delete(TableNames.farmersTBL);
  }

  // Count total farmers
  Future<int> getFarmersCount() async {
    final db = await databaseHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${TableNames.farmersTBL}'),
    );
    return count ?? 0;
  }

  // Search farmers by name
  Future<List<Farmer>> searchFarmersByName(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.farmersTBL,
      where: 'first_name LIKE ? OR last_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Farmer.fromJson(maps[i]));
  }

  // Get farmers by society name with pagination
  Future<List<Farmer>> getFarmersByDistrict(
    String societyName, {
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await databaseHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.farmersTBL,
        where: 'society_name = ?',
        whereArgs: [societyName],
        limit: limit,
        offset: offset,
        orderBy: 'first_name ASC, last_name ASC',
      );
      return List.generate(maps.length, (i) => Farmer.fromJson(maps[i]));
    } catch (e) {
      debugPrint('Error getting farmers by society: $e');
      rethrow;
    }
  }
}