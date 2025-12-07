import 'dart:io';
import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/child_details.dart';
import 'package:human_rights_monitor/controller/models/chilld_details_model.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/remediation/remediation_page.dart';
import 'package:image_picker/image_picker.dart';

// ==================== CUSTOM WIDGETS ====================

class CustomRadioButton<T> extends StatelessWidget {
  final T? value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final String title;
  final String? subtitle;

  const CustomRadioButton({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.1)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? theme.primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : Colors.grey.shade500,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String title;
  final String? subtitle;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => WidgetsBinding.instance.addPostFrameCallback((_) {
            onChanged(!value);
          }),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: value ? primaryColor.withOpacity(0.1) : Colors.grey[50],
              border: Border.all(
                color: value ? primaryColor : Colors.grey[300]!,
                width: value ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: value ? primaryColor : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: value ? primaryColor : Colors.transparent,
                  ),
                  child: value
                      ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: value ? primaryColor : Colors.grey[800],
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 11,
                            color: value
                                ? primaryColor.withOpacity(0.8)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
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

// ==================== CHILD DETAILS PAGE ====================

class ChildDetailsPage extends StatefulWidget {
  final int coverPageId;
  final int totalChildren;

  const ChildDetailsPage({
    Key? key,
    required this.coverPageId,
    required this.totalChildren,
  }) : super(key: key);

  @override
  State<ChildDetailsPage> createState() => _ChildDetailsPageState();
}

class _ChildDetailsPageState extends State<ChildDetailsPage> {
  // ==================== TRACKING STATE ====================
  int _currentChildNumber = 1;
  final List<ChildDetailsModel> _savedChildren = [];
  bool _isSaving = false;

  // ==================== FORM STATE ====================
  final _formKey = GlobalKey<FormState>();

  // Basic Information
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _childNumberController = TextEditingController();
  String? _gender;
  bool? _isFarmerChild;
  bool? _canBeSurveyedNow;
  bool? _hasBirthCertificate;
  String? _bornInCommunity;
  String? _birthCountry;
  String? _relationshipToHead;
  final TextEditingController _noBirthCertificateReasonController = TextEditingController();
  final TextEditingController _otherRelationshipController = TextEditingController();

  // Family Information
  String? _fatherResidence;
  String? _fatherCountry;
  String? _motherResidence;
  String? _motherCountry;
  String? _timeInHousehold;
  String? _whoAccompaniedChild;
  bool? _childAgreedWithDecision;
  bool? _hasSpokenWithParents;
  String? _whoDecidedChildCame;
  String? _lastTimeSpokeWithParents;
  final TextEditingController _otherFatherCountryController = TextEditingController();
  final TextEditingController _otherMotherCountryController = TextEditingController();
  final TextEditingController _otherAccompaniedController = TextEditingController();
  final TextEditingController _otherWhoDecidedController = TextEditingController();

  // Education Information
  bool? _isCurrentlyEnrolled;
  final TextEditingController _schoolNameController = TextEditingController();
  String? _schoolType;
  String? _gradeLevel;
  String? _educationLevel;
  bool? _hasEverBeenToSchool;
  bool? _attendedSchoolLast7Days;
  bool? _missedSchoolDays;
  String? _reasonNotAttendedSchool;
  String? _reasonForLeavingSchool;
  String? _reasonNeverAttendedSchool;
  String? _canWriteSentences;
  final TextEditingController _leftSchoolYearController = TextEditingController();
  final TextEditingController _otherReasonNotAttendedController = TextEditingController();
  final TextEditingController _otherReasonForLeavingSchoolController = TextEditingController();
  final TextEditingController _otherReasonNeverAttendedController = TextEditingController();
  final Map<String, bool> _absenceReasons = {
    'He/she was sick': false,
    'He/she was working': false,
    'He/she traveled': false,
    'Other': false,
  };
  final TextEditingController _otherAbsenceReasonController = TextEditingController();
  final Set<String> _availableSchoolSupplies = {};
  String? _schoolAttendanceFrequency;

  // Work Information
  bool? _workedInHouse;
  bool? _workedOnCocoaFarm;
  final Set<String> _cocoaFarmTasks = {};
  String? _workFrequency;
  bool? _observedWorking;
  bool? _receivedRemuneration;
  String? _workForWhom;
  final Set<String> _whyWorkReasons = {};
  final TextEditingController _workForWhomOtherController = TextEditingController();
  final TextEditingController _whyWorkOtherController = TextEditingController();

  // Light Tasks (7 Days)
  bool? _receivedRemunerationLighttasks7days;
  String? _longestLightDutyTimeLighttasks7days;
  String? _longestNonSchoolDayTimeLighttasks7days;
  bool? _wasSupervisedByAdultLighttasks7days;
  String? _taskLocationLighttasks7days;
  final TextEditingController _otherLocationLighttasks7daysController = TextEditingController();
  final TextEditingController _schoolDayTaskDurationLighttasks7daysController = TextEditingController();
  final TextEditingController _nonSchoolDayTaskDurationLighttasks7daysController = TextEditingController();

  // Light Tasks (12 Months)
  bool? _receivedRemunerationLighttasks12months;
  String? _longestSchoolDayTimeLighttasks12months;
  String? _longestNonSchoolDayTimeLighttasks12months;
  String? _taskLocationLighttasks12months;
  String? _otherTaskLocationLighttasks12months;
  String? _totalSchoolDayHoursLighttasks12months;
  String? _totalNonSchoolDayHoursLighttasks12months;
  bool? _wasSupervisedDuringTaskLighttasks12months;

  // Dangerous Tasks (7 Days)
  bool? _hasReceivedSalaryDangeroustask7days;
  String? _taskLocationDangeroustask7days;
  final TextEditingController _otherLocationDangeroustask7daysController = TextEditingController();
  String? _longestSchoolDayTimeDangeroustask7days;
  String? _longestNonSchoolDayTimeDangeroustask7days;
  final TextEditingController _schoolDayHoursDangeroustask7daysController = TextEditingController();
  final TextEditingController _nonSchoolDayHoursDangeroustask7daysController = TextEditingController();
  bool? _wasSupervisedByAdultDangeroustask7days;

  // Dangerous Tasks (12 Months)
  bool? _hasReceivedSalaryDangeroustask12months;
  String? _taskLocationDangeroustask12months;
  final TextEditingController _otherLocationDangeroustask12monthsController = TextEditingController();
  String? _longestSchoolDayTimeDangeroustask12months;
  String? _longestNonSchoolDayTimeDangeroustask12months;
  final TextEditingController _schoolDayHoursDangeroustask12monthsController = TextEditingController();
  final TextEditingController _nonSchoolDayHoursDangeroustask12monthsController = TextEditingController();
  bool? _wasSupervisedByAdultDangeroustask12months;
  final Set<String> _dangerousTasks12Months = {};
  final Set<String> _tasksLast12Months = {};

  // Health and Safety
  bool? _appliedAgrochemicals;
  bool? _onFarmDuringApplication;
  bool? _sufferedInjury;
  bool? _oftenFeelPains;
  final TextEditingController _howWoundedController = TextEditingController();
  final TextEditingController _whenWoundedController = TextEditingController();
  final Set<String> _helpReceived = {};
  final TextEditingController _otherHelpController = TextEditingController();

  // Photo Consent
  bool? _parentConsentPhoto;
  File? _childPhoto;
  final TextEditingController _noConsentReasonController = TextEditingController();

  // Survey Reasons
  final Set<String> _surveyNotPossibleReasons = {};
  final TextEditingController _otherSurveyReasonController = TextEditingController();

  // Lists for dropdowns
  final List<String> _gradeLevels = [
    'Kindergarten 1',
    'Kindergarten 2',
    'Primary 1',
    'Primary 2',
    'Primary 3',
    'Primary 4',
    'Primary 5',
    'Primary 6',
    'JHS/JSS 1',
    'JHS/JSS 2',
    'JHS/JSS 3',
    'SSS/JHS 1',
    'SSS/JHS 2',
    'SSS/JHS 3',
    'SSS/JHS 4',
  ];

  final List<String> _countries = [
    'Benin',
    'Burkina Faso',
    'Ivory Coast',
    'Mali',
    'Niger',
    'Togo',
    'Other'
  ];

  final List<String> _fatherCountries = [
    'Benin',
    'Burkina Faso',
    'Ghana',
    'Guinea',
    'Guinea-Bissau',
    'Liberia',
    'Mauritania',
    'Mali',
    'Nigeria',
    'Niger',
    'Sénégal',
    'Sierra Leone',
    'Togo',
    'Don\'t know',
    'Others to be specified'
  ];

  // ==================== INITIALIZATION ====================
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _childNumberController.text = _currentChildNumber.toString();
  }

  // ==================== FORM RESET ====================
  void _resetForm() {
    setState(() {
      // Clear all controllers
      _nameController.clear();
      _surnameController.clear();
      _birthYearController.clear();
      _noBirthCertificateReasonController.clear();
      _otherRelationshipController.clear();
      _otherFatherCountryController.clear();
      _otherMotherCountryController.clear();
      _otherAccompaniedController.clear();
      _otherWhoDecidedController.clear();
      _schoolNameController.clear();
      _leftSchoolYearController.clear();
      _otherReasonNotAttendedController.clear();
      _otherReasonForLeavingSchoolController.clear();
      _otherReasonNeverAttendedController.clear();
      _otherAbsenceReasonController.clear();
      _workForWhomOtherController.clear();
      _whyWorkOtherController.clear();
      _otherLocationLighttasks7daysController.clear();
      _schoolDayTaskDurationLighttasks7daysController.clear();
      _nonSchoolDayTaskDurationLighttasks7daysController.clear();
      _otherLocationDangeroustask7daysController.clear();
      _schoolDayHoursDangeroustask7daysController.clear();
      _nonSchoolDayHoursDangeroustask7daysController.clear();
      _otherLocationDangeroustask12monthsController.clear();
      _schoolDayHoursDangeroustask12monthsController.clear();
      _nonSchoolDayHoursDangeroustask12monthsController.clear();
      _howWoundedController.clear();
      _whenWoundedController.clear();
      _otherHelpController.clear();
      _noConsentReasonController.clear();
      _otherSurveyReasonController.clear();

      // Reset all state variables
      _gender = null;
      _isFarmerChild = null;
      _canBeSurveyedNow = null;
      _hasBirthCertificate = null;
      _bornInCommunity = null;
      _birthCountry = null;
      _relationshipToHead = null;
      _fatherResidence = null;
      _fatherCountry = null;
      _motherResidence = null;
      _motherCountry = null;
      _timeInHousehold = null;
      _whoAccompaniedChild = null;
      _childAgreedWithDecision = null;
      _hasSpokenWithParents = null;
      _whoDecidedChildCame = null;
      _lastTimeSpokeWithParents = null;
      _isCurrentlyEnrolled = null;
      _schoolType = null;
      _gradeLevel = null;
      _educationLevel = null;
      _hasEverBeenToSchool = null;
      _attendedSchoolLast7Days = null;
      _missedSchoolDays = null;
      _reasonNotAttendedSchool = null;
      _reasonForLeavingSchool = null;
      _reasonNeverAttendedSchool = null;
      _canWriteSentences = null;
      _workedInHouse = null;
      _workedOnCocoaFarm = null;
      _workFrequency = null;
      _observedWorking = null;
      _receivedRemuneration = null;
      _workForWhom = null;
      _receivedRemunerationLighttasks7days = null;
      _longestLightDutyTimeLighttasks7days = null;
      _longestNonSchoolDayTimeLighttasks7days = null;
      _wasSupervisedByAdultLighttasks7days = null;
      _taskLocationLighttasks7days = null;
      _receivedRemunerationLighttasks12months = null;
      _longestSchoolDayTimeLighttasks12months = null;
      _longestNonSchoolDayTimeLighttasks12months = null;
      _taskLocationLighttasks12months = null;
      _otherTaskLocationLighttasks12months = null;
      _totalSchoolDayHoursLighttasks12months = null;
      _totalNonSchoolDayHoursLighttasks12months = null;
      _wasSupervisedDuringTaskLighttasks12months = null;
      _hasReceivedSalaryDangeroustask7days = null;
      _taskLocationDangeroustask7days = null;
      _longestSchoolDayTimeDangeroustask7days = null;
      _longestNonSchoolDayTimeDangeroustask7days = null;
      _wasSupervisedByAdultDangeroustask7days = null;
      _hasReceivedSalaryDangeroustask12months = null;
      _taskLocationDangeroustask12months = null;
      _longestSchoolDayTimeDangeroustask12months = null;
      _longestNonSchoolDayTimeDangeroustask12months = null;
      _wasSupervisedByAdultDangeroustask12months = null;
      _appliedAgrochemicals = null;
      _onFarmDuringApplication = null;
      _sufferedInjury = null;
      _oftenFeelPains = null;
      _parentConsentPhoto = null;

      // Clear all sets
      _cocoaFarmTasks.clear();
      _whyWorkReasons.clear();
      _dangerousTasks12Months.clear();
      _tasksLast12Months.clear();
      _helpReceived.clear();
      _surveyNotPossibleReasons.clear();
      _availableSchoolSupplies.clear();

      // Reset absence reasons
      _absenceReasons.updateAll((key, value) => false);

      // Clear photo
      _childPhoto = null;

      // Update child number for next child
      _currentChildNumber++;
      _childNumberController.text = _currentChildNumber.toString();
    });
  }

  // ==================== DATA SAVING ====================
  Future<void> _saveCurrentChild() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final childModel = ChildDetailsModel(
        coverPageId: widget.coverPageId,
        isFarmerChild: _isFarmerChild,
        childNumber: _currentChildNumber,
        birthYear: _birthYearController.text.isNotEmpty
            ? int.tryParse(_birthYearController.text)
            : null,
        canBeSurveyedNow: _canBeSurveyedNow,
        surveyNotPossibleReasons: _surveyNotPossibleReasons.toList(),
        otherSurveyReason: _otherSurveyReasonController.text,
        childName: _nameController.text,
        childSurname: _surnameController.text,
        childGender: _gender,
        childAge: _birthYearController.text.isNotEmpty
            ? DateTime.now().year - int.parse(_birthYearController.text)
            : null,
        hasBirthCertificate: _hasBirthCertificate,
        noBirthCertificateReason: _noBirthCertificateReasonController.text,
        bornInCommunity: _bornInCommunity,
        birthCountry: _birthCountry,
        relationshipToHead: _relationshipToHead,
        otherRelationship: _otherRelationshipController.text,
        fatherResidence: _fatherResidence,
        fatherCountry: _fatherCountry,
        otherFatherCountry: _otherFatherCountryController.text,
        motherResidence: _motherResidence,
        motherCountry: _motherCountry,
        otherMotherCountry: _otherMotherCountryController.text,
        isCurrentlyEnrolled: _isCurrentlyEnrolled,
        schoolName: _schoolNameController.text,
        schoolType: _schoolType,
        gradeLevel: _gradeLevel,
        hasEverBeenToSchool: _hasEverBeenToSchool,
        leftSchoolYear: _leftSchoolYearController.text,
        attendedSchoolLast7Days: _attendedSchoolLast7Days,
        reasonNotAttendedSchool: _reasonNotAttendedSchool,
        otherReasonNotAttended: _otherReasonNotAttendedController.text,
        missedSchoolDays: _missedSchoolDays,
        absenceReasons: _absenceReasons,
        otherAbsenceReason: _otherAbsenceReasonController.text,
        workedInHouse: _workedInHouse,
        workedOnCocoaFarm: _workedOnCocoaFarm,
        cocoaFarmTasks: _cocoaFarmTasks.toList(),
        workFrequency: _workFrequency,
        observedWorking: _observedWorking,
        receivedRemuneration: _receivedRemuneration,
        wasSupervisedByAdultLighttasks7days: _wasSupervisedByAdultLighttasks7days,
        longestLightDutyTimeLighttasks7days: _longestLightDutyTimeLighttasks7days,
        longestNonSchoolDayTimeLighttasks7days: _longestNonSchoolDayTimeLighttasks7days,
        tasksLast12Months: _tasksLast12Months.toList(),
        taskLocationLighttasks7days: _taskLocationLighttasks7days,
        otherLocationLighttasks7days: _otherLocationLighttasks7daysController.text,
        schoolDayTaskHoursLighttasks7days: _schoolDayTaskDurationLighttasks7daysController.text,
        nonSchoolDayTaskHoursLighttasks7days: _nonSchoolDayTaskDurationLighttasks7daysController.text,
        educationLevel: _educationLevel,
        canWriteSentences: _canWriteSentences,
        reasonForLeavingSchool: _reasonForLeavingSchool,
        otherReasonForLeavingSchool: _otherReasonForLeavingSchoolController.text,
        reasonNeverAttendedSchool: _reasonNeverAttendedSchool,
        otherReasonNeverAttended: _otherReasonNeverAttendedController.text,
        workForWhom: _workForWhom,
        otherWorkForWhom: _workForWhomOtherController.text,
        whyWorkReasons: _whyWorkReasons.toList(),
        otherWhyWorkReason: _whyWorkOtherController.text,
        receivedRemunerationLighttasks12months: _receivedRemunerationLighttasks12months,
        longestSchoolDayTimeLighttasks12months: _longestSchoolDayTimeLighttasks12months,
        longestNonSchoolDayTimeLighttasks12months: _longestNonSchoolDayTimeLighttasks12months,
        taskLocationLighttasks12months: _taskLocationLighttasks12months,
        otherTaskLocationLighttasks12months: _otherTaskLocationLighttasks12months,
        totalSchoolDayHoursLighttasks12months: _totalSchoolDayHoursLighttasks12months,
        totalNonSchoolDayHoursLighttasks12months: _totalNonSchoolDayHoursLighttasks12months,
        wasSupervisedDuringTaskLighttasks12months: _wasSupervisedDuringTaskLighttasks12months,
        hasReceivedSalaryDangeroustask7days: _hasReceivedSalaryDangeroustask7days,
        taskLocationDangeroustask7days: _taskLocationDangeroustask7days,
        otherLocationDangeroustask7days: _otherLocationDangeroustask7daysController.text,
        longestSchoolDayTimeDangeroustask7days: _longestSchoolDayTimeDangeroustask7days,
        longestNonSchoolDayTimeDangeroustask7days: _longestNonSchoolDayTimeDangeroustask7days,
        schoolDayHoursDangeroustask7days: _schoolDayHoursDangeroustask7daysController.text,
        nonSchoolDayHoursDangeroustask7days: _nonSchoolDayHoursDangeroustask7daysController.text,
        wasSupervisedByAdultDangeroustask7days: _wasSupervisedByAdultDangeroustask7days,
        hasReceivedSalaryDangeroustask12months: _hasReceivedSalaryDangeroustask12months,
        taskLocationDangeroustask12months: _taskLocationDangeroustask12months,
        otherLocationDangeroustask12months: _otherLocationDangeroustask12monthsController.text,
        longestSchoolDayTimeDangeroustask12months: _longestSchoolDayTimeDangeroustask12months,
        longestNonSchoolDayTimeDangeroustask12months: _longestNonSchoolDayTimeDangeroustask12months,
        schoolDayHoursDangeroustask12months: _schoolDayHoursDangeroustask12monthsController.text,
        nonSchoolDayHoursDangeroustask12months: _nonSchoolDayHoursDangeroustask12monthsController.text,
        wasSupervisedByAdultDangeroustask12months: _wasSupervisedByAdultDangeroustask12months,
        dangerousTasks12Months: _dangerousTasks12Months.toList(),
        appliedAgrochemicals: _appliedAgrochemicals,
        onFarmDuringApplication: _onFarmDuringApplication,
        sufferedInjury: _sufferedInjury,
        howWounded: _howWoundedController.text,
        whenWounded: _whenWoundedController.text,
        oftenFeelPains: _oftenFeelPains,
        helpReceived: _helpReceived.toList(),
        otherHelp: _otherHelpController.text,
        parentConsentPhoto: _parentConsentPhoto,
        noConsentReason: _noConsentReasonController.text,
        childPhotoPath: _childPhoto?.path,
      );

      // Save to database
      final result = await ChildRepositoryImpl().insertChild(childModel);

      if (result > 0) {
        debugPrint('Child saved successfully!::::::::::::::::::::::::$result');
        _savedChildren.add(childModel);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Child $_currentChildNumber saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to save child data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving child: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ==================== FORM SUBMISSION ====================
  Future<void> _handleSubmit() async {
    // Save current child
    await _saveCurrentChild();

    // Check if this is the last child
    if (_currentChildNumber >= widget.totalChildren) {
      // Navigate to next screen
      _navigateToNextScreen();
    } else {
      // Reset form for next child
      _resetForm();

      // Show message for next child
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ready to add child ${_currentChildNumber} of ${widget.totalChildren}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToNextScreen() {
    // Navigate to the next screen with all saved children
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RemediationPage(
          coverPageId: widget.coverPageId,
        ),
      ),
    );
  }

  // ==================== UI BUILDERS ====================
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.blue[800],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioGroup<T>({
    required String question,
    required T? groupValue,
    required List<Map<String, dynamic>> options,
    required ValueChanged<T?> onChanged,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 8),
        ...options.map((option) {
          return CustomRadioButton<T>(
            value: option['value'] as T,
            groupValue: groupValue,
            onChanged: onChanged,
            title: option['title'] as String,
            subtitle: option['subtitle'] as String?,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCheckboxGroup({
    required String question,
    required Map<String, bool> values,
    required Function(String, bool?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...values.entries.map((entry) => CustomCheckbox(
          value: entry.value,
          onChanged: (selected) => onChanged(entry.key, selected),
          title: entry.key,
        )),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ==================== CAMERA FUNCTIONALITY ====================
  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (photo != null && mounted) {
      setState(() {
        _childPhoto = File(photo.path);
      });
    }
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Child Photo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (_childPhoto != null)
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_childPhoto!, fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _takePhoto,
          icon: const Icon(Icons.camera_alt),
          label: Text(_childPhoto == null ? 'Take Photo' : 'Retake Photo'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SECTION BUILDERS ====================

  Widget _buildBasicInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('BASIC INFORMATION'),

        // Farmer's Children Section
        _buildRadioGroup<bool>(
          question: 'Is the child among the list of children declared in the cover to be the farmer\'s children?',
          groupValue: _isFarmerChild,
          onChanged: (value) {
            setState(() {
              _isFarmerChild = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 16),

        // Child Number Input
        // _buildTextField(
        //   label: 'Enter the number attached to the child name in the cover so we can identify the child in question:',
        //   controller: _childNumberController,
        //   keyboardType: TextInputType.number,
        //   hintText: 'Enter child number',
        // ),
        // const SizedBox(height: 16),

        // Survey Availability
        _buildRadioGroup<bool>(
          question: 'Can the child be surveyed now?',
          groupValue: _canBeSurveyedNow,
          onChanged: (value) {
            setState(() {
              _canBeSurveyedNow = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),

        // Show reasons if survey is not possible
        if (_canBeSurveyedNow == false) ...[
          const SizedBox(height: 16),
          _buildCheckboxGroup(
            question: 'If not, what are the reasons?',
            values: {
              'The child is at school': _surveyNotPossibleReasons.contains('the_child_is_at_school'),
              'The child has gone to work on the cocoa farm': _surveyNotPossibleReasons.contains('the_child_has_gone_to_work_on_the_cocoa_farm'),
              'Child is busy doing housework': _surveyNotPossibleReasons.contains('child_is_busy_doing_housework'),
              'Child works outside the household': _surveyNotPossibleReasons.contains('child_works_outside_the_household'),
              'The child is too young': _surveyNotPossibleReasons.contains('the_child_is_too_young'),
              'The child is sick': _surveyNotPossibleReasons.contains('the_child_is_sick'),
              'The child has travelled': _surveyNotPossibleReasons.contains('the_child_has_travelled'),
              'The child has gone out to play': _surveyNotPossibleReasons.contains('the_child_has_gone_out_to_play'),
              'The child is sleeping': _surveyNotPossibleReasons.contains('the_child_is_sleeping'),
              'Other reasons': _surveyNotPossibleReasons.contains('other_reasons'),
            },
            onChanged: (String reason, bool? selected) {
              setState(() {
                final key = reason.toLowerCase().replaceAll(' ', '_');
                if (selected == true) {
                  _surveyNotPossibleReasons.add(key);
                } else {
                  _surveyNotPossibleReasons.remove(key);
                }
              });
            },
          ),

          // Show other reason text field if 'Other reasons' is selected
          if (_surveyNotPossibleReasons.contains('other_reasons')) ...[
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Please specify other reasons',
              controller: _otherSurveyReasonController,
              hintText: 'Enter other reasons for not being able to survey',
            ),
          ],
        ],
        const SizedBox(height: 16),

        // Child's basic information - Only show if not a farmer's child
        if (_isFarmerChild != true) ...[
          _buildTextField(
            label: 'Child\'s First Name:',
            controller: _nameController,
            hintText: 'Enter child\'s first name',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Child\'s Surname:',
            controller: _surnameController,
            hintText: 'Enter child\'s surname',
          ),
          const SizedBox(height: 16),
        ],

        // Child's Gender
        _buildRadioGroup<String>(
          question: 'Gender of the child',
          groupValue: _gender,
          onChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
          options: [
            {'value': 'Male', 'title': 'Male'},
            {'value': 'Female', 'title': 'Female'},
          ],
        ),
        const SizedBox(height: 16),

        // Year of Birth
        _buildTextField(
          label: 'Year of Birth of the child',
          controller: _birthYearController,
          readOnly: true,
          onTap: () => _selectBirthYear(context),
          hintText: 'Select year of birth',
        ),
        const SizedBox(height: 16),

        // Birth certificate
        _buildRadioGroup<bool>(
          question: 'Does the child have a birth certificate?',
          groupValue: _hasBirthCertificate,
          onChanged: (value) {
            setState(() {
              _hasBirthCertificate = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),

        // Show reason field if no birth certificate
        if (_hasBirthCertificate == false) ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'If no, please specify why',
            controller: _noBirthCertificateReasonController,
            hintText: 'Enter reason for not having a birth certificate',
          ),
        ],
        const SizedBox(height: 16),

        // Child's birth location
        _buildRadioGroup<String>(
          question: 'Is the child born in this community?',
          groupValue: _bornInCommunity,
          onChanged: (value) {
            setState(() {
              _bornInCommunity = value;
            });
          },
          options: [
            {'value': 'yes', 'title': 'Yes'},
            {'value': 'no', 'title': 'No'},
          ],
        ),

        // Show country dropdown if not born in community
        if (_bornInCommunity == 'no') ...[
          const SizedBox(height: 16),
          _buildDropdown<String>(
            label: 'In which country is the child born?',
            value: _birthCountry,
            items: _countries.map((country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _birthCountry = value;
              });
            },
            hintText: 'Select country',
          ),
        ],
        const SizedBox(height: 16),

        // Child's relationship to head of household
        _buildRadioGroup<String>(
          question: 'Relationship of the child to the head of the household',
          groupValue: _relationshipToHead,
          onChanged: (value) {
            setState(() {
              _relationshipToHead = value;
            });
          },
          options: [
            {'value': 'son_daughter', 'title': 'Son/Daughter'},
            {'value': 'brother_sister', 'title': 'Brother/Sister'},
            {'value': 'in_law', 'title': 'Son-in-law/Daughter-in-law'},
            {'value': 'grandchild', 'title': 'Grandson/Granddaughter'},
            {'value': 'niece_nephew', 'title': 'Niece/Nephew'},
            {'value': 'cousin', 'title': 'Cousin'},
            {'value': 'worker_child', 'title': 'Child of the worker'},
            {
              'value': 'owner_child',
              'title': 'Child of the farm owner (only if the respondent is the caretaker)'
            },
            {'value': 'other', 'title': 'Other (please specify)'},
          ],
        ),

        // Show text field if "Other" is selected
        if (_relationshipToHead == 'other') ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Please specify the relationship',
            controller: _otherRelationshipController,
            hintText: 'Enter relationship to head of household',
          ),
        ],
      ],
    );
  }

  Widget _buildFamilyInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('FAMILY INFORMATION'),

        // Who decided the child should come into the household?
        _buildRadioGroup<String>(
          question: 'Who decided that the child should come into the household?',
          groupValue: _whoDecidedChildCame,
          onChanged: (value) {
            setState(() {
              _whoDecidedChildCame = value;
            });
          },
          options: [
            {'value': 'myself', 'title': 'Myself'},
            {'value': 'father_mother', 'title': 'Father/Mother'},
            {'value': 'grandparents', 'title': 'Grandparents'},
            {'value': 'other_family', 'title': 'Other family members'},
            {'value': 'recruiter_agency', 'title': 'An external recruiter or agency'},
            {'value': 'other_person', 'title': 'Other person (specify)'},
          ],
        ),

        // Show text field if "Other person" is selected
        if (_whoDecidedChildCame == 'other_person') ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Please specify who decided',
            controller: _otherWhoDecidedController,
            hintText: 'Enter who decided the child should come into the household',
          ),
        ],
        const SizedBox(height: 16),

        // Ask if the child agreed with the decision if someone else decided
        if (_whoDecidedChildCame != null && _whoDecidedChildCame != 'myself') ...[
          _buildRadioGroup<bool>(
            question: 'Did the child agree with this decision?',
            groupValue: _childAgreedWithDecision,
            onChanged: (value) {
              setState(() {
                _childAgreedWithDecision = value;
              });
            },
            options: [
              {'value': true, 'title': 'Yes'},
              {'value': false, 'title': 'No'},
              {'value': null, 'title': 'Not sure'},
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Has the child seen/spoken with parents in past year?
        if (_whoDecidedChildCame != null && _whoDecidedChildCame != 'myself') ...[
          _buildRadioGroup<bool>(
            question: 'Has the child seen and/or spoken with his/her parents in the past year?',
            groupValue: _hasSpokenWithParents,
            onChanged: (value) {
              setState(() {
                _hasSpokenWithParents = value;
              });
            },
            options: [
              {'value': true, 'title': 'Yes'},
              {'value': false, 'title': 'No'},
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Last time spoke with parents
        _buildRadioGroup<String>(
          question: 'When was the last time the child saw and/or talked with mom and/or dad?',
          groupValue: _lastTimeSpokeWithParents,
          onChanged: (value) {
            setState(() {
              _lastTimeSpokeWithParents = value;
            });
          },
          options: [
            {'value': 'Max 1 week', 'title': 'Max 1 week'},
            {'value': 'Max 1 month', 'title': 'Max 1 month'},
            {'value': 'Max 1 year', 'title': 'Max 1 year'},
            {'value': 'More than 1 year', 'title': 'More than 1 year'},
            {'value': 'Never', 'title': 'Never'},
          ],
        ),
        const SizedBox(height: 16),

        // How long has the child been living in the household?
        _buildRadioGroup<String>(
          question: 'For how long has the child been living in the household?',
          groupValue: _timeInHousehold,
          onChanged: (value) {
            setState(() {
              _timeInHousehold = value;
            });
          },
          options: [
            {'value': 'Born in the household', 'title': 'Born in the household'},
            {'value': 'Less than 1 year', 'title': 'Less than 1 year'},
            {'value': '1-2 years', 'title': '1-2 years'},
            {'value': '2-4 years old', 'title': '2-4 years old'},
            {'value': '4-6 years old', 'title': '4-6 years old'},
            {'value': '6-8 years old', 'title': '6-8 years old'},
            {'value': 'More than 8 years', 'title': 'More than 8 years'},
            {'value': 'Don\'t know', 'title': 'Don\'t know'},
          ],
        ),
        const SizedBox(height: 16),

        // Who accompanied the child?
        if (_whoDecidedChildCame != null && _whoDecidedChildCame != 'myself') ...[
          _buildRadioGroup<String>(
            question: 'Who accompanied the child to come here?',
            groupValue: _whoAccompaniedChild,
            onChanged: (value) {
              setState(() {
                _whoAccompaniedChild = value;
              });
            },
            options: [
              {'value': 'came_alone', 'title': 'Came alone'},
              {'value': 'father_mother', 'title': 'Father / Mother'},
              {'value': 'grandparents', 'title': 'Grandparents'},
              {'value': 'other_family_member', 'title': 'Other family member'},
              {'value': 'with_a_recruit', 'title': 'With a recruit'},
              {'value': 'other', 'title': 'Other'},
            ],
          ),
          if (_whoAccompaniedChild == 'other') ...[
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Please specify who accompanied the child',
              controller: _otherAccompaniedController,
            ),
          ],
          const SizedBox(height: 16),
        ],

        // Father's residence
        _buildRadioGroup<String>(
          question: 'Where does the child\'s father live?',
          groupValue: _fatherResidence,
          onChanged: (value) {
            setState(() {
              _fatherResidence = value;
            });
          },
          options: [
            {'value': 'In the same household', 'title': 'In the same household'},
            {'value': 'In another household in the same village', 'title': 'In another household in the same village'},
            {'value': 'In another household in the same region', 'title': 'In another household in the same region'},
            {'value': 'In another household in another region', 'title': 'In another household in another region'},
            {'value': 'Abroad', 'title': 'Abroad'},
            {'value': 'Parents deceased', 'title': 'Parents deceased'},
            {'value': 'Don\'t know/Don\'t want to answer', 'title': 'Don\'t know/Don\'t want to answer'},
          ],
        ),

        // Show country selection if father is abroad
        if (_fatherResidence == 'Abroad') ...[
          const SizedBox(height: 16),
          _buildDropdown<String>(
            label: 'Father\'s country of residence',
            value: _fatherCountry,
            items: _fatherCountries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _fatherCountry = value;
              });
            },
            hintText: 'Select country',
          ),
          if (_fatherCountry == 'Others to be specified') ...[
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Please specify country',
              controller: _otherFatherCountryController,
            ),
          ],
          const SizedBox(height: 16),
        ],

        // Mother's residence
        _buildRadioGroup<String>(
          question: 'Where does the child\'s mother live?',
          groupValue: _motherResidence,
          onChanged: (value) {
            setState(() {
              _motherResidence = value;
            });
          },
          options: [
            {'value': 'In the same household', 'title': 'In the same household'},
            {'value': 'In another household in the same village', 'title': 'In another household in the same village'},
            {'value': 'In another household in the same region', 'title': 'In another household in the same region'},
            {'value': 'In another household in another region', 'title': 'In another household in another region'},
            {'value': 'Abroad', 'title': 'Abroad'},
            {'value': 'Parents deceased', 'title': 'Parents deceased'},
            {'value': 'Don\'t know/Don\'t want to answer', 'title': 'Don\'t know/Don\'t want to answer'},
          ],
        ),

        // Show country selection if mother is abroad
        if (_motherResidence == 'Abroad') ...[
          const SizedBox(height: 16),
          _buildDropdown<String>(
            label: 'Mother\'s country of residence',
            value: _motherCountry,
            items: _fatherCountries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _motherCountry = value;
              });
            },
            hintText: 'Select country',
          ),
          if (_motherCountry == 'Others to be specified') ...[
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Please specify country',
              controller: _otherMotherCountryController,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildEducationInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('EDUCATION INFORMATION'),

        // School enrollment
        _buildRadioGroup<bool>(
          question: 'Is the child currently enrolled in school?',
          groupValue: _isCurrentlyEnrolled,
          onChanged: (value) {
            setState(() {
              _isCurrentlyEnrolled = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),

        // Currently enrolled section
        if (_isCurrentlyEnrolled == true) ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'What is the name of the school?',
            controller: _schoolNameController,
            hintText: 'Enter school name',
          ),
        ],

        if (_isCurrentlyEnrolled == true && _schoolNameController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRadioGroup<String>(
            question: 'Is the school a public or private school?',
            groupValue: _schoolType,
            onChanged: (value) {
              setState(() {
                _schoolType = value;
              });
            },
            options: [
              {'value': 'Public', 'title': 'Public'},
              {'value': 'Private', 'title': 'Private'},
            ],
          ),
        ],

        if (_isCurrentlyEnrolled == true && _schoolNameController.text.trim().isNotEmpty && _schoolType != null) ...[
          const SizedBox(height: 16),
          _buildDropdown<String>(
            label: 'What grade is the child enrolled in?',
            value: _gradeLevel,
            items: _gradeLevels.map((String grade) {
              return DropdownMenuItem<String>(
                value: grade,
                child: Text(grade),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _gradeLevel = value;
              });
            },
            hintText: 'Select grade level',
          ),
        ],

        if (_isCurrentlyEnrolled == true && _schoolNameController.text.trim().isNotEmpty && _schoolType != null && _gradeLevel != null) ...[
          const SizedBox(height: 16),
          _buildRadioGroup<String>(
            question: 'How many times does the child go to school in a week?',
            groupValue: _schoolAttendanceFrequency,
            onChanged: (value) {
              setState(() {
                _schoolAttendanceFrequency = value;
              });
            },
            options: [
              {'value': 'Once', 'title': 'Once'},
              {'value': 'Twice', 'title': 'Twice'},
              {'value': 'Thrice', 'title': 'Thrice'},
              {'value': 'Four times', 'title': 'Four times'},
              {'value': 'Five times', 'title': 'Five times'},
            ],
          ),
        ],

        if (_schoolAttendanceFrequency != null) ...[
          const SizedBox(height: 16),
          Text(
            'Select the basic school needs that are available to the child:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              CustomCheckbox(
                value: _availableSchoolSupplies.contains('Books'),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _availableSchoolSupplies.add('Books');
                    } else {
                      _availableSchoolSupplies.remove('Books');
                    }
                  });
                },
                title: 'Books',
              ),
              CustomCheckbox(
                value: _availableSchoolSupplies.contains('School bag'),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _availableSchoolSupplies.add('School bag');
                    } else {
                      _availableSchoolSupplies.remove('School bag');
                    }
                  });
                },
                title: 'School bag',
              ),
              CustomCheckbox(
                value: _availableSchoolSupplies.contains('Pen / Pencils'),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _availableSchoolSupplies.add('Pen / Pencils');
                    } else {
                      _availableSchoolSupplies.remove('Pen / Pencils');
                    }
                  });
                },
                title: 'Pen / Pencils',
              ),
              CustomCheckbox(
                value: _availableSchoolSupplies.contains('School Uniforms'),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _availableSchoolSupplies.add('School Uniforms');
                    } else {
                      _availableSchoolSupplies.remove('School Uniforms');
                    }
                  });
                },
                title: 'School Uniforms',
              ),
              CustomCheckbox(
                value: _availableSchoolSupplies.contains('Shoes and Socks'),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _availableSchoolSupplies.add('Shoes and Socks');
                    } else {
                      _availableSchoolSupplies.remove('Shoes and Socks');
                    }
                  });
                },
                title: 'Shoes and Socks',
              ),
              CustomCheckbox(
                value: _availableSchoolSupplies.contains('None of the above'),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _availableSchoolSupplies.clear();
                      _availableSchoolSupplies.add('None of the above');
                    } else {
                      _availableSchoolSupplies.remove('None of the above');
                    }
                  });
                },
                title: 'None of the above',
              ),
            ],
          ),
        ],

        // Not currently enrolled section
        if (_isCurrentlyEnrolled == false) ...[
          const SizedBox(height: 16),
          _buildRadioGroup<bool>(
            question: 'Has the child ever been to school?',
            groupValue: _hasEverBeenToSchool,
            onChanged: (value) {
              setState(() {
                _hasEverBeenToSchool = value;
              });
            },
            options: [
              {
                'value': true,
                'title': 'Yes, they went to school but stopped',
              },
              {
                'value': false,
                'title': 'No, they have never been to school',
              },
            ],
          ),

          // Additional sections for children who were enrolled but stopped
          if (_hasEverBeenToSchool == true) ...[
            const SizedBox(height: 16),
            _buildTextField(
              label: 'When did the child leave school?',
              controller: _leftSchoolYearController,
              keyboardType: TextInputType.number,
              hintText: 'Enter year (e.g., 2023)',
            ),
          ],
        ],

        // Education level question
        if (_hasEverBeenToSchool == true || _isCurrentlyEnrolled == false) ...[
          const SizedBox(height: 16),
          _buildRadioGroup<String>(
            question: 'What is the education level of the child?',
            groupValue: _educationLevel,
            onChanged: (value) {
              setState(() {
                _educationLevel = value;
              });
            },
            options: [
              {'value': 'pre_school', 'title': 'Pre-school (Kindergarten)'},
              {'value': 'primary', 'title': 'Primary'},
              {'value': 'jss', 'title': 'JSS/Middle school'},
              {
                'value': 'sss',
                'title': 'SSS/\'O\'-level/\'A\'-level (including vocational & technical training)'
              },
              {'value': 'university', 'title': 'University or higher'},
              {'value': 'not_applicable', 'title': 'Not applicable'},
            ],
          ),
        ],

        // Reason for leaving school
        if (_hasEverBeenToSchool == true) ...[
          const SizedBox(height: 16),
          _buildRadioGroup<String>(
            question: 'What is the main reason for the child leaving school?',
            groupValue: _reasonForLeavingSchool,
            onChanged: (value) {
              setState(() {
                _reasonForLeavingSchool = value;
                if (value != 'other') {
                  _otherReasonForLeavingSchoolController.clear();
                }
              });
            },
            options: [
              {'value': 'too_far', 'title': 'The school is too far away'},
              {'value': 'fees_high', 'title': 'Tuition fees for private school too high'},
              {'value': 'poor_performance', 'title': 'Poor academic performance'},
              {'value': 'insecurity', 'title': 'Insecurity in the area'},
              {'value': 'learn_trade', 'title': 'To learn a trade'},
              {'value': 'pregnancy', 'title': 'Early pregnancy'},
              {'value': 'child_refused', 'title': 'The child did not want to go to school anymore'},
              {'value': 'cant_afford_materials', 'title': 'Parents can\'t afford Teaching and Learning Materials'},
              {'value': 'other', 'title': 'Other'},
              {'value': 'dont_know', 'title': 'Does not know'},
            ],
          ),
          if (_reasonForLeavingSchool == 'other') ...[
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Please specify other reason',
              controller: _otherReasonForLeavingSchoolController,
            ),
          ],
        ],

        // Reason for never attending school
        if (_hasEverBeenToSchool == false) ...[
          const SizedBox(height: 16),
          _buildRadioGroup<String>(
            question: 'Why has the child never been to school before?',
            groupValue: _reasonNeverAttendedSchool,
            onChanged: (value) {
              setState(() {
                _reasonNeverAttendedSchool = value;
                if (value != 'other') {
                  _otherReasonNeverAttendedController.clear();
                }
              });
            },
            options: [
              {'value': 'too_far', 'title': 'The school is too far away'},
              {'value': 'fees_high', 'title': 'Tuition fees too high'},
              {'value': 'too_young', 'title': 'Too young to be in school'},
              {'value': 'insecurity', 'title': 'Insecurity in the region'},
              {'value': 'learn_trade', 'title': 'To learn a trade (apprenticeship)'},
              {'value': 'child_refused', 'title': 'The child doesn\'t want to go to school'},
              {'value': 'cant_afford', 'title': 'Parents can\'t afford TLMs and/or enrollment fees'},
              {'value': 'other', 'title': 'Other'},
            ],
          ),
          if (_reasonNeverAttendedSchool == 'other') ...[
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Please specify other reason',
              controller: _otherReasonNeverAttendedController,
            ),
          ],
        ],

        // School attendance in past 7 days - Only show if currently enrolled
        if (_isCurrentlyEnrolled == true) ...[
          const SizedBox(height: 16),
          _buildRadioGroup<bool>(
            question: 'Has the child been to school in the past 7 days?',
            groupValue: _attendedSchoolLast7Days,
            onChanged: (value) {
              setState(() {
                _attendedSchoolLast7Days = value;
              });
            },
            options: [
              {'value': true, 'title': 'Yes'},
              {'value': false, 'title': 'No'},
            ],
          ),
        ],

        // Show reason for not attending school if not attended in past 7 days
        if (_isCurrentlyEnrolled == true && _attendedSchoolLast7Days == false) ...[
          const SizedBox(height: 16),
          _buildRadioGroup<String>(
            question: 'Why has the child not been to school?',
            groupValue: _reasonNotAttendedSchool,
            onChanged: (value) {
              setState(() {
                _reasonNotAttendedSchool = value;
                if (value != 'other') {
                  _otherReasonNotAttendedController.clear();
                }
              });
            },
            options: [
              {'value': 'holidays', 'title': 'It was the holidays'},
              {'value': 'sick', 'title': 'He/she was sick'},
              {'value': 'working', 'title': 'He/she was working'},
              {'value': 'traveling', 'title': 'He/she was traveling'},
              {'value': 'other', 'title': 'Other'},
            ],
          ),
          if (_reasonNotAttendedSchool == 'other') ...[
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Please specify other reason',
              controller: _otherReasonNotAttendedController,
            ),
          ],
        ],

        // Question about missing school days
        const SizedBox(height: 16),
        _buildRadioGroup<bool>(
          question: 'Has the child missed any school days in the past 7 days?',
          groupValue: _missedSchoolDays,
          onChanged: (value) {
            setState(() {
              _missedSchoolDays = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),

        if (_missedSchoolDays == true) ...[
          const SizedBox(height: 16),
          _buildCheckboxGroup(
            question: 'Why has the child miss school?',
            values: _absenceReasons,
            onChanged: (String reason, bool? selected) {
              setState(() {
                _absenceReasons[reason] = selected ?? false;
              });
            },
          ),
          if (_absenceReasons['Other'] == true) ...[
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Please specify other reason',
              controller: _otherAbsenceReasonController,
            ),
          ],
        ],

        // Writing assessment
        const SizedBox(height: 24),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Writing Assessment',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please ask the child to write any sentence on a piece of paper:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRadioGroup<String>(
                  question: 'Can the child write sentences?',
                  groupValue: _canWriteSentences,
                  onChanged: (value) {
                    setState(() {
                      _canWriteSentences = value;
                    });
                  },
                  options: [
                    {'value': 'writes_both', 'title': 'Yes, he/she can write both sentences'},
                    {'value': 'writes_simple', 'title': 'Only the simple text'},
                    {'value': 'cannot_write', 'title': 'No'},
                    {'value': 'refused', 'title': 'The child refuses to try'},
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('WORK INFORMATION'),

        // Work-related questions
        _buildRadioGroup<bool>(
          question: 'In the past 7 days, has the child worked in the house?',
          groupValue: _workedInHouse,
          onChanged: (value) {
            setState(() {
              _workedInHouse = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 16),

        _buildRadioGroup<bool>(
          question: 'In the past 7 days, has the child been working on the cocoa farm?',
          groupValue: _workedOnCocoaFarm,
          onChanged: (value) {
            setState(() {
              _workedOnCocoaFarm = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),

        // Tasks performed on cocoa farm
        if (_workedOnCocoaFarm == true) ...[
          const SizedBox(height: 16),
          Text(
            'Which of these tasks has the child performed in the last 7 Days?',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskCheckbox('Collect and gather fruits, pods, seeds after harvesting'),
              _buildTaskCheckbox('Extracting cocoa beans after shelling by an adult'),
              _buildTaskCheckbox('Wash beans, fruits, vegetables or tubers'),
              _buildTaskCheckbox('Prepare the germinators and pour the seeds into the germinators'),
              _buildTaskCheckbox('Collecting firewood'),
              _buildTaskCheckbox('Help measure distances between plants during transplanting'),
              _buildTaskCheckbox('Sort and spread the beans, cereals and other vegetables for drying'),
              _buildTaskCheckbox('Putting cuttings on the mounds'),
              _buildTaskCheckbox('Holding bags or filling them with small containers for packaging'),
              _buildTaskCheckbox('Covering stored agricultural products with tarps'),
              _buildTaskCheckbox('To shell or dehusk seeds, plants and fruits by hand'),
              _buildTaskCheckbox('Sowing seeds'),
              _buildTaskCheckbox('Transplant or put in the ground the cuttings or plants'),
              _buildTaskCheckbox('Harvesting legumes, fruits and other leafy products (corn, beans, soybeans, various vegetables)'),
              _buildTaskCheckbox('None'),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Work frequency
        const SizedBox(height: 16),
        _buildRadioGroup<String>(
          question: 'How often has the child worked in the past 7 days?',
          groupValue: _workFrequency,
          onChanged: (value) {
            setState(() {
              _workFrequency = value;
            });
          },
          options: [
            {'value': 'Every day', 'title': 'Every day'},
            {'value': '4-5 days', 'title': '4-5 days'},
            {'value': '2-3 days', 'title': '2-3 days'},
            {'value': 'Once', 'title': 'Once'},
          ],
        ),

        // Observer question
        const SizedBox(height: 16),
        _buildRadioGroup<bool>(
          question: 'Did the enumerator observe the child working in a real situation?',
          groupValue: _observedWorking,
          onChanged: (value) {
            setState(() {
              _observedWorking = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),

        // For whom does the child work question
        if (_workedOnCocoaFarm == true) ...[
          const SizedBox(height: 16),
          _buildRadioGroup<String>(
            question: 'For whom does the child work on cocoa farming?',
            groupValue: _workForWhom,
            onChanged: (value) {
              setState(() {
                _workForWhom = value;
              });
            },
            options: [
              {'value': 'parents', 'title': 'For his/her parents'},
              {'value': 'family_not_parents', 'title': 'For family, not parents'},
              {'value': 'family_friends', 'title': 'For family friends'},
              {'value': 'other', 'title': 'Other'},
            ],
          ),
          if (_workForWhom == 'other') ...[
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Please specify',
              controller: _workForWhomOtherController,
            ),
          ],
        ],

        // Why does the child work?
        if (_workedOnCocoaFarm == true) ...[
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why does the child work on cocoa farming?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  CustomCheckbox(
                    value: _whyWorkReasons.contains('own_money'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _whyWorkReasons.add('own_money');
                        } else {
                          _whyWorkReasons.remove('own_money');
                        }
                      });
                    },
                    title: 'To have his/her own money',
                  ),
                  CustomCheckbox(
                    value: _whyWorkReasons.contains('increase_income'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _whyWorkReasons.add('increase_income');
                        } else {
                          _whyWorkReasons.remove('increase_income');
                        }
                      });
                    },
                    title: 'To increase household income',
                  ),
                  CustomCheckbox(
                    value: _whyWorkReasons.contains('cannot_afford_adult'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _whyWorkReasons.add('cannot_afford_adult');
                        } else {
                          _whyWorkReasons.remove('cannot_afford_adult');
                        }
                      });
                    },
                    title: 'Household cannot afford adult\'s work',
                  ),
                  CustomCheckbox(
                    value: _whyWorkReasons.contains('no_adult_labor'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _whyWorkReasons.add('no_adult_labor');
                        } else {
                          _whyWorkReasons.remove('no_adult_labor');
                        }
                      });
                    },
                    title: 'Household cannot find adult labor',
                  ),
                  CustomCheckbox(
                    value: _whyWorkReasons.contains('learn_farming'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _whyWorkReasons.add('learn_farming');
                        } else {
                          _whyWorkReasons.remove('learn_farming');
                        }
                      });
                    },
                    title: 'To learn cocoa farming',
                  ),
                  CustomCheckbox(
                    value: _whyWorkReasons.contains('other'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _whyWorkReasons.add('other');
                        } else {
                          _whyWorkReasons.remove('other');
                        }
                      });
                    },
                    title: 'Other (specify)',
                  ),
                  if (_whyWorkReasons.contains('other')) ...[
                    const SizedBox(height: 8),
                    _buildTextField(
                      label: 'Please specify',
                      controller: _whyWorkOtherController,
                    ),
                  ],
                  CustomCheckbox(
                    value: _whyWorkReasons.contains('dont_know'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _whyWorkReasons.add('dont_know');
                        } else {
                          _whyWorkReasons.remove('dont_know');
                        }
                      });
                    },
                    title: 'Does not know',
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTaskCheckbox(String task) {
    return CustomCheckbox(
      value: _cocoaFarmTasks.contains(task),
      onChanged: (selected) {
        setState(() {
          if (selected == true) {
            _cocoaFarmTasks.add(task);
          } else {
            _cocoaFarmTasks.remove(task);
          }
        });
      },
      title: task,
    );
  }

  Widget _buildLightTasks7DaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('LIGHT TASKS (7 DAYS)'),

        // Light work explanation
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Light work refers to tasks that do not interfere with a child\'s education, health, or development.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // Remuneration question for light tasks
        _buildRadioGroup<bool>(
          question: 'Did the child receive remuneration for the activity?',
          groupValue: _receivedRemunerationLighttasks7days,
          onChanged: (value) {
            setState(() {
              _receivedRemunerationLighttasks7days = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 16),

        // Time spent on light duty - School day
        _buildRadioGroup<String>(
          question: 'What was the longest time spent on light duty during a SCHOOL DAY in the last 7 days?',
          groupValue: _longestLightDutyTimeLighttasks7days,
          onChanged: (value) {
            setState(() {
              _longestLightDutyTimeLighttasks7days = value;
            });
          },
          options: [
            {'value': 'Less than 1 hour', 'title': 'Less than 1 hour'},
            {'value': '1-2 hours', 'title': '1-2 hours'},
            {'value': '2-3 hours', 'title': '2-3 hours'},
            {'value': '3-4 hours', 'title': '3-4 hours'},
            {'value': '4-6 hours', 'title': '4-6 hours'},
            {'value': '6-8 hours', 'title': '6-8 hours'},
            {'value': 'More than 8 hours', 'title': 'More than 8 hours'},
            {'value': 'Does not apply', 'title': 'Does not apply'},
          ],
        ),
        const SizedBox(height: 16),

        // Time spent on light duty - Non-school day
        _buildRadioGroup<String>(
          question: 'What was the longest amount of time spent on light duty on a NON-SCHOOL DAY in the last 7 days?',
          groupValue: _longestNonSchoolDayTimeLighttasks7days,
          onChanged: (value) {
            setState(() {
              _longestNonSchoolDayTimeLighttasks7days = value;
            });
          },
          options: [
            {'value': '1-2 hours', 'title': '1-2 hours'},
            {'value': '2-3 hours', 'title': '2-3 hours'},
            {'value': '3-4 hours', 'title': '3-4 hours'},
            {'value': '4-6 hours', 'title': '4-6 hours'},
            {'value': '6-8 hours', 'title': '6-8 hours'},
            {'value': 'More than 8 hours', 'title': 'More than 8 hours'},
            {'value': 'Does not apply', 'title': 'Does not apply'},
          ],
        ),
        const SizedBox(height: 16),

        // Adult supervision question for light tasks
        _buildRadioGroup<bool>(
          question: 'Was the child under supervision of an adult when performing light tasks?',
          groupValue: _wasSupervisedByAdultLighttasks7days,
          onChanged: (value) {
            setState(() {
              _wasSupervisedByAdultLighttasks7days = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 16),

        // Task location for light tasks
        _buildRadioGroup<String>(
          question: 'Where were the light tasks done?',
          groupValue: _taskLocationLighttasks7days,
          onChanged: (value) {
            setState(() {
              _taskLocationLighttasks7days = value;
            });
          },
          options: [
            {'value': 'On family farm', 'title': 'On family farm'},
            {'value': 'As a hired labourer on another farm', 'title': 'As a hired labourer on another farm'},
            {'value': 'School farms/compounds', 'title': 'School farms/compounds'},
            {'value': 'Teachers farms (during communal labour)', 'title': 'Teachers farms (during communal labour)'},
            {'value': 'Church farms or cleaning activities', 'title': 'Church farms or cleaning activities'},
            {'value': 'Helping a community member for free', 'title': 'Helping a community member for free'},
            {'value': 'Other', 'title': 'Other'},
          ],
        ),

        if (_taskLocationLighttasks7days == 'Other') ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Please specify',
            controller: _otherLocationLighttasks7daysController,
          ),
        ],
        const SizedBox(height: 16),

        // Total hours on school days for light tasks
        _buildTextField(
          label: 'How many hours in total did the child spend on light tasks during SCHOOL DAYS in the past 7 days?',
          controller: _schoolDayTaskDurationLighttasks7daysController,
          keyboardType: TextInputType.number,
          hintText: 'Enter hours',
        ),
        const SizedBox(height: 16),

        _buildTextField(
          label: 'How many hours in total did the child spend on light tasks during NON-SCHOOL DAYS in the past 7 days?',
          controller: _nonSchoolDayTaskDurationLighttasks7daysController,
          keyboardType: TextInputType.number,
          hintText: 'Enter hours',
        ),
      ],
    );
  }

  Widget _buildLightTasks12MonthsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('LIGHT TASK (12 MONTHS)'),

        // Activity remuneration question for 12 months
        _buildRadioGroup<bool>(
          question: 'Did the child receive any remuneration for the activity?',
          groupValue: _receivedRemunerationLighttasks12months,
          onChanged: (value) {
            setState(() {
              _receivedRemunerationLighttasks12months = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 16),

        // School day task duration question for 12 months
        _buildRadioGroup<String>(
          question: 'What was the longest time spent on light tasks during a SCHOOL DAY in the last 12 months?',
          groupValue: _longestSchoolDayTimeLighttasks12months,
          onChanged: (value) {
            setState(() {
              _longestSchoolDayTimeLighttasks12months = value;
            });
          },
          options: [
            {'value': 'Less than 1 hour', 'title': 'Less than 1 hour'},
            {'value': '1-2 hours', 'title': '1-2 hours'},
            {'value': '2-3 hours', 'title': '2-3 hours'},
            {'value': '3-4 hours', 'title': '3-4 hours'},
            {'value': '4-6 hours', 'title': '4-6 hours'},
            {'value': '6-8 hours', 'title': '6-8 hours'},
            {'value': 'More than 8 hours', 'title': 'More than 8 hours'},
            {'value': 'Does not apply', 'title': 'Does not apply'},
          ],
        ),
        const SizedBox(height: 16),

        // Non-school day task duration question for 12 months
        _buildRadioGroup<String>(
          question: 'What was the longest time spent on light tasks on a NON-SCHOOL DAY in the last 12 months?',
          groupValue: _longestNonSchoolDayTimeLighttasks12months,
          onChanged: (value) {
            setState(() {
              _longestNonSchoolDayTimeLighttasks12months = value;
            });
          },
          options: [
            {'value': 'Less than 1 hour', 'title': 'Less than 1 hour'},
            {'value': '1-2 hours', 'title': '1-2 hours'},
            {'value': '2-3 hours', 'title': '2-3 hours'},
            {'value': '3-4 hours', 'title': '3-4 hours'},
            {'value': '4-6 hours', 'title': '4-6 hours'},
            {'value': '6-8 hours', 'title': '6-8 hours'},
            {'value': 'More than 8 hours', 'title': 'More than 8 hours'},
            {'value': 'Does not apply', 'title': 'Does not apply'},
          ],
        ),
        const SizedBox(height: 16),

        // Task location question for 12 months
        _buildRadioGroup<String>(
          question: 'Where was this task done?',
          groupValue: _taskLocationLighttasks12months,
          onChanged: (value) {
            setState(() {
              _taskLocationLighttasks12months = value;
            });
          },
          options: [
            {'value': 'On family farm', 'title': 'On family farm'},
            {'value': 'As a hired labourer on another farm', 'title': 'As a hired labourer on another farm'},
            {'value': 'School farms/compounds', 'title': 'School farms/compounds'},
            {'value': 'Teachers farms (during communal labour)', 'title': 'Teachers farms (during communal labour)'},
            {'value': 'Church farms or cleaning activities', 'title': 'Church farms or cleaning activities'},
            {'value': 'Helping a community member for free', 'title': 'Helping a community member for free'},
            {'value': 'Other', 'title': 'Other'},
          ],
        ),

        if (_taskLocationLighttasks12months == 'Other') ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Please specify where the task was done',
            controller: TextEditingController(text: _otherTaskLocationLighttasks12months),
            onTap: () {
              // Handle text input
            },
          ),
        ],
        const SizedBox(height: 16),

        // Total hours on school days question for 12 months
        _buildRadioGroup<String>(
          question: 'How many hours in total did the child spend on light tasks during SCHOOL DAYS in the past 12 months?',
          groupValue: _totalSchoolDayHoursLighttasks12months,
          onChanged: (value) {
            setState(() {
              _totalSchoolDayHoursLighttasks12months = value;
            });
          },
          options: [
            {'value': 'Less than 1 hour', 'title': 'Less than 1 hour'},
            {'value': '1-2 hours', 'title': '1-2 hours'},
            {'value': '2-4 hours', 'title': '2-4 hours'},
            {'value': '4-6 hours', 'title': '4-6 hours'},
            {'value': '6-8 hours', 'title': '6-8 hours'},
            {'value': 'More than 8 hours', 'title': 'More than 8 hours'},
            {'value': 'Not applicable', 'title': 'Not applicable'},
          ],
        ),
        const SizedBox(height: 16),

        // Total hours on non-school days question for 12 months
        _buildRadioGroup<String>(
          question: 'How many hours in total did the child spend on light tasks during NON-SCHOOL DAYS in the past 12 months?',
          groupValue: _totalNonSchoolDayHoursLighttasks12months,
          onChanged: (value) {
            setState(() {
              _totalNonSchoolDayHoursLighttasks12months = value;
            });
          },
          options: [
            {'value': 'Less than 1 hour', 'title': 'Less than 1 hour'},
            {'value': '1-2 hours', 'title': '1-2 hours'},
            {'value': '2-4 hours', 'title': '2-4 hours'},
            {'value': '4-6 hours', 'title': '4-6 hours'},
            {'value': '6-8 hours', 'title': '6-8 hours'},
            {'value': 'More than 8 hours', 'title': 'More than 8 hours'},
            {'value': 'Not applicable', 'title': 'Not applicable'},
          ],
        ),
        const SizedBox(height: 16),

        // Adult supervision question for 12 months
        _buildRadioGroup<bool>(
          question: 'Was the child under supervision of an adult when performing this task?',
          groupValue: _wasSupervisedDuringTaskLighttasks12months,
          onChanged: (value) {
            setState(() {
              _wasSupervisedDuringTaskLighttasks12months = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
      ],
    );
  }

  Widget _buildDangerousTasks7DaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('DANGEROUS TASKS (7 DAYS)'),

        // Salary question for dangerous tasks (7 days)
        _buildRadioGroup<bool>(
          question: 'Has the child received a salary for this task?',
          groupValue: _hasReceivedSalaryDangeroustask7days,
          onChanged: (value) {
            setState(() {
              _hasReceivedSalaryDangeroustask7days = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 16),

        // Task location question for dangerous tasks (7 days)
        _buildRadioGroup<String>(
          question: 'Where was this task done?',
          groupValue: _taskLocationDangeroustask7days,
          onChanged: (value) {
            setState(() {
              _taskLocationDangeroustask7days = value;
            });
          },
          options: [
            {'value': 'On family farm', 'title': 'On family farm'},
            {'value': 'As a hired labourer on another farm', 'title': 'As a hired labourer on another farm'},
            {'value': 'School farms/compounds', 'title': 'School farms/compounds'},
            {'value': 'Teachers farms (during communal labour)', 'title': 'Teachers farms (during communal labour)'},
            {'value': 'Church farms or cleaning activities', 'title': 'Church farms or cleaning activities'},
            {'value': 'Helping a community member for free', 'title': 'Helping a community member for free'},
            {'value': 'Other', 'title': 'Other'},
          ],
        ),

        if (_taskLocationDangeroustask7days == 'Other') ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Please specify',
            controller: _otherLocationDangeroustask7daysController,
          ),
        ],
        const SizedBox(height: 16),

        // Longest time spent on dangerous task during school day (7 days)
        _buildRadioGroup<String>(
          question: 'What was the longest time spent on the task during a SCHOOL DAY in the last 7 days?',
          groupValue: _longestSchoolDayTimeDangeroustask7days,
          onChanged: (value) {
            setState(() {
              _longestSchoolDayTimeDangeroustask7days = value;
            });
          },
          options: [
            {'value': 'Less than one hour', 'title': 'Less than one hour'},
            {'value': '1 hour', 'title': '1 hour'},
            {'value': '2 hours', 'title': '2 hours'},
            {'value': '3-4 hours', 'title': '3-4 hours'},
            {'value': '4-6 hours', 'title': '4-6 hours'},
            {'value': '6-8 hours', 'title': '6-8 hours'},
            {'value': 'More than 8 hours', 'title': 'More than 8 hours'},
            {'value': 'Does not apply', 'title': 'Does not apply'},
          ],
        ),
        const SizedBox(height: 16),

        // Longest time spent on dangerous task during non-school day (7 days)
        _buildRadioGroup<String>(
          question: 'What was the longest time spent on the task during a NON-SCHOOL DAY in the last 7 days?',
          groupValue: _longestNonSchoolDayTimeDangeroustask7days,
          onChanged: (value) {
            setState(() {
              _longestNonSchoolDayTimeDangeroustask7days = value;
            });
          },
          options: [
            {'value': 'Less than one hour', 'title': 'Less than one hour'},
            {'value': '1-2 hours', 'title': '1-2 hours'},
            {'value': '2-3 hours', 'title': '2-3 hours'},
            {'value': '3-4 hours', 'title': '3-4 hours'},
            {'value': '4-6 hours', 'title': '4-6 hours'},
            {'value': '6-8 hours', 'title': '6-8 hours'},
            {'value': 'More than 8 hours', 'title': 'More than 8 hours'},
            {'value': 'Does not apply', 'title': 'Does not apply'},
          ],
        ),
        const SizedBox(height: 16),

        // School day hours input for dangerous tasks (7 days)
        _buildTextField(
          label: 'How many hours has the child worked on DANGEROUS tasks during SCHOOL DAYS in the last 7 days?',
          controller: _schoolDayHoursDangeroustask7daysController,
          keyboardType: TextInputType.number,
          hintText: 'Enter number of hours',
        ),
        const SizedBox(height: 16),

        // Non-school day hours input for dangerous tasks (7 days)
        _buildTextField(
          label: 'How many hours has the child worked on DANGEROUS tasks during NON-SCHOOL DAYS in the last 7 days?',
          controller: _nonSchoolDayHoursDangeroustask7daysController,
          keyboardType: TextInputType.number,
          hintText: 'Enter number of hours',
        ),
        const SizedBox(height: 16),

        // Adult supervision question for dangerous tasks (7 days)
        _buildRadioGroup<bool>(
          question: 'Was the child under supervision of an adult when performing DANGEROUS tasks?',
          groupValue: _wasSupervisedByAdultDangeroustask7days,
          onChanged: (value) {
            setState(() {
              _wasSupervisedByAdultDangeroustask7days = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
      ],
    );
  }

  Widget _buildDangerousTasks12MonthsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('DANGEROUS TASKS (12 MONTHS)'),

        // Salary question for dangerous tasks (12 months)
        _buildRadioGroup<bool>(
          question: 'Has the child received a salary for this task?',
          groupValue: _hasReceivedSalaryDangeroustask12months,
          onChanged: (value) {
            setState(() {
              _hasReceivedSalaryDangeroustask12months = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 16),

        // Task location question for dangerous tasks (12 months)
        _buildRadioGroup<String>(
          question: 'Where was this task done?',
          groupValue: _taskLocationDangeroustask12months,
          onChanged: (value) {
            setState(() {
              _taskLocationDangeroustask12months = value;
            });
          },
          options: [
            {'value': 'On family farm', 'title': 'On family farm'},
            {'value': 'As a hired labourer on another farm', 'title': 'As a hired labourer on another farm'},
            {'value': 'School farms/compounds', 'title': 'School farms/compounds'},
            {'value': 'Teachers farms (during communal labour)', 'title': 'Teachers farms (during communal labour)'},
            {'value': 'Church farms or cleaning activities', 'title': 'Church farms or cleaning activities'},
            {'value': 'Helping a community member for free', 'title': 'Helping a community member for free'},
            {'value': 'Other', 'title': 'Other'},
          ],
        ),

        if (_taskLocationDangeroustask12months == 'Other') ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Please specify',
            controller: _otherLocationDangeroustask12monthsController,
          ),
        ],
        const SizedBox(height: 16),

        // Longest time spent on dangerous task during school day (12 months)
        _buildRadioGroup<String>(
          question: 'What was the longest time spent on the task during a SCHOOL DAY in the last 12 months?',
          groupValue: _longestSchoolDayTimeDangeroustask12months,
          onChanged: (value) {
            setState(() {
              _longestSchoolDayTimeDangeroustask12months = value;
            });
          },
          options: [
            {'value': 'Less than one hour', 'title': 'Less than one hour'},
            {'value': '1 hour', 'title': '1 hour'},
            {'value': '2 hours', 'title': '2 hours'},
            {'value': '3-4 hours', 'title': '3-4 hours'},
            {'value': '4-6 hours', 'title': '4-6 hours'},
            {'value': '6-8 hours', 'title': '6-8 hours'},
            {'value': 'More than 8 hours', 'title': 'More than 8 hours'},
            {'value': 'Does not apply', 'title': 'Does not apply'},
          ],
        ),
        const SizedBox(height: 16),

        // Longest time spent on dangerous task during non-school day (12 months)
        _buildRadioGroup<String>(
          question: 'What was the longest time spent on the task during a NON-SCHOOL DAY in the last 12 months?',
          groupValue: _longestNonSchoolDayTimeDangeroustask12months,
          onChanged: (value) {
            setState(() {
              _longestNonSchoolDayTimeDangeroustask12months = value;
            });
          },
          options: [
            {'value': 'Less than one hour', 'title': 'Less than one hour'},
            {'value': '1-2 hours', 'title': '1-2 hours'},
            {'value': '2-3 hours', 'title': '2-3 hours'},
            {'value': '3-4 hours', 'title': '3-4 hours'},
            {'value': '4-6 hours', 'title': '4-6 hours'},
            {'value': '6-8 hours', 'title': '6-8 hours'},
            {'value': 'More than 8 hours', 'title': 'More than 8 hours'},
            {'value': 'Does not apply', 'title': 'Does not apply'},
          ],
        ),
        const SizedBox(height: 16),

        // School day hours input for dangerous tasks (12 months)
        _buildTextField(
          label: 'How many hours has the child worked on DANGEROUS tasks during SCHOOL DAYS in the last 12 months?',
          controller: _schoolDayHoursDangeroustask12monthsController,
          keyboardType: TextInputType.number,
          hintText: 'Enter number of hours',
        ),
        const SizedBox(height: 16),

        // Non-school day hours input for dangerous tasks (12 months)
        _buildTextField(
          label: 'How many hours has the child worked on DANGEROUS tasks during NON-SCHOOL DAYS in the last 12 months?',
          controller: _nonSchoolDayHoursDangeroustask12monthsController,
          keyboardType: TextInputType.number,
          hintText: 'Enter number of hours',
        ),
        const SizedBox(height: 16),

        // Adult supervision question for dangerous tasks (12 months)
        _buildRadioGroup<bool>(
          question: 'Was the child under supervision of an adult when performing DANGEROUS tasks?',
          groupValue: _wasSupervisedByAdultDangeroustask12months,
          onChanged: (value) {
            setState(() {
              _wasSupervisedByAdultDangeroustask12months = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 16),

        // Dangerous tasks in last 12 months
        Text(
          'Which of the following DANGEROUS tasks has the child done in the last 12 months on the cocoa farm?',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            _buildDangerousTaskCheckbox('Use of machetes for weeding or pruning (Clearing)', 'use_machetes'),
            _buildDangerousTaskCheckbox('Felling of trees', 'felling_trees'),
            _buildDangerousTaskCheckbox('Burning of plots', 'burning_plots'),
            _buildDangerousTaskCheckbox('Game hunting with a weapon', 'game_hunting'),
            _buildDangerousTaskCheckbox('Woodcutter\'s work', 'woodcutter_work'),
            _buildDangerousTaskCheckbox('Charcoal production', 'charcoal_production'),
            _buildDangerousTaskCheckbox('Stump removal', 'stump_removal'),
            _buildDangerousTaskCheckbox('Digging holes', 'digging_holes'),
            _buildDangerousTaskCheckbox('Working with a machete or any other sharp tool', 'sharp_tools'),
            _buildDangerousTaskCheckbox('Handling of agrochemicals', 'agrochemicals'),
            _buildDangerousTaskCheckbox('Driving motorized vehicles', 'driving_vehicles'),
            _buildDangerousTaskCheckbox('Carrying heavy loads', 'heavy_loads'),
            _buildDangerousTaskCheckbox('Night work on farm (between 6pm and 6am)', 'night_work'),
            _buildDangerousTaskCheckbox('None of the above', 'none'),
          ],
        ),
      ],
    );
  }

  Widget _buildDangerousTaskCheckbox(String title, String value) {
    return CustomCheckbox(
      value: _dangerousTasks12Months.contains(value),
      onChanged: (selected) {
        setState(() {
          if (selected == true) {
            _dangerousTasks12Months.add(value);
          } else {
            _dangerousTasks12Months.remove(value);
          }
        });
      },
      title: title,
    );
  }

  Widget _buildHealthAndSafetySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('HEALTH AND SAFETY'),

        // Has the child ever applied or sprayed agrochemicals on the farm?
        _buildRadioGroup<bool>(
          question: 'Has the child ever applied or sprayed agrochemicals on the farm?',
          groupValue: _appliedAgrochemicals,
          onChanged: (value) {
            setState(() {
              _appliedAgrochemicals = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 16),

        // Was the child on the farm during application of agrochemicals?
        _buildRadioGroup<bool>(
          question: 'Was the child on the farm during application of agrochemicals?',
          groupValue: _onFarmDuringApplication,
          onChanged: (value) {
            setState(() {
              _onFarmDuringApplication = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 16),

        // Recently, has the child suffered any injury?
        _buildRadioGroup<bool>(
          question: 'Recently, has the child suffered any injury?',
          groupValue: _sufferedInjury,
          onChanged: (value) {
            setState(() {
              _sufferedInjury = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),

        if (_sufferedInjury == true) ...[
          const SizedBox(height: 16),
          // How did the child get wounded?
          _buildTextField(
            label: 'How did the child get wounded?',
            controller: _howWoundedController,
            hintText: 'Describe how the injury occurred',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // When was the child wounded?
          _buildTextField(
            label: 'When was the child wounded?',
            controller: _whenWoundedController,
            readOnly: true,
            onTap: () => _selectWoundedDate(context),
            hintText: 'Select date of injury',
          ),
        ],
        const SizedBox(height: 16),

        _buildRadioGroup<bool>(
          question: 'Does the child often feel pains or aches?',
          groupValue: _oftenFeelPains,
          onChanged: (value) {
            setState(() {
              _oftenFeelPains = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),

        if (_sufferedInjury == true || _oftenFeelPains == true) ...[
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What help did the child receive to get better?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  CustomCheckbox(
                    value: _helpReceived.contains('adults_household'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _helpReceived.add('adults_household');
                        } else {
                          _helpReceived.remove('adults_household');
                        }
                      });
                    },
                    title: 'The adults of the household looked after him/her',
                  ),
                  CustomCheckbox(
                    value: _helpReceived.contains('adults_community'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _helpReceived.add('adults_community');
                        } else {
                          _helpReceived.remove('adults_community');
                        }
                      });
                    },
                    title: 'Adults of the community looked after him/her',
                  ),
                  CustomCheckbox(
                    value: _helpReceived.contains('medical_facility'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _helpReceived.add('medical_facility');
                        } else {
                          _helpReceived.remove('medical_facility');
                        }
                      });
                    },
                    title: 'The child was sent to the closest medical facility',
                  ),
                  CustomCheckbox(
                    value: _helpReceived.contains('no_help'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _helpReceived.clear();
                          _helpReceived.add('no_help');
                        } else {
                          _helpReceived.remove('no_help');
                        }
                      });
                    },
                    title: 'The child did not receive any help',
                  ),
                  CustomCheckbox(
                    value: _helpReceived.contains('other'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _helpReceived.add('other');
                        } else {
                          _helpReceived.remove('other');
                        }
                      });
                    },
                    title: 'Other',
                  ),
                  if (_helpReceived.contains('other')) ...[
                    const SizedBox(height: 8),
                    _buildTextField(
                      label: 'Please specify',
                      controller: _otherHelpController,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),

        // Photo Consent Section
        _buildSectionHeader('PHOTO CONSENT'),

        _buildRadioGroup<bool>(
          question: 'Does the parent consent to the taking of a picture of the child?',
          groupValue: _parentConsentPhoto,
          onChanged: (value) {
            setState(() {
              _parentConsentPhoto = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),

        if (_parentConsentPhoto == false) ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'If no, please specify reason',
            controller: _noConsentReasonController,
            hintText: 'Enter reason for not consenting to photo',
          ),
        ],

        if (_parentConsentPhoto == true) ...[
          const SizedBox(height: 16),
          _buildPhotoSection(),
        ],
      ],
    );
  }

  // ==================== DATE PICKERS ====================
  Future<void> _selectBirthYear(BuildContext context) async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year of Birth'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2007),
              lastDate: DateTime(2020),
              initialDate: DateTime(2010),
              selectedDate: DateTime(2010),
              onChanged: (DateTime date) {
                Navigator.pop(context, date);
              },
            ),
          ),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _birthYearController.text = picked.year.toString();
      });
    }
  }

  Future<void> _selectWoundedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _whenWoundedController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons() {
    final isLastChild = _currentChildNumber >= widget.totalChildren;
    final buttonText = isLastChild ? 'SAVE & FINISH' : 'SAVE & ADD ANOTHER CHILD';

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
      child: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: _currentChildNumber / widget.totalChildren,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Child $_currentChildNumber of ${widget.totalChildren}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSubmit,
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
                  : Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MAIN BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child $_currentChildNumber Details'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildBasicInformationSection(),
                    const SizedBox(height: 20),

                    // Family Information
                    _buildFamilyInformationSection(),
                    const SizedBox(height: 20),

                    // Education Information
                    _buildEducationInformationSection(),
                    const SizedBox(height: 20),

                    // Work Information
                    _buildWorkInformationSection(),
                    const SizedBox(height: 20),

                    // Light Tasks (7 Days)
                    _buildLightTasks7DaysSection(),
                    const SizedBox(height: 20),

                    // Light Tasks (12 Months)
                    _buildLightTasks12MonthsSection(),
                    const SizedBox(height: 20),

                    // Dangerous Tasks (7 Days)
                    _buildDangerousTasks7DaysSection(),
                    const SizedBox(height: 20),

                    // Dangerous Tasks (12 Months)
                    _buildDangerousTasks12MonthsSection(),
                    const SizedBox(height: 20),

                    // Health and Safety
                    _buildHealthAndSafetySection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ==================== CLEANUP ====================
  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _surnameController.dispose();
    _birthYearController.dispose();
    _childNumberController.dispose();
    _noBirthCertificateReasonController.dispose();
    _otherRelationshipController.dispose();
    _otherFatherCountryController.dispose();
    _otherMotherCountryController.dispose();
    _otherAccompaniedController.dispose();
    _otherWhoDecidedController.dispose();
    _schoolNameController.dispose();
    _leftSchoolYearController.dispose();
    _otherReasonNotAttendedController.dispose();
    _otherReasonForLeavingSchoolController.dispose();
    _otherReasonNeverAttendedController.dispose();
    _otherAbsenceReasonController.dispose();
    _workForWhomOtherController.dispose();
    _whyWorkOtherController.dispose();
    _otherLocationLighttasks7daysController.dispose();
    _schoolDayTaskDurationLighttasks7daysController.dispose();
    _nonSchoolDayTaskDurationLighttasks7daysController.dispose();
    _otherLocationDangeroustask7daysController.dispose();
    _schoolDayHoursDangeroustask7daysController.dispose();
    _nonSchoolDayHoursDangeroustask7daysController.dispose();
    _otherLocationDangeroustask12monthsController.dispose();
    _schoolDayHoursDangeroustask12monthsController.dispose();
    _nonSchoolDayHoursDangeroustask12monthsController.dispose();
    _howWoundedController.dispose();
    _whenWoundedController.dispose();
    _otherHelpController.dispose();
    _noConsentReasonController.dispose();
    _otherSurveyReasonController.dispose();
    super.dispose();
  }
}

// ==================== NEXT SCREEN (Placeholder) ====================
class NextScreen extends StatelessWidget {
  final int coverPageId;
  final List<ChildDetailsModel> savedChildren;

  const NextScreen({
    Key? key,
    required this.coverPageId,
    required this.savedChildren,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'All Children Saved Successfully!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cover Page ID: $coverPageId',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Children Saved: ${savedChildren.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}