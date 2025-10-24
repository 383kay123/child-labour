import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/workers_in_farm_page.dart';

import '../../../../theme/app_theme.dart';

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class IdentificationOfOwnerPage extends StatefulWidget {
  const IdentificationOfOwnerPage({
    super.key,
    this.initialData,
    this.onPrevious,
    this.onNext,
  });

  final Map<String, dynamic>? initialData;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  State<IdentificationOfOwnerPage> createState() =>
      _IdentificationOfOwnerPageState();
}

class _IdentificationOfOwnerPageState extends State<IdentificationOfOwnerPage> {
  // Form controllers
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerFirstNameController =
      TextEditingController();
  final TextEditingController _otherNationalityController =
      TextEditingController();
  final TextEditingController _yearsWithOwnerController =
      TextEditingController();

  // State variables
  String? _nationality;
  String? _specificNationality;

  // List of nationalities for non-Ghanaian selection
  final List<Map<String, String>> _nationalityOptions = [
    {'value': 'Burkina Faso', 'display': 'Burkina Faso'},
    {'value': 'Mali', 'display': 'Mali'},
    {'value': 'Guinea', 'display': 'Guinea'},
    {'value': 'Ivory Coast', 'display': 'Ivory Coast'},
    {'value': 'Liberia', 'display': 'Liberia'},
    {'value': 'Togo', 'display': 'Togo'},
    {'value': 'Benin', 'display': 'Benin'},
    {'value': 'Other', 'display': 'Other (specify)'},
  ];

  bool get _isFormComplete {
    return _ownerNameController.text.isNotEmpty &&
        _ownerFirstNameController.text.isNotEmpty &&
        _nationality != null &&
        (_nationality != 'Non-Ghanaian' ||
            (_specificNationality != null &&
                (_specificNationality != 'Other' ||
                    _otherNationalityController.text.isNotEmpty))) &&
        _yearsWithOwnerController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _initializeFromData();
  }

  void _initializeFromData() {
    if (widget.initialData != null) {
      setState(() {
        _nationality = widget.initialData!['nationality'];
        _specificNationality = widget.initialData!['specificNationality'];

        if (widget.initialData!['ownerName'] != null) {
          _ownerNameController.text = widget.initialData!['ownerName'];
        }
        if (widget.initialData!['ownerFirstName'] != null) {
          _ownerFirstNameController.text =
              widget.initialData!['ownerFirstName'];
        }
        if (widget.initialData!['otherNationality'] != null) {
          _otherNationalityController.text =
              widget.initialData!['otherNationality'];
        }
        if (widget.initialData!['yearsWithOwner'] != null) {
          _yearsWithOwnerController.text =
              widget.initialData!['yearsWithOwner'];
        }
      });
    }
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerFirstNameController.dispose();
    _otherNationalityController.dispose();
    _yearsWithOwnerController.dispose();
    super.dispose();
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
    TextInputType? keyboardType,
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
        TextField(
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
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
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
        const SizedBox(height: _Spacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
            ),
            color: isDark ? AppTheme.darkCard : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: _Spacing.md),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
              iconSize: 24,
              elevation: 16,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
              onChanged: onChanged,
              dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
              items: items
                  .map<DropdownMenuItem<String>>((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(
                    item['display']!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
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
          'Identification of the Owner',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Owner Name
                  _buildQuestionCard(
                    child: _buildTextField(
                      label: 'Name of the owner?',
                      controller: _ownerNameController,
                      hintText:
                          'Verify this information with his identification document or any other document of identification. In capital letters',
                    ),
                  ),

                  // Owner First Name
                  _buildQuestionCard(
                    child: _buildTextField(
                      label: 'First name of the owner?',
                      controller: _ownerFirstNameController,
                      hintText:
                          'Verify this information with his identification document or any other document of identification. In capital letters',
                    ),
                  ),

                  // Nationality Card
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What is the nationality of the owner?',
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
                              value: 'Ghanaian',
                              groupValue: _nationality,
                              label: 'Ghanaian',
                              onChanged: (value) {
                                setState(() {
                                  _nationality = value;
                                  // Clear specific nationality when switching to Ghanaian
                                  _specificNationality = null;
                                  _otherNationalityController.clear();
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: 'Non-Ghanaian',
                              groupValue: _nationality,
                              label: 'Non-Ghanaian',
                              onChanged: (value) {
                                setState(() {
                                  _nationality = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Show nationality selection only if Non-Ghanaian is selected
                  if (_nationality == 'Non-Ghanaian')
                    _buildQuestionCard(
                      child: _buildDropdownField(
                        label: 'If Non Ghanaian , specify country of origin',
                        value: _specificNationality,
                        items: _nationalityOptions,
                        onChanged: (value) {
                          setState(() {
                            _specificNationality = value;
                            // Clear the other field when changing selection
                            if (value != 'Other') {
                              _otherNationalityController.clear();
                            }
                          });
                        },
                      ),
                    ),

                  // Show 'Other' specification when 'Other' is selected
                  if (_nationality == 'Non-Ghanaian' &&
                      _specificNationality == 'Other')
                    _buildQuestionCard(
                      child: _buildTextField(
                        label: 'Please specify nationality',
                        controller: _otherNationalityController,
                        hintText: 'Enter nationality',
                      ),
                    ),

                  // Years working with owner
                  _buildQuestionCard(
                    child: _buildTextField(
                      label:
                          'For how many years has the respondent been working with owner?',
                      controller: _yearsWithOwnerController,
                      keyboardType: TextInputType.number,
                      hintText: 'Enter number of years',
                    ),
                  ),

                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(_Spacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
                          style: GoogleFonts.inter(
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
                    onPressed: _isFormComplete
                        ? () {
                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const WorkersInFarmPage(),
                                ),
                              );
                            } catch (e) {
                              debugPrint('Navigation error: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Could not navigate. Please try again.'),
                                    backgroundColor: Colors.red.shade600,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormComplete
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
                          'Next',
                          style: GoogleFonts.inter(
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
          ),
        ),
      ),
    );
  }
}
