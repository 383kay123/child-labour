import 'package:human_rights_monitor/controller/models/remediation_model.dart';

class RemediationData {
  final bool? owesSchoolFees;
  final bool childProtectionEducation;
  final bool schoolKitsSupport;
  final bool igaSupport;
  final bool otherSupport;
  final String? otherSupportDetails;
  final String? communityAction;
  final String? otherCommunityActionDetails;

  const RemediationData({
    this.owesSchoolFees,
    this.childProtectionEducation = false,
    this.schoolKitsSupport = false,
    this.igaSupport = false,
    this.otherSupport = false,
    this.otherSupportDetails,
    this.communityAction,
    this.otherCommunityActionDetails,
  });

  // Create a copyWith method for immutability
  RemediationData copyWith({
    bool? owesSchoolFees,
    bool? childProtectionEducation,
    bool? schoolKitsSupport,
    bool? igaSupport,
    bool? otherSupport,
    String? otherSupportDetails,
    String? communityAction,
    String? otherCommunityActionDetails,
  }) {
    return RemediationData(
      owesSchoolFees: owesSchoolFees ?? this.owesSchoolFees,
      childProtectionEducation: childProtectionEducation ?? this.childProtectionEducation,
      schoolKitsSupport: schoolKitsSupport ?? this.schoolKitsSupport,
      igaSupport: igaSupport ?? this.igaSupport,
      otherSupport: otherSupport ?? this.otherSupport,
      otherSupportDetails: otherSupportDetails ?? this.otherSupportDetails,
      communityAction: communityAction ?? this.communityAction,
      otherCommunityActionDetails: otherCommunityActionDetails ?? this.otherCommunityActionDetails,
    );
  }
  
  // Convert to database model
  RemediationModel toModel() {
    return RemediationModel(
      hasSchoolFees: owesSchoolFees,
      childProtectionEducation: childProtectionEducation,
      schoolKitsSupport: schoolKitsSupport,
      igaSupport: igaSupport,
      otherSupport: otherSupport,
      otherSupportDetails: otherSupportDetails,
      communityAction: communityAction,
      otherCommunityActionDetails: otherCommunityActionDetails,
    );
  }
}
