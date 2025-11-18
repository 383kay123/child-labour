import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

/// Represents the data collected at the end of the survey.
class EndOfCollectionData {
  /// Database primary key
  final int? id;
  
  /// Reference to the farm identification record
  final int farmIdentificationId;
  
  /// Path to the respondent's image
  final String? respondentImagePath;
  
  /// Path to the producer's signature image
  final String? producerSignaturePath;
  
  /// GPS coordinates where the survey was completed
  final String gpsCoordinates;
  
  /// Time when the survey was completed
  final DateTime? endTime;
  
  /// Any additional remarks
  final String remarks;
  
  /// When the record was created
  final DateTime? createdAt;
  
  /// When the record was last updated
  final DateTime? updatedAt;
  
  /// Whether the record has been synced with the server
  final bool isSynced;
  
  /// Sync status (0 = not synced, 1 = synced, 2 = sync failed)
  final int syncStatus;
  
  /// Creates a new [EndOfCollectionData] instance.
  const EndOfCollectionData({
    this.id,
    required this.farmIdentificationId,
    this.respondentImagePath,
    this.producerSignaturePath,
    required this.gpsCoordinates,
    this.endTime,
    required this.remarks,
    this.createdAt,
    this.updatedAt,
    this.isSynced = false,
    this.syncStatus = 0,
  });
  
  /// Creates a copy of this [EndOfCollectionData] with the given fields replaced.
  EndOfCollectionData copyWith({
    int? id,
    int? farmIdentificationId,
    String? respondentImagePath,
    String? producerSignaturePath,
    String? gpsCoordinates,
    DateTime? endTime,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    int? syncStatus,
  }) {
    return EndOfCollectionData(
      id: id ?? this.id,
      farmIdentificationId: farmIdentificationId ?? this.farmIdentificationId,
      respondentImagePath: respondentImagePath ?? this.respondentImagePath,
      producerSignaturePath: producerSignaturePath ?? this.producerSignaturePath,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      endTime: endTime ?? this.endTime,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
  
  /// Creates an empty instance with default values
  factory EndOfCollectionData.empty() {
    return EndOfCollectionData(
      farmIdentificationId: 0,
      gpsCoordinates: '',
      remarks: '',
    );
  }
  
  /// Check if this instance is empty (has only default values)
  bool get isEmpty => this == EndOfCollectionData.empty();
  
  /// Check if this instance is not empty
  bool get isNotEmpty => !isEmpty;
  
  /// Validates required fields
  bool get isValid {
    return farmIdentificationId > 0 &&
        gpsCoordinates.isNotEmpty &&
        remarks.isNotEmpty;
  }
  
  /// Converts this [EndOfCollectionData] to a Map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farm_identification_id': farmIdentificationId,
      'respondent_image_path': respondentImagePath,
      'producer_signature_path': producerSignaturePath,
      'gps_coordinates': gpsCoordinates,
      'end_time': endTime?.toIso8601String(),
      'remarks': remarks,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'sync_status': syncStatus,
    };
  }
  
  /// Converts to JSON (same as toMap but for API serialization)
  Map<String, dynamic> toJson() => toMap();
  
  /// Creates an [EndOfCollectionData] from a Map (e.g., from database).
  factory EndOfCollectionData.fromMap(Map<String, dynamic> map) {
    return EndOfCollectionData(
      id: map['id'] as int?,
      farmIdentificationId: map['farm_identification_id'] as int,
      respondentImagePath: map['respondent_image_path'] as String?,
      producerSignaturePath: map['producer_signature_path'] as String?,
      gpsCoordinates: map['gps_coordinates'] as String,
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
      remarks: map['remarks'] as String,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      isSynced: (map['is_synced'] as int?) == 1,
      syncStatus: map['sync_status'] as int? ?? 0,
    );
  }
  
  /// Creates from JSON (same as fromMap but for API deserialization)
  factory EndOfCollectionData.fromJson(Map<String, dynamic> json) => EndOfCollectionData.fromMap(json);
  
  /// Helper method to format TimeOfDay to string (HH:mm format)
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  /// Helper method to parse string to TimeOfDay
  static TimeOfDay? parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    
    if (!RegExp(r'^\d{1,2}:\d{2}$').hasMatch(timeString)) {
      return null;
    }
    
    final parts = timeString.split(':');
    if (parts.length != 2) return null;
    
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    
    return TimeOfDay(hour: hour, minute: minute);
  }
  
  /// Get end time as TimeOfDay (convenience method)
  TimeOfDay? get endTimeAsTimeOfDay {
    if (endTime == null) return null;
    return TimeOfDay(hour: endTime!.hour, minute: endTime!.minute);
  }
  
  /// Create a copy with TimeOfDay for endTime
  EndOfCollectionData copyWithTimeOfDay({
    int? id,
    int? farmIdentificationId,
    String? respondentImagePath,
    String? producerSignaturePath,
    String? gpsCoordinates,
    TimeOfDay? endTime,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    int? syncStatus,
  }) {
    return EndOfCollectionData(
      id: id ?? this.id,
      farmIdentificationId: farmIdentificationId ?? this.farmIdentificationId,
      respondentImagePath: respondentImagePath ?? this.respondentImagePath,
      producerSignaturePath: producerSignaturePath ?? this.producerSignaturePath,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      endTime: endTime != null 
          ? DateTime(0, 1, 1, endTime.hour, endTime.minute)
          : this.endTime,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  String toString() {
    return 'EndOfCollectionData('
        'id: $id, '
        'farmIdentificationId: $farmIdentificationId, '
        'respondentImagePath: $respondentImagePath, '
        'producerSignaturePath: $producerSignaturePath, '
        'gpsCoordinates: $gpsCoordinates, '
        'endTime: $endTime, '
        'remarks: $remarks, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'isSynced: $isSynced, '
        'syncStatus: $syncStatus'
        ')';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is EndOfCollectionData &&
        other.id == id &&
        other.farmIdentificationId == farmIdentificationId &&
        other.respondentImagePath == respondentImagePath &&
        other.producerSignaturePath == producerSignaturePath &&
        other.gpsCoordinates == gpsCoordinates &&
        other.endTime == endTime &&
        other.remarks == remarks &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.syncStatus == syncStatus;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      id,
      farmIdentificationId,
      respondentImagePath,
      producerSignaturePath,
      gpsCoordinates,
      endTime,
      remarks,
      createdAt,
      updatedAt,
      isSynced,
      syncStatus,
    );
  }
}