import 'package:flutter/material.dart';
import 'adult_info_model.dart';
import 'visit_information_model.dart';
import 'identification_of_owner_model.dart';
import 'workers_in_farm_model.dart';

class CombinedFarmerIdentificationModel {
  final int? id; // For database primary key
  final int? coverPageId; // Reference to the cover page

  // Visit Information
  final VisitInformationData? visitInformation;
  
  // Owner Identification
  final IdentificationOfOwnerData? ownerInformation;
  
  // Workers in Farm
  final WorkersInFarmData? workersInFarm;
  
  // Adults Information
  final AdultsInformationData? adultsInformation;

  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced; // Track if synced with server
  final int? syncStatus; // Sync status code

  const CombinedFarmerIdentificationModel({
    this.id,
    this.coverPageId,
    
    // Visit Information
    this.visitInformation,
    
    // Owner Identification
    this.ownerInformation,
    
    // Workers in Farm
    this.workersInFarm,
    
    // Adults Information
    this.adultsInformation,
    
    // Metadata
    this.createdAt,
    this.updatedAt,
    this.isSynced = false,
    this.syncStatus = 0,
  });
  
  // Create an empty instance
  factory CombinedFarmerIdentificationModel.empty() {
    return CombinedFarmerIdentificationModel(
      visitInformation: VisitInformationData(),
      ownerInformation: IdentificationOfOwnerData(),
      workersInFarm: WorkersInFarmData(),
      adultsInformation: AdultsInformationData(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      
      // Nested models
      'visitInformation': visitInformation?.toMap(),
      'ownerInformation': ownerInformation?.toMap(),
      'workersInFarm': workersInFarm?.toMap(),
      'adultsInformation': adultsInformation?.toMap(),
      
      // Metadata
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Create from Map (for database retrieval)
  factory CombinedFarmerIdentificationModel.fromMap(Map<String, dynamic> map) {
    return CombinedFarmerIdentificationModel(
      id: map['id'],
      
      // Nested models
      visitInformation: map['visitInformation'] != null 
          ? VisitInformationData.fromMap(Map<String, dynamic>.from(map['visitInformation']))
          : null,
      ownerInformation: map['ownerInformation'] != null
          ? IdentificationOfOwnerData.fromMap(Map<String, dynamic>.from(map['ownerInformation']))
          : null,
      workersInFarm: map['workersInFarm'] != null
          ? WorkersInFarmData.fromMap(Map<String, dynamic>.from(map['workersInFarm']))
          : null,
      adultsInformation: map['adultsInformation'] != null
          ? AdultsInformationData.fromMap(Map<String, dynamic>.from(map['adultsInformation']))
          : null,
      
      // Metadata
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isSynced: map['isSynced'] == 1,
    );
  }

  // Create a copy with updated fields
  CombinedFarmerIdentificationModel copyWith({
    int? id,
    int? coverPageId,
    
    // Nested models
    VisitInformationData? visitInformation,
    IdentificationOfOwnerData? ownerInformation,
    WorkersInFarmData? workersInFarm,
    AdultsInformationData? adultsInformation,
    
    // Metadata
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    int? syncStatus,
  }) {
    return CombinedFarmerIdentificationModel(
      id: id ?? this.id,
      coverPageId: coverPageId ?? this.coverPageId,
      
      // Nested models
      visitInformation: visitInformation ?? this.visitInformation,
      ownerInformation: ownerInformation ?? this.ownerInformation,
      workersInFarm: workersInFarm ?? this.workersInFarm,
      adultsInformation: adultsInformation ?? this.adultsInformation,
      
      // Metadata
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  String toString() {
    return 'CombinedFarmerIdentificationModel{'
        'id: $id, '
        'visitInformation: $visitInformation, '
        'ownerInformation: $ownerInformation, '
        'workersInFarm: $workersInFarm, '
        'adultsInformation: $adultsInformation, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'isSynced: $isSynced, '
        'syncStatus: $syncStatus}';
}
}
