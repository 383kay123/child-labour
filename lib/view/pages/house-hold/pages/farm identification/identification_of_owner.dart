import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/workers_in_farm_page.dart';

// import 'package:surveyflow/view/pages/house-hold/pages/farm%20identification/workers_in_farm_page.dart';
// import 'package:surveyflow/view/theme/app_theme.dart';

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
  const IdentificationOfOwnerPage({super.key});

  @override
  State<IdentificationOfOwnerPage> createState() =>
      _IdentificationOfOwnerPageState();
}

class _IdentificationOfOwnerPageState extends State<IdentificationOfOwnerPage> {
  bool _isFormComplete = true; // Always enable the form

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

  bool _validateForm() => true;

  Widget _buildQuestionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: _Spacing.md),
      color: isDark ? AppTheme.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: child,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
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
        ),
      ],
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: theme.primaryColor,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
        ),
      ),
      onTap: () => onChanged(value),
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
        const SizedBox(height: _Spacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: _Spacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
              items: items.map<DropdownMenuItem<String>>((item) {
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
              onChanged: onChanged,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: Column(
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
                  _buildRadioOption(
                    value: 'Ghanaian',
                    groupValue: _nationality,
                    label: 'Ghanaian',
                    onChanged: (value) {
                      setState(() {
                        _nationality = value;
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
            ),

            // Show nationality selection only if Non-Ghanaian is selected
            if (_nationality == 'Non-Ghanaian') ...[
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
              if (_specificNationality == 'Other')
                _buildQuestionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Please specify nationality',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: _Spacing.md),
                      TextField(
                        controller: _otherNationalityController,
                        decoration: InputDecoration(
                          hintText: 'Enter nationality',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppTheme.darkCard
                                  : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppTheme.darkCard
                                  : Colors.grey.shade300,
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
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
            ],

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

            const SizedBox(height: 80), // Space for fixed bottom buttons
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkersInFarmPage(),
                        ),
                      );
                    },
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
