import 'dart:developer';
import 'package:human_rights_monitor/controller/db/db_tables/community_assessment_table.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Import table names

// Import community-related table files

// Add other community-related table imports here

class CommunityDBHelper {
  static const _dbName = 'community.db';
  static const _dbVersion = 2;
  static Database? _database;

  /// Private constructor to prevent direct instantiation
  CommunityDBHelper._privateConstructor();
  static final CommunityDBHelper instance = CommunityDBHelper._privateConstructor();

  /// Returns existing or initializes the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables for community module
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add any schema changes for version 2 here
      await db.execute('''
        ALTER TABLE ${TableNames.communityAssessmentTBL} 
        ADD COLUMN status INTEGER DEFAULT 0
      ''');
    }
    // Add more version upgrades as needed
  }

  /// Register all community tables here
  static Future<void> _createTables(Database db) async {
    // Create community assessment table and its indexes
    await CommunityAssessmentTable.createTable(db);
    await CommunityAssessmentTable.createIndexes(db);
  }

  /// Close the database when done
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete database if needed (for reset/debug)
  static Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
  }

  // Add CRUD operations for community tables here
  
  // CRUD operations for community assessment
  
  /// Inserts a new community assessment record
  Future<int> insertCommunityAssessment(Map<String, dynamic> row) async {
    final db = await instance.database;
    // Add current timestamp if not provided
    if (!row.containsKey('date_created')) {
      row['date_created'] = DateTime.now().toIso8601String();
    }
    return await db.insert(
      CommunityAssessmentTable.tableName,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all community assessments
  Future<List<Map<String, dynamic>>> getAllCommunityAssessments() async {
    final db = await instance.database;
    return await db.query(
      CommunityAssessmentTable.tableName,
      orderBy: '${CommunityAssessmentTable.date_created} DESC',
    );
  }

  /// Updates the status of a community assessment by ID
  Future<bool> updateAssessmentStatus(int id, int status) async {
    try {
      final db = await database;
      final count = await db.update(
        CommunityAssessmentTable.tableName,
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      log('Error updating assessment status: $e');
      return false;
    }
  }

  /// Retrieves a single community assessment by ID
  Future<Map<String, dynamic>?> getCommunityAssessment(int id) async {
    final db = await instance.database;
    final results = await db.query(
      CommunityAssessmentTable.tableName,
      where: '${CommunityAssessmentTable.id} = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Updates an existing community assessment
  Future<int> updateCommunityAssessment(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row[CommunityAssessmentTable.id];
    return await db.update(
      CommunityAssessmentTable.tableName,
      row,
      where: '${CommunityAssessmentTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a community assessment by ID
  Future<int> deleteCommunityAssessment(int id) async {
    final db = await instance.database;
    return await db.delete(
      CommunityAssessmentTable.tableName,
      where: '${CommunityAssessmentTable.id} = ?',
      whereArgs: [id],
    );
  }
  
  /// Searches community assessments by name or location
  Future<List<Map<String, dynamic>>> searchCommunityAssessments(String query) async {
    final db = await instance.database;
    return await db.query(
      CommunityAssessmentTable.tableName,
      where: '''
        ${CommunityAssessmentTable.community_name} LIKE ? OR 
        ${CommunityAssessmentTable.region} LIKE ? OR 
        ${CommunityAssessmentTable.district} LIKE ?
      ''',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }
}
