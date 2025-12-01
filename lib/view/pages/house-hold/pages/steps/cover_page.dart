import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/daos/cover_page_dao.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/farmers_repo.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart' show CoverPageData, DropdownItem;

/// A widget that represents the cover page for the household survey.
/// This page allows users to select a society and farmer before proceeding with the survey.
class CoverPage extends StatefulWidget {
  final CoverPageData data;
  final ValueChanged<CoverPageData> onDataChanged;
  final VoidCallback? onNext;
  final Future<bool> Function()? onNextPressed;
  final CoverPageDao? coverPageDao;

  const CoverPage({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onNext,
    this.onNextPressed,
    this.coverPageDao,
  });

  @override
  State<CoverPage> createState() => CoverPageState();
}

class CoverPageState extends State<CoverPage> {
  bool _isLoading = false;
  late final CoverPageDao _coverPageDao;

  @override
  void initState() {
    super.initState();
    _coverPageDao = widget.coverPageDao ?? CoverPageDao(dbHelper: HouseholdDBHelper.instance);
    
  

    // Notify parent that this page needs to handle next button
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDataChanged(widget.data);
    });
  }

//   /// Loads the first 10 farmers for the farmer dropdown
//   Future<void> _loadSavedData() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);
    
//     try {
//       // Initialize with empty data first
//       var newData = widget.data.copyWith(
//         towns: const [],  // No districts/towns needed
//         farmers: const [],
//         selectedTownCode: null,
//         selectedFarmerCode: null,
//         hasUnsavedChanges: true,
//         isLoadingFarmers: true,
//         farmerError: null,
//       );
      
//       widget.onDataChanged(newData);
      
//       // Load first 10 farmers
//       try {
//         final farmerRepo = FarmerRepository();
//         debugPrint('🔄 Loading first 10 farmers...');
//         final farmers = await farmerRepo.getFirst10Farmers();
//         debugPrint('✅ Loaded ${farmers.length} farmers');
        
//         newData = newData.copyWith(
//           farmers: farmers.map((farmer) => DropdownItem(
//             code: farmer.farmerCode,
//             name: '${farmer.firstName} ${farmer.lastName}'.trim(),
//           )).toList(),
//           isLoadingFarmers: false,
//           hasUnsavedChanges: true,
//         );
        
//         if (mounted) {
//           widget.onDataChanged(newData);
//         }
//       } catch (e) {
//         debugPrint('❌ Error loading farmers: $e');
//         if (mounted) {
//           widget.onDataChanged(newData.copyWith(
//             farmerError: 'Failed to load farmers: $e',
//             isLoadingFarmers: false,
//           ));
//         }
//       }
      
//     } catch (e) {
//       debugPrint('❌ Error in _loadSavedData: $e');
//       if (mounted) {
//         widget.onDataChanged(widget.data.copyWith(
//           farmerError: 'Error initializing: $e',
//           isLoadingFarmers: false,
//         ));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
// }
  // Public method to save data that can be called from parent
  Future<bool> saveData() => _saveData();
  
  Future<bool> _saveData() async {
    if (!mounted) return false;
    
    debugPrint('🔄 Starting to save cover page data...');
    debugPrint('  - Selected Town Code: ${widget.data.selectedTownCode}');
    debugPrint('  - Selected Farmer Code: ${widget.data.selectedFarmerCode}');
    debugPrint('  - Has unsaved changes: ${widget.data.hasUnsavedChanges}');

    if (!widget.data.isComplete) {
      debugPrint('❌ Validation failed: Both society and farmer must be selected');
      if (!mounted) return false;
      
      final messenger = ScaffoldMessenger.of(context);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Please select both society and farmer'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false;
    }

    debugPrint('⏳ Saving data to database...');
    setState(() => _isLoading = true);

    try {
      debugPrint('📝 Attempting to insert data into database...');
      final id = await _coverPageDao.insert(widget.data);
      debugPrint('✅ Cover page data saved successfully with ID: $id');
      
      // Verify the data was saved
      final savedData = await _coverPageDao.getById(id);
      if (savedData != null) {
        debugPrint('🔍 Verified saved data:');
        debugPrint('  - Selected Town Code: ${savedData.selectedTownCode}');
        debugPrint('  - Selected Farmer Code: ${savedData.selectedFarmerCode}');
      } else {
        debugPrint('❌ Failed to verify saved data - record not found');
      }
      
      if (!mounted) return false;
      
      // Mark as saved before showing any UI
      widget.onDataChanged(widget.data.copyWith(
        id: id,
        hasUnsavedChanges: false,
      ));
      
      debugPrint('📝 Updated local state with new ID: $id');
      
      // Show success message only if still mounted
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Cover page saved successfully'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving cover page data:');
      debugPrint('  - Error: $e');
      debugPrint('  - Stack trace: $stackTrace');
      
      if (!mounted) return false;
      
      // Only show error if still on this page
      final messenger = ScaffoldMessenger.of(context);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to save cover page data: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                if (mounted) {
                  debugPrint('🔄 Retrying save operation...');
                  _saveData();
                }
              },
            ),
          ),
        );
      }
      
      return false;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    // Navigation is handled by the parent widget
    // Add any custom back button logic here if needed
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                          value: widget.data.selectedTownCode,
                          items: DropdownItem.toMapList(widget.data.towns),
                          onChanged: (value) {
                            widget.onDataChanged(widget.data.selectTown(value));
                          },
                          hint: 'Select your society',
                          isLoading: widget.data.isLoadingTowns,
                          error: widget.data.townError,
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
                          value: widget.data.selectedFarmerCode,
                          items: DropdownItem.toMapList(widget.data.farmers),
                          onChanged: (value) {
                            widget
                                .onDataChanged(widget.data.selectFarmer(value));
                          },
                          hint: 'Select a farmer',
                          isLoading: widget.data.isLoadingFarmers,
                          error: widget.data.farmerError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a consistent section container with a title, icon, and child widget.
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
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 120, // Minimum height for better appearance
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
              color: Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 32,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Options Found',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Please check your internet connection\nor try refreshing the page',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: GoogleFonts.inter(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // Remove duplicate items based on 'code' to prevent assertion errors
    final uniqueItems = _removeDuplicateItems(items);

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
              value: value,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  hint,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              items: uniqueItems
                  .map<DropdownMenuItem<String>>((Map<String, String> item) {
                final itemCode = item['code'];
                final itemName = item['name'] ?? 'Unnamed';

                // Ensure we don't have null codes
                if (itemCode == null) {
                  return DropdownMenuItem<String>(
                    value:
                        '__null_${itemName}', // Create a unique value for null codes
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
  List<Map<String, String>> _removeDuplicateItems(
      List<Map<String, String>> items) {
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
      }
    }

    return uniqueItems;
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