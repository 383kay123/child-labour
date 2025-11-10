import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/db_tables/consent_table.dart';
import 'package:human_rights_monitor/controller/models/consent_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ConsentDao {
  final LocalDBHelper dbHelper;

  ConsentDao({required this.dbHelper});

  /// Inserts a new consent record
  Future<int> insert(ConsentData model) async {
    final db = await dbHelper.database;
    
    final data = <String, dynamic>{
      if (model.consentGiven != null) ConsentTable.consentGiven: model.consentGiven! ? 1 : 0,
      if (model.declinedConsent != null) ConsentTable.declinedConsent: model.declinedConsent! ? 1 : 0,
      if (model.refusalReason != null) ConsentTable.refusalReason: model.refusalReason,
      if (model.consentTimestamp != null) ConsentTable.consentTimestamp: model.consentTimestamp!.toIso8601String(),
      if (model.communityType != null) ConsentTable.communityType: model.communityType,
      if (model.residesInCommunityConsent != null) ConsentTable.residesInCommunityConsent: model.residesInCommunityConsent,
      if (model.otherCommunityName != null) ConsentTable.otherCommunityName: model.otherCommunityName,
      if (model.farmerAvailable != null) ConsentTable.farmerAvailable: model.farmerAvailable,
      if (model.farmerStatus != null) ConsentTable.farmerStatus: model.farmerStatus,
      if (model.availablePerson != null) ConsentTable.availablePerson: model.availablePerson,
      if (model.otherSpecification != null) ConsentTable.otherSpecification: model.otherSpecification,
      if (model.interviewStartTime != null) ConsentTable.interviewStartTime: model.interviewStartTime!.toIso8601String(),
      if (model.timeStatus != null) ConsentTable.timeStatus: model.timeStatus,
      if (model.currentPosition != null) ...{
        ConsentTable.currentPositionLat: model.currentPosition!.latitude,
        ConsentTable.currentPositionLng: model.currentPosition!.longitude,
      },
      if (model.locationStatus != null) ConsentTable.locationStatus: model.locationStatus,
      if (model.isGettingLocation != null) ConsentTable.isGettingLocation: model.isGettingLocation! ? 1 : 0,
      ConsentTable.createdAt: DateTime.now().toIso8601String(),
      ConsentTable.updatedAt: DateTime.now().toIso8601String(),
      ConsentTable.isSynced: 0, // Not synced yet
    };
    
    // Remove null values from the map
    data.removeWhere((key, value) => value == null);

    return await db.insert(
      ConsentTable.tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing consent record
  Future<int> update(ConsentData model) async {
    if (model.id == null) {
      throw ArgumentError('Cannot update a model without an ID');
    }

    final db = await dbHelper.database;
    
    final data = {
      ConsentTable.consentGiven: model.consentGiven == true ? 1 : 0,
      ConsentTable.declinedConsent: model.declinedConsent == true ? 1 : 0,
      ConsentTable.refusalReason: model.refusalReason,
      ConsentTable.communityType: model.communityType,
      ConsentTable.residesInCommunityConsent: model.residesInCommunityConsent,
      ConsentTable.otherCommunityName: model.otherCommunityName,
      ConsentTable.farmerAvailable: model.farmerAvailable,
      ConsentTable.farmerStatus: model.farmerStatus,
      ConsentTable.availablePerson: model.availablePerson,
      ConsentTable.otherSpecification: model.otherSpecification,
      ConsentTable.interviewStartTime: model.interviewStartTime?.toIso8601String(),
      ConsentTable.timeStatus: model.timeStatus,
      ConsentTable.currentPositionLat: model.currentPosition?.latitude,
      ConsentTable.currentPositionLng: model.currentPosition?.longitude,
      ConsentTable.locationStatus: model.locationStatus,
      ConsentTable.isGettingLocation: (model.isGettingLocation ?? false) ? 1 : 0,
      ConsentTable.updatedAt: DateTime.now().toIso8601String(),
      ConsentTable.isSynced: 0, // Reset sync status on update
    };

    return await db.update(
      ConsentTable.tableName,
      data,
      where: '${ConsentTable.id} = ?',
      whereArgs: [model.id],
    );
  }

  /// Gets a consent record by ID
  Future<ConsentData?> getById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      ConsentTable.tableName,
      where: '${ConsentTable.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToModel(maps.first);
    }
    return null;
  }

  /// Gets all consent records
  Future<List<ConsentData>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(ConsentTable.tableName);
    return List.generate(maps.length, (i) => _mapToModel(maps[i]));
  }

  /// Gets unsynced consent records
  Future<List<ConsentData>> getUnsynced() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      ConsentTable.tableName,
      where: '${ConsentTable.isSynced} = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => _mapToModel(maps[i]));
  }

  /// Deletes a consent record by ID
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      ConsentTable.tableName,
      where: '${ConsentTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// Marks a record as synced
  Future<int> markAsSynced(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      ConsentTable.tableName,
      {
        ConsentTable.isSynced: 1,
        ConsentTable.updatedAt: DateTime.now().toIso8601String(),
      },
      where: '${ConsentTable.id} = ?',
      whereArgs: [id],
    );
  }

  /// Maps database row to ConsentData model
  ConsentData _mapToModel(Map<String, dynamic> map) {
    return ConsentData(
      id: map[ConsentTable.id],
      communityType: map[ConsentTable.communityType],
      residesInCommunityConsent: map[ConsentTable.residesInCommunityConsent],
      farmerAvailable: map[ConsentTable.farmerAvailable],
      farmerStatus: map[ConsentTable.farmerStatus],
      availablePerson: map[ConsentTable.availablePerson],
      otherSpecification: map[ConsentTable.otherSpecification],
      otherCommunityName: map[ConsentTable.otherCommunityName],
      refusalReason: map[ConsentTable.refusalReason],
      consentGiven: map[ConsentTable.consentGiven] == 1,
      declinedConsent: map[ConsentTable.declinedConsent] == 1,
      consentTimestamp: map[ConsentTable.consentTimestamp] != null
          ? DateTime.parse(map[ConsentTable.consentTimestamp])
          : null,
      interviewStartTime: map[ConsentTable.interviewStartTime] != null
          ? DateTime.parse(map[ConsentTable.interviewStartTime])
          : null,
      timeStatus: map[ConsentTable.timeStatus] ?? 'Not recorded',
      currentPosition: map[ConsentTable.currentPositionLat] != null &&
              map[ConsentTable.currentPositionLng] != null
          ? Position(
              latitude: map[ConsentTable.currentPositionLat],
              longitude: map[ConsentTable.currentPositionLng],
              timestamp: map[ConsentTable.interviewStartTime] != null
                  ? DateTime.parse(map[ConsentTable.interviewStartTime])
                  : DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            )
          : null,
      locationStatus: map[ConsentTable.locationStatus],
      isGettingLocation: map[ConsentTable.isGettingLocation] == 1,
      otherSpecController: TextEditingController(
        text: map[ConsentTable.otherSpecification]?.toString() ?? '',
      ),
      otherCommunityController: TextEditingController(
        text: map[ConsentTable.otherCommunityName]?.toString() ?? '',
      ),
      refusalReasonController: TextEditingController(
        text: map[ConsentTable.refusalReason]?.toString() ?? '',
      ),
    );
  }
}