import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/farmers/farmers_model.dart';
import 'package:sqflite/sqflite.dart';

class FarmerRepository {
  final LocalDBHelper databaseHelper = LocalDBHelper.instance;

  // Create - Insert a single farmer
  Future<int> insertFarmer(Farmer farmer) async {
    final db = await databaseHelper.database;
    
    try {
      final id = await db.insert(
        'farmers',
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
          'farmers',
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
          'farmers',
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
    final List<Map<String, dynamic>> maps = await db.query('farmers');
    return List.generate(maps.length, (i) => Farmer.fromJson(maps[i]));
  }

  // Read - Get farmer by ID
  Future<Farmer?> getFarmerById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'farmers',
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
      'farmers',
      where: 'farmer_code = ?',
      whereArgs: [farmerCode],
    );
    
    if (maps.isNotEmpty) {
      return Farmer.fromJson(maps.first);
    }
    return null;
  }

  // Read - Get farmers with pagination
  Future<List<Farmer>> getFarmersPaginated(int limit, int offset) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'farmers',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) => Farmer.fromJson(maps[i]));
  }

  // Update - Update a farmer
  // Future<int> updateFarmer(Farmer farmer) async {
  //   final db = await databaseHelper.database;
    
  //   return await db.update(
  //     'farmers',
  //     farmer.toJson(),
  //     where: 'id = ?',
  //     whereArgs: [farmer.id], // You'll need to add an id field to your Farmer model
  //   );
  // }

  // Update - Update farmer by farmer code
  Future<int> updateFarmerByCode(Farmer farmer) async {
    final db = await databaseHelper.database;
    
    return await db.update(
      'farmers',
      farmer.toJson(),
      where: 'farmer_code = ?',
      whereArgs: [farmer.farmerCode],
    );
  }

  // Delete - Delete a farmer by ID
  Future<int> deleteFarmer(int id) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'farmers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete - Delete a farmer by farmer code
  Future<int> deleteFarmerByCode(String farmerCode) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'farmers',
      where: 'farmer_code = ?',
      whereArgs: [farmerCode],
    );
  }

  // Delete all farmers
  Future<int> deleteAllFarmers() async {
    final db = await databaseHelper.database;
    return await db.delete('farmers');
  }

  // Count total farmers
  Future<int> getFarmersCount() async {
    final db = await databaseHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM farmers'),
    );
    return count ?? 0;
  }

  // Search farmers by name
  Future<List<Farmer>> searchFarmersByName(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'farmers',
      where: 'first_name LIKE ? OR last_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Farmer.fromJson(maps[i]));
  }
}