import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/models/enums.dart';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';

import 'package:human_rights_monitor/controller/models/combinefarmer.dart/visit_information_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/identification_of_owner_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/adult_info_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/workers_in_farm_model.dart';

import 'package:geolocator/geolocator.dart';

class CoverPageTable {
  static const String tableName = TableNames.coverPageTBL;

  // Column names as static constants
  static const String id = 'id';
  static const String selectedTownCode = 'selectedTownCode';
  static const String selectedFarmerCode = 'selectedFarmerCode';
  static const String towns = 'towns';
  static const String farmers = 'farmers';
  static const String townError = 'townError';
  static const String farmerError = 'farmerError';
  static const String isLoadingTowns = 'isLoadingTowns';
  static const String isLoadingFarmers = 'isLoadingFarmers';
  static const String hasUnsavedChanges = 'hasUnsavedChanges';
  static const String member = 'member';
  static const String created_at = 'created_at';
  static const String updated_at = 'updated_at';
  static const String is_synced = 'is_synced';

  /// Creates the cover page table
  static Future<void> createTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $selectedTownCode TEXT,
        $selectedFarmerCode TEXT,
        $towns TEXT, -- JSON-encoded list of towns
        $farmers TEXT, -- JSON-encoded list of farmers
        $townError TEXT,
        $farmerError TEXT,
        $isLoadingTowns INTEGER DEFAULT 0,
        $isLoadingFarmers INTEGER DEFAULT 0,
        $hasUnsavedChanges INTEGER DEFAULT 0,
        $member TEXT, -- JSON-encoded member data
        $created_at TEXT,
        $updated_at TEXT,
        $is_synced INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_sync 
      ON $tableName($is_synced)
    ''');
    
    // Create index for selectedFarmerCode
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_farmer 
      ON $tableName($selectedFarmerCode)
    ''');
    
    // Create index for selectedTownCode
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_town 
      ON $tableName($selectedTownCode)
    ''');
  }

  /// Creates the necessary triggers for the table
  static Future<void> createTriggers(Database db) async {
    // Create trigger to update timestamps and sync status
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_trigger
      AFTER UPDATE ON $tableName
      BEGIN
          UPDATE $tableName 
          SET 
              $updated_at = datetime('now'),
              $is_synced = 0
          WHERE $id = NEW.$id;
      END;
    ''');
  }

  /// Handles database upgrades for this table
  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS $tableName');
      await createTable(db);
      await createTriggers(db);
    }
  }

  /// Prepares cover page data for insertion
  static Map<String, dynamic> prepareCoverPageData(CoverPageData data) {
    final now = DateTime.now().toIso8601String();
    return {
      selectedTownCode: data.selectedTownCode,
      selectedFarmerCode: data.selectedFarmerCode,
      towns: jsonEncode(data.towns.map((e) => e.toMap()).toList()),
      farmers: jsonEncode(data.farmers.map((e) => e.toMap()).toList()),
      townError: data.townError,
      farmerError: data.farmerError,
      isLoadingTowns: data.isLoadingTowns ? 1 : 0,
      isLoadingFarmers: data.isLoadingFarmers ? 1 : 0,
      hasUnsavedChanges: data.hasUnsavedChanges ? 1 : 0,
      member: data.member != null ? jsonEncode(data.member) : null,
      created_at: now,
      updated_at: now,
      is_synced: 0,
    };
  }
  
  /// Creates a CoverPageData from a database row
  static CoverPageData fromMap(Map<String, dynamic> map) {
    return CoverPageData(
      id: map[id],
      selectedTownCode: map[selectedTownCode],
      selectedFarmerCode: map[selectedFarmerCode],
      towns: map[towns] != null 
          ? (jsonDecode(map[towns]) as List)
              .map((e) => DropdownItem.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      farmers: map[farmers] != null
          ? (jsonDecode(map[farmers]) as List)
              .map((e) => DropdownItem.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      townError: map[townError],
      farmerError: map[farmerError],
      isLoadingTowns: map[isLoadingTowns] == 1,
      isLoadingFarmers: map[isLoadingFarmers] == 1,
      hasUnsavedChanges: map[hasUnsavedChanges] == 1,
      member: map[member] != null ? Map<String, dynamic>.from(jsonDecode(map[member])) : null,
    );
  }

  /// Validates cover page data before saving
  static bool validateCoverPageData(Map<String, dynamic> data) {
    return data[selectedTownCode] != null &&
        data[selectedFarmerCode] != null;
  }
}

class VisitInformationTable {
  static const String tableName = 'visit_information';

  // Primary key
  static const String id = 'id';

  // Foreign key to combined_farmer_identification
  static const String combinedFarmerId = 'combined_farmer_id';

  // Form fields
  static const String respondentNameCorrect = 'respondent_name_correct';
  static const String respondentNationality = 'respondent_nationality';
  static const String countryOfOrigin = 'country_of_origin';
  static const String isFarmOwner = 'is_farm_owner';
  static const String farmOwnershipType = 'farm_ownership_type';
  static const String correctedRespondentName = 'corrected_respondent_name';
  static const String respondentOtherNames = 'respondent_other_names';
  static const String otherCountry = 'other_country';

  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';

  /// Creates the visit information table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $combinedFarmerId INTEGER NOT NULL,
        $respondentNameCorrect TEXT,
        $respondentNationality TEXT,
        $countryOfOrigin TEXT,
        $isFarmOwner TEXT,
        $farmOwnershipType TEXT,
        $correctedRespondentName TEXT NOT NULL DEFAULT '',
        $respondentOtherNames TEXT NOT NULL DEFAULT '',
        $otherCountry TEXT NOT NULL DEFAULT '',
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        FOREIGN KEY ($combinedFarmerId) REFERENCES ${TableNames.combinedFarmIdentificationTBL}(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Converts a VisitInformationData to a database map
  static Map<String, dynamic> toMap(
      VisitInformationData data, int combinedFarmerId) {
    return {
      VisitInformationTable.combinedFarmerId: combinedFarmerId,
      VisitInformationTable.respondentNameCorrect: data.respondentNameCorrect,
      VisitInformationTable.respondentNationality: data.respondentNationality,
      VisitInformationTable.countryOfOrigin: data.countryOfOrigin,
      VisitInformationTable.isFarmOwner: data.isFarmOwner,
      VisitInformationTable.farmOwnershipType: data.farmOwnershipType,
      VisitInformationTable.correctedRespondentName:
          data.correctedRespondentName,
      VisitInformationTable.respondentOtherNames: data.respondentOtherNames,
      VisitInformationTable.otherCountry: data.otherCountry,
      VisitInformationTable.createdAt: DateTime.now().toIso8601String(),
      VisitInformationTable.updatedAt: DateTime.now().toIso8601String(),
      VisitInformationTable.isSynced: 0,
    };
  }

  /// Creates a VisitInformationData from a database row
  static VisitInformationData fromMap(Map<String, dynamic> map) {
    return VisitInformationData(
      respondentNameCorrect: map[respondentNameCorrect],
      respondentNationality: map[respondentNationality],
      countryOfOrigin: map[countryOfOrigin],
      isFarmOwner: map[isFarmOwner],
      farmOwnershipType: map[farmOwnershipType],
      correctedRespondentName: map[correctedRespondentName] ?? '',
      respondentOtherNames: map[respondentOtherNames] ?? '',
      otherCountry: map[otherCountry] ?? '',
    );
  }
}

class IdentificationOfOwnerTable {
  static const String tableName = 'identification_of_owner';

  // Primary key
  static const String id = 'id';

  // Foreign key to combined_farmer_identification
  static const String combinedFarmerId = 'combined_farmer_id';

  // Form fields
  static const String ownerName = 'owner_name';
  static const String ownerFirstName = 'owner_first_name';
  static const String nationality = 'nationality';
  static const String specificNationality = 'specific_nationality';
  static const String otherNationality = 'other_nationality';
  static const String yearsWithOwner = 'years_with_owner';

  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';

  /// Creates the identification of owner table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $combinedFarmerId INTEGER NOT NULL,
        $ownerName TEXT NOT NULL DEFAULT '',
        $ownerFirstName TEXT NOT NULL DEFAULT '',
        $nationality TEXT,
        $specificNationality TEXT,
        $otherNationality TEXT NOT NULL DEFAULT '',
        $yearsWithOwner TEXT NOT NULL DEFAULT '',
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        FOREIGN KEY ($combinedFarmerId) REFERENCES ${TableNames.combinedFarmIdentificationTBL}(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Converts an IdentificationOfOwnerData to a database map
  static Map<String, dynamic> toMap(
      IdentificationOfOwnerData data, int combinedFarmerId) {
    return {
      IdentificationOfOwnerTable.combinedFarmerId: combinedFarmerId,
      IdentificationOfOwnerTable.ownerName: data.ownerName,
      IdentificationOfOwnerTable.ownerFirstName: data.ownerFirstName,
      IdentificationOfOwnerTable.nationality: data.nationality,
      IdentificationOfOwnerTable.specificNationality: data.specificNationality,
      IdentificationOfOwnerTable.otherNationality: data.otherNationality,
      IdentificationOfOwnerTable.yearsWithOwner: data.yearsWithOwner,
      IdentificationOfOwnerTable.createdAt: DateTime.now().toIso8601String(),
      IdentificationOfOwnerTable.updatedAt: DateTime.now().toIso8601String(),
      IdentificationOfOwnerTable.isSynced: 0,
    };
  }

  /// Creates an IdentificationOfOwnerData from a database row
  static IdentificationOfOwnerData fromMap(Map<String, dynamic> map) {
    return IdentificationOfOwnerData(
      ownerName: map[ownerName] ?? '',
      ownerFirstName: map[ownerFirstName] ?? '',
      nationality: map[nationality],
      specificNationality: map[specificNationality],
      otherNationality: map[otherNationality] ?? '',
      yearsWithOwner: map[yearsWithOwner] ?? '',
    );
  }
}

class WorkersInFarmTable {
  static const String tableName = 'workers_in_farm';

  // Primary key
  static const String id = 'id';

  // Foreign key to combined_farmer_identification
  static const String combinedFarmerId = 'combined_farmer_id';

  // Form fields
  static const String hasRecruitedWorker = 'has_recruited_worker';
  static const String everRecruitedWorker = 'ever_recruited_worker';
  static const String workerAgreementType = 'worker_agreement_type';
  static const String tasksClarified = 'tasks_clarified';
  static const String additionalTasks = 'additional_tasks';
  static const String refusalAction = 'refusal_action';
  static const String salaryPaymentFrequency = 'salary_payment_frequency';
  static const String permanentLabor = 'permanent_labor';
  static const String casualLabor = 'casual_labor';
  static const String otherAgreement = 'other_agreement';
  static const String agreementResponses = 'agreement_responses';

  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';

  /// Creates the workers in farm table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $combinedFarmerId INTEGER NOT NULL,
        $hasRecruitedWorker TEXT,
        $everRecruitedWorker TEXT,
        $workerAgreementType TEXT,
        $tasksClarified TEXT,
        $additionalTasks TEXT,
        $refusalAction TEXT,
        $salaryPaymentFrequency TEXT,
        $permanentLabor INTEGER DEFAULT 0,
        $casualLabor INTEGER DEFAULT 0,
        $otherAgreement TEXT NOT NULL DEFAULT '',
        $agreementResponses TEXT NOT NULL DEFAULT '{}',
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        FOREIGN KEY ($combinedFarmerId) REFERENCES ${TableNames.combinedFarmIdentificationTBL}(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Converts a WorkersInFarmData to a database map
  static Map<String, dynamic> toMap(
      WorkersInFarmData data, int combinedFarmerId) {
    return {
      WorkersInFarmTable.combinedFarmerId: combinedFarmerId,
      WorkersInFarmTable.hasRecruitedWorker: data.hasRecruitedWorker,
      WorkersInFarmTable.everRecruitedWorker: data.everRecruitedWorker,
      WorkersInFarmTable.workerAgreementType: data.workerAgreementType,
      WorkersInFarmTable.tasksClarified: data.tasksClarified,
      WorkersInFarmTable.additionalTasks: data.additionalTasks,
      WorkersInFarmTable.refusalAction: data.refusalAction,
      WorkersInFarmTable.salaryPaymentFrequency: data.salaryPaymentFrequency,
      WorkersInFarmTable.permanentLabor: data.permanentLabor ? 1 : 0,
      WorkersInFarmTable.casualLabor: data.casualLabor ? 1 : 0,
      WorkersInFarmTable.otherAgreement: data.otherAgreement,
      WorkersInFarmTable.agreementResponses:
          jsonEncode(data.agreementResponses),
      WorkersInFarmTable.createdAt: DateTime.now().toIso8601String(),
      WorkersInFarmTable.updatedAt: DateTime.now().toIso8601String(),
      WorkersInFarmTable.isSynced: 0,
    };
  }

  /// Creates a WorkersInFarmData from a database row
  static WorkersInFarmData fromMap(Map<String, dynamic> map) {
    final agreementResponses = map['agreementResponses'] != null &&
            map['agreementResponses'].isNotEmpty
        ? Map<String, String?>.from(jsonDecode(map['agreementResponses']))
        : <String, String?>{};

    // Ensure all response keys exist with null values if not present
    final defaultResponses = <String, String?>{
      'salary_workers': null,
      'recruit_1': null,
      'recruit_2': null,
      'recruit_3': null,
      'conditions_1': null,
      'conditions_2': null,
      'conditions_3': null,
      'conditions_4': null,
      'conditions_5': null,
      'leaving_1': null,
      'leaving_2': null,
    }..addAll(agreementResponses);

    return WorkersInFarmData(
      hasRecruitedWorker: map[hasRecruitedWorker],
      everRecruitedWorker: map[everRecruitedWorker],
      workerAgreementType: map[workerAgreementType],
      tasksClarified: map[tasksClarified],
      additionalTasks: map[additionalTasks],
      refusalAction: map[refusalAction],
      salaryPaymentFrequency: map[salaryPaymentFrequency],
      permanentLabor: map[permanentLabor] == 1,
      casualLabor: map[casualLabor] == 1,
      otherAgreement: map[otherAgreement] ?? '',
      agreementResponses: defaultResponses,
    );
  }
}

class AdultsInformationTable {
  static const String tableName = 'adults_information';

  // Primary key
  static const String id = 'id';

  // Foreign key to combined_farmer_identification
  static const String combinedFarmerId = 'combined_farmer_id';

  // Form fields
  static const String numberOfAdults = 'number_of_adults';
  static const String members = 'members';

  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';

  /// Creates the adults information table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $combinedFarmerId INTEGER NOT NULL,
        $numberOfAdults INTEGER,
        $members TEXT NOT NULL,
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        FOREIGN KEY ($combinedFarmerId) REFERENCES ${TableNames.combinedFarmIdentificationTBL}(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Converts an AdultsInformationData to a database map
  static Map<String, dynamic> toMap(
      AdultsInformationData data, int combinedFarmerId) {
    return {
      AdultsInformationTable.combinedFarmerId: combinedFarmerId,
      AdultsInformationTable.numberOfAdults: data.numberOfAdults,
      AdultsInformationTable.members: jsonEncode(
        data.members.map((member) => member.toJson()).toList(),
      ),
      AdultsInformationTable.createdAt: DateTime.now().toIso8601String(),
      AdultsInformationTable.updatedAt: DateTime.now().toIso8601String(),
      AdultsInformationTable.isSynced: 0,
    };
  }

  /// Creates an AdultsInformationData from a database row
  static AdultsInformationData fromMap(Map<String, dynamic> map) {
    final membersJson = map[members] as String? ?? '[]';
    final membersList = (jsonDecode(membersJson) as List<dynamic>? ?? [])
        .map((e) => HouseholdMember.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return AdultsInformationData(
      numberOfAdults: map[numberOfAdults],
      members: membersList,
    );
  }

  /// Drops the table
  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }
}

class ChildrenHouseholdTable {
  static const String tableName = TableNames.childrenHouseholdTBL;

  // Primary key
  static const String id = 'id';

  // Foreign keys - UPDATED: Only cover_page_id
  static const String coverPageId = 'cover_page_id';

  // Fields
  static const String hasChildrenInHousehold = 'has_children_in_household';
  static const String numberOfChildren = 'number_of_children';
  static const String children5To17 = 'children_5_to_17';
  static const String childrenDetails = 'children_details'; // JSON string

  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the children household table - UPDATED: Only cover_page_id
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $coverPageId INTEGER NOT NULL,
        $hasChildrenInHousehold TEXT,
        $numberOfChildren INTEGER DEFAULT 0,
        $children5To17 INTEGER DEFAULT 0,
        $childrenDetails TEXT,
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        $syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY ($coverPageId) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
      )
    ''');

    await _createTriggers(db);
  }

  /// Creates database triggers for the table
  static Future<void> _createTriggers(Database db) async {
    // Create trigger to update timestamps and sync status
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_timestamps
      AFTER UPDATE ON $tableName
      FOR EACH ROW
      BEGIN
        UPDATE $tableName 
        SET $updatedAt = datetime('now'),
            $isSynced = 0,
            $syncStatus = 0
        WHERE $id = NEW.$id;
      END;
    ''');

    // Create trigger for insert to set created_at and updated_at
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS set_${tableName}_timestamps
      AFTER INSERT ON $tableName
      BEGIN
        UPDATE $tableName 
        SET $createdAt = datetime('now'),
            $updatedAt = datetime('now')
        WHERE $id = NEW.$id;
      END;
    ''');
  }

  /// Drops the table
  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Returns a map of all columns and their types
  static Map<String, String> get columns => {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        coverPageId: 'INTEGER NOT NULL',
        hasChildrenInHousehold: 'TEXT',
        numberOfChildren: 'INTEGER DEFAULT 0',
        children5To17: 'INTEGER DEFAULT 0',
        childrenDetails: 'TEXT',
        createdAt: 'TEXT NOT NULL',
        updatedAt: 'TEXT NOT NULL',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        coverPageId,
        hasChildrenInHousehold,
        numberOfChildren,
        children5To17,
        childrenDetails,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        coverPageId,
        hasChildrenInHousehold,
        numberOfChildren,
        children5To17,
        childrenDetails,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        hasChildrenInHousehold,
        numberOfChildren,
        children5To17,
        childrenDetails,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Converts model data to database map - UPDATED: Only cover_page_id
  static Map<String, dynamic> toMap({
    required int coverPageId,
    String? hasChildrenInHousehold,
    int numberOfChildren = 0,
    int children5To17 = 0,
    String? childrenDetails,
  }) {
    final now = DateTime.now().toIso8601String();
    return {
      ChildrenHouseholdTable.coverPageId: coverPageId,
      ChildrenHouseholdTable.hasChildrenInHousehold: hasChildrenInHousehold,
      ChildrenHouseholdTable.numberOfChildren: numberOfChildren,
      ChildrenHouseholdTable.children5To17: children5To17,
      ChildrenHouseholdTable.childrenDetails: childrenDetails,
      ChildrenHouseholdTable.createdAt: now,
      ChildrenHouseholdTable.updatedAt: now,
      ChildrenHouseholdTable.isSynced: 0,
      ChildrenHouseholdTable.syncStatus: 0,
    }..removeWhere((key, value) => value == null);
  }

  /// Creates model data from database row - UPDATED: Only cover_page_id
  static Map<String, dynamic> fromMap(Map<String, dynamic> map) {
    return {
      'id': map[ChildrenHouseholdTable.id],
      'cover_page_id': map[ChildrenHouseholdTable.coverPageId],
      'has_children_in_household':
          map[ChildrenHouseholdTable.hasChildrenInHousehold],
      'number_of_children': map[ChildrenHouseholdTable.numberOfChildren] ?? 0,
      'children_5_to_17': map[ChildrenHouseholdTable.children5To17] ?? 0,
      'children_details': map[ChildrenHouseholdTable.childrenDetails],
      'created_at': map[ChildrenHouseholdTable.createdAt],
      'updated_at': map[ChildrenHouseholdTable.updatedAt],
      'is_synced': map[ChildrenHouseholdTable.isSynced] ?? 0,
      'sync_status': map[ChildrenHouseholdTable.syncStatus] ?? 0,
    };
  }
}

class RemediationTable {
  static const String tableName = TableNames.remediationTBL;

  // Primary key
  static const String id = 'id';

  // Foreign keys - UPDATED: Only cover_page_id
  static const String coverPageId = 'cover_page_id';

  // School Fees Information
  static const String hasSchoolFees = 'has_school_fees';

  // Support Options
  static const String childProtectionEducation = 'child_protection_education';
  static const String schoolKitsSupport = 'school_kits_support';
  static const String igaSupport = 'iga_support';
  static const String otherSupport = 'other_support';
  static const String otherSupportDetails = 'other_support_details';

  // Community Action
  static const String communityAction = 'community_action';
  static const String otherCommunityActionDetails = 'other_community_action_details';

  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the remediation table with updated schema - UPDATED: Only cover_page_id
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $coverPageId INTEGER NOT NULL,
        $hasSchoolFees INTEGER,
        $childProtectionEducation INTEGER DEFAULT 0,
        $schoolKitsSupport INTEGER DEFAULT 0,
        $igaSupport INTEGER DEFAULT 0,
        $otherSupport INTEGER DEFAULT 0,
        $otherSupportDetails TEXT,
        $communityAction TEXT,
        $otherCommunityActionDetails TEXT,
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        $syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY ($coverPageId) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
      )
    ''');

    await _createTriggers(db);
    
    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_cover_page 
      ON $tableName($coverPageId)
    ''');
  }

  /// Creates database triggers for the table
  static Future<void> _createTriggers(Database db) async {
    // Create trigger to update timestamps and sync status
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_timestamps
      AFTER UPDATE ON $tableName
      FOR EACH ROW
      BEGIN
        UPDATE $tableName 
        SET $updatedAt = datetime('now'),
            $isSynced = 0,
            $syncStatus = 0
        WHERE $id = NEW.$id;
      END;
    ''');

    // Create trigger for insert to set created_at and updated_at
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS set_${tableName}_timestamps
      AFTER INSERT ON $tableName
      BEGIN
        UPDATE $tableName 
        SET $createdAt = datetime('now'),
            $updatedAt = datetime('now')
        WHERE $id = NEW.$id;
      END;
    ''');
  }

  /// Drops the table
  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Returns a map of all columns and their types
  static Map<String, String> get columns => {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        coverPageId: 'INTEGER NOT NULL',
        hasSchoolFees: 'INTEGER',
        childProtectionEducation: 'INTEGER DEFAULT 0',
        schoolKitsSupport: 'INTEGER DEFAULT 0',
        igaSupport: 'INTEGER DEFAULT 0',
        otherSupport: 'INTEGER DEFAULT 0',
        otherSupportDetails: 'TEXT',
        communityAction: 'TEXT',
        otherCommunityActionDetails: 'TEXT',
        createdAt: 'TEXT NOT NULL',
        updatedAt: 'TEXT NOT NULL',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        coverPageId,
        hasSchoolFees,
        childProtectionEducation,
        schoolKitsSupport,
        igaSupport,
        otherSupport,
        otherSupportDetails,
        communityAction,
        otherCommunityActionDetails,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        coverPageId,
        hasSchoolFees,
        childProtectionEducation,
        schoolKitsSupport,
        igaSupport,
        otherSupport,
        otherSupportDetails,
        communityAction,
        otherCommunityActionDetails,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        hasSchoolFees,
        childProtectionEducation,
        schoolKitsSupport,
        igaSupport,
        otherSupport,
        otherSupportDetails,
        communityAction,
        otherCommunityActionDetails,
        updatedAt,
        isSynced,
        syncStatus,
      ];
}

class SensitizationTable {
  static const String tableName = TableNames.sensitizationTBL;

  // Primary key
  static const String id = 'id';

  // Fields - UPDATED: Only cover_page_id
  static const String coverPageId = 'cover_page_id';
  static const String isAcknowledged = 'is_acknowledged';
  static const String acknowledgedAt = 'acknowledged_at';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the sensitization table - UPDATED: Only cover_page_id
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $coverPageId INTEGER NOT NULL,
        $isAcknowledged INTEGER DEFAULT 0,
        $acknowledgedAt TEXT,
        $createdAt TEXT,
        $updatedAt TEXT,
        $isSynced INTEGER DEFAULT 0,
        $syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY ($coverPageId) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
      )
    ''');

    await _createTriggers(db);
  }

  /// Creates database triggers for the table
  static Future<void> _createTriggers(Database db) async {
    // Create trigger to update timestamps and sync status
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_timestamps
      AFTER UPDATE ON $tableName
      FOR EACH ROW
      BEGIN
        UPDATE $tableName 
        SET $updatedAt = datetime('now'),
            $isSynced = 0,
            $syncStatus = 0
        WHERE $id = NEW.$id;
      END;
    ''');

    // Create trigger for insert to set created_at and updated_at
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS set_${tableName}_timestamps
      AFTER INSERT ON $tableName
      FOR EACH ROW
      WHEN NEW.$createdAt IS NULL OR NEW.$updatedAt IS NULL
      BEGIN
        UPDATE $tableName 
        SET $createdAt = datetime('now'),
            $updatedAt = datetime('now')
        WHERE $id = NEW.$id;
      END;
    ''');
  }

  /// Drops the table
  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Returns a map of all columns and their types
  static Map<String, String> get columns => {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        coverPageId: 'INTEGER NOT NULL',
        isAcknowledged: 'INTEGER DEFAULT 0',
        acknowledgedAt: 'TEXT',
        createdAt: 'TEXT',
        updatedAt: 'TEXT',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

      

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        coverPageId,
        isAcknowledged,
        acknowledgedAt,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        coverPageId,
        isAcknowledged,
        acknowledgedAt,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        isAcknowledged,
        acknowledgedAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Converts a SensitizationData object to a map for database operations
  static Map<String, dynamic> toMap(SensitizationData data) {
    return {
      id: data.id,
      coverPageId: data.coverPageId,
      isAcknowledged: data.isAcknowledged ? 1 : 0,
      acknowledgedAt: data.acknowledgedAt?.toIso8601String(),
      createdAt: data.createdAt?.toIso8601String(),
      updatedAt: data.updatedAt?.toIso8601String(),
      isSynced: data.isSynced ? 1 : 0,
      syncStatus: data.syncStatus ?? 0,
    };
  }

  /// Creates a SensitizationData object from a database row
  static SensitizationData fromMap(Map<String, dynamic> map) {
    return SensitizationData(
      id: map[id] as int?,
      coverPageId: map[coverPageId] as int,
      isAcknowledged: map[isAcknowledged] == 1,
      acknowledgedAt: map[acknowledgedAt] != null 
          ? DateTime.parse(map[acknowledgedAt] as String) 
          : null,
      createdAt: map[createdAt] != null 
          ? DateTime.parse(map[createdAt] as String) 
          : DateTime.now(),
      updatedAt: map[updatedAt] != null 
          ? DateTime.parse(map[updatedAt] as String) 
          : DateTime.now(),
      isSynced: map[isSynced] == 1,
      syncStatus: map[syncStatus] as int? ?? 0,
    );
  }
}

class SensitizationQuestionsTable {
  static const String tableName = TableNames.sensitizationQuestionsTBL;

  // Primary key
  static const String id = 'id';

  // Foreign keys - UPDATED: Only cover_page_id
  static const String coverPageId = 'cover_page_id';

  // Sensitization status
  static const String hasSensitizedHousehold = 'has_sensitized_household';
  static const String hasSensitizedOnProtection =
      'has_sensitized_on_protection';
  static const String hasSensitizedOnSafeLabour =
      'has_sensitized_on_safe_labour';

  // Attendance
  static const String femaleAdultsCount = 'female_adults_count';
  static const String maleAdultsCount = 'male_adults_count';

  // Consent and media
  static const String consentForPicture = 'consent_for_picture';
  static const String consentReason = 'consent_reason';
  static const String sensitizationImagePath = 'sensitization_image_path';
  static const String householdWithUserImagePath =
      'household_with_user_image_path';

  // Observations
  static const String parentsReaction = 'parents_reaction';

  // Timestamps and sync
  static const String submittedAt = 'submitted_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the sensitization questions table - UPDATED: Only cover_page_id
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $coverPageId INTEGER NOT NULL,
        $hasSensitizedHousehold INTEGER,
        $hasSensitizedOnProtection INTEGER,
        $hasSensitizedOnSafeLabour INTEGER,
        $femaleAdultsCount TEXT,
        $maleAdultsCount TEXT,
        $consentForPicture INTEGER,
        $consentReason TEXT,
        $sensitizationImagePath TEXT,
        $householdWithUserImagePath TEXT,
        $parentsReaction TEXT,
        $submittedAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        $syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY ($coverPageId) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
      )
    ''');

    await _createTriggers(db);
  }

  /// Creates database triggers for the table
  static Future<void> _createTriggers(Database db) async {
    // Create trigger to update timestamps and sync status
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_timestamps
      AFTER UPDATE ON $tableName
      FOR EACH ROW
      BEGIN
        UPDATE $tableName 
        SET $updatedAt = datetime('now'),
            $isSynced = 0,
            $syncStatus = 0
        WHERE $id = NEW.$id;
      END;
    ''');

    // Create trigger for insert to set created_at and updated_at
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS set_${tableName}_timestamps
      AFTER INSERT ON $tableName
      BEGIN
        UPDATE $tableName 
        SET $submittedAt = COALESCE($submittedAt, datetime('now')),
            $updatedAt = datetime('now')
        WHERE $id = NEW.$id;
      END;
    ''');
  }

  /// Drops the table
  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Returns a map of all columns and their types
  static Map<String, String> get columns => {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        coverPageId: 'INTEGER NOT NULL',
        hasSensitizedHousehold: 'INTEGER',
        hasSensitizedOnProtection: 'INTEGER',
        hasSensitizedOnSafeLabour: 'INTEGER',
        femaleAdultsCount: 'TEXT',
        maleAdultsCount: 'TEXT',
        consentForPicture: 'INTEGER',
        consentReason: 'TEXT',
        sensitizationImagePath: 'TEXT',
        householdWithUserImagePath: 'TEXT',
        parentsReaction: 'TEXT',
        submittedAt: 'TEXT NOT NULL',
        updatedAt: 'TEXT NOT NULL',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        coverPageId,
        hasSensitizedHousehold,
        hasSensitizedOnProtection,
        hasSensitizedOnSafeLabour,
        femaleAdultsCount,
        maleAdultsCount,
        consentForPicture,
        consentReason,
        sensitizationImagePath,
        householdWithUserImagePath,
        parentsReaction,
        submittedAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        coverPageId,
        hasSensitizedHousehold,
        hasSensitizedOnProtection,
        hasSensitizedOnSafeLabour,
        femaleAdultsCount,
        maleAdultsCount,
        consentForPicture,
        consentReason,
        sensitizationImagePath,
        householdWithUserImagePath,
        parentsReaction,
        submittedAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        hasSensitizedHousehold,
        hasSensitizedOnProtection,
        hasSensitizedOnSafeLabour,
        femaleAdultsCount,
        maleAdultsCount,
        consentForPicture,
        consentReason,
        sensitizationImagePath,
        householdWithUserImagePath,
        parentsReaction,
        updatedAt,
        isSynced,
        syncStatus,
      ];
}

class EndOfCollectionTable {
  static const String tableName = TableNames.endOfCollectionTBL;

  // Primary key
  static const String id = 'id';

  // Foreign keys - UPDATED: Only cover_page_id
  static const String coverPageId = 'cover_page_id';

  // Image paths
  static const String respondentImagePath = 'respondent_image_path';
  static const String producerSignaturePath = 'producer_signature_path';

  // Location data
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String gpsCoordinates = 'gps_coordinates';

  // Additional information
  static const String remarks = 'remarks';

  // Timestamps and sync
  static const String endTime = 'end_time';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the end of collection table - UPDATED: Only cover_page_id
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $coverPageId INTEGER NOT NULL,
        $respondentImagePath TEXT,
        $producerSignaturePath TEXT,
        $latitude REAL,
        $longitude REAL,
        $gpsCoordinates TEXT,
        $endTime TEXT,
        $remarks TEXT,
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        $syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY ($coverPageId) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
      )
    ''');

    await _createTriggers(db);
  }

  /// Creates database triggers for the table
  static Future<void> _createTriggers(Database db) async {
    // Create trigger to update timestamps and sync status
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_timestamps
      AFTER UPDATE ON $tableName
      FOR EACH ROW
      BEGIN
        UPDATE $tableName 
        SET $updatedAt = datetime('now'),
            $isSynced = 0,
            $syncStatus = 0
        WHERE $id = NEW.$id;
      END;
    ''');

    // Create trigger for insert to set created_at and updated_at
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS set_${tableName}_timestamps
      AFTER INSERT ON $tableName
      BEGIN
        UPDATE $tableName 
        SET $createdAt = COALESCE($createdAt, datetime('now')),
            $updatedAt = datetime('now')
        WHERE $id = NEW.$id;
      END;
    ''');
  }

  /// Drops the table
  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Returns a map of all columns and their types
  static Map<String, String> get columns => {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        coverPageId: 'INTEGER NOT NULL',
        respondentImagePath: 'TEXT',
        producerSignaturePath: 'TEXT',
        latitude: 'REAL',
        longitude: 'REAL',
        gpsCoordinates: 'TEXT',
        endTime: 'TEXT',
        remarks: 'TEXT',
        createdAt: 'TEXT NOT NULL',
        updatedAt: 'TEXT NOT NULL',
        isSynced: 'INTEGER DEFAULT 0',
        syncStatus: 'INTEGER DEFAULT 0',
      };

  /// Returns a list of all column names
  static List<String> get allColumns => [
        id,
        coverPageId,
        respondentImagePath,
        producerSignaturePath,
        latitude,
        longitude,
        gpsCoordinates,
        endTime,
        remarks,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns without the ID (for inserts)
  static List<String> get insertableColumns => [
        coverPageId,
        respondentImagePath,
        producerSignaturePath,
        latitude,
        longitude,
        gpsCoordinates,
        endTime,
        remarks,
        createdAt,
        updatedAt,
        isSynced,
        syncStatus,
      ];

  /// Returns a list of columns that can be updated
  static List<String> get updatableColumns => [
        respondentImagePath,
        producerSignaturePath,
        latitude,
        longitude,
        gpsCoordinates,
        endTime,
        remarks,
        updatedAt,
        isSynced,
        syncStatus,
      ];
}

class CombinedFarmerIdentificationTable {
  static const String tableName = TableNames.combinedFarmIdentificationTBL;

  // Primary key
  static const String id = 'id';

  // Foreign keys - UPDATED: Only cover_page_id
  static const String coverPageId = 'cover_page_id';

  // Form data columns (kept for backward compatibility)
  static const String visitInformation = 'visit_information';
  static const String ownerInformation = 'owner_information';
  static const String workersInFarm = 'workers_in_farm';
  static const String adultsInformation = 'adults_information';

  // Timestamps and sync
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  /// Creates the combined farmer identification table - UPDATED: Only cover_page_id
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $coverPageId INTEGER NOT NULL,
        $visitInformation TEXT,
        $ownerInformation TEXT,
        $workersInFarm TEXT,
        $adultsInformation TEXT,
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        $syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY ($coverPageId) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
      )
    ''');

    // Create all related tables
    await Future.wait([
      VisitInformationTable.createTable(db),
      IdentificationOfOwnerTable.createTable(db),
      WorkersInFarmTable.createTable(db),
      AdultsInformationTable.createTable(db),
      ChildrenHouseholdTable.createTable(db),
    ]);

    await _createTriggers(db);
  }

  /// Creates database triggers for the table
  static Future<void> _createTriggers(Database db) async {
    // Create triggers for automatic timestamps
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_updated_at
      AFTER UPDATE ON $tableName
      BEGIN
        UPDATE $tableName 
        SET $updatedAt = '${DateTime.now().toIso8601String()}' 
        WHERE $id = NEW.$id;
      END;
    ''');

    // Create trigger for visit information table
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${VisitInformationTable.tableName}_updated_at
      AFTER UPDATE ON ${VisitInformationTable.tableName}
      BEGIN
        UPDATE ${VisitInformationTable.tableName}
        SET ${VisitInformationTable.updatedAt} = '${DateTime.now().toIso8601String()}'
        WHERE ${VisitInformationTable.id} = NEW.${VisitInformationTable.id};
      END;
    ''');

    // Create trigger for identification of owner table
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${IdentificationOfOwnerTable.tableName}_updated_at
      AFTER UPDATE ON ${IdentificationOfOwnerTable.tableName}
      BEGIN
        UPDATE ${IdentificationOfOwnerTable.tableName}
        SET ${IdentificationOfOwnerTable.updatedAt} = '${DateTime.now().toIso8601String()}'
        WHERE ${IdentificationOfOwnerTable.id} = NEW.${IdentificationOfOwnerTable.id};
      END;
    ''');

    // Create trigger for workers in farm table
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${WorkersInFarmTable.tableName}_updated_at
      AFTER UPDATE ON ${WorkersInFarmTable.tableName}
      BEGIN
        UPDATE ${WorkersInFarmTable.tableName}
        SET ${WorkersInFarmTable.updatedAt} = '${DateTime.now().toIso8601String()}'
        WHERE ${WorkersInFarmTable.id} = NEW.${WorkersInFarmTable.id};
      END;
    ''');

    // Create trigger for adults information table
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${AdultsInformationTable.tableName}_updated_at
      AFTER UPDATE ON ${AdultsInformationTable.tableName}
      BEGIN
        UPDATE ${AdultsInformationTable.tableName}
        SET ${AdultsInformationTable.updatedAt} = '${DateTime.now().toIso8601String()}'
        WHERE ${AdultsInformationTable.id} = NEW.${AdultsInformationTable.id};
      END;
    ''');

    // Create trigger for children household table
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${ChildrenHouseholdTable.tableName}_updated_at
      AFTER UPDATE ON ${ChildrenHouseholdTable.tableName}
      BEGIN
        UPDATE ${ChildrenHouseholdTable.tableName}
        SET ${ChildrenHouseholdTable.updatedAt} = '${DateTime.now().toIso8601String()}'
        WHERE ${ChildrenHouseholdTable.id} = NEW.${ChildrenHouseholdTable.id};
      END;
    ''');

    // Create trigger for setting timestamps on insert
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS set_${tableName}_timestamps
      AFTER INSERT ON $tableName
      BEGIN
        UPDATE $tableName 
        SET $createdAt = datetime('now'),
            $updatedAt = datetime('now')
        WHERE $id = NEW.$id;
      END;
    ''');
  }

  /// Drops the table
  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  /// Extension to convert between model and database map
  static Map<String, dynamic> toMap(CombinedFarmerIdentificationModel model) {
    return {
      'id': model.id,
      'cover_page_id': model.coverPageId,
      'visit_information': model.visitInformation?.toJson(),
      'owner_information': model.ownerInformation?.toJson(),
      'workers_in_farm': model.workersInFarm?.toJson(),
      'adults_information': model.adultsInformation?.toJson(),
      'created_at': model.createdAt?.toIso8601String(),
      'updated_at': model.updatedAt?.toIso8601String(),
      'is_synced': model.isSynced ? 1 : 0,
      'sync_status': model.syncStatus ?? 0,
    }..removeWhere((key, value) => value == null);
  }

  /// Creates a CombinedFarmerIdentificationModel from a database row
  static CombinedFarmerIdentificationModel fromMap(Map<String, dynamic> map) {
    return CombinedFarmerIdentificationModel(
      id: map['id'] as int?,
      coverPageId: map['cover_page_id'] as int?,
      visitInformation: map['visit_information'] != null
          ? VisitInformationData.fromJson(
              Map<String, dynamic>.from(map['visit_information'] as Map))
          : null,
      ownerInformation: map['owner_information'] != null
          ? IdentificationOfOwnerData.fromJson(
              Map<String, dynamic>.from(map['owner_information'] as Map))
          : null,
      workersInFarm: map['workers_in_farm'] != null
          ? WorkersInFarmData.fromJson(
              Map<String, dynamic>.from(map['workers_in_farm'] as Map))
          : null,
      adultsInformation: map['adults_information'] != null
          ? AdultsInformationData.fromJson(
              Map<String, dynamic>.from(map['adults_information'] as Map))
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      isSynced: map['is_synced'] == 1,
      syncStatus: map['sync_status'] as int?,
    );
  }
}

class ConsentTable {
  static const String tableName = TableNames.consentTBL;

  // Column names as static constants
  static const String id = 'id';
  static const String coverPageId = 'cover_page_id';

  // Consent Information
  static const String consentGiven = 'consent_given';
  static const String declinedConsent = 'declined_consent';
  static const String refusalReason = 'refusal_reason';
  static const String consentTimestamp = 'consent_timestamp';

  // Community and Farmer Information
  static const String communityType = 'community_type';
  static const String residesInCommunityConsent =
      'resides_in_community_consent';
  static const String otherCommunityName = 'other_community_name';
  static const String farmerAvailable = 'farmer_available';
  static const String farmerStatus = 'farmer_status';
  static const String availablePerson = 'available_person';
  static const String otherSpecification = 'other_specification';

  // Location and Timing
  static const String interviewStartTime = 'interview_start_time';
  static const String timeStatus = 'time_status';
  static const String currentPositionLat = 'current_position_lat';
  static const String currentPositionLng = 'current_position_lng';
  static const String locationStatus = 'location_status';
  static const String isGettingLocation = 'is_getting_location';

  // Metadata
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';

  /// Creates the consent table
  static Future<void> createTable(Database db) async {
    try {
      debugPrint('🔄 Ensuring table $tableName exists...');
      
      // First, check if the table already exists
      final existingTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]
      );
      
      if (existingTables.isNotEmpty) {
        debugPrint('  • Table $tableName already exists, dropping it first...');
        await db.execute('DROP TABLE IF EXISTS $tableName');
      }
      
      // Create the table with the new schema
      debugPrint('  • Creating table $tableName with latest schema...');
      await db.execute('''
        CREATE TABLE $tableName (
          $id INTEGER PRIMARY KEY AUTOINCREMENT,
          $coverPageId INTEGER NOT NULL,
          $consentGiven INTEGER NOT NULL DEFAULT 0,
          $declinedConsent INTEGER NOT NULL DEFAULT 0,
          $refusalReason TEXT,
          $consentTimestamp TEXT,
          $communityType TEXT,
          $residesInCommunityConsent TEXT,
          $otherCommunityName TEXT,
          $farmerAvailable TEXT,
          $farmerStatus TEXT,
          $availablePerson TEXT,
          $otherSpecification TEXT,
          $interviewStartTime TEXT,
          $timeStatus TEXT,
          $currentPositionLat REAL,
          $currentPositionLng REAL,
          $locationStatus TEXT,
          $isGettingLocation INTEGER NOT NULL DEFAULT 0,
          $createdAt TEXT NOT NULL,
          $updatedAt TEXT NOT NULL,
          $isSynced INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY ($coverPageId) REFERENCES ${TableNames.coverPageTBL}($id) ON DELETE CASCADE
        )
      ''');

      // Verify the table was created
      final createdTables = await db.rawQuery(
        'SELECT name, sql FROM sqlite_master WHERE type="table" AND name=?', 
        [tableName]
      );
      
      if (createdTables.isEmpty) {
        throw Exception('Failed to create table $tableName');
      }
      
      debugPrint('✅ Successfully created table $tableName');
      
      // Create indexes for better performance
      debugPrint('  • Creating indexes...');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_${tableName}_sync 
        ON $tableName($isSynced)
      ''');
      
      debugPrint('✅ Successfully created indexes for table: $tableName');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating table $tableName: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Try to get more detailed error information
      try {
        final tables = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
        debugPrint('📋 Existing tables:');
        for (var table in tables) {
          debugPrint('  - ${table['name']}');
        }
      } catch (e) {
        debugPrint('❌ Error listing tables: $e');
      }
      
      rethrow;
    }
  }

  /// Creates the necessary triggers for the table
  static Future<void> createTriggers(Database db) async {
    try {
      debugPrint('🔄 Creating triggers for table: $tableName');
      
      // Drop existing trigger if it exists
      await db.execute('DROP TRIGGER IF EXISTS update_${tableName}_trigger');
      
      // Create trigger to update timestamps and sync status
      await db.execute('''
        CREATE TRIGGER IF NOT EXISTS update_${tableName}_trigger
        AFTER UPDATE ON $tableName
        BEGIN
            UPDATE $tableName 
            SET 
                $updatedAt = datetime('now'),
                $isSynced = 0
            WHERE $id = NEW.$id;
        END;
      ''');
      
      debugPrint('✅ Successfully created triggers for table: $tableName');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating triggers for table $tableName: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Handles database upgrades for this table
  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Upgrading $tableName from version $oldVersion to $newVersion');
    
    try {
      if (oldVersion < 2) {
        debugPrint('  • Migrating to version 2...');
        
        // First, check if the table exists
        final tableExists = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type="table" AND name="$tableName"'
        );
        
        if (tableExists.isNotEmpty) {
          debugPrint('  • Table exists, dropping and recreating...');
          await db.execute('DROP TABLE IF EXISTS $tableName');
        }
        
        // Create the table with the latest schema
        await createTable(db);
        await createTriggers(db);
        
        debugPrint('✅ Successfully upgraded $tableName to version 2');
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error upgrading $tableName: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Prepares consent data for insertion or update
  static Map<String, dynamic> prepareData(ConsentData data) {
    return data.toMap();
  }

  /// Converts database map to ConsentData object
  static ConsentData fromMap(Map<String, dynamic> map) {
    return ConsentData(
      id: map[id] as int?,
      communityType: map[communityType]?.toString(),
      residesInCommunityConsent: map[residesInCommunityConsent]?.toString(),
      farmerAvailable: map[farmerAvailable]?.toString(),
      farmerStatus: map[farmerStatus]?.toString(),
      availablePerson: map[availablePerson]?.toString(),
      otherSpecification: map[otherSpecification]?.toString(),
      otherCommunityName: map[otherCommunityName]?.toString(),
      refusalReason: map[refusalReason]?.toString(),
      consentGiven: map[consentGiven] == 1,
      declinedConsent: map[declinedConsent] == 1,
      consentTimestamp: map[consentTimestamp] != null
          ? DateTime.parse(map[consentTimestamp] as String)
          : null,
      otherSpecController: TextEditingController(
          text: map[otherSpecification]?.toString() ?? ''),
      otherCommunityController: TextEditingController(
          text: map[otherCommunityName]?.toString() ?? ''),
      refusalReasonController:
          TextEditingController(text: map[refusalReason]?.toString() ?? ''),
      interviewStartTime: map[interviewStartTime] != null
          ? DateTime.parse(map[interviewStartTime] as String)
          : null,
      timeStatus: map[timeStatus]?.toString(),
      currentPosition:
          map[currentPositionLat] != null && map[currentPositionLng] != null
              ? Position(
                  latitude: (map[currentPositionLat] as num).toDouble(),
                  longitude: (map[currentPositionLng] as num).toDouble(),
                  timestamp: DateTime.now(),
                  accuracy: 0.0,
                  altitude: 0.0,
                  heading: 0.0,
                  speed: 0.0,
                  speedAccuracy: 0.0,
                  altitudeAccuracy: 0.0,
                  headingAccuracy: 0.0,
                )
              : null,
      locationStatus: map[locationStatus]?.toString(),
      isGettingLocation: map[isGettingLocation] == 1,
    );
  }
}

class FarmerIdentificationTable {
  static const String tableName = TableNames.farmerIdentificationTBL;

  // Column names in snake_case for SQLite
  static const String id = 'id';
  static const String coverPageId = 'cover_page_id';
  static const String hasGhanaCard = 'has_ghana_card';
  static const String ghanaCardNumber = 'ghana_card_number';
  static const String selectedIdType = 'selected_id_type';
  static const String idNumber = 'id_number';
  static const String idPictureConsent = 'id_picture_consent';
  static const String noConsentReason = 'no_consent_reason';
  static const String idImagePath = 'id_image_path';
  static const String contactNumber = 'contact_number';
  static const String childrenCount = 'children_count';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String isSynced = 'is_synced';
  static const String syncStatus = 'sync_status';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $coverPageId INTEGER NOT NULL,
        $hasGhanaCard INTEGER DEFAULT 0,
        $ghanaCardNumber TEXT,
        $selectedIdType TEXT,
        $idNumber TEXT,
        $idPictureConsent INTEGER DEFAULT 0,
        $noConsentReason TEXT,
        $idImagePath TEXT,
        $contactNumber TEXT,
        $childrenCount INTEGER DEFAULT 0,
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER DEFAULT 0,
        $syncStatus INTEGER DEFAULT 0,
        FOREIGN KEY ($coverPageId) REFERENCES ${TableNames.coverPageTBL}(id) ON DELETE CASCADE
      )
    ''');

    await _createTriggers(db);
  }

  static Future<void> _createTriggers(Database db) async {
    // Create trigger to update timestamps and sync status
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_trigger
      AFTER UPDATE ON $tableName
      BEGIN
          UPDATE $tableName 
          SET 
              $updatedAt = datetime('now'),
              $isSynced = 0,
              $syncStatus = 0
          WHERE $id = NEW.$id;
      END;
    ''');
  }

  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      try {
        // Drop any existing triggers first
        await db.execute('DROP TRIGGER IF EXISTS update_${tableName}_trigger');

        // Check if we need to migrate from old schema
        final oldTableInfo = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='farmer_identification_table'");

        if (oldTableInfo.isNotEmpty) {
          // Get all columns from old table
          final oldColumns = await db
              .rawQuery('PRAGMA table_info(farmer_identification_table)');
          final columnMap = <String, String>{};

          // Map column names to their types for the migration
          for (var column in oldColumns) {
            final name = column['name'] as String;
            columnMap[name.toLowerCase()] =
                name; // Store original case for reference
          }

          // Create a safe column reference
          String safeColumn(String name, {String defaultValue = 'NULL'}) {
            final lowerName = name.toLowerCase();
            if (columnMap.containsKey(lowerName)) {
              return '"' +
                  columnMap[lowerName]! +
                  '"'; // Use original case in quotes
            }
            return defaultValue;
          }

          // Create a new temporary table with the new schema
          await db.execute('''
            CREATE TABLE ${tableName}_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cover_page_id INTEGER NOT NULL,
              has_ghana_card INTEGER DEFAULT 0,
              ghana_card_number TEXT,
              selected_id_type TEXT,
              id_number TEXT,
              id_picture_consent INTEGER DEFAULT 0,
              no_consent_reason TEXT,
              id_image_path TEXT,
              contact_number TEXT,
              children_count INTEGER DEFAULT 0,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              is_synced INTEGER DEFAULT 0,
              sync_status INTEGER DEFAULT 0
            )
          ''');

          // Migrate data with safe column references
          await db.execute('''
            INSERT INTO ${tableName}_new (
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
            )
            SELECT 
              id,
              ${safeColumn('cover_page_id', defaultValue: 'NULL')},
              COALESCE(${safeColumn('has_ghana_card')}, 0) as has_ghana_card,
              ${safeColumn('ghana_card_number')} as ghana_card_number,
              ${safeColumn('selected_id_type')} as selected_id_type,
              ${safeColumn('id_number')} as id_number,
              COALESCE(${safeColumn('id_picture_consent')}, 0) as id_picture_consent,
              ${safeColumn('no_consent_reason')} as no_consent_reason,
              ${safeColumn('id_image_path')} as id_image_path,
              ${safeColumn('contact_number')} as contact_number,
              COALESCE(${safeColumn('children_count')}, 0) as children_count,
              COALESCE(${safeColumn('created_at')}, datetime('now')) as created_at,
              COALESCE(${safeColumn('updated_at')}, datetime('now')) as updated_at,
              COALESCE(${safeColumn('is_synced')}, 0) as is_synced,
              COALESCE(${safeColumn('sync_status')}, 0) as sync_status
            FROM farmer_identification_table
          ''');

          // Drop old table and rename new one
          await db.execute('DROP TABLE IF EXISTS farmer_identification_table');
          await db.execute('ALTER TABLE ${tableName}_new RENAME TO $tableName');

          // Recreate indexes and triggers
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_farmer_identification_sync 
            ON $tableName(sync_status, is_synced)
          ''');

          await _createTriggers(db);
        } else {
          // No old table exists, just create a new one
          await createTable(db);
        }
      } catch (e, stackTrace) {
        print('Error during migration: $e\n$stackTrace');
        // If migration fails, ensure we have a valid table structure
        await db.execute('DROP TABLE IF EXISTS $tableName');
        await createTable(db);
      }
    }
  }
}