import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'survey_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE surveys(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        createdAt TEXT,
        updatedAt TEXT,
        status TEXT,
        consentData TEXT,
        farmerData TEXT,
        remediationData TEXT,
        sensitizationData TEXT,
        childrenData TEXT,
        endCollectionData TEXT
      )
    ''');
  }

  Future<int> insertSurvey(Map<String, dynamic> survey) async {
    final db = await database;
    return await db.insert('surveys', survey);
  }

  Future<List<Map<String, dynamic>>> getSurveys() async {
    final db = await database;
    return await db.query('surveys');
  }

  Future<int> updateSurvey(Map<String, dynamic> survey) async {
    final db = await database;
    return await db.update(
      'surveys',
      survey,
      where: 'id = ?',
      whereArgs: [survey['id']],
    );
  }

  Future<void> deleteSurvey(int id) async {
    final db = await database;
    await db.delete(
      'surveys',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
