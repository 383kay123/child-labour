import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/view/theme/app_theme.dart';

import 'identification_of_owner.dart';

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class VisitInformationPage extends StatefulWidget {
  const VisitInformationPage({super.key, this.initialData});

  final Map<String, dynamic>? initialData;

  @override
  State<VisitInformationPage> createState() => _VisitInformationPageState();
}

class _VisitInformationPageState extends State<VisitInformationPage> {
  String? _respondentNameCorrect;
  String? _respondentNationality;
  String? _countryOfOrigin;
  String? _isFarmOwner;
  String? _farmOwnershipType;

  // Text controllers
  final TextEditingController _respondentNameController = TextEditingController();
  final TextEditingController _otherCountryController = TextEditingController();

  // Country list
  final List<Map<String, String>> _countries = [
    {'value': 'Burkina Faso', 'display': 'Burkina Faso'},
    {'value': 'Mali', 'display': 'Mali'},
    {'value': 'Guinea', 'display': 'Guinea'},
    {'value': 'Ivory Coast', 'display': 'Ivory Coast'},
    {'value': 'Liberia', 'display': 'Liberia'},
    {'value': 'Togo', 'display': 'Togo'},
    {'value': 'Benin', 'display': 'Benin'},
    {'value': 'Niger', 'display': 'Niger'},
    {'value': 'Nigeria', 'display': 'Nigeria'},
    {'value': 'Other', 'display': 'Other (specify)'},
  ];

  bool get _isFormComplete {
    return _respondentNameCorrect != null &&
        _respondentNationality != null &&
        (_respondentNationality != 'Non-Ghanaian' ||
            (_countryOfOrigin != null &&
                (_countryOfOrigin != 'Other' ||
                    _otherCountryController.text.isNotEmpty))) &&
        _isFarmOwner != null &&
        (_isFarmOwner != 'Yes' || _farmOwnershipType != null) &&
        (_isFarmOwner != 'No' || _farmOwnershipType != null);
  }

  @override
  void initState() {
    super.initState();
    _initializeFromData();
  }

  void _initializeFromData() {
    if (widget.initialData != null) {
      setState(() {
        _respondentNameCorrect = widget.initialData!['respondentNameCorrect'];
        _respondentNationality = widget.initialData!['respondentNationality'];
        _countryOfOrigin = widget.initialData!['countryOfOrigin'];
        _isFarmOwner = widget.initialData!['isFarmOwner'];
        _farmOwnershipType = widget.initialData!['farmOwnershipType'];

        if (widget.initialData!['correctedRespondentName'] != null) {
          _respondentNameController.text = widget.initialData!['correctedRespondentName'];
        }
        if (widget.initialData!['otherCountry'] != null) {
          _otherCountryController.text = widget.initialData!['otherCountry'];
        }
      });
    }
  }

  @override
  void dispose() {
    _respondentNameController.dispose();
    _otherCountryController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Information on the Visit',
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
                  // Card 1: Name Confirmation Question
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Is the respondent's name correct?",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: _Spacing.md),
                        Wrap(
                          spacing: 20,
                          children: [
                            _buildRadioOption(
                              value: 'Yes',
                              groupValue: _respondentNameCorrect,
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  _respondentNameCorrect = value;
                                  if (value == 'Yes') {
                                    _respondentNameController.clear();
                                  }
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: 'No',
                              groupValue: _respondentNameCorrect,
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  _respondentNameCorrect = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Card 2: Respondent's Name (only shown when 'No' is selected)
                  if (_respondentNameCorrect == 'No')
                    _buildQuestionCard(
                      child: _buildTextField(
                        label: 'If No, fill in the exact name and surname of the producer',
                        controller: _respondentNameController,
                        hintText: 'Enter full name',
                      ),
                    ),

                  // Card 3: Nationality Question
                  if ((_respondentNameCorrect == 'Yes' ||
                      (_respondentNameCorrect == 'No' && _respondentNameController.text.isNotEmpty)))
                    _buildQuestionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Is the respondent Ghanaian?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: _Spacing.md),
                          Wrap(
                            spacing: 20,
                            children: [
                              _buildRadioOption(
                                value: 'Ghanaian',
                                groupValue: _respondentNationality,
                                label: 'Ghanaian',
                                onChanged: (value) {
                                  setState(() {
                                    _respondentNationality = value;
                                    // Clear country fields when switching to Ghanaian
                                    _countryOfOrigin = null;
                                    _otherCountryController.clear();
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Non-Ghanaian',
                                groupValue: _respondentNationality,
                                label: 'Non-Ghanaian',
                                onChanged: (value) {
                                  setState(() {
                                    _respondentNationality = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Card 4: Country of Origin (only shown for non-Ghanaian respondents)
                  if (_respondentNationality == 'Non-Ghanaian')
                    _buildQuestionCard(
                      child: _buildDropdownField(
                        label: 'If Non-Ghanaian, specify the country of origin',
                        value: _countryOfOrigin,
                        items: _countries,
                        onChanged: (value) {
                          setState(() {
                            _countryOfOrigin = value;
                            if (value != 'Other') {
                              _otherCountryController.clear();
                            }
                          });
                        },
                      ),
                    ),

                  // Card 5: Other Country Specification
                  if (_respondentNationality == 'Non-Ghanaian' && _countryOfOrigin == 'Other')
                    _buildQuestionCard(
                      child: _buildTextField(
                        label: 'Other to specify',
                        controller: _otherCountryController,
                        hintText: 'Enter country name',
                      ),
                    ),

                  // Card 6: Farm Ownership Question
                  if (_respondentNationality != null &&
                      (_respondentNationality == 'Ghanaian' ||
                          (_respondentNationality == 'Non-Ghanaian' &&
                              _countryOfOrigin != null &&
                              (_countryOfOrigin != 'Other' || _otherCountryController.text.isNotEmpty))))
                    _buildQuestionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Is the respondent the owner of this farm?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: _Spacing.md),
                          Wrap(
                            spacing: 20,
                            children: [
                              _buildRadioOption(
                                value: 'Yes',
                                groupValue: _isFarmOwner,
                                label: 'Yes',
                                onChanged: (value) {
                                  setState(() {
                                    _isFarmOwner = value;
                                    // Clear non-owner relationship type
                                    if (value == 'Yes') {
                                      _farmOwnershipType = null;
                                    }
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'No',
                                groupValue: _isFarmOwner,
                                label: 'No',
                                onChanged: (value) {
                                  setState(() {
                                    _isFarmOwner = value;
                                    // Clear owner type
                                    if (value == 'No') {
                                      _farmOwnershipType = null;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Card 7: Farm Ownership Type (shown when respondent is the farm owner)
                  if (_isFarmOwner == 'Yes')
                    _buildQuestionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Which of these best describes you?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: _Spacing.md),
                          Column(
                            children: [
                              _buildRadioOption(
                                value: 'Complete Owner',
                                groupValue: _farmOwnershipType,
                                label: 'Complete Owner',
                                onChanged: (value) {
                                  setState(() {
                                    _farmOwnershipType = value;
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Sharecropper',
                                groupValue: _farmOwnershipType,
                                label: 'Sharecropper',
                                onChanged: (value) {
                                  setState(() {
                                    _farmOwnershipType = value;
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Owner/Sharecropper',
                                groupValue: _farmOwnershipType,
                                label: 'Owner/Sharecropper',
                                onChanged: (value) {
                                  setState(() {
                                    _farmOwnershipType = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Card 8: Non-owner Farm Role
                  if (_isFarmOwner == 'No')
                    _buildQuestionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What is your relationship with the farm owner?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: _Spacing.md),
                          Column(
                            children: [
                              _buildRadioOption(
                                value: 'Family Member',
                                groupValue: _farmOwnershipType,
                                label: 'Family Member',
                                onChanged: (value) {
                                  setState(() {
                                    _farmOwnershipType = value;
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Renting',
                                groupValue: _farmOwnershipType,
                                label: 'Renting',
                                onChanged: (value) {
                                  setState(() {
                                    _farmOwnershipType = value;
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Other',
                                groupValue: _farmOwnershipType,
                                label: 'Other',
                                onChanged: (value) {
                                  setState(() {
                                    _farmOwnershipType = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
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
                    onPressed: _isFormComplete ? () {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IdentificationOfOwnerPage(),
                          ),
                        );
                      } catch (e) {
                        debugPrint('Navigation error: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Could not navigate. Please try again.'),
                              backgroundColor: Colors.red.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      }
                    } : null,
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
