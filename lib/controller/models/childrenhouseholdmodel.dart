class ChildrenHouseholdModel {
  final String? hasChildrenInHousehold;
  final int numberOfChildren;
  final int children5To17;
  final List<Map<String, dynamic>> childrenDetails;
  final DateTime? timestamp;

  ChildrenHouseholdModel({
    this.hasChildrenInHousehold,
    this.numberOfChildren = 0,
    this.children5To17 = 0,
    List<Map<String, dynamic>>? childrenDetails,
    this.timestamp,
  }) : childrenDetails = childrenDetails ?? [];

  factory ChildrenHouseholdModel.empty() {
    return ChildrenHouseholdModel(
      hasChildrenInHousehold: null,
      numberOfChildren: 0,
      children5To17: 0,
      childrenDetails: [],
      timestamp: DateTime.now(),
    );
  }

  factory ChildrenHouseholdModel.fromJson(Map<String, dynamic> json) {
    return ChildrenHouseholdModel(
      hasChildrenInHousehold: json['hasChildrenInHousehold'],
      numberOfChildren: json['numberOfChildren'] ?? 0,
      children5To17: json['children5To17'] ?? 0,
      childrenDetails:
          List<Map<String, dynamic>>.from(json['childrenDetails'] ?? []),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasChildrenInHousehold': hasChildrenInHousehold,
      'numberOfChildren': numberOfChildren,
      'children5To17': children5To17,
      'childrenDetails': childrenDetails,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  ChildrenHouseholdModel copyWith({
    String? hasChildrenInHousehold,
    int? numberOfChildren,
    int? children5To17,
    List<Map<String, dynamic>>? childrenDetails,
    DateTime? timestamp,
  }) {
    return ChildrenHouseholdModel(
      hasChildrenInHousehold:
          hasChildrenInHousehold ?? this.hasChildrenInHousehold,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      children5To17: children5To17 ?? this.children5To17,
      childrenDetails: childrenDetails ?? this.childrenDetails,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  bool get hasChildren => hasChildrenInHousehold == 'Yes';

  bool get hasChildren5To17 => hasChildren && children5To17 > 0;

  bool get allChildrenDetailsCollected =>
      childrenDetails.length >= children5To17;

  bool get isValid {
    if (hasChildrenInHousehold == null) return false;
    if (!hasChildren) return true;
    if (numberOfChildren <= 0) return false;
    if (children5To17 < 0) return false;
    if (children5To17 > numberOfChildren) return false;
    return true;
  }

  @override
  String toString() {
    return 'ChildrenHouseholdModel('
        'hasChildrenInHousehold: $hasChildrenInHousehold, '
        'numberOfChildren: $numberOfChildren, '
        'children5To17: $children5To17, '
        'childrenDetails: ${childrenDetails.length} children, '
        'timestamp: $timestamp'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildrenHouseholdModel &&
        other.hasChildrenInHousehold == hasChildrenInHousehold &&
        other.numberOfChildren == numberOfChildren &&
        other.children5To17 == children5To17 &&
        other.childrenDetails.length == childrenDetails.length &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      hasChildrenInHousehold,
      numberOfChildren,
      children5To17,
      childrenDetails.length,
      timestamp,
    );
  }
}
