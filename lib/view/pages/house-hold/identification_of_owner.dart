import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'workers_in_farm_page.dart';

class IdentificationOfOwnerPage extends StatefulWidget {
  const IdentificationOfOwnerPage({super.key});

  @override
  State<IdentificationOfOwnerPage> createState() =>
      _IdentificationOfOwnerPageState();
}

class _IdentificationOfOwnerPageState extends State<IdentificationOfOwnerPage> {
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerFirstNameController =
      TextEditingController();
  final TextEditingController _otherNationalityController =
      TextEditingController();
  final TextEditingController _yearsWithOwnerController =
      TextEditingController();
  String? _nationality; // 'Ghanaian' or 'Non-Ghanaian'
  String?
      _specificNationality; // For storing the specific nationality when 'Other' is selected

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerFirstNameController.dispose();
    _otherNationalityController.dispose();
    _yearsWithOwnerController.dispose();
    super.dispose();
  }

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

  Widget _buildQuestionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
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

    return RadioListTile<String>(
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: theme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    bool showOtherField = false,
    TextEditingController? otherController,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onChanged: onChanged,
              items: items
                  .map<DropdownMenuItem<String>>((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['display']!),
                );
              }).toList(),
            ),
          ),
        ),
        if (showOtherField && value == 'Other')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: otherController,
              decoration: InputDecoration(
                hintText: 'Please specify',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification of the Owner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pop(true); // Return true when going back to mark as complete
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name of the owner?',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ownerNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter owner\'s full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First name of the owner?',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ownerFirstNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter owner\'s first name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),

            // Nationality Card
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is the nationality of the owner?',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRadioOption(
                    context: context,
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
                    context: context,
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
                  label:
                      'If Non-Ghanaian, please indicate the country you are from?',
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
                  showOtherField:
                      false, // We'll handle the 'Other' field separately
                  otherController: _otherNationalityController,
                ),
              ),
              // Show 'Other' specification in a separate card when 'Other' is selected
              if (_specificNationality == 'Other')
                _buildQuestionCard(
                  child: TextField(
                    controller: _otherNationalityController,
                    decoration: InputDecoration(
                      hintText: 'Please specify',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade900
                          : Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
            ],

            // Years working with owner
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'For how many years has the respondent been working with owner?',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _yearsWithOwnerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter number of years',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade900
                          : Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onChanged: (value) {
                      // Only allow numbers
                      if (value.isNotEmpty &&
                          !RegExp(r'^\d+$').hasMatch(value)) {
                        _yearsWithOwnerController.text =
                            value.replaceAll(RegExp(r'[^0-9]'), '');
                        _yearsWithOwnerController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset: _yearsWithOwnerController.text.length),
                        );
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),

            // Add Workers Button
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                top: 16.0,
                bottom: 32.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkersInFarmPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Next: Workers in the Farm',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
