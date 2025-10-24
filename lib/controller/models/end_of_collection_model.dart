class EndOfCollectionModel {
  final int? id; // For database primary key
  
  // Image paths (stored as file paths in local storage)
  final String? respondentImagePath;
  final String? producerSignaturePath;
  
  // Location data
  final double? latitude;
  final double? longitude;
  final String? gpsCoordinates; // Formatted as "latitude,longitude"
  
  // Timestamps
  final DateTime? endTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Additional information
  final String? remarks;
  final bool isSynced; // Track if synced with server

  const EndOfCollectionModel({
    this.id,
    this.respondentImagePath,
    this.producerSignaturePath,
    this.latitude,
    this.longitude,
    this.gpsCoordinates,
    this.endTime,
    this.createdAt,
    this.updatedAt,
    this.remarks,
    this.isSynced = false,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'respondentImagePath': respondentImagePath,
      'producerSignaturePath': producerSignaturePath,
      'latitude': latitude,
      'longitude': longitude,
      'gpsCoordinates': gpsCoordinates,
      'endTime': endTime?.toIso8601String(),
      'remarks': remarks,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // Create from Map (for database retrieval)
  factory EndOfCollectionModel.fromMap(Map<String, dynamic> map) {
    return EndOfCollectionModel(
      id: map['id'],
      respondentImagePath: map['respondentImagePath'],
      producerSignaturePath: map['producerSignaturePath'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      gpsCoordinates: map['gpsCoordinates'],
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      remarks: map['remarks'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isSynced: map['isSynced'] == 1,
    );
  }

  // Create a copy with some fields updated
  EndOfCollectionModel copyWith({
    int? id,
    String? respondentImagePath,
    String? producerSignaturePath,
    double? latitude,
    double? longitude,
    String? gpsCoordinates,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? remarks,
    bool? isSynced,
  }) {
    return EndOfCollectionModel(
      id: id ?? this.id,
      respondentImagePath: respondentImagePath ?? this.respondentImagePath,
      producerSignaturePath: producerSignaturePath ?? this.producerSignaturePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remarks: remarks ?? this.remarks,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // Create an empty instance
  static EndOfCollectionModel empty() => const EndOfCollectionModel();

  // Check if the model is empty
  bool get isEmpty => this == empty();

  // Check if the model is not empty
  bool get isNotEmpty => this != empty();

  @override
  String toString() {
    return 'EndOfCollectionModel{\n'
           '  id: $id,\n'
           '  respondentImagePath: $respondentImagePath,\n'
           '  producerSignaturePath: $producerSignaturePath,\n'
           '  latitude: $latitude,\n'
           '  longitude: $longitude,\n'
           '  gpsCoordinates: $gpsCoordinates,\n'
           '  endTime: $endTime,\n'
           '  remarks: $remarks,\n'
           '  createdAt: $createdAt,\n'
           '  updatedAt: $updatedAt,\n'
           '  isSynced: $isSynced\n'
           '}';
  }
}
