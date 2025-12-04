import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/community-assessment-model.dart';
import 'table_names.dart';
import '../../view/models/monitoring_model.dart';

// Import all table classes

import '../models/society/society_data_model.dart';
import 'db_tables/monitoring_table.dart';
// import 'db_columns/society_data_columns.dart';

class LocalDBHelper {
  static final LocalDBHelper instance = LocalDBHelper._init();
  static Database? _database;
  static const int _databaseVersion = 2; // Incremented from 1 to 2

  LocalDBHelper._init();
   static const String id = 'id';
  static const String createdDate = 'created_date';
  static const String deleteField = 'delete_field';
  static const String society = 'society';
  static const String societyCode = 'society_code';
  static const String societyPreCode = 'society_pre_code';
  static const String newSocietyPreCode = 'new_society_pre_code';
  static const String districtTblForeignKey = 'districtTbl_foreignkey';

  // Create community assessment table
  Future<void> _createCommunityAssessmentTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${TableNames.communityAssessmentTBL}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        communityName TEXT,
        communityScore INTEGER,
        q1 TEXT, q2 TEXT, q3 TEXT, q4 TEXT, q5 TEXT,
        q6 TEXT, q7a INTEGER, q7b TEXT, q7c TEXT, q8 TEXT, q9 TEXT, q10 TEXT, 
        status INTEGER
      )
    ''');


        await db.execute('''
      CREATE TABLE ${TableNames.farmersTBL}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        farmer_code TEXT UNIQUE NOT NULL,
        society_name INTEGER NOT NULL,
        national_id_no TEXT UNIQUE,
        contact TEXT,
        id_type TEXT,
        id_expiry_date TEXT,
        no_of_cocoa_farms INTEGER DEFAULT 0,
        no_of_certified_crop INTEGER DEFAULT 0,
        total_cocoa_bags_harvested_previous_year INTEGER DEFAULT 0,
        total_cocoa_bags_sold_group_previous_year INTEGER DEFAULT 0,
        current_year_yeild_estimate INTEGER DEFAULT 0,
        staffTbl_foreignkey INTEGER,
        uuid TEXT UNIQUE,
        farmer_photo TEXT,
        cal_no_mapped_farms INTEGER DEFAULT 0,
        mapped_status TEXT,
        new_farmer_code TEXT UNIQUE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

     await db.execute('''
      CREATE TABLE ${TableNames.districtsTBL}(
        id INTEGER PRIMARY KEY,
        created_date TEXT NOT NULL,
        delete_field TEXT NOT NULL,
        district TEXT NOT NULL,
        district_code TEXT NOT NULL,
        regionTbl_foreignkey INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');


      await db.execute('''
      CREATE TABLE ${TableNames.society}(
       $id INTEGER PRIMARY KEY,
      $createdDate TEXT NOT NULL,
      $deleteField TEXT NOT NULL,
      $society TEXT NOT NULL,
      $societyCode TEXT NOT NULL,
      $societyPreCode TEXT NOT NULL,
      $newSocietyPreCode TEXT NOT NULL,
      $districtTblForeignKey INTEGER NOT NULL
      )
    ''');

    await db.execute('''
    CREATE TABLE ${TableNames.staffTBL} (
      id INTEGER PRIMARY KEY,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      gender TEXT NOT NULL,
      contact TEXT NOT NULL,
      designation INTEGER NOT NULL,
      email_address TEXT,
      staffid TEXT NOT NULL UNIQUE,
      district TEXT,
      created_at INTEGER DEFAULT (strftime('%s', 'now')),
      updated_at INTEGER DEFAULT (strftime('%s', 'now'))
    )
  ''');

 await db.execute('''
     CREATE TABLE farmer_interviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  enumerator INTEGER,
  farmer INTEGER,
  interview_start_time TEXT,
  gps_point TEXT,
  community_type TEXT,
  farmer_resides_in_community TEXT,
  latitude TEXT,
  longitude TEXT,
  farmer_residing_community TEXT,
  farmer_available TEXT,
  reason_unavailable TEXT,
  reason_unavailable_other TEXT,
  available_answer_by TEXT,
  refusal_toa_participate_reason_survey TEXT,
  total_adults INTEGER,
  is_name_correct TEXT,
  exact_name TEXT,
  nationality TEXT,
  country_origin TEXT,
  country_origin_other TEXT,
  is_owner TEXT,
  owner_status_01 TEXT,
  owner_status_00 TEXT,
  children_present TEXT,
  num_children_5_to_17 INTEGER,
  feedback_enum TEXT,
  picture_of_respondent TEXT,
  signature_producer TEXT,
  end_gps TEXT,
  end_time TEXT,
  sensitized_good_parenting TEXT,
  sensitized_child_protection TEXT,
  sensitized_safe_labour TEXT,
  number_of_female_adults INTEGER,
  number_of_male_adults INTEGER,
  picture_sensitization TEXT,
  feedback_observations TEXT,
  school_fees_owed TEXT,
  parent_remediation TEXT,
  parent_remediation_other TEXT,
  community_remediation TEXT,
  community_remediation_other TEXT,
  name_owner TEXT,
  first_name_owner TEXT,
  nationality_owner TEXT,
  country_origin_owner TEXT,
  country_origin_owner_other TEXT,
  manager_work_length INTEGER,
  recruited_workers TEXT,
  worker_recruitment_type TEXT,
  worker_agreement_type TEXT,
  worker_agreement_other TEXT,
  tasks_clarified TEXT,
  additional_tasks TEXT,
  refusal_action TEXT,
  refusal_action_other TEXT,
  salary_status TEXT,
  recruit_1 TEXT,
  recruit_2 TEXT,
  recruit_3 TEXT,
  conditions_1 TEXT,
  conditions_2 TEXT,
  conditions_3 TEXT,
  conditions_4 TEXT,
  conditions_5 TEXT,
  leaving_1 TEXT,
  leaving_2 TEXT,
  consent_recruitment TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX idx_farmer ON farmer_interviews(farmer);
CREATE INDEX idx_enumerator ON farmer_interviews(enumerator);
CREATE INDEX idx_created_at ON farmer_interviews(created_at);
CREATE INDEX idx_name_owner ON farmer_interviews(name_owner, first_name_owner);
    ''');


//      await db.execute('''
//   CREATE TABLE ${SocietyDataColumns.tableName} (
//     ${SocietyDataColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
//     ${SocietyDataColumns.enumerator} INTEGER NOT NULL,
//     ${SocietyDataColumns.society} INTEGER NOT NULL,
//     ${SocietyDataColumns.accessToProtectedWater} REAL NOT NULL,
//     ${SocietyDataColumns.hireAdultLabourers} REAL NOT NULL,
//     ${SocietyDataColumns.awarenessRaisingSession} REAL NOT NULL,
//     ${SocietyDataColumns.womenLeaders} REAL NOT NULL,
//     ${SocietyDataColumns.preSchool} REAL NOT NULL,
//     ${SocietyDataColumns.primarySchool} REAL NOT NULL,
//     ${SocietyDataColumns.separateToilets} REAL NOT NULL,
//     ${SocietyDataColumns.provideFood} REAL NOT NULL,
//     ${SocietyDataColumns.scholarships} REAL NOT NULL,
//     ${SocietyDataColumns.corporalPunishment} REAL NOT NULL,
//     UNIQUE(${SocietyDataColumns.enumerator}, ${SocietyDataColumns.society})
//     ON CONFLICT REPLACE
//   )
// ''');
     await db.execute('''
      CREATE TABLE ${SocietyDataColumns.tableName} (
        ${SocietyDataColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SocietyDataColumns.enumerator} INTEGER NOT NULL,
        ${SocietyDataColumns.society} INTEGER NOT NULL,
        ${SocietyDataColumns.accessToProtectedWater} REAL NOT NULL,
        ${SocietyDataColumns.hireAdultLabourers} REAL NOT NULL,
        ${SocietyDataColumns.awarenessRaisingSession} REAL NOT NULL,
        ${SocietyDataColumns.womenLeaders} REAL NOT NULL,
        ${SocietyDataColumns.preSchool} REAL NOT NULL,
        ${SocietyDataColumns.primarySchool} REAL NOT NULL,
        ${SocietyDataColumns.separateToilets} REAL NOT NULL,
        ${SocietyDataColumns.provideFood} REAL NOT NULL,
        ${SocietyDataColumns.scholarships} REAL NOT NULL,
        ${SocietyDataColumns.corporalPunishment} REAL NOT NULL,
        UNIQUE(${SocietyDataColumns.enumerator}, ${SocietyDataColumns.society}) ON CONFLICT REPLACE
      )
    ''');


     await db.execute('''
      CREATE TABLE IF NOT EXISTS child_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cover_page_id INTEGER NOT NULL,
        household_id INTEGER NOT NULL,
        child_number INTEGER NOT NULL,
        
        -- Basic Information
        is_farmer_child INTEGER,
        child_list_number TEXT,
        birth_date TEXT,
        birth_year INTEGER,
        can_be_surveyed_now INTEGER,
        survey_not_possible_reasons TEXT,
        other_survey_reason TEXT,
        respondent_type TEXT,
        other_respondent_type TEXT,
        child_name TEXT,
        child_surname TEXT,
        child_gender TEXT,
        child_age INTEGER,
        has_birth_certificate INTEGER,
        no_birth_certificate_reason TEXT,
        born_in_community TEXT,
        birth_country TEXT,
        relationship_to_head TEXT,
        other_relationship TEXT,
        not_with_family_reasons TEXT,
        other_not_with_family_reason TEXT,
        child_agreed_with_decision INTEGER,
        has_spoken_with_parents INTEGER,
        time_in_household TEXT,
        who_accompanied_child TEXT,
        other_accompanied TEXT,
        father_residence TEXT,
        father_country TEXT,
        other_father_country TEXT,
        mother_residence TEXT,
        mother_country TEXT,
        other_mother_country TEXT,
        
        -- Education Information
        is_currently_enrolled INTEGER,
        school_name TEXT,
        school_type TEXT,
        grade_level TEXT,
        school_attendance_frequency TEXT,
        available_school_supplies TEXT,
        has_ever_been_to_school INTEGER,
        left_school_year TEXT,
        attended_school_last_7_days INTEGER,
        reason_not_attended_school TEXT,
        other_reason_not_attended TEXT,
        missed_school_days INTEGER,
        absence_reasons TEXT,
        other_absence_reason TEXT,
        worked_in_house INTEGER,
        worked_on_cocoa_farm INTEGER,
        cocoa_farm_tasks TEXT,
        work_frequency TEXT,
        observed_working INTEGER,
        received_remuneration INTEGER,
        was_supervised_by_adult_lighttasks7days INTEGER,
        longest_light_duty_time_lighttasks7days TEXT,
        longest_non_school_day_time_lighttasks7days TEXT,
        tasks_last_12_months TEXT,
        task_location_lighttasks7days TEXT,
        other_location_lighttasks7days TEXT,
        school_day_task_hours_lighttasks7days TEXT,
        non_school_day_task_hours_lighttasks7days TEXT,
        education_level TEXT,
        can_write_sentences TEXT,
        reason_for_leaving_school TEXT,
        other_reason_for_leaving_school TEXT,
        reason_never_attended_school TEXT,
        other_reason_never_attended TEXT,
        
        -- Work Information
        work_for_whom TEXT,
        other_work_for_whom TEXT,
        why_work_reasons TEXT,
        other_why_work_reason TEXT,
        
        -- Light Tasks 12 Months
        received_remuneration_lighttasks12months INTEGER,
        longest_school_day_time_lighttasks12months TEXT,
        longest_non_school_day_time_lighttasks12months TEXT,
        task_location_lighttasks12months TEXT,
        other_task_location_lighttasks12months TEXT,
        total_school_day_hours_lighttasks12months TEXT,
        total_non_school_day_hours_lighttasks12months TEXT,
        was_supervised_during_task_lighttasks12months INTEGER,
        
        -- Dangerous Tasks 7 Days
        has_received_salary_dangeroustask7days INTEGER,
        task_location_dangeroustask7days TEXT,
        other_location_dangeroustask7days TEXT,
        longest_school_day_time_dangeroustask7days TEXT,
        longest_non_school_day_time_dangeroustask7days TEXT,
        school_day_hours_dangeroustask7days TEXT,
        non_school_day_hours_dangeroustask7days TEXT,
        was_supervised_by_adult_dangeroustask7days INTEGER,
        
        -- Dangerous Tasks 12 Months
        has_received_salary_dangeroustask12months INTEGER,
        task_location_dangeroustask12months TEXT,
        other_location_dangeroustask12months TEXT,
        longest_school_day_time_dangeroustask12months TEXT,
        longest_non_school_day_time_dangeroustask12months TEXT,
        school_day_hours_dangeroustask12months TEXT,
        non_school_day_hours_dangeroustask12months TEXT,
        was_supervised_by_adult_dangeroustask12months INTEGER,
        dangerous_tasks_12_months TEXT,
        
        -- Health and Safety
        applied_agrochemicals INTEGER,
        on_farm_during_application INTEGER,
        suffered_injury INTEGER,
        how_wounded TEXT,
        when_wounded TEXT,
        often_feel_pains INTEGER,
        help_received TEXT,
        other_help TEXT,
        
        -- Photo Consent
        parent_consent_photo INTEGER,
        no_consent_reason TEXT,
        child_photo_path TEXT,
        
        -- Metadata
        is_synced INTEGER DEFAULT 0,
        sync_status INTEGER DEFAULT 0,
        synced_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_surveyed INTEGER DEFAULT 0,
        
        UNIQUE(household_id, child_number)
      )
    ''');

     
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    debugPrint('🔄 Initializing database at: $path');
    debugPrint('📊 Database version: 8');

    return await openDatabase(
      path,
      version: 8, // Incremented to add cover_page_id column
      onCreate: _createAllTables,
      onUpgrade: _upgradeDatabase,
      onOpen: (db) {
        debugPrint('✅ Database opened successfully');
      },
    );
  }


  Future<void> _createAllTables(Database db, int version) async {
    debugPrint('🛠️ Creating all tables...');
    
    // Create community assessment table
    debugPrint('📋 Creating community assessment table...');
    await _createCommunityAssessmentTable(db);

    // Create monitoring table and indexes
    debugPrint('📊 Creating monitoring table...');
    await MonitoringTable.createTable(db);
    await MonitoringTable.createIndexes(db);
    
    // Create child_details table with cover_page_id
    await db.execute('''
      CREATE TABLE IF NOT EXISTS child_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cover_page_id INTEGER NOT NULL,
        household_id INTEGER NOT NULL,
        child_number INTEGER NOT NULL,
        is_farmer_child INTEGER,
        child_list_number TEXT,
        birth_date TEXT,
        birth_year INTEGER,
        can_be_surveyed_now INTEGER,
        survey_not_possible_reasons TEXT,
        other_survey_reason TEXT,
        respondent_type TEXT,
        other_respondent_type TEXT,
        child_name TEXT,
        child_surname TEXT,
        child_gender TEXT,
        child_age INTEGER,
        has_birth_certificate INTEGER,
        no_birth_certificate_reason TEXT,
        born_in_community TEXT,
        birth_country TEXT,
        relationship_to_head TEXT,
        other_relationship TEXT,
        not_with_family_reasons TEXT,
        other_not_with_family_reason TEXT,
        child_agreed_with_decision INTEGER,
        has_spoken_with_parents INTEGER,
        time_in_household TEXT,
        who_accompanied_child TEXT,
        other_accompanied TEXT,
        father_residence TEXT,
        father_country TEXT,
        other_father_country TEXT,
        mother_residence TEXT,
        mother_country TEXT,
        other_mother_country TEXT,
        is_currently_enrolled INTEGER,
        school_name TEXT,
        school_type TEXT,
        grade_level TEXT,
        school_attendance_frequency TEXT,
        available_school_supplies TEXT,
        has_ever_been_to_school INTEGER,
        left_school_year TEXT,
        attended_school_last_7_days INTEGER,
        reason_not_attended_school TEXT,
        other_reason_not_attended TEXT,
        missed_school_days INTEGER,
        absence_reasons TEXT,
        other_absence_reason TEXT,
        worked_in_house INTEGER,
        worked_on_cocoa_farm INTEGER,
        cocoa_farm_tasks TEXT,
        work_frequency TEXT,
        observed_working INTEGER,
        received_remuneration INTEGER,
        was_supervised_by_adult_lighttasks7days INTEGER,
        longest_light_duty_time_lighttasks7days TEXT,
        longest_non_school_day_time_lighttasks7days TEXT,
        tasks_last_12_months TEXT,
        task_location_lighttasks7days TEXT,
        other_location_lighttasks7days TEXT,
        school_day_task_hours_lighttasks7days TEXT,
        non_school_day_task_hours_lighttasks7days TEXT,
        education_level TEXT,
        can_write_sentences TEXT,
        reason_for_leaving_school TEXT,
        other_reason_for_leaving_school TEXT,
        reason_never_attended_school TEXT,
        other_reason_never_attended TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        sync_status INTEGER DEFAULT 0
      )
    ''');
    
    // Create staff_districts table
    debugPrint('🔗 Creating staff_districts table...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${TableNames.staffDistrictsTBL} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_id INTEGER NOT NULL,
        district_id INTEGER NOT NULL,
        district_name TEXT NOT NULL,
        FOREIGN KEY (staff_id) REFERENCES ${TableNames.staffTBL}(id) ON DELETE CASCADE,
        UNIQUE(staff_id, district_id) ON CONFLICT REPLACE
      )
    ''');

    // Create remediation table
    debugPrint('🔧 Creating remediation table...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${TableNames.remediationTBL} ( 
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farm_identification_id INTEGER,
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
        sync_status INTEGER DEFAULT 0
      )
    ''');
    debugPrint('📈 Creating index on farm_identification_id...');
    // Create index on farm_identification_id for better query performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_remediation_farm_id 
      ON ${TableNames.remediationTBL}(farm_identification_id)
      WHERE farm_identification_id IS NOT NULL
    ''');

    // Create any necessary triggers or indexes
    await _createDatabaseTriggers(db);
  }

  

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 8) {
      // Add cover_page_id to child_details table
      try {
        // Check if the column already exists to avoid errors
        final columns = await db.rawQuery('PRAGMA table_info(child_details)');
        final hasCoverPageId = columns.any((col) => col['name'] == 'cover_page_id');
        
        if (!hasCoverPageId) {
          await db.execute('ALTER TABLE child_details ADD COLUMN cover_page_id INTEGER NOT NULL DEFAULT 0');
          debugPrint('✅ Added cover_page_id column to child_details table');
        }
      } catch (e) {
        debugPrint('❌ Error adding cover_page_id column: $e');
        // If the table doesn't exist, it will be created with the new schema
        if (e.toString().contains('no such table')) {
          debugPrint('ℹ️ child_details table does not exist, it will be created with the new schema');
        } else {
          rethrow;
        }
      }
    }
    
    if (oldVersion < 7) {
      // Create the new staff_districts table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${TableNames.staffDistrictsTBL} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          staff_id INTEGER NOT NULL,
          district_id INTEGER NOT NULL,
          district_name TEXT NOT NULL,
          FOREIGN KEY (staff_id) REFERENCES ${TableNames.staffTBL}(id) ON DELETE CASCADE,
          UNIQUE(staff_id, district_id) ON CONFLICT REPLACE
        )
      ''');
      
      debugPrint('✅ Created ${TableNames.staffDistrictsTBL} table');
    }
    
    // Let MonitoringTable handle its own upgrades
    await MonitoringTable.onUpgrade(db, oldVersion, newVersion);
  }

  Future<void> _createDatabaseTriggers(Database db) async {
    // Create any necessary triggers for your tables
    // Example:
    // await CoverPageTable.createTriggers(db);
    // await ConsentTable.createTriggers(db);
    // ... and so on for other tables with triggers
  }

  // Get database instance
  Future<Database> get database async {
    if (_database != null) {
      // Verify the remediation table exists
      await _verifyRemediationTable();
      return _database!;
    }
    _database = await _initDB('child_labour.db');
    
    // Verify the remediation table exists after initialization
    await _verifyRemediationTable();
    
    return _database!;
  }
  
  // Verify the remediation table exists, create it if it doesn't
  Future<void> _verifyRemediationTable() async {
    if (_database == null) return;
    
    try {
      // Check if the table exists
      final result = await _database!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [TableNames.remediationTBL]
      );
      
      if (result.isEmpty) {
        debugPrint('⚠️ Remediation table does not exist, creating it now...');
        await _database!.execute('''
          CREATE TABLE IF NOT EXISTS ${TableNames.remediationTBL} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            farm_identification_id INTEGER,
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
            sync_status INTEGER DEFAULT 0
          )
        ''');
        debugPrint('✅ Remediation table created successfully');
      } else {
        debugPrint('✅ Remediation table already exists');
      }
    } catch (e) {
      debugPrint('❌ Error verifying/creating remediation table: $e');
      rethrow;
    }
  }

  // Community Assessment CRUD operations
  Future<int> insertCommunityAssessment(CommunityAssessmentModel model) async {
    final db = await database;
    return await db.insert(TableNames.communityAssessmentTBL, model.toMap());
  }

  Future<int> updateCommunityAssessment(CommunityAssessmentModel model) async {
    final db = await database;
    return await db.update(
      TableNames.communityAssessmentTBL,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<List<CommunityAssessmentModel>> getCommunityAssessment() async {
    final db = await database;
    final result = await db.query(TableNames.communityAssessmentTBL);
    return result
        .map((json) => CommunityAssessmentModel.fromMap(json))
        .toList();
  }

  Future<List<CommunityAssessmentModel>> getCommunityAssessmentByStatus(
      {int status = 0}) async {
    final db = await database;
    final result = await db.query(
      TableNames.communityAssessmentTBL,
      where: 'status = ?',
      whereArgs: [status],
    );
    return result
        .map((json) => CommunityAssessmentModel.fromMap(json))
        .toList();
  }

  Future<int> deleteAllCommunityAssessment() async {
    final db = await database;
    return await db.delete(TableNames.communityAssessmentTBL);
  }

  // Monitoring CRUD operations
  Future<int> insertIntoMonitoringTable(MonitoringModel form) async {
    final db = await database;
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

  Future<List<MonitoringModel>> getMonitoringTableByStatus(int status) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        TableNames.monitoringTBL,
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'date_created DESC',
      );
      return List.generate(maps.length, (i) {
        return MonitoringModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting monitoring records by status $status: $e');
      return [];
    }
  }

  /// Gets all pending monitoring assessments (status = 0)
  Future<List<MonitoringModel>> getPendingMonitoringAssessments() async {
    return await getMonitoringTableByStatus(0);
  }

  /// Gets all submitted monitoring assessments (status = 1)
  Future<List<MonitoringModel>> getSubmittedMonitoringAssessments() async {
    return await getMonitoringTableByStatus(1);
  }

  Future<int> updateMonitoringTable(MonitoringModel form) async {
    final db = await database;
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

  /// Clears all survey data from the database
  /// This should be called when navigating back to the StartSurvey screen
  Future<void> clearAllSurveyData() async {
    final db = await database;
    await db.delete(TableNames.communityAssessmentTBL);
    await db.delete(TableNames.monitoringTBL);
  }

  // Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

//   // ===================================================================
//   // COVER PAGE TABLE METHODS

//   Future<int> insertCoverPageData(Map<String, dynamic> data) async {
//     final db = await database;
//     final now = DateTime.now().toIso8601String();
//     final insertData = {
//       'selected_town': data['selected_town'],
//       'selected_town_name': data['selected_town_name'],
//       'selected_farmer': data['selected_farmer'],
//       'selected_farmer_name': data['selected_farmer_name'],
//       'status': data['status'] ?? 0,
//       'sync_status': 0,
//       'created_at': now,
//       'updated_at': now,
//       'is_synced': 0,
//     };
//     return await db.insert(TableNames.coverPageTBL, insertData);
//   }

//   Future<Map<String, dynamic>?> getLatestCoverPageData() async {
//     final db = await database;
//     final List<Map<String, dynamic>> results = await db.query(
//       TableNames.coverPageTBL,
//       orderBy: 'id DESC',
//       limit: 1,
//     );
//     return results.isNotEmpty ? results.first : null;
//   }

//   Future<List<Map<String, dynamic>>> getAllCoverPageData() async {
//     final db = await database;
//     return await db.query(TableNames.coverPageTBL);
//   }

//   Future<int> updateCoverPageData(int id, Map<String, dynamic> data) async {
//     final db = await database;
//     data['updated_at'] = DateTime.now().toIso8601String();
//     return await db.update(
//       TableNames.coverPageTBL,
//       data,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<int> updateCoverPageStatus({
//     required int id,
//     required int status,
//   }) async {
//     final db = await database;
//     return await db.update(
//       TableNames.coverPageTBL,
//       {
//         'status': status,
//         'updated_at': DateTime.now().toIso8601String(),
//       },
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<int> deleteCoverPageData(int id) async {
//     final db = await database;
//     return await db.delete(
//       TableNames.coverPageTBL,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<int> clearAllCoverPageData() async {
//     final db = await database;
//     return await db.delete(TableNames.coverPageTBL);
//   }

//   // ===================================================================
//   // CONSENT TABLE METHODS

//   Future<int> insertConsentData(Map<String, dynamic> data) async {
//     final db = await database;
//     final now = DateTime.now().toIso8601String();
//     final insertData = {
//       ...data,
//       'created_at': now,
//       'updated_at': now,
//       'is_synced': 0,
//     };
//     return await db.insert(TableNames.consentTBL, insertData);
//   }

//   Future<int> updateConsentData(int id, Map<String, dynamic> data) async {
//     final db = await database;
//     data['updated_at'] = DateTime.now().toIso8601String();
//     return await db.update(
//       TableNames.consentTBL,
//       data,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<Map<String, dynamic>?> getLatestConsentData() async {
//     final db = await database;
//     final List<Map<String, dynamic>> results = await db.query(
//       TableNames.consentTBL,
//       orderBy: 'id DESC',
//       limit: 1,
//     );
//     return results.isNotEmpty ? results.first : null;
//   }
// }
}
