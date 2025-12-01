import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:sqflite/sqflite.dart';


class RemediationDao {
  final HouseholdDBHelper dbHelper;

  RemediationDao({required this.dbHelper});

  /// Inserts a new remediation record
  Future<int> insert(RemediationModel model, int coverPageId,) async {
    try {
      final db = await dbHelper.database;
      
      final data = {
        'cover_page_id': coverPageId,
        // 'farm_identification_id': farmerId,
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
        TableNames.remediationTBL,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      return id;
    } catch (e) {
      print('❌ Error in insert: $e');
      rethrow;
    }
  }

  /// Gets a remediation record by cover page ID
  Future<RemediationModel?> findByCoverPageId(int coverPageId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.remediationTBL,
        where: 'cover_page_id = ?',
        whereArgs: [coverPageId],
      );

      if (maps.isNotEmpty) {
        return RemediationModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('❌ Error in findByCoverPageId: $e');
      rethrow;
    }
  }

  /// Gets a remediation record by ID
  Future<RemediationModel?> getById(int id) async {
    try {
      final db = await dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.remediationTBL,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return _fromMap(maps.first);
    } catch (e) {
      print('❌ Error in getById: $e');
      rethrow;
    }
  }

  /// Gets a remediation record by cover page ID
  Future<RemediationModel?> getByCoverPageId(int coverPageId) async {
    try {
      final db = await dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.remediationTBL,
        where: 'cover_page_id = ?',
        whereArgs: [coverPageId],
        orderBy: 'id DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _fromMap(maps.first);
    } catch (e) {
      print('❌ Error in getByCoverPageId: $e');
      rethrow;
    }
  }

  /// Gets a remediation record by farmer identification ID
  Future<RemediationModel?> getByFarmerId(int farmerId) async {
    try {
      final db = await dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.remediationTBL,
        where: 'farm_identification_id = ?',
        whereArgs: [farmerId],
        orderBy: 'id DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _fromMap(maps.first);
    } catch (e) {
      print('❌ Error in getByFarmerId: $e');
      rethrow;
    }
  }

  /// Gets a remediation record by both cover page ID AND farmer ID
  Future<RemediationModel?> getByCoverPageAndFarmerId(int coverPageId, int farmerId) async {
    try {
      final db = await dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.remediationTBL,
        where: 'cover_page_id = ? AND farm_identification_id = ?',
        whereArgs: [coverPageId, farmerId],
        orderBy: 'id DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _fromMap(maps.first);
    } catch (e) {
      print('❌ Error in getByCoverPageAndFarmerId: $e');
      rethrow;
    }
  }

  /// Gets all remediation records
  Future<List<RemediationModel>> getAll() async {
    try {
      final db = await dbHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.remediationTBL,
        orderBy: 'id DESC',
      );

      return List.generate(maps.length, (i) => _fromMap(maps[i]));
    } catch (e) {
      print('❌ Error in getAll: $e');
      rethrow;
    }
  }

  /// Updates a remediation record
  Future<int> update(RemediationModel model) async {
    try {
      final db = await dbHelper.database;
      
      return await db.update(
        TableNames.remediationTBL,
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      print('❌ Error in update: $e');
      rethrow;
    }
  }

  /// Deletes a remediation record by ID
  Future<int> delete(int id) async {
    try {
      final db = await dbHelper.database;
      
      return await db.delete(
        TableNames.remediationTBL,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('❌ Error in delete: $e');
      rethrow;
    }
  }

  /// Converts a Map to a RemediationModel
  RemediationModel _fromMap(Map<String, dynamic> map) {
    return RemediationModel(
      id: map['id'] as int?,
      coverPageId: map['cover_page_id'] as int?,
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
}