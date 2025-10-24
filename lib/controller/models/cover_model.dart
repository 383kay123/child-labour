import 'package:flutter/foundation.dart';

import '../../data/dummy_data/cover_dummy_data.dart';

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

class CoverPageData {
  /// Creates an empty CoverPageData instance with default values
  factory CoverPageData.empty() => CoverPageData(
        selectedTownCode: null,
        selectedFarmerCode: null,
        towns: const [],
        farmers: const [],
        townError: null,
        farmerError: null,
        isLoadingTowns: false,
        isLoadingFarmers: false,
        hasUnsavedChanges: false,
      );
      
  /// Creates a CoverPageData instance with test data
  factory CoverPageData.test() {
    return CoverDummyData.testCoverData;
  }

  String? _selectedTownCode;
  String? _selectedFarmerCode;
  List<DropdownItem> _towns;
  List<DropdownItem> _farmers;
  String? _townError;
  String? _farmerError;
  bool _isLoadingTowns;
  bool _isLoadingFarmers;
  bool hasUnsavedChanges;

  String? get selectedTownCode => _selectedTownCode;
  String? get selectedFarmerCode => _selectedFarmerCode;
  List<DropdownItem> get towns => List.unmodifiable(_towns);
  List<DropdownItem> get farmers => List.unmodifiable(_farmers);
  String? get townError => _townError;
  String? get farmerError => _farmerError;
  bool get isLoadingTowns => _isLoadingTowns;
  bool get isLoadingFarmers => _isLoadingFarmers;
  bool get isComplete => _selectedTownCode != null && _selectedFarmerCode != null;

  CoverPageData({
    String? selectedTownCode,
    String? selectedFarmerCode,
    List<DropdownItem>? towns,
    List<DropdownItem>? farmers,
    String? townError,
    String? farmerError,
    bool? isLoadingTowns,
    bool? isLoadingFarmers,
    bool? hasUnsavedChanges,
  })  : _selectedTownCode = selectedTownCode,
        _selectedFarmerCode = selectedFarmerCode,
        _towns = towns ?? [],
        _farmers = farmers ?? [],
        _townError = townError,
        _farmerError = farmerError,
        _isLoadingTowns = isLoadingTowns ?? false,
        _isLoadingFarmers = isLoadingFarmers ?? false,
        hasUnsavedChanges = hasUnsavedChanges ?? false;

  /// Update town selection
  CoverPageData selectTown(String? townCode) {
    return copyWith(
      selectedTownCode: townCode,
      hasUnsavedChanges: true,
    );
  }

  /// Update farmer selection
  CoverPageData selectFarmer(String? farmerCode) {
    return copyWith(
      selectedFarmerCode: farmerCode,
      hasUnsavedChanges: true,
    );
  }

  /// Marks the data as having unsaved changes
  void markAsChanged(bool changed) {
    hasUnsavedChanges = changed;
  }

  /// Create a copy of this CoverPageData with the given fields replaced with the new values
  CoverPageData copyWith({
    String? selectedTownCode,
    String? selectedFarmerCode,
    List<DropdownItem>? towns,
    List<DropdownItem>? farmers,
    String? townError,
    String? farmerError,
    bool? isLoadingTowns,
    bool? isLoadingFarmers,
    bool? hasUnsavedChanges,
  }) {
    return CoverPageData(
      selectedTownCode: selectedTownCode ?? _selectedTownCode,
      selectedFarmerCode: selectedFarmerCode ?? _selectedFarmerCode,
      towns: towns ?? _towns,
      farmers: farmers ?? _farmers,
      townError: townError ?? _townError,
      farmerError: farmerError ?? _farmerError,
      isLoadingTowns: isLoadingTowns ?? _isLoadingTowns,
      isLoadingFarmers: isLoadingFarmers ?? _isLoadingFarmers,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  String toString() {
    return 'CoverPageData(town: $_selectedTownCode, farmer: $_selectedFarmerCode, hasUnsavedChanges: $hasUnsavedChanges)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoverPageData &&
        other._selectedTownCode == _selectedTownCode &&
        other._selectedFarmerCode == _selectedFarmerCode &&
        listEquals(other._towns, _towns) &&
        listEquals(other._farmers, _farmers) &&
        other._townError == _townError &&
        other._farmerError == _farmerError &&
        other._isLoadingTowns == _isLoadingTowns &&
        other._isLoadingFarmers == _isLoadingFarmers &&
        other.hasUnsavedChanges == hasUnsavedChanges;
  }

  @override
  int get hashCode {
    return Object.hash(
      _selectedTownCode,
      _selectedFarmerCode,
      Object.hashAll(_towns),
      Object.hashAll(_farmers),
      _townError,
      _farmerError,
      _isLoadingTowns,
      _isLoadingFarmers,
      hasUnsavedChanges,
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
