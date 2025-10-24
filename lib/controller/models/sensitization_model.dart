/// Represents the user's acknowledgment of sensitization information.
class SensitizationData {
  /// Whether the user has read and acknowledged the sensitization information.
  final bool isAcknowledged;

  /// The timestamp when the user acknowledged the information.
  final DateTime? acknowledgedAt;

  /// Creates a new [SensitizationData] instance.
  ///
  /// - [isAcknowledged]: Whether the user has acknowledged the information.
  /// - [acknowledgedAt]: When the acknowledgment was made (defaults to current time if null and isAcknowledged is true).
   SensitizationData({
    this.isAcknowledged = false,
    DateTime? acknowledgedAt,
  }) : acknowledgedAt = isAcknowledged ? (acknowledgedAt ?? DateTime.now()) : null;

  /// Creates a copy of this [SensitizationData] with the given fields replaced by the non-null parameter values.
  SensitizationData copyWith({
    bool? isAcknowledged,
    DateTime? acknowledgedAt,
  }) {
    return SensitizationData(
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensitizationData &&
          runtimeType == other.runtimeType &&
          isAcknowledged == other.isAcknowledged &&
          acknowledgedAt == other.acknowledgedAt;

  @override
  int get hashCode => Object.hash(isAcknowledged, acknowledgedAt);

  @override
  String toString() => 'SensitizationData(isAcknowledged: $isAcknowledged, acknowledgedAt: $acknowledgedAt)';
}

/// A class containing all the sensitization content for the application.
class SensitizationContent {
  /// Title for the Good Parenting section.
  static const String goodParentingTitle = 'GOOD PARENTING';

  /// Bullet points for the Good Parenting section.
  static const List<String> goodParentingBullets = [
    'Every parent is responsible for loving, protecting, training and discipling their children.',
    'Good parenting begins from inception. It is cheaper to get things right during early childhood than trying to fix it later.',
    'Good parenting nurtures innovation and creative thinking in children.',
    'Parenting a child is a one-time opportunity; there is no do-over.',
  ];

  /// Title for the Child Protection section.
  static const String childProtectionTitle = 'CHILD PROTECTION';

  /// Bullet points for the Child Protection section.
  static const List<String> childProtectionBullets = [
    'Children\'s rights are all about the needs of a child, all the care and the protection a child must enjoy to guarantee his/her development and full growth.',
    'Child labour is mentally, physically, socially, morally dangerous and detrimental to children\'s development.',
    'Socialization of children must not be an excuse for exploitation or compromise their education.',
    'Children are more likely to have occupational accidents because they are less experienced, less aware of the risks and means to prevent them.',
    'Child labour can have tragic consequences at individual, family, community and national levels.',
  ];

  /// Title for the Safe Labour Practices section.
  static const String safeLabourPracticesTitle = 'SAFE LABOUR PRACTICES';

  /// Bullet points for the Safe Labour Practices section.
  static const List<String> safeLabourPracticesBullets = [
    'Carefully read the instructions provided for the use of the chemical product before application.',
    'Wear the appropriate protective clothing and footwear before setting off to the farm.',
    'Wear protective clothing during spraying of agrochemical products, fertilizer application and pruning.',
    'Threats, harassment, assault and deprivations of all kinds are all characteristics of forced labour.',
    'Forced/compulsory labour is an affront to children\'s rights and development.',
    'Promote safe labour practices in cocoa cultivation among adults.',
  ];

  /// The main description text shown at the top of the sensitization page.
  static const String description =
      'Please take a moment to understand the dangers and impact of child labour and to promote child protection and education.';
}
