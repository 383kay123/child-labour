import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/daos/remediation_dao.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/sensitization/sensitization_page.dart';

void _log(String message,
    {String name = 'RemediationPage', Object? error, StackTrace? stackTrace}) {
  developer.log(
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
    time: DateTime.now(),
  );
  debugPrint('[$name] $message');
  if (error != null) {
    debugPrint('Error: $error');
  }
  if (stackTrace != null) {
    debugPrint('Stack trace: $stackTrace');
  }
}

class RemediationPage extends StatefulWidget {
  final int coverPageId;

  const RemediationPage({
    Key? key,
    required this.coverPageId,
  }) : super(key: key);

  @override
  RemediationPageState createState() => RemediationPageState();
}

class RemediationPageState extends State<RemediationPage> {
  // ==================== FORM STATE ====================
  bool? _hasSchoolFees;
  bool _childProtectionEducation = false;
  bool _schoolKitsSupport = false;
  bool _igaSupport = false;
  bool _otherSupport = false;
  String? _communityAction;
  final TextEditingController _otherSupportController = TextEditingController();
  final TextEditingController _otherCommunityActionController =
      TextEditingController();

  // ==================== TRACKING STATE ====================
  bool _isSaving = false;
  bool _isFormValid = false;

  // ==================== INITIALIZATION ====================
  @override
  void initState() {
    super.initState();
    _log('RemediationPage initialized for coverPageId: ${widget.coverPageId}');
    _loadSavedData();
  }

  // ==================== DATA LOADING ====================
  Future<void> _loadSavedData() async {
    try {
      final dbHelper = HouseholdDBHelper.instance;
      final remediationDao = RemediationDao(dbHelper: dbHelper);

      final savedData =
          await remediationDao.getByCoverPageId(widget.coverPageId);
      if (savedData != null && mounted) {
        setState(() {
          _hasSchoolFees = savedData.hasSchoolFees;
          _childProtectionEducation =
              savedData.childProtectionEducation ?? false;
          _schoolKitsSupport = savedData.schoolKitsSupport ?? false;
          _igaSupport = savedData.igaSupport ?? false;
          _otherSupport = savedData.otherSupport ?? false;
          _communityAction = savedData.communityAction;
          _otherSupportController.text = savedData.otherSupportDetails ?? '';
          _otherCommunityActionController.text =
              savedData.otherCommunityActionDetails ?? '';
        });
        _log('Loaded saved data for coverPageId: ${widget.coverPageId}');
      }
    } catch (e, stackTrace) {
      _log('Error loading saved data', error: e, stackTrace: stackTrace);
    }
  }

  // ==================== FORM VALIDATION ====================
  bool _validateForm() {
    // Check if at least one field is filled
    final hasData = _hasSchoolFees != null ||
        _childProtectionEducation ||
        _schoolKitsSupport ||
        _igaSupport ||
        _otherSupport ||
        (_communityAction != null && _communityAction!.isNotEmpty);

    if (!hasData) {
      setState(() => _isFormValid = false);
      return false;
    }

    // Validate other support details
    if (_otherSupport && _otherSupportController.text.trim().isEmpty) {
      setState(() => _isFormValid = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide details for "Other Support"'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    // Validate other community action details
    if (_communityAction == 'Other (please specify)' &&
        _otherCommunityActionController.text.trim().isEmpty) {
      setState(() => _isFormValid = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide details for "Other Community Action"'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    setState(() => _isFormValid = true);
    return true;
  }

  // ==================== DATA SAVING ====================
  Future<void> _saveData() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Validate form
      if (!_validateForm()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create remediation model
      final remediationData = RemediationModel(
        coverPageId: widget.coverPageId,
        hasSchoolFees: _hasSchoolFees,
        childProtectionEducation: _childProtectionEducation,
        schoolKitsSupport: _schoolKitsSupport,
        igaSupport: _igaSupport,
        otherSupport: _otherSupport,
        otherSupportDetails:
            _otherSupport && _otherSupportController.text.trim().isNotEmpty
                ? _otherSupportController.text.trim()
                : null,
        communityAction: _communityAction,
        otherCommunityActionDetails:
            _communityAction == 'Other (please specify)' &&
                    _otherCommunityActionController.text.trim().isNotEmpty
                ? _otherCommunityActionController.text.trim()
                : null,
      );

      // Save to database
      final dao = RemediationDao(dbHelper: HouseholdDBHelper.instance);
      final id = await dao.insert(remediationData, widget.coverPageId);

      _log('Saved successfully with ID: $id');

      // if (id >= 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SensitizationPage(
            coverPageId: widget.coverPageId,
          );
        }));
      // }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Remediation data saved successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      _log('Error saving: $e', stackTrace: stackTrace);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving remediation data: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ==================== UI COMPONENTS ====================
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
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
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

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // ==================== MAIN BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remediation'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
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
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 20,
                          children: [
                            _buildRadioOption(
                              value: 'Yes',
                              groupValue: _hasSchoolFees == true
                                  ? 'Yes'
                                  : _hasSchoolFees == false
                                      ? 'No'
                                      : null,
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  _hasSchoolFees = value == 'Yes';
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: 'No',
                              groupValue: _hasSchoolFees == true
                                  ? 'Yes'
                                  : _hasSchoolFees == false
                                      ? 'No'
                                      : null,
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  _hasSchoolFees = value == 'Yes';
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Support Options Question
                  if (_hasSchoolFees != null)
                    _buildQuestionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What should be done for the parent to stop involving their children in child labour?',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              _buildCheckboxOption(
                                label:
                                    'Child protection and parenting education',
                                value: _childProtectionEducation,
                                onChanged: (value) {
                                  setState(() {
                                    _childProtectionEducation = value ?? false;
                                  });
                                },
                              ),
                              _buildCheckboxOption(
                                label: 'School kits support',
                                value: _schoolKitsSupport,
                                onChanged: (value) {
                                  setState(() {
                                    _schoolKitsSupport = value ?? false;
                                  });
                                },
                              ),
                              _buildCheckboxOption(
                                label: 'IGA support',
                                value: _igaSupport,
                                onChanged: (value) {
                                  setState(() {
                                    _igaSupport = value ?? false;
                                  });
                                },
                              ),
                              _buildCheckboxOption(
                                label: 'Other (please specify)',
                                value: _otherSupport,
                                onChanged: (value) {
                                  setState(() {
                                    _otherSupport = value ?? false;
                                    if (!_otherSupport) {
                                      _otherSupportController.clear();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          // Other Support Specification
                          if (_otherSupport) ...[
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Please specify other support needed',
                              controller: _otherSupportController,
                              hintText: 'Enter details of other support needed',
                              isRequired: true,
                            ),
                          ],
                        ],
                      ),
                    ),

                  // Community Action Question
                  if (_hasSchoolFees != null &&
                      (_childProtectionEducation ||
                          _schoolKitsSupport ||
                          _igaSupport ||
                          _otherSupport))
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
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              _buildRadioOption(
                                value: 'Community education on child labour',
                                groupValue: _communityAction,
                                label: 'Community education on child labour',
                                onChanged: (value) {
                                  setState(() {
                                    _communityAction = value;
                                    if (value != 'Other (please specify)') {
                                      _otherCommunityActionController.clear();
                                    }
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Community school building',
                                groupValue: _communityAction,
                                label: 'Community school building',
                                onChanged: (value) {
                                  setState(() {
                                    _communityAction = value;
                                    if (value != 'Other (please specify)') {
                                      _otherCommunityActionController.clear();
                                    }
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Community school renovation',
                                groupValue: _communityAction,
                                label: 'Community school renovation',
                                onChanged: (value) {
                                  setState(() {
                                    _communityAction = value;
                                    if (value != 'Other (please specify)') {
                                      _otherCommunityActionController.clear();
                                    }
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'Other (please specify)',
                                groupValue: _communityAction,
                                label: 'Other (please specify)',
                                onChanged: (value) {
                                  setState(() {
                                    _communityAction = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          // Other Community Action Specification
                          if (_communityAction == 'Other (please specify)') ...[
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Please specify other community action',
                              controller: _otherCommunityActionController,
                              hintText:
                                  'Enter details of other community action',
                              isRequired: true,
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
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ==================== CLEANUP ====================
  @override
  void dispose() {
    _otherSupportController.dispose();
    _otherCommunityActionController.dispose();
    super.dispose();
  }
}
