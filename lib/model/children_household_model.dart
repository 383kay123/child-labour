class ChildrenHouseholdModel {
  // Validation method to check if all required fields are filled
  bool get isValid {
    // Check if required fields are not null/empty
    if (hasChildrenInHousehold == null || hasChildrenInHousehold!.isEmpty) {
      return false;
    }
    
    // If there are children, verify the counts are valid
    if (hasChildrenInHousehold == 'Yes') {
      if (numberOfChildren <= 0 || children5To17 < 0) {
        return false;
      }
      
      // Validate children details if they exist
      if (childrenDetails.isNotEmpty && childrenDetails.length != numberOfChildren) {
        return false;
      }
    }
    
    return true;
  }
  final String? hasChildrenInHousehold;
  final int numberOfChildren;
  final int children5To17;
  final List<Map<String, dynamic>> childrenDetails;
  final bool isEditing;

  ChildrenHouseholdModel({
    this.hasChildrenInHousehold,
    this.numberOfChildren = 0,
    this.children5To17 = 0,
    List<Map<String, dynamic>>? childrenDetails,
    this.isEditing = false,
  }) : childrenDetails = childrenDetails ?? [];

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'hasChildrenInHousehold': hasChildrenInHousehold,
      'numberOfChildren': numberOfChildren,
      'children5To17': children5To17,
      'childrenDetails': childrenDetails,
      'isEditing': isEditing,
    };
  }

  // Create model from JSON
  factory ChildrenHouseholdModel.fromJson(Map<String, dynamic> json) {
    return ChildrenHouseholdModel(
      hasChildrenInHousehold: json['hasChildrenInHousehold'],
      numberOfChildren: json['numberOfChildren'] ?? 0,
      children5To17: json['children5To17'] ?? 0,
      childrenDetails: List<Map<String, dynamic>>.from(json['childrenDetails'] ?? []),
      isEditing: json['isEditing'] ?? false,
    );
  }

  // Validate if all required fields are filled
  bool validate() {
    return isValid;
  }

  // Create a copy with some updated values
  ChildrenHouseholdModel copyWith({
    String? hasChildrenInHousehold,
    int? numberOfChildren,
    int? children5To17,
    List<Map<String, dynamic>>? childrenDetails,
    bool? isEditing,
  }) {
    return ChildrenHouseholdModel(
      hasChildrenInHousehold: hasChildrenInHousehold ?? this.hasChildrenInHousehold,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      children5To17: children5To17 ?? this.children5To17,
      childrenDetails: childrenDetails ?? this.childrenDetails,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  // Create an empty instance
  factory ChildrenHouseholdModel.empty() {
    return ChildrenHouseholdModel();
  }
}
