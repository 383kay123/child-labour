import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/cover_page_model.dart';

class CoverPageDao {
  final LocalDBHelper dbHelper;

  CoverPageDao({required this.dbHelper});

  /// Inserts a new cover page record
  Future<int> insert(CoverPageModel model) async {
    final db = await dbHelper.database;
    
    final data = {
      'selected_town': model.selectedTown,
      'selected_town_name': model.selectedTownName,
      'selected_farmer': model.selectedFarmer,
      'selected_farmer_name': model.selectedFarmerName,
      'status': model.status,
      'sync_status': 0,
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
  Future<int> update(CoverPageModel model) async {
    if (model.id == null) {
      throw ArgumentError('Cannot update a model without an ID');
    }

    final db = await dbHelper.database;
    
    final data = {
      'selected_town': model.selectedTown,
      'selected_town_name': model.selectedTownName,
      'selected_farmer': model.selectedFarmer,
      'selected_farmer_name': model.selectedFarmerName,
      'status': model.status,
      'sync_status': model.syncStatus,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': model.syncStatus == 1 ? 1 : 0,
    };

    return await db.update(
      TableNames.coverPageTBL,
      data,
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  /// Gets a cover page record by ID
  Future<CoverPageModel?> getById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      TableNames.coverPageTBL,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      // Map the database columns to the model properties
      final map = Map<String, dynamic>.from(result.first);
      return CoverPageModel(
        id: map['id'],
        selectedTown: map['selected_town'],
        selectedTownName: map['selected_town_name'],
        selectedFarmer: map['selected_farmer'],
        selectedFarmerName: map['selected_farmer_name'],
        status: map['status'] ?? 0,
        syncStatus: map['sync_status'] ?? 0,
        createdAt: map['created_at'],
        updatedAt: map['updated_at'],
      );
    }
    return null;
  }

  /// Gets all cover page records
  Future<List<CoverPageModel>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(TableNames.coverPageTBL);
    return result.map((map) => CoverPageModel(
      id: map['id'],
      selectedTown: map['selected_town'],
      selectedTownName: map['selected_town_name'],
      selectedFarmer: map['selected_farmer'],
      selectedFarmerName: map['selected_farmer_name'],
      status: map['status'] ?? 0,
      syncStatus: map['sync_status'] ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    )).toList();
  }

  /// Gets unsynced cover page records
  Future<List<CoverPageModel>> getUnsynced() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.coverPageTBL,
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => CoverPageModel(
      id: map['id'],
      selectedTown: map['selected_town'],
      selectedTownName: map['selected_town_name'],
      selectedFarmer: map['selected_farmer'],
      selectedFarmerName: map['selected_farmer_name'],
      status: map['status'] ?? 0,
      syncStatus: map['sync_status'] ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    )).toList();
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
