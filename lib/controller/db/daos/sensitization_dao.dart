import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/sensitization_model.dart';

class SensitizationDao {
  final LocalDBHelper dbHelper;

  SensitizationDao({required this.dbHelper});

  /// Inserts a new sensitization record
  Future<int> insert(SensitizationData model, int farmIdentificationId) async {
    final db = await dbHelper.database;
    
    final data = {
      'farm_identification_id': farmIdentificationId,
      'is_acknowledged': model.isAcknowledged ? 1 : 0,
      'acknowledged_at': model.acknowledgedAt?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
      'sync_status': 0,
    };

    return await db.insert(
      'sensitization',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing sensitization record
  Future<int> update(SensitizationData model, int id) async {
    final db = await dbHelper.database;
    
    final data = {
      'is_acknowledged': model.isAcknowledged ? 1 : 0,
      'acknowledged_at': model.acknowledgedAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    return await db.update(
      'sensitization',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets a sensitization record by ID
  Future<SensitizationData?> getById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sensitization',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets a sensitization record by farm identification ID
  Future<SensitizationData?> getByFarmIdentificationId(int farmId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sensitization',
      where: 'farm_identification_id = ?',
      whereArgs: [farmId],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets all sensitization records
  Future<List<SensitizationData>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('sensitization');
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Deletes a sensitization record by ID
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'sensitization',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Converts a database map to a SensitizationData
  SensitizationData _fromMap(Map<String, dynamic> map) {
    return SensitizationData(
      isAcknowledged: map['is_acknowledged'] == 1,
      acknowledgedAt: map['acknowledged_at'] != null 
          ? DateTime.parse(map['acknowledged_at']) 
          : null,
    );
  }

  /// Saves a sensitization record (inserts or updates)
  Future<int> save(SensitizationData model, int farmIdentificationId, {int? id}) async {
    if (id == null) {
      return await insert(model, farmIdentificationId);
    } else {
      return await update(model, id);
    }
  }

  /// Acknowledges the sensitization for a farm
  Future<int> acknowledge(int farmIdentificationId) async {
    final db = await dbHelper.database;
    
    final data = {
      'farm_identification_id': farmIdentificationId,
      'is_acknowledged': 1,
      'acknowledged_at': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
      'sync_status': 0,
    };

    return await db.insert(
      'sensitization',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Checks if sensitization is acknowledged for a farm
  Future<bool> isAcknowledged(int farmIdentificationId) async {
    final db = await dbHelper.database;
    final count = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sensitization 
      WHERE farm_identification_id = ? AND is_acknowledged = 1
    ''', [farmIdentificationId]);
    
    return (count.first['count'] as int) > 0;
  }

  /// Gets the count of unsynced sensitization records
  Future<int> getUnsyncedCount() async {
    final db = await dbHelper.database;
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sensitization WHERE is_synced = 0',
    );
    return count.first['count'] as int;
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      'sensitization',
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
