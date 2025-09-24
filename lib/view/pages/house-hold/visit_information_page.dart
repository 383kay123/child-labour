import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'form_fields.dart';

class VisitInformationPage extends StatefulWidget {
  const VisitInformationPage({super.key});

  @override
  State<VisitInformationPage> createState() => _VisitInformationPageState();
}

class _VisitInformationPageState extends State<VisitInformationPage> {
  String? _respondentNameCorrect;
  String? _farmerAvailableWhy;
  String? _respondentNationality;
  String? _countryOfOrigin;
  String? _isFarmOwner;
  final List<Map<String, String>> _countries = [
    {'value': 'Burkina Faso', 'display': 'Burkina Faso'},
    {'value': 'Mali', 'display': 'Mali'},
    {'value': 'Guinea', 'display': 'Guinea'},
    {'value': 'Ivory Coast', 'display': 'Ivory Coast'},
    {'value': 'Libéria', 'display': 'Libéria'},
    {'value': 'Togo', 'display': 'Togo'},
    {'value': 'Benin', 'display': 'Benin'},
    {'value': 'Niger', 'display': 'Niger'},
    {'value': 'Nigeria', 'display': 'Nigeria'},
    {'value': 'Other', 'display': 'Other (specify)'},
  ];
  final TextEditingController _otherCountryController = TextEditingController();
  final TextEditingController _respondentNameController =
      TextEditingController();
  final TextEditingController _otherSpecController = TextEditingController();

  @override
  void dispose() {
    _respondentNameController.dispose();
    _otherSpecController.dispose();
    _otherCountryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Information on the Visit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card 1: Name Confirmation Question
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Is the name of the respondent correct?',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRadioOption(
                    context: context,
                    value: '1',
                    groupValue: _respondentNameCorrect,
                    label: 'Yes',
                    onChanged: (value) {
                      setState(() {
                        _respondentNameCorrect = value;
                        _farmerAvailableWhy = null;
                      });
                    },
                  ),
                  _buildRadioOption(
                    context: context,
                    value: '2',
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
            ),

            // Card 2: Respondent's Name (only shown when 'No' is selected)
            if (_respondentNameCorrect == '2')
              _buildQuestionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Please enter the correct name of the respondent',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FormFields.buildTextField(
                      context: context,
                      label: 'Full name of respondent',
                      controller: _respondentNameController,
                      hintText: 'Enter full name',
                      isRequired: true,
                      onChanged: (value) {
                        setState(() {
                          // Update state when name changes
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Card 3: Nationality Question (shown when name is confirmed/entered)
            if ((_respondentNameCorrect == '1' ||
                (_respondentNameCorrect == '2' &&
                    _respondentNameController.text.isNotEmpty)))
              _buildQuestionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3. What is the nationality of the respondent?',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRadioOption(
                      context: context,
                      value: 'Ghanaian',
                      groupValue: _respondentNationality,
                      label: 'Ghanaian',
                      onChanged: (value) {
                        setState(() {
                          _respondentNationality = value;
                        });
                      },
                    ),
                    _buildRadioOption(
                      context: context,
                      value: 'Non-Ghanaian',
                      groupValue: _respondentNationality,
                      label: 'Non-Ghanaian',
                      onChanged: (value) {
                        setState(() {
                          _respondentNationality = value;
                          _countryOfOrigin =
                              null; // Reset country when toggling
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Card 4: Country of Origin (only shown for non-Ghanaian respondents)
            if (_respondentNationality == 'Non-Ghanaian')
              _buildQuestionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '4. Please specify the country of origin',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _countryOfOrigin,
                      decoration: InputDecoration(
                        labelText: 'Select country',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      items: _countries.map((country) {
                        return DropdownMenuItem<String>(
                          value: country['value'],
                          child: Text(country['display']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _countryOfOrigin = value;
                          if (value != 'Other') {
                            _otherCountryController.clear();
                          }
                        });
                      },
                      validator: (value) {
                        if (_respondentNationality == 'Non-Ghanaian' &&
                            (value == null || value.isEmpty)) {
                          return 'Please select a country';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

            // Card 5: Other Country Specification (only shown when 'Other' is selected)
            if (_countryOfOrigin == 'Other')
              _buildQuestionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5. Please specify the country',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _otherCountryController,
                      decoration: InputDecoration(
                        labelText: 'Enter country name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (_countryOfOrigin == 'Other' &&
                            (value == null || value.isEmpty)) {
                          return 'Other to specify';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

            // Card 6: Farm Ownership Question (shown after nationality is provided)
            if (_respondentNationality != null &&
                (_respondentNationality == 'Ghanaian' || 
                (_respondentNationality == 'Non-Ghanaian' && 
                (_countryOfOrigin != null && (_countryOfOrigin != 'Other' || _otherCountryController.text.isNotEmpty)))))
              _buildQuestionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '6. Is the respondent the owner of the farm?',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRadioOption(
                      context: context,
                      value: 'Yes',
                      groupValue: _isFarmOwner,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          _isFarmOwner = value;
                        });
                      },
                    ),
                    _buildRadioOption(
                      context: context,
                      value: 'No',
                      groupValue: _isFarmOwner,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          _isFarmOwner = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({required Widget child}) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildRadioOption({
    required BuildContext context,
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: theme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
