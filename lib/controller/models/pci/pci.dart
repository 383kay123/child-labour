class SocietyData {
  final int enumerator;
  final int society;
  final double accessToProtectedWater;
  final double hireAdultLabourers;
  final double awarenessRaisingSession;
  final double womenLeaders;
  final double preSchool;
  final double primarySchool;
  final double separateToilets;
  final double provideFood;
  final double scholarships;
  final double corporalPunishment;

  SocietyData({
    required this.enumerator,
    required this.society,
    required this.accessToProtectedWater,
    required this.hireAdultLabourers,
    required this.awarenessRaisingSession,
    required this.womenLeaders,
    required this.preSchool,
    required this.primarySchool,
    required this.separateToilets,
    required this.provideFood,
    required this.scholarships,
    required this.corporalPunishment,
  });

  factory SocietyData.fromJson(Map<String, dynamic> json) {
    return SocietyData(
      enumerator: json['enumerator'] as int,
      society: json['society'] as int,
      accessToProtectedWater: (json['access_to_protected_water'] as num).toDouble(),
      hireAdultLabourers: (json['hire_adult_labourers'] as num).toDouble(),
      awarenessRaisingSession: (json['awareness_raising_session'] as num).toDouble(),
      womenLeaders: (json['women_leaders'] as num).toDouble(),
      preSchool: (json['pre_school'] as num).toDouble(),
      primarySchool: (json['primary_school'] as num).toDouble(),
      separateToilets: (json['separate_toilets'] as num).toDouble(),
      provideFood: (json['provide_food'] as num).toDouble(),
      scholarships: (json['scholarships'] as num).toDouble(),
      corporalPunishment: (json['corporal_punishment'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enumerator': enumerator,
      'society': society,
      'access_to_protected_water': accessToProtectedWater,
      'hire_adult_labourers': hireAdultLabourers,
      'awareness_raising_session': awarenessRaisingSession,
      'women_leaders': womenLeaders,
      'pre_school': preSchool,
      'primary_school': primarySchool,
      'separate_toilets': separateToilets,
      'provide_food': provideFood,
      'scholarships': scholarships,
      'corporal_punishment': corporalPunishment,
    };
  }

  @override
  String toString() {
    return 'SocietyData(enumerator: $enumerator, society: $society, accessToProtectedWater: $accessToProtectedWater, hireAdultLabourers: $hireAdultLabourers, awarenessRaisingSession: $awarenessRaisingSession, womenLeaders: $womenLeaders, preSchool: $preSchool, primarySchool: $primarySchool, separateToilets: $separateToilets, provideFood: $provideFood, scholarships: $scholarships, corporalPunishment: $corporalPunishment)';
  }

}