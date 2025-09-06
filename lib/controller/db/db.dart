import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      CREATE TABLE responses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        communityName TEXT,
        communityScore INTEGER,
        q1 TEXT, q2 TEXT, q3 TEXT, q4 TEXT, q5 TEXT,
        q6 TEXT, q7 TEXT, q8 TEXT, q9 TEXT, q10 TEXT, status INTEGER
      )
    ''');
  }

  Future<int> insertResponse(CommunityAssessmentModel model) async {
    final db = await instance.database;
    return await db.insert('responses', model.toMap());
  }

  Future<int> updateResponse(CommunityAssessmentModel model) async {
    final db = await instance.database;
    return await db.update('responses', model.toMap(), where: 'id = ?', whereArgs: [model.id]);
  }

  Future<List<CommunityAssessmentModel>> getResponses() async {
    final db = await instance.database;
    final result = await db.query('responses');
    return result.map((json) => CommunityAssessmentModel.fromMap(Map<String, String>.from(json))).toList();
  }

  // get response by status
  Future<List<CommunityAssessmentModel>> getResponsesByStatus({int status = 0}) async {
    final db = await instance.database;
    final result = await db.query('responses', where: 'status = ?', whereArgs: [status]);
    return result.map((json) => CommunityAssessmentModel.fromMap(Map<String, String>.from(json))).toList();
  }

  Future<int> deleteAll() async {
    final db = await instance.database;
    return await db.delete('responses');
  }
}
