import 'dart:async';

import 'package:human_rights_monitor/controller/models/consent_model.dart' as consent_model;
import 'package:human_rights_monitor/controller/models/farmeridentification_model.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/models/sensitization_questions_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Import table names
import '../../table_names.dart';
// Import ConsentTable from household_tables with a prefix
import '../../household_tables.dart' as household_tables;

// Import models

import '../../../models/consent_model.dart';
import '../../../models/combined_farmer_identification_model.dart'
    show CombinedFarmerIdentificationModel;
import '../../../models/childrenhouseholdmodel.dart'
    show ChildrenHouseholdModel;
import '../../../models/remediation_model.dart' show RemediationModel;
import '../../../models/sensitization_model.dart' show SensitizationData;
import '../../../models/sensitization_questions_model.dart'
    show SensitizationQuestionModel;
import '../../../models/end_of_collection_model.dart' show EndOfCollectionModel;

class HouseholdDBHelper {
  static const _dbName = 'household.db';
  static const _dbVersion = 1;
  static Database? _database;

  /// Private constructor to prevent direct instantiation
  HouseholdDBHelper._privateConstructor();
  static final HouseholdDBHelper instance =
      HouseholdDBHelper._privateConstructor();

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

  /// Create tables for household module
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add schema changes for version 2 here
    }
    // Add more version upgrades as needed
  }

  /// Register all household tables
  static Future<void> _createTables(Database db) async {
    await household_tables.CoverPageTable.createTable(db);
    await household_tables.ConsentTable.createTable(db);
    await household_tables.FarmerIdentificationTable.createTable(db);
    await household_tables.CombinedFarmerIdentificationTable.createTable(db);
    await household_tables.ChildrenHouseholdTable.createTable(db);
    await household_tables.RemediationTable.createTable(db);
    await household_tables.SensitizationTable.createTable(db);
    await household_tables.SensitizationQuestionsTable.createTable(db);
    await household_tables.EndOfCollectionTable.createTable(db);

    // Create indexes
    await _createIndexes(db);
  }

  /// Create indexes for better query performance
  static Future<void> _createIndexes(Database db) async {
    // Add indexes for frequently queried columns
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_cover_page_farmer 
      ON ${TableNames.coverPageTBL} (selectedFarmer)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_consent_community 
      ON ${TableNames.consentTBL} (communityType)
    ''');
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
    final db = await database;

    // Delete data from all household-related tables
    await db.delete(TableNames.coverPageTBL);
    await db.delete(TableNames.consentTBL);
    await db.delete(TableNames.farmerIdentificationTBL);
    await db.delete(TableNames.combinedFarmIdentificationTBL);
    await db.delete(TableNames.childrenHouseholdTBL);
    await db.delete(TableNames.remediationTBL);
    await db.delete(TableNames.sensitizationTBL);
    await db.delete(TableNames.sensitizationQuestionsTBL);
    await db.delete(TableNames.endOfCollectionTBL);
  }

  /// Delete database if needed (for reset/debug)
  static Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
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

  /// Inserts a new consent record
  Future<int> insertConsent(ConsentData consent) async {
    final db = await database;
    return await db.insert(
      TableNames.consentTBL,
      consent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves a consent record by ID
  Future<ConsentData?> getConsent(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      TableNames.consentTBL,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ConsentData.fromMap(maps.first);
    }
    return null;
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
      return FarmerIdentificationData().copyWith(
        id: data['id'] as int?,
        // Add other properties as needed from the map
      );
    }
    return null;
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
      where: 'farmerId = ?',
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

  /// Gets the count of records in a table
  Future<int> getRecordCount(String tableName) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
    return count ?? 0;
  }

  /// Checks if a record exists
  Future<bool> recordExists(
      String tableName, String column, dynamic value) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $tableName WHERE $column = ?', [value]));
    return count != null && count > 0;
  }
}
