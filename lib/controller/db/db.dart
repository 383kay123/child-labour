import 'dart:async';

import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../view/models/monitoring_model.dart';
import '../models/community-assessment-model.dart';
import '../models/cover_model.dart';

class LocalDBHelper {
  static final LocalDBHelper instance = LocalDBHelper._init();
  static Database? _database;

  LocalDBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('community_assessment.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${TableNames.communityAssessmentTBL}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        communityName TEXT,
        communityScore INTEGER,
        q1 TEXT, q2 TEXT, q3 TEXT, q4 TEXT, q5 TEXT,
        q6 TEXT, q7a INTEGER, q7b TEXT, q7c TEXT, q8 TEXT, q9 TEXT, q10 TEXT, status INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE ${TableNames.consentTBL}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        interviewStartTime TEXT,
        timeStatus TEXT,
        latitude REAL,
        longitude REAL,
        locationStatus TEXT,
        isGettingLocation INTEGER,
        communityType TEXT,
        residesInCommunityConsent TEXT,
        farmerAvailable TEXT,
        farmerStatus TEXT,
        availablePerson TEXT,
        otherSpecification TEXT,
        otherCommunityName TEXT,
        consentGiven INTEGER,
        refusalReason TEXT,
        consentTimestamp TEXT,
        syncStatus INTEGER DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${TableNames.monitoringTBL}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        childId TEXT,
        childName TEXT,
        age TEXT,
        sex TEXT,
        community TEXT,
        farmerId TEXT,
        firstRemediationDate TEXT,
        remediationFormProvided TEXT,
        followUpVisitsCount TEXT,
        isEnrolledInSchool INTEGER,
        attendanceImproved INTEGER,
        receivedSchoolMaterials INTEGER,
        canReadWriteBasicText INTEGER,
        advancedToNextGrade INTEGER,
        classAtRemediation TEXT,
        academicYearEnded INTEGER,
        promoted INTEGER,
        promotedGrade TEXT,
        improvementInSkills INTEGER,
        recommendations TEXT,
        engagedInHazardousWork INTEGER,
        reducedWorkHours INTEGER,
        involvedInLightWork INTEGER,
        outOfHazardousWork INTEGER,
        hasBirthCertificate INTEGER,
        birthCertificateProcess INTEGER,
        noBirthCertificateReason TEXT,
        receivedAwarenessSessions INTEGER,
        improvedUnderstanding INTEGER,
        caregiversSupportSchool INTEGER,
        receivedFinancialSupport INTEGER,
        referralsMade INTEGER,
        ongoingFollowUpPlanned INTEGER,
        consideredRemediated INTEGER,
        additionalComments TEXT,
        followUpVisitsCountSinceIdentification TEXT,
        visitsSpacedCorrectly INTEGER,
        confirmedNotInChildLabour INTEGER,
        followUpCycleComplete INTEGER,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // COVER PAGE TABLE - FIXED: This was outside the method
    await db.execute('''
      CREATE TABLE ${TableNames.coverPageTBL}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        selectedTown TEXT,
        selectedTownName TEXT,
        selectedFarmer TEXT,
        selectedFarmerName TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        status INTEGER DEFAULT 0,
        syncStatus INTEGER DEFAULT 0
      )
    ''');
  } // Added missing closing brace for _createDB method

  Future<int> insertCommunityAssessment(CommunityAssessmentModel model) async {
    final db = await instance.database;
    return await db.insert(TableNames.communityAssessmentTBL, model.toMap());
  }

  Future<int> updateCommunityAssessment(CommunityAssessmentModel model) async {
    final db = await instance.database;
    return await db.update(TableNames.communityAssessmentTBL, model.toMap(),
        where: 'id = ?', whereArgs: [model.id]);
  }

  Future<List<CommunityAssessmentModel>> getCommunityAssessment() async {
    final db = await instance.database;
    final result = await db.query(TableNames.communityAssessmentTBL);
    return result
        .map((json) =>
            CommunityAssessmentModel.fromMap(Map<String, String>.from(json)))
        .toList();
  }

  // get response by status
  Future<List<CommunityAssessmentModel>> getCommunityAssessmentByStatus(
      {int status = 0}) async {
    final db = await database;
    final result = await db.query(TableNames.communityAssessmentTBL,
        where: 'status = ?', whereArgs: [status]);
    return result
        .map((json) =>
            CommunityAssessmentModel.fromMap(Map<String, String>.from(json)))
        .toList();
  }

  Future<int> deleteAllCommunityAssessment() async {
    final db = await instance.database;
    return await db.delete(TableNames.communityAssessmentTBL);
  }

  // ========================================================================================
  // MONITORING TABLE QUERIES

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

  // get by status
  Future<List<MonitoringModel>> getMonitoringTableByStatus(int status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.monitoringTBL,
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) {
      return MonitoringModel.fromMap(maps[i]);
    });
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

  // ========================================================================================
  // COVER PAGE TABLE QUERIES - FIXED: These were outside the class

  Future<int> insertCoverPageData(CoverPageModel coverData) async {
    final db = await database;
    coverData.createdAt = DateTime.now().toString();
    coverData.updatedAt = DateTime.now().toString();

    return await db.insert(TableNames.coverPageTBL, coverData.toMap());
  }

  Future<List<CoverPageModel>> getAllCoverPageData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(TableNames.coverPageTBL);
    return List.generate(maps.length, (i) {
      return CoverPageModel.fromMap(maps[i]);
    });
  }

  Future<CoverPageModel?> getCoverPageData(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.coverPageTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return CoverPageModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<CoverPageModel>> getCoverPageDataByStatus(int status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.coverPageTBL,
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) {
      return CoverPageModel.fromMap(maps[i]);
    });
  }

  Future<int> updateCoverPageData(CoverPageModel coverData) async {
    final db = await database;
    coverData.updatedAt = DateTime.now().toString();

    return await db.update(
      TableNames.coverPageTBL,
      coverData.toMap(),
      where: 'id = ?',
      whereArgs: [coverData.id],
    );
  }

  Future<int> deleteCoverPageData(int id) async {
    final db = await database;
    return await db.delete(
      TableNames.coverPageTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get the latest cover page data
  Future<CoverPageModel?> getLatestCoverPageData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.coverPageTBL,
      orderBy: 'id DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return CoverPageModel.fromMap(maps.first);
    }
    return null;
  }

  // Check if cover page data exists for a specific town and farmer
  Future<bool> coverPageDataExists(String townCode, String farmerCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.coverPageTBL,
      where: 'selectedTown = ? AND selectedFarmer = ?',
      whereArgs: [townCode, farmerCode],
    );
    return maps.isNotEmpty;
  }
// ========================================================================================
}

//
// // ========================================================================================
// // CONSENT TABLE QUERIES
//
// Future<int> insertConsentData(ConsentModel consentData) async {
//   final db = await database;
//
//   // Ensure timestamps are set
//   final modelWithTimestamps = consentData.copyWith(
//     createdAt: consentData.createdAt ?? DateTime.now(),
//     updatedAt: DateTime.now(),
//   );
//
//   return await db.insert(TableNames.consentTBL, modelWithTimestamps.toMap());
// }
//
// Future<List<ConsentModel>> getAllConsentData() async {
//   final db = await database;
//   final List<Map<String, dynamic>> maps = await db.query(TableNames.consentTBL);
//   return List.generate(maps.length, (i) {
//     return ConsentModel.fromMap(maps[i]);
//   });
// }
//
// Future<ConsentModel?> getConsentData(int id) async {
//   final db = await database;
//   final List<Map<String, dynamic>> maps = await db.query(
//     TableNames.consentTBL,
//     where: 'id = ?',
//     whereArgs: [id],
//   );
//   if (maps.isNotEmpty) {
//     return ConsentModel.fromMap(maps.first);
//   }
//   return null;
// }
//
// Future<List<ConsentModel>> getConsentDataBySyncStatus(int syncStatus) async {
//   final db = await database;
//   final List<Map<String, dynamic>> maps = await db.query(
//     TableNames.consentTBL,
//     where: 'syncStatus = ?',
//     whereArgs: [syncStatus],
//   );
//   return List.generate(maps.length, (i) {
//     return ConsentModel.fromMap(maps[i]);
//   });
// }
//
// Future<int> updateConsentData(ConsentModel consentData) async {
//   final db = await database;
//
//   final modelWithUpdateTime = consentData.copyWith(
//     updatedAt: DateTime.now(),
//   );
//
//   return await db.update(
//     TableNames.consentTBL,
//     modelWithUpdateTime.toMap(),
//     where: 'id = ?',
//     whereArgs: [consentData.id],
//   );
// }
//
// Future<int> deleteConsentData(int id) async {
//   final db = await database;
//   return await db.delete(
//     TableNames.consentTBL,
//     where: 'id = ?',
//     whereArgs: [id],
//   );
// }
//
// Future<void> clearAllConsentData() async {
//   final db = await database;
//   await db.delete(TableNames.consentTBL);
// }
//
// // Get the latest consent data
// Future<ConsentModel?> getLatestConsentData() async {
//   final db = await database;
//   final List<Map<String, dynamic>> maps = await db.query(
//     TableNames.consentTBL,
//     orderBy: 'id DESC',
//     limit: 1,
//   );
//   if (maps.isNotEmpty) {
//     return ConsentModel.fromMap(maps.first);
//   }
//   return null;
// }
//
// // Mark consent as synced
// Future<int> markConsentAsSynced(int id) async {
//   final db = await database;
//   return await db.update(
//     TableNames.consentTBL,
//     {
//       'syncStatus': 1,
//       'updatedAt': DateTime.now().toIso8601String(),
//     },
//     where: 'id = ?',
//     whereArgs: [id],
//   );
// }
//
// // Get unsynced consent data
// Future<List<ConsentModel>> getUnsyncedConsentData() async {
//   return await getConsentDataBySyncStatus(0);
// }
