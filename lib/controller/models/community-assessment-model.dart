import 'dart:convert';

class CommunityAssessmentModel {
  int? id;
  String? communityName;
  String? region;
  String? district;
  String? subCounty;
  String? parish;
  String? village;
  String? gpsCoordinates;
  int? totalHouseholds;
  int? totalPopulation;
  int? totalChildren;
  int? primarySchoolsCount;
  String? schools;
  String? schoolsWithToilets;
  String? schoolsWithFood;
  String? schoolsNoCorporalPunishment;
  String? notes;
  String? rawData;
  String? dateCreated;
  String? dateModified;
  String? createdBy;
  String? modifiedBy;
  int status;
  int? communityScore;
  
  // Question fields
  String? q1;
  String? q2;
  String? q3;
  String? q4;
  String? q5;
  String? q6;
  int? q7a;
  String? q7b;
  String? q7c;
  String? q8;
  String? q9;
  String? q10;

  CommunityAssessmentModel({
    this.id,
    this.communityName,
    this.region,
    this.district,
    this.subCounty,
    this.parish,
    this.village,
    this.gpsCoordinates,
    this.totalHouseholds,
    this.totalPopulation,
    this.totalChildren,
    this.primarySchoolsCount,
    this.schools,
    this.schoolsWithToilets,
    this.schoolsWithFood,
    this.schoolsNoCorporalPunishment,
    this.notes,
    this.rawData,
    this.dateCreated,
    this.dateModified,
    this.createdBy,
    this.modifiedBy,
    this.status = 0,
    this.communityScore,
    this.q1,
    this.q2,
    this.q3,
    this.q4,
    this.q5,
    this.q6,
    this.q7a,
    this.q7b,
    this.q7c,
    this.q8,
    this.q9,
    this.q10,
  });

  factory CommunityAssessmentModel.fromMap(Map<String, dynamic> map) {
    return CommunityAssessmentModel(
      id: map["id"],
      communityName: map["community_name"],
      region: map["region"],
      district: map["district"],
      subCounty: map["sub_county"],
      parish: map["parish"],
      village: map["village"],
      gpsCoordinates: map["gps_coordinates"],
      totalHouseholds: map["total_households"],
      totalPopulation: map["total_population"],
      totalChildren: map["total_children"],
      primarySchoolsCount: map["primary_schools_count"],
      schools: map["schools"],
      schoolsWithToilets: map["schools_with_toilets"],
      schoolsWithFood: map["schools_with_food"],
      schoolsNoCorporalPunishment: map["schools_no_corporal_punishment"],
      notes: map["notes"],
      rawData: map["raw_data"],
      dateCreated: map["date_created"] ?? map["dateCreated"],
      dateModified: map["date_modified"] ?? map["dateModified"],
      createdBy: map["created_by"] ?? map["createdBy"],
      modifiedBy: map["modified_by"] ?? map["modifiedBy"],
      status: map["status"] ?? 0,
      communityScore: map["community_score"] ?? map["communityScore"],
      q1: map["q1"],
      q2: map["q2"],
      q3: map["q3"],
      q4: map["q4"],
      q5: map["q5"],
      q6: map["q6"],
      q7a: map["q7a"],
      q7b: map["q7b"],
      q7c: map["q7c"],
      q8: map["q8"],
      q9: map["q9"],
      q10: map["q10"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "community_name": communityName,
      "region": region,
      "district": district,
      "sub_county": subCounty,
      "parish": parish,
      "village": village,
      "gps_coordinates": gpsCoordinates,
      "total_households": totalHouseholds,
      "total_population": totalPopulation,
      "total_children": totalChildren,
      "primary_schools_count": primarySchoolsCount,
      "schools": schools,
      "schools_with_toilets": schoolsWithToilets,
      "schools_with_food": schoolsWithFood,
      "schools_no_corporal_punishment": schoolsNoCorporalPunishment,
      "notes": notes,
      "raw_data": rawData,
      "community_score": communityScore,
      "q1": q1,
      "q2": q2,
      "q3": q3,
      "q4": q4,
      "q5": q5,
      "q6": q6,
      "q7a": q7a,
      "q7b": q7b,
      "q7c": q7c,
      "q8": q8,
      "q9": q9,
      "q10": q10,
      "date_created": dateCreated,
      "date_modified": dateModified,
      "created_by": createdBy,
      "modified_by": modifiedBy,
      "status": status,
    };
  }

  CommunityAssessmentModel copyWith({
    int? id,
    String? communityName,
    String? region,
    String? district,
    String? subCounty,
    String? parish,
    String? village,
    String? gpsCoordinates,
    int? totalHouseholds,
    int? totalPopulation,
    int? totalChildren,
    int? primarySchoolsCount,
    String? schools,
    String? schoolsWithToilets,
    String? schoolsWithFood,
    String? schoolsNoCorporalPunishment,
    String? notes,
    String? rawData,
    String? dateCreated,
    String? dateModified,
    String? createdBy,
    String? modifiedBy,
    int? status,
    int? communityScore,
    String? q1,
    String? q2,
    String? q3,
    String? q4,
    String? q5,
    String? q6,
    int? q7a,
    String? q7b,
    String? q7c,
    String? q8,
    String? q9,
    String? q10,
  }) {
    return CommunityAssessmentModel(
      id: id ?? this.id,
      communityName: communityName ?? this.communityName,
      region: region ?? this.region,
      district: district ?? this.district,
      subCounty: subCounty ?? this.subCounty,
      parish: parish ?? this.parish,
      village: village ?? this.village,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      totalHouseholds: totalHouseholds ?? this.totalHouseholds,
      totalPopulation: totalPopulation ?? this.totalPopulation,
      totalChildren: totalChildren ?? this.totalChildren,
      primarySchoolsCount: primarySchoolsCount ?? this.primarySchoolsCount,
      schools: schools ?? this.schools,
      schoolsWithToilets: schoolsWithToilets ?? this.schoolsWithToilets,
      schoolsWithFood: schoolsWithFood ?? this.schoolsWithFood,
      schoolsNoCorporalPunishment: schoolsNoCorporalPunishment ?? this.schoolsNoCorporalPunishment,
      notes: notes ?? this.notes,
      rawData: rawData ?? this.rawData,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      status: status ?? this.status,
      communityScore: communityScore ?? this.communityScore,
      q1: q1 ?? this.q1,
      q2: q2 ?? this.q2,
      q3: q3 ?? this.q3,
      q4: q4 ?? this.q4,
      q5: q5 ?? this.q5,
      q6: q6 ?? this.q6,
      q7a: q7a ?? this.q7a,
      q7b: q7b ?? this.q7b,
      q7c: q7c ?? this.q7c,
      q8: q8 ?? this.q8,
      q9: q9 ?? this.q9,
      q10: q10 ?? this.q10,
    );
  }

  // Helper method to convert model to database map with all fields
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'community_name': communityName,
      'region': region,
      'district': district,
      'sub_county': subCounty,
      'parish': parish,
      'village': village,
      'gps_coordinates': gpsCoordinates,
      'total_households': totalHouseholds,
      'total_population': totalPopulation,
      'total_children': totalChildren,
      'primary_schools_count': primarySchoolsCount,
      'schools': schools,
      'schools_with_toilets': schoolsWithToilets,
      'schools_with_food': schoolsWithFood,
      'schools_no_corporal_punishment': schoolsNoCorporalPunishment,
      'notes': notes,
      'raw_data': rawData,
      'date_created': dateCreated ?? DateTime.now().toIso8601String(),
      'date_modified': dateModified,
      'created_by': createdBy,
      'modified_by': modifiedBy,
      'status': status,
      'community_score': communityScore,
      'q1': q1,
      'q2': q2,
      'q3': q3,
      'q4': q4,
      'q5': q5,
      'q6': q6,
      'q7a': q7a,
      'q7b': q7b,
      'q7c': q7c,
      'q8': q8,
      'q9': q9,
      'q10': q10,
    };
  }
}