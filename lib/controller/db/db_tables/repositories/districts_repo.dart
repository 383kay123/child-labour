import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/districts/districts_model.dart';
import 'package:sqflite/sqflite.dart';

class DistrictRepository {
  final LocalDBHelper databaseHelper = LocalDBHelper.instance;

  // Create - Insert a single district
  Future<int> insertDistrict(District district) async {
    final db = await databaseHelper.database;
    
    try {
      final id = await db.insert(
        'districts',
        district.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      throw Exception('Failed to insert district: $e');
    }
  }

  // Bulk Insert - Insert multiple districts using Batch
  Future<List<int>> insertDistricts(List<District> districts) async {
    final db = await databaseHelper.database;
    final batch = db.batch();
    
    try {
      for (final district in districts) {
        batch.insert(
          'districts',
          district.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      final results = await batch.commit();
      return results.cast<int>();
    } catch (e) {
      throw Exception('Failed to insert districts in bulk: $e');
    }
  }

  // Bulk Insert with Transaction (More efficient for large datasets)
  Future<List<int>> insertDistrictsTransaction(List<District> districts) async {
    final db = await databaseHelper.database;
    
    return await db.transaction((txn) async {
      final List<int> ids = [];
      
      for (final district in districts) {
        final id = await txn.insert(
          'districts',
          district.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        ids.add(id);
      }
      
      return ids;
    });
  }

  // Read - Get all districts
  Future<List<District>> getAllDistricts() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('districts');
    return List.generate(maps.length, (i) => District.fromJson(maps[i]));
  }

  // Read - Get district by ID
  Future<District?> getDistrictById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'districts',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return District.fromJson(maps.first);
    }
    return null;
  }

  // Read - Get districts by region foreign key
  Future<List<District>> getDistrictsByRegion(int regionId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'districts',
      where: 'regionTbl_foreignkey = ?',
      whereArgs: [regionId],
    );
    return List.generate(maps.length, (i) => District.fromJson(maps[i]));
  }

  // Read - Get district by district code
  Future<District?> getDistrictByCode(String districtCode) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'districts',
      where: 'district_code = ?',
      whereArgs: [districtCode],
    );
    
    if (maps.isNotEmpty) {
      return District.fromJson(maps.first);
    }
    return null;
  }

  // Read - Get districts with pagination
  Future<List<District>> getDistrictsPaginated(int limit, int offset) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'districts',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) => District.fromJson(maps[i]));
  }

  // Update - Update a district
  Future<int> updateDistrict(District district) async {
    final db = await databaseHelper.database;
    
    return await db.update(
      'districts',
      district.toJson(),
      where: 'id = ?',
      whereArgs: [district.id],
    );
  }

  // Delete - Delete a district by ID
  Future<int> deleteDistrict(int id) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'districts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete - Delete districts by region
  Future<int> deleteDistrictsByRegion(int regionId) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'districts',
      where: 'regionTbl_foreignkey = ?',
      whereArgs: [regionId],
    );
  }

  // Delete all districts
  Future<int> deleteAllDistricts() async {
    final db = await databaseHelper.database;
    return await db.delete('districts');
  }

  // Count total districts
  Future<int> getDistrictsCount() async {
    final db = await databaseHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM districts'),
    );
    return count ?? 0;
  }

  // Count districts by region
  Future<int> getDistrictsCountByRegion(int regionId) async {
    final db = await databaseHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM districts WHERE regionTbl_foreignkey = ?',
        [regionId],
      ),
    );
    return count ?? 0;
  }

  // Search districts by name or code
  Future<List<District>> searchDistricts(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'districts',
      where: 'district LIKE ? OR district_code LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => District.fromJson(maps[i]));
  }

  // Check if district exists
  Future<bool> districtExists(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'districts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  // Get districts ordered by name
  Future<List<District>> getDistrictsOrderByName({bool ascending = true}) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'districts',
      orderBy: 'district ${ascending ? 'ASC' : 'DESC'}',
    );
    return List.generate(maps.length, (i) => District.fromJson(maps[i]));
  }
}