/// A simple model class representing an item in a dropdown.
class DropdownItem {
  final String code;
  final String name;

  const DropdownItem({
    required this.code,
    required this.name,
  });

  /// Creates a DropdownItem from a map
  factory DropdownItem.fromMap(Map<String, dynamic> map) {
    return DropdownItem(
      code: map['code'] as String,
      name: map['name'] as String,
    );
  }

  /// Converts the DropdownItem to a map
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
    };
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

  /// Converts a list of DropdownItems to a list of maps
  static List<Map<String, String>> toMapList(List<DropdownItem> items) {
    return items.map((item) => {'code': item.code, 'name': item.name}).toList();
  }
}
