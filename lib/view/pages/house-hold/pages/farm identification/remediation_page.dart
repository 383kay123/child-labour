import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/daos/remediation_dao.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';

void _log(String message, {String name = 'RemediationPage', Object? error, StackTrace? stackTrace}) {
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

// Public interface for the RemediationPage state
abstract class RemediationPageStateInterface {
  bool validateForm();
  Future<bool> saveData();
  Map<String, dynamic> getFormData();
  
  // Getters for form data
  bool? get hasSchoolFees;
  bool get childProtectionEducation;
  bool get schoolKitsSupport;
  bool get igaSupport;
  bool get otherSupport;
  String? get communityAction;
  String? get otherSupportText;
  String? get communityActionOtherText;
}

class RemediationPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int coverPageId;

  const RemediationPage({
    Key? key,
    required this.onNext,
    required this.onPrevious,
    required this.coverPageId,
  }) : super(key: key);

  @override
  RemediationPageState createState() => RemediationPageState();
  
  // Helper method to get the state from a GlobalKey
  static RemediationPageStateInterface? of(GlobalKey<State<RemediationPage>> key) {
    final state = key.currentState;
    if (state is RemediationPageState) {
      return state;
    }
    return null;
  }
}

// Make the state class public by removing the underscore
class RemediationPageState extends State<RemediationPage> with WidgetsBindingObserver implements RemediationPageStateInterface {
  // Form state variables
  bool? _hasSchoolFees;
  bool _childProtectionEducation = false;
  bool _schoolKitsSupport = false;
  bool _igaSupport = false;
  bool _otherSupport = false;
  String? _communityAction;
  final TextEditingController _otherSupportController = TextEditingController();
  final TextEditingController _otherCommunityActionController = TextEditingController();
  
  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Form validation state
  bool _isFormValid = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _otherSupportController.addListener(_onOtherSupportChanged);
    _otherCommunityActionController.addListener(_onCommunityActionOtherChanged);
    _log('RemediationPage initialized');
    
    // Load saved data if any
    _loadSavedData();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _otherSupportController.dispose();
    _otherCommunityActionController.dispose();
    super.dispose();
  }
  
  // Implement interface getters
  @override
  bool? get hasSchoolFees => _hasSchoolFees;
  
  @override
  bool get childProtectionEducation => _childProtectionEducation;
  
  @override
  bool get schoolKitsSupport => _schoolKitsSupport;
  
  @override
  bool get igaSupport => _igaSupport;
  
  @override
  bool get otherSupport => _otherSupport;
  
  @override
  String? get communityAction => _communityAction;
  
  @override
  String? get otherSupportText => _otherSupportController.text.trim().isNotEmpty ? _otherSupportController.text.trim() : null;
  
  @override
  String? get communityActionOtherText => _communityAction == 'Other' ? _otherCommunityActionController.text.trim() : null;
  
  void _onOtherSupportChanged() {
    // No need to call setState here as we're not updating any state variables
  }
  
  void _onCommunityActionOtherChanged() {
    setState(() {
      // Update state when community action other text changes
    });
  }
  
  // Load saved data if any
  Future<void> _loadSavedData() async {
    try {
      final dbHelper = LocalDBHelper.instance;
      final remediationDao = RemediationDao(dbHelper: dbHelper);
      
      // Get the latest remediation data for this cover page
      final savedData = await remediationDao.getByCoverPageId(widget.coverPageId);
      if (savedData != null && mounted) {
        setState(() {
          _hasSchoolFees = savedData.hasSchoolFees;
          _childProtectionEducation = savedData.childProtectionEducation;
          _schoolKitsSupport = savedData.schoolKitsSupport;
          _igaSupport = savedData.igaSupport;
          _otherSupport = savedData.otherSupport;
          _communityAction = savedData.communityAction;
          
          _otherSupportController.text = savedData.otherSupportDetails ?? '';
          _otherCommunityActionController.text = savedData.otherCommunityActionDetails ?? '';
        });
      }
    } catch (e) {
      _log('Error loading saved data', error: e);
    }
  }
  
  // Validate the form
  @override
  bool validateForm() {
    _log('Validating form...');
    final formState = _formKey.currentState;
    if (formState == null) {
      _log('Form state is null', error: 'Form validation failed');
      return false;
    }
    
    final isValid = formState.validate();
    _log('Form validation result: $isValid');
    _log('Form data: ${getFormData().toString()}');
    
    if (mounted) {
      setState(() {
        _isFormValid = isValid;
      });
    }
    
    if (!isValid) {
      _log('Validation errors present', error: 'Please check the form for errors');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required fields'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    return isValid;
  }
  
  // Get form data as a map
  @override
  Map<String, dynamic> getFormData() {
    return {
      'hasSchoolFees': hasSchoolFees,
      'childProtectionEducation': childProtectionEducation,
      'schoolKitsSupport': schoolKitsSupport,
      'igaSupport': igaSupport,
      'otherSupport': otherSupport,
      'otherSupportText': _otherSupportController.text,
      'communityAction': communityAction,
      'communityActionOther': _otherCommunityActionController.text,
    };
  }

  /// Public method to save data, called from parent widgets
  @override
  Future<bool> saveData() async {
    return await saveFormData();
  }

  /// Saves the current form data to the database
  Future<bool> saveFormData([int coverPageId = 0]) async {
    _log('Saving form data for cover page ID: $coverPageId');
  
    if (!validateForm()) {
      _log('Form validation failed, not saving', error: 'Invalid form data');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fix the validation errors before saving'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
    
    // Show loading indicator
    bool? isDialogShown;
    
    try {
      _log('🔍 Getting database helper instance...');
      final dbHelper = LocalDBHelper.instance;
      final remediationDao = RemediationDao(dbHelper: dbHelper);
      
      _log('📋 Getting current form data...');
      final formData = getFormData();
      
      // Convert form data to RemediationModel
      final model = RemediationModel(
        hasSchoolFees: formData['hasSchoolFees'] as bool?,
        childProtectionEducation: formData['childProtectionEducation'] as bool? ?? false,
        schoolKitsSupport: formData['schoolKitsSupport'] as bool? ?? false,
        igaSupport: formData['igaSupport'] as bool? ?? false,
        otherSupport: formData['otherSupport'] as bool? ?? false,
        otherSupportDetails: formData['otherSupportText'] as String?,
        communityAction: formData['communityAction'] as String?,
        otherCommunityActionDetails: formData['communityActionOther'] as String?,
      );
      
      _log('📝 Form data: ${model.toMap()}');
      
      // Show loading dialog
      if (mounted) {
        isDialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving data...'),
                ],
              ),
            );
          },
        );
      }
      
      _log('🔍 Checking for existing records for cover page ID: $coverPageId');
      
      // First try to find a record with matching farm_identification_id
     final existingRecords = await remediationDao.findByCoverPageId(coverPageId);
      final existingRecord = existingRecords.isNotEmpty ? existingRecords.first : null;
      
      if (existingRecord != null) {
        _log('ℹ️ Found existing record ID: ${existingRecord.id}, will update');
        _log('🔄 Updating existing record ID: ${existingRecord.id}');
        final rowsUpdated = await remediationDao.update(model, existingRecord.id!);
        _log('✅ Remediation data updated. Rows affected: $rowsUpdated');
      } else {
        _log('ℹ️ No existing record found, will insert new record');
        _log('➕ Inserting new record...');
        try {
          final id = await remediationDao.insert(model, coverPageId);
          _log('✅ Remediation data inserted successfully with ID: $id');
        } catch (e) {
          _log('❌ Error inserting remediation data', error: e);
          rethrow;
        }
      }
      
      _log('🎉 Successfully saved remediation data');
      
      // Close the loading dialog if it was shown
      if (isDialogShown == true && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Show success message but DON'T navigate automatically
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remediation data saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      return true;
      
    } catch (e, stackTrace) {
      final errorMsg = '❌ Error saving remediation data: $e';
      _log(errorMsg, error: e, stackTrace: stackTrace);
      
      // Close the loading dialog if it was shown
      if (isDialogShown == true && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Show error message
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save data: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
      return false;
    }
  }

  // Validate required field
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
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
    bool isRequired = false,
    String? Function(String?)? validator,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
          onChanged: (value) {
            if (validator != null) {
              validator(value);
            }
            if (mounted) {
              setState(() {});
            }
          },
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _log('Building RemediationPage UI. Form valid: $_isFormValid');
    
    return Scaffold(
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: () {
          _log('Form changed, validating...');
          validateForm();
        },
        child: Column(
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
                                groupValue: _hasSchoolFees == true ? 'Yes' : _hasSchoolFees == false ? 'No' : null,
                                label: 'Yes',
                                onChanged: (value) {
                                  setState(() {
                                    _hasSchoolFees = value == 'Yes';
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'No',
                                groupValue: _hasSchoolFees == true ? 'Yes' : _hasSchoolFees == false ? 'No' : null,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: [
                                _buildCheckboxOption(
                                  label: 'Child protection and parenting education',
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
                                validator: (value) => _validateRequired(value, 'other support details'),
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
                            (_otherSupport &&
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
                                hintText: 'Enter details of other community action',
                                isRequired: true,
                                validator: (value) => _validateRequired(value, 'community action details'),
                              ),
                            ],
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),
                    const SizedBox(height: 80), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}