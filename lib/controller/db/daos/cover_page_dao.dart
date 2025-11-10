import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';

class CoverPageDao {
  final HouseholdDBHelper dbHelper;

  CoverPageDao({required this.dbHelper});

  /// Inserts a new cover page record
  Future<int> insert(CoverPageData model) async {
    final db = await dbHelper.database;
    
    final data = {
      'selectedTownCode': model.selectedTownCode,
      'selectedFarmerCode': model.selectedFarmerCode,
      'towns': model.towns.map((town) => town.toMap()).toList(),
      'farmers': model.farmers.map((farmer) => farmer.toMap()).toList(),
      'townError': model.townError,
      'farmerError': model.farmerError,
      'isLoadingTowns': model.isLoadingTowns ? 1 : 0,
      'isLoadingFarmers': model.isLoadingFarmers ? 1 : 0,
      'hasUnsavedChanges': model.hasUnsavedChanges ? 1 : 0,
      'member': model.member,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    return await db.insert(
      TableNames.coverPageTBL,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing cover page record
  Future<int> update(CoverPageData model) async {
    if (model.id == null) {
      throw ArgumentError('Cannot update a model without an ID');
    }

    final db = await dbHelper.database;
    
    final data = {
      'selectedTownCode': model.selectedTownCode,
      'selectedFarmerCode': model.selectedFarmerCode,
      'towns': model.towns.map((town) => town.toMap()).toList(),
      'farmers': model.farmers.map((farmer) => farmer.toMap()).toList(),
      'townError': model.townError,
      'farmerError': model.farmerError,
      'isLoadingTowns': model.isLoadingTowns ? 1 : 0,
      'isLoadingFarmers': model.isLoadingFarmers ? 1 : 0,
      'hasUnsavedChanges': model.hasUnsavedChanges ? 1 : 0,
      'member': model.member,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    return await db.update(
      TableNames.coverPageTBL,
      data,
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  /// Gets a cover page record by ID
  Future<CoverPageData?> getById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      TableNames.coverPageTBL,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      // Map the database columns to the model properties
      return CoverPageData.fromMap(result.first);
    }
    return null;
  }

  /// Gets all cover page records
  Future<List<CoverPageData>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = 
        await db.query(TableNames.coverPageTBL);
    return result.map((e) => CoverPageData.fromMap(e)).toList();
  }

  /// Gets unsynced cover page records
  Future<List<CoverPageData>> getUnsynced() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.coverPageTBL,
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => CoverPageData.fromMap(map)).toList();
  }

  /// Deletes a cover page record by ID
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      TableNames.coverPageTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      TableNames.coverPageTBL,
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
