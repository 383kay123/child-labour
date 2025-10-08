import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/view/pages/house-hold/pages/farm%20identification/workers_in_farm_page.dart';
import 'package:surveyflow/view/theme/app_theme.dart';

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
  bool _isFormComplete = false;

  // Form controllers
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerFirstNameController = TextEditingController();
  final TextEditingController _otherNationalityController = TextEditingController();
  final TextEditingController _yearsWithOwnerController = TextEditingController();

  // Form validation errors
  String? _ownerNameError;
  String? _ownerFirstNameError;
  String? _yearsWithOwnerError;
  String? _nationalityError;
  String? _specificNationalityError;

  // Form values
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

  @override
  void initState() {
    super.initState();
    _ownerNameController.addListener(_validateForm);
    _ownerFirstNameController.addListener(_validateForm);
    _yearsWithOwnerController.addListener(_validateForm);
    _otherNationalityController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _ownerNameController.removeListener(_validateForm);
    _ownerFirstNameController.removeListener(_validateForm);
    _yearsWithOwnerController.removeListener(_validateForm);
    _otherNationalityController.removeListener(_validateForm);

    _ownerNameController.dispose();
    _ownerFirstNameController.dispose();
    _otherNationalityController.dispose();
    _yearsWithOwnerController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate owner name
    if (_ownerNameController.text.trim().isEmpty) {
      _ownerNameError = 'Owner name is required';
      isValid = false;
    } else {
      _ownerNameError = null;
    }

    // Validate owner first name
    if (_ownerFirstNameController.text.trim().isEmpty) {
      _ownerFirstNameError = 'Owner first name is required';
      isValid = false;
    } else {
      _ownerFirstNameError = null;
    }

    // Validate years with owner
    if (_yearsWithOwnerController.text.trim().isEmpty) {
      _yearsWithOwnerError = 'This field is required';
      isValid = false;
    } else {
      final years = int.tryParse(_yearsWithOwnerController.text);
      if (years == null || years < 0) {
        _yearsWithOwnerError = 'Please enter a valid number';
        isValid = false;
      } else {
        _yearsWithOwnerError = null;
      }
    }

    // Validate nationality
    if (_nationality == null) {
      _nationalityError = 'Please select a nationality';
      isValid = false;
    } else if (_nationality == 'Non-Ghanaian' && _specificNationality == null) {
      _nationalityError = 'Please specify nationality';
      isValid = false;
    } else if (_nationality == 'Non-Ghanaian' &&
        _specificNationality == 'Other' &&
        _otherNationalityController.text.trim().isEmpty) {
      _specificNationalityError = 'Please specify other nationality';
      isValid = false;
    } else {
      _nationalityError = null;
      _specificNationalityError = null;
    }

    setState(() {
      _isFormComplete = isValid;
    });

    return isValid;
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
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? errorText,
    TextInputType keyboardType = TextInputType.text,
    String hintText = '',
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
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: _Spacing.sm),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: _Spacing.md),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
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
            _validateForm();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
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
                errorText: _ownerNameError,
                hintText: 'Enter owner\'s full name',
              ),
            ),

            // Owner First Name
            _buildQuestionCard(
              child: _buildTextField(
                label: 'First name of the owner?',
                controller: _ownerFirstNameController,
                errorText: _ownerFirstNameError,
                hintText: 'Enter owner\'s first name',
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
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_nationalityError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: _Spacing.sm),
                      child: Text(
                        _nationalityError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
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
                        _validateForm();
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
                        _validateForm();
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
                  label: 'If Non-Ghanaian, please indicate the country you are from?',
                  value: _specificNationality,
                  items: _nationalityOptions,
                  onChanged: (value) {
                    setState(() {
                      _specificNationality = value;
                      // Clear the other field when changing selection
                      if (value != 'Other') {
                        _otherNationalityController.clear();
                      }
                      _validateForm();
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
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_specificNationalityError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: _Spacing.sm),
                          child: Text(
                            _specificNationalityError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: _Spacing.md),
                      TextField(
                        controller: _otherNationalityController,
                        decoration: InputDecoration(
                          hintText: 'Enter nationality',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
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
                          _validateForm();
                        },
                      ),
                    ],
                  ),
                ),
            ],

            // Years working with owner
            _buildQuestionCard(
              child: _buildTextField(
                label: 'For how many years has the respondent been working with owner?',
                controller: _yearsWithOwnerController,
                errorText: _yearsWithOwnerError,
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
                    onPressed: _isFormComplete
                        ? () {
                      if (_validateForm()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkersInFarmPage(),
                          ),
                        );
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