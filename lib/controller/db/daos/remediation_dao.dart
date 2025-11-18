import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';


class RemediationDao {
  final LocalDBHelper dbHelper;

  RemediationDao({required this.dbHelper});

  /// Inserts a new remediation record
  /// Finds remediation records by cover page ID
  Future<List<RemediationModel>> findByCoverPageId(int coverPageId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'remediation',
        where: 'farm_identification_id = ?',
        whereArgs: [coverPageId],
      );
      return List.generate(maps.length, (i) => RemediationModel.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error in findByCoverPageId: $e');
      rethrow;
    }
  }

  /// Inserts a new remediation record
  Future<int> insert(RemediationModel model, [int? coverPageId]) async {
    try {
      final db = await dbHelper.database;
      
      final data = {
        if (coverPageId != null) 'farm_identification_id': coverPageId,
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

      final id = await db.insert(
        'remediation',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      return id;
    } catch (e) {
      print('❌ Error in insert: $e');
      rethrow;
    }
  }

  /// Updates an existing remediation record
  Future<int> update(RemediationModel model, int id) async {
    try {
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

      final count = await db.update(
        'remediation',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return count;
    } catch (e) {
      print('❌ Error in update: $e');
      rethrow;
    }
  }

  /// Gets a remediation record by ID
  Future<RemediationModel?> getById(int id) async {
    Database? db;
    try {
      db = await dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.transaction((txn) async {
        return await txn.query(
          'remediation',
          where: 'id = ?',
          whereArgs: [id],
        );
      });

      if (maps.isEmpty) return null;
      return _fromMap(maps.first);
    } catch (e) {
      print('❌ Error in getById: $e');
      rethrow;
    }
  }

  /// Gets a remediation record by cover page ID
  Future<RemediationModel?> getByCoverPageId(int coverPageId) async {
    Database? db;
    try {
      db = await dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.transaction((txn) async {
        return await txn.query(
          'remediation',
          where: 'farm_identification_id = ?',
          whereArgs: [coverPageId],
          orderBy: 'id DESC',
          limit: 1,
        );
      });

      if (maps.isEmpty) return null;
      return _fromMap(maps.first);
    } catch (e) {
      print('❌ Error in getByCoverPageId: $e');
      rethrow;
    }
  }

  /// Gets all remediation records
  Future<List<RemediationModel>> getAll() async {
    Database? db;
    try {
      db = await dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.transaction((txn) async {
        return await txn.query('remediation');
      });
      
      return List.generate(maps.length, (i) => _fromMap(maps[i]));
    } catch (e) {
      print('❌ Error in getAll: $e');
      rethrow;
    }
  }

  /// Deletes a remediation record by ID
  Future<int> delete(int id) async {
    Database? db;
    try {
      db = await dbHelper.database;
      
      return await db.transaction<int>((txn) async {
        try {
          final count = await txn.delete(
            'remediation',
            where: 'id = ?',
            whereArgs: [id],
          );
          return count;
        } catch (e) {
          print('❌ Error in delete transaction: $e');
          rethrow;
        }
      });
    } catch (e) {
      print('❌ Error in delete: $e');
      rethrow;
    } finally {
      // No need to close the database here as it's managed by LocalDBHelper
    }
  }

  /// Converts a database map to a RemediationModel
  RemediationModel _fromMap(Map<String, dynamic> map) {
    return RemediationModel(
      id: map['id'] as int?,
      coverPageId: map['farm_identification_id'] as int?,
      hasSchoolFees: map['has_school_fees'] == null 
          ? null 
          : map['has_school_fees'] == 1,
      childProtectionEducation: map['child_protection_education'] == 1,
      schoolKitsSupport: map['school_kits_support'] == 1,
      igaSupport: map['iga_support'] == 1,
      otherSupport: map['other_support'] == 1,
      otherSupportDetails: map['other_support_details'] as String?,
      communityAction: map['community_action'] as String?,
      otherCommunityActionDetails: map['other_community_action_details'] as String?,
    );
  }

  /// Saves a remediation record (inserts or updates)
  Future<int> save(RemediationModel model, {int? coverPageId, int? id}) async {
    if (id == null) {
      return await insert(model, coverPageId);
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
