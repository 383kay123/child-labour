import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/remediation_model.dart';

class RemediationDao {
  final LocalDBHelper dbHelper;

  RemediationDao({required this.dbHelper});

  /// Inserts a new remediation record
  Future<int> insert(RemediationModel model, int farmIdentificationId) async {
    final db = await dbHelper.database;
    
    final data = {
      'farm_identification_id': farmIdentificationId,
      'has_school_fees': model.hasSchoolFees == null ? null : (model.hasSchoolFees! ? 1 : 0),
      'child_protection_education': model.childProtectionEducation ? 1 : 0,
      'school_kits_support': model.schoolKitsSupport ? 1 : 0,
      'iga_support': model.igaSupport ? 1 : 0,
      'other_support': model.otherSupport ? 1 : 0,
      'other_support_details': model.otherSupportDetails,
      'community_action': model.communityAction,
      'other_community_action_details': model.otherCommunityActionDetails,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
      'sync_status': 0,
    };

    return await db.insert(
      'remediation',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing remediation record
  Future<int> update(RemediationModel model, int id) async {
    final db = await dbHelper.database;
    
    final data = {
      'has_school_fees': model.hasSchoolFees == null ? null : (model.hasSchoolFees! ? 1 : 0),
      'child_protection_education': model.childProtectionEducation ? 1 : 0,
      'school_kits_support': model.schoolKitsSupport ? 1 : 0,
      'iga_support': model.igaSupport ? 1 : 0,
      'other_support': model.otherSupport ? 1 : 0,
      'other_support_details': model.otherSupportDetails,
      'community_action': model.communityAction,
      'other_community_action_details': model.otherCommunityActionDetails,
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    };

    return await db.update(
      'remediation',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets a remediation record by ID
  Future<RemediationModel?> getById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'remediation',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets a remediation record by farm identification ID
  Future<RemediationModel?> getByFarmIdentificationId(int farmId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'remediation',
      where: 'farm_identification_id = ?',
      whereArgs: [farmId],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Gets all remediation records
  Future<List<RemediationModel>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('remediation');
    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Deletes a remediation record by ID
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'remediation',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Converts a database map to a RemediationModel
  RemediationModel _fromMap(Map<String, dynamic> map) {
    return RemediationModel(
      hasSchoolFees: map['has_school_fees'] == null 
          ? null 
          : map['has_school_fees'] == 1,
      childProtectionEducation: map['child_protection_education'] == 1,
      schoolKitsSupport: map['school_kits_support'] == 1,
      igaSupport: map['iga_support'] == 1,
      otherSupport: map['other_support'] == 1,
      otherSupportDetails: map['other_support_details'],
      communityAction: map['community_action'],
      otherCommunityActionDetails: map['other_community_action_details'],
    );
  }

  /// Saves a remediation record (inserts or updates)
  Future<int> save(RemediationModel model, int farmIdentificationId, {int? id}) async {
    if (id == null) {
      return await insert(model, farmIdentificationId);
    } else {
      return await update(model, id);
    }
  }

  /// Gets the count of unsynced remediation records
  Future<int> getUnsyncedCount() async {
    final db = await dbHelper.database;
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM remediation WHERE is_synced = 0',
    );
    return count.first['count'] as int;
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      'remediation',
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
