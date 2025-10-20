import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../child_details_page.dart';

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class ChildrenHouseholdPage extends StatefulWidget {
  final Map<String, dynamic> producerDetails;

  const ChildrenHouseholdPage({
    Key? key,
    required this.producerDetails,
  }) : super(key: key);

  @override
  _ChildrenHouseholdPageState createState() => _ChildrenHouseholdPageState();
}

class _ChildrenHouseholdPageState extends State<ChildrenHouseholdPage> {
  final _formKey = GlobalKey<FormState>();
  String? _hasChildrenInHousehold;
  final TextEditingController _numberOfChildrenController =
      TextEditingController();
  final TextEditingController _children5To17Controller =
      TextEditingController();
  final List<Map<String, dynamic>> _childrenDetails = [];

  Future<void> _navigateToChildDetails(BuildContext context, int totalChildren,
      {int? childNumberToEdit}) async {
    int currentChild = childNumberToEdit ?? 1;

    while (currentChild <= totalChildren) {
      // Navigate to child details page
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChildDetailsPage(
            childNumber: currentChild,
            totalChildren: totalChildren,
            childrenDetails: _childrenDetails,
          ),
        ),
      );

      if (result == null || result['childData'] == null) {
        // User cancelled the operation or there was an error
        return;
      }

      // Update or add the child data to our list
      setState(() {
        final existingIndex = _childrenDetails.indexWhere((child) =>
            child['childNumber'] == result['childData']['childNumber']);

        if (existingIndex >= 0) {
          // Update existing child data
          _childrenDetails[existingIndex] = result['childData'];
        } else {
          // Add new child data
          _childrenDetails.add(result['childData']);
        }
      });

      // Check if we should navigate to next child
      if (result['navigateToNextChild'] == true &&
          result['nextChildNumber'] != null) {
        currentChild = result['nextChildNumber'];
      } else {
        // Return to children household page
        if (context.mounted) {
          // Save the children data before navigating
          final childrenData = {
            'hasChildrenInHousehold': _hasChildrenInHousehold,
            'numberOfChildren': _numberOfChildrenController.text.isNotEmpty
                ? int.tryParse(_numberOfChildrenController.text) ?? 0
                : 0,
            'children5To17': totalChildren,
            'childrenDetails': _childrenDetails,
            'editingMode': childNumberToEdit != null,
          };

          // Return to the children household page
          Navigator.pop(context, childrenData);
        }
        return;
      }
    }
  }

  Widget _buildQuestionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: _Spacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: child,
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RadioListTile<String>(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      tileColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.md),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _Spacing.lg,
              vertical: _Spacing.md,
            ),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _submitForm() {
    if (_hasChildrenInHousehold == 'Yes') {
      final children5To17 = int.tryParse(_children5To17Controller.text) ?? 0;

      // If there are children 5-17, navigate to child details
      if (children5To17 > 0) {
        _navigateToChildDetails(context, children5To17);
        return;
      }
    }

    // If no children 5-17 or 'No' was selected, return the data
    final childrenData = {
      'hasChildrenInHousehold': _hasChildrenInHousehold,
      'numberOfChildren': _hasChildrenInHousehold == 'Yes'
          ? int.tryParse(_numberOfChildrenController.text) ?? 0
          : 0,
      'children5To17': _hasChildrenInHousehold == 'Yes'
          ? int.tryParse(_children5To17Controller.text) ?? 0
          : 0,
      'childrenDetails': _childrenDetails,
    };

    // Return to previous screen with the collected data
    if (mounted) {
      Navigator.pop(context, childrenData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Children in Household',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question about children in household
                    _buildQuestionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Are there children living in the respondent\'s household?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: _Spacing.md),
                          Wrap(
                            spacing: 20,
                            children: [
                              _buildRadioOption(
                                value: 'Yes',
                                groupValue: _hasChildrenInHousehold,
                                label: 'Yes',
                                onChanged: (value) {
                                  setState(() {
                                    _hasChildrenInHousehold = value;
                                    if (value == 'No') {
                                      _numberOfChildrenController.clear();
                                      _children5To17Controller.clear();
                                      _childrenDetails.clear();
                                    }
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'No',
                                groupValue: _hasChildrenInHousehold,
                                label: 'No',
                                onChanged: (value) {
                                  setState(() {
                                    _hasChildrenInHousehold = value;
                                    _numberOfChildrenController.clear();
                                    _children5To17Controller.clear();
                                    _childrenDetails.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Number of children field (conditional)
                    if (_hasChildrenInHousehold == 'Yes')
                      _buildQuestionCard(
                        child: _buildTextField(
                          label: 'How many children are in the household?',
                          controller: _numberOfChildrenController,
                          hintText: 'Enter number of children',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _children5To17Controller.clear();
                              _childrenDetails.clear();
                            });
                          },
                        ),
                      ),

                    // Children aged 5-17 field (conditional)
                    if (_hasChildrenInHousehold == 'Yes' &&
                        _numberOfChildrenController.text.isNotEmpty &&
                        int.tryParse(_numberOfChildrenController.text) !=
                            null &&
                        int.tryParse(_numberOfChildrenController.text)! > 0)
                      _buildQuestionCard(
                        child: _buildTextField(
                          label:
                              'Out of ${_numberOfChildrenController.text} children, how many are between 5-17 years old?',
                          controller: _children5To17Controller,
                          hintText: 'Enter number of children (5-17 years)',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            // Force a rebuild when the value changes
                            setState(() {});
                          },
                        ),
                      ),

                    const SizedBox(height: _Spacing.lg),

                    // Navigation Buttons
                    const SizedBox(height: _Spacing.lg),
                    Row(
                      children: [
                        // Previous Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.green.shade600, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back_ios,
                                    size: 18, color: Colors.green.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  'Previous',
                                  style: TextStyle(
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Next Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasChildrenInHousehold == 'Yes' &&
                                      _numberOfChildrenController.text.isNotEmpty &&
                                      (_hasChildrenInHousehold == 'No' ||
                                          _children5To17Controller.text.isNotEmpty)
                                  ? Colors.green.shade600
                                  : Colors.grey[400],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Colors.green.shade600.withOpacity(0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _hasChildrenInHousehold == 'Yes' &&
                                          int.tryParse(_children5To17Controller.text) != null &&
                                          (int.tryParse(_children5To17Controller.text) ?? 0) > 0
                                      ? 'Next: Child Details'
                                      : 'Next',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: _Spacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
