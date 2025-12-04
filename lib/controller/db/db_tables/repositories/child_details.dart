import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../controller/models/chilld_details_model.dart';

abstract class ChildRepository {
  Future<int> insertChild(ChildDetailsModel child);
  Future<void> insertChildren(List<ChildDetailsModel> children);
  Future<ChildDetailsModel?> getChildById(int id);
  Future<ChildDetailsModel?> getChildByHouseholdAndNumber(int householdId, int childNumber);
  Future<List<ChildDetailsModel>> getChildrenByHousehold(int householdId);
  Future<List<ChildDetailsModel>> getChildrenByCoverPageId(int coverPageId);
  Future<List<ChildDetailsModel>> getAllChildren({int? limit, int? offset, String? orderBy});
  Future<List<ChildDetailsModel>> getUnsyncedChildren();
  Future<List<ChildDetailsModel>> searchChildrenByName(String query);
  Future<int> updateChild(ChildDetailsModel child);
  Future<int> deleteAllChildren();
}

class ChildRepositoryImpl implements ChildRepository {
  final dbHelper = LocalDBHelper.instance;

  @override
  Future<int> insertChild(ChildDetailsModel child) async {
    try {
      final db = await dbHelper.database;  // Await the database instance
      return await db.insert(
        'child_details',
        child.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert child: $e');
    }
  }

  @override
  Future<void> insertChildren(List<ChildDetailsModel> children) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var child in children) {
      batch.insert('child_details', child.toMap());
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<ChildDetailsModel?> getChildById(int id) async {
    try {
      final database = await dbHelper.database;  // Await the Future<Database> to get the Database instance
      final List<Map<String, dynamic>> maps = await database.query(
        'child_details',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return ChildDetailsModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to get child by id: $e');
    }
  }

  @override
  Future<ChildDetailsModel?> getChildByHouseholdAndNumber(int householdId, int childNumber) async {
    try {
      final database = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await database.query(
        'child_details',
        where: 'household_id = ? AND child_number = ?',
        whereArgs: [householdId, childNumber],
      );
      if (maps.isNotEmpty) {
        return ChildDetailsModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to get child by household and number: $e');
    }
  }

  @override
  Future<List<ChildDetailsModel>> getChildrenByHousehold(int householdId) async {
    try {
      final database = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await database.query(
        'child_details',
        where: 'household_id = ?',
        whereArgs: [householdId],
      );
      return List.generate(maps.length, (i) => ChildDetailsModel.fromMap(maps[i]));
    } catch (e) {
      throw DatabaseException('Failed to get children by household: $e');
    }
  }

  @override
  Future<List<ChildDetailsModel>> getChildrenByCoverPageId(int coverPageId) async {
    try {
      final database = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await database.query(
        'child_details',
        where: 'cover_page_id = ?',
        whereArgs: [coverPageId],
      );
      return List.generate(maps.length, (i) => ChildDetailsModel.fromMap(maps[i]));
    } catch (e) {
      throw DatabaseException('Failed to get children by cover page ID: $e');
    }
  }

  @override
  Future<List<ChildDetailsModel>> getAllChildren({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    try {
       final database = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await database.query(
        'child_details',
        limit: limit,
        offset: offset,
        orderBy: orderBy,
      );
      return List.generate(maps.length, (i) => ChildDetailsModel.fromMap(maps[i]));
    } catch (e) {
      throw DatabaseException('Failed to get all children: $e');
    }
  }

  @override
  Future<List<ChildDetailsModel>> getUnsyncedChildren() async {
    try {
       final database = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await database.query(
        'child_details',
        where: 'is_synced = ?',
        whereArgs: [0],
      );
      return List.generate(maps.length, (i) => ChildDetailsModel.fromMap(maps[i]));
    } catch (e) {
      throw DatabaseException('Failed to get unsynced children: $e');
    }
  }

  @override
  Future<List<ChildDetailsModel>> searchChildrenByName(String query) async {
    try {
       final database = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await database.query(
        'child_details',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );
      return List.generate(maps.length, (i) => ChildDetailsModel.fromMap(maps[i]));
    } catch (e) {
      throw DatabaseException('Failed to search children by name: $e');
    }
  }

  @override
  Future<int> updateChild(ChildDetailsModel child) async {
    try {
       final database = await dbHelper.database;
      return await database.update(
        'child_details',
        child.toMap(),
        where: 'id = ?',
        whereArgs: [child.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update child: $e');
    }
  }

  @override
  Future<int> deleteAllChildren() async {
    try {
       final database = await dbHelper.database;
      return await database.delete('child_details');
    } catch (e) {
      throw DatabaseException('Failed to delete all children: $e');
    }
  }
}

class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}