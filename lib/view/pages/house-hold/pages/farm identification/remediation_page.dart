import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/daos/remediation_dao.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';

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
  Future<bool> saveData([int? coverPageId]);
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
  final RemediationModel? remediationModel;

  const RemediationPage({
    Key? key,
    required this.onNext,
    required this.onPrevious,
    required this.coverPageId,
    this.remediationModel,
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

class RemediationPageState extends State<RemediationPage> 
    with WidgetsBindingObserver 
    implements RemediationPageStateInterface {
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
  void didUpdateWidget(RemediationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coverPageId != widget.coverPageId) {
      _loadSavedData();
    }
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
  String? get communityActionOtherText => _communityAction == 'Other (please specify)' ? _otherCommunityActionController.text.trim() : null;
  
  void _onOtherSupportChanged() {
    // Trigger validation when other support text changes
    if (mounted) {
      setState(() {});
    }
  }
  
  void _onCommunityActionOtherChanged() {
    // Trigger validation when community action other text changes
    if (mounted) {
      setState(() {});
    }
  }
  
  // Load saved data if any
  Future<void> _loadSavedData() async {
    try {
      final dbHelper = HouseholdDBHelper.instance;
      final remediationDao = RemediationDao(dbHelper: dbHelper);
      
      // Get the latest remediation data for this cover page
      final savedData = await remediationDao.getByCoverPageId(widget.coverPageId);
      if (savedData != null && mounted) {
        setState(() {
          _hasSchoolFees = savedData.hasSchoolFees;
          _childProtectionEducation = savedData.childProtectionEducation ?? false;
          _schoolKitsSupport = savedData.schoolKitsSupport ?? false;
          _igaSupport = savedData.igaSupport ?? false;
          _otherSupport = savedData.otherSupport ?? false;
          _communityAction = savedData.communityAction;
          
          _otherSupportController.text = savedData.otherSupportDetails ?? '';
          _otherCommunityActionController.text = savedData.otherCommunityActionDetails ?? '';
        });
        _log('Loaded saved remediation data for coverPageId: ${widget.coverPageId}');
      } else {
        _log('No saved remediation data found for coverPageId: ${widget.coverPageId}');
      }
    } catch (e, stackTrace) {
      _log('Error loading saved data', error: e, stackTrace: stackTrace);
    }
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

  /// Validates the form before saving
  @override
  bool validateForm() {
    _log('Validating form...');
    
    // Basic validation - at least one field should be filled
    if (hasSchoolFees == null && 
        !childProtectionEducation && 
        !schoolKitsSupport && 
        !igaSupport && 
        !otherSupport &&
        (communityAction == null || communityAction!.isEmpty)) {
      _log('No data entered');
      if (mounted) {
        setState(() {
          _isFormValid = false;
        });
      }
      return false;
    }

    // Validate other support details if other support is checked
    if (otherSupport && _otherSupportController.text.trim().isEmpty) {
      _log('Other support selected but no details provided');
      if (mounted) {
        setState(() {
          _isFormValid = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide details for "Other Support"'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }

    // Validate other community action details if "Other" is selected
    if (communityAction == 'Other (please specify)' && 
        _otherCommunityActionController.text.trim().isEmpty) {
      _log('Other community action selected but no details provided');
      if (mounted) {
        setState(() {
          _isFormValid = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide details for "Other Community Action"'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }

    _log('Form validation successful');
    if (mounted) {
      setState(() {
        _isFormValid = true;
      });
    }
    return true;
  }

  /// Saves the current form data to the database
  @override
  Future<bool> saveData([int? coverPageId]) async {
    try {
      final effectiveCoverPageId = coverPageId ?? widget.coverPageId;
      
      // Validate coverPageId
      if (effectiveCoverPageId <= 0) {
        _log('Error: Invalid or missing coverPageId: $effectiveCoverPageId');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Missing or invalid survey ID. Please start a new survey.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      // Validate form
      if (!validateForm()) {
        _log('Form validation failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete all required fields'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      _log('Starting save with coverPageId: $effectiveCoverPageId');

      // Create the remediation model with current form data
      final remediationData = RemediationModel(
        id: widget.remediationModel?.id, // Keep existing ID if updating
        coverPageId: effectiveCoverPageId,
        hasSchoolFees: hasSchoolFees,
        childProtectionEducation: childProtectionEducation,
        schoolKitsSupport: schoolKitsSupport,
        igaSupport: igaSupport,
        otherSupport: otherSupport,
        otherSupportDetails: otherSupport && _otherSupportController.text.trim().isNotEmpty
            ? _otherSupportController.text.trim()
            : null,
        communityAction: communityAction,
        otherCommunityActionDetails: communityAction == 'Other (please specify)' && 
            _otherCommunityActionController.text.trim().isNotEmpty
            ? _otherCommunityActionController.text.trim()
            : null,
      );

      _log('Data to save: ${remediationData.toMap()}');

      // Save to database using DAO
      final dao = RemediationDao(dbHelper: HouseholdDBHelper.instance);
      final id = await dao.insert(remediationData, effectiveCoverPageId);
      
      _log('Saved successfully with ID: $id');

      // Show success message
      if (mounted) {
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
      }

      return true;
    } catch (e, stackTrace) {
      _log('Error saving: $e', stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving remediation data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      return false;
    }
  }

  /// Saves the current form data to the database
  @Deprecated('Use saveData() instead')
  Future<bool> saveFormData(int coverPageId) async {
    return saveData(coverPageId);
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
      backgroundColor: Colors.grey.shade50,
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: () {
          _log('Form changed, validating...');
          validateForm();
        },
        child: Column(
          children: [
            // Header Section
    
            
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
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                validator: (value) => _otherSupport && (value == null || value.isEmpty) 
                                    ? 'Please provide details for other support'
                                    : null,
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
                                hintText: 'Enter details of other community action',
                                isRequired: true,
                                validator: (value) => _communityAction == 'Other (please specify)' && (value == null || value.isEmpty)
                                    ? 'Please provide details for other community action'
                                    : null,
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
      ),
      
    
    );
  }
}