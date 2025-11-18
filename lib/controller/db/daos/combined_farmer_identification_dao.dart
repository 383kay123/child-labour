import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/adult_info_model.dart';

import 'package:human_rights_monitor/controller/models/combinefarmer.dart/identification_of_owner_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/visit_information_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/workers_in_farm_model.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/db/household_tables.dart' as table;

class CombinedFarmerIdentificationDao {
  final LocalDBHelper dbHelper;

  CombinedFarmerIdentificationDao({required this.dbHelper});

  /// Inserts a new combined farmer identification record
  Future<int> insert(CombinedFarmerIdentificationModel model) async {
    final db = await dbHelper.database;

    // Convert nested objects to JSON strings
    final visitInfoJson = model.visitInformation != null
        ? jsonEncode(model.visitInformation!.toMap())
        : null;
    final ownerInfoJson = model.ownerInformation != null
        ? jsonEncode(model.ownerInformation!.toMap())
        : null;
    final workersInFarmJson = model.workersInFarm != null
        ? jsonEncode(model.workersInFarm!.toMap())
        : null;
    final adultsInfoJson = model.adultsInformation != null
        ? jsonEncode(model.adultsInformation!.toMap())
        : null;

    final data = {
      table.CombinedFarmerIdentificationTable.coverPageId: model.coverPageId,
      'visit_information': visitInfoJson,
      'owner_information': ownerInfoJson,
      'workers_in_farm': workersInFarmJson,
      'adults_information': adultsInfoJson,
      table.CombinedFarmerIdentificationTable.createdAt:
          DateTime.now().toIso8601String(),
      table.CombinedFarmerIdentificationTable.updatedAt:
          DateTime.now().toIso8601String(),
      table.CombinedFarmerIdentificationTable.isSynced:
          0, // Not synced by default
      table.CombinedFarmerIdentificationTable.syncStatus: 0, // Not synced yet
    };

    final id = await db.insert(
      table.CombinedFarmerIdentificationTable.tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  /// Updates an existing combined farmer identification record
  Future<int> update(CombinedFarmerIdentificationModel model) async {
    if (model.id == null) {
      throw Exception(
          'Cannot update a combined farmer identification record without an ID');
    }

    final db = await dbHelper.database;

    // Convert nested objects to JSON strings
    final visitInfoJson = model.visitInformation != null
        ? jsonEncode(model.visitInformation!.toMap())
        : null;
    final ownerInfoJson = model.ownerInformation != null
        ? jsonEncode(model.ownerInformation!.toMap())
        : null;
    final workersInFarmJson = model.workersInFarm != null
        ? jsonEncode(model.workersInFarm!.toMap())
        : null;
    final adultsInfoJson = model.adultsInformation != null
        ? jsonEncode(model.adultsInformation!.toMap())
        : null;

    final data = {
      table.CombinedFarmerIdentificationTable.coverPageId: model.coverPageId,
      'visit_information': visitInfoJson,
      'owner_information': ownerInfoJson,
      'workers_in_farm': workersInFarmJson,
      'adults_information': adultsInfoJson,
      table.CombinedFarmerIdentificationTable.updatedAt:
          DateTime.now().toIso8601String(),
      table.CombinedFarmerIdentificationTable.isSynced: model.isSynced ? 1 : 0,
      table.CombinedFarmerIdentificationTable.syncStatus: model.syncStatus ?? 0,
    };

    return await db.update(
      table.CombinedFarmerIdentificationTable.tableName,
      data,
      where: '${table.CombinedFarmerIdentificationTable.id} = ?',
      whereArgs: [model.id],
    );
  }

  /// Retrieves a combined farmer identification record by ID
  Future<CombinedFarmerIdentificationModel?> getById(int id) async {
    final db = await dbHelper.database;

    final maps = await db.query(
      table.CombinedFarmerIdentificationTable.tableName,
      where: '${table.CombinedFarmerIdentificationTable.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves a combined farmer identification record by cover page ID
  Future<CombinedFarmerIdentificationModel?> getByCoverPageId(
      int coverPageId) async {
    final db = await dbHelper.database;

    final maps = await db.query(
      table.CombinedFarmerIdentificationTable.tableName,
      where: '${table.CombinedFarmerIdentificationTable.coverPageId} = ?',
      whereArgs: [coverPageId],
    );

    if (maps.isNotEmpty) {
      return _fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all unsynced combined farmer identification records
  Future<List<CombinedFarmerIdentificationModel>> getUnsynced() async {
    final db = await dbHelper.database;

    final maps = await db.query(
      table.CombinedFarmerIdentificationTable.tableName,
      where: '${table.CombinedFarmerIdentificationTable.isSynced} = ?',
      whereArgs: [0], // 0 means not synced
    );

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;

    return await db.update(
      table.CombinedFarmerIdentificationTable.tableName,
      {
        table.CombinedFarmerIdentificationTable.isSynced: 1,
        table.CombinedFarmerIdentificationTable.syncStatus:
            1, // Successfully synced
        table.CombinedFarmerIdentificationTable.updatedAt:
            DateTime.now().toIso8601String(),
      },
      where: '${table.CombinedFarmerIdentificationTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a combined farmer identification record
  Future<int> delete(int id) async {
    final db = await dbHelper.database;

    return await db.delete(
      table.CombinedFarmerIdentificationTable.tableName,
      where: '${table.CombinedFarmerIdentificationTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// Converts a database map to a FarmerIdentificationModel
  CombinedFarmerIdentificationModel _fromMap(Map<String, dynamic> map) {
    // Parse JSON strings back to objects
    VisitInformationData? visitInfo;
    if (map['visit_information'] != null) {
      try {
        visitInfo = VisitInformationData.fromMap(
            Map<String, dynamic>.from(jsonDecode(map['visit_information'])));
      } catch (e) {
        debugPrint('Error parsing visit_information: $e');
      }
    }

    IdentificationOfOwnerData? ownerInfo;
    if (map['owner_information'] != null) {
      try {
        ownerInfo = IdentificationOfOwnerData.fromMap(
            Map<String, dynamic>.from(jsonDecode(map['owner_information'])));
      } catch (e) {
        debugPrint('Error parsing owner_information: $e');
      }
    }

    WorkersInFarmData? workersInFarm;
    if (map['workers_in_farm'] != null) {
      try {
        workersInFarm = WorkersInFarmData.fromMap(
            Map<String, dynamic>.from(jsonDecode(map['workers_in_farm'])));
      } catch (e) {
        debugPrint('Error parsing workers_in_farm: $e');
      }
    }

    AdultsInformationData? adultsInfo;
    if (map['adults_information'] != null) {
      try {
        adultsInfo = AdultsInformationData.fromMap(
            Map<String, dynamic>.from(jsonDecode(map['adults_information'])));
      } catch (e) {
        debugPrint('Error parsing adults_information: $e');
      }
    }

    return CombinedFarmerIdentificationModel(
      id: map[table.CombinedFarmerIdentificationTable.id],
      coverPageId: map[table.CombinedFarmerIdentificationTable.coverPageId],
      visitInformation: visitInfo,
      ownerInformation: ownerInfo,
      workersInFarm: workersInFarm,
      adultsInformation: adultsInfo,
      createdAt: map[table.CombinedFarmerIdentificationTable.createdAt] != null
          ? DateTime.parse(
              map[table.CombinedFarmerIdentificationTable.createdAt])
          : null,
      updatedAt: map[table.CombinedFarmerIdentificationTable.updatedAt] != null
          ? DateTime.parse(
              map[table.CombinedFarmerIdentificationTable.updatedAt])
          : null,
      isSynced: map[table.CombinedFarmerIdentificationTable.isSynced] == 1,
      syncStatus: map[table.CombinedFarmerIdentificationTable.syncStatus],
    );
  }
}
