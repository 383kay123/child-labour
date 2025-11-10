import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/daos/remediation_dao.dart';
import 'package:human_rights_monitor/controller/models/remediation_model.dart';

class RemediationPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const RemediationPage({
    Key? key,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  RemediationPageState createState() => RemediationPageState();
}

class RemediationPageState extends State<RemediationPage> {
  // Make these fields public for validation
  bool? hasSchoolFees;
  bool childProtectionEducation = false;
  bool schoolKitsSupport = false;
  bool igaSupport = false;
  bool otherSupport = false;
  String? communityAction;
  final TextEditingController _otherSupportController = TextEditingController();
  final TextEditingController _otherCommunityActionController = TextEditingController();
  
  // Getters for validation
  String get otherSupportText => _otherSupportController.text;
  String get communityActionOtherText => _otherCommunityActionController.text;
  // State variables are now declared above

  @override
  void dispose() {
    _otherSupportController.dispose();
    _otherCommunityActionController.dispose();
    super.dispose();
  }

  /// Saves the current form data to the database
  /// [farmIdentificationId] - The ID of the farm identification record to associate with this remediation data.
  /// If not provided, defaults to 0 (temporary value until we get the actual ID).
  Future<bool> saveData([int farmIdentificationId = 0]) async {
    try {
      // Create a RemediationModel with the current state
      final model = RemediationModel(
        hasSchoolFees: hasSchoolFees,
        childProtectionEducation: childProtectionEducation,
        schoolKitsSupport: schoolKitsSupport,
        igaSupport: igaSupport,
        otherSupport: otherSupport,
        otherSupportDetails: otherSupport ? _otherSupportController.text : null,
        communityAction: communityAction,
        otherCommunityActionDetails: communityAction == 'Other' 
            ? _otherCommunityActionController.text 
            : null,
      );

      // Get the database helper instance
      final dbHelper = LocalDBHelper.instance;
      final remediationDao = RemediationDao(dbHelper: dbHelper);
      
      // Check if a record already exists for this farm identification
      final existingRecord = await remediationDao.getByFarmIdentificationId(farmIdentificationId);
      
      // Save the data
      if (existingRecord == null) {
        // Insert new record
        await remediationDao.insert(model, farmIdentificationId);
      } else {
        // Update existing record
        await remediationDao.update(model, farmIdentificationId);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error saving remediation data: $e');
      return false;
    }
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
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (String? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
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
                            fontSize: 14,
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
                              groupValue: hasSchoolFees == true ? 'Yes' : hasSchoolFees == false ? 'No' : null,
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  hasSchoolFees = value == 'Yes';
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: 'No',
                              groupValue: hasSchoolFees == true ? 'Yes' : hasSchoolFees == false ? 'No' : null,
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  hasSchoolFees = value == 'Yes';
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
                            'What should be done for the parent to stop involving their children in child labour?',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
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
      // Navigation is handled by the parent component
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
