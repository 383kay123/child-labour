/// Represents the data collected from the Sensitization Questions form.
class SensitizationQuestionsData {
  /// Whether the household has been sensitized
  final bool? hasSensitizedHousehold;

  /// Whether sensitization on protection was conducted
  final bool? hasSensitizedOnProtection;

  /// Whether sensitization on safe labor was conducted
  final bool? hasSensitizedOnSafeLabour;

  /// Number of female adults present during sensitization
  final String femaleAdultsCount;

  /// Number of male adults present during sensitization
  final String maleAdultsCount;

  /// Whether consent was given for taking pictures
  final bool? consentForPicture;

  /// Reason for not giving consent (if applicable)
  final String consentReason;

  /// Path to the sensitization session image
  final String? sensitizationImagePath;

  /// Path to the household with user image
  final String? householdWithUserImagePath;

  /// Observations about parents' reaction to sensitization
  final String parentsReaction;

  /// Timestamp when the form was submitted
  final DateTime submittedAt;

  /// Creates a new instance of [SensitizationQuestionsData].
  SensitizationQuestionsData({
    this.hasSensitizedHousehold,
    this.hasSensitizedOnProtection,
    this.hasSensitizedOnSafeLabour,
    this.femaleAdultsCount = '',
    this.maleAdultsCount = '',
    this.consentForPicture,
    this.consentReason = '',
    this.sensitizationImagePath,
    this.householdWithUserImagePath,
    this.parentsReaction = '',
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();

  /// Creates an empty instance with default values.
  factory SensitizationQuestionsData.empty() {
    return SensitizationQuestionsData();
  }

  /// Creates a copy of this [SensitizationQuestionsData] with the given fields replaced.
  SensitizationQuestionsData copyWith({
    bool? hasSensitizedHousehold,
    bool? hasSensitizedOnProtection,
    bool? hasSensitizedOnSafeLabour,
    String? femaleAdultsCount,
    String? maleAdultsCount,
    bool? consentForPicture,
    String? consentReason,
    String? sensitizationImagePath,
    String? householdWithUserImagePath,
    String? parentsReaction,
    DateTime? submittedAt,
  }) {
    return SensitizationQuestionsData(
      hasSensitizedHousehold:
          hasSensitizedHousehold ?? this.hasSensitizedHousehold,
      hasSensitizedOnProtection:
          hasSensitizedOnProtection ?? this.hasSensitizedOnProtection,
      hasSensitizedOnSafeLabour:
          hasSensitizedOnSafeLabour ?? this.hasSensitizedOnSafeLabour,
      femaleAdultsCount: femaleAdultsCount ?? this.femaleAdultsCount,
      maleAdultsCount: maleAdultsCount ?? this.maleAdultsCount,
      consentForPicture: consentForPicture ?? this.consentForPicture,
      consentReason: consentReason ?? this.consentReason,
      sensitizationImagePath:
          sensitizationImagePath ?? this.sensitizationImagePath,
      householdWithUserImagePath:
          householdWithUserImagePath ?? this.householdWithUserImagePath,
      parentsReaction: parentsReaction ?? this.parentsReaction,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  /// Converts this [SensitizationQuestionsData] to a Map for database storage.
  /// This is similar to toJson() but might have different field names or formatting
  /// if needed for database compatibility.
  Map<String, dynamic> toMap() {
    return {
      'hasSensitizedHousehold': hasSensitizedHousehold,
      'hasSensitizedOnProtection': hasSensitizedOnProtection,
      'hasSensitizedOnSafeLabour': hasSensitizedOnSafeLabour,
      'femaleAdultsCount': femaleAdultsCount,
      'maleAdultsCount': maleAdultsCount,
      'consentForPicture': consentForPicture,
      'consentReason': consentReason,
      'sensitizationImagePath': sensitizationImagePath,
      'householdWithUserImagePath': householdWithUserImagePath,
      'parentsReaction': parentsReaction,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  /// Converts this [SensitizationQuestionsData] to a JSON map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  /// Creates a [SensitizationQuestionsData] from a JSON map.
  factory SensitizationQuestionsData.fromJson(Map<String, dynamic> json) {
    return SensitizationQuestionsData(
      hasSensitizedHousehold: json['hasSensitizedHousehold'] as bool?,
      hasSensitizedOnProtection: json['hasSensitizedOnProtection'] as bool?,
      hasSensitizedOnSafeLabour: json['hasSensitizedOnSafeLabour'] as bool?,
      femaleAdultsCount: json['femaleAdultsCount'] as String? ?? '',
      maleAdultsCount: json['maleAdultsCount'] as String? ?? '',
      consentForPicture: json['consentForPicture'] as bool?,
      consentReason: json['consentReason'] as String? ?? '',
      sensitizationImagePath: json['sensitizationImagePath'] as String?,
      householdWithUserImagePath: json['householdWithUserImagePath'] as String?,
      parentsReaction: json['parentsReaction'] as String? ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SensitizationQuestionsData &&
        other.hasSensitizedHousehold == hasSensitizedHousehold &&
        other.hasSensitizedOnProtection == hasSensitizedOnProtection &&
        other.hasSensitizedOnSafeLabour == hasSensitizedOnSafeLabour &&
        other.femaleAdultsCount == femaleAdultsCount &&
        other.maleAdultsCount == maleAdultsCount &&
        other.consentForPicture == consentForPicture &&
        other.consentReason == consentReason &&
        other.sensitizationImagePath == sensitizationImagePath &&
        other.householdWithUserImagePath == householdWithUserImagePath &&
        other.parentsReaction == parentsReaction;
  }

  @override
  int get hashCode {
    return Object.hash(
      hasSensitizedHousehold,
      hasSensitizedOnProtection,
      hasSensitizedOnSafeLabour,
      femaleAdultsCount,
      maleAdultsCount,
      consentForPicture,
      consentReason,
      sensitizationImagePath,
      householdWithUserImagePath,
      parentsReaction,
    );
  }

  @override
  String toString() {
    return 'SensitizationQuestionsData(' +
        'hasSensitizedHousehold: $hasSensitizedHousehold, ' +
        'hasSensitizedOnProtection: $hasSensitizedOnProtection, ' +
        'hasSensitizedOnSafeLabour: $hasSensitizedOnSafeLabour, ' +
        'femaleAdultsCount: $femaleAdultsCount, ' +
        'maleAdultsCount: $maleAdultsCount, ' +
        'consentForPicture: $consentForPicture, ' +
        'consentReason: $consentReason, ' +
        'sensitizationImagePath: $sensitizationImagePath, ' +
        'householdWithUserImagePath: $householdWithUserImagePath, ' +
        'parentsReaction: $parentsReaction, ' +
        'submittedAt: $submittedAt' +
        ')';
  }
}
