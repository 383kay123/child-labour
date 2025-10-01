import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sensitization_page.dart';

class RemediationPage extends StatefulWidget {
  const RemediationPage({Key? key}) : super(key: key);

  @override
  _RemediationPageState createState() => _RemediationPageState();
}

class _RemediationPageState extends State<RemediationPage> {
  bool? hasSchoolFees;
  bool? needsSupportToStopChildLabor;
  bool childProtectionEducation = false;
  bool schoolKitsSupport = false;
  bool igaSupport = false;
  bool otherSupport = false;
  String? communityAction;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _supportDetailsController =
      TextEditingController();
  final TextEditingController _otherSupportController = TextEditingController();
  final TextEditingController _otherCommunityActionController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> communityActions = [
    'Community education on child labour',
    'Community school building',
    'Community school renovation',
    'Other (please specify)'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _supportDetailsController.dispose();
    _otherSupportController.dispose();
    _otherCommunityActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Remediation',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // School Fees Question
              Text(
                'Do you owe fees for the school of the children living in your household?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildRadioOption('Yes', true),
                  const SizedBox(width: 20),
                  _buildRadioOption('No', false),
                ],
              ),

              const SizedBox(height: 32),

              // Support Options
              Text(
                'What support is needed to prevent child labor?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Checkbox Options
              _buildSupportCheckbox(
                'Child protection and parenting education',
                childProtectionEducation,
                (bool? value) {
                  setState(() {
                    childProtectionEducation = value ?? false;
                  });
                },
              ),
              _buildSupportCheckbox(
                'School kits support',
                schoolKitsSupport,
                (bool? value) {
                  setState(() {
                    schoolKitsSupport = value ?? false;
                  });
                },
              ),
              _buildSupportCheckbox(
                'IGA support',
                igaSupport,
                (bool? value) {
                  setState(() {
                    igaSupport = value ?? false;
                  });
                },
              ),
              _buildSupportCheckbox(
                'Other (please specify)',
                otherSupport,
                (bool? value) {
                  setState(() {
                    otherSupport = value ?? false;
                    if (!otherSupport) {
                      _otherSupportController.clear();
                    }
                  });
                },
              ),
              if (otherSupport) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 32.0, right: 16.0),
                  child: TextFormField(
                    controller: _otherSupportController,
                    decoration: InputDecoration(
                      hintText: 'Please specify other support needed',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 24),

              // Community Action Question
              Text(
                'What can be done for the community to stop involving the children in child labour?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...communityActions.map((action) {
                final isOther = action == 'Other (please specify)';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<String>(
                      title: Text(
                        action,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: action,
                      groupValue: communityAction,
                      onChanged: (String? value) {
                        setState(() {
                          communityAction = value;
                          if (!isOther) {
                            _otherCommunityActionController.clear();
                          }
                        });
                      },
                      activeColor: theme.primaryColor,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (isOther && communityAction == action)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 32.0, right: 16.0, bottom: 8.0),
                        child: TextFormField(
                          controller: _otherCommunityActionController,
                          decoration: InputDecoration(
                            hintText: 'Please specify',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          minLines: 1,
                          maxLines: 2,
                        ),
                      ),
                  ],
                );
              }).toList(),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Save the form data if needed
                      // Then navigate to SensitizationPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SensitizationPage(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Information',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(String label, bool value) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: hasSchoolFees,
          onChanged: (bool? newValue) {
            setState(() {
              hasSchoolFees = newValue;
              if (newValue == false) {
                _amountController.clear();
              }
            });
          },
          activeColor: const Color(0xFF1A5F7A),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
