/// Model class for society data
class SocietyData {
  final int? id;
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
    this.id,
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

  // Convert a SocietyData into a Map
  Map<String, dynamic> toMap() {
    return {
      SocietyDataColumns.id: id,
      SocietyDataColumns.enumerator: enumerator,
      SocietyDataColumns.society: society,
      SocietyDataColumns.accessToProtectedWater: accessToProtectedWater,
      SocietyDataColumns.hireAdultLabourers: hireAdultLabourers,
      SocietyDataColumns.awarenessRaisingSession: awarenessRaisingSession,
      SocietyDataColumns.womenLeaders: womenLeaders,
      SocietyDataColumns.preSchool: preSchool,
      SocietyDataColumns.primarySchool: primarySchool,
      SocietyDataColumns.separateToilets: separateToilets,
      SocietyDataColumns.provideFood: provideFood,
      SocietyDataColumns.scholarships: scholarships,
      SocietyDataColumns.corporalPunishment: corporalPunishment,
    };
  }

  // Create a SocietyData from a Map
  factory SocietyData.fromMap(Map<String, dynamic> map) {
    return SocietyData(
      id: map[SocietyDataColumns.id],
      enumerator: map[SocietyDataColumns.enumerator],
      society: map[SocietyDataColumns.society],
      accessToProtectedWater: map[SocietyDataColumns.accessToProtectedWater].toDouble(),
      hireAdultLabourers: map[SocietyDataColumns.hireAdultLabourers].toDouble(),
      awarenessRaisingSession: map[SocietyDataColumns.awarenessRaisingSession].toDouble(),
      womenLeaders: map[SocietyDataColumns.womenLeaders].toDouble(),
      preSchool: map[SocietyDataColumns.preSchool].toDouble(),
      primarySchool: map[SocietyDataColumns.primarySchool].toDouble(),
      separateToilets: map[SocietyDataColumns.separateToilets].toDouble(),
      provideFood: map[SocietyDataColumns.provideFood].toDouble(),
      scholarships: map[SocietyDataColumns.scholarships].toDouble(),
      corporalPunishment: map[SocietyDataColumns.corporalPunishment].toDouble(),
    );
  }
}

/// Contains the column names for the society_data table
class SocietyDataColumns {
  static const String tableName = 'society_data';
  static const String id = '_id';
  static const String enumerator = 'enumerator';
  static const String society = 'society';
  static const String accessToProtectedWater = 'access_to_protected_water';
  static const String hireAdultLabourers = 'hire_adult_labourers';
  static const String awarenessRaisingSession = 'awareness_raising_session';
  static const String womenLeaders = 'women_leaders';
  static const String preSchool = 'pre_school';
  static const String primarySchool = 'primary_school';
  static const String separateToilets = 'separate_toilets';
  static const String provideFood = 'provide_food';
  static const String scholarships = 'scholarships';
  static const String corporalPunishment = 'corporal_punishment';
}
