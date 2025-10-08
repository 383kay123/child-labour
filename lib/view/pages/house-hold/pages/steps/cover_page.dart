import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A widget that represents the cover page for the household survey.
/// This page allows users to select a society and farmer before proceeding with the survey.

/// A widget that displays a cover page with society and farmer selection dropdowns.
/// 
/// This widget is typically the first step in a multi-step form where users need to
/// select their society (town) and farmer before proceeding with the survey.
class CoverPage extends StatelessWidget {
  /// Currently selected town ID
  final String? selectedTown;

  /// Currently selected farmer ID
  final String? selectedFarmer;

  /// List of available towns with their IDs and names
  final List<Map<String, String>> towns;

  /// List of available farmers with their IDs and names
  final List<Map<String, String>> farmers;

  /// Callback when a town is selected
  final ValueChanged<String?> onTownChanged;

  /// Callback when a farmer is selected
  final ValueChanged<String?> onFarmerChanged;

  /// Callback when the continue button is pressed
  /// This is no longer used but kept for backward compatibility
  final VoidCallback onNext;

  /// Error message for town selection
  final String? townError;

  /// Error message for farmer selection
  final String? farmerError;

  /// Loading state for towns
  final bool isLoadingTowns;

  /// Loading state for farmers
  final bool isLoadingFarmers;

  /// Creates a [CoverPage] widget.
  ///
  /// The [selectedTown] and [selectedFarmer] parameters can be null if no selection has been made.
  /// The [towns] and [farmers] lists should contain maps with 'code' and 'name' keys.
  /// The callbacks [onTownChanged], [onFarmerChanged], and [onNext] must not be null.
  /// Sample farmer data - in a real app, this would come from an API or database
  static const List<Map<String, String>> defaultFarmers = [
    {'code': 'f1', 'name': 'John Doe'},
    {'code': 'f2', 'name': 'Jane Smith'},
    {'code': 'f3', 'name': 'Robert Johnson'},
    {'code': 'f4', 'name': 'Emily Davis'},
    {'code': 'f5', 'name': 'Michael Brown'},
  ];

   CoverPage({
    Key? key,
    this.selectedTown,
    this.selectedFarmer,
    this.towns = const [],
    List<Map<String, String>>? farmers,
    required this.onTownChanged,
    required this.onFarmerChanged,
    required this.onNext,
    this.townError,
    this.farmerError,
    this.isLoadingTowns = false,
    this.isLoadingFarmers = false,
  }) : farmers = farmers ?? defaultFarmers,
        super(key: key) {
    // Validate that selected values exist in their respective lists
    if (selectedTown != null && !_isValueValid(selectedTown, towns)) {
      debugPrint('Warning: Selected town $selectedTown not found in towns list');
    }
    if (selectedFarmer != null && !_isValueValid(selectedFarmer, farmers ?? defaultFarmers)) {
      debugPrint('Warning: Selected farmer $selectedFarmer not found in farmers list');
    }
  }

  /// Validates if the current selected value exists in the items list
  static bool _isValueValid(String? value, List<Map<String, String>> items) {
    final matchingItems = items.where((item) => item['code'] == value).toList();
    return matchingItems.length == 1; // Exactly one match is valid
  }

  @override
  Widget build(BuildContext context) {
    // Get the primary color from the current theme for consistent theming
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // AppBar removed as requested
      body: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Society Selection
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _buildSection(
                      context: context,
                      title: 'Select Society',
                      icon: Icons.apartment_rounded,
                      child: _buildDropdown(
                        context: context,
                        value: selectedTown,
                        items: towns,
                        onChanged: onTownChanged,
                        hint: 'Select your society',
                        isLoading: isLoadingTowns,
                        error: townError,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Farmer Selection
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _buildSection(
                      context: context,
                      title: 'Select Farmer',
                      icon: Icons.person_outline_rounded,
                      child: _buildDropdown(
                        context: context,
                        value: selectedFarmer,
                        items: farmers,
                        onChanged: onFarmerChanged,
                        hint: 'Select a farmer',
                        isLoading: isLoadingFarmers,
                        error: farmerError,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Next Button removed as per request
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  /// Builds a consistent section container with a title, icon, and child widget.
  ///
  /// This widget creates a card-like container with a header section containing
  /// an icon and title, followed by the provided child widget.
  ///
  /// - [context]: The build context
  /// - [title]: The section title text
  /// - [icon]: The icon to display next to the title
  /// - [child]: The widget to display below the section header
  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Builds a custom styled dropdown menu.
  ///
  /// Creates a dropdown button with consistent styling that matches the app's design system.
  /// The dropdown shows a list of items where each item has a 'code' and 'name'.
  ///
  /// - [context]: The build context
  /// - [value]: Currently selected value (should match an item's 'code')
  /// - [items]: List of items to display in the dropdown
  /// - [onChanged]: Callback when a new item is selected
  /// - [hint]: Text to show when no item is selected
  /// - [isLoading]: Whether the dropdown is in loading state
  /// - [error]: Error message to display below the dropdown
  Widget _buildDropdown({
    required BuildContext context,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    required String hint,
    bool isLoading = false,
    String? error,
  }) {
    final theme = Theme.of(context);

    // Log the items for debugging
    debugPrint('Dropdown items: $items');
    debugPrint('Selected value: $value');

    // Handle loading state
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading...',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    // If no items, show disabled state
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              color: Colors.grey.shade100,
            ),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 32, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'No options available',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Please check your connection',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.inter(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ],
      );
    }

    // Check if the current value exists in the items list
    // If not, set value to null to avoid the assertion error
    String? safeValue = value;
    if (safeValue != null) {
      final matchingItems = items.where((item) => item['code'] == safeValue).toList();
      if (matchingItems.isEmpty || matchingItems.length > 1) {
        safeValue = null;
        debugPrint('Warning: Selected value $value not found in items or has duplicates. Resetting to null.');
      }
    }

    // Remove duplicate items based on 'code' to prevent assertion errors
    final uniqueItems = _removeDuplicateItems(items);
    if (uniqueItems.length != items.length) {
      debugPrint('Warning: Removed ${items.length - uniqueItems.length} duplicate items from dropdown');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: error != null ? Colors.red : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value, // Use the original value to maintain selection state
              onChanged: onChanged,
              isExpanded: true,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              hint: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  hint,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              items: uniqueItems.map<DropdownMenuItem<String>>((Map<String, String> item) {
                final itemCode = item['code'];
                final itemName = item['name'] ?? 'Unnamed';

                // Ensure we don't have null codes
                if (itemCode == null) {
                  debugPrint('Warning: Found item with null code: $item');
                  return DropdownMenuItem<String>(
                    value: '__null_${itemName}', // Create a unique value for null codes
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        itemName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                return DropdownMenuItem<String>(
                  value: itemCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      itemName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return uniqueItems.map<Widget>((Map<String, String> item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      item['name'] ?? 'Unnamed',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              dropdownColor: Colors.white,
              focusColor: Colors.transparent,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.inter(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  /// Helper method to remove duplicate items based on 'code'
  List<Map<String, String>> _removeDuplicateItems(List<Map<String, String>> items) {
    final seen = <String>{};
    final uniqueItems = <Map<String, String>>[];

    for (final item in items) {
      final code = item['code'];
      if (code != null && !seen.contains(code)) {
        seen.add(code);
        uniqueItems.add(item);
      } else if (code == null) {
        // Handle items with null codes by adding them with a warning
        uniqueItems.add(item);
        debugPrint('Warning: Item with null code found: $item');
      }
    }

    return uniqueItems;
  }

  /// Builds a styled 'Continue' button.
  ///
  /// Creates a prominent button that calls [onNext] when pressed.
  /// The button's appearance changes based on the [isEnabled] state.
  ///
  /// - [context]: The build context
  /// - [onNext]: Callback when the button is pressed
  /// - [isEnabled]: Whether the button should be enabled
  Widget _buildNextButton(
      BuildContext context, {
        required VoidCallback onNext,
        bool isEnabled = true,
      }) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: isEnabled ? primaryColor : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onNext : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a search dialog for large lists of items
  void _showSearchDialog(
      BuildContext context,
      List<Map<String, String>> items,
      ValueChanged<String?> onChanged,
      String title,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                items[index]['name'] ?? 'Unnamed',
                style: GoogleFonts.inter(),
              ),
              onTap: () {
                onChanged(items[index]['code']);
                Navigator.pop(context);
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhanced type-safe version of dropdown items
class DropdownItem {
  final String code;
  final String name;

  const DropdownItem({required this.code, required this.name});

  Map<String, String> toMap() => {'code': code, 'name': name};

  factory DropdownItem.fromMap(Map<String, String> map) {
    return DropdownItem(
      code: map['code'] ?? '',
      name: map['name'] ?? 'Unnamed',
    );
  }
}

/// Localization class for CoverPage strings
class CoverPageLocalizations {
  final String selectSociety;
  final String selectFarmer;
  final String societyHint;
  final String farmerHint;
  final String continueText;
  final String loading;
  final String noOptions;
  final String checkConnection;
  final String cancel;

  const CoverPageLocalizations({
    this.selectSociety = 'Select Society',
    this.selectFarmer = 'Select Farmer',
    this.societyHint = 'Select your society',
    this.farmerHint = 'Select a farmer',
    this.continueText = 'Continue',
    this.loading = 'Loading...',
    this.noOptions = 'No options available',
    this.checkConnection = 'Please check your connection',
    this.cancel = 'Cancel',
  });
}