import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/models/consent_model.dart' show ConsentData;
import 'package:geolocator/geolocator.dart';

class ConsentTable {
  static const String tableName = TableNames.consentTBL;
  
  // Column names as static constants
  static const String id = 'id';
  
  // Consent Information
  static const String consentGiven = 'consent_given';
  static const String declinedConsent = 'declined_consent';
  static const String refusalReason = 'refusal_reason';
  static const String consentTimestamp = 'consent_timestamp';
  
  // Community and Farmer Information
  static const String communityType = 'community_type';
  static const String residesInCommunityConsent = 'resides_in_community_consent';
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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $id INTEGER PRIMARY KEY AUTOINCREMENT,
        
        -- Consent Information
        $consentGiven INTEGER NOT NULL DEFAULT 0,
        $declinedConsent INTEGER NOT NULL DEFAULT 0,
        $refusalReason TEXT,
        $consentTimestamp TEXT,
        
        -- Community and Farmer Information
        $communityType TEXT,
        $residesInCommunityConsent TEXT,
        $otherCommunityName TEXT,
        $farmerAvailable TEXT,
        $farmerStatus TEXT,
        $availablePerson TEXT,
        $otherSpecification TEXT,
        
        -- Location and Timing
        $interviewStartTime TEXT,
        $timeStatus TEXT,
        $currentPositionLat REAL,
        $currentPositionLng REAL,
        $locationStatus TEXT,
        $isGettingLocation INTEGER NOT NULL DEFAULT 0,
        
        -- Metadata
        $createdAt TEXT NOT NULL,
        $updatedAt TEXT NOT NULL,
        $isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_sync 
      ON $tableName($isSynced)
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
              $updatedAt = datetime('now'),
              $isSynced = 0
          WHERE $id = NEW.$id;
      END;
    ''');
  }

  /// Handles database upgrades for this table
  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await createTable(db);
      await createTriggers(db);
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
      otherSpecController: TextEditingController(text: map[otherSpecification]?.toString() ?? ''),
      otherCommunityController: TextEditingController(text: map[otherCommunityName]?.toString() ?? ''),
      refusalReasonController: TextEditingController(text: map[refusalReason]?.toString() ?? ''),
      interviewStartTime: map[interviewStartTime] != null
          ? DateTime.parse(map[interviewStartTime] as String)
          : null,
      timeStatus: map[timeStatus]?.toString(),
      currentPosition: map[currentPositionLat] != null && map[currentPositionLng] != null
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