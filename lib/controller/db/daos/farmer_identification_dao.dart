import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/farmeridentification_model.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/db/db_tables/farmer_identification_table.dart' as table;

class FarmerIdentificationDao {
  final LocalDBHelper dbHelper;

  FarmerIdentificationDao({required this.dbHelper});

  /// Inserts a new farmer identification record
  Future<int> insert(FarmerIdentificationData model) async {
    final db = await dbHelper.database;
    
    final data = {
      table.FarmerIdentificationTable.coverPageId: model.coverPageId,
      table.FarmerIdentificationTable.hasGhanaCard: model.hasGhanaCard,
      table.FarmerIdentificationTable.ghanaCardNumber: model.ghanaCardNumber,
      table.FarmerIdentificationTable.selectedIdType: model.selectedIdType,
      table.FarmerIdentificationTable.idNumber: model.idNumber,
      table.FarmerIdentificationTable.idPictureConsent: model.idPictureConsent,
      table.FarmerIdentificationTable.noConsentReason: model.noConsentReason,
      table.FarmerIdentificationTable.idImagePath: model.idImagePath,
      table.FarmerIdentificationTable.contactNumber: model.contactNumber,
      table.FarmerIdentificationTable.childrenCount: model.childrenCount,
      table.FarmerIdentificationTable.createdAt: model.createdAt.toIso8601String(),
      table.FarmerIdentificationTable.updatedAt: DateTime.now().toIso8601String(),
      table.FarmerIdentificationTable.isSynced: 0, // Not synced by default
      table.FarmerIdentificationTable.syncStatus: 0, // Not synced yet
    };

    // Remove null values to use database defaults
    data.removeWhere((key, value) => value == null);

    final id = await db.insert(
      table.FarmerIdentificationTable.tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  /// Updates an existing farmer identification record
  Future<int> update(FarmerIdentificationData model) async {
    if (model.id == null) {
      throw Exception('Cannot update a farmer identification record without an ID');
    }

    final db = await dbHelper.database;
    
    final data = {
      table.FarmerIdentificationTable.coverPageId: model.coverPageId,
      table.FarmerIdentificationTable.hasGhanaCard: model.hasGhanaCard,
      table.FarmerIdentificationTable.ghanaCardNumber: model.ghanaCardNumber,
      table.FarmerIdentificationTable.selectedIdType: model.selectedIdType,
      table.FarmerIdentificationTable.idNumber: model.idNumber,
      table.FarmerIdentificationTable.idPictureConsent: model.idPictureConsent,
      table.FarmerIdentificationTable.noConsentReason: model.noConsentReason,
      table.FarmerIdentificationTable.idImagePath: model.idImagePath,
      table.FarmerIdentificationTable.contactNumber: model.contactNumber,
      table.FarmerIdentificationTable.childrenCount: model.childrenCount,
      table.FarmerIdentificationTable.updatedAt: DateTime.now().toIso8601String(),
      table.FarmerIdentificationTable.isSynced: model.isSynced,
      table.FarmerIdentificationTable.syncStatus: model.syncStatus,
    };

    // Remove null values to use existing values
    data.removeWhere((key, value) => value == null);

    return await db.update(
      table.FarmerIdentificationTable.tableName,
      data,
      where: '${table.FarmerIdentificationTable.id} = ?',
      whereArgs: [model.id],
    );
  }

  /// Retrieves a farmer identification record by ID
  Future<FarmerIdentificationData?> getById(int id) async {
    final db = await dbHelper.database;
    
    final maps = await db.query(
      table.FarmerIdentificationTable.tableName,
      where: '${table.FarmerIdentificationTable.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves a farmer identification record by cover page ID
  Future<FarmerIdentificationData?> getByCoverPageId(int coverPageId) async {
    final db = await dbHelper.database;
    
    final maps = await db.query(
      table.FarmerIdentificationTable.tableName,
      where: '${table.FarmerIdentificationTable.coverPageId} = ?',
      whereArgs: [coverPageId],
    );

    if (maps.isNotEmpty) {
      return _fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all farmer identification records
  Future<List<FarmerIdentificationData>> getAll() async {
    final db = await dbHelper.database;
    
    final maps = await db.query(table.FarmerIdentificationTable.tableName);
    
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Retrieves all unsynced farmer identification records
  Future<List<FarmerIdentificationData>> getUnsynced() async {
    final db = await dbHelper.database;
    
    final maps = await db.query(
      table.FarmerIdentificationTable.tableName,
      where: '${table.FarmerIdentificationTable.isSynced} = ?',
      whereArgs: [0], // 0 means not synced
    );
    
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Deletes a farmer identification record by ID
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    
    return await db.delete(
      table.FarmerIdentificationTable.tableName,
      where: '${table.FarmerIdentificationTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;
    
    return await db.update(
      table.FarmerIdentificationTable.tableName,
      {
        table.FarmerIdentificationTable.isSynced: 1,
        table.FarmerIdentificationTable.syncStatus: 1,
        table.FarmerIdentificationTable.updatedAt: DateTime.now().toIso8601String(),
      },
      where: '${table.FarmerIdentificationTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// Converts a database map to a FarmerIdentificationData object
  FarmerIdentificationData _fromMap(Map<String, dynamic> map) {
    return FarmerIdentificationData(
      id: map[table.FarmerIdentificationTable.id],
      coverPageId: map[table.FarmerIdentificationTable.coverPageId],
      hasGhanaCard: map[table.FarmerIdentificationTable.hasGhanaCard] ?? 0,
      ghanaCardNumber: map[table.FarmerIdentificationTable.ghanaCardNumber],
      selectedIdType: map[table.FarmerIdentificationTable.selectedIdType],
      idNumber: map[table.FarmerIdentificationTable.idNumber],
      idPictureConsent: map[table.FarmerIdentificationTable.idPictureConsent] ?? 0,
      noConsentReason: map[table.FarmerIdentificationTable.noConsentReason],
      idImagePath: map[table.FarmerIdentificationTable.idImagePath],
      contactNumber: map[table.FarmerIdentificationTable.contactNumber],
      childrenCount: map[table.FarmerIdentificationTable.childrenCount] ?? 0,
      createdAt: DateTime.parse(map[table.FarmerIdentificationTable.createdAt] as String),
      updatedAt: DateTime.parse(map[table.FarmerIdentificationTable.updatedAt] as String),
      isSynced: map[table.FarmerIdentificationTable.isSynced] ?? 0,
      syncStatus: map[table.FarmerIdentificationTable.syncStatus] ?? 0,
      // Note: Children would need to be loaded separately as they're in a different table
    );
  }
}
