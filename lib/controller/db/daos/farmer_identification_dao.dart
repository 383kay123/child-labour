import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/household_tables.dart';


class FarmerIdentificationDao {
  final LocalDBHelper dbHelper;

  FarmerIdentificationDao({required this.dbHelper});


  /// Inserts a new farmer identification record
  Future<int> insert(FarmerIdentificationData model) async {
    final db = await dbHelper.database;

    final data = {
      FarmerIdentificationTable.coverPageId: model.coverPageId,
      FarmerIdentificationTable.hasGhanaCard: model.hasGhanaCard,
      FarmerIdentificationTable.ghanaCardNumber: model.ghanaCardNumber,
      FarmerIdentificationTable.selectedIdType: model.selectedIdType,
      FarmerIdentificationTable.idNumber: model.idNumber,
      FarmerIdentificationTable.idPictureConsent: model.idPictureConsent,
      FarmerIdentificationTable.noConsentReason: model.noConsentReason,
      FarmerIdentificationTable.idImagePath: model.idImagePath,
      FarmerIdentificationTable.contactNumber: model.contactNumber,
      FarmerIdentificationTable.childrenCount: model.childrenCount,
      FarmerIdentificationTable.createdAt: model.createdAt.toIso8601String(),
      FarmerIdentificationTable.updatedAt: DateTime.now().toIso8601String(),
      FarmerIdentificationTable.isSynced: 0, // Not synced by default
      FarmerIdentificationTable.syncStatus: 0, // Not synced yet
    };

    // Remove null values to use database defaults
    data.removeWhere((key, value) => value == null);

    final id = await db.insert(
      FarmerIdentificationTable.tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  /// Updates an existing farmer identification record
  Future<int> update(FarmerIdentificationData model) async {
    if (model.id == null) {
      throw Exception(
          'Cannot update a farmer identification record without an ID');
    }

    final db = await dbHelper.database;

    final data = {
      FarmerIdentificationTable.coverPageId: model.coverPageId,
      FarmerIdentificationTable.hasGhanaCard: model.hasGhanaCard,
      FarmerIdentificationTable.ghanaCardNumber: model.ghanaCardNumber,
      FarmerIdentificationTable.selectedIdType: model.selectedIdType,
      FarmerIdentificationTable.idNumber: model.idNumber,
      FarmerIdentificationTable.idPictureConsent: model.idPictureConsent,
      FarmerIdentificationTable.noConsentReason: model.noConsentReason,
      FarmerIdentificationTable.idImagePath: model.idImagePath,
      FarmerIdentificationTable.contactNumber: model.contactNumber,
      FarmerIdentificationTable.childrenCount: model.childrenCount,
      FarmerIdentificationTable.updatedAt: DateTime.now().toIso8601String(),
      FarmerIdentificationTable.isSynced: model.isSynced,
      FarmerIdentificationTable.syncStatus: model.syncStatus,
    };

    // Remove null values to use existing values
    data.removeWhere((key, value) => value == null);

    return await db.update(
      FarmerIdentificationTable.tableName,
      data,
      where: '${FarmerIdentificationTable.id} = ?',
      whereArgs: [model.id],
    );
  }

  /// Retrieves a farmer identification record by ID
  Future<FarmerIdentificationData?> getById(int id) async {
    final db = await dbHelper.database;

    final maps = await db.query(
      FarmerIdentificationTable.tableName,
      where: '${FarmerIdentificationTable.id} = ?',
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
      FarmerIdentificationTable.tableName,
      where: '${FarmerIdentificationTable.coverPageId} = ?',
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

    final maps = await db.query(FarmerIdentificationTable.tableName);

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Retrieves all unsynced farmer identification records
  Future<List<FarmerIdentificationData>> getUnsynced() async {
    final db = await dbHelper.database;

    final maps = await db.query(
      FarmerIdentificationTable.tableName,
      where: '${FarmerIdentificationTable.isSynced} = ?',
      whereArgs: [0], // 0 means not synced
    );

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Deletes a farmer identification record by ID
  Future<int> delete(int id) async {
    final db = await dbHelper.database;

    return await db.delete(
      FarmerIdentificationTable.tableName,
      where: '${FarmerIdentificationTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;

    return await db.update(
      FarmerIdentificationTable.tableName,
      {
        FarmerIdentificationTable.isSynced: 1,
        FarmerIdentificationTable.syncStatus: 1,
        FarmerIdentificationTable.updatedAt: DateTime.now().toIso8601String(),
      },
      where: '${FarmerIdentificationTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// Converts a database map to a FarmerIdentificationData object
  FarmerIdentificationData _fromMap(Map<String, dynamic> map) {
    return FarmerIdentificationData(
      id: map[FarmerIdentificationTable.id],
      coverPageId: map[FarmerIdentificationTable.coverPageId],
      hasGhanaCard: map[FarmerIdentificationTable.hasGhanaCard] ?? 0,
      ghanaCardNumber: map[FarmerIdentificationTable.ghanaCardNumber],
      selectedIdType: map[FarmerIdentificationTable.selectedIdType],
      idNumber: map[FarmerIdentificationTable.idNumber],
      idPictureConsent: map[FarmerIdentificationTable.idPictureConsent] ?? 0,
      noConsentReason: map[FarmerIdentificationTable.noConsentReason],
      idImagePath: map[FarmerIdentificationTable.idImagePath],
      contactNumber: map[FarmerIdentificationTable.contactNumber],
      childrenCount: map[FarmerIdentificationTable.childrenCount] ?? 0,
      createdAt: DateTime.parse(map[FarmerIdentificationTable.createdAt] as String),
      updatedAt: DateTime.parse(map[FarmerIdentificationTable.updatedAt] as String),
      isSynced: map[FarmerIdentificationTable.isSynced] ?? 0,
      syncStatus: map[FarmerIdentificationTable.syncStatus] ?? 0,
      // Note: Children would need to be loaded separately as they're in a different table
    );
  }
}
