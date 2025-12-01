import 'dart:convert';
import 'package:human_rights_monitor/controller/db/db_tables/monitoring_table.dart';
import 'package:human_rights_monitor/controller/models/monitoring_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';



class MonitoringDBHelper {
  static const _dbName = 'monitoring.db';
  static const _dbVersion = 3;  // Bump version to trigger migration for ongoing_birth_cert_process_details
  static Database? _database;

  /// Private constructor to prevent direct instantiation
  MonitoringDBHelper._privateConstructor();
  static final MonitoringDBHelper instance = MonitoringDBHelper._privateConstructor();

  /// Returns existing or initializes the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      
      print('Initializing monitoring database at: $path');
      
      final db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      
      print('Database opened successfully');
      
      // Verify tables exist
      final tables = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
      print('Database tables:');
      for (var table in tables) {
        print(' - ${table['name']}');
      }
      
      return db;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  /// Create tables for monitoring module
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await MonitoringTable.onUpgrade(db, oldVersion, newVersion);
  }

  /// Register all monitoring tables here
  static Future<void> _createTables(Database db) async {
    try {
      print('Creating monitoring tables...');
      // Create monitoring table and its indexes using MonitoringTable
      await MonitoringTable.createTable(db);
      print('Monitoring table created successfully');
      await MonitoringTable.createIndexes(db);
      print('Monitoring table indexes created successfully');
    } catch (e) {
      print('Error creating monitoring tables: $e');
      rethrow;
    }
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

  // CRUD operations for monitoring

  /// Inserts a new monitoring record
  Future<MonitoringModel> insertMonitoringRecord(MonitoringModel monitoring) async {
    final db = await instance.database;
    final id = await db.insert(
      MonitoringTable.tableName,
      monitoring.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return monitoring.copyWith(id: id);
  }

  /// Retrieves all monitoring records
  Future<List<MonitoringModel>> getAllMonitoringRecords() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MonitoringTable.tableName,
      orderBy: '${MonitoringTable.visitDate} DESC',
    );
    return List.generate(maps.length, (i) => MonitoringModel.fromMap(maps[i]));
  }

  /// Retrieves monitoring records for a specific community
  Future<List<MonitoringModel>> getMonitoringRecordsByCommunity(int communityId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MonitoringTable.tableName,
      where: '${MonitoringTable.communityId} = ?',
      whereArgs: [communityId],
      orderBy: '${MonitoringTable.visitDate} DESC',
    );
    return List.generate(maps.length, (i) => MonitoringModel.fromMap(maps[i]));
  }

  /// Gets a single monitoring record by ID
  Future<MonitoringModel?> getMonitoringRecord(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MonitoringTable.tableName,
      where: '${MonitoringTable.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return MonitoringModel.fromMap(maps.first);
    }
    return null;
  }

  /// Updates an existing monitoring record
  Future<int> updateMonitoringRecord(MonitoringModel monitoring) async {
    if (monitoring.id == null) {
      throw Exception('Cannot update a monitoring record without an ID');
    }
    
    final db = await instance.database;
    return await db.update(
      MonitoringTable.tableName,
      monitoring.toMap(),
      where: '${MonitoringTable.id} = ?',
      whereArgs: [monitoring.id],
    );
  }

  /// Deletes a monitoring record by ID
  Future<int> deleteMonitoringRecord(int id) async {
    final db = await instance.database;
    return await db.delete(
      MonitoringTable.tableName,
      where: '${MonitoringTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// Gets monitoring records within a date range
  Future<List<MonitoringModel>> getMonitoringRecordsByDateRange(
    DateTime startDate, 
    DateTime endDate, {
    int? communityId,
  }) async {
    final db = await instance.database;
    final start = DateFormat('yyyy-MM-dd').format(startDate);
    final end = DateFormat('yyyy-MM-dd').format(endDate);
    
    String where = '${MonitoringTable.visitDate} BETWEEN ? AND ?';
    List<dynamic> whereArgs = [start, end];
    
    if (communityId != null) {
      where += ' AND ${MonitoringTable.communityId} = ?';
      whereArgs.add(communityId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      MonitoringTable.tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: '${MonitoringTable.visitDate} DESC',
    );
    
    return List.generate(maps.length, (i) => MonitoringModel.fromMap(maps[i]));
  }

  /// Gets the most recent monitoring record for a community
  Future<MonitoringModel?> getLatestMonitoringRecord(int communityId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MonitoringTable.tableName,
      where: '${MonitoringTable.communityId} = ?',
      whereArgs: [communityId],
      orderBy: '${MonitoringTable.visitDate} DESC',
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return MonitoringModel.fromMap(maps.first);
    }
    return null;
  }

  /// Gets monitoring records by status
  Future<List<MonitoringModel>> getMonitoringRecordsByStatus(int status) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MonitoringTable.tableName,
      where: '${MonitoringTable.status} = ?',
      whereArgs: [status],
      orderBy: '${MonitoringTable.visitDate} DESC',
    );
    return List.generate(maps.length, (i) => MonitoringModel.fromMap(maps[i]));
  }
}
