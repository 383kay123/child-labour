class SurveyResponse {
  final int? id;
  final DateTime createdAt;
  DateTime updatedAt;
  String status; // 'draft', 'in_progress', 'completed', 'submitted'
  
  // Section data
  Map<String, dynamic> consentData;
  Map<String, dynamic> farmerData;
  Map<String, dynamic> remediationData;
  Map<String, dynamic> sensitizationData;
  Map<String, dynamic> childrenData;
  Map<String, dynamic> endCollectionData;

  SurveyResponse({
    this.id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status = 'draft',
    this.consentData = const {},
    this.farmerData = const {},
    this.remediationData = const {},
    this.sensitizationData = const {},
    this.childrenData = const {},
    this.endCollectionData = const {},
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert a SurveyResponse into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
      'consentData': consentData,
      'farmerData': farmerData,
      'remediationData': remediationData,
      'sensitizationData': sensitizationData,
      'childrenData': childrenData,
      'endCollectionData': endCollectionData,
    };
  }

  // Create a SurveyResponse from a Map
  factory SurveyResponse.fromMap(Map<String, dynamic> map) {
    return SurveyResponse(
      id: map['id'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      status: map['status'] ?? 'draft',
      consentData: Map<String, dynamic>.from(map['consentData'] ?? {}),
      farmerData: Map<String, dynamic>.from(map['farmerData'] ?? {}),
      remediationData: Map<String, dynamic>.from(map['remediationData'] ?? {}),
      sensitizationData: Map<String, dynamic>.from(map['sensitizationData'] ?? {}),
      childrenData: Map<String, dynamic>.from(map['childrenData'] ?? {}),
      endCollectionData: Map<String, dynamic>.from(map['endCollectionData'] ?? {}),
    );
  }

  // Create a copy of the SurveyResponse with updated fields
  SurveyResponse copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    Map<String, dynamic>? consentData,
    Map<String, dynamic>? farmerData,
    Map<String, dynamic>? remediationData,
    Map<String, dynamic>? sensitizationData,
    Map<String, dynamic>? childrenData,
    Map<String, dynamic>? endCollectionData,
  }) {
    return SurveyResponse(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      status: status ?? this.status,
      consentData: consentData ?? this.consentData,
      farmerData: farmerData ?? this.farmerData,
      remediationData: remediationData ?? this.remediationData,
      sensitizationData: sensitizationData ?? this.sensitizationData,
      childrenData: childrenData ?? this.childrenData,
      endCollectionData: endCollectionData ?? this.endCollectionData,
    );
  }
}
