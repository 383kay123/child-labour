import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:human_rights_monitor/controller/models/fullsurveymodel.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:human_rights_monitor/controller/models/survey_summary.dart';

// Import table names
import '../../table_names.dart';
// Import ConsentTable from household_tables with a prefix
import '../../household_tables.dart' as household_tables;

class HouseholdDBHelper {
  // Database version - increment this when making schema changes
  static const int _dbVersion = 13; // Incremented to fix sensitization_questions table
  static const String _dbName = 'household.db';
  static Database? _database;
  
  /// Private constructor to prevent direct instantiation
  HouseholdDBHelper._privateConstructor();
  static final HouseholdDBHelper instance = HouseholdDBHelper._privateConstructor();

  /// Saves all survey data in a single transaction with enhanced error handling and debugging
  Future<bool> saveCompleteSurvey({
    required CoverPageData coverPage,
    required ConsentData consent,
    required FarmerIdentificationData farmer,
    required CombinedFarmerIdentificationModel? combinedFarm,
    required ChildrenHouseholdModel? childrenHousehold,
    required RemediationModel? remediation,
    required SensitizationData? sensitization,
    required List<SensitizationQuestionsData>? sensitizationQuestions,
    required EndOfCollectionModel? endOfCollection,
  }) async {
    final db = await database;
    
    try {
      // Start by diagnosing the current state
      await _diagnoseForeignKeyConstraints(db);
      
      // Start transaction
      await db.execute('BEGIN EXCLUSIVE TRANSACTION');
      debugPrint('🚀 Starting transaction for complete survey save...');
      
      // 1. Save Cover Page - Let SQLite auto-generate the ID
      final coverPageMap = coverPage.toMap();
      coverPageMap.remove('id'); // Remove ID to avoid conflicts
      
      debugPrint('💾 Inserting cover page with data: $coverPageMap');
      
      final coverPageId = await db.insert(
        TableNames.coverPageTBL,
        coverPageMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      debugPrint('✅ Saved cover page with AUTO-GENERATED ID: $coverPageId');
      
      // Verify the cover page was inserted
      final verifyCoverPage = await db.query(
        TableNames.coverPageTBL,
        where: 'id = ?',
        whereArgs: [coverPageId],
      );
      
      if (verifyCoverPage.isEmpty) {
        throw Exception('Cover page was not inserted correctly');
      }
      
      // 2. Save Consent with reference to Cover Page
      debugPrint('💾 Saving consent data for cover page ID: $coverPageId');
      final consentWithId = consent.copyWith(coverPageId: coverPageId);
      await db.insert(
        TableNames.consentTBL,
        consentWithId.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('✅ Saved consent data');
      
      // 3. Save Farmer Identification with reference to Cover Page
      debugPrint('💾 Saving farmer identification for cover page ID: $coverPageId');
      final updatedFarmer = farmer.copyWith(coverPageId: coverPageId);
      final farmerId = await db.insert(
        TableNames.farmerIdentificationTBL,
        updatedFarmer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('✅ Saved farmer identification with ID: $farmerId');
      
      // Verify the farmer was inserted
      final verifyFarmer = await db.query(
        TableNames.farmerIdentificationTBL,
        where: 'id = ?',
        whereArgs: [farmerId],
      );
      
      if (verifyFarmer.isEmpty) {
        throw Exception('Farmer identification was not inserted correctly');
      }
      
      // 4. Save Combined Farm if exists and get its ID
      int? combinedFarmId;
      if (combinedFarm != null) {
        debugPrint('💾 Saving combined farm data for cover page ID: $coverPageId');
        final combinedFarmWithId = combinedFarm.copyWith(coverPageId: coverPageId);
        combinedFarmId = await db.insert(
          TableNames.combinedFarmIdentificationTBL,
          combinedFarmWithId.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint('✅ Saved combined farm with ID: $combinedFarmId');
        
        // Verify the combined farm was inserted
        if (combinedFarmId != null) {
          final verifyCombinedFarm = await db.query(
            TableNames.combinedFarmIdentificationTBL,
            where: 'id = ?',
            whereArgs: [combinedFarmId],
          );
          
          if (verifyCombinedFarm.isEmpty) {
            debugPrint('⚠️ Warning: Combined farm record not found after insertion');
          }
        }
      }
      
      // 5. Save Children Household if exists
      if (childrenHousehold != null) {
        if (combinedFarmId == null) {
          debugPrint('⚠️ Warning: Cannot save children household - no combined farm record exists');
        } else {
          debugPrint('💾 Saving children household for combined farm ID: $combinedFarmId');
          final updatedHousehold = childrenHousehold.copyWith(coverPageId: combinedFarmId);
          await db.insert(
            TableNames.childrenHouseholdTBL,
            updatedHousehold.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          debugPrint('✅ Saved children household with farm_identification_id: $combinedFarmId');
        }
      }
      
      // 6. Save Remediation if exists
      if (remediation != null) {
        debugPrint('💾 Saving remediation data for cover page ID: $coverPageId');
        
        // Ensure we have a valid farmerId
        if (farmerId == null) {
          throw Exception('Cannot save remediation: farmerId is required');
        }
        
        // Create a copy with the correct IDs
        final updatedRemediation = remediation.copyWith(
          coverPageId: coverPageId,
        );
        
        // Convert to map and ensure field names match the database schema
        final remediationMap = {
          ...updatedRemediation.toMap(),
          'farm_identification_id': farmerId, // This is the foreign key in the table
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_synced': 0,
          'sync_status': 0,
        };
        
        // Remove any null values to prevent SQL errors
        remediationMap.removeWhere((key, value) => value == null);
        
        debugPrint('📝 Remediation data to save: $remediationMap');
        
        try {
          final remediationId = await db.insert(
            TableNames.remediationTBL,
            remediationMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          debugPrint('✅ Saved remediation data with ID: $remediationId');
        } catch (e, stackTrace) {
          debugPrint('❌ Error saving remediation data: $e');
          debugPrint('Stack trace: $stackTrace');
          rethrow;
        }
      }
      
      // 7. Save Sensitization if exists - FIXED: Use farmerId instead of combinedFarmId
      if (sensitization != null) {
        // Ensure we have a valid farmIdentificationId - use farmerId which is guaranteed to exist
        if (farmerId == null) {
          throw Exception('Cannot save sensitization: farmerId is required');
        }
        
        final updatedSensitization = sensitization.copyWith(
          coverPageId: coverPageId,
          farmIdentificationId: farmerId,  // FIX: Use farmerId instead of combinedFarmId
          updatedAt: DateTime.now(),
          isSynced: false,
        );
        
        // Create the data map manually to ensure all required fields are included
        final data = {
          ...updatedSensitization.toMap(),
          'cover_page_id': coverPageId,
          'farm_identification_id': farmerId,  // FIX: Use farmerId instead of combinedFarmId
          'updated_at': DateTime.now().toIso8601String(),
          'is_synced': 0,
        };
        
        // Ensure created_at is set if it's a new record
        if (data['created_at'] == null) {
          data['created_at'] = DateTime.now().toIso8601String();
        }
        
        await db.insert(
          TableNames.sensitizationTBL,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        debugPrint('✅ Saved sensitization with farm_identification_id: $farmerId');
      }
      
      // 8. Save Sensitization Questions if exists - FIXED: Add combined farm check
      if (sensitizationQuestions != null && sensitizationQuestions.isNotEmpty) {
        debugPrint('💾 Saving ${sensitizationQuestions.length} sensitization questions...');
        
        // Determine the appropriate ID to use for sensitization questions
        int? sensitizationQuestionsId;
        
        if (combinedFarmId != null) {
          // Use existing combined farm ID
          sensitizationQuestionsId = combinedFarmId;
          debugPrint('✅ Using existing combined farm ID: $sensitizationQuestionsId for sensitization questions');
        } else if (combinedFarm != null) {
          // Create new combined farm record
          debugPrint('🔄 Creating new combined farm record for sensitization questions...');
          final combinedFarmWithId = combinedFarm.copyWith(coverPageId: coverPageId);
          sensitizationQuestionsId = await db.insert(
            TableNames.combinedFarmIdentificationTBL,
            combinedFarmWithId.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          debugPrint('✅ Created new combined farm record with ID: $sensitizationQuestionsId');
        } else {
          // No combined farm data available - use farmerId as fallback
          debugPrint('⚠️ No combined farm data available, using farmerId as fallback for sensitization questions');
          sensitizationQuestionsId = farmerId;
        }

        for (var question in sensitizationQuestions) {
          try {
            // Ensure all required fields are set
            final updatedQuestion = question.copyWith(
              coverPageId: sensitizationQuestionsId, // Use the determined ID
              createdAt: question.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            final questionMap = updatedQuestion.toMap();
            debugPrint('🔍 Saving sensitization question with coverPageId: $sensitizationQuestionsId');
            
            await db.insert(
              TableNames.sensitizationQuestionsTBL,
              questionMap,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            debugPrint('✅ Saved sensitization question');
          } catch (e, stackTrace) {
            debugPrint('❌ Error saving sensitization question: $e');
            debugPrint('Stack trace: $stackTrace');
            debugPrint('Question data: ${question.toMap()}');
            rethrow;
          }
        }
        debugPrint('✅ All sensitization questions saved with ID: $sensitizationQuestionsId');
      }
      
      // 9. Save End of Collection if exists
      if (endOfCollection != null) {
        debugPrint('💾 Saving end of collection data for cover page ID: $coverPageId');
        
        // First, ensure we have a valid farmerId
        if (farmerId == null) {
          throw Exception('Cannot save end of collection: farmerId is required');
        }
        
        // Verify the farmer record exists in the database
        final farmerExists = await _hasRecord(db, TableNames.farmerIdentificationTBL, 'id', farmerId);
        if (!farmerExists) {
          throw Exception('Cannot save end of collection: Farmer with ID $farmerId does not exist');
        }
        
        // Create an updated model with required fields
        final updatedEndOfCollection = endOfCollection.copyWith(
          coverPageId: coverPageId,
          farmIdentificationId: farmerId,
          createdAt: endOfCollection.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Prepare the data for insertion
        final endOfCollectionMap = updatedEndOfCollection.toMap()
          ..addAll({
            'farm_identification_id': farmerId,
            'cover_page_id': coverPageId,
            'created_at': updatedEndOfCollection.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
            'updated_at': updatedEndOfCollection.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
            'is_synced': 0,
            'sync_status': 0,
          });
        
        // Remove any null values to prevent SQL errors
        endOfCollectionMap.removeWhere((key, value) => value == null);
        
        debugPrint('📝 End of collection data to save: $endOfCollectionMap');
        
        try {
          final endOfCollectionId = await db.insert(
            TableNames.endOfCollectionTBL,
            endOfCollectionMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          debugPrint('✅ Saved end of collection data with ID: $endOfCollectionId');
        } catch (e, stackTrace) {
          debugPrint('❌ Error saving end of collection data: $e');
          debugPrint('Stack trace: $stackTrace');
          
          // Log current state of relevant tables for debugging
          await _logCurrentStateForDebugging(db, coverPageId, farmerId);
          rethrow;
        }
      }
      
      // Commit transaction
      await db.execute('COMMIT');
      debugPrint('🎉 Complete survey saved successfully!');
      debugPrint('   - Cover Page ID: $coverPageId');
      debugPrint('   - Farmer ID: $farmerId');
      debugPrint('   - Combined Farm ID: $combinedFarmId');
      return true;
      
    } catch (e, stackTrace) {
      // Rollback in case of error
      await db.execute('ROLLBACK');
      debugPrint('❌ [HouseholdDB] Error saving complete survey: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      return false;
    }
  }

  /// Returns existing or initializes the database
  Future<Database> get database async {
    try {
      debugPrint('🔄 [HouseholdDB] Getting database instance...');
      if (_database != null) {
        debugPrint('✅ [HouseholdDB] Using existing database instance');
        await _logDatabaseInfo();
        return _database!;
      }
      
      debugPrint('🔄 [HouseholdDB] Initializing new database...');
      _database = await _initDatabase();
      
      // Log detailed database info after initialization
      await _logDatabaseInfo();
      
      // Log all tables and their row counts
      await _logTableRowCounts();
      
      return _database!;
    } catch (e, stackTrace) {
      debugPrint('❌ [HouseholdDB] Error accessing database: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Logs detailed information about all tables in the database
  Future<void> _logDatabaseInfo() async {
    try {
      if (_database == null) {
        debugPrint('❌ [HouseholdDB] Database is not initialized');
        return;
      }
      
      final db = _database!;
      
      // Get list of all tables with their SQL
      final tables = await db.rawQuery(
        "SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_metadata'"
      );
      
      debugPrint('\n📊 [HouseholdDB] Database contains ${tables.length} tables:');
      for (var table in tables) {
        final tableName = table['name'] as String;
        final tableSql = table['sql'] as String? ?? 'No SQL available';
        
        debugPrint('\n📋 Table: $tableName');
        debugPrint('   • SQL: $tableSql');
        
        try {
          // Get row count
          final count = await db.rawQuery('SELECT COUNT(*) as count FROM "$tableName"');
          final rowCount = (count.first['count'] as int?) ?? 0;
          debugPrint('   • Rows: $rowCount');
          
          // Get column info
          final columnInfo = await db.rawQuery('PRAGMA table_info("$tableName")');
          debugPrint('   • Columns (${columnInfo.length}):');
          for (var col in columnInfo) {
            debugPrint('     - ${col['name']} (${col['type']}) ${col['pk'] == 1 ? 'PRIMARY KEY' : ''}');
          }
          
          // Show sample data for non-empty tables
          if (rowCount > 0) {
            debugPrint('   • Sample data (first ${rowCount > 3 ? 3 : rowCount} rows):');
            final rows = await db.query(tableName, limit: 3);
            for (var i = 0; i < rows.length; i++) {
              debugPrint('     [Row ${i + 1}]');
              rows[i].forEach((key, value) {
                debugPrint('       $key: $value');
              });
            }
            if (rowCount > 3) {
              debugPrint('     ... and ${rowCount - 3} more rows');
            }
          }
        } catch (e, stackTrace) {
          debugPrint('   • Error reading table $tableName: $e');
          debugPrint('     Stack trace: $stackTrace');
        }
      }
      
      // Check for required tables
      final requiredTables = [
        TableNames.coverPageTBL,
        TableNames.consentTBL,
        TableNames.farmerIdentificationTBL,
        TableNames.combinedFarmIdentificationTBL,
        TableNames.childrenHouseholdTBL,
      ];
      
      final existingTables = tables.map((t) => t['name'] as String).toList();
      final missingTables = requiredTables.where((t) => !existingTables.contains(t)).toList();
      
      if (missingTables.isNotEmpty) {
        debugPrint('\n❌ [HouseholdDB] Missing required tables: $missingTables');
      } else {
        debugPrint('\n✅ [HouseholdDB] All required tables exist');
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ [HouseholdDB] Error getting database info: $e');
      debugPrint('📜 Stack trace: $stackTrace');
    }
  }
  
  /// Logs row counts for all tables
  Future<void> _logTableRowCounts() async {
    try {
      if (_database == null) return;
      
      final db = _database!;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_metadata'"
      );
      
      debugPrint('\n📊 [HouseholdDB] Table Row Counts:');
      for (var table in tables) {
        final tableName = table['name'] as String;
        try {
          final count = await db.rawQuery('SELECT COUNT(*) as count FROM "$tableName"');
          debugPrint('   • $tableName: ${count.first['count']} rows');
        } catch (e) {
          debugPrint('   • $tableName: Error - $e');
        }
      }
    } catch (e) {
      debugPrint('❌ [HouseholdDB] Error getting table row counts: $e');
    }
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    debugPrint('🔄 [HouseholdDB] Initializing database at: $path');
    debugPrint('  • [HouseholdDB] Database version: $_dbVersion');
    
    // Print database file info
    final dbFile = File(path);
    debugPrint('  • [HouseholdDB] Database exists: ${dbFile.existsSync()}');
    if (dbFile.existsSync()) {
      debugPrint('  • [HouseholdDB] Database size: ${dbFile.lengthSync()} bytes');
      debugPrint('  • [HouseholdDB] Last modified: ${dbFile.lastModifiedSync()}');
    }
    if (await dbFile.exists()) {
      debugPrint('  • [HouseholdDB] Database file exists. Size: ${(await dbFile.length()) / 1024} KB');
      debugPrint('  • [HouseholdDB] Last modified: ${await dbFile.lastModified()}');
    } else {
      debugPrint('  • [HouseholdDB] Database file does not exist, will be created');
    }
    
    // Try to open the database with proper error handling
    Database? db;
    
    try {
      // First, try to open the database normally
      debugPrint('🔄 [HouseholdDB] Opening database with version $_dbVersion...');
      db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onUpgrade,
        onConfigure: (db) async {
          debugPrint('  • [HouseholdDB] Configuring database...');
          await db.execute('PRAGMA foreign_keys = ON');
        },
      );
      
      // Verify tables after opening
      await _verifyDatabaseStructure(db);
      
      // Verify tables were created
      final tables = await db.rawQuery("SELECT name, sql FROM sqlite_master WHERE type='table'");
      debugPrint('✅ Database initialized with ${tables.length} tables');
      for (var table in tables) {
        debugPrint('   - ${table['name']}: ${table['sql']}');
      }
      
      // Verify consent table exists and has correct structure
      await _verifyAndFixDatabase(db);
      
      return db;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing database: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Close database if it was opened but then failed
      await db?.close();
      
      try {
        // Delete and recreate the database
        debugPrint('🔄 Attempting to delete and recreate database...');
        await databaseFactory.deleteDatabase(path);
        debugPrint('✅ Database deleted. Recreating...');
        
        // Try opening again with just onCreate
        db = await openDatabase(
          path,
          version: _dbVersion,
          onCreate: _onCreate,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
        );
        
        // Verify recreation
        await _verifyAndFixDatabase(db);
        
        return db;
      } catch (e) {
        debugPrint('❌ Error recreating database: $e');
        rethrow;
      }
    }
  }
  
  /// Verifies the entire database structure
  Future<void> _verifyDatabaseStructure(Database db) async {
    debugPrint('🔍 [HouseholdDB] Verifying database structure...');
    
    // List of all tables that should exist
    final requiredTables = [
      TableNames.coverPageTBL,
      TableNames.consentTBL,
      TableNames.farmerIdentificationTBL,
      TableNames.combinedFarmIdentificationTBL,
      TableNames.childrenHouseholdTBL,
      TableNames.remediationTBL,
      TableNames.sensitizationTBL,
      TableNames.sensitizationQuestionsTBL,
      TableNames.endOfCollectionTBL,
    ];
    
    // Get all existing tables
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    final tableNames = tables.map((t) => t['name'].toString()).toList();
    
    debugPrint('📋 [HouseholdDB] Found ${tables.length} tables in database:');
    for (var table in tables) {
      debugPrint('   • ${table['name']}');
    }
    
    // Check for missing tables
    final missingTables = requiredTables.where((t) => !tableNames.contains(t)).toList();
    
    if (missingTables.isNotEmpty) {
      debugPrint('❌ [HouseholdDB] Missing tables: $missingTables');
      await _createMissingTables(db, missingTables);
    } else {
      debugPrint('✅ [HouseholdDB] All required tables exist');
    }
  }
  
  /// Creates any missing tables
  Future<void> _createMissingTables(Database db, List<String> missingTables) async {
    debugPrint('🔄 [HouseholdDB] Creating ${missingTables.length} missing tables...');
    
    for (final table in missingTables) {
      try {
        debugPrint('  • [HouseholdDB] Creating missing table: $table');
        await _createTableByName(db, table);
      } catch (e, stackTrace) {
        debugPrint('❌ [HouseholdDB] Error creating table $table: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Creates a table by name
  Future<void> _createTableByName(Database db, String tableName) async {
    switch (tableName) {
      case TableNames.remediationTBL:
        await _createRemediationTable(db);
        break;
      case TableNames.coverPageTBL:
        await _createCoverPageTable(db);
        break;
      case TableNames.consentTBL:
        await _createConsentTable(db);
        break;
      case TableNames.farmerIdentificationTBL:
        await _createFarmerIdentificationTable(db);
        break;
      case TableNames.combinedFarmIdentificationTBL:
        await _createCombinedFarmerIdentificationTable(db);
        break;
      case TableNames.childrenHouseholdTBL:
        await _createChildrenHouseholdTable(db);
        break;
      case TableNames.sensitizationTBL:
        await _createSensitizationTable(db);
        break;
      case TableNames.sensitizationQuestionsTBL:
        await _createSensitizationQuestionsTable(db);
        break;
      case TableNames.endOfCollectionTBL:
        await _createEndOfCollectionTable(db);
        break;
      default:
        debugPrint('⚠️ [HouseholdDB] Unknown table: $tableName');
    }
  }

  /// Verifies the database structure and fixes any issues
  Future<void> _verifyAndFixDatabase(Database db) async {
    try {
      // Check if consent table exists
      final consentTableExists = await db.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name=?',
        [TableNames.consentTBL]
      );
      
      if (consentTableExists.isEmpty) {
        debugPrint('❌ Consent table not found! Creating all tables...');
        await _createTables(db);
      } else {
        debugPrint('✅ Consent table exists');
        
        // Verify table structure by checking for required columns
        try {
          final columns = await db.rawQuery('PRAGMA table_info(${TableNames.consentTBL})');
          final columnNames = columns.map((c) => c['name'].toString().toLowerCase()).toList();
          
          debugPrint('📋 Consent table has ${columns.length} columns');
          
          // Check for required columns
          final requiredColumns = ['id', 'consentgiven', 'declinedconsent', 'createdat'];
          final missingColumns = requiredColumns.where(
            (col) => !columnNames.contains(col.toLowerCase())
          ).toList();
          
          if (missingColumns.isNotEmpty) {
            debugPrint('❌ Missing required columns: $missingColumns');
            await _createConsentTable(db);
          } else {
            debugPrint('✅ All required columns exist in consent table');
          }
          
        } catch (e) {
          debugPrint('❌ Error checking consent table structure: $e');
          await _createConsentTable(db);
        }
      }
      
      // Verify all other tables
      await _verifyAndFixOtherTables(db);
      
    } catch (e) {
      debugPrint('❌ Error in _verifyAndFixDatabase: $e');
      rethrow;
    }
  }
  
  /// Verifies and fixes other tables in the database
  Future<void> _verifyAndFixOtherTables(Database db) async {
    try {
      // List of all table names that should exist
      final requiredTables = [
        TableNames.coverPageTBL,
        TableNames.consentTBL,
        TableNames.farmerIdentificationTBL,
        TableNames.combinedFarmIdentificationTBL,
        TableNames.childrenHouseholdTBL,
        TableNames.remediationTBL,
        TableNames.sensitizationTBL,
        TableNames.sensitizationQuestionsTBL,
        TableNames.endOfCollectionTBL,
      ];
      
      // Get all existing tables
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final tableNames = tables.map((t) => t['name'].toString().toLowerCase()).toList();
      
      // Check for missing tables
      for (final table in requiredTables) {
        if (!tableNames.contains(table.toLowerCase())) {
          debugPrint('❌ Table not found: $table');
          await _createTables(db); // Recreate all tables if any are missing
          return;
        }
      }
      
      debugPrint('✅ All required tables exist');
      
    } catch (e) {
      debugPrint('❌ Error in _verifyAndFixOtherTables: $e');
      rethrow;
    }
  }

  /// Called when the database is created
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🔄 Running database creation for version $version');
    
    try {
      // Enable foreign key support
      await db.execute('PRAGMA foreign_keys = ON');
      debugPrint('✅ Foreign key support enabled');
      
      // List all tables before creation
      final existingTables = await db.rawQuery("SELECT name, sql FROM sqlite_master WHERE type='table'");
      debugPrint('📋 Existing tables before creation (${existingTables.length}):');
      for (var table in existingTables) {
        debugPrint('   - ${table['name']}: ${table['sql']}');
      }
      
      // Create all tables in the correct order
      await _createTables(db);
      
      // Create indexes
      await _createIndexes(db);
      
      // List all tables after creation
      final createdTables = await db.rawQuery("SELECT name, sql FROM sqlite_master WHERE type='table'");
      debugPrint('\n✅ Database created with ${createdTables.length} tables:');
      for (var table in createdTables) {
        debugPrint('   - ${table['name']}: ${table['sql']}');
      }
      
      // Create all tables explicitly
      debugPrint('\n🔄 Creating database tables...');
      
      // Create Consent table first as it's a dependency
      try {
        debugPrint('\n🔍 Creating Consent table...');
        
        // 1. First drop the table if it exists
        debugPrint('   • Dropping existing table if it exists...');
        await db.execute('DROP TABLE IF EXISTS ${TableNames.consentTBL}');
        
        // 2. Create the table
        debugPrint('   • Creating table using ConsentTable.createTable()...');
        await household_tables.ConsentTable.createTable(db);
        
        // 3. Verify the table was created
        debugPrint('   • Verifying table creation...');
        final tables = await db.rawQuery(
          "SELECT name, sql FROM sqlite_master WHERE type='table' AND name=?",
          [TableNames.consentTBL]
        );
        
        if (tables.isEmpty) {
          throw Exception('❌ Failed to create ${TableNames.consentTBL} table - no table found after creation');
        }
        
        // 4. Log table details
        debugPrint('✅ ${TableNames.consentTBL} table created successfully');
        debugPrint('   • Schema: ${tables.first['sql']}');
        
        // 5. Create any triggers
        debugPrint('   • Creating triggers...');
        await household_tables.ConsentTable.createTriggers(db);
        
        // 6. List all tables after creation
        final afterTables = await db.rawQuery("SELECT name, sql FROM sqlite_master WHERE type='table'");
        debugPrint('\n📋 All tables after creation (${afterTables.length}):');
        for (var table in afterTables) {
          debugPrint('   - ${table['name']}: ${table['sql']}');
        }
        
      } catch (e, stackTrace) {
        debugPrint('❌ Error creating Consent table: $e');
        debugPrint('Stack trace: $stackTrace');
        
        // List all tables to help with debugging
        try {
          final allTables = await db.rawQuery("SELECT name, sql FROM sqlite_master WHERE type='table'");
          debugPrint('📋 Current tables in database:');
          for (var table in allTables) {
            debugPrint('    • ${table['name']} - ${table['sql']}');
          }
        } catch (e) {
          debugPrint('❌ Error listing tables: $e');
        }
        
        rethrow;
      }
      
      // Create other tables
      try {
        debugPrint('  • Creating CoverPage table...');
        await household_tables.CoverPageTable.createTable(db);
        debugPrint('  ✅ CoverPage table created successfully');
        
        debugPrint('  • Creating FarmerIdentification table...');
        await household_tables.FarmerIdentificationTable.createTable(db);
        debugPrint('  ✅ FarmerIdentification table created successfully');
        
        debugPrint('  • Creating CombinedFarmerIdentification table...');
        await household_tables.CombinedFarmerIdentificationTable.createTable(db);
        debugPrint('  ✅ CombinedFarmerIdentification table created successfully');
        
        debugPrint('  • Creating ChildrenHousehold table...');
        await household_tables.ChildrenHouseholdTable.createTable(db);
        debugPrint('  ✅ ChildrenHousehold table created successfully');
        
        debugPrint('  • Creating Remediation table...');
        await household_tables.RemediationTable.createTable(db);
        debugPrint('  ✅ Remediation table created successfully');
        
        debugPrint('  • Creating Sensitization table...');
        await household_tables.SensitizationTable.createTable(db);
        debugPrint('  ✅ Sensitization table created successfully');
        
        debugPrint('  • Creating SensitizationQuestions table...');
        await household_tables.SensitizationQuestionsTable.createTable(db);
        debugPrint('  ✅ SensitizationQuestions table created successfully');
        
        debugPrint('  • Creating EndOfCollection table...');
        await household_tables.EndOfCollectionTable.createTable(db);
        debugPrint('  ✅ EndOfCollection table created successfully');
        
        // Create any additional tables here
        
      } catch (e) {
        debugPrint('❌ Error creating database tables: $e');
        rethrow;
      }
      
      debugPrint('✅ All database tables created successfully');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error during database creation: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Called when the database needs to be upgraded
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from version $oldVersion to $newVersion');
    
    try {
      // Enable foreign key support
      await db.execute('PRAGMA foreign_keys = ON');
      
      // Handle upgrades from version 1 to 2
      if (oldVersion < 2) {
        print('  • Upgrading from version 1 to 2...');
        
        // Drop and recreate tables with new schema
        print('  • Recreating tables with latest schema...');
        await _createTables(db);
        
        // Create any new triggers
        print('  • Creating triggers...');
        await household_tables.ConsentTable.createTriggers(db);
      }
      
      // Handle upgrades to version 3
      if (oldVersion < 3) {
        print('  • Upgrading to version 3...');
        
        // Log current tables
        final tables = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
        print('  • Current tables in database:');
        for (var table in tables) {
          print('    - ${table['name']}');
        }
        
        // Drop and recreate consent table to ensure latest schema
        print('  • Recreating consent table with latest schema...');
        await db.execute('DROP TABLE IF EXISTS ${TableNames.consentTBL}');
        await household_tables.ConsentTable.createTable(db);
        await household_tables.ConsentTable.createTriggers(db);
        
        // Verify table was created
        final consentTable = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type="table" AND name="${TableNames.consentTBL}"'
        );
        if (consentTable.isEmpty) {
          throw Exception('Failed to create ${TableNames.consentTBL} table');
        }
        
        print('  • Successfully recreated ${TableNames.consentTBL} table');
      }
      
      print('✅ Database upgrade completed successfully');
    } catch (e, stackTrace) {
      print('❌ Error during database upgrade: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Creates all database tables in the correct order
  Future<void> _createTables(Database db) async {
    debugPrint('🔄 Creating database tables...');
    
    try {
      // Create tables in dependency order
      await _createCoverPageTable(db);  // Must be created before its indexes
      await _createConsentTable(db);
      await _createFarmerIdentificationTable(db);
      await _createCombinedFarmerIdentificationTable(db);
      await _createChildrenHouseholdTable(db);
      await _createRemediationTable(db);
      await _createSensitizationTable(db);
      await _createSensitizationQuestionsTable(db);
      await _createEndOfCollectionTable(db);
      
      // Verify all tables were created
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      debugPrint('✅ All tables created successfully. Total tables: ${tables.length}');
      for (var table in tables) {
        debugPrint('   - ${table['name']}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating tables: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Create CoverPage table - FIXED: Remove any foreign key constraints
  static Future<void> _createCoverPageTable(Database db) async {
    try {
      debugPrint('\n🔍 Creating ${TableNames.coverPageTBL} table...');
      
      // Drop the table if it exists
      await db.execute('DROP TABLE IF EXISTS ${TableNames.coverPageTBL}');
      
      // Create the table WITHOUT any foreign key constraints
      await db.execute('''
        CREATE TABLE ${TableNames.coverPageTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          selectedTownCode TEXT,
          selectedFarmerCode TEXT,
          towns TEXT,
          farmers TEXT,
          townError TEXT,
          farmerError TEXT,
          isLoadingTowns INTEGER DEFAULT 0,
          isLoadingFarmers INTEGER DEFAULT 0,
          hasUnsavedChanges INTEGER DEFAULT 0,
          member TEXT,
          ghana_card_number TEXT,
          contact_number TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          sync_status INTEGER DEFAULT 0
        )
      ''');
      
      debugPrint('✅ ${TableNames.coverPageTBL} table created successfully (no foreign keys)');
      
      // Create necessary indexes
      await db.execute('CREATE INDEX IF NOT EXISTS idx_cover_page_farmer ON ${TableNames.coverPageTBL}(selectedFarmerCode)');
      debugPrint('✅ Created index on selectedFarmerCode');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating ${TableNames.coverPageTBL} table: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Create Consent table
  static Future<void> _createConsentTable(Database db) async {
    try {
      debugPrint('\n🔍 Creating ${TableNames.consentTBL} table...');
      await db.execute('DROP TABLE IF EXISTS ${TableNames.consentTBL}');
      await household_tables.ConsentTable.createTable(db);
      await household_tables.ConsentTable.createTriggers(db);
      debugPrint('✅ ${TableNames.consentTBL} table created successfully');
    } catch (e) {
      debugPrint('❌ Error creating ${TableNames.consentTBL} table: $e');
      rethrow;
    }
  }
  
  /// Create FarmerIdentification table
  static Future<void> _createFarmerIdentificationTable(Database db) async {
    try {
      debugPrint('\n🔍 Creating ${TableNames.farmerIdentificationTBL} table...');
      await db.execute('DROP TABLE IF EXISTS ${TableNames.farmerIdentificationTBL}');
      await household_tables.FarmerIdentificationTable.createTable(db);
      debugPrint('✅ ${TableNames.farmerIdentificationTBL} table created successfully');
    } catch (e) {
      debugPrint('❌ Error creating ${TableNames.farmerIdentificationTBL} table: $e');
      rethrow;
    }
  }
  
  /// Create CombinedFarmerIdentification table
  static Future<void> _createCombinedFarmerIdentificationTable(Database db) async {
    try {
      debugPrint('\n🔍 Creating ${TableNames.combinedFarmIdentificationTBL} table...');
      await db.execute('DROP TABLE IF EXISTS ${TableNames.combinedFarmIdentificationTBL}');
      await household_tables.CombinedFarmerIdentificationTable.createTable(db);
      debugPrint('✅ ${TableNames.combinedFarmIdentificationTBL} table created successfully');
    } catch (e) {
      debugPrint('❌ Error creating ${TableNames.combinedFarmIdentificationTBL} table: $e');
      rethrow;
    }
  }
  
  /// Create ChildrenHousehold table
  static Future<void> _createChildrenHouseholdTable(Database db) async {
    try {
      debugPrint('\n🔍 Creating ${TableNames.childrenHouseholdTBL} table...');
      await db.execute('DROP TABLE IF EXISTS ${TableNames.childrenHouseholdTBL}');
      await household_tables.ChildrenHouseholdTable.createTable(db);
      debugPrint('✅ ${TableNames.childrenHouseholdTBL} table created successfully');
    } catch (e) {
      debugPrint('❌ Error creating ${TableNames.childrenHouseholdTBL} table: $e');
      rethrow;
    }
  }
  
  /// Create Sensitization table
  static Future<void> _createSensitizationTable(Database db) async {
    try {
      debugPrint('\n🔍 Creating ${TableNames.sensitizationTBL} table...');
      
      // Drop the table if it exists
      await db.execute('DROP TABLE IF EXISTS ${TableNames.sensitizationTBL}');
      debugPrint('  • Dropped existing ${TableNames.sensitizationTBL} table');
      
      // Create the table (this will also create triggers via createTable)
      await household_tables.SensitizationTable.createTable(db);
      debugPrint('  • Created ${TableNames.sensitizationTBL} table and triggers');
      
      // Verify table was created with correct schema
      final tables = await db.rawQuery(
        "SELECT name, sql FROM sqlite_master WHERE type='table' AND name=?",
        [TableNames.sensitizationTBL]
      );
      
      if (tables.isEmpty) {
        throw Exception('Failed to create ${TableNames.sensitizationTBL} table');
      }
      
      // Log the table schema for debugging
      final tableInfo = await db.rawQuery('PRAGMA table_info(${TableNames.sensitizationTBL})');
      debugPrint('  • Table schema:');
      for (var column in tableInfo) {
        debugPrint('     - ${column['name']} (${column['type']})');
      }
      
      debugPrint('✅ ${TableNames.sensitizationTBL} table created successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating ${TableNames.sensitizationTBL} table: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Create Remediation table
  static Future<void> _createRemediationTable(Database db) async {
    try {
      debugPrint('\n🔍 Creating ${TableNames.remediationTBL} table...');
      
      // Drop the table if it exists
      await db.execute('DROP TABLE IF EXISTS ${TableNames.remediationTBL}');
      debugPrint('  • Dropped existing ${TableNames.remediationTBL} table');
      
      // Create the table
      await household_tables.RemediationTable.createTable(db);
      debugPrint('  • Created ${TableNames.remediationTBL} table');
      
      // Verify table was created
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [TableNames.remediationTBL]
      );
      
      if (tables.isNotEmpty) {
        debugPrint('✅ ${TableNames.remediationTBL} table verified');
      } else {
        throw Exception('Failed to verify table creation');
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating ${TableNames.remediationTBL} table: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  
  /// Create SensitizationQuestions table with proper schema
  static Future<void> _createSensitizationQuestionsTable(Database db) async {
    try {
      debugPrint('\n🔍 Creating ${TableNames.sensitizationQuestionsTBL} table...');
      await db.execute('DROP TABLE IF EXISTS ${TableNames.sensitizationQuestionsTBL}');
      
      // Create the table with all required columns
      await db.execute('''
        CREATE TABLE ${TableNames.sensitizationQuestionsTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          farm_identification_id INTEGER,
          has_sensitized_household INTEGER,
          has_sensitized_on_protection INTEGER,
          has_sensitized_on_safe_labour INTEGER,
          female_adults_count TEXT,
          male_adults_count TEXT,
          consent_for_picture INTEGER,
          consent_reason TEXT,
          sensitization_image_path TEXT,
          household_with_user_image_path TEXT,
          parents_reaction TEXT,
          submitted_at TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (farm_identification_id) REFERENCES ${TableNames.farmerIdentificationTBL}(id)
        )
      ''');
      
      debugPrint('✅ ${TableNames.sensitizationQuestionsTBL} table created successfully');
    } catch (e) {
      debugPrint('❌ Error creating ${TableNames.sensitizationQuestionsTBL} table: $e');
      rethrow;
    }
  }
  
  /// Create EndOfCollection table
  static Future<void> _createEndOfCollectionTable(Database db) async {
    try {
      debugPrint('\n🔍 Creating ${TableNames.endOfCollectionTBL} table...');
      
      // Drop the existing table
      await db.execute('DROP TABLE IF EXISTS ${TableNames.endOfCollectionTBL}');
      
      // Create the table with snake_case column names to match your model
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${TableNames.endOfCollectionTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cover_page_id INTEGER NOT NULL,
          farm_identification_id INTEGER NOT NULL,
          respondent_image_path TEXT,
          producer_signature_path TEXT,
          latitude REAL,
          longitude REAL,
          gps_coordinates TEXT,
          end_time TEXT,
          remarks TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (cover_page_id) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE,
          FOREIGN KEY (farm_identification_id) REFERENCES ${TableNames.farmerIdentificationTBL}(id) ON DELETE CASCADE
        )
      ''');
      
      debugPrint('✅ ${TableNames.endOfCollectionTBL} table created successfully');
    } catch (e) {
      debugPrint('❌ Error creating ${TableNames.endOfCollectionTBL} table: $e');
      rethrow;
    }
  }

  /// Create indexes for better query performance
  Future<void> _createIndexes(Database db) async {
    try {
      print('  • Creating indexes...');
      
      // Create index on cover_page for farmer code
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_cover_page_farmer 
        ON ${TableNames.coverPageTBL} (${household_tables.CoverPageTable.selectedFarmerCode});
      ''');
      
      // Create index on farmer_identification table for cover_page_id
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_farmer_identification_cover_page_id 
        ON ${TableNames.farmerIdentificationTBL} (${household_tables.FarmerIdentificationTable.coverPageId});
      ''');
      
      print('  ✅ Database indexes created successfully');
    } catch (e, stackTrace) {
      print('❌ Error creating database indexes: $e');
      print('Stack trace: $stackTrace');
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

  /// Clears all survey data from household-related tables
  /// This should be called when resetting the form or starting a new survey
  Future<void> clearAllSurveyData() async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        // List of all tables to clear
        final tables = [
          TableNames.coverPageTBL,
          TableNames.consentTBL,
          TableNames.farmerIdentificationTBL,
          TableNames.combinedFarmIdentificationTBL,
          TableNames.childrenHouseholdTBL,
          TableNames.remediationTBL,
          TableNames.sensitizationTBL,
          TableNames.sensitizationQuestionsTBL,
          TableNames.endOfCollectionTBL,
        ];

        // Check if tables exist and delete all records from each table
        for (final table in tables) {
          try {
            // Check if table exists
            final result = await txn.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
              [table]
            );
            
            if (result.isNotEmpty) {
              await txn.delete(table);
              debugPrint('✅ Cleared data from $table');
            } else {
              debugPrint('ℹ️ Table $table does not exist, skipping');
            }
          } catch (e) {
            debugPrint('⚠️ Error clearing $table: $e');
          }
        }
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error in clearAllSurveyData: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't rethrow to prevent app crash, just log the error
    }
  }

  /// Delete database if needed (for reset/debug)
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null; // Reset the database instance
  }

  /// Get the database path for debugging
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }

  /// Verifies if the sensitization table exists and has the correct structure
  Future<bool> verifySensitizationTable() async {
    try {
      final db = await database;
      
      // Check if table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?", 
        [TableNames.sensitizationTBL]
      );
      
      if (tables.isEmpty) {
        debugPrint('❌ ${TableNames.sensitizationTBL} table does not exist');
        return false;
      }
      
      // Check table structure
      try {
        // Try to query the table structure
        await db.rawQuery('PRAGMA table_info(${TableNames.sensitizationTBL})');
        debugPrint('✅ ${TableNames.sensitizationTBL} table exists and is accessible');
        return true;
      } catch (e) {
        debugPrint('❌ Error accessing ${TableNames.sensitizationTBL} table: $e');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error verifying ${TableNames.sensitizationTBL} table: $e');
      return false;
    }
  }

  /// Diagnoses and attempts to fix issues with the sensitization table
  Future<bool> diagnoseAndFixSensitizationTable() async {
    debugPrint('\n🔍 Starting diagnosis of ${TableNames.sensitizationTBL} table...');
    
    try {
      final db = await database;
      
      // 1. Check if table exists
      final tables = await db.rawQuery(
        "SELECT name, sql FROM sqlite_master WHERE type='table' AND name=?", 
        [TableNames.sensitizationTBL]
      );
      
      if (tables.isEmpty) {
        debugPrint('❌ ${TableNames.sensitizationTBL} table does not exist. Attempting to create it...');
        try {
          await _createSensitizationTable(db);
          debugPrint('✅ Successfully created ${TableNames.sensitizationTBL} table');
          return true;
        } catch (e) {
          debugPrint('❌ Failed to create ${TableNames.sensitizationTBL} table: $e');
          return false;
        }
      } else {
        debugPrint('ℹ️ Table ${TableNames.sensitizationTBL} exists. Checking structure...');
        debugPrint('   - Table definition: ${tables.first['sql']}');
        
        // 2. Check table structure
        try {
          final columns = await db.rawQuery('PRAGMA table_info(${TableNames.sensitizationTBL})');
          debugPrint('✅ Table structure is valid. Columns:');
          for (var col in columns) {
            debugPrint('   - ${col['name']} (${col['type']}): ${col['notnull'] == 1 ? 'NOT NULL' : 'NULLABLE'}');
          }
          return true;
        } catch (e) {
          debugPrint('❌ Error checking table structure: $e');
          debugPrint('🔄 Attempting to recreate the table...');
          
          try {
            await _createSensitizationTable(db);
            debugPrint('✅ Successfully recreated ${TableNames.sensitizationTBL} table');
            return true;
          } catch (e) {
            debugPrint('❌ Failed to recreate ${TableNames.sensitizationTBL} table: $e');
            return false;
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error during diagnosis: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  // ==================== Cover Page Operations ====================

  /// Inserts a new cover page record
  Future<int> insertCoverPage(CoverPageData coverPage) async {
    final db = await database;
    return await db.insert(
      TableNames.coverPageTBL,
      coverPage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves a cover page by ID
  Future<CoverPageData?> getCoverPage(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.coverPageTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return CoverPageData.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all cover pages
  Future<List<CoverPageData>> getAllCoverPages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(TableNames.coverPageTBL);
    return List.generate(maps.length, (i) => CoverPageData.fromMap(maps[i]));
  }

  /// Updates an existing cover page
  Future<int> updateCoverPage(CoverPageData coverPage) async {
    if (coverPage.id == null) {
      throw Exception('Cannot update a cover page without an ID');
    }

    final db = await database;
    return await db.update(
      TableNames.coverPageTBL,
      coverPage.toMap(),
      where: 'id = ?',
      whereArgs: [coverPage.id],
    );
  }

  /// Deletes a cover page by ID
  Future<int> deleteCoverPage(int id) async {
    final db = await database;
    return await db.delete(
      TableNames.coverPageTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Consent Operations ====================

  /// Creates the consent table if it doesn't exist
  Future<void> _ensureConsentTableExists() async {
    final db = await database;
    try {
      // Check if table exists
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [TableNames.consentTBL],
      );
      
      if (result.isEmpty) {
        debugPrint('🔄 Consent table not found, creating...');
        await household_tables.ConsentTable.createTable(db);
        await household_tables.ConsentTable.createTriggers(db);
        debugPrint('✅ Consent table created successfully');
      }
    } catch (e) {
      debugPrint('❌ Error ensuring consent table exists: $e');
      rethrow;
    }
  }

  /// Inserts a new consent record
  Future<int> insertConsent(ConsentData consent) async {
    Database? db;
    try {
      // Get database instance
      db = await database;
      
      // Log the data being saved
      final consentMap = consent.toMap();
      debugPrint('ℹ️ Attempting to save consent data: $consentMap');
      
      // Ensure table exists
      await _ensureConsentTableExists();
      
      // Log table info before insert
      await _logTableInfo();
      
      // Perform the insert
      final id = await db.insert(
        TableNames.consentTBL,
        consentMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      debugPrint('✅ Successfully saved consent with ID: $id');
      
      // Verify the record was saved
      final savedRecord = await getConsent(id);
      debugPrint('🔍 Verifying saved record: ${savedRecord?.toMap()}');
      
      return id;
      
    } on DatabaseException catch (e) {
      if (e.toString().contains('no such table')) {
        debugPrint('❌ Consent table not found, attempting to recreate...');
        
        try {
          // Recreate the table
          await _recreateConsentTable();
          
          // Try the insert again
          final id = await db!.insert(
            TableNames.consentTBL,
            consent.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          
          debugPrint('✅ Successfully saved consent after table recreation, ID: $id');
          return id;
          
        } catch (innerE) {
          debugPrint('❌ Failed to recreate consent table: $innerE');
          await _logDatabaseSchema();
          rethrow;
        }
      } else if (e.toString().contains('NOT NULL constraint failed')) {
        debugPrint('❌ NOT NULL constraint failed: $e');
        await _logTableStructure(TableNames.consentTBL);
        rethrow;
      } else {
        debugPrint('❌ Database error in insertConsent: $e');
        rethrow;
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in insertConsent: $e');
      rethrow;
    } finally {
      // Log table info after operation
      if (db != null) {
        await _logTableInfo();
      }
    }
  }
  
  /// Recreates the consent table
  Future<void> _recreateConsentTable() async {
    try {
      final db = await database;
      
      // Drop existing table if it exists
      await db.execute('DROP TABLE IF EXISTS ${TableNames.consentTBL}');
      
      // Create the table using the schema from ConsentTable
      await household_tables.ConsentTable.createTable(db);
      await household_tables.ConsentTable.createTriggers(db);
      
      debugPrint('✅ Successfully recreated ${TableNames.consentTBL} table');
    } catch (e) {
      debugPrint('❌ Failed to recreate consent table: $e');
      rethrow;
    }
  }
  
  /// Logs information about the consent table
  Future<void> _logTableInfo() async {
    try {
      final db = await database;
      
      // Check if table exists
      final tableInfo = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [TableNames.consentTBL]
      );
      
      if (tableInfo.isEmpty) {
        debugPrint('ℹ️ Table ${TableNames.consentTBL} does not exist');
        return;
      }
      
      // Get table structure
      final structure = await db.rawQuery('PRAGMA table_info(${TableNames.consentTBL})');
      debugPrint('ℹ️ Table structure for ${TableNames.consentTBL}:');
      for (var column in structure) {
        debugPrint('  • ${column['name']} (${column['type']}) ${column['notnull'] == 1 ? 'NOT NULL' : ''}');
      }
      
      // Get row count
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${TableNames.consentTBL}')
      ) ?? 0;
      debugPrint('ℹ️ Total records in ${TableNames.consentTBL}: $count');
      
    } catch (e) {
      debugPrint('❌ Error logging table info: $e');
    }
  }
  
  /// Logs the database schema for debugging
  Future<void> _logDatabaseSchema() async {
    try {
      final db = await database;
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      debugPrint('📊 Database schema:');
      
      for (var table in tables) {
        final tableName = table['name'] as String;
        debugPrint('\nTable: $tableName');
        
        try {
          final structure = await db.rawQuery('PRAGMA table_info($tableName)');
          for (var column in structure) {
            debugPrint('  • ${column['name']} (${column['type']}) ${column['notnull'] == 1 ? 'NOT NULL' : ''}');
          }
          
          final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $tableName')
          ) ?? 0;
          debugPrint('  Records: $count');
          
        } catch (e) {
          debugPrint('  Error reading table info: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error logging database schema: $e');
    }
  }
  
  /// Logs the structure of a specific table
  Future<void> _logTableStructure(String tableName) async {
    try {
      final db = await database;
      final structure = await db.rawQuery('PRAGMA table_info($tableName)');
      debugPrint('📋 Table structure for $tableName:');
      
      for (var column in structure) {
        debugPrint('  • ${column['name']} (${column['type']}) ${column['notnull'] == 1 ? 'NOT NULL' : ''}');
      }
      
      // Check for indexes
      final indexes = await db.rawQuery("PRAGMA index_list($tableName)");
      if (indexes.isNotEmpty) {
        debugPrint('\nIndexes:');
        for (var index in indexes) {
          final indexName = index['name'] as String;
          final unique = index['unique'] == 1 ? 'UNIQUE' : '';
          debugPrint('  • $indexName $unique');
          
          // Get index columns
          final indexInfo = await db.rawQuery('PRAGMA index_info($indexName)');
          for (var info in indexInfo) {
            debugPrint('    - ${info['name']}');
          }
        }
      }
      
      // Check for foreign keys
      final foreignKeys = await db.rawQuery('PRAGMA foreign_key_list($tableName)');
      if (foreignKeys.isNotEmpty) {
        debugPrint('\nForeign Keys:');
        for (var fk in foreignKeys) {
          debugPrint('  • ${fk['from']} → ${fk['table']}.${fk['to']}');
        }
      }
      
    } catch (e) {
      debugPrint('❌ Error logging table structure: $e');
    }
  }

  /// Retrieves a consent record by ID
  Future<ConsentData?> getConsent(int id) async {
    try {
      final db = await database;
      await _ensureConsentTableExists();
      
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.consentTBL,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        return ConsentData.fromMap(maps.first);
      }
      return null;
    } on DatabaseException catch (e) {
      if (e.toString().contains('no such table')) {
        debugPrint('❌ Consent table not found after recreation, trying alternative approach...');
        
        // Try to create just the consent table directly
        try {
          final db = await database;
          await household_tables.ConsentTable.createTable(db);
          await household_tables.ConsentTable.createTriggers(db);
          
          // Table was just created, so no data exists yet
          return null;
        } catch (innerE) {
          debugPrint('❌ Failed to create consent table: $innerE');
          rethrow;
        }
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ Error in getConsent: $e');
      rethrow;
    }
  }

  /// Updates an existing consent record
  Future<int> updateConsent(ConsentData consent) async {
    if (consent.id == null) {
      throw Exception('Cannot update a consent record without an ID');
    }

    final db = await database;
    return await db.update(
      TableNames.consentTBL,
      consent.toMap(),
      where: 'id = ?',
      whereArgs: [consent.id],
    );
  }

  // ==================== Farmer Identification Operations ====================

  /// Inserts a new farmer identification record
  Future<int> insertFarmerIdentification(
      FarmerIdentificationData farmer) async {
    final db = await database;
    return await db.insert(
      TableNames.farmerIdentificationTBL,
      farmer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves a farmer identification record by ID
  Future<FarmerIdentificationData?> getFarmerIdentification(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.farmerIdentificationTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      // Create a new instance of FarmerIdentificationData and set its properties from the map
      final data = maps.first;
      return FarmerIdentificationData.fromMap(data);
    }
    return null;
  }

  /// Updates an existing farmer identification record
  Future<int> updateFarmerIdentification(FarmerIdentificationData farmer) async {
    if (farmer.id == null) {
      throw Exception('Cannot update farmer identification without an ID');
    }
    
    final db = await database;
    final updatedData = farmer.toMap()..remove('id'); // Remove ID from update data
    
    return await db.update(
      TableNames.farmerIdentificationTBL,
      updatedData,
      where: 'id = ?',
      whereArgs: [farmer.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== Combined Farmer Identification Operations ====================

  /// Inserts a new combined farmer identification record
  Future<int> insertCombinedFarmerIdentification(
      CombinedFarmerIdentificationModel farmer) async {
    final db = await database;
    return await db.insert(
      TableNames.combinedFarmIdentificationTBL,
      farmer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== Children Household Operations ====================

  /// Inserts a new children household record
  Future<int> insertChildrenHousehold(ChildrenHouseholdModel household) async {
    final db = await database;
    // Convert the model to a map - adjust according to your actual model
    final Map<String, dynamic> householdMap = {
      // Add all relevant fields from ChildrenHouseholdModel
      'id': household.id,
      // Add other fields as needed
    };

    return await db.insert(
      TableNames.childrenHouseholdTBL,
      householdMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all children household records for a specific farmer
  Future<List<ChildrenHouseholdModel>> getChildrenByFarmer(int farmerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.childrenHouseholdTBL,
      where: 'farm_identification_id = ?',
      whereArgs: [farmerId],
    );
    return List.generate(
        maps.length, (i) => ChildrenHouseholdModel.fromMap(maps[i]));
  }

  // ==================== Remediation Operations ====================

  /// Inserts a new remediation record
  Future<int> insertRemediation(RemediationModel remediation) async {
    final db = await database;
    return await db.insert(
      TableNames.remediationTBL,
      remediation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== Sensitization Operations ====================

  /// Inserts a new sensitization record
  Future<int> insertSensitization(SensitizationData sensitization) async {
    final db = await database;
    return await db.insert(
      TableNames.sensitizationTBL,
      sensitization.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== Sensitization Questions Operations ====================

  /// Inserts a new sensitization question record
  Future<int> insertSensitizationQuestion(
      SensitizationQuestionsData question) async {
    final db = await database;
    return await db.insert(
      TableNames.sensitizationQuestionsTBL,
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== End of Collection Operations ====================

  /// Inserts a new end of collection record
  Future<int> insertEndOfCollection(
      EndOfCollectionModel endOfCollection) async {
    final db = await database;
    return await db.insert(
      TableNames.endOfCollectionTBL,
      endOfCollection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== Transaction Operations ====================

  /// Executes multiple database operations in a single transaction
  Future<void> executeInTransaction(Function(Database) operation) async {
    final db = await database;
    await db.transaction((txn) async {
      // Create a new Database object that uses this transaction
      final txDb = txn.database;
      await operation(txDb);
    });
  }

  // ==================== Batch Operations ====================

  /// Executes multiple operations in a batch
  Future<void> executeBatchOperations(
      List<Map<String, dynamic>> operations) async {
    final db = await database;
    final batch = db.batch();

    for (var op in operations) {
      final String table = op['table'];
      final String type = op['type'];
      final Map<String, dynamic> data = op['data'];

      switch (type) {
        case 'insert':
          batch.insert(table, data);
          break;
        case 'update':
          batch.update(
            table,
            data['values'],
            where: data['where'],
            whereArgs: data['whereArgs'],
          );
          break;
        case 'delete':
          batch.delete(
            table,
            where: data['where'],
            whereArgs: data['whereArgs'],
          );
          break;
      }
    }

    await batch.commit(noResult: true);
  }

  // ==================== Helper Methods ====================

  /// Diagnose foreign key constraints in the database
  Future<void> _diagnoseForeignKeyConstraints(Database db) async {
    debugPrint('\n🔍 Diagnosing Foreign Key Constraints...');
    
    try {
      // Get all tables and their foreign keys
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      
      for (var table in tables) {
        final tableName = table['name'] as String;
        debugPrint('\n📋 Table: $tableName');
        
        // Get foreign key information
        final foreignKeys = await db.rawQuery('PRAGMA foreign_key_list($tableName)');
        
        if (foreignKeys.isNotEmpty) {
          debugPrint('   Foreign Keys:');
          for (var fk in foreignKeys) {
            debugPrint('     • ${fk['from']} → ${fk['table']}.${fk['to']}');
          }
        } else {
          debugPrint('   No foreign keys');
        }
        
        // Get table structure
        final structure = await db.rawQuery('PRAGMA table_info($tableName)');
        for (var column in structure) {
          if (column['pk'] == 1) {
            debugPrint('   Primary Key: ${column['name']}');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error diagnosing foreign keys: $e');
    }
  }

  /// Logs the current state of relevant tables for debugging
  Future<void> _logCurrentStateForDebugging(Database db, int? coverPageId, int? farmerId) async {
    try {
      debugPrint('\n📊 CURRENT DATABASE STATE FOR DEBUGGING:');
      
      // Log cover page info
      if (coverPageId != null) {
        final coverPage = await db.query(
          TableNames.coverPageTBL,
          where: 'id = ?',
          whereArgs: [coverPageId],
        );
        debugPrint('\n📄 Cover Page (ID: $coverPageId):');
        debugPrint(coverPage.isNotEmpty ? coverPage.first.toString() : 'Not found');
      }
      
      // Log farmer info
      if (farmerId != null) {
        final farmer = await db.query(
          TableNames.farmerIdentificationTBL,
          where: 'id = ?',
          whereArgs: [farmerId],
        );
        debugPrint('\n👨‍🌾 Farmer (ID: $farmerId):');
        debugPrint(farmer.isNotEmpty ? farmer.first.toString() : 'Not found');
      }
      
      // Log end of collection records
      final endOfCollection = await db.query(
        TableNames.endOfCollectionTBL,
        where: 'cover_page_id = ?',
        whereArgs: [coverPageId],
      );
      debugPrint('\n📦 End of Collection Records:');
      if (endOfCollection.isEmpty) {
        debugPrint('No records found');
      } else {
        debugPrint('Found ${endOfCollection.length} records:');
        for (var record in endOfCollection) {
          debugPrint(record.toString());
        }
      }
      
      // Log table counts
      final tables = [
        TableNames.coverPageTBL,
        TableNames.farmerIdentificationTBL,
        TableNames.combinedFarmIdentificationTBL,
        TableNames.sensitizationQuestionsTBL,
        TableNames.endOfCollectionTBL,
      ];
      
      debugPrint('\n📊 Table Record Counts:');
      for (var table in tables) {
        try {
          final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $table')
          ) ?? 0;
          debugPrint('   - $table: $count records');
        } catch (e) {
          debugPrint('   - $table: Error - $e');
        }
      }
      
    } catch (e) {
      debugPrint('❌ Error logging database state: $e');
    }
  }

  /// Gets the count of records in a table
  Future<int> getRecordCount(String tableName) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Checks if a record exists
  /// Helper method to check if a record exists in a table
  Future<bool> _hasRecord(Database db, String tableName, String column, dynamic value) async {
    try {
      if (value == null) return false;
      final result = await db.query(
        tableName,
        columns: ['1'],
        where: '$column = ?',
        whereArgs: [value],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking if record exists in $tableName: $e');
      return false;
    }
  }

  Future<bool> recordExists(String tableName, String column, dynamic value) async {
    final db = await database;
    return _hasRecord(db, tableName, column, value);
  }

  /// Fetches all surveys from relevant tables and combines them into a single list
  /// of SurveySummary objects, sorted by date (newest first)
 Future<List<SurveySummary>> getAllSurveys() async {
  final db = await database;
  final List<SurveySummary> allSurveys = [];

  try {
    debugPrint('🔍 [HouseholdDB] Fetching all surveys...');
    
    // 1. First, get all cover pages
    debugPrint('🔍 [HouseholdDB] Querying ${TableNames.coverPageTBL} table...');
    final List<Map<String, dynamic>> coverPages = await db.query(
      TableNames.coverPageTBL,
      orderBy: 'created_at DESC',
    );
    debugPrint('✅ [HouseholdDB] Found ${coverPages.length} cover pages');

    // 2. For each cover page, gather all related data
    for (final coverPage in coverPages) {
      try {
        debugPrint('\n🔄 [HouseholdDB] Processing survey with cover page ID: ${coverPage['id']}');
        
        // Extract data from cover page with null safety
        final selectedTownCode = coverPage['selectedTownCode']?.toString() ?? '';
        final selectedFarmerCode = coverPage['selectedFarmerCode']?.toString() ?? '';
        
        // Parse towns and farmers JSON data to get the actual names
        String townName = 'Unknown';
        String farmerName = 'Unknown';
        
        try {
          // Parse towns JSON to get town name
          final townsJson = coverPage['towns']?.toString();
          if (townsJson != null && townsJson.isNotEmpty) {
            try {
              final townsList = jsonDecode(townsJson) as List;
              for (var town in townsList) {
                if (town is Map && town['code'] == selectedTownCode) {
                  townName = town['name']?.toString() ?? 'Unknown';
                  break;
                }
              }
            } catch (e) {
              debugPrint('❌ Error parsing towns JSON: $e');
            }
          }
          
          // Parse farmers JSON to get farmer name
          final farmersJson = coverPage['farmers']?.toString();
          if (farmersJson != null && farmersJson.isNotEmpty) {
            try {
              final farmersList = jsonDecode(farmersJson) as List;
              for (var farmer in farmersList) {
                if (farmer is Map && farmer['code'] == selectedFarmerCode) {
                  farmerName = farmer['name']?.toString() ?? 'Unknown';
                  break;
                }
              }
            } catch (e) {
              debugPrint('❌ Error parsing farmers JSON: $e');
            }
          }
        } catch (e) {
          debugPrint('❌ Error parsing JSON data: $e');
        }

        // Check what data exists for this survey with null safety
        final coverPageId = coverPage['id'] as int? ?? 0;
        
        final hasConsent = (await db.query(
          TableNames.consentTBL,
          where: 'cover_page_id = ?',
          whereArgs: [coverPageId],
        )).isNotEmpty;

        final hasFarmer = (await db.query(
          TableNames.farmerIdentificationTBL,
          where: 'cover_page_id = ?',
          whereArgs: [coverPageId],
        )).isNotEmpty;

        final hasCombinedFarm = (await db.query(
          TableNames.combinedFarmIdentificationTBL,
          where: 'cover_page_id = ?',
          whereArgs: [coverPageId],
        )).isNotEmpty;

        // First get the farmer ID to check for children
        final farmerData = await db.query(
          TableNames.farmerIdentificationTBL,
          where: 'cover_page_id = ?',
          whereArgs: [coverPageId],
          columns: ['id'],
        );
        
        bool hasChildren = false;
        if (farmerData.isNotEmpty) {
          final farmerId = farmerData.first['id'];
          hasChildren = (await db.query(
            TableNames.childrenHouseholdTBL,
            where: 'farm_identification_id = ?',
            whereArgs: [farmerId],
          )).isNotEmpty;
        }

        // Check for remediation using farmer ID
        bool hasRemediation = false;
        if (farmerData.isNotEmpty) {
          final farmerId = farmerData.first['id'];
          hasRemediation = (await db.query(
            TableNames.remediationTBL,
            where: 'farm_identification_id = ?',
            whereArgs: [farmerId],
          )).isNotEmpty;
        }

        // Create and add survey summary
       // Safely parse the submission date
  DateTime submissionDate;
  try {
    submissionDate = DateTime.parse(coverPage['created_at']?.toString() ?? DateTime.now().toIso8601String());
  } catch (e) {
    debugPrint('⚠️ Error parsing date for cover page ${coverPage['id']}, using current date');
    submissionDate = DateTime.now();
  }

  // Create survey summary with all required fields
  final survey = SurveySummary(
    id: coverPage['id'] as int?,
    farmerName: farmerName,
    ghanaCardNumber: coverPage['ghana_card_number']?.toString() ?? 'N/A',
    contactNumber: coverPage['contact_number']?.toString() ?? '',
    community: townName,
    submissionDate: submissionDate,
    isSynced: coverPage['is_synced'] == 1 || coverPage['is_synced'] == true,
    hasCoverData: true,
    hasConsentData: hasConsent,
    hasFarmerData: hasFarmer,
    hasCombinedData: hasCombinedFarm,
    hasRemediationData: hasRemediation,
    hasSensitizationData: false,
    hasSensitizationQuestionsData: false,
    hasEndOfCollectionData: false,
  );

allSurveys.add(survey);
      } catch (e, stackTrace) {
        debugPrint('❌ Error processing cover page ${coverPage['id']}: $e');
        debugPrint('📋 Cover page data: ${coverPage.toString()}');
        debugPrint('📋 Stack trace: $stackTrace');
        
        // Log the error to help with debugging
        if (e is TypeError) {
          debugPrint('🔍 Type error details:');
          debugPrint('- Error: ${e.toString()}');
          debugPrint('- Stack trace: $stackTrace');
        }
        
        // Continue with next cover page instead of failing the whole operation
        continue;
      }
    }

    // 3. Sort all surveys by date (newest first)
    allSurveys.sort((a, b) => b.submissionDate.compareTo(a.submissionDate));

    debugPrint('✅ [HouseholdDB] Successfully loaded ${allSurveys.length} surveys in total');
    return allSurveys;
  } catch (e, stackTrace) {
    debugPrint('❌ [HouseholdDB] Error in getAllSurveys: $e');
    debugPrint('❌ [HouseholdDB] Stack trace: $stackTrace');
    rethrow;
  }
}
  /// Gets all data for a specific survey
  Future<Map<String, dynamic>> getSurveyData(int coverPageId) async {
    final db = await HouseholdDBHelper.instance.database;
    final Map<String, dynamic> surveyData = {};
  
    try {
      debugPrint('🔍 Loading survey data for cover page ID: $coverPageId');
    
      // 1. Cover Page
      final coverPages = await db.query(
        TableNames.coverPageTBL,
        where: 'id = ?',
        whereArgs: [coverPageId],
      );
      if (coverPages.isNotEmpty) {
        surveyData['cover_page'] = coverPages.first;
        debugPrint('✅ Loaded cover page data');
      }
      
      // 2. Consent
      final consentData = await db.query(
        TableNames.consentTBL,
        where: 'coverPageId = ?',
        whereArgs: [coverPageId],
      );
      if (consentData.isNotEmpty) {
        surveyData['consent'] = consentData.first;
        debugPrint('✅ Loaded consent data');
      }
      
      // 3. Farmer Identification
      final farmerData = await db.query(
        TableNames.farmerIdentificationTBL,
        where: 'coverPageId = ?',
        whereArgs: [coverPageId],
      );
      
      if (farmerData.isNotEmpty) {
        final farmerId = farmerData.first['id'] as int;
        surveyData['farmer_identification'] = farmerData.first;
        debugPrint('✅ Loaded farmer identification data (ID: $farmerId)');
      } else {
        debugPrint('⚠️ No farmer identification data found for coverPageId: $coverPageId');
      }

      // 4. Combined Farmer Identification
      final combinedFarmData = await db.query(
        TableNames.combinedFarmIdentificationTBL,
        where: 'id = ?',
        whereArgs: [coverPageId],
      );
      if (combinedFarmData.isNotEmpty) {
        surveyData['combined_farm'] = combinedFarmData.first;
        debugPrint('✅ Loaded combined farm data');
      }

      // 5. Children Household (now we have farmerId available)
      if (surveyData['farmer_identification'] != null) {
        final farmerId = surveyData['farmer_identification']['id'];
        final childrenData = await db.query(
          TableNames.childrenHouseholdTBL,
          where: 'farmerId = ?',
          whereArgs: [farmerId],
        );
        if (childrenData.isNotEmpty) {
          surveyData['children_household'] = childrenData;
          debugPrint('✅ Loaded ${childrenData.length} children records');
        } else {
          debugPrint('ℹ️ No children records found for farmerId: $farmerId');
        }
      }

      // 6. Remediation
      if (surveyData['farmer_identification'] != null) {
        final farmerId = surveyData['farmer_identification']['id'];
        final remediationData = await db.query(
          TableNames.remediationTBL,
          where: 'farm_identification_id = ?',
          whereArgs: [farmerId],
        );
        if (remediationData.isNotEmpty) {
          surveyData['remediation'] = remediationData.first;
          debugPrint('✅ Loaded remediation data');
        }
      }

      // 7. Sensitization
      if (surveyData['farmer_identification'] != null) {
        final farmerId = surveyData['farmer_identification']['id'];
        final sensitizationData = await db.query(
          TableNames.sensitizationTBL,
          where: 'farm_identification_id = ?',
          whereArgs: [farmerId],
        );
        if (sensitizationData.isNotEmpty) {
          surveyData['sensitization'] = sensitizationData.first;
          debugPrint('✅ Loaded sensitization data');
        }

        // 8. Sensitization Questions
        final questionsData = await db.query(
          TableNames.sensitizationQuestionsTBL,
          where: 'farm_identification_id = ?',
          whereArgs: [farmerId],
        );
        if (questionsData.isNotEmpty) {
          surveyData['sensitization_questions'] = questionsData;
          debugPrint('✅ Loaded ${questionsData.length} sensitization questions');
        }

        // 9. End of Collection
        final endData = await db.query(
          TableNames.endOfCollectionTBL,
          where: 'farm_identification_id = ?',
          whereArgs: [farmerId],
        );
        if (endData.isNotEmpty) {
          surveyData['end_of_collection'] = endData.first;
          debugPrint('✅ Loaded end of collection data');
        }
      }

      // Print survey data summary
      debugPrint('📊 Survey data summary:');
      surveyData.forEach((key, value) {
        if (value is List) {
          debugPrint('   - $key: ${value.length} records');
        } else {
          debugPrint('   - $key: ${value != null ? 'exists' : 'missing'}');
        }
      });

      return surveyData;
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading survey data: $e');
      debugPrint('Stack trace: $stackTrace');
      return {};
    }
  }

/// Loads a complete survey by farmerIdentificationId or coverId
Future<FullSurveyModel?> getFullSurvey(int id) async {
 final dbHelper = HouseholdDBHelper.instance;
final db = await dbHelper.database;
  try {
    // 1. Cover Page
    final coverMaps = await db.query(TableNames.coverPageTBL, where: 'id = ?', whereArgs: [id]);
    if (coverMaps.isEmpty) return null;
    final cover = CoverPageData.fromMap(coverMaps.first);

    // 2. Consent
    final consentMaps = await db.query(TableNames.consentTBL, where: 'coverPageId = ?', whereArgs: [id]);
    final consent = consentMaps.isNotEmpty ? ConsentData.fromMap(consentMaps.first) : null;

    // 3. Farmer
    final farmerMaps = await db.query(TableNames.farmerIdentificationTBL, where: 'coverPageId = ?', whereArgs: [id]);
    final farmer = farmerMaps.isNotEmpty ? FarmerIdentificationData.fromMap(farmerMaps.first) : null;

    // 4. Combined Farm
    final farmMaps = await db.query(TableNames.combinedFarmIdentificationTBL, where: 'coverPageId = ?', whereArgs: [id]);
    final farm = farmMaps.isNotEmpty ? CombinedFarmerIdentificationModel.fromMap(farmMaps.first) : null;

    // 5. Children Household
    final childrenMaps = await db.query(TableNames.childrenHouseholdTBL, where: 'farmerId = ?', whereArgs: [farmer?.id ?? id]);
    final childrenHousehold = childrenMaps.isNotEmpty ? ChildrenHouseholdModel.fromMap(childrenMaps.first) : null;

    // 6. Child Details (assume stored as JSON in childrenHousehold or separate table)
    List<dynamic> childDetails = [];
    if (childrenHousehold?.childrenDetails != null) {
      childDetails = childrenHousehold!.childrenDetails;
    }

    // 7. Remediation
    final remMaps = await db.query(TableNames.remediationTBL, where: 'farmerId = ?', whereArgs: [farmer?.id ?? id]);
    final remediation = remMaps.isNotEmpty ? RemediationModel.fromMap(remMaps.first) : null;

    // 8. Sensitization
    final senMaps = await db.query(TableNames.sensitizationTBL, where: 'farmerId = ?', whereArgs: [farmer?.id ?? id]);
    final sensitization = senMaps.isNotEmpty ? SensitizationData.fromMap(senMaps.first) : null;

    // 9. Sensitization Questions
    final sqMaps = await db.query(TableNames.sensitizationQuestionsTBL, where: 'farmerId = ?', whereArgs: [farmer?.id ?? id]);
    final sensitizationQuestions = sqMaps.isNotEmpty 
        ? sqMaps.map((map) => SensitizationQuestionsData.fromMap(map)).toList() 
        : null;

    // 10. Farm (CombinedFarmIdentification)
    final combinedFarmMaps = await db.query(
      TableNames.combinedFarmIdentificationTBL,
      where: 'id = ?',
      whereArgs: [farmer?.id ?? id],
    );
    final combinedFarm = combinedFarmMaps.isNotEmpty ? CombinedFarmerIdentificationModel.fromMap(combinedFarmMaps.first) : null;

    // 11. End of Collection
    final endMaps = await db.query(TableNames.endOfCollectionTBL, where: 'farmerId = ?', whereArgs: [farmer?.id ?? id]);
    final endOfCollection = endMaps.isNotEmpty ? EndOfCollectionModel.fromMap(endMaps.first) : null;

    return FullSurveyModel(
      cover: cover,
      consent: consent,
      farmer: farmer,
      combinedFarm: combinedFarm,
      childrenHousehold: childrenHousehold,
      // childDetails: childDetails,
      remediation: remediation,
      sensitization: sensitization,
      sensitizationQuestions: sensitizationQuestions,
      endOfCollection: endOfCollection,
      surveyId: farmer?.id?.toString() ?? id.toString(),
      createdAt: DateTime.now(),
    );
  } catch (e) {
    debugPrint('Error loading full survey: $e');
    return null;
  }
}
}