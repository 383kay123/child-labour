import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/end_of_collection_model.dart';

class EndOfCollectionDao {
  final LocalDBHelper dbHelper;

  EndOfCollectionDao({required this.dbHelper});

  /// Inserts a new end of collection record
  Future<int> insert(EndOfCollectionModel model, int farmIdentificationId) async {
    final db = await dbHelper.database;
    
    final data = {
      'farm_identification_id': farmIdentificationId,
      'respondent_image_path': model.respondentImagePath,
      'producer_signature_path': model.producerSignaturePath,
      'latitude': model.latitude,
      'longitude': model.longitude,
      'gps_coordinates': model.gpsCoordinates,
      'end_time': model.endTime?.toIso8601String(),
      'remarks': model.remarks,
      'created_at': model.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': model.isSynced ? 1 : 0,
      'sync_status': 0,
    };

    return await db.insert(
      'end_of_collection',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing end of collection record
  Future<int> update(EndOfCollectionModel model, int id) async {
    final db = await dbHelper.database;
    
    final data = {
      'respondent_image_path': model.respondentImagePath,
      'producer_signature_path': model.producerSignaturePath,
      'latitude': model.latitude,
      'longitude': model.longitude,
      'gps_coordinates': model.gpsCoordinates,
      'end_time': model.endTime?.toIso8601String(),
      'remarks': model.remarks,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': model.isSynced ? 1 : 0,
    };

    return await db.update(
      'end_of_collection',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets an end of collection record by ID
  Future<EndOfCollectionModel?> getById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'end_of_collection',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets an end of collection record by farm identification ID
  Future<EndOfCollectionModel?> getByFarmIdentificationId(int farmId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'end_of_collection',
      where: 'farm_identification_id = ?',
      whereArgs: [farmId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets all end of collection records
  Future<List<EndOfCollectionModel>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('end_of_collection');
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Gets all unsynced end of collection records
  Future<List<EndOfCollectionModel>> getUnsynced() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'end_of_collection',
      where: 'is_synced = 0',
    );
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Deletes an end of collection record by ID
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'end_of_collection',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Converts a database map to an EndOfCollectionModel
  EndOfCollectionModel _fromMap(Map<String, dynamic> map) {
    return EndOfCollectionModel(
      id: map['id'],
      respondentImagePath: map['respondent_image_path'],
      producerSignaturePath: map['producer_signature_path'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      gpsCoordinates: map['gps_coordinates'],
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      remarks: map['remarks'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isSynced: map['is_synced'] == 1,
    );
  }

  /// Saves an end of collection record (inserts or updates)
  Future<int> save(EndOfCollectionModel model, int farmIdentificationId, {int? id}) async {
    if (id == null) {
      return await insert(model, farmIdentificationId);
    } else {
      return await update(model, id);
    }
  }

  /// Gets the count of unsynced end of collection records
  Future<int> getUnsyncedCount() async {
    final db = await dbHelper.database;
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM end_of_collection WHERE is_synced = 0',
    );
    return count.first['count'] as int;
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      'end_of_collection',
      {
        'is_synced': 1,
        'sync_status': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Checks if a farm has any end of collection records
  Future<bool> hasEndOfCollectionRecord(int farmId) async {
    final db = await dbHelper.database;
    final count = await db.rawQuery('''
      SELECT COUNT(*) as count FROM end_of_collection 
      WHERE farm_identification_id = ?
    ''', [farmId]);
    
    return (count.first['count'] as int) > 0;
  }
}
