import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/models/dropdown_item_model.dart';

/// Contains dummy data for the Cover page
class CoverDummyData {
  /// Returns a list of dummy towns
  static List<DropdownItem> get dummyTowns => [
        const DropdownItem(code: 'T001', name: 'Accra'),
        const DropdownItem(code: 'T002', name: 'Kumasi'),
        const DropdownItem(code: 'T003', name: 'Tamale'),
        const DropdownItem(code: 'T004', name: 'Sekondi-Takoradi'),
        const DropdownItem(code: 'T005', name: 'Cape Coast'),
      ];

  /// Returns a list of dummy farmers for a given town
  static List<DropdownItem> getDummyFarmers(String? townCode) {
    if (townCode == null) return [];

    // Different farmers for different towns
    switch (townCode) {
      case 'T001': // Accra
        return const [
          DropdownItem(code: 'F001', name: 'Kwame Asare'),
          DropdownItem(code: 'F002', name: 'Ama Serwaa'),
        ];
      case 'T002': // Kumasi
        return const [
          DropdownItem(code: 'F003', name: 'Yaw Mensah'),
          DropdownItem(code: 'F004', name: 'Akosua Agyemang'),
        ];
      case 'T003': // Tamale
        return const [
          DropdownItem(code: 'F005', name: 'Ibrahim Mohammed'),
          DropdownItem(code: 'F006', name: 'Fati Alhassan'),
        ];
      default:
        return const [
          DropdownItem(code: 'F007', name: 'John Doe'),
          DropdownItem(code: 'F008', name: 'Jane Smith'),
        ];
    }
  }

  /// Returns a pre-populated CoverPageData for testing
  static CoverPageData get testCoverData => CoverPageData(
        selectedTownCode: 'T001',
        selectedFarmerCode: 'F001',
        towns: dummyTowns,
        farmers: getDummyFarmers('T001'),
        hasUnsavedChanges: false,
      );
}
