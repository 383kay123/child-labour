import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:human_rights_monitor/controller/models/fullsurveymodel.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:human_rights_monitor/controller/models/survey_summary.dart';

// Import table names
import '../../table_names.dart';
// Import ConsentTable from household_tables with a prefix
import '../../household_tables.dart' as household_tables;

class HouseholdDBHelper {
  // Database version - increment this when making schema changes
  static const int _dbVersion = 15; // Updated to use only cover_page_id
  static const String _dbName = 'household.db';
  static Database? _database;
  static bool _isInitialized = false;
  
  /// Private constructor to prevent direct instantiation
  HouseholdDBHelper._privateConstructor();
  static final HouseholdDBHelper instance = HouseholdDBHelper._privateConstructor();

  /// Get the database instance with proper connection management
  /// Gets the most recent cover page from the database
  Future<CoverPageData?> getLatestCoverPage() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.coverPageTBL,
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return CoverPageData.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting latest cover page: $e');
      return null;
    }
  }

  /// Gets combined farmer identification by cover page ID
  Future<CombinedFarmerIdentificationModel?> getCombinedFarmByCoverPageId(int coverPageId) async {
    try {
      final db = await database;
      final maps = await db.query(
        TableNames.combinedFarmIdentificationTBL,
        where: 'cover_page_id = ?',
        whereArgs: [coverPageId],
      );
      
      if (maps.isNotEmpty) {
        return CombinedFarmerIdentificationModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting combined farm by cover page ID: $e');
      return null;
    }
  }

  /// Gets a cover page by its ID
Future<CoverPageData?> getCoverPage(int id) async {
  final db = await database;
  try {
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.coverPageTBL,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return CoverPageData.fromMap(maps.first);
    }
    return null;
  } catch (e) {
    debugPrint('❌ Error getting cover page: $e');
    rethrow;
  }
}

  Future<Database> get database async {
    if (_database != null && _isInitialized) {
      try {
        // Verify the database is still open
        await _database!.rawQuery('SELECT 1');
        return _database!;
      } catch (e) {
        debugPrint('⚠️ Database connection lost, reinitializing...');
        _database = null;
        _isInitialized = false;
      }
    }

    // Initialize a new database connection
    if (!_isInitialized) {
      try {
        _database = await _initDatabase();
        _isInitialized = true;
        debugPrint('✅ Database initialized successfully');
      } catch (e) {
        _isInitialized = false;
        _database = null;
        debugPrint('❌ Failed to initialize database: $e');
        rethrow;
      }
    }

    return _database!;
  }

  /// Saves all survey data in a single transaction using only cover_page_id
  /// 
  /// This method saves all survey-related data in a single database transaction.
  /// It ensures data consistency by rolling back all changes if any part fails.
  /// 
  /// Parameters:
  /// - coverPage: The cover page data
  /// - consent: The consent data
  /// - farmer: The farmer identification data
  /// - combinedFarm: Optional combined farm data
  /// - childrenHousehold: Optional children household data
  /// - remediation: Optional remediation data
  /// - sensitization: Optional sensitization data
  /// - sensitizationQuestions: Optional list of sensitization questions
  /// - endOfCollection: Optional end of collection data
  /// 
  /// Returns: A Future that completes with true if the operation was successful, false otherwise
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
    // Start transaction
    await db.execute('BEGIN EXCLUSIVE TRANSACTION');
    debugPrint('🚀 Starting transaction for complete survey save...');
    
    // 1. UPDATE Cover Page (Don't create new one)
    debugPrint('💾 Updating existing cover page with ID: ${coverPage.id}');
    
    final coverPageWithSync = coverPage.copyWith(
      isSynced: 0,
      updatedAt: DateTime.now(),
    );

    final coverPageMap = coverPageWithSync.toMap()
      ..addAll({
        'updated_at': DateTime.now().toIso8601String(),
      });

    // Remove any null values to prevent SQL errors
    coverPageMap.removeWhere((key, value) => value == null);

    // UPDATE existing cover page instead of INSERT
    final rowsAffected = await db.update(
      TableNames.coverPageTBL,
      coverPageMap,
      where: 'id = ?',
      whereArgs: [coverPage.id],
    );

    if (rowsAffected == 0) {
      debugPrint('❌ Failed to update cover page with ID: ${coverPage.id}');
      await db.execute('ROLLBACK');
      return false;
    }

    final coverPageId = coverPage.id!; // Use existing ID
    debugPrint('✅ Updated cover page with ID: $coverPageId');

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
    debugPrint('💾 [DEBUG] Starting to save farmer identification...');
    debugPrint('💾 [DEBUG] Cover page ID: $coverPageId');

    try {
      // Create an updated farmer object with the coverPageId set and ensure all required fields are initialized
      final updatedFarmer = farmer.copyWith(
        coverPageId: coverPageId,
        updatedAt: DateTime.now(),
        // Ensure these fields are not null
        hasGhanaCard: farmer.hasGhanaCard ?? 0,
        idPictureConsent: farmer.idPictureConsent ?? 0,
        childrenCount: farmer.childrenCount ?? 0,
        isSynced: farmer.isSynced ?? 0,
        syncStatus: farmer.syncStatus ?? 0,
      );
      
      // Prepare all values with proper null handling
      final hasGhanaCard = updatedFarmer.hasGhanaCard ?? 0;
      final ghanaCardNumber = updatedFarmer.ghanaCardNumber ?? '';
      final selectedIdType = updatedFarmer.selectedIdType ?? '';
      final idNumber = updatedFarmer.idNumber ?? '';
      final idPictureConsent = updatedFarmer.idPictureConsent ?? 0;
      final noConsentReason = updatedFarmer.noConsentReason ?? '';
      final idImagePath = updatedFarmer.idImagePath ?? '';
      final contactNumber = updatedFarmer.contactNumber ?? '';
      final childrenCount = updatedFarmer.childrenCount;
      final now = DateTime.now().toIso8601String();
      
      // Build the SQL query with all fields explicitly listed
      final sql = '''
        INSERT OR REPLACE INTO ${TableNames.farmerIdentificationTBL} (
          id,
          cover_page_id,
          has_ghana_card,
          ghana_card_number,
          selected_id_type,
          id_number,
          id_picture_consent,
          no_consent_reason,
          id_image_path,
          contact_number,
          children_count,
          created_at,
          updated_at,
          is_synced,
          sync_status
        ) VALUES (
          ?,
          ?,
          ?,
          ?,
          ?,
          ?,
          ?,
          ?,
          ?,
          ?,
          ?,
          ?,
          ?,
          ?,
          ?
        )
      ''';

      // Execute the raw query with all parameters
      final result = await db.rawInsert(
        sql,
        [
          updatedFarmer.id,  // id
          updatedFarmer.coverPageId,  // cover_page_id - explicitly included
          hasGhanaCard,  // has_ghana_card
          ghanaCardNumber,  // ghana_card_number
          selectedIdType,  // selected_id_type
          idNumber,  // id_number
          idPictureConsent,  // id_picture_consent
          noConsentReason,  // no_consent_reason
          idImagePath,  // id_image_path
          contactNumber,  // contact_number
          childrenCount,  // children_count
          updatedFarmer.createdAt?.toIso8601String() ?? now,  // created_at
          now,  // updated_at
          updatedFarmer.isSynced ?? 0,  // is_synced
          updatedFarmer.syncStatus ?? 0  // sync_status
        ],
      );
      
      debugPrint('✅ [DEBUG] Successfully saved farmer identification with ID: $result');
      debugPrint('✅ Saved farmer identification with cover_page_id: $coverPageId');
    } catch (e, stackTrace) {
      debugPrint('❌ [DEBUG] Error saving farmer identification: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      rethrow;
    }
    
    // 4. Save Combined Farmer Identification if exists
    if (combinedFarm != null) {
      try {
        debugPrint('💾 Saving combined farmer identification...');
        final combinedMap = combinedFarm.toMap()
          ..addAll({
            'cover_page_id': coverPageId,
            'updated_at': DateTime.now().toIso8601String(),
          });
        
        await db.insert(
          TableNames.combinedFarmIdentificationTBL,
          combinedMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint('✅ Saved combined farmer identification');
      } catch (e, stackTrace) {
        debugPrint('❌ Error saving combined farmer identification: $e');
        debugPrint('📜 Stack trace: $stackTrace');
        rethrow;
      }
    }

    // 5. Save Children Household if exists
    if (childrenHousehold != null) {
      try {
        debugPrint('💾 Saving children household data...');
        final childrenMap = childrenHousehold.toMap()
          ..addAll({
            'cover_page_id': coverPageId,
            'updated_at': DateTime.now().toIso8601String(),
          });
        
        await db.insert(
          TableNames.childrenHouseholdTBL,
          childrenMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint('✅ Saved children household data');
      } catch (e, stackTrace) {
        debugPrint('❌ Error saving children household data: $e');
        debugPrint('📜 Stack trace: $stackTrace');
        rethrow;
      }
    }

    // 6. Save Remediation if exists
    if (remediation != null) {
      try {
        debugPrint('💾 Saving remediation data...');
        final remediationMap = remediation.toMap()
          ..addAll({
            'cover_page_id': coverPageId,
            'updated_at': DateTime.now().toIso8601String(),
          });
        
        await db.insert(
          TableNames.remediationTBL,
          remediationMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint('✅ Saved remediation data');
      } catch (e, stackTrace) {
        debugPrint('❌ Error saving remediation data: $e');
        debugPrint('📜 Stack trace: $stackTrace');
        rethrow;
      }
    }

    // 7. Save Sensitization if exists
    if (sensitization != null) {
      try {
        debugPrint('💾 Saving sensitization data...');
        final sensitizationMap = sensitization.toMap()
          ..addAll({
            'cover_page_id': coverPageId,
            'updated_at': DateTime.now().toIso8601String(),
          });
        
        await db.insert(
          TableNames.sensitizationTBL,
          sensitizationMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint('✅ Saved sensitization data');
      } catch (e, stackTrace) {
        debugPrint('❌ Error saving sensitization data: $e');
        debugPrint('📜 Stack trace: $stackTrace');
        rethrow;
      }
    }

    // 8. Save Sensitization Questions if they exist
    if (sensitizationQuestions != null && sensitizationQuestions.isNotEmpty) {
      try {
        debugPrint('💾 Saving ${sensitizationQuestions.length} sensitization questions...');
        final batch = db.batch();
        
        for (final question in sensitizationQuestions) {
          final questionMap = question.toMap()
            ..addAll({
              'cover_page_id': coverPageId,
              'updated_at': DateTime.now().toIso8601String(),
            });
          
          batch.insert(
            TableNames.sensitizationQuestionsTBL,
            questionMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        
        await batch.commit(noResult: true);
        debugPrint('✅ Saved ${sensitizationQuestions.length} sensitization questions');
      } catch (e, stackTrace) {
        debugPrint('❌ Error saving sensitization questions: $e');
        debugPrint('📜 Stack trace: $stackTrace');
        rethrow;
      }
    }

    // 9. Save End of Collection if exists
    if (endOfCollection != null) {
      try {
        debugPrint('💾 Saving end of collection data...');
        final endMap = endOfCollection.toMap()
          ..addAll({
            'cover_page_id': coverPageId,
            'updated_at': DateTime.now().toIso8601String(),
          });
        
        await db.insert(
          TableNames.endOfCollectionTBL,
          endMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint('✅ Saved end of collection data');
      } catch (e, stackTrace) {
        debugPrint('❌ Error saving end of collection data: $e');
        debugPrint('📜 Stack trace: $stackTrace');
        rethrow;
      }
    }
    
    // Commit transaction
    await db.execute('COMMIT');
    debugPrint('🎉 Complete survey saved successfully!');
    debugPrint('   - Cover Page ID: $coverPageId');
    return true;
    
  } on DatabaseException catch (e, stackTrace) {
    await db.execute('ROLLBACK');
    debugPrint('❌ Database error: ${e.toString()}');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  } catch (e, stackTrace) {
    await db.execute('ROLLBACK');
    debugPrint('❌ Error saving complete survey: $e');
    debugPrint('Stack trace: $stackTrace');
    return false;
  }
}

  /// Updates an existing consent record in the database
  Future<int> updateConsent(ConsentData consent) async {
    final db = await database;
    try {
      // Convert the consent data to a map
      final consentMap = consent.toMap();
      
      // Remove the ID to prevent updating the primary key
      consentMap.remove('id');
      
      // Add updated_at timestamp
      consentMap['updated_at'] = DateTime.now().toIso8601String();
      
      // Update the record
      final result = await db.update(
        'consent',  // Assuming the table name is 'consent'
        consentMap,
        where: 'id = ?',
        whereArgs: [consent.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      debugPrint('✅ Updated consent with ID: ${consent.id}');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating consent: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Updates an existing farmer identification record in the database
  Future<int> updateFarmerIdentification(FarmerIdentificationData farmer) async {
    final db = await database;
    try {
      // Convert the farmer data to a map
      final farmerMap = farmer.toMap();
      
      // Remove the ID to prevent updating the primary key
      farmerMap.remove('id');
      
      // Add updated_at timestamp
      farmerMap['updated_at'] = DateTime.now().toIso8601String();
      
      // Update the record
      final result = await db.update(
        TableNames.farmerIdentificationTBL,
        farmerMap,
        where: 'id = ?',
        whereArgs: [farmer.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      debugPrint('✅ Updated farmer identification with ID: ${farmer.id}');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating farmer identification: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Logs the row count for all tables in the database
  Future<void> _logTableRowCounts() async {
    try {
      final db = await database;
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'");
      
      debugPrint('📊 Table Row Counts:');
      for (final table in tables) {
        final tableName = table['name'] as String;
        try {
          final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM "$tableName"'));
          debugPrint('   - $tableName: $count rows');
        } catch (e) {
          debugPrint('   - $tableName: Error counting rows - $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error logging table row counts: $e');
    }
  }

  /// Initialize database with proper persistence
  /// Verifies that all required tables exist and have the correct structure
  Future<void> _verifyDatabaseStructure(Database db) async {
    debugPrint('🔍 Verifying database structure...');
    
    // List of all required tables
    final requiredTables = [
      TableNames.coverPageTBL,
      TableNames.combinedFarmIdentificationTBL,
      TableNames.sensitizationQuestionsTBL,
      // Add other table names as needed from your TableNames class
    ];
    
    // Check if all required tables exist
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN (${List.filled(requiredTables.length, '?').join(',')})",
      requiredTables,
    );
    
    final existingTables = tables.map((e) => e['name'] as String).toList();
    final missingTables = requiredTables.where((table) => !existingTables.contains(table)).toList();
    
    if (missingTables.isNotEmpty) {
      debugPrint('⚠️ Missing tables: ${missingTables.join(', ')}');
      // Recreate missing tables by calling onCreate
      await _onCreate(db, _dbVersion);
    } else {
      debugPrint('✅ All required tables exist');
    }
    
    // Here you could add more specific structure validations for each table
    // For example, checking if certain columns exist in each table
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    debugPrint('🔄 [HouseholdDB] Initializing database at: $path');
    debugPrint('  • [HouseholdDB] Database version: $_dbVersion');
    
    final dbFile = File(path);
    bool dbExists = await dbFile.exists();
    
    debugPrint('  • [HouseholdDB] Database exists: $dbExists');
    if (dbExists) {
      debugPrint('  • [HouseholdDB] Database size: ${(await dbFile.length()) / 1024} KB');
    }
    
    Database? db;
    
    try {
      db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: onDatabaseDowngradeDelete,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
          await db.execute('PRAGMA journal_mode = WAL');
          await db.execute('PRAGMA synchronous = NORMAL');
        },
      );
      
      await _verifyDatabaseStructure(db);
      final tables = await db.rawQuery("SELECT name, sql FROM sqlite_master WHERE type='table'");
      debugPrint('✅ Database initialized with ${tables.length} tables');
      
      await _logTableRowCounts();
      
      return db;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing database: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Recovery logic...
      try {
        await db?.close();
        db = await openDatabase(
          path,
          version: _dbVersion,
          onCreate: _onCreate,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
        );
        debugPrint('✅ Database recovered successfully');
        return db;
      } catch (recoveryError) {
        debugPrint('❌ Database recovery failed: $recoveryError');
        await databaseFactory.deleteDatabase(path);
        db = await openDatabase(
          path,
          version: _dbVersion,
          onCreate: _onCreate,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
        );
        debugPrint('✅ Database recreated successfully');
        return db;
      }
    }
  }

  /// Called when the database is created - UPDATED SCHEMAS
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🔄 Running database creation for version $version');
    
    try {
      await db.execute('PRAGMA foreign_keys = ON');
      debugPrint('✅ Foreign key support enabled');
      
      await _createTables(db);
      await _createIndexes(db);
      
      debugPrint('✅ All database tables created successfully');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error during database creation: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Called when the database needs to be upgraded - UPDATED FOR NEW SCHEMA
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from version $oldVersion to $newVersion');
    
    try {
      await db.execute('PRAGMA foreign_keys = ON');
      
      // Handle upgrade to version 15 - Remove farmer_id dependencies
      if (oldVersion < 15) {
        print('  • Upgrading to version 15: Removing farmer_id dependencies...');
        await _migrateToCoverPageOnly(db);
      }
      
      print('✅ Database upgrade completed successfully');
    } catch (e, stackTrace) {
      print('❌ Error during database upgrade: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Migrate all tables to use only cover_page_id
  Future<void> _migrateToCoverPageOnly(Database db) async {
    try {
      // Recreate all tables with new schema
      await _createTables(db);
      print('✅ Successfully migrated to cover_page_id only schema');
    } catch (e, stackTrace) {
      print('❌ Error migrating to cover_page_id only: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Creates database indexes for better query performance
  Future<void> _createIndexes(Database db) async {
    debugPrint('🔄 Creating database indexes...');
    
    try {
      // Index for cover_page_id foreign key in all related tables
      await db.execute('CREATE INDEX IF NOT EXISTS idx_consent_cover_page_id ON ${TableNames.consentTBL}(cover_page_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_farmer_identification_cover_page_id ON ${TableNames.farmerIdentificationTBL}(cover_page_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_combined_farmer_identification_cover_page_id ON ${TableNames.combinedFarmIdentificationTBL}(cover_page_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_children_household_cover_page_id ON ${TableNames.childrenHouseholdTBL}(cover_page_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_remediation_cover_page_id ON ${TableNames.remediationTBL}(cover_page_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_sensitization_cover_page_id ON ${TableNames.sensitizationTBL}(cover_page_id)');
      
      // Add other indexes for frequently queried columns
      await db.execute('CREATE INDEX IF NOT EXISTS idx_cover_page_ghana_card ON ${TableNames.coverPageTBL}(ghana_card_number)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_cover_page_sync_status ON ${TableNames.coverPageTBL}(sync_status)');
      
      debugPrint('✅ All database indexes created successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating database indexes: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Creates all database tables with cover_page_id only
  Future<void> _createTables(Database db) async {
    debugPrint('🔄 Creating database tables with cover_page_id only...');
    
    try {
      // Create tables in dependency order
      await _createCoverPageTable(db);
      await _createConsentTable(db);
      await _createFarmerIdentificationTable(db);
      await _createCombinedFarmerIdentificationTable(db);
      await _createChildrenHouseholdTable(db);
      await _createRemediationTable(db);
      await _createSensitizationTable(db);
      await _createSensitizationQuestionsTable(db);
      await _createEndOfCollectionTable(db);
      
      debugPrint('✅ All tables created successfully with cover_page_id only');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating tables: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Create CoverPage table
  static Future<void> _createCoverPageTable(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS ${TableNames.coverPageTBL}');
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
      debugPrint('✅ ${TableNames.coverPageTBL} table created successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating ${TableNames.coverPageTBL} table: $e');
      rethrow;
    }
  }
  
  /// Create Consent table
  static Future<void> _createConsentTable(Database db) async {
    try {
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
      await db.execute('DROP TABLE IF EXISTS ${TableNames.combinedFarmIdentificationTBL}');
      await household_tables.CombinedFarmerIdentificationTable.createTable(db);
      debugPrint('✅ ${TableNames.combinedFarmIdentificationTBL} table created successfully');
    } catch (e) {
      debugPrint('❌ Error creating ${TableNames.combinedFarmIdentificationTBL} table: $e');
      rethrow;
    }
  }
  
  /// Create ChildrenHousehold table - UPDATED: No farm_identification_id
  static Future<void> _createChildrenHouseholdTable(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS ${TableNames.childrenHouseholdTBL}');
      await db.execute('''
        CREATE TABLE ${TableNames.childrenHouseholdTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cover_page_id INTEGER NOT NULL,
          has_children_in_household TEXT,
          number_of_children INTEGER DEFAULT 0,
          children_5_to_17 INTEGER DEFAULT 0,
          children_details TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (cover_page_id) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
        )
      ''');
      debugPrint('✅ ${TableNames.childrenHouseholdTBL} table created successfully (cover_page_id only)');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating ${TableNames.childrenHouseholdTBL} table: $e');
      rethrow;
    }
  }
  
  /// Create Sensitization table with required columns (without farm_identification_id)
  static Future<void> _createSensitizationTable(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS ${TableNames.sensitizationTBL}');
      await db.execute('''
        CREATE TABLE ${TableNames.sensitizationTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cover_page_id INTEGER NOT NULL,
          is_acknowledged INTEGER DEFAULT 0,
          acknowledged_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (cover_page_id) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
        )
      ''');
      debugPrint('✅ ${TableNames.sensitizationTBL} table created successfully (without farm_identification_id)');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating ${TableNames.sensitizationTBL} table: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Create Remediation table - UPDATED: No farm_identification_id
  static Future<void> _createRemediationTable(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS ${TableNames.remediationTBL}');
      await db.execute('''
        CREATE TABLE ${TableNames.remediationTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cover_page_id INTEGER NOT NULL,
          has_school_fees INTEGER,
          child_protection_education INTEGER DEFAULT 0,
          school_kits_support INTEGER DEFAULT 0,
          iga_support INTEGER DEFAULT 0,
          other_support INTEGER DEFAULT 0,
          other_support_details TEXT,
          community_action TEXT,
          other_community_action_details TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_synced INTEGER DEFAULT 0,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (cover_page_id) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
        )
      ''');
      debugPrint('✅ ${TableNames.remediationTBL} table created successfully (cover_page_id only)');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating ${TableNames.remediationTBL} table: $e');
      rethrow;
    }
  }
  
  /// Create SensitizationQuestions table - UPDATED: No farm_identification_id
  static Future<void> _createSensitizationQuestionsTable(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS ${TableNames.sensitizationQuestionsTBL}');
      await db.execute('''
        CREATE TABLE ${TableNames.sensitizationQuestionsTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cover_page_id INTEGER NOT NULL,
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
          FOREIGN KEY (cover_page_id) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
        )
      ''');
      debugPrint('✅ ${TableNames.sensitizationQuestionsTBL} table created successfully (cover_page_id only)');
    } catch (e) {
      debugPrint('❌ Error creating ${TableNames.sensitizationQuestionsTBL} table: $e');
      rethrow;
    }
  }
  
  /// Create EndOfCollection table - UPDATED: No farm_identification_id
  static Future<void> _createEndOfCollectionTable(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS ${TableNames.endOfCollectionTBL}');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${TableNames.endOfCollectionTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cover_page_id INTEGER NOT NULL,
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
          FOREIGN KEY (cover_page_id) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
        )
      ''');
      debugPrint('✅ ${TableNames.endOfCollectionTBL} table created successfully (cover_page_id only)');
    } catch (e) {
      debugPrint('❌ Error creating ${TableNames.endOfCollectionTBL} table: $e');
      rethrow;
    }
  }

  // ... (keep all your existing methods like close, clearAllSurveyData, etc.)

  /// Loads a complete survey by cover page ID using only cover_page_id
Future<FullSurveyModel?> getFullSurvey(int coverPageId) async {
  final db = await database;
  
  try {
    debugPrint('🔍 [HouseholdDB] Loading full survey for coverPageId: $coverPageId');
    
    // 1. Cover Page
    final coverMaps = await db.query(
      TableNames.coverPageTBL, 
      where: 'id = ?', 
      whereArgs: [coverPageId]
    );
    
    if (coverMaps.isEmpty) {
      debugPrint('❌ [HouseholdDB] No cover page found for ID: $coverPageId');
      return null;
    }
    
    final cover = CoverPageData.fromMap(coverMaps.first);
    debugPrint('✅ [HouseholdDB] Loaded cover page with ID: ${cover.id}');

    // 2. Consent
    final consentMaps = await db.query(
      TableNames.consentTBL, 
      where: 'cover_page_id = ?', 
      whereArgs: [coverPageId]
    );
    final consent = consentMaps.isNotEmpty ? ConsentData.fromMap(consentMaps.first) : null;
    debugPrint('✅ [HouseholdDB] Loaded consent: ${consent != null}');

    // 3. Farmer Identification
    final farmerMaps = await db.query(
      TableNames.farmerIdentificationTBL, 
      where: 'cover_page_id = ?', 
      whereArgs: [coverPageId]
    );
    final farmer = farmerMaps.isNotEmpty ? FarmerIdentificationData.fromMap(farmerMaps.first) : null;
    debugPrint('✅ [HouseholdDB] Loaded farmer identification: ${farmer != null}');

    // 4. Combined Farm - ENHANCED PARSING
   // In your getFullSurvey method, enhance the combined farm loading:
CombinedFarmerIdentificationModel? farm;
try {
  final farmMaps = await db.query(
    TableNames.combinedFarmIdentificationTBL, 
    where: 'cover_page_id = ?', 
    whereArgs: [coverPageId]
  );
  
  if (farmMaps.isNotEmpty) {
    debugPrint('🔍 [HouseholdDB] Found combined farm record: ${farmMaps.first}');
    
    // Enhanced parsing with better error handling
    final farmData = Map<String, dynamic>.from(farmMaps.first);
    
    // Check if we have any meaningful data (not just an empty record)
    bool hasValidData = false;
    final jsonFields = ['visit_information', 'owner_information', 'workers_in_farm', 'adults_information'];
    
    for (final field in jsonFields) {
      if (farmData[field] != null && farmData[field].toString().isNotEmpty) {
        try {
          final parsed = jsonDecode(farmData[field].toString());
          if (parsed is Map && parsed.isNotEmpty) {
            hasValidData = true;
            break;
          }
        } catch (e) {
          // If it's already a Map, check if it has data
          if (farmData[field] is Map && (farmData[field] as Map).isNotEmpty) {
            hasValidData = true;
            break;
          }
        }
      }
    }
    
    if (hasValidData) {
      farm = CombinedFarmerIdentificationModel.fromMap(farmData);
      debugPrint('✅ Successfully loaded combined farm data');
    } else {
      debugPrint('⚠️ Combined farm record exists but has no meaningful data');
      farm = null;
    }
  } else {
    debugPrint('ℹ️ No combined farm records found for coverPageId: $coverPageId');
  }
} catch (e, stackTrace) {
  debugPrint('❌ Error loading combined farm: $e');
  debugPrint('📜 Stack trace: $stackTrace');
  farm = null;
}
    // 5. Children Household
    final childrenMaps = await db.query(
      TableNames.childrenHouseholdTBL, 
      where: 'cover_page_id = ?', 
      whereArgs: [coverPageId]
    );
    final childrenHousehold = childrenMaps.isNotEmpty ? ChildrenHouseholdModel.fromMap(childrenMaps.first) : null;
    debugPrint('✅ [HouseholdDB] Loaded children household: ${childrenHousehold != null}');

    // 6. Remediation
    final remMaps = await db.query(
      TableNames.remediationTBL, 
      where: 'cover_page_id = ?', 
      whereArgs: [coverPageId]
    );
    final remediation = remMaps.isNotEmpty ? RemediationModel.fromMap(remMaps.first) : null;
    debugPrint('✅ [HouseholdDB] Loaded remediation: ${remediation != null}');

   // In getFullSurvey method, update sensitization loading:

// 7. Sensitization - ENHANCED with better validation
SensitizationData? sensitization;
try {
  final senMaps = await db.query(
    TableNames.sensitizationTBL, 
    where: 'cover_page_id = ?', 
    whereArgs: [coverPageId]
  );
  
  if (senMaps.isNotEmpty) {
    final senData = Map<String, dynamic>.from(senMaps.first);
    debugPrint('🔍 [HouseholdDB] Raw sensitization data: $senData');
    
    // Check if we have valid data (not just a default record)
    final isAcknowledged = senData['is_acknowledged'] == 1 || senData['is_acknowledged'] == true;
    final hasAcknowledgedAt = senData['acknowledged_at'] != null && 
                              senData['acknowledged_at'].toString().isNotEmpty;
    
    if (isAcknowledged || hasAcknowledgedAt) {
      // Convert boolean fields
      if (senData['is_acknowledged'] != null) {
        senData['is_acknowledged'] = senData['is_acknowledged'] == 1;
      }
      if (senData['is_synced'] != null) {
        senData['is_synced'] = senData['is_synced'] == 1;
      }
      
      // Parse DateTime fields safely
      for (final field in ['acknowledged_at', 'created_at', 'updated_at']) {
        if (senData[field] != null && senData[field] is String) {
          try {
            senData[field] = DateTime.parse(senData[field]);
          } catch (e) {
            debugPrint('⚠️ Error parsing $field: ${senData[field]}');
            senData[field] = null;
          }
        }
      }
      
      sensitization = SensitizationData.fromMap(senData);
      debugPrint('✅ Loaded valid sensitization data');
    } else {
      debugPrint('⚠️ Sensitization record exists but has no meaningful data');
      sensitization = null;
    }
  } else {
    debugPrint('ℹ️ No sensitization records found');
  }
} catch (e, stackTrace) {
  debugPrint('❌ Error loading sensitization: $e');
  debugPrint('📜 Stack trace: $stackTrace');
  sensitization = null;
}

// 8. Sensitization Questions - ENHANCED with comprehensive debugging
List<SensitizationQuestionsData> sensitizationQuestions = [];
try {
  debugPrint('🔍 [HouseholdDB] ===== LOADING SENSITIZATION QUESTIONS =====');
  debugPrint('🔍 [HouseholdDB] Cover Page ID: $coverPageId');
  
  // First, call the debug method
  await debugSensitizationQuestions(coverPageId);
  
  // Verify table exists
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
    [TableNames.sensitizationQuestionsTBL],
  );
  
  if (tables.isEmpty) {
    debugPrint('❌ [HouseholdDB] Table ${TableNames.sensitizationQuestionsTBL} does not exist');
  } else {
    debugPrint('✅ [HouseholdDB] Table exists, querying for data...');
    
    // Query for sensitization questions
    final sqMaps = await db.query(
      TableNames.sensitizationQuestionsTBL, 
      where: 'cover_page_id = ?', 
      whereArgs: [coverPageId],
      orderBy: 'id ASC'
    );
    
    debugPrint('📊 [HouseholdDB] Query returned ${sqMaps.length} records');
    
    if (sqMaps.isNotEmpty) {
      debugPrint('📋 [HouseholdDB] First raw record: ${sqMaps.first}');
      
      for (var i = 0; i < sqMaps.length; i++) {
        try {
          final questionMap = sqMaps[i];
          final qData = Map<String, dynamic>.from(questionMap);
          
          debugPrint('\n📝 [HouseholdDB] Processing question ${i + 1}...');
          debugPrint('   - Raw data: $qData');
          
          // Validate required fields
          if (qData['id'] == null) {
            debugPrint('⚠️ [HouseholdDB] Skipping record with null ID');
            continue;
          }
          
          if (qData['cover_page_id'] != coverPageId) {
            debugPrint('⚠️ [HouseholdDB] Skipping record with wrong cover_page_id: ${qData['cover_page_id']}');
            continue;
          }
          
          // Convert boolean fields with comprehensive handling
          final booleanFields = [
            'has_sensitized_household',
            'has_sensitized_on_protection',
            'has_sensitized_on_safe_labour',
            'consent_for_picture',
            'is_synced'
          ];
          
          for (final field in booleanFields) {
            if (qData[field] != null) {
              if (qData[field] is int) {
                qData[field] = qData[field] == 1;
              } else if (qData[field] is String) {
                final value = qData[field].toString().toLowerCase();
                qData[field] = value == 'true' || value == '1';
              } else if (qData[field] is! bool) {
                qData[field] = false;
              }
            } else {
              qData[field] = false;
            }
            debugPrint('   - $field: ${qData[field]}');
          }
          
          // Parse DateTime fields with comprehensive error handling
          final dateFields = ['submitted_at', 'created_at', 'updated_at'];
          for (final field in dateFields) {
            if (qData[field] != null) {
              try {
                if (qData[field] is String) {
                  qData[field] = DateTime.parse(qData[field]);
                } else if (qData[field] is int) {
                  qData[field] = DateTime.fromMillisecondsSinceEpoch(qData[field]);
                } else if (qData[field] is! DateTime) {
                  qData[field] = DateTime.now();
                }
              } catch (e) {
                debugPrint('⚠️ [HouseholdDB] Error parsing $field: ${qData[field]}');
                qData[field] = field == 'submitted_at' ? DateTime.now() : null;
              }
            } else if (field == 'submitted_at') {
              qData[field] = DateTime.now();
            }
            debugPrint('   - $field: ${qData[field]}');
          }
          
          // Ensure string fields are properly typed
          qData['female_adults_count'] = qData['female_adults_count']?.toString() ?? '0';
          qData['male_adults_count'] = qData['male_adults_count']?.toString() ?? '0';
          qData['consent_reason'] = qData['consent_reason']?.toString() ?? '';
          qData['parents_reaction'] = qData['parents_reaction']?.toString() ?? '';
          qData['sensitization_image_path'] = qData['sensitization_image_path']?.toString();
          qData['household_with_user_image_path'] = qData['household_with_user_image_path']?.toString();
          
          debugPrint('✅ [HouseholdDB] Processed data: $qData');
          
          // Create the model
          final question = SensitizationQuestionsData.fromMap(qData);
          
          if (question.id != null) {
            sensitizationQuestions.add(question);
            debugPrint('✅ [HouseholdDB] Successfully added question ${i + 1} with ID: ${question.id}');
          } else {
            debugPrint('⚠️ [HouseholdDB] Skipping question with null ID after parsing');
          }
          
        } catch (e, stackTrace) {
          debugPrint('❌ [HouseholdDB] Error parsing question ${i + 1}: $e');
          debugPrint('📜 Stack trace: $stackTrace');
          continue;
        }
      }
    } else {
      debugPrint('ℹ️ [HouseholdDB] No records found in query result');
    }
  }
  
  debugPrint('✅ [HouseholdDB] Final count: ${sensitizationQuestions.length} questions loaded');
  debugPrint('🔍 [HouseholdDB] ===== END LOADING SENSITIZATION QUESTIONS =====\n');
  
} catch (e, stackTrace) {
  debugPrint('❌ [HouseholdDB] Error loading sensitization questions: $e');
  debugPrint('📜 Stack trace: $stackTrace');
  sensitizationQuestions = [];
}

// Debug output for verification
debugPrint('📋 Final sensitization questions count: ${sensitizationQuestions.length}');
if (sensitizationQuestions.isNotEmpty) {
  debugPrint('📋 First question summary:');
  debugPrint('   - ID: ${sensitizationQuestions.first.id}');
  debugPrint('   - Cover Page ID: ${sensitizationQuestions.first.coverPageId}');
  debugPrint('   - Has Sensitized Household: ${sensitizationQuestions.first.hasSensitizedHousehold}');
}    // 9. End of Collection - ENHANCED
    EndOfCollectionModel? endOfCollection;
    try {
      final endMaps = await db.query(
        TableNames.endOfCollectionTBL, 
        where: 'cover_page_id = ?', 
        whereArgs: [coverPageId]
      );
      
      if (endMaps.isNotEmpty) {
        endOfCollection = EndOfCollectionModel.fromMap(endMaps.first);
        debugPrint('✅ Loaded end of collection');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading end of collection: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      endOfCollection = null;
    }

    // Create the full survey model
    final fullSurvey = FullSurveyModel(
      cover: cover,
      consent: consent,
      farmer: farmer,
      combinedFarm: farm,
      childrenHousehold: childrenHousehold,
      remediation: remediation,
      sensitization: sensitization,
      sensitizationQuestions: sensitizationQuestions, // Always include the list, even if empty
      endOfCollection: endOfCollection,
      surveyId: coverPageId.toString(),
      createdAt: coverMaps.first['created_at'] != null 
          ? DateTime.parse(coverMaps.first['created_at'].toString())
          : DateTime.now(),
    );

    // Final debug summary
    debugPrint('\n🎉 [HouseholdDB] Survey Load Summary:');
    debugPrint('   - Cover: ${cover != null}');
    debugPrint('   - Consent: ${consent != null}');
    debugPrint('   - Farmer: ${farmer != null}');
    debugPrint('   - Combined Farm: ${farm != null}');
    debugPrint('   - Children: ${childrenHousehold != null}');
    debugPrint('   - Remediation: ${remediation != null}');
    debugPrint('   - Sensitization: ${sensitization != null}');
    debugPrint('   - Sensitization Questions: ${sensitizationQuestions.length}');
    debugPrint('   - End of Collection: ${endOfCollection != null}');
    
    return fullSurvey;
  } catch (e, stackTrace) {
    debugPrint('❌ [HouseholdDB] Error loading full survey: $e');
    debugPrint('📜 Stack trace: $stackTrace');
    rethrow;
  }
}

/// Debug method to verify sensitization questions in database
Future<void> debugSensitizationQuestions(int coverPageId) async {
  try {
    final db = await database;
    
    debugPrint('\n🔍 ====== SENSITIZATION QUESTIONS DEBUG ======');
    debugPrint('🔍 Cover Page ID: $coverPageId');
    
    // Check if table exists
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [TableNames.sensitizationQuestionsTBL],
    );
    
    if (tables.isEmpty) {
      debugPrint('❌ Table ${TableNames.sensitizationQuestionsTBL} does not exist!');
      return;
    }
    
    debugPrint('✅ Table exists');
    
    // Get table schema
    final schema = await db.rawQuery('PRAGMA table_info(${TableNames.sensitizationQuestionsTBL})');
    debugPrint('📋 Table Schema:');
    for (var column in schema) {
      debugPrint('   - ${column['name']}: ${column['type']}');
    }
    
    // Get all records for this cover page
    final records = await db.query(
      TableNames.sensitizationQuestionsTBL,
      where: 'cover_page_id = ?',
      whereArgs: [coverPageId],
    );
    
    debugPrint('📊 Found ${records.length} record(s) for cover_page_id: $coverPageId');
    
    if (records.isEmpty) {
      // Check if there are ANY records in the table
      final allRecords = await db.query(TableNames.sensitizationQuestionsTBL);
      debugPrint('ℹ️ Total records in table: ${allRecords.length}');
      
      if (allRecords.isNotEmpty) {
        debugPrint('ℹ️ Sample record IDs and cover_page_ids:');
        for (var record in allRecords.take(5)) {
          debugPrint('   - ID: ${record['id']}, Cover Page ID: ${record['cover_page_id']}');
        }
      }
    } else {
      // Display each record
      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        debugPrint('\n📄 Record ${i + 1}:');
        record.forEach((key, value) {
          debugPrint('   $key: $value');
        });
      }
    }
    
    debugPrint('🔍 ====== END DEBUG ======\n');
  } catch (e, stackTrace) {
    debugPrint('❌ Error in debug method: $e');
    debugPrint('📜 Stack trace: $stackTrace');
  }
}
/// Inserts a new cover page record
Future<int> insertCoverPage(CoverPageData coverPage) async {
  final db = await database;
  
  final coverMap = coverPage.toMap()
    ..addAll({
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

  coverMap.removeWhere((key, value) => value == null);
  
  debugPrint('💾 Inserting cover page data: $coverMap');
  
  try {
    final id = await db.insert(
      TableNames.coverPageTBL,
      coverMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    debugPrint('✅ Cover page inserted with ID: $id');
    return id;
  } catch (e) {
    debugPrint('❌ Error inserting cover page: $e');
    rethrow;
  }
}

/// Inserts a new consent record
Future<int> insertConsent(ConsentData consent) async {
  final db = await database;
  
  // Convert to map and add timestamp fields
  final consentMap = consent.toMap()
    ..addAll({
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  
  // Remove any null values to prevent SQL errors
  consentMap.removeWhere((key, value) => value == null);
  
  debugPrint('📝 Consent data to save: $consentMap');
  
  try {
    final id = await db.insert(
      TableNames.consentTBL,
      consentMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('✅ Saved consent with ID: $id');
    return id;
  } catch (e, stackTrace) {
    debugPrint('❌ Error saving consent: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

/// Inserts a new farmer identification record
Future<int> insertFarmerIdentification(FarmerIdentificationData farmer) async {
  final db = await database;
  
  // First, ensure we have a valid coverPageId
  if (farmer.coverPageId == null) {
    throw Exception('Cannot save farmer identification: coverPageId is required');
  }
  
  // Create a new map with all required fields, including cover_page_id
  final farmerMap = {
    'id': farmer.id,
    'cover_page_id': farmer.coverPageId, // This is now guaranteed to be non-null
    'has_ghana_card': farmer.hasGhanaCard ?? 0,
    'ghana_card_number': farmer.ghanaCardNumber,
    'selected_id_type': farmer.selectedIdType,
    'id_number': farmer.idNumber,
    'id_picture_consent': farmer.idPictureConsent ?? 0,
    'no_consent_reason': farmer.noConsentReason,
    'id_image_path': farmer.idImagePath,
    'contact_number': farmer.contactNumber,
    'children_count': farmer.childrenCount,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'is_synced': 0,
    'sync_status': 0,
  }..removeWhere((key, value) => key != 'cover_page_id' && value == null);
  
  debugPrint('📝 Farmer identification data to save: $farmerMap');
  
  try {
    final id = await db.insert(
      TableNames.farmerIdentificationTBL,
      farmerMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('✅ Saved farmer identification with ID: $id');
    return id;
  } catch (e, stackTrace) {
    debugPrint('❌ Error saving farmer identification: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}


/// Inserts a new combined farmer identification record
Future<int> insertCombinedFarmerIdentification(CombinedFarmerIdentificationModel farmer) async {
  final db = await database;
  
  // First convert the model to a map
  final farmerMap = farmer.toMap();
  
  // Convert nested objects to JSON strings
  if (farmerMap['visit_information'] != null) {
    farmerMap['visit_information'] = jsonEncode(farmerMap['visit_information']);
  }
  if (farmerMap['owner_information'] != null) {
    farmerMap['owner_information'] = jsonEncode(farmerMap['owner_information']);
  }
  if (farmerMap['workers_in_farm'] != null) {
    farmerMap['workers_in_farm'] = jsonEncode(farmerMap['workers_in_farm']);
  }
  if (farmerMap['adults_information'] != null) {
    farmerMap['adults_information'] = jsonEncode(farmerMap['adults_information']);
  }
  
  // Ensure timestamps are set
  final now = DateTime.now().toIso8601String();
  farmerMap['created_at'] = farmerMap['created_at'] ?? now;
  farmerMap['updated_at'] = now;
  farmerMap['is_synced'] = 0;
  
  // Remove any null values to prevent SQL errors
  farmerMap.removeWhere((key, value) => value == null);
  
  debugPrint('📝 Combined farmer data to save: $farmerMap');
  
  try {
    final id = await db.insert(
      TableNames.combinedFarmIdentificationTBL,
      farmerMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('✅ Saved combined farmer identification with ID: $id');
    return id;
  } catch (e, stackTrace) {
    debugPrint('❌ Error saving combined farmer identification: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

/// Inserts a new children household record
Future<int> insertChildrenHousehold(ChildrenHouseholdModel household) async {
  final db = await database;
  
  // Convert to map and add timestamp fields
  final householdMap = household.toMap()
    ..addAll({
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  
  // Remove any null values to prevent SQL errors
  householdMap.removeWhere((key, value) => value == null);
  
  debugPrint('📝 Children household data to save: $householdMap');
  
  try {
    final id = await db.insert(
      TableNames.childrenHouseholdTBL,
      householdMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('✅ Saved children household with ID: $id');
    return id;
  } catch (e, stackTrace) {
    debugPrint('❌ Error saving children household: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

/// Inserts a new remediation record
Future<int> insertRemediation(RemediationModel remediation) async {
  final db = await database;
  
  // Convert to map and add timestamp fields
  final remediationMap = remediation.toMap()
    ..addAll({
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  
  // Remove any null values to prevent SQL errors
  remediationMap.removeWhere((key, value) => value == null);
  
  debugPrint('📝 Remediation data to save: $remediationMap');
  
  try {
    final id = await db.insert(
      TableNames.remediationTBL,
      remediationMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('✅ Saved remediation with ID: $id');
    return id;
  } catch (e, stackTrace) {
    debugPrint('❌ Error saving remediation: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

  /// Inserts a new sensitization record
  Future<int> insertSensitization(SensitizationData sensitization) async {
  try {
    final db = await database;
    
    // Create a new instance with updated timestamps
    final updatedSensitization = SensitizationData(
      id: sensitization.id,
      coverPageId: sensitization.coverPageId,
      isAcknowledged: sensitization.isAcknowledged,
      acknowledgedAt: sensitization.acknowledgedAt,
      createdAt: sensitization.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      syncStatus: 0,
    );
    
    // Convert to map and add timestamp fields
    final sensitizationMap = updatedSensitization.toMap();
    
    debugPrint('📝 Sensitization data to save: $sensitizationMap');
    
    final id = await db.insert(
      TableNames.sensitizationTBL, 
      sensitizationMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    debugPrint('✅ Saved sensitization with ID: $id');
    return id;
  } catch (e, stackTrace) {
    debugPrint('❌ Error saving sensitization: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}
/// Inserts a new sensitization question record
Future<int> insertSensitizationQuestion(SensitizationQuestionsData question) async {
  final db = await database;
  
  // Convert to map and add timestamp fields
  final questionMap = question.toMap()
    ..addAll({
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  
  // Remove any null values to prevent SQL errors
  questionMap.removeWhere((key, value) => value == null);
  
  debugPrint('📝 Sensitization question data to save: $questionMap');
  
  try {
    final id = await db.insert(
      TableNames.sensitizationQuestionsTBL,
      questionMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('✅ Saved sensitization question with ID: $id');
    return id;
  } catch (e, stackTrace) {
    debugPrint('❌ Error saving sensitization question: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

/// Inserts a new end of collection record
Future<int> insertEndOfCollection(EndOfCollectionModel endOfCollection) async {
  final db = await database;
  
  // Convert to map and add timestamp fields
  final endMap = endOfCollection.toMap()
    ..addAll({
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  
  // Remove any null values to prevent SQL errors
  endMap.removeWhere((key, value) => value == null);
  
  debugPrint('📝 End of collection data to save: $endMap');
  
  try {
    final id = await db.insert(
      TableNames.endOfCollectionTBL,
      endMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('✅ Saved end of collection with ID: $id');
    return id;
  } catch (e, stackTrace) {
    debugPrint('❌ Error saving end of collection: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

  // Update your model classes to remove farmer_id dependencies
  // Make sure all your model classes only use cover_page_id and remove farm_identification_id fields
  
  /// Fetches all survey records from the database and returns them as SurveySummary objects
  Future<List<SurveySummary>> getAllSurveys() async {
    final db = await database;
    final List<SurveySummary> allSurveys = [];

    try {
      debugPrint('🔍 [HouseholdDB] Fetching all surveys...');
      
      // 1. Get all cover pages
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
          
          final coverPageId = coverPage['id'] as int? ?? 0;
          if (coverPageId == 0) continue; // Skip invalid entries
          
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

          // Check what data exists for this survey using cover_page_id only
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

          final hasChildren = (await db.query(
            TableNames.childrenHouseholdTBL,
            where: 'cover_page_id = ?',
            whereArgs: [coverPageId],
          )).isNotEmpty;

          final hasRemediation = (await db.query(
            TableNames.remediationTBL,
            where: 'cover_page_id = ?',
            whereArgs: [coverPageId],
          )).isNotEmpty;

          final hasSensitization = (await db.query(
            TableNames.sensitizationTBL,
            where: 'cover_page_id = ?',
            whereArgs: [coverPageId],
          )).isNotEmpty;

          final hasSensitizationQuestions = (await db.query(
            TableNames.sensitizationQuestionsTBL,
            where: 'cover_page_id = ?',
            whereArgs: [coverPageId],
          )).isNotEmpty;

          final hasEndOfCollection = (await db.query(
            TableNames.endOfCollectionTBL,
            where: 'cover_page_id = ?',
            whereArgs: [coverPageId],
          )).isNotEmpty;

          // Get farmer data for this cover page to retrieve Ghana Card number
          String ghanaCardNumber = 'N/A';
          String contactNumber = '';
          
          if (hasFarmer) {
            final farmerData = await db.query(
              TableNames.farmerIdentificationTBL,
              where: 'cover_page_id = ?',
              whereArgs: [coverPageId],
              limit: 1,
            );
            
            if (farmerData.isNotEmpty) {
              ghanaCardNumber = farmerData.first['ghana_card_number']?.toString() ?? 'N/A';
              contactNumber = farmerData.first['contact_number']?.toString() ?? '';
            }
          }

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
            id: coverPageId,
            farmerName: farmerName,
            ghanaCardNumber: ghanaCardNumber,
            contactNumber: contactNumber,
            community: townName,
            submissionDate: submissionDate,
            isSynced: coverPage['is_synced'] == 1 || coverPage['is_synced'] == true,
            isSubmitted: coverPage['is_submitted'] == 1 || coverPage['is_submitted'] == true,
            hasCoverData: true,
            hasConsentData: hasConsent,
            hasFarmerData: hasFarmer,
            hasCombinedData: hasCombinedFarm,
            hasRemediationData: hasRemediation,
            hasSensitizationData: hasSensitization,
            hasSensitizationQuestionsData: hasSensitizationQuestions,
            hasEndOfCollectionData: hasEndOfCollection,
          );

          allSurveys.add(survey);
        } catch (e, stackTrace) {
          debugPrint('❌ Error processing cover page ${coverPage['id']}: $e');
          debugPrint('📋 Stack trace: $stackTrace');
          continue; // Continue with next cover page instead of failing the whole operation
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

  /// Deletes a survey and all its related data using the cover page ID
  /// Returns the number of rows affected (1 if successful, 0 otherwise)
  Future<int> deleteSurvey(int coverPageId) async {
    try {
      final db = await database;
      
      // Delete from coverPageTBL - this will cascade to delete related records
      // due to the foreign key constraints with ON DELETE CASCADE
      final count = await db.delete(
        TableNames.coverPageTBL,
        where: 'id = ?',
        whereArgs: [coverPageId],
      );
      
      debugPrint('✅ [HouseholdDB] Deleted $count survey(s) with coverPageId: $coverPageId');
      return count;
    } catch (e, stackTrace) {
      debugPrint('❌ [HouseholdDB] Error deleting survey with coverPageId $coverPageId: $e');
      debugPrint('❌ [HouseholdDB] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Alternative method to delete a survey
  Future<int> removeSurvey(int coverPageId) async {
    return deleteSurvey(coverPageId);
  }

  /// Saves end of collection data with better error handling
  Future<int> saveEndOfCollection(EndOfCollectionModel endOfCollection) async {
    final db = await database;
    
    try {
      debugPrint('💾 [HouseholdDB] Saving end of collection data...');
      
      final endMap = endOfCollection.toMap();
      
      // Ensure all required fields are present
      endMap['updated_at'] = DateTime.now().toIso8601String();
      if (endMap['created_at'] == null) {
        endMap['created_at'] = DateTime.now().toIso8601String();
      }
      
      debugPrint('📝 [HouseholdDB] End of collection data to save: $endMap');
      
      final id = await db.insert(
        TableNames.endOfCollectionTBL,
        endMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      debugPrint('✅ [HouseholdDB] Saved end of collection with ID: $id');
      return id;
    } catch (e, stackTrace) {
      debugPrint('❌ [HouseholdDB] Error saving end of collection: $e');
      debugPrint('❌ [HouseholdDB] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Enhanced method to get end of collection data with debugging
  Future<EndOfCollectionModel?> getEndOfCollection(int coverPageId) async {
    final db = await database;
    
    try {
      debugPrint('🔍 [HouseholdDB] Getting end of collection for coverPageId: $coverPageId');
      
      final maps = await db.query(
        TableNames.endOfCollectionTBL,
        where: 'cover_page_id = ?',
        whereArgs: [coverPageId],
      );
      
      debugPrint('📊 [HouseholdDB] Found ${maps.length} end of collection records');
      
      if (maps.isEmpty) {
        debugPrint('ℹ️ [HouseholdDB] No end of collection data found for coverPageId: $coverPageId');
        return null;
      }
      
      final endOfCollection = EndOfCollectionModel.fromMap(maps.first);
      
      // Debug log what we found
      debugPrint('✅ [HouseholdDB] Loaded end of collection data:');
      debugPrint('   - ID: ${endOfCollection.id}');
      debugPrint('   - Cover Page ID: ${endOfCollection.coverPageId}');
      debugPrint('   - Respondent Image: ${endOfCollection.respondentImagePath}');
      debugPrint('   - Signature: ${endOfCollection.producerSignaturePath}');
      debugPrint('   - GPS: ${endOfCollection.gpsCoordinates}');
      debugPrint('   - Lat/Lng: ${endOfCollection.latitude}, ${endOfCollection.longitude}');
      debugPrint('   - End Time: ${endOfCollection.endTime}');
      debugPrint('   - Remarks: ${endOfCollection.remarks}');
      debugPrint('   - Created At: ${endOfCollection.createdAt}');
      debugPrint('   - Updated At: ${endOfCollection.updatedAt}');
      debugPrint('   - Is Synced: ${endOfCollection.isSynced}');
      debugPrint('   - Sync Status: ${endOfCollection.syncStatus}');
      
      return endOfCollection;
    } catch (e, stackTrace) {
      debugPrint('❌ [HouseholdDB] Error getting end of collection: $e');
      debugPrint('❌ [HouseholdDB] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Verifies the existence of sensitization data for a given cover page ID
  /// by checking both the sensitization and sensitization questions tables.
  ///
  /// This method is useful for debugging and verifying data integrity.
  ///
  /// [coverPageId] The ID of the cover page to verify data for
  Future<void> verifySensitizationData(int coverPageId) async {
    final db = await database;
    
    try {
      // Check sensitization table
      final sensitizationData = await db.query(
        TableNames.sensitizationTBL,
        where: 'cover_page_id = ?',
        whereArgs: [coverPageId],
      );
      
      debugPrint('🔍 [HouseholdDB] Sensitization data for coverPageId $coverPageId: ${sensitizationData.length} records');
      if (sensitizationData.isNotEmpty) {
        debugPrint('   - ID: ${sensitizationData.first['id']}');
        debugPrint('   - Is Acknowledged: ${sensitizationData.first['is_acknowledged']}');
        debugPrint('   - Acknowledged At: ${sensitizationData.first['acknowledged_at']}');
      }
      
      // Check sensitization questions table
      final questionsData = await db.query(
        TableNames.sensitizationQuestionsTBL,
        where: 'cover_page_id = ?',
        whereArgs: [coverPageId],
      );
      
      debugPrint('🔍 [HouseholdDB] Sensitization questions for coverPageId $coverPageId: ${questionsData.length} records');
      for (var i = 0; i < questionsData.length; i++) {
        final question = questionsData[i];
        debugPrint('   Question ${i + 1}:');
        debugPrint('   - ID: ${question['id']}');
        debugPrint('   - Question: ${question['question']}');
        debugPrint('   - Answer: ${question['answer']}');
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ [HouseholdDB] Error verifying sensitization data: $e');
      debugPrint('❌ [HouseholdDB] Stack trace: $stackTrace');
      rethrow;
    }
  }
}