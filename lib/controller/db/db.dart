import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:surveyflow/controller/db/table_names.dart';

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
      CREATE TABLE ${TableNames.communityAssessmentTBL}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        communityName TEXT,
        communityScore INTEGER,
        q1 TEXT, q2 TEXT, q3 TEXT, q4 TEXT, q5 TEXT,
        q6 TEXT, q7a INTEGER, q7b TEXT, q7c TEXT, q8 TEXT, q9 TEXT, q10 TEXT, status INTEGER
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
  }

  Future<int> insertCommunityAssessment(CommunityAssessmentModel model) async {
    final db = await instance.database;
    return await db.insert('responses', model.toMap());
  }

  Future<int> updateCommunityAssessment(CommunityAssessmentModel model) async {
    final db = await instance.database;
    return await db.update('responses', model.toMap(),
        where: 'id = ?', whereArgs: [model.id]);
  }

  Future<List<CommunityAssessmentModel>> getCommunityAssessment() async {
    final db = await instance.database;
    final result = await db.query('responses');
    return result
        .map((json) =>
            CommunityAssessmentModel.fromMap(Map<String, String>.from(json)))
        .toList();
  }

  // get response by status
  Future<List<CommunityAssessmentModel>> getCommunityAssessmentByStatus(
      {int status = 0}) async {
    final db = await instance.database;
    final result =
        await db.query('responses', where: 'status = ?', whereArgs: [status]);
    return result
        .map((json) =>
            CommunityAssessmentModel.fromMap(Map<String, String>.from(json)))
        .toList();
  }

  Future<int> deleteAllCommunityAssessment() async {
    final db = await instance.database;
    return await db.delete('responses');
  }

  // ========================================================================================
  // MONITORING TABLE QUERIES

  Future<int> insertIntoMonitoringTable(MonitoringModel form) async {
    final db = await database;
    // form.cr = DateTime.now().toString();
    // form.updatedAt = DateTime.now().toString();

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
    // form.updatedAt = DateTime.now().toString();

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
}
