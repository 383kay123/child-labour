import 'package:human_rights_monitor/controller/models/end_of_collection_model.dart';

class EndOfCollectionData {
  final DateTime? endTime;
  final String? interviewerName;
  final String? interviewerSignature;
  final String? supervisorName;
  final String? supervisorSignature;
  final String? additionalNotes;
  final bool isComplete;

  EndOfCollectionData({
    this.endTime,
    this.interviewerName,
    this.interviewerSignature,
    this.supervisorName,
    this.supervisorSignature,
    this.additionalNotes,
    this.isComplete = false,
  });

  // Create a copyWith method for immutability
  EndOfCollectionData copyWith({
    DateTime? endTime,
    String? interviewerName,
    String? interviewerSignature,
    String? supervisorName,
    String? supervisorSignature,
    String? additionalNotes,
    bool? isComplete,
  }) {
    return EndOfCollectionData(
      endTime: endTime ?? this.endTime,
      interviewerName: interviewerName ?? this.interviewerName,
      interviewerSignature: interviewerSignature ?? this.interviewerSignature,
      supervisorName: supervisorName ?? this.supervisorName,
      supervisorSignature: supervisorSignature ?? this.supervisorSignature,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'endTime': endTime?.toIso8601String(),
      'interviewerName': interviewerName,
      'interviewerSignature': interviewerSignature,
      'supervisorName': supervisorName,
      'supervisorSignature': supervisorSignature,
      'additionalNotes': additionalNotes,
      'isComplete': isComplete,
    };
  }

  factory EndOfCollectionData.fromJson(Map<String, dynamic> json) {
    return EndOfCollectionData(
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      interviewerName: json['interviewerName'],
      interviewerSignature: json['interviewerSignature'],
      supervisorName: json['supervisorName'],
      supervisorSignature: json['supervisorSignature'],
      additionalNotes: json['additionalNotes'],
      isComplete: json['isComplete'] ?? false,
    );
  }

  /// Converts this EndOfCollectionData to an EndOfCollectionModel
  /// Converts this EndOfCollectionData to an EndOfCollectionModel
  EndOfCollectionModel toModel() {
    return EndOfCollectionModel(
      endTime: endTime,
      remarks: additionalNotes,
      // Map the interviewer signature to producer signature path if available
      producerSignaturePath: interviewerSignature,
      // For respondent image path, you might want to handle this differently
      // based on your app's requirements
      respondentImagePath: null, // You might want to set this from your UI state
      // Set other required fields with default or null values
      latitude: null,
      longitude: null,
      gpsCoordinates: null,
      isSynced: false,
    );
  }
}
