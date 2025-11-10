import 'package:flutter/material.dart';

import 'sections/survey_availability_section.dart';
import 'sections/personal_info_section.dart';
import 'sections/family_decision_section.dart';
import 'sections/family_info_section.dart';
import 'sections/education_info_section.dart';
import 'sections/work_info_section.dart';
import 'sections/health_safety_section.dart';
import 'sections/photo_consent_section.dart';

class ChildDetailsNew extends StatefulWidget {
  final Function(dynamic) onComplete;
  final dynamic initialData;

  const ChildDetailsNew({
    Key? key,
    required this.onComplete,
    this.initialData,
  }) : super(key: key);

  @override
  _ChildDetailsNewState createState() => _ChildDetailsNewState();
}

class _ChildDetailsNewState extends State<ChildDetailsNew> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _childNumberController = TextEditingController();
  final TextEditingController _otherRelationshipController = TextEditingController();
  final TextEditingController _otherWorkTypeController = TextEditingController();
  final TextEditingController _healthIssuesController = TextEditingController();
  final TextEditingController _safetyConcernsController = TextEditingController();
  final TextEditingController _consentNotesController = TextEditingController();
  final TextEditingController _otherReasonController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();

  // State variables
  bool _canBeSurveyedNow = true;
  final Map<String, bool> _surveyNotPossibleReasons = {
    'Child is not at home': false,
    'Child is sleeping': false,
    'Child is sick': false,
    'Other (specify)': false,
  };
  final Map<String, bool> _surveyNotPossibleValues = {};
  String? _gender;
  DateTime? _dateOfBirth;
  String? _relationshipToHead;
  bool? _isFarmerChild;
  bool _showOtherRelationshipField = false;
  
  // Education
  bool _isInSchool = true;
  String? _schoolName;
  String? _grade;
  String? _schoolType;
  String? _schoolLocation;
  String? _schoolDistance;
  String? _transportType;
  String? _reasonNotInSchool;
  String? _otherReasonNotInSchool;
  
  // Work
  bool _isWorking = false;
  String? _workType;
  String? _workLocation;
  double? _hoursPerDay;
  int? _daysPerWeek;
  bool _isHazardousWork = false;
  String? _hazardsDescription;
  double? _monthlyIncome;
  
  // Health & Safety
  bool _hasHealthIssues = false;
  bool _hasAccessToMedicalCare = false;
  bool _hasSafetyConcerns = false;
  
  // Family Decision
  String? _educationDecisionMaker;
  String? _workDecisionMaker;
  String? _healthDecisionMaker;
  String? _otherEducationDecisionMaker;
  String? _otherWorkDecisionMaker;
  String? _otherHealthDecisionMaker;
  bool _showOtherEducationField = false;
  bool _showOtherWorkField = false;
  bool _showOtherHealthField = false;
  
  // Family Information
  String? _livingDuration;
  bool? _isOrphan;
  List<String> _orphanedParents = [];
  bool _showOrphanedParentsField = false;
  
  // Photo Consent
  bool _hasGivenConsent = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      // Load initial data if provided
      // Example: _nameController.text = widget.initialData['name'] ?? '';
      // Set other fields similarly
    }
    
    // Generate child number (example: CH-001, CH-002, etc.)
    _childNumberController.text = 'CH-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    
    // Initialize _isFarmerChild based on initial data if needed
    // _isFarmerChild = widget.initialData?['isFarmerChild'];
  }

  @override
  void dispose() {
    _childNumberController.dispose();
    // Dispose all controllers
    _nameController.dispose();
    _surnameController.dispose();
    _childNumberController.dispose();
    _otherRelationshipController.dispose();
    _otherWorkTypeController.dispose();
    _healthIssuesController.dispose();
    _safetyConcernsController.dispose();
    _consentNotesController.dispose();
    _birthYearController.dispose(); 
    super.dispose();
  }

  // Handle form submission
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Prepare data to return
      final formData = {
        'surveyAvailability': {
          'canBeSurveyedNow': _canBeSurveyedNow,
          'surveyNotPossibleReasons': _surveyNotPossibleReasons,
        },
        'personalInfo': {
          'name': _nameController.text,
          'surname': _surnameController.text,
          'childNumber': _childNumberController.text,
          'gender': _gender,
          'dateOfBirth': _dateOfBirth?.toIso8601String(),
          'relationshipToHead': _relationshipToHead,
          'otherRelationship': _otherRelationshipController.text,
          'isFarmerChild': _isFarmerChild,
        },
        'familyDecision': {
          'educationDecisionMaker': _educationDecisionMaker,
          'workDecisionMaker': _workDecisionMaker,
          'healthDecisionMaker': _healthDecisionMaker,
          'otherEducationDecisionMaker': _otherEducationDecisionMaker,
          'otherWorkDecisionMaker': _otherWorkDecisionMaker,
          'otherHealthDecisionMaker': _otherHealthDecisionMaker,
        },
        'familyInfo': {
          'livingDuration': _livingDuration,
          'isOrphan': _isOrphan,
          'orphanedParents': _orphanedParents,
        },
        'educationInfo': {
          'isInSchool': _isInSchool,
          'schoolName': _schoolName,
          'grade': _grade,
          'schoolType': _schoolType,
          'schoolLocation': _schoolLocation,
          'schoolDistance': _schoolDistance,
          'transportType': _transportType,
          'reasonNotInSchool': _reasonNotInSchool,
          'otherReasonNotInSchool': _otherReasonNotInSchool,
        },
        'workInfo': {
          'isWorking': _isWorking,
          'workType': _workType,
          'otherWorkType': _otherWorkTypeController.text,
          'workLocation': _workLocation,
          'hoursPerDay': _hoursPerDay,
          'daysPerWeek': _daysPerWeek,
          'isHazardousWork': _isHazardousWork,
          'hazardsDescription': _hazardsDescription,
          'monthlyIncome': _monthlyIncome,
        },
        'healthSafety': {
          'hasHealthIssues': _hasHealthIssues,
          'healthIssuesDescription': _healthIssuesController.text,
          'hasAccessToMedicalCare': _hasAccessToMedicalCare,
          'hasSafetyConcerns': _hasSafetyConcerns,
          'safetyConcernsDescription': _safetyConcernsController.text,
        },
        'photoConsent': {
          'hasGivenConsent': _hasGivenConsent,
          'consentNotes': _consentNotesController.text,
        },
      };

      // Return the form data
      widget.onComplete(formData);
      
      // Optionally navigate back
      Navigator.of(context).pop(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Survey Availability Section
              SurveyAvailabilitySection(
                isFarmerChild: _isFarmerChild,
                onFarmerChildChanged: (bool? newValue) {
                  if (mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _isFarmerChild = newValue;
                      });
                    });
                  }
                },
                childNumberController: _childNumberController,
                onSurveyAvailabilityChanged: (bool? canBeSurveyed) {
                  if (mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _canBeSurveyedNow = canBeSurveyed ?? true;
                      });
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Personal Information Section
             PersonalInfoSection(
  nameController: _nameController,
  surnameController: _surnameController,
  childNumberController: _childNumberController,
  birthYearController: _birthYearController,  // Add this line
  canBeSurveyedNow: _canBeSurveyedNow,
  gender: _gender,
  onGenderChanged: (value) {
    setState(() {
      _gender = value;
    });
  },
),
              
              const SizedBox(height: 24),
              
              // Family Decision Section
              FamilyDecisionSection(
                educationDecisionMaker: _educationDecisionMaker,
                workDecisionMaker: _workDecisionMaker,
                healthDecisionMaker: _healthDecisionMaker,
                otherEducationDecisionMaker: _otherEducationDecisionMaker,
                otherWorkDecisionMaker: _otherWorkDecisionMaker,
                otherHealthDecisionMaker: _otherHealthDecisionMaker,
                showEducationDecisionField: _canBeSurveyedNow,
                showWorkDecisionField: _canBeSurveyedNow,
                showHealthDecisionField: _canBeSurveyedNow,
                showOtherEducationField: _showOtherEducationField,
                showOtherWorkField: _showOtherWorkField,
                showOtherHealthField: _showOtherHealthField,
                onEducationDecisionChanged: (value) {
                  setState(() {
                    _educationDecisionMaker = value;
                    _showOtherEducationField = value == 'Other (specify)';
                  });
                },
                onWorkDecisionChanged: (value) {
                  setState(() {
                    _workDecisionMaker = value;
                    _showOtherWorkField = value == 'Other (specify)';
                  });
                },
                onHealthDecisionChanged: (value) {
                  setState(() {
                    _healthDecisionMaker = value;
                    _showOtherHealthField = value == 'Other (specify)';
                  });
                },
                onOtherEducationChanged: (value) => setState(() => _otherEducationDecisionMaker = value),
                onOtherWorkChanged: (value) => setState(() => _otherWorkDecisionMaker = value),
                onOtherHealthChanged: (value) => setState(() => _otherHealthDecisionMaker = value),
              ),
              
              const SizedBox(height: 24),
              
              // Family Information Section
              FamilyInfoSection(
                livingDuration: _livingDuration,
                isOrphan: _isOrphan,
                orphanedParents: _orphanedParents,
                showOrphanedParentsField: _showOrphanedParentsField,
                onLivingDurationChanged: (value) => setState(() => _livingDuration = value),
                onIsOrphanChanged: (value) {
                  setState(() {
                    _isOrphan = value;
                    _showOrphanedParentsField = value == true;
                    if (!_showOrphanedParentsField) {
                      _orphanedParents = [];
                    }
                  });
                },
                onOrphanedParentsChanged: (value) => setState(() => _orphanedParents = value),
              ),
              
              const SizedBox(height: 24),
              
              // Education Information Section
              EducationInfoSection(
                isInSchool: _isInSchool,
                schoolName: _schoolName,
                grade: _grade,
                schoolType: _schoolType,
                schoolLocation: _schoolLocation,
                schoolDistance: _schoolDistance,
                transportType: _transportType,
                reasonNotInSchool: _reasonNotInSchool,
                otherReasonNotInSchool: _otherReasonNotInSchool,
                showSchoolNameField: _isInSchool,
                showGradeField: _isInSchool,
                showSchoolTypeField: _isInSchool,
                showSchoolLocationField: _isInSchool,
                showSchoolDistanceField: _isInSchool,
                showTransportTypeField: _isInSchool,
                showReasonNotInSchoolField: !_isInSchool,
                showOtherReasonField: _reasonNotInSchool == 'Other (specify)',
                onIsInSchoolChanged: (value) => setState(() => _isInSchool = value ?? true),
                onSchoolNameChanged: (value) => _schoolName = value,
                onGradeChanged: (value) => _grade = value,
                onSchoolTypeChanged: (value) => _schoolType = value,
                onSchoolLocationChanged: (value) => _schoolLocation = value,
                onSchoolDistanceChanged: (value) => _schoolDistance = value,
                onTransportTypeChanged: (value) => _transportType = value,
                onReasonNotInSchoolChanged: (value) {
                  setState(() {
                    _reasonNotInSchool = value;
                    if (value != 'Other (specify)') {
                      _otherReasonNotInSchool = null;
                    }
                  });
                },
                onOtherReasonChanged: (value) => _otherReasonNotInSchool = value,
              ),
              
              const SizedBox(height: 24),
              
              // Work Information Section
              WorkInfoSection(
                isWorking: _isWorking,
                workType: _workType,
                workLocation: _workLocation,
                hoursPerDay: _hoursPerDay,
                daysPerWeek: _daysPerWeek,
                isHazardousWork: _isHazardousWork,
                hazardsDescription: _hazardsDescription,
                monthlyIncome: _monthlyIncome,
                otherWorkType: _otherWorkTypeController.text,
                showWorkTypeField: _isWorking,
                showWorkLocationField: _isWorking,
                showHoursField: _isWorking,
                showDaysField: _isWorking,
                showHazardField: _isWorking,
                showHazardsDescriptionField: _isWorking && _isHazardousWork,
                showIncomeField: _isWorking,
                showOtherWorkTypeField: _workType == 'Other (specify)',
                onIsWorkingChanged: (value) => setState(() => _isWorking = value ?? false),
                onWorkTypeChanged: (value) {
                  setState(() {
                    _workType = value;
                    if (value != 'Other (specify)') {
                      _otherWorkTypeController.clear();
                    }
                  });
                },
                onWorkLocationChanged: (value) => _workLocation = value,
                onHoursPerDayChanged: (value) => _hoursPerDay = double.tryParse(value),
                onDaysPerWeekChanged: (value) => _daysPerWeek = int.tryParse(value),
                onIsHazardousWorkChanged: (value) => setState(() => _isHazardousWork = value ?? false),
                onHazardsDescriptionChanged: (value) => _hazardsDescription = value,
                onMonthlyIncomeChanged: (value) => _monthlyIncome = double.tryParse(value),
                onOtherWorkTypeChanged: (value) => _otherWorkTypeController.text = value,
              ),
              
              const SizedBox(height: 24),
              
              // Health and Safety Section
              HealthSafetySection(
                hasHealthIssues: _hasHealthIssues,
                healthIssuesDescription: _healthIssuesController.text,
                hasAccessToMedicalCare: _hasAccessToMedicalCare,
                hasSafetyConcerns: _hasSafetyConcerns,
                safetyConcernsDescription: _safetyConcernsController.text,
                showHealthIssuesField: true,
                showHealthIssuesDescriptionField: _hasHealthIssues,
                showMedicalCareField: _hasHealthIssues,
                showSafetyConcernsField: true,
                showSafetyConcernsDescriptionField: _hasSafetyConcerns,
                onHasHealthIssuesChanged: (value) => setState(() => _hasHealthIssues = value ?? false),
                onHealthIssuesDescriptionChanged: (value) => _healthIssuesController.text = value,
                onHasAccessToMedicalCareChanged: (value) => setState(() => _hasAccessToMedicalCare = value ?? false),
                onHasSafetyConcernsChanged: (value) => setState(() => _hasSafetyConcerns = value ?? false),
                onSafetyConcernsDescriptionChanged: (value) => _safetyConcernsController.text = value,
              ),
              
              const SizedBox(height: 24),
              
              // Photo Consent Section
              PhotoConsentSection(
                hasGivenConsent: _hasGivenConsent,
                consentNotes: _consentNotesController.text,
                showConsentField: true,
                showNotesField: true,
                onConsentChanged: (value) => setState(() => _hasGivenConsent = value ?? false),
                onConsentNotesChanged: (value) => _consentNotesController.text = value,
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Child Details',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              
              const SizedBox(height: 24),
            ]   
          ),
        ),
      )
      );
    
  }
}
