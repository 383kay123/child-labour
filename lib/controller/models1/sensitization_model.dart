/// Data model for the Sensitization form
class SensitizationData {
  bool hasUnderstood;
  String signature;
  DateTime date;

  // Alias for hasUnderstood to maintain backward compatibility
  bool get isAcknowledged => hasUnderstood;

  SensitizationData({
    this.hasUnderstood = false,
    this.signature = '',
    DateTime? date,
    // For backward compatibility
    bool? isAcknowledged,
  }) : date = date ?? DateTime.now() {
    if (isAcknowledged != null) {
      hasUnderstood = isAcknowledged;
    }
  }

  // Convert to Map for storage
  Map<String, dynamic> toJson() => {
        'hasUnderstood': hasUnderstood,
        'signature': signature,
        'date': date.toIso8601String(),
      };

  // Create from Map
  factory SensitizationData.fromJson(Map<String, dynamic> json) {
    return SensitizationData(
      hasUnderstood: json['hasUnderstood'] ?? false,
      signature: json['signature'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  // Create a copy of this object with the given fields replaced by the non-null values
  SensitizationData copyWith({
    bool? hasUnderstood,
    String? signature,
    DateTime? date,
  }) {
    return SensitizationData(
      hasUnderstood: hasUnderstood ?? this.hasUnderstood,
      signature: signature ?? this.signature,
      date: date ?? this.date,
    );
  }
}

/// Contains all the static content for the Sensitization page.
class SensitizationContent {
  static const String title = 'Sensitization on Child Labor and Safe Practices';
  static const String description = 'This section provides important information about child labor laws, safe working conditions, and responsible practices for farmers and employers.';
  
  // Good Parenting Section
  static const String goodParentingTitle = 'GOOD PARENTING';
  static const List<String> goodParentingBullets = [
    'Ensure children attend school regularly',
    'Provide a safe and nurturing environment at home',
    'Encourage children\'s participation in age-appropriate activities',
    'Be aware of your child\'s daily activities and whereabouts',
  ];

  // Child Protection Section
  static const String childProtectionTitle = 'CHILD PROTECTION';
  static const List<String> childProtectionBullets = [
    'Report any cases of child labor to local authorities',
    'Support community initiatives against child labor',
    'Educate others about children\'s rights',
    'Promote safe and healthy environments for all children',
  ];

  // Safe Labor Practices Section
  static const String safeLabourPracticesTitle = 'SAFE LABOR PRACTICES';
  static const List<String> safeLabourPracticesBullets = [
    'Ensure all workers are of legal working age',
    'Provide proper training and safety equipment',
    'Maintain safe working conditions',
    'Follow all labor laws and regulations',
  ];
}
