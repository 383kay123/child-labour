import 'package:sqflite/sqflite.dart';
import '../table_names.dart';

class CommunityAssessmentTable {
  static const String tableName = TableNames.communityAssessmentTBL;
  
  // Column names - using snake_case for consistency with database schema
  static const String id = 'id';
  static const String date_created = 'date_created';
  static const String date_modified = 'date_modified';
  static const String created_by = 'created_by';
  static const String modified_by = 'modified_by';
  static const String status = 'status';
  
  // Community information
  static const String community_name = 'community_name';
  static const String region = 'region';
  static const String district = 'district';
  static const String sub_county = 'sub_county';
  static const String parish = 'parish';
  static const String village = 'village';
  static const String gps_coordinates = 'gps_coordinates';
  
  // Population information
  static const String total_households = 'total_households';
  static const String total_population = 'total_population';
  static const String total_children = 'total_children';
  
  // School information
  static const String primary_schools_count = 'primary_schools_count';
  static const String schools = 'schools';
  static const String has_preschool = 'has_preschool';
  static const String has_primary_school = 'has_primary_school';
  static const String schools_with_toilets = 'schools_with_toilets';
  static const String schools_with_food = 'schools_with_food';
  static const String schools_no_corporal_punishment = 'schools_no_corporal_punishment';
  
  // Community resources
  static const String has_protected_water = 'has_protected_water';
  static const String hires_adult_labor = 'hires_adult_labor';
  static const String child_labor_awareness = 'child_labor_awareness';
  static const String has_women_leaders = 'has_women_leaders';
  
  // Additional information
  static const String notes = 'notes';
  static const String raw_data = 'raw_data';
  static const String community_score = 'community_score';
  
  // Make this class non-instantiable
  CommunityAssessmentTable._();
  
  /// Creates the community assessment table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        $date_created TEXT NOT NULL,
        $date_modified TEXT,
        $created_by TEXT,
        $modified_by TEXT,
        $status INTEGER DEFAULT 0,
        $community_name TEXT,
        $region TEXT,
        $district TEXT,
        $sub_county TEXT,
        $parish TEXT,
        $village TEXT,
        $gps_coordinates TEXT,
        $total_households INTEGER,
        $total_population INTEGER,
        $total_children INTEGER,
        $primary_schools_count INTEGER,
        $schools TEXT,
        $schools_with_toilets TEXT,
        $schools_with_food TEXT,
        $schools_no_corporal_punishment TEXT,
        $notes TEXT,
        $raw_data TEXT,
        $community_score INTEGER,
        q1 TEXT,
        q2 TEXT,
        q3 TEXT,
        q4 TEXT,
        q5 TEXT,
        q6 TEXT,
        q7a INTEGER,
        q7b TEXT,
        q7c TEXT,
        q8 TEXT,
        q9 TEXT,
        q10 TEXT
      )
    ''');
  }
  
  /// Creates any necessary indexes
  static Future<void> createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_date_created 
      ON $tableName($date_created)
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_region 
      ON $tableName($region)
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_district 
      ON $tableName($district)
    ''');
  }
  
  /// Handles database upgrades
  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add all the new columns for version 2
      await _addColumnIfNotExists(db, tableName, region, 'TEXT');
      await _addColumnIfNotExists(db, tableName, district, 'TEXT');
      await _addColumnIfNotExists(db, tableName, parish, 'TEXT');
      await _addColumnIfNotExists(db, tableName, village, 'TEXT');
      await _addColumnIfNotExists(db, tableName, gps_coordinates, 'TEXT');
      await _addColumnIfNotExists(db, tableName, total_households, 'INTEGER');
      await _addColumnIfNotExists(db, tableName, total_population, 'INTEGER');
      await _addColumnIfNotExists(db, tableName, total_children, 'INTEGER');
      await _addColumnIfNotExists(db, tableName, primary_schools_count, 'INTEGER');
      await _addColumnIfNotExists(db, tableName, schools, 'TEXT');
      await _addColumnIfNotExists(db, tableName, schools_with_toilets, 'TEXT');
      await _addColumnIfNotExists(db, tableName, schools_with_food, 'TEXT');
      await _addColumnIfNotExists(db, tableName, schools_no_corporal_punishment, 'TEXT');
      await _addColumnIfNotExists(db, tableName, notes, 'TEXT');
      await _addColumnIfNotExists(db, tableName, raw_data, 'TEXT');
      await _addColumnIfNotExists(db, tableName, status, 'INTEGER DEFAULT 0');
    }
    
    // Version 3 upgrades
    if (oldVersion < 3) {
      await _upgradeToVersion3(db);
    }
  }
  
  /// Helper method to safely add a column if it doesn't exist
  static Future<void> _addColumnIfNotExists(Database db, String table, String column, String type) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    } catch (e) {
      // Column might already exist, which is fine
      if (!e.toString().contains('duplicate column')) {
        rethrow;
      }
    }
  }
  
  /// Handle database upgrades for version 3
  static Future<void> _upgradeToVersion3(Database db) async {
    await _addColumnIfNotExists(db, tableName, sub_county, 'TEXT');
    await _addColumnIfNotExists(db, tableName, has_protected_water, 'INTEGER');
    await _addColumnIfNotExists(db, tableName, hires_adult_labor, 'INTEGER');
    await _addColumnIfNotExists(db, tableName, child_labor_awareness, 'INTEGER');
    await _addColumnIfNotExists(db, tableName, has_women_leaders, 'INTEGER');
    await _addColumnIfNotExists(db, tableName, has_preschool, 'INTEGER');
    await _addColumnIfNotExists(db, tableName, has_primary_school, 'INTEGER');
    await _addColumnIfNotExists(db, tableName, community_score, 'INTEGER');
  }
  }

