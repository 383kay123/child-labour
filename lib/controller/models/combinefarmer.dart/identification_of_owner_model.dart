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

  /// Converts the model to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'ownerName': ownerName,
      'ownerFirstName': ownerFirstName,
      'nationality': nationality,
      'specificNationality': specificNationality,
      'otherNationality': otherNationality,
      'yearsWithOwner': yearsWithOwner,
    };
  }
  
  /// For backward compatibility
  Map<String, dynamic> toMap() => toJson();

  /// Creates an IdentificationOfOwnerData from a JSON map
  factory IdentificationOfOwnerData.fromJson(Map<String, dynamic> json) {
    return IdentificationOfOwnerData(
      ownerName: json['ownerName'] ?? '',
      ownerFirstName: json['ownerFirstName'] ?? '',
      nationality: json['nationality'],
      specificNationality: json['specificNationality'],
      otherNationality: json['otherNationality'] ?? '',
      yearsWithOwner: json['yearsWithOwner'] ?? '',
    );
  }
  
  /// For backward compatibility
  factory IdentificationOfOwnerData.fromMap(Map<String, dynamic> map) => 
      IdentificationOfOwnerData.fromJson(map);

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
