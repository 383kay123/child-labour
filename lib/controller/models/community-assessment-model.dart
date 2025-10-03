class CommunityAssessmentModel {
  int? id;
  String? communityName;
  int? communityScore;
  String q1;
  String q2;
  String q3;
  String q4;
  String q5;
  String q6;
  int q7a;
  String q7b;
  String q7c;
  String q8;
  String q9;
  String q10;
  int status;

  CommunityAssessmentModel({
    this.id,
    this.communityName,
    this.communityScore,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.q5,
    required this.q6,
    required this.q7a,
    required this.q7b,
    required this.q7c,
    required this.q8,
    required this.q9,
    required this.q10,
    this.status = 0,
  });

  factory CommunityAssessmentModel.fromMap(Map<String, dynamic> map) {
    return CommunityAssessmentModel(
      id: map["id"],
      communityName: map["communityName"],
      communityScore: map["communityScore"],
      q1: map["q1"] ?? "",
      q2: map["q2"] ?? "",
      q3: map["q3"] ?? "",
      q4: map["q4"] ?? "",
      q5: map["q5"] ?? "",
      q6: map["q6"] ?? "",
      q7a: map["q7a"] ?? "",
      q7b: map["q7b"] ?? "",
      q7c: map["q7c"] ?? "",
      q8: map["q8"] ?? "",
      q9: map["q9"] ?? "",
      q10: map["q10"] ?? "",
      status: map["status"] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "communityName": communityName,
      "communityScore": communityScore,
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
      "status": status,
    };
  }

  CommunityAssessmentModel copyWith({
    int? id,
    String? communityName,
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
    int? status,
  }) {
    return CommunityAssessmentModel(
      id: id ?? this.id,
      communityName: communityName ?? this.communityName,
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
      status: status ?? this.status,
    );
  }
}
