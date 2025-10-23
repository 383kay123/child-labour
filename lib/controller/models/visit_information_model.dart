class VisitInformationData {
  final String? respondentNameCorrect;
  final String? respondentNationality;
  final String? countryOfOrigin;
  final String? isFarmOwner;
  final String? farmOwnershipType;
  final String correctedRespondentName;
  final String respondentOtherNames;
  final String otherCountry;

  const VisitInformationData({
    this.respondentNameCorrect,
    this.respondentNationality,
    this.countryOfOrigin,
    this.isFarmOwner,
    this.farmOwnershipType,
    this.correctedRespondentName = '',
    this.respondentOtherNames = '',
    this.otherCountry = '',
  });

  VisitInformationData copyWith({
    String? respondentNameCorrect,
    String? respondentNationality,
    String? countryOfOrigin,
    String? isFarmOwner,
    String? farmOwnershipType,
    String? correctedRespondentName,
    String? respondentOtherNames,
    String? otherCountry,
  }) {
    return VisitInformationData(
      respondentNameCorrect:
          respondentNameCorrect ?? this.respondentNameCorrect,
      respondentNationality:
          respondentNationality ?? this.respondentNationality,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      isFarmOwner: isFarmOwner ?? this.isFarmOwner,
      farmOwnershipType: farmOwnershipType ?? this.farmOwnershipType,
      correctedRespondentName:
          correctedRespondentName ?? this.correctedRespondentName,
      respondentOtherNames: respondentOtherNames ?? this.respondentOtherNames,
      otherCountry: otherCountry ?? this.otherCountry,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'respondentNameCorrect': respondentNameCorrect,
      'respondentNationality': respondentNationality,
      'countryOfOrigin': countryOfOrigin,
      'isFarmOwner': isFarmOwner,
      'farmOwnershipType': farmOwnershipType,
      'correctedRespondentName': correctedRespondentName,
      'respondentOtherNames': respondentOtherNames,
      'otherCountry': otherCountry,
    };
  }

  factory VisitInformationData.fromMap(Map<String, dynamic> map) {
    return VisitInformationData(
      respondentNameCorrect: map['respondentNameCorrect'],
      respondentNationality: map['respondentNationality'],
      countryOfOrigin: map['countryOfOrigin'],
      isFarmOwner: map['isFarmOwner'],
      farmOwnershipType: map['farmOwnershipType'],
      correctedRespondentName: map['correctedRespondentName'] ?? '',
      respondentOtherNames: map['respondentOtherNames'] ?? '',
      otherCountry: map['otherCountry'] ?? '',
    );
  }

  static VisitInformationData empty() {
    return const VisitInformationData();
  }

  bool get isFormComplete {
    return respondentNameCorrect != null &&
        respondentNationality != null &&
        (respondentNationality != 'Non-Ghanaian' ||
            (countryOfOrigin != null &&
                (countryOfOrigin != 'Other' || otherCountry.isNotEmpty))) &&
        isFarmOwner != null &&
        (isFarmOwner != 'Yes' || farmOwnershipType != null) &&
        (isFarmOwner != 'No' || farmOwnershipType != null);
  }

  @override
  String toString() {
    return 'VisitInformationData(respondentNameCorrect: $respondentNameCorrect, respondentNationality: $respondentNationality, countryOfOrigin: $countryOfOrigin, isFarmOwner: $isFarmOwner, farmOwnershipType: $farmOwnershipType, correctedRespondentName: $correctedRespondentName, respondentOtherNames: $respondentOtherNames, otherCountry: $otherCountry)';
  }
}
