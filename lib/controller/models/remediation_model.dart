class RemediationModel {
  // School Fees Information
  final bool? hasSchoolFees;
  
  // Support Options
  final bool childProtectionEducation;
  final bool schoolKitsSupport;
  final bool igaSupport;
  final bool otherSupport;
  final String? otherSupportDetails;
  
  // Community Action
  final String? communityAction;
  final String? otherCommunityActionDetails;

  const RemediationModel({
    this.hasSchoolFees,
    this.childProtectionEducation = false,
    this.schoolKitsSupport = false,
    this.igaSupport = false,
    this.otherSupport = false,
    this.otherSupportDetails,
    this.communityAction,
    this.otherCommunityActionDetails,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'hasSchoolFees': hasSchoolFees == null ? null : (hasSchoolFees! ? 1 : 0),
      'childProtectionEducation': childProtectionEducation ? 1 : 0,
      'schoolKitsSupport': schoolKitsSupport ? 1 : 0,
      'igaSupport': igaSupport ? 1 : 0,
      'otherSupport': otherSupport ? 1 : 0,
      'otherSupportDetails': otherSupportDetails,
      'communityAction': communityAction,
      'otherCommunityActionDetails': otherCommunityActionDetails,
    };
  }

  // Create from Map (for database retrieval)
  factory RemediationModel.fromMap(Map<String, dynamic> map) {
    return RemediationModel(
      hasSchoolFees: map['hasSchoolFees'] == null 
          ? null 
          : map['hasSchoolFees'] == 1,
      childProtectionEducation: map['childProtectionEducation'] == 1,
      schoolKitsSupport: map['schoolKitsSupport'] == 1,
      igaSupport: map['igaSupport'] == 1,
      otherSupport: map['otherSupport'] == 1,
      otherSupportDetails: map['otherSupportDetails'],
      communityAction: map['communityAction'],
      otherCommunityActionDetails: map['otherCommunityActionDetails'],
    );
  }

  // Create a copy with some fields updated
  RemediationModel copyWith({
    bool? hasSchoolFees,
    bool? childProtectionEducation,
    bool? schoolKitsSupport,
    bool? igaSupport,
    bool? otherSupport,
    String? otherSupportDetails,
    String? communityAction,
    String? otherCommunityActionDetails,
  }) {
    return RemediationModel(
      hasSchoolFees: hasSchoolFees ?? this.hasSchoolFees,
      childProtectionEducation: childProtectionEducation ?? this.childProtectionEducation,
      schoolKitsSupport: schoolKitsSupport ?? this.schoolKitsSupport,
      igaSupport: igaSupport ?? this.igaSupport,
      otherSupport: otherSupport ?? this.otherSupport,
      otherSupportDetails: otherSupportDetails ?? this.otherSupportDetails,
      communityAction: communityAction ?? this.communityAction,
      otherCommunityActionDetails: otherCommunityActionDetails ?? this.otherCommunityActionDetails,
    );
  }

  // Create an empty instance
  static RemediationModel empty() => const RemediationModel();

  // Check if the model is empty
  bool get isEmpty => this == empty();

  // Check if the model is not empty
  bool get isNotEmpty => this != empty();

  @override
  String toString() {
    return 'RemediationModel{\n'
           '  hasSchoolFees: $hasSchoolFees,\n'
           '  childProtectionEducation: $childProtectionEducation,\n'
           '  schoolKitsSupport: $schoolKitsSupport,\n'
           '  igaSupport: $igaSupport,\n'
           '  otherSupport: $otherSupport,\n'
           '  otherSupportDetails: $otherSupportDetails,\n'
           '  communityAction: $communityAction,\n'
           '  otherCommunityActionDetails: $otherCommunityActionDetails\n'
           '}';
  }
}
