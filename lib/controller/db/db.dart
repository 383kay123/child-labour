import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/community-assessment-model.dart';
import 'table_names.dart';
import '../../view/models/monitoring_model.dart';

// Import all table classes
import 'db_tables/consent_table.dart';
import 'db_tables/farmer_identification_table.dart';
import 'db_tables/combined_farmer_identification_table.dart';
import 'db_tables/children_household_table.dart';
import 'db_tables/remediation_table.dart';
import 'db_tables/sensitization_table.dart';
import 'db_tables/sensitization_questions_table.dart';
import 'db_tables/end_of_collection_table.dart';
import 'db_tables/monitoring_table.dart';

class LocalDBHelper {
  static final LocalDBHelper instance = LocalDBHelper._init();
  static Database? _database;

  LocalDBHelper._init();

  // Create community assessment table
  Future<void> _createCommunityAssessmentTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${TableNames.communityAssessmentTBL}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        communityName TEXT,
        communityScore INTEGER,
        q1 TEXT, q2 TEXT, q3 TEXT, q4 TEXT, q5 TEXT,
        q6 TEXT, q7a INTEGER, q7b TEXT, q7c TEXT, q8 TEXT, q9 TEXT, q10 TEXT, 
        status INTEGER
      )
    ''');
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Incremented to update schema and add missing columns
      onCreate: _createAllTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createAllTables(Database db, int version) async {
    // Create community assessment table
    await _createCommunityAssessmentTable(db);

    // Create monitoring table and indexes
    await MonitoringTable.createTable(db);
    await MonitoringTable.createIndexes(db);

    // Create other tables
    await ConsentTable.createTable(db);
    await FarmerIdentificationTable.createTable(db);
    await CombinedFarmerIdentificationTable.createTable(db);
    await ChildrenHouseholdTable.createTable(db);
    await RemediationTable.createTable(db);
    await SensitizationTable.createTable(db);
    await SensitizationQuestionsTable.createTable(db);
    await EndOfCollectionTable.createTable(db);

    // Create any necessary triggers or indexes
    await _createDatabaseTriggers(db);
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    // Let MonitoringTable handle its own upgrades
    await MonitoringTable.onUpgrade(db, oldVersion, newVersion);

    // Add future version migrations here
    // Example for version 4:
    // if (oldVersion < 4) {
    //   // Migration code for version 4
    // }
  }

  Future<void> _createDatabaseTriggers(Database db) async {
    // Create any necessary triggers for your tables
    // Example:
    // await CoverPageTable.createTriggers(db);
    // await ConsentTable.createTriggers(db);
    // ... and so on for other tables with triggers
  }

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('child_labour.db');
    return _database!;
  }

  // Community Assessment CRUD operations
  Future<int> insertCommunityAssessment(CommunityAssessmentModel model) async {
    final db = await database;
    return await db.insert(TableNames.communityAssessmentTBL, model.toMap());
  }

  Future<int> updateCommunityAssessment(CommunityAssessmentModel model) async {
    final db = await database;
    return await db.update(
      TableNames.communityAssessmentTBL,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<List<CommunityAssessmentModel>> getCommunityAssessment() async {
    final db = await database;
    final result = await db.query(TableNames.communityAssessmentTBL);
    return result
        .map((json) => CommunityAssessmentModel.fromMap(json))
        .toList();
  }

  Future<List<CommunityAssessmentModel>> getCommunityAssessmentByStatus(
      {int status = 0}) async {
    final db = await database;
    final result = await db.query(
      TableNames.communityAssessmentTBL,
      where: 'status = ?',
      whereArgs: [status],
    );
    return result
        .map((json) => CommunityAssessmentModel.fromMap(json))
        .toList();
  }

  Future<int> deleteAllCommunityAssessment() async {
    final db = await database;
    return await db.delete(TableNames.communityAssessmentTBL);
  }

  // Monitoring CRUD operations
  Future<int> insertIntoMonitoringTable(MonitoringModel form) async {
    final db = await database;
    return await db.insert(TableNames.monitoringTBL, form.toMap());
  }

  Future<List<MonitoringModel>> getAllFromMonitoringTable() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(TableNames.monitoringTBL);
    return List.generate(maps.length, (i) {
      return MonitoringModel.fromMap(maps[i]);
    });
  }

  Future<MonitoringModel?> getFromMonitoringTable(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.monitoringTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return MonitoringModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MonitoringModel>> getMonitoringTableByStatus(int status) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.monitoringTBL,
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'date_created DESC',
      );
      return List.generate(maps.length, (i) {
        return MonitoringModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting monitoring records by status $status: $e');
      return [];
    }
  }

  /// Gets all pending monitoring assessments (status = 0)
  Future<List<MonitoringModel>> getPendingMonitoringAssessments() async {
    return await getMonitoringTableByStatus(0);
  }

  /// Gets all submitted monitoring assessments (status = 1)
  Future<List<MonitoringModel>> getSubmittedMonitoringAssessments() async {
    return await getMonitoringTableByStatus(1);
  }

  Future<int> updateMonitoringTable(MonitoringModel form) async {
    final db = await database;
    return await db.update(
      TableNames.monitoringTBL,
      form.toMap(),
      where: 'id = ?',
      whereArgs: [form.id],
    );
  }

  Future<int> deleteFromMonitoringTable(int id) async {
    final db = await database;
    return await db.delete(
      TableNames.monitoringTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllFromMonitoringTable() async {
    final db = await database;
    await db.delete(TableNames.monitoringTBL);
  }

  /// Clears all survey data from the database
  /// This should be called when navigating back to the StartSurvey screen
  Future<void> clearAllSurveyData() async {
    final db = await database;
    await db.delete(TableNames.communityAssessmentTBL);
    await db.delete(TableNames.monitoringTBL);
  }

  // Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

//   // ===================================================================
//   // COVER PAGE TABLE METHODS

//   Future<int> insertCoverPageData(Map<String, dynamic> data) async {
//     final db = await database;
//     final now = DateTime.now().toIso8601String();
//     final insertData = {
//       'selected_town': data['selected_town'],
//       'selected_town_name': data['selected_town_name'],
//       'selected_farmer': data['selected_farmer'],
//       'selected_farmer_name': data['selected_farmer_name'],
//       'status': data['status'] ?? 0,
//       'sync_status': 0,
//       'created_at': now,
//       'updated_at': now,
//       'is_synced': 0,
//     };
//     return await db.insert(TableNames.coverPageTBL, insertData);
//   }

//   Future<Map<String, dynamic>?> getLatestCoverPageData() async {
//     final db = await database;
//     final List<Map<String, dynamic>> results = await db.query(
//       TableNames.coverPageTBL,
//       orderBy: 'id DESC',
//       limit: 1,
//     );
//     return results.isNotEmpty ? results.first : null;
//   }

//   Future<List<Map<String, dynamic>>> getAllCoverPageData() async {
//     final db = await database;
//     return await db.query(TableNames.coverPageTBL);
//   }

//   Future<int> updateCoverPageData(int id, Map<String, dynamic> data) async {
//     final db = await database;
//     data['updated_at'] = DateTime.now().toIso8601String();
//     return await db.update(
//       TableNames.coverPageTBL,
//       data,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<int> updateCoverPageStatus({
//     required int id,
//     required int status,
//   }) async {
//     final db = await database;
//     return await db.update(
//       TableNames.coverPageTBL,
//       {
//         'status': status,
//         'updated_at': DateTime.now().toIso8601String(),
//       },
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<int> deleteCoverPageData(int id) async {
//     final db = await database;
//     return await db.delete(
//       TableNames.coverPageTBL,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<int> clearAllCoverPageData() async {
//     final db = await database;
//     return await db.delete(TableNames.coverPageTBL);
//   }

//   // ===================================================================
//   // CONSENT TABLE METHODS

//   Future<int> insertConsentData(Map<String, dynamic> data) async {
//     final db = await database;
//     final now = DateTime.now().toIso8601String();
//     final insertData = {
//       ...data,
//       'created_at': now,
//       'updated_at': now,
//       'is_synced': 0,
//     };
//     return await db.insert(TableNames.consentTBL, insertData);
//   }

//   Future<int> updateConsentData(int id, Map<String, dynamic> data) async {
//     final db = await database;
//     data['updated_at'] = DateTime.now().toIso8601String();
//     return await db.update(
//       TableNames.consentTBL,
//       data,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<Map<String, dynamic>?> getLatestConsentData() async {
//     final db = await database;
//     final List<Map<String, dynamic>> results = await db.query(
//       TableNames.consentTBL,
//       orderBy: 'id DESC',
//       limit: 1,
//     );
//     return results.isNotEmpty ? results.first : null;
//   }
// }
}
