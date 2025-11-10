class IdentificationOfOwnerData {
  final String ownerName;
  final String ownerFirstName;
  final String? nationality;
  final String? specificNationality;
  final String otherNationality;
  final String yearsWithOwner;

  const IdentificationOfOwnerData({
    this.ownerName = '',
    this.ownerFirstName = '',
    this.nationality,
    this.specificNationality,
    this.otherNationality = '',
    this.yearsWithOwner = '',
  });

  IdentificationOfOwnerData copyWith({
    String? ownerName,
    String? ownerFirstName,
    String? nationality,
    String? specificNationality,
    String? otherNationality,
    String? yearsWithOwner,
  }) {
    return IdentificationOfOwnerData(
      ownerName: ownerName ?? this.ownerName,
      ownerFirstName: ownerFirstName ?? this.ownerFirstName,
      nationality: nationality ?? this.nationality,
      specificNationality: specificNationality ?? this.specificNationality,
      otherNationality: otherNationality ?? this.otherNationality,
      yearsWithOwner: yearsWithOwner ?? this.yearsWithOwner,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerName': ownerName,
      'ownerFirstName': ownerFirstName,
      'nationality': nationality,
      'specificNationality': specificNationality,
      'otherNationality': otherNationality,
      'yearsWithOwner': yearsWithOwner,
    };
  }

  factory IdentificationOfOwnerData.fromMap(Map<String, dynamic> map) {
    return IdentificationOfOwnerData(
      ownerName: map['ownerName'] ?? '',
      ownerFirstName: map['ownerFirstName'] ?? '',
      nationality: map['nationality'],
      specificNationality: map['specificNationality'],
      otherNationality: map['otherNationality'] ?? '',
      yearsWithOwner: map['yearsWithOwner'] ?? '',
    );
  }

  static IdentificationOfOwnerData empty() {
    return const IdentificationOfOwnerData();
  }

  bool get isFormComplete {
    return ownerName.isNotEmpty &&
        ownerFirstName.isNotEmpty &&
        nationality != null &&
        (nationality != 'Non-Ghanaian' ||
            (specificNationality != null &&
                (specificNationality != 'Other' ||
                    otherNationality.isNotEmpty))) &&
        yearsWithOwner.isNotEmpty;
  }

  @override
  String toString() {
    return 'IdentificationOfOwnerData(ownerName: $ownerName, ownerFirstName: $ownerFirstName, nationality: $nationality, specificNationality: $specificNationality, otherNationality: $otherNationality, yearsWithOwner: $yearsWithOwner)';
  }
}
