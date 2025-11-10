/// Represents a dropdown item with a code and display name
class DropdownItem {
  final String code;
  final String name;

  const DropdownItem({
    required this.code,
    required this.name,
  });

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownItem &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name;

  @override
  int get hashCode => code.hashCode ^ name.hashCode;
}

/// Represents the data model for the Cover page
class CoverPageData {
  final String? selectedTownCode;
  final String? selectedFarmerCode;
  final List<DropdownItem> towns;
  final List<DropdownItem> farmers;
  final bool hasUnsavedChanges;

  const CoverPageData({
    this.selectedTownCode,
    this.selectedFarmerCode,
    this.towns = const [],
    this.farmers = const [],
    this.hasUnsavedChanges = false,
  });

  /// Creates a copy of this CoverPageData with the given fields replaced with the new values
  CoverPageData copyWith({
    String? selectedTownCode,
    String? selectedFarmerCode,
    List<DropdownItem>? towns,
    List<DropdownItem>? farmers,
    bool? hasUnsavedChanges,
  }) {
    return CoverPageData(
      selectedTownCode: selectedTownCode ?? this.selectedTownCode,
      selectedFarmerCode: selectedFarmerCode ?? this.selectedFarmerCode,
      towns: towns ?? this.towns,
      farmers: farmers ?? this.farmers,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  String toString() {
    return 'CoverPageData{\n'
    '  selectedTownCode: $selectedTownCode,\n'
    '  selectedFarmerCode: $selectedFarmerCode,\n'
    '  towns: $towns,\n'
    '  farmers: $farmers,\n'
    '  hasUnsavedChanges: $hasUnsavedChanges\n'
    '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoverPageData &&
          runtimeType == other.runtimeType &&
          selectedTownCode == other.selectedTownCode &&
          selectedFarmerCode == other.selectedFarmerCode &&
          towns == other.towns &&
          farmers == other.farmers &&
          hasUnsavedChanges == other.hasUnsavedChanges;

  @override
  int get hashCode =>
      selectedTownCode.hashCode ^
      selectedFarmerCode.hashCode ^
      towns.hashCode ^
      farmers.hashCode ^
      hasUnsavedChanges.hashCode;
}

/// Extension methods for List<DropdownItem>
extension DropdownItemListExtensions on List<DropdownItem> {
  /// Converts a list of DropdownItems to a list of maps with 'code' and 'name' keys
  List<Map<String, String>> toMapList() {
    return map((item) => {'code': item.code, 'name': item.name}).toList();
  }
  
  /// Finds a DropdownItem by its code
  DropdownItem? findByCode(String? code) {
    if (code == null) return null;
    try {
      return firstWhere((item) => item.code == code);
    } catch (e) {
      return null;
    }
  }
}
