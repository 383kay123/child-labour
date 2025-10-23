import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RemediationPage extends StatefulWidget {
  const RemediationPage({Key? key}) : super(key: key);

  @override
  _RemediationPageState createState() => _RemediationPageState();
}

class _RemediationPageState extends State<RemediationPage> {
  bool? hasSchoolFees;
  bool childProtectionEducation = false;
  bool schoolKitsSupport = false;
  bool igaSupport = false;
  bool otherSupport = false;
  String? communityAction;

  final TextEditingController _otherSupportController = TextEditingController();
  final TextEditingController _otherCommunityActionController =
      TextEditingController();

  @override
  void dispose() {
    _otherSupportController.dispose();
    _otherCommunityActionController.dispose();
    super.dispose();
  }

  Widget _buildQuestionCard({required Widget child}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
    return RadioListTile<String>(
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildCheckboxOption({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Remediation',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // School Fees Question
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Do you owe fees for the school of the children living in your household?',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 20,
                          children: [
                            _buildRadioOption(
                              value: 'Yes',
                              groupValue: hasSchoolFees?.toString(),
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  hasSchoolFees = value == 'Yes';
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: 'No',
                              groupValue: hasSchoolFees?.toString(),
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  hasSchoolFees = value == 'No';
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Support Options Question
                  if (hasSchoolFees != null)
                    _buildQuestionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What support is needed to prevent child labor?',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              _buildCheckboxOption(
                                label:
                                    'Child protection and parenting education',
                                value: childProtectionEducation,
                                onChanged: (value) {
                                  setState(() {
                                    childProtectionEducation = value ?? false;
                                  });
                                },
                              ),
                              _buildCheckboxOption(
                                label: 'School kits support',
                                value: schoolKitsSupport,
                                onChanged: (value) {
                                  setState(() {
                                    schoolKitsSupport = value ?? false;
                                  });
                                },
                              ),
                              _buildCheckboxOption(
                                label: 'IGA support',
                                value: igaSupport,
                                onChanged: (value) {
                                  setState(() {
                                    igaSupport = value ?? false;
                                  });
                                },
                              ),
                              _buildCheckboxOption(
                                label: 'Other (please specify)',
                                value: otherSupport,
                                onChanged: (value) {
                                  setState(() {
                                    otherSupport = value ?? false;
                                    if (!otherSupport) {
                                      _otherSupportController.clear();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          // Other Support Specification
                          if (otherSupport) ...[
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Please specify other support needed',
                              controller: _otherSupportController,
                              hintText: 'Enter details of other support needed',
                            ),
                          ],
                        ],
                      ),
                    ),

                  // Community Action Question
                  if (hasSchoolFees != null &&
                      (childProtectionEducation ||
                          schoolKitsSupport ||
                          igaSupport ||
                          (otherSupport &&
                              _otherSupportController.text.isNotEmpty)))
                    _buildQuestionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What can be done for the community to stop involving the children in child labour?',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              _buildRadioOption(
                                value: 'Community education on child labour',
                                groupValue: communityAction,
                                label: 'Community education on child labour',
                                onChanged: (value) {
                                  setState(() {
                                    communityAction = value;
                                    if (value != 'Other (please specify)') {
                                      _otherCommunityActionController.clear();
                                    }
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Community school building',
                                groupValue: communityAction,
                                label: 'Community school building',
                                onChanged: (value) {
                                  setState(() {
                                    communityAction = value;
                                    if (value != 'Other (please specify)') {
                                      _otherCommunityActionController.clear();
                                    }
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Community school renovation',
                                groupValue: communityAction,
                                label: 'Community school renovation',
                                onChanged: (value) {
                                  setState(() {
                                    communityAction = value;
                                    if (value != 'Other (please specify)') {
                                      _otherCommunityActionController.clear();
                                    }
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Other (please specify)',
                                groupValue: communityAction,
                                label: 'Other (please specify)',
                                onChanged: (value) {
                                  setState(() {
                                    communityAction = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          // Other Community Action Specification
                          if (communityAction == 'Other (please specify)') ...[
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Please specify other community action',
                              controller: _otherCommunityActionController,
                              hintText:
                                  'Enter details of other community action',
                            ),
                          ],
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
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
              // Next Button (Navigation removed)
              Expanded(
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (hasSchoolFees != null &&
                            communityAction != null &&
                            (communityAction != 'Other (please specify)' ||
                                _otherCommunityActionController
                                    .text.isNotEmpty))
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
    );
  }
}

// Removed class
// class EndOfCollectionPage extends StatelessWidget {
//   const EndOfCollectionPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('End of Collection'),
//       ),
//       body: Center(
//         child: Text('End of Collection Page'),
//       ),
//     );
//   }
// }
