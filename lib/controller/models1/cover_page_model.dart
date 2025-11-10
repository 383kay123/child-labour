import 'package:flutter/foundation.dart';

class CoverPageModel {
  final int? id;
  final String? selectedTown;
  final String? selectedTownName;
  final String? selectedFarmer;
  final String? selectedFarmerName;
  final String? createdAt;
  final String? updatedAt;
  final int status;
  final int syncStatus;

  CoverPageModel({
    this.id,
    this.selectedTown,
    this.selectedTownName,
    this.selectedFarmer,
    this.selectedFarmerName,
    this.createdAt,
    this.updatedAt,
    this.status = 0,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'selectedTown': selectedTown,
      'selectedTownName': selectedTownName,
      'selectedFarmer': selectedFarmer,
      'selectedFarmerName': selectedFarmerName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      'syncStatus': syncStatus,
    };
  }

  factory CoverPageModel.fromMap(Map<String, dynamic> map) {
    return CoverPageModel(
      id: map['id'] as int?,
      selectedTown: map['selectedTown'] as String?,
      selectedTownName: map['selectedTownName'] as String?,
      selectedFarmer: map['selectedFarmer'] as String?,
      selectedFarmerName: map['selectedFarmerName'] as String?,
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
      status: map['status'] as int? ?? 0,
      syncStatus: map['syncStatus'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'CoverPageModel(id: $id, selectedTown: $selectedTown, selectedTownName: $selectedTownName, selectedFarmer: $selectedFarmer, selectedFarmerName: $selectedFarmerName, status: $status, syncStatus: $syncStatus)';
  }
}
