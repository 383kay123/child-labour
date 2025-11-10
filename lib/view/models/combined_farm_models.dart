import 'package:flutter/foundation.dart';

/// Model for visit information data
class VisitInformationData {
  final String? respondentNameCorrect;
  final String correctedRespondentName;
  final String respondentOtherNames;
  final String? respondentNationality;
  final String? countryOfOrigin;
  final String otherCountry;
  final bool isFarmOwner;
  final String? farmOwnershipType;

  VisitInformationData({
    required this.respondentNameCorrect,
    this.correctedRespondentName = '',
    this.respondentOtherNames = '',
    required this.respondentNationality,
    required this.countryOfOrigin,
    this.otherCountry = '',
    required this.isFarmOwner,
    this.farmOwnershipType,
  });
}

/// Model for owner identification data
class IdentificationOfOwnerData {
  final String ownerName;
  final String ownerFirstName;
  final String? nationality;
  final String? specificNationality;
  final String otherNationality;
  final String yearsWithOwner;

  IdentificationOfOwnerData({
    required this.ownerName,
    required this.ownerFirstName,
    required this.nationality,
    required this.specificNationality,
    this.otherNationality = '',
    required this.yearsWithOwner,
  });
}

/// Model for worker details in the farm
class WorkersInFarmData {
  final bool hasRecruitedWorker;
  final bool everRecruitedWorker;
  final bool permanentLabor;
  final bool casualLabor;
  final String? workerAgreementType;
  final String otherAgreement;
  final String? tasksClarified;
  final String? additionalTasks;
  final String? refusalAction;
  final String? salaryPaymentFrequency;
  final Map<String, String?> agreementResponses;

  WorkersInFarmData({
    required this.hasRecruitedWorker,
    required this.everRecruitedWorker,
    required this.permanentLabor,
    required this.casualLabor,
    required this.workerAgreementType,
    this.otherAgreement = '',
    required this.tasksClarified,
    required this.additionalTasks,
    required this.refusalAction,
    required this.salaryPaymentFrequency,
    required this.agreementResponses,
  });
}

/// Model for household member details
class HouseholdMemberDetails {
  final String? gender;
  final String? nationality;
  final String? selectedCountry;
  final String otherCountry;
  final int? yearOfBirth;
  final String? relationshipToRespondent;
  final bool isResponsibleForFarm;
  final bool isEngagedInFarmWork;

  const HouseholdMemberDetails({
    required this.gender,
    required this.nationality,
    required this.selectedCountry,
    this.otherCountry = '',
    required this.yearOfBirth,
    required this.relationshipToRespondent,
    required this.isResponsibleForFarm,
    required this.isEngagedInFarmWork,
  });
}

/// Model for household member
class HouseholdMember {
  final String name;
  final HouseholdMemberDetails producerDetails;

  const HouseholdMember({
    required this.name,
    required this.producerDetails,
  });
}

/// Model for adults information data
class AdultsInformationData {
  final int? numberOfAdults;
  final List<HouseholdMember> members;

  AdultsInformationData({
    required this.numberOfAdults,
    required this.members,
  });
}
