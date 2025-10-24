import 'dart:async';

import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../view/models/monitoring_model.dart';
import '../models/community-assessment-model.dart';

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
      CREATE TABLE IF NOT EXISTS ${TableNames.communityAssessmentTBL}(
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

    // COVER PAGE TABLE
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

    // FARMER IDENTIFICATION TABLE
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${TableNames.farmerIdentificationTBL} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        
        -- Visit Information
        respondentNameCorrect TEXT,
        respondentNationality TEXT,
        countryOfOrigin TEXT,
        isFarmOwner TEXT,
        farmOwnershipType TEXT,
        correctedRespondentName TEXT,
        respondentOtherNames TEXT,
        otherCountry TEXT,
        
        -- Workers in Farm
        hasRecruitedWorker TEXT,
        everRecruitedWorker TEXT,
        workerAgreementType TEXT,
        tasksClarified TEXT,
        additionalTasks TEXT,
        refusalAction TEXT,
        salaryPaymentFrequency TEXT,
        permanentLabor INTEGER,
        casualLabor INTEGER,
        otherAgreement TEXT,
        agreementResponses TEXT,
        
        -- Adults Information
        numberOfAdults INTEGER,
        householdMembers TEXT,
        
        -- Metadata
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // CONSENT TABLE
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${TableNames.consentTBL} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        
        -- Consent Information
        consentType TEXT,
        consentStatus TEXT,
        consentMethod TEXT,
        consentWitnessName TEXT,
        consentWitnessContact TEXT,
        consentNotes TEXT,
        isVerified INTEGER DEFAULT 0,
        
        -- Location and Timing
        consentDateTime TEXT,
        consentLatitude REAL,
        consentLongitude REAL,
        consentStatusMessage TEXT,
        isProcessingConsent INTEGER DEFAULT 0,
        
        -- Metadata
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
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
  // FARMER IDENTIFICATION TABLE QUERIES

  Future<int> insertFarmerIdentification(Map<String, dynamic> data) async {
    final db = await database;
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();
    data['isSynced'] = 0;
    return await db.insert(TableNames.farmerIdentificationTBL, data);
  }

  Future<List<Map<String, dynamic>>> getAllFarmerIdentifications() async {
    final db = await database;
    return await db.query(TableNames.farmerIdentificationTBL);
  }

  Future<Map<String, dynamic>?> getFarmerIdentification(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      TableNames.farmerIdentificationTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getUnsyncedFarmerIdentifications() async {
    final db = await database;
    return await db.query(
      TableNames.farmerIdentificationTBL,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
  }

  Future<int> updateFarmerIdentification(
      int id, Map<String, dynamic> data) async {
    final db = await database;
    data['updatedAt'] = DateTime.now().toIso8601String();
    return await db.update(
      TableNames.farmerIdentificationTBL,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFarmerIdentification(int id) async {
    final db = await database;
    return await db.delete(
      TableNames.farmerIdentificationTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markFarmerIdentificationAsSynced(int id) async {
    final db = await database;
    return await db.update(
      TableNames.farmerIdentificationTBL,
      {
        'isSynced': 1,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAllFarmerIdentifications() async {
    final db = await database;
    return await db.delete(TableNames.farmerIdentificationTBL);
  }

  // ========================================================================================
  // COVER PAGE TABLE QUERIES

  Future<int> insertCoverPageData(Map<String, dynamic> data) async {
    final db = await database;
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();
    data['syncStatus'] = 0; // Mark as not synced
    return await db.insert(TableNames.coverPageTBL, data);
  }

  Future<List<Map<String, dynamic>>> getAllCoverPageData() async {
    final db = await database;
    return await db.query(TableNames.coverPageTBL);
  }

  Future<Map<String, dynamic>?> getCoverPageData(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      TableNames.coverPageTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getUnsyncedCoverPageData() async {
    final db = await database;
    return await db.query(
      TableNames.coverPageTBL,
      where: 'syncStatus = ?',
      whereArgs: [0],
    );
  }

  Future<int> updateCoverPageData(int id, Map<String, dynamic> data) async {
    final db = await database;
    data['updatedAt'] = DateTime.now().toIso8601String();
    return await db.update(
      TableNames.coverPageTBL,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Updates the status of a cover page record
  /// [id] - The ID of the record to update
  /// [status] - The new status (0 for pending, 1 for submitted)
  /// [updatedAt] - The timestamp of the update (defaults to current time if null)
  Future<int> updateCoverPageStatus({
    required int id,
    required int status,
    String? updatedAt,
  }) async {
    final db = await database;
    return await db.update(
      TableNames.coverPageTBL,
      {
        'status': status,
        'updatedAt': updatedAt ?? DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
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

  Future<int> markCoverPageAsSynced(int id) async {
    final db = await database;
    return await db.update(
      TableNames.coverPageTBL,
      {
        'syncStatus': 1,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAllCoverPageData() async {
    final db = await database;
    return await db.delete(TableNames.coverPageTBL);
  }

  // Get the latest cover page data
  Future<Map<String, dynamic>?> getLatestCoverPageData() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      TableNames.coverPageTBL,
      orderBy: 'id DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Clears all survey data from the database
  /// This should be called when navigating back to the StartSurvey screen
  Future<void> clearAllSurveyData() async {
    final db = await database;
    await db.delete(TableNames.coverPageTBL);
    await db.delete(TableNames.farmerIdentificationTBL);
    await db.delete(TableNames.consentTBL);
    // Add any other survey-related tables that need to be cleared
  }

  // ========================================================================================
  // CONSENT TABLE QUERIES

  Future<int> insertConsentData(Map<String, dynamic> data) async {
    final db = await database;
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();
    data['isSynced'] = 0;
    return await db.insert(TableNames.consentTBL, data);
  }

  Future<List<Map<String, dynamic>>> getAllConsentData() async {
    final db = await database;
    return await db.query(TableNames.consentTBL);
  }

  Future<Map<String, dynamic>?> getConsentData(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      TableNames.consentTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getUnsyncedConsentData() async {
    final db = await database;
    return await db.query(
      TableNames.consentTBL,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
  }

  Future<int> updateConsentData(int id, Map<String, dynamic> data) async {
    final db = await database;
    data['updatedAt'] = DateTime.now().toIso8601String();
    return await db.update(
      TableNames.consentTBL,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteConsentData(int id) async {
    final db = await database;
    return await db.delete(
      TableNames.consentTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markConsentAsSynced(int id) async {
    final db = await database;
    return await db.update(
      TableNames.consentTBL,
      {
        'isSynced': 1,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAllConsentData() async {
    final db = await database;
    return await db.delete(TableNames.consentTBL);
  }

  // Get the latest consent data
  Future<Map<String, dynamic>?> getLatestConsentData() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      TableNames.consentTBL,
      orderBy: 'id DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
}
