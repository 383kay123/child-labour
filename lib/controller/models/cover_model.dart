import 'package:flutter/foundation.dart';

/// Model representing a dropdown item with code and name
class DropdownItem {
  final String code;
  final String name;

  const DropdownItem({
    required this.code,
    required this.name,
  });

  /// Convert to Map for storage/transmission
  Map<String, String> toMap() {
    return {
      'code': code,
      'name': name,
    };
  }

  /// Create from Map from storage/API
  factory DropdownItem.fromMap(Map<String, dynamic> map) {
    return DropdownItem(
      code: map['code']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed',
    );
  }

  /// Create list from list of maps
  static List<DropdownItem> fromMapList(List<dynamic> mapList) {
    return mapList.map((item) => DropdownItem.fromMap(item)).toList();
  }

  /// Convert list to list of maps
  static List<Map<String, String>> toMapList(List<DropdownItem> items) {
    return items.map((item) => item.toMap()).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownItem && other.code == code && other.name == name;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode;

  @override
  String toString() => 'DropdownItem(code: $code, name: $name)';
}

/// Main model for Cover Page data
class CoverPageData {
  final String? selectedTownCode;
  final String? selectedFarmerCode;
  final List<DropdownItem> towns;
  final List<DropdownItem> farmers;
  final String? townError;
  final String? farmerError;
  final bool isLoadingTowns;
  final bool isLoadingFarmers;

  const CoverPageData({
    this.selectedTownCode,
    this.selectedFarmerCode,
    this.towns = const [],
    this.farmers = const [],
    this.townError,
    this.farmerError,
    this.isLoadingTowns = false,
    this.isLoadingFarmers = false,
  });

  /// Get selected town name
  String? get selectedTownName {
    if (selectedTownCode == null) return null;
    return towns
        .where((town) => town.code == selectedTownCode)
        .firstOrNull
        ?.name;
  }

  /// Get selected farmer name
  String? get selectedFarmerName {
    if (selectedFarmerCode == null) return null;
    return farmers
        .where((farmer) => farmer.code == selectedFarmerCode)
        .firstOrNull
        ?.name;
  }

  /// Check if town selection is valid
  bool get isTownSelectionValid {
    if (selectedTownCode == null) return false;
    return towns.any((town) => town.code == selectedTownCode);
  }

  /// Check if farmer selection is valid
  bool get isFarmerSelectionValid {
    if (selectedFarmerCode == null) return false;
    return farmers.any((farmer) => farmer.code == selectedFarmerCode);
  }

  /// Check if both selections are made and valid
  bool get isComplete {
    return isTownSelectionValid && isFarmerSelectionValid;
  }

  /// Check if form can be submitted (both selected and no errors)
  bool get canProceed {
    return isComplete && townError == null && farmerError == null;
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'selectedTownCode': selectedTownCode,
      'selectedFarmerCode': selectedFarmerCode,
      'towns': towns.map((town) => town.toMap()).toList(),
      'farmers': farmers.map((farmer) => farmer.toMap()).toList(),
      'townError': townError,
      'farmerError': farmerError,
      'isLoadingTowns': isLoadingTowns,
      'isLoadingFarmers': isLoadingFarmers,
    };
  }

  /// Create from Map from storage
  factory CoverPageData.fromMap(Map<String, dynamic> map) {
    return CoverPageData(
      selectedTownCode: map['selectedTownCode']?.toString(),
      selectedFarmerCode: map['selectedFarmerCode']?.toString(),
      towns: (map['towns'] as List<dynamic>? ?? [])
          .map((item) => DropdownItem.fromMap(item))
          .toList(),
      farmers: (map['farmers'] as List<dynamic>? ?? [])
          .map((item) => DropdownItem.fromMap(item))
          .toList(),
      townError: map['townError']?.toString(),
      farmerError: map['farmerError']?.toString(),
      isLoadingTowns: map['isLoadingTowns'] == true,
      isLoadingFarmers: map['isLoadingFarmers'] == true,
    );
  }

  /// Create empty instance
  factory CoverPageData.empty() {
    return const CoverPageData();
  }

  /// Create with default farmers (for testing/demo)
  factory CoverPageData.withDefaultFarmers({
    String? selectedTownCode,
    String? selectedFarmerCode,
    List<DropdownItem> towns = const [],
  }) {
    const defaultFarmers = [
      DropdownItem(code: 'f1', name: 'John Doe'),
      DropdownItem(code: 'f2', name: 'Jane Smith'),
      DropdownItem(code: 'f3', name: 'Robert Johnson'),
      DropdownItem(code: 'f4', name: 'Emily Davis'),
      DropdownItem(code: 'f5', name: 'Michael Brown'),
    ];

    return CoverPageData(
      selectedTownCode: selectedTownCode,
      selectedFarmerCode: selectedFarmerCode,
      towns: towns,
      farmers: defaultFarmers,
    );
  }

  /// Copy with method for immutability
  CoverPageData copyWith({
    String? selectedTownCode,
    String? selectedFarmerCode,
    List<DropdownItem>? towns,
    List<DropdownItem>? farmers,
    String? townError,
    String? farmerError,
    bool? isLoadingTowns,
    bool? isLoadingFarmers,
  }) {
    return CoverPageData(
      selectedTownCode: selectedTownCode ?? this.selectedTownCode,
      selectedFarmerCode: selectedFarmerCode ?? this.selectedFarmerCode,
      towns: towns ?? this.towns,
      farmers: farmers ?? this.farmers,
      townError: townError,
      farmerError: farmerError,
      isLoadingTowns: isLoadingTowns ?? this.isLoadingTowns,
      isLoadingFarmers: isLoadingFarmers ?? this.isLoadingFarmers,
    );
  }

  /// Update town selection
  CoverPageData selectTown(String? townCode) {
    return copyWith(
      selectedTownCode: townCode,
      townError: townCode == null ? 'Please select a town' : null,
    );
  }

  /// Update farmer selection
  CoverPageData selectFarmer(String? farmerCode) {
    return copyWith(
      selectedFarmerCode: farmerCode,
      farmerError: farmerCode == null ? 'Please select a farmer' : null,
    );
  }

  /// Update towns list
  CoverPageData updateTowns(List<DropdownItem> newTowns) {
    return copyWith(
      towns: newTowns,
      isLoadingTowns: false,
      // Reset selection if current selection is no longer valid
      selectedTownCode: isTownSelectionValid ? selectedTownCode : null,
    );
  }

  /// Update farmers list
  CoverPageData updateFarmers(List<DropdownItem> newFarmers) {
    return copyWith(
      farmers: newFarmers,
      isLoadingFarmers: false,
      // Reset selection if current selection is no longer valid
      selectedFarmerCode: isFarmerSelectionValid ? selectedFarmerCode : null,
    );
  }

  /// Set loading states
  CoverPageData setLoading({
    bool? townsLoading,
    bool? farmersLoading,
  }) {
    return copyWith(
      isLoadingTowns: townsLoading ?? isLoadingTowns,
      isLoadingFarmers: farmersLoading ?? isLoadingFarmers,
    );
  }

  /// Set error messages
  CoverPageData setErrors({
    String? townError,
    String? farmerError,
  }) {
    return copyWith(
      townError: townError,
      farmerError: farmerError,
    );
  }

  /// Clear all errors
  CoverPageData clearErrors() {
    return copyWith(
      townError: null,
      farmerError: null,
    );
  }

  /// Clear all selections
  CoverPageData clearSelections() {
    return copyWith(
      selectedTownCode: null,
      selectedFarmerCode: null,
      townError: null,
      farmerError: null,
    );
  }

  /// Validate the current state and return errors if any
  Map<String, String?> validate() {
    final errors = <String, String?>{};

    if (selectedTownCode == null) {
      errors['town'] = 'Please select a town';
    } else if (!isTownSelectionValid) {
      errors['town'] = 'Selected town is no longer available';
    }

    if (selectedFarmerCode == null) {
      errors['farmer'] = 'Please select a farmer';
    } else if (!isFarmerSelectionValid) {
      errors['farmer'] = 'Selected farmer is no longer available';
    }

    return errors;
  }

  /// Get summary for display
  Map<String, String?> get summary {
    return {
      'Town': selectedTownName ?? 'Not selected',
      'Farmer': selectedFarmerName ?? 'Not selected',
      'Status': isComplete ? 'Complete' : 'Incomplete',
    };
  }

  /// Debug information
  void debugPrint() {
    print('=== COVER PAGE DATA ===');
    print('Selected Town: $selectedTownCode ($selectedTownName)');
    print('Selected Farmer: $selectedFarmerCode ($selectedFarmerName)');
    print('Towns available: ${towns.length}');
    print('Farmers available: ${farmers.length}');
    print('Town Error: $townError');
    print('Farmer Error: $farmerError');
    print('Loading Towns: $isLoadingTowns');
    print('Loading Farmers: $isLoadingFarmers');
    print('Is Complete: $isComplete');
    print('Can Proceed: $canProceed');
    print('=======================');
  }

  @override
  String toString() {
    return 'CoverPageData(town: $selectedTownCode, farmer: $selectedFarmerCode, complete: $isComplete)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoverPageData &&
        other.selectedTownCode == selectedTownCode &&
        other.selectedFarmerCode == selectedFarmerCode &&
        listEquals(other.towns, towns) &&
        listEquals(other.farmers, farmers) &&
        other.townError == townError &&
        other.farmerError == farmerError &&
        other.isLoadingTowns == isLoadingTowns &&
        other.isLoadingFarmers == isLoadingFarmers;
  }

  @override
  int get hashCode {
    return Object.hash(
      selectedTownCode,
      selectedFarmerCode,
      Object.hashAll(towns),
      Object.hashAll(farmers),
      townError,
      farmerError,
      isLoadingTowns,
      isLoadingFarmers,
    );
  }
}

// Extension for firstOrNull on List
extension FirstWhereOrNullExtension<T> on List<T> {
  T? firstOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
