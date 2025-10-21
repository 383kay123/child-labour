// models/cover_page_model.dart
class CoverPageModel {
  int? id;
  String selectedTown;
  String selectedTownName;
  String selectedFarmer;
  String selectedFarmerName;
  String createdAt;
  String updatedAt;
  int status; // 0 = draft, 1 = completed
  int syncStatus; // 0 = not synced, 1 = synced

  CoverPageModel({
    this.id,
    required this.selectedTown,
    required this.selectedTownName,
    required this.selectedFarmer,
    required this.selectedFarmerName,
    required this.createdAt,
    required this.updatedAt,
    this.status = 0,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'selectedTown': selectedTown,
      'selectedTownName': selectedTownName,
      'selectedFarmer': selectedFarmer,
      'selectedFarmerName': selectedFarmerName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      'syncStatus': syncStatus,
    };
  }

  factory CoverPageModel.fromMap(Map<String, dynamic> map) {
    return CoverPageModel(
      id: map['id'],
      selectedTown: map['selectedTown'] ?? '',
      selectedTownName: map['selectedTownName'] ?? '',
      selectedFarmer: map['selectedFarmer'] ?? '',
      selectedFarmerName: map['selectedFarmerName'] ?? '',
      createdAt: map['createdAt'] ?? DateTime.now().toString(),
      updatedAt: map['updatedAt'] ?? DateTime.now().toString(),
      status: map['status'] ?? 0,
      syncStatus: map['syncStatus'] ?? 0,
    );
  }

  // Helper method to create from dropdown selections
  static CoverPageModel fromSelections({
    String? townCode,
    String? townName,
    String? farmerCode,
    String? farmerName,
  }) {
    return CoverPageModel(
      selectedTown: townCode ?? '',
      selectedTownName: townName ?? '',
      selectedFarmer: farmerCode ?? '',
      selectedFarmerName: farmerName ?? '',
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
    );
  }

  // Check if both selections are made
  bool get isComplete => selectedTown.isNotEmpty && selectedFarmer.isNotEmpty;

  @override
  String toString() {
    return 'CoverPageModel{id: $id, town: $selectedTownName, farmer: $selectedFarmerName, status: $status}';
  }
}
