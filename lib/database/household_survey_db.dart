import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/household_survey.dart';

class HouseholdSurveyDB {
  static final HouseholdSurveyDB _instance = HouseholdSurveyDB._internal();
  static Database? _database;

  factory HouseholdSurveyDB() => _instance;

  HouseholdSurveyDB._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'household_survey.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create questions table
    await db.execute('''
      CREATE TABLE questions(
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        type TEXT NOT NULL,
        options TEXT,
        isRequired INTEGER DEFAULT 1,
        section TEXT,
        hint TEXT,
        showIf INTEGER DEFAULT 0,
        showIfQuestionId TEXT,
        showIfValue TEXT
      )
    ''');

    // Create responses table
    await db.execute('''
      CREATE TABLE responses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surveyId TEXT NOT NULL,
        questionId TEXT NOT NULL,
        response TEXT,
        timestamp TEXT NOT NULL,
        section TEXT,
        metadata TEXT
      )
    ''');

    // Create survey progress table
    await db.execute('''
      CREATE TABLE survey_progress(
        surveyId TEXT PRIMARY KEY,
        currentSection TEXT NOT NULL,
        currentQuestionIndex INTEGER NOT NULL,
        isCompleted INTEGER DEFAULT 0,
        lastUpdated TEXT NOT NULL
      )
    ''');
  }

  // Questions CRUD
  Future<void> insertQuestions(List<SurveyQuestion> questions) async {
    final db = await database;
    final batch = db.batch();
    
    for (var question in questions) {
      batch.insert('questions', question.toMap(), 
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
  }

  Future<List<SurveyQuestion>> getQuestions({String? section}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    
    if (section != null) {
      maps = await db.query('questions', where: 'section = ?', whereArgs: [section]);
    } else {
      maps = await db.query('questions');
    }
    
    return List.generate(maps.length, (i) => SurveyQuestion.fromMap(maps[i]));
  }

  // Responses CRUD
  Future<int> saveResponse(SurveyResponse response) async {
    final db = await database;
    return await db.insert('responses', response.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SurveyResponse>> getResponses(String surveyId, {String? questionId}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    
    if (questionId != null) {
      maps = await db.query('responses',
          where: 'surveyId = ? AND questionId = ?',
          whereArgs: [surveyId, questionId]);
    } else {
      maps = await db.query('responses', where: 'surveyId = ?', whereArgs: [surveyId]);
    }
    
    return List.generate(maps.length, (i) => SurveyResponse.fromMap(maps[i]));
  }

  // Survey Progress
  Future<void> saveProgress(SurveyProgress progress) async {
    final db = await database;
    await db.insert('survey_progress', progress.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<SurveyProgress?> getProgress(String surveyId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'survey_progress',
      where: 'surveyId = ?',
      whereArgs: [surveyId],
    );

    if (maps.isNotEmpty) {
      return SurveyProgress.fromMap(maps.first);
    }
    return null;
  }

  // Helper methods
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('questions');
    await db.delete('responses');
    await db.delete('survey_progress');
  }
}
