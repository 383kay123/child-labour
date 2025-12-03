import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class _ArithmeticItem extends StatelessWidget {
  final String expression;

  const _ArithmeticItem({
    Key? key,
    required this.expression,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        expression,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

// Modern Radio Button Widget
class ModernRadioButton<T> extends StatelessWidget {
  final T? value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final String title;
  final String? subtitle;

  const ModernRadioButton({
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
                        color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
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
// Modern Checkbox Widget
class ModernCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String title;
  final String? subtitle;

  const ModernCheckbox({
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
          onTap: () {
            // Use a post-frame callback to ensure the widget tree is stable
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onChanged(!value);
            });
          },
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
                // Custom Checkbox
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

class ChildDetailsPage extends StatefulWidget {
  final int childNumber;
  final int totalChildren;
  final List<dynamic> childrenDetails;
  final Function(dynamic) onComplete;
  final Map<String, dynamic>? initialData;

  const ChildDetailsPage({
    Key? key,
    required this.childNumber,
    required this.totalChildren,
    required this.childrenDetails,
    required this.onComplete,
    this.initialData,
  }) : super(key: key);

  @override
  State<ChildDetailsPage> createState() => ChildDetailsPageState();
}

class ChildDetailsPageState extends State<ChildDetailsPage> {
  final Set<String> _cocoaFarmTasksLast12Months = {};
  bool? _parentConsentPhoto;
  final TextEditingController _noConsentReasonController =
      TextEditingController();
  File? _childPhoto;

  final Set<String> _helpReceived = {};
  final TextEditingController _otherHelpController = TextEditingController();
  final TextEditingController _howWoundedController = TextEditingController();
  final TextEditingController _whenWoundedController = TextEditingController();
  bool? _oftenFeelPains;
  DateTime? _woundedDate;
  bool? _appliedAgrochemicals;
  bool? _onFarmDuringApplication;
  bool? _sufferedInjury;
  bool? _wasSupervisedByAdultLighttasks7daysDangerous;
  bool? _receivedSalaryForTasks;
  String? _longestSchoolDayTimeDangerous;
  String? _longestNonSchoolDayTimeLighttasks7daysDangerous;
  final TextEditingController _totalHoursWorkedControllerDangerous =
      TextEditingController();
  final TextEditingController _totalHoursWorkedControllerNonSchoolDangerous =
      TextEditingController();
  String? _whereTaskDone;
 
  String? _taskDangerousLocation;
  final TextEditingController _otherLocationDangerousController =
      TextEditingController();
  bool? _attendedSchoolLast7Days;
  bool? _missedSchoolDays;
  bool? _workedInHouse;
  final TextEditingController _schoolDayHoursDangerousController =
      TextEditingController();
  final TextEditingController _nonSchoolDayHoursController =
      TextEditingController();
  final TextEditingController _schoolDayHoursController =
      TextEditingController();
  String? _longestSchoolDayTime;
  String? _reasonForLeavingSchool;
final TextEditingController _otherReasonForLeavingSchoolController = TextEditingController();
  String? _selectedSchoolDayTime;
  bool? _workedOnCocoaFarm;
  String? _reasonNeverAttendedSchool;
final TextEditingController _otherReasonNeverAttendedController = TextEditingController();
  String? _workFrequency;
  bool? _observedWorking;
  bool? _receivedRemuneration;
  String? _reasonNotAttendedSchool;
final TextEditingController _otherReasonNotAttendedController = TextEditingController();
  bool? _activityRemuneration;
  


  String? _schoolDayTaskDuration;
  String? _nonSchoolDayTaskDuration;
  String? _taskLocationLighttasks7daysType;
  String? _lastTimeSpokeWithParents;
  String? _totalSchoolDayHours;
  String? _totalNonSchoolDayHours;
  bool? _wasSupervisedDuringTask;
  String? _educationLevel;
  final Set<String> _cocoaFarmTasksLast7Days = {};
  bool? _hasReceivedSalary;
  final TextEditingController _schoolDayTaskDurationLighttasks7daysControllerController =
      TextEditingController();
  final Set<String> _cocoaFarmTasks = {};
  final Set<String> _tasksLast12Months = {};
  final Map<String, bool> _absenceReasons = {
   'He/she was sick': false,
  'He/she was working': false,
  'He/she traveled': false,
  'Other': false,
  };
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otherReasonController = TextEditingController();
  final TextEditingController _otherReasonForSchoolController =
      TextEditingController();
  final TextEditingController _workForWhomOtherController =
      TextEditingController();
  final TextEditingController _whyWorkOtherController = TextEditingController();
  String? _workForWhom;
  final Set<String> _whyWorkReasons = {};
  final TextEditingController _otherAbsenceReasonController =
      TextEditingController();
  final TextEditingController _missedDaysReasonController =
      TextEditingController();
  String? _selectedLeaveReason;
  String? _gender;
  bool? _isFarmerChild;
  bool? _canBeSurveyedNow;
  bool? _hasBirthCertificate;
  bool? _bornInCommunity;
  String? _birthCountry;
  String? _workRelationship;
final TextEditingController _otherWorkRelationshipController = TextEditingController();
  bool? _hasSeenSpokenToParents;
  String? _relationshipToHead;
  final TextEditingController _otherRelationshipController =
      TextEditingController();
  List<String> _notWithFamilyReasons = [];
  final TextEditingController _otherNotWithFamilyController =
      TextEditingController();
  bool? _childAgreedWithDecision;
  bool? _hasSpokenWithParents;
  String? _neverBeenToSchool;
  String? _lastContactWithParents;
  String? _timeInHousehold;
  String? _whoAccompaniedChild;
  final TextEditingController _otherAccompaniedController =
      TextEditingController();
  String? _respondentType;
  String? _fatherResidence;
  String? _fatherCountry;
  final TextEditingController _otherFatherCountryController =
      TextEditingController();
  String? _motherResidence;
  String? _motherCountry;
  String? _canWriteSentences;
  final TextEditingController _otherMotherCountryController =
      TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _leftSchoolYearController =
      TextEditingController();
  DateTime? _leftSchoolDate;
  final TextEditingController _leftSchoolDateController =
      TextEditingController();
  bool? _isCurrentlyEnrolled;
  bool? _hasEverBeenToSchool;
  final TextEditingController _schoolNameController = TextEditingController();
  String? _schoolType;
  String? _gradeLevel;
  String? _schoolAttendanceFrequency;
  final Set<String> _availableSchoolSupplies = {};
  String? _whoDecidedChildCame;
final TextEditingController _otherWhoDecidedController = TextEditingController();

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

  final List<String> _countries = [
    'Benin',
    'Burkina Faso',
    'Ivory Coast',
    'Mali',
    'Niger',
    'Togo',
    'Other'
  ];

  final List<String> _surveyNotPossibleReasons = [];
  final Set<String> _dangerousTasks12Months = {};
  final TextEditingController _otherSurveyReasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalHoursWorkedController =
      TextEditingController();
  final TextEditingController _nonSchoolDayDangerousHoursController =
      TextEditingController();
  bool? _isSupervised;
  DateTime? _selectedDate;
  final TextEditingController _childNumberController = TextEditingController();
  final TextEditingController _respondentNameController =
      TextEditingController();
  final TextEditingController _otherRespondentTypeController =
      TextEditingController();
  final TextEditingController _otherRespondentSpecifyController =
      TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _noBirthCertificateReasonController =
      TextEditingController();

      

 // Light Tasks 7 Days State Variables
bool? _receivedRemunerationLighttasks7days;
String? _longestLightDutyTimeLighttasks7days;
String? _longestNonSchoolDayTimeLighttasks7days;
bool? _wasSupervisedByAdultLighttasks7days;
String? _taskLocationLighttasks7days;
final TextEditingController _otherLocationLighttasks7daysController = TextEditingController();
  final TextEditingController _schoolDayTaskDurationLighttasks7DaysControllerController =
      TextEditingController();
  final TextEditingController _nonSchoolDayTaskDurationLighttasks7DaysControllerController =
      TextEditingController();

      // Light Tasks 12 Months State Variables
bool? _receivedRemunerationLighttasks12months;
String? _longestSchoolDayTimeLighttasks12months;
String? _longestNonSchoolDayTimeLighttasks12months;
String? _taskLocationLighttasks12months;
String? _otherTaskLocationLighttasks12months;
String? _totalSchoolDayHoursLighttasks12months;
String? _totalNonSchoolDayHoursLighttasks12months;
bool? _wasSupervisedDuringTaskLighttasks12months;
TextEditingController _otherLocationDangeroustask12monthsController = TextEditingController();
TextEditingController _schoolDayHoursDangeroustask12monthsController = TextEditingController();
TextEditingController _nonSchoolDayHoursDangeroustask12monthsController = TextEditingController();

// Dangerous Tasks 7 Days State Variables
bool? _hasReceivedSalaryDangeroustask7days;
String? _taskLocationDangeroustask7days;
final TextEditingController _otherLocationDangeroustask7daysController = TextEditingController();
String? _longestSchoolDayTimeDangeroustask7days;
String? _longestNonSchoolDayTimeDangeroustask7days;
final TextEditingController _schoolDayHoursDangeroustask7daysController = TextEditingController();
final TextEditingController _nonSchoolDayHoursDangeroustask7daysController = TextEditingController();
bool? _wasSupervisedByAdultDangeroustask7days;

// State variables for Dangerous Tasks (12 Months)
bool? _hasReceivedSalaryDangeroustask12months;
String? _taskLocationDangeroustask12months;
String? _longestSchoolDayTimeDangeroustask12months;
String? _longestNonSchoolDayTimeDangeroustask12months;
bool? _wasSupervisedByAdultDangeroustask12months;

  // Birth location state
  String? _childBirthLocation;
  String? _childBirthCountry;
  
  // Relationship to head of household
  String? _childRelationship;
  
  // Reason for not living with family
  String? _reasonNotWithFamily;
  final TextEditingController _otherReasonNotWithFamilyController = TextEditingController();

  // Camera functionality
  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (photo != null) {
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
        if (_childPhoto != null) ...[
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _childPhoto!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
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
        ),
        const SizedBox(height: 8),
        if (_childPhoto != null) ...[
          Text(
            'Photo captured successfully!',
            style: TextStyle(
              color: Colors.green[600],
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  // Modern helper methods
  Widget _buildModernTaskCheckbox12Months(String task) {
    return ModernCheckbox(
      value: _tasksLast12Months.contains(task),
      onChanged: (bool? selected) {
        setState(() {
          if (selected == true) {
            _tasksLast12Months.add(task);
          } else {
            _tasksLast12Months.remove(task);
          }
        });
      },
      title: task,
    );
  }

  Widget _buildModernTaskCheckbox(String task) {
    return ModernCheckbox(
      value: _cocoaFarmTasks.contains(task),
      onChanged: (bool? selected) {
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

  Widget _buildDangerousTaskCheckbox12Months(String title, String value, {bool isNoneOption = false}) {
  return ModernCheckbox(
    value: _dangerousTasks12Months.contains(value),
    onChanged: (bool? selected) {
      setState(() {
        if (selected == true) {
          if (isNoneOption) {
            _dangerousTasks12Months.clear();
          } else {
            _dangerousTasks12Months.remove('none_dangeroustask12months');
          }
          _dangerousTasks12Months.add(value);
        } else {
          _dangerousTasks12Months.remove(value);
        }
      });
    },
    title: title,
  );
}

  Widget _buildModernRadioGroup<T>({
  required String question,
  required T? groupValue,
  required List<Map<String, dynamic>> options,
  required ValueChanged<T?> onChanged,
  String? subtitle,
  bool isRequired = false,
  String? errorMessage,
  bool showError = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Question and required indicator
      Container(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                question,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
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
      if (showError && isRequired && groupValue == null) ...[
        const SizedBox(height: 4),
        Text(
          errorMessage ?? 'This field is required',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 12,
          ),
        ),
      ],
      const SizedBox(height: 8),
      ...options.map((option) {
        try {
          return ModernRadioButton<T>(
            value: option['value'] as T,
            groupValue: groupValue,
            onChanged: (value) {
              onChanged(value);
              if (mounted) setState(() {});
            },
            title: option['title'] as String,
            subtitle: option['subtitle'] as String?,
          );
        } catch (e) {
          debugPrint('Error creating radio button: $e');
          return const SizedBox.shrink();
        }
      }).toList(), // Add .toList() to ensure proper list handling
    ],
  );
}
  Widget _buildModernCheckboxGroup({
    required String question,
    required Map<String, bool> values,
    required Function(String, bool?) onChanged,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,fontSize: 13
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
        const SizedBox(height: 12),
        ...values.entries.map((entry) => ModernCheckbox(
              value: entry.value,
              onChanged: (bool? selected) => onChanged(entry.key, selected),
              title: entry.key,
            )),
      ],
    );
  }

  Widget _buildModernDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
    String? Function(T?)? validator,
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
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool isRequired = false,  // All fields are optional by default
    VoidCallback? onTap,
    String? hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? requiredMessage,
    bool? isConditionallyRequired,  // For fields that are only required under certain conditions
    bool isConditionMet = true,     // Whether the condition for required is met
  }) {
    // Create a composite validator that checks both the custom validator and required status
    String? validateField(String? value) {
      // If there's a custom validator, use it first
      if (validator != null) {
        final customError = validator(value);
        if (customError != null) return customError;
      }
      
      // Check if field is required based on conditions
      final bool isFieldRequired = isConditionallyRequired == true 
          ? isConditionMet 
          : isRequired;
          
      // If field is required, check if it's empty
      if (isFieldRequired && (value == null || value.trim().isEmpty)) {
        return requiredMessage ?? '$label is required';
      }
      
      return null;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
                color: isRequired 
                    ? Theme.of(context).colorScheme.error 
                    : null,
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
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            errorMaxLines: 2,
          ),
          validator: validateField,
        ),
      ],
    );
  }

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

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
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
              initialDate: _selectedDate ?? DateTime(2010),
              selectedDate: _selectedDate ?? DateTime(2010),
              onChanged: (DateTime date) {
                Navigator.pop(context, date);
              },
            ),
          ),
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthYearController.text = picked.year.toString();
      });
    }
  }

  // No validation, just submit the form
  Future<void> _submitForm() async {
    debugPrint('Submitting form without validation...');
    debugPrint('Child number: ${widget.childNumber}, Total children: ${widget.totalChildren}');
    
    // Show loading indicator
    debugPrint('🔄 Showing loading dialog...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    
    // Delay to ensure the loading dialog is shown
    Future.delayed(Duration.zero, () async {
      debugPrint('🚀 Starting form submission process...');

      // If we get here, all validations passed
      try {
        final Map<String, dynamic> childData = {
        'childNumber': widget.childNumber,
        'isFarmerChild': _isFarmerChild,
        'childListNumber': _childNumberController.text.trim(),
        'birthDate': _selectedDate,
        'birthYear': _selectedDate?.year,
        'canBeSurveyedNow': _canBeSurveyedNow,
        'surveyNotPossibleReasons':
            _canBeSurveyedNow == false ? _surveyNotPossibleReasons : [],
        'otherReason': _canBeSurveyedNow == false &&
                _surveyNotPossibleReasons.contains('other')
            ? _otherReasonController.text.trim()
            : null,
        'respondentType': _canBeSurveyedNow == false ? _respondentType : null,
        'otherRespondentType':
            _canBeSurveyedNow == false && _respondentType == 'other'
                ? _otherRespondentTypeController.text.trim()
                : null,
        'childName': _nameController.text.trim(),
        'childSurname': _surnameController.text.trim(),
        'childGender': _gender,
        'childAge': _selectedDate != null
            ? (DateTime.now().year - _selectedDate!.year).toString()
            : '',
        'birthYear': _selectedDate?.year.toString() ?? '',
        'hasBirthCertificate': _hasBirthCertificate,
        'bornInCommunity': _bornInCommunity,
        'birthCountry': _birthCountry,
        'relationshipToHead': _relationshipToHead,
        'otherRelationship': _otherRelationshipController.text.trim(),
        'notWithFamilyReasons': _notWithFamilyReasons,
        'otherNotWithFamilyReason': _otherNotWithFamilyController.text.trim(),
        'childAgreedWithDecision': _childAgreedWithDecision,
        'hasSpokenWithParents': _hasSpokenWithParents,
        'timeInHousehold': _timeInHousehold,
        'whoAccompaniedChild': _whoAccompaniedChild,
        'otherAccompanied': _otherAccompaniedController.text.trim(),
        'fatherResidence': _fatherResidence,
        'fatherCountry': _fatherCountry,
        'otherFatherCountry': _otherFatherCountryController.text.trim(),
        'motherResidence': _motherResidence,
        'motherCountry': _motherCountry,
        'reasonNotAttendedSchool': _reasonNotAttendedSchool,
'otherReasonNotAttended': _reasonNotAttendedSchool == 'other'
    ? _otherReasonNotAttendedController.text.trim()
    : null,
        'otherMotherCountry': _otherMotherCountryController.text.trim(),
        'isCurrentlyEnrolled': _isCurrentlyEnrolled,
        'schoolName': _isCurrentlyEnrolled == true
            ? _schoolNameController.text.trim()
            : null,
        'schoolType': _isCurrentlyEnrolled == true ? _schoolType : null,
        'gradeLevel': _isCurrentlyEnrolled == true ? _gradeLevel : null,
        'schoolAttendanceFrequency':
            _isCurrentlyEnrolled == true ? _schoolAttendanceFrequency : null,
        'availableSchoolSupplies': _isCurrentlyEnrolled == true
            ? _availableSchoolSupplies.toList()
            : null,
        'hasEverBeenToSchool':
            _isCurrentlyEnrolled == false ? _hasEverBeenToSchool : null,
        'leftSchoolYear': _hasEverBeenToSchool == true
            ? _leftSchoolYearController.text.trim()
            : null,
        'attendedSchoolLast7Days': _attendedSchoolLast7Days,
        'reasonForLeavingSchool': _reasonForLeavingSchool,
'otherReasonForLeavingSchool': _reasonForLeavingSchool == 'other' 
    ? _otherReasonForLeavingSchoolController.text.trim()
    : null,
        'missedSchoolDays': _missedSchoolDays,
        'workedInHouse': _workedInHouse,
        'workedOnCocoaFarm': _workedOnCocoaFarm,
        'cocoaFarmTasks': _cocoaFarmTasks.toList(),
        'workFrequency': _workFrequency,
        'observedWorking': _observedWorking,
        'receivedRemuneration': _receivedRemuneration,
        'wasSupervisedByAdult': _wasSupervisedByAdultLighttasks7days,
        'longestLightDutyTime':  _longestLightDutyTimeLighttasks7days,
        'longestNonSchoolDayTime': _longestNonSchoolDayTimeLighttasks7days,
        'tasksLast12Months': _tasksLast12Months.toList(),
        'taskLocation': _taskLocationLighttasks7days,
        'reasonNeverAttendedSchool': _reasonNeverAttendedSchool,
'otherReasonNeverAttended': _reasonNeverAttendedSchool == 'other'
    ? _otherReasonNeverAttendedController.text.trim()
    : null,
        'otherTaskLocation':  _otherLocationLighttasks7daysController.text.trim(),
        'schoolDayHours': _schoolDayHoursController.text.trim(),
        'schoolDayTaskHours': _schoolDayTaskDurationLighttasks7daysControllerController.text.trim(),
        'parentConsentPhoto': _parentConsentPhoto,
        'childPhotoPath': _childPhoto?.path,
      };

        debugPrint('📝 Form data prepared, sending to parent...');
        debugPrint('   Child data: $childData');
      
      // Return the data to the parent
      if (!mounted) {
        debugPrint('❌ Widget is not mounted, aborting');
        return;
      }
      
      debugPrint('🔄 Dismissing loading dialog...');
      try {
        Navigator.of(context).pop(); // Dismiss loading dialog
        debugPrint('✅ Loading dialog dismissed');
      } catch (e) {
        debugPrint('❌ Error dismissing dialog: $e');
      }
      
      // Check if this is the last child
      final isLastChild = widget.childNumber >= widget.totalChildren;
      
      debugPrint('📞 Preparing to call onComplete callback...');
      debugPrint('   Child number: ${widget.childNumber}');
      debugPrint('   Total children: ${widget.totalChildren}');
      debugPrint('   Is last child: $isLastChild');
      debugPrint('   Child data: $childData');
      
      // Close any open dialogs first
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      // Add a small delay to ensure the dialog is dismissed
      await Future.delayed(const Duration(milliseconds: 100));
      
      try {
        if (widget.onComplete == null) {
          debugPrint('❌ ERROR: onComplete callback is null!');
          _showValidationError('System error: Cannot save child details');
          return;
        }
        
        debugPrint('🔹 Sending child data to parent...');
        final result = {
          'childData': childData,
          'navigateToNextChild': !isLastChild,
        };
        
        debugPrint('   Sending result: $result');
        
        // Call the callback
        final callbackResult = widget.onComplete(result);
        
        // If the callback returns a Future, wait for it
        if (callbackResult is Future) {
          await callbackResult;
        }
        
        debugPrint('✅ onComplete callback executed successfully');
      } catch (e, stackTrace) {
        debugPrint('❌ ERROR in onComplete callback: $e');
        debugPrint('Stack trace: $stackTrace');
        if (mounted) {
          _showValidationError('Error saving child details: ${e.toString()}');
        }
      }  
      } catch (e, stackTrace) {
        // Handle any errors during form submission
        debugPrint('EXCEPTION in form submission: $e');
        debugPrint('Stack trace: $stackTrace');
        
        if (mounted) {
          try {
            Navigator.of(context).pop(); // Dismiss loading dialog
          } catch (e) {
            debugPrint('Error dismissing dialog: $e');
          }
          
          _showValidationError('Error submitting form: ${e.toString()}');
        }
      }
    }); // Close the Future.delayed
  }

  Future<void> _selectWoundedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _woundedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _woundedDate) {
      setState(() {
        _woundedDate = picked;
        _whenWoundedController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectLeftSchoolDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _leftSchoolDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _leftSchoolDate) {
      setState(() {
        _leftSchoolDate = picked;
        _leftSchoolDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _onChildNumberChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _childNumberController.addListener(_onChildNumberChanged);
  }

  // Method to validate the form, can be called by parent
  void _showValidationError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool validateForm() {
    return true; // Always return true to bypass validation
  }

  /// Saves the current form data
  Future<void> saveData() async {
    // This will trigger form validation
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // If you have any additional save logic, add it here
    }
  }

  @override
  void dispose() {
    _childNumberController.removeListener(_onChildNumberChanged);
     _otherLocationLighttasks7daysController.dispose();
    _otherReasonController.dispose();
     _otherReasonController.dispose();
  _otherWorkRelationshipController.dispose(); // From previous addition
    _otherReasonForSchoolController.dispose();
    _otherAbsenceReasonController.dispose();
    _birthYearController.dispose();
    _leftSchoolYearController.dispose();
    _nameController.dispose();
    _otherFatherCountryController.dispose();
    _otherMotherCountryController.dispose();
    _schoolNameController.dispose();
    _childNumberController.dispose();
    _respondentNameController.dispose();
    _otherRespondentTypeController.dispose();
    _otherRespondentSpecifyController.dispose();
    _surnameController.dispose();
    _noBirthCertificateReasonController.dispose();
    _otherRelationshipController.dispose();
    _otherNotWithFamilyController.dispose();
    _otherAccompaniedController.dispose();
     _otherLocationLighttasks7daysController.dispose();
    _schoolDayTaskDurationLighttasks7daysControllerController.dispose();
    _nonSchoolDayHoursController.dispose();
    @override
void dispose() {
  _otherLocationLighttasks7daysController.dispose();
 
  super.dispose();
}
    _howWoundedController.dispose();
    _whenWoundedController.dispose();
    _otherHelpController.dispose();
    _noConsentReasonController.dispose();
     // Dispose all TextEditingControllers for Dangerous Tasks (12 months)
  _otherLocationDangeroustask12monthsController.dispose();
  _schoolDayHoursDangeroustask12monthsController.dispose();
  _nonSchoolDayHoursDangeroustask12monthsController.dispose();
    super.dispose();
  }

  // ==================== SECTION BUILDERS ====================

  Widget _buildBasicInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('BASIC INFORMATION'),
        
        // Farmer's Children Section
        _buildModernRadioGroup<bool>(
          question:
              'Is the child among the list of children declared in the cover to be the farmer\'s children?',
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
        const SizedBox(height: 24),

        _buildInfoCard('FARMER CHILDREN LIST'),

        // Child Number Input
        _buildModernTextField(
          label:
              'Enter the number attached to the child name in the cover so we can identify the child in question:',
          controller: _childNumberController,
          keyboardType: TextInputType.number,
          hintText: 'Enter child number',
        ),
        const SizedBox(height: 24),
         // Survey Availability
        _buildModernRadioGroup<bool>(
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
          const SizedBox(height: 24),
          _buildModernCheckboxGroup(
            question: 'If not, what are the reasons?',
            values: {
              'The child is at school': _surveyNotPossibleReasons
                  .contains('the_child_is_at_school'),
              'The child has gone to work on the cocoa farm':
                  _surveyNotPossibleReasons.contains(
                      'the_child_has_gone_to_work_on_the_cocoa_farm'),
              'Child is busy doing housework': _surveyNotPossibleReasons
                  .contains('child_is_busy_doing_housework'),
              'Child works outside the household':
                  _surveyNotPossibleReasons
                      .contains('child_works_outside_the_household'),
              'The child is too young': _surveyNotPossibleReasons
                  .contains('the_child_is_too_young'),
              'The child is sick':
                  _surveyNotPossibleReasons.contains('the_child_is_sick'),
              'The child has travelled': _surveyNotPossibleReasons
                  .contains('the_child_has_travelled'),
              'The child has gone out to play': _surveyNotPossibleReasons
                  .contains('the_child_has_gone_out_to_play'),
              'The child is sleeping': _surveyNotPossibleReasons
                  .contains('the_child_is_sleeping'),
              'Other reasons':
                  _surveyNotPossibleReasons.contains('other_reasons'),
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
          if (_surveyNotPossibleReasons.contains('other_reasons'))
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: _buildModernTextField(
                label: 'Please specify other reasons',
                controller: _otherSurveyReasonController,
                hintText: 'Enter other reasons for not being able to survey',
              ),
            ),
SizedBox(height: 24,),
        // Child's basic information
        _buildModernTextField(
          label: 'Child\'s First Name:',
          controller: _nameController,
          hintText: 'Enter child\'s first name',
        ),
        const SizedBox(height: 16),

        _buildModernTextField(
          label: 'Child\'s Surname:',
          controller: _surnameController,
          hintText: 'Enter child\'s surname',
        ),
        const SizedBox(height: 16),

        // Child's Gender
        _buildModernRadioGroup<String>(
          question: 'Gender of the child ${_childNumberController.text.isNotEmpty ? _childNumberController.text : 'Child'}',
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
        _buildModernTextField(
          label: 'Year of Birth of the child ${_childNumberController.text.isNotEmpty ? _childNumberController.text : 'Child'}',
          controller: _birthYearController,
          readOnly: true,
          onTap: () => _selectDate(context),
          hintText: 'Select year of birth',
        ),

        // Birth certificate
        const SizedBox(height: 24),
        _buildModernRadioGroup<bool>(
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
          _buildModernTextField(
            label: 'If no, please specify why',
            controller: _noBirthCertificateReasonController,
            hintText: 'Enter reason for not having a birth certificate',
          ),
        ],
        
        // Child's birth location
        const SizedBox(height: 24),
        _buildModernRadioGroup<String>(
          question: 'Is the child ${_childNumberController.text.isNotEmpty ? _childNumberController.text : 'Child'} born in this community?',
          groupValue: _childBirthLocation,
          onChanged: (value) {
            setState(() {
              _childBirthLocation = value;
            });
          },
          isRequired: true,
          options: [
            {'value': 'same_community', 'title': 'Yes'},
            {'value': 'same_district', 'title': 'No, he was born in this district but different community within the district'},
            {'value': 'same_region', 'title': 'No, he was born in this region but different district within the region'},
            {'value': 'other_region_ghana', 'title': 'No, he was born in another region of Ghana'},
            {'value': 'other_country', 'title': 'No, he was born in another country'},
          ],
        ),
        
        // Show country dropdown if born in another country
        if (_childBirthLocation == 'other_country') ...[
          const SizedBox(height: 16),
          _buildModernDropdown<String>(
            label: 'In which country is the child ${_childNumberController.text.isNotEmpty ? _childNumberController.text : 'Child'} born?',
            value: _childBirthCountry,
            items: _countries.map((country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _childBirthCountry = value;
              });
            },
            hintText: 'Select country',
          ),
        ],

        // Child's relationship to head of household
const SizedBox(height: 24),
_buildModernRadioGroup<String>(
  question: 'Relationship of the child ${_childNumberController.text.isNotEmpty ? _childNumberController.text : ''} to the head of the household',
  groupValue: _childRelationship,
  onChanged: (value) {
    setState(() {
      _childRelationship = value;
    });
  },
  isRequired: true,
  options: [
    {'value': 'son_daughter', 'title': 'Son/Daughter'},
    {'value': 'brother_sister', 'title': 'Brother/Sister'},
    {'value': 'in_law', 'title': 'Son-in-law/Daughter-in-law'},
    {'value': 'grandchild', 'title': 'Grandson/Granddaughter'},
    {'value': 'niece_nephew', 'title': 'Niece/Nephew'},
    {'value': 'cousin', 'title': 'Cousin'},
    {'value': 'worker_child', 'title': 'Child of the worker'},
    {'value': 'owner_child', 'title': 'Child of the farm owner (only if the respondent is the caretaker)'},
    {'value': 'other', 'title': 'Other (please specify)'},
  ],
),

// Show text field if "Other" is selected
if (_childRelationship == 'other') ...[
  const SizedBox(height: 16),
  _buildModernTextField(
    label: 'Please specify the relationship',
    controller: _otherRelationshipController,
    hintText: 'Enter relationship to head of household',
  ),
],
      ],
      ]
    );
  }

 

  Widget _buildFamilyInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('FAMILY INFORMATION'),

        // Show reason for not living with family if applicable
if (_childRelationship == 'worker_child' || 
    _childRelationship == 'owner_child' || 
    _childRelationship == 'other') ...[
  const SizedBox(height: 24),
  _buildModernRadioGroup<String>(
    question: 'Why does the child ${_childNumberController.text.isNotEmpty ? _childNumberController.text : ''} not live with his/her family?',
    groupValue: _reasonNotWithFamily,
    onChanged: (value) {
      setState(() {
        _reasonNotWithFamily = value;
      });
    },
    isRequired: true,
    options: [
      {'value': 'parents_deceased', 'title': 'Parents deceased'},
      {'value': 'cant_take_care', 'title': 'Can\'t take care of me'},
      {'value': 'abandoned', 'title': 'Abandoned'},
      {'value': 'school_reasons', 'title': 'School reasons'},
      {'value': 'recruitment_agency', 'title': 'A recruitment agency brought me here'},
      {'value': 'personal_choice', 'title': 'I did not want to live with my parents'},
      {'value': 'other_reason', 'title': 'Other (specify)'},
      {'value': 'dont_know', 'title': 'Don\'t know'},
    ],
  ),

  // Show text field if "Other" is selected
  if (_reasonNotWithFamily == 'other_reason') ...[
    const SizedBox(height: 16),
    _buildModernTextField(
      label: 'Please specify the reason',
      controller: _otherReasonNotWithFamilyController,
      hintText: 'Enter reason for not living with family',
    ),
  ],
],
SizedBox(height: 16,),
// Who decided the child should come into the household?
const SizedBox(height: 24),
_buildModernRadioGroup<String>(
  question: 'Who decided that the child ${_childNumberController.text.isNotEmpty ? _childNumberController.text : ''} should come into the household?',
  groupValue: _whoDecidedChildCame,
  onChanged: (value) {
    setState(() {
      _whoDecidedChildCame = value;
    });
  },
  isRequired: true,
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
  _buildModernTextField(
    label: 'Please specify who decided',
    controller: _otherWhoDecidedController,
    hintText: 'Enter who decided the child should come into the household',
  ),
],
SizedBox(height: 16,),
// Ask if the child agreed with the decision if someone else decided
if (_whoDecidedChildCame != null && _whoDecidedChildCame != 'myself') ...[
  const SizedBox(height: 16),
  _buildModernRadioGroup<bool>(
    question: 'Did the child ${_childNumberController.text.isNotEmpty ? _childNumberController.text : ''} agree with this decision?',
    groupValue: _childAgreedWithDecision,
    onChanged: (value) {
      setState(() {
        _childAgreedWithDecision = value;
      });
    },
    isRequired: true,
    options: [
      {'value': true, 'title': 'Yes'},
      {'value': false, 'title': 'No'},
      {'value': null, 'title': 'Not sure'},
    ],
  ),
],
SizedBox(height: 16,),
if (_whoDecidedChildCame != null && _whoDecidedChildCame != 'myself') ...[
  const SizedBox(height: 16),
  _buildModernRadioGroup<bool>(
    question: 'Has the child ${_childNumberController.text.isNotEmpty ? _childNumberController.text : ""} seen and/or spoken with his/her parents in the past year?',
    groupValue: _hasSeenSpokenToParents,
    onChanged: (value) {
      setState(() {
        _hasSeenSpokenToParents = value;
      });
    },
    isRequired: true,
    options: [
      {'value': true, 'title': 'Yes'},
      {'value': false, 'title': 'No'},
    ],
  ),
],

const SizedBox(height: 16),
  _buildModernRadioGroup<String>(
    question: 'When was the last time the child saw and/or talked with mom and/or dad?',
    groupValue: _lastTimeSpokeWithParents,
    onChanged: (String? value) {
      setState(() {
        _lastTimeSpokeWithParents = value;
      });
    },
    isRequired: true,
    options: [
      {'value': 'Max 1 week', 'title': 'Max 1 week'},
      {'value': 'Max 1 month', 'title': 'Max 1 month'},
      {'value': 'Max 1 year', 'title': 'Max 1 year'},
      {'value': 'More than 1 year', 'title': 'More than 1 year'},
      {'value': 'Never', 'title': 'Never'},
    ],
  ),
  SizedBox(height: 16,),
        // How long has the child been living in the household?
        _buildModernRadioGroup<String>(
          question:
              'For how long has the child been living in the household?',
          groupValue: _timeInHousehold,
          onChanged: (String? value) {
            setState(() {
              _timeInHousehold = value;
            });
          },
          options: [
            {
              'value': 'Born in the household',
              'title': 'Born in the household'
            },
            {'value': 'Less than 1 year', 'title': 'Less than 1 year'},
            {'value': '1-2 years', 'title': '1-2 years'},
            {'value': '2-4 years old', 'title': '2-4 years old'},
            {'value': '4-6 years old', 'title': '4-6 years old'},
            {'value': '6-8 years old', 'title': '6-8 years old'},
            {
              'value': 'More than 8 years',
              'title': 'More than 8 years'
            },
            {'value': 'Don\'t know', 'title': 'Don\'t know'},
          ],
        ),
        const SizedBox(height: 16),
        if (_whoDecidedChildCame != null && _whoDecidedChildCame != 'myself') ...[
  const SizedBox(height: 16),
  _buildModernRadioGroup<String>(
    question: 'Who accompanied the child ${_childNumberController.text.isNotEmpty ? _childNumberController.text : ""} to come here?',
    groupValue: _whoAccompaniedChild,
    onChanged: (String? value) {
      setState(() {
        _whoAccompaniedChild = value;
      });
    },
    isRequired: true,
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
    _buildModernTextField(
      label: 'Please specify who accompanied the child',
      controller: _otherAccompaniedController,
    ),
  ],
],

        // Father's residence - Only show if someone else made the decision
if (_whoDecidedChildCame != null && _whoDecidedChildCame != 'myself') ...[
  _buildModernRadioGroup<String>(
    question: 'Where does the child\'s father live?',
    groupValue: _fatherResidence,
    onChanged: (String? value) {
      setState(() {
        _fatherResidence = value;
      });
    },
    options: [
      {
        'value': 'In the same household',
        'title': 'In the same household'
      },
      {
        'value': 'In another household in the same village',
        'title': 'In another household in the same village'
      },
      {
        'value': 'In another household in the same region',
        'title': 'In another household in the same region'
      },
      {
        'value': 'In another household in another region',
        'title': 'In another household in another region'
      },
      {'value': 'Abroad', 'title': 'Abroad'},
      {'value': 'Parents deceased', 'title': 'Parents deceased'},
      {
        'value': 'Don\'t know/Don\'t want to answer',
        'title': 'Don\'t know/Don\'t want to answer'
      },
    ],
  ),

  // Show country selection if father is abroad
  if (_fatherResidence == 'Abroad') ...[
    const SizedBox(height: 16),
    _buildModernDropdown<String>(
      label: 'Father\'s country of residence',
      value: _fatherCountry,
      items: _fatherCountries.map((String country) {
        return DropdownMenuItem<String>(
          value: country,
          child: Text(country),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _fatherCountry = newValue;
        });
      },
      hintText: 'Select country',
    ),
    if (_fatherCountry == 'Others to be specified') ...[
      const SizedBox(height: 16),
      _buildModernTextField(
        label: 'Please specify country',
        controller: _otherFatherCountryController,
      ),
    ],
    const SizedBox(height: 16),
  ],
  const SizedBox(height: 24),
],
        // Mother's residence
        _buildModernRadioGroup<String>(
          question: 'Where does the child\'s mother live?',
          groupValue: _motherResidence,
          onChanged: (String? value) {
            setState(() {
              _motherResidence = value;
            });
          },
          options: [
            {
              'value': 'In the same household',
              'title': 'In the same household'
            },
            {
              'value': 'In another household in the same village',
              'title': 'In another household in the same village'
            },
            {
              'value': 'In another household in the same region',
              'title': 'In another household in the same region'
            },
            {
              'value': 'In another household in another region',
              'title': 'In another household in another region'
            },
            {'value': 'Abroad', 'title': 'Abroad'},
            {'value': 'Parents deceased', 'title': 'Parents deceased'},
            {
              'value': 'Don\'t know/Don\'t want to answer',
              'title': 'Don\'t know/Don\'t want to answer'
            },
          ],
        ),

        // Show country selection if mother is abroad
        if (_motherResidence == 'Abroad') ...[
          const SizedBox(height: 16),
          _buildModernDropdown<String>(
            label: 'Mother\'s country of residence',
            value: _motherCountry,
            items: _fatherCountries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _motherCountry = newValue;
              });
            },
            hintText: 'Select country',
          ),
          if (_motherCountry == 'Others to be specified') ...[
            const SizedBox(height: 16),
            _buildModernTextField(
              label: 'Please specify country',
              controller: _otherMotherCountryController,
            ),
          ],
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEducationInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('EDUCATION INFORMATION'),

        // School enrollment
        _buildModernRadioGroup<bool>(
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
          _buildModernTextField(
            label: 'What is the name of the school?',
            controller: _schoolNameController,
            hintText: 'Enter school name',
          ),
        ],
        if (_isCurrentlyEnrolled == true && _schoolNameController.text.trim().isNotEmpty) ...[
  const SizedBox(height: 16),
  _buildModernRadioGroup<String>(
    question: 'Is the school a public or private school?',
    groupValue: _schoolType,
    onChanged: (String? value) {
      setState(() {
        _schoolType = value;
      });
    },
    options: [
      {'value': 'Public', 'title': 'Public'},
      {'value': 'Private', 'title': 'Private'},
    ],
    isRequired: true,  // Added to make this a required field
  ),
],
        if (_isCurrentlyEnrolled == true &&
            _schoolNameController.text.trim().isNotEmpty &&
            _schoolType != null) ...[
          const SizedBox(height: 16),
          _buildModernDropdown<String>(
            label: 'What grade is the child enrolled in?',
            value: _gradeLevel,
            items: _gradeLevels.map((String grade) {
              return DropdownMenuItem<String>(
                value: grade,
                child: Text(grade),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _gradeLevel = newValue;
              });
            },
            hintText: 'Select grade level',
          ),
        ],
        if (_isCurrentlyEnrolled == true &&
            _schoolNameController.text.trim().isNotEmpty &&
            _schoolType != null &&
            _gradeLevel != null) ...[
          const SizedBox(height: 16),
          _buildModernRadioGroup<String>(
            question:
            'How many times does the child go to school in a week?',
            groupValue: _schoolAttendanceFrequency,
            onChanged: (String? value) {
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
                ModernCheckbox(
                  value: _availableSchoolSupplies.contains('Books'),
                  onChanged: (bool? selected) {
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
                ModernCheckbox(
                  value:
                      _availableSchoolSupplies.contains('School bag'),
                  onChanged: (bool? selected) {
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
                ModernCheckbox(
                  value: _availableSchoolSupplies
                      .contains('Pen / Pencils'),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _availableSchoolSupplies.add('Pen / Pencils');
                      } else {
                        _availableSchoolSupplies
                            .remove('Pen / Pencils');
                      }
                    });
                  },
                  title: 'Pen / Pencils',
                ),
                ModernCheckbox(
                  value: _availableSchoolSupplies
                      .contains('School Uniforms'),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _availableSchoolSupplies.add('School Uniforms');
                      } else {
                        _availableSchoolSupplies
                            .remove('School Uniforms');
                      }
                    });
                  },
                  title: 'School Uniforms',
                ),
                ModernCheckbox(
                  value: _availableSchoolSupplies
                      .contains('Shoes and Socks'),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _availableSchoolSupplies.add('Shoes and Socks');
                      } else {
                        _availableSchoolSupplies
                            .remove('Shoes and Socks');
                      }
                    });
                  },
                  title: 'Shoes and Socks',
                ),
                ModernCheckbox(
                  value: _availableSchoolSupplies
                      .contains('None of the above'),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _availableSchoolSupplies.clear();
                        _availableSchoolSupplies
                            .add('None of the above');
                      } else {
                        _availableSchoolSupplies
                            .remove('None of the above');
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
          _buildModernRadioGroup<bool>(
            question: 'Has the child ever been to school?',
            groupValue: _hasEverBeenToSchool,
            onChanged: (bool? value) {
              setState(() {
                _hasEverBeenToSchool = value;
              });
            },
            options: [
              {
                'value': true,
                'title': 'Yes, they went to school but stopped',
                'subtitle': null,
              },
              {
                'value': false,
                'title': 'No, they have never been to school',
                'subtitle': null,
              },
            ],
          ),

          // Additional sections for children who were enrolled but stopped
         if (_hasEverBeenToSchool == true) ...[
  const SizedBox(height: 16),
  _buildModernTextField(
    label: 'When did the child leave school?',
    controller: _leftSchoolYearController,
    keyboardType: TextInputType.number,
    hintText: 'Enter year (e.g., 2023)',
    isRequired: true,  // Make this field required
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter the year';
      }
      final year = int.tryParse(value);
      if (year == null || year < 1900 || year > DateTime.now().year) {
        return 'Please enter a valid year';
      }
      return null;
    },
  ),
  const SizedBox(height: 16),
  _buildModernTextField(
    label: 'Or select exact date:',
    controller: _leftSchoolDateController,
    readOnly: true,
    isRequired: true,  // Make this field required
    onTap: () => _selectLeftSchoolDate(context),
    hintText: 'Select date',
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select a date';
      }
      return null;
    },
  ),
         ],

            // Arithmetic Assessment Section
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.2)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Arithmetic Reference',
                        style: TextStyle(fontSize: 17,  fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
Text(
  'Please ask the child to solve these problems:',
  style: TextStyle(
    fontSize: 13,
    color: Colors.grey,
    fontStyle: FontStyle.italic,
  ),
),
const SizedBox(height: 8),
Wrap(
  spacing: 16,
  runSpacing: 8,
  children: [
    _ArithmeticItem(expression: '1 + 2 = 3'),
    _ArithmeticItem(expression: '2 + 3 = 5'),
    _ArithmeticItem(expression: '5 - 3 = 2'),
    _ArithmeticItem(expression: '9 - 4 = 5'),
    _ArithmeticItem(expression: '9 + 7 = 16'),
    _ArithmeticItem(expression: '3 × 7 = 21'),
  ],
),
                  ],
                ),
              ),
            ),

            // Reading Assessment Section
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.2)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reading Assessment',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text(
  'Please ask the child to read these sentences out loud:',
  style: TextStyle(
    fontSize: 13,
    color: Colors.grey,
    fontStyle: FontStyle.italic,
  ),
),
const SizedBox(height: 8),
Text(
  '1. "This is Ama"\n'
  '2. "It is water"\n'
  '3. "I like to play with my friends"\n'
  '4. "I am going to school"\n'
  '5. "Kofi is crying loudly"\n'
  '6. "I am good at playing both Basketball and football"',
  style: TextStyle(fontSize: 16, height: 1.8),
),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: Theme.of(context).primaryColor.withOpacity(0.2),
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Writing Assessment',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Please ask the child to write any of the above sentences on a piece of paper:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        _buildModernRadioGroup<String>(
          question: 'Can the child write the sentences?',
          groupValue: _canWriteSentences,
          onChanged: (String? value) {
            setState(() {
              _canWriteSentences = value;
            });
          },
          options: [
            {
              'value': 'writes_both',
              'title': 'Yes, he/she can write both sentences'
            },
            {
              'value': 'writes_simple',
              'title': 'Only the simple text (text 1)'
            },
            {
              'value': 'cannot_write',
              'title': 'No'
            },
            {
              'value': 'refused',
              'title': 'The child refuses to try'
            },
          ],
        ),
      ],
    ),
  ),
),
if (_hasEverBeenToSchool == true || _isCurrentlyEnrolled == false) ...[
  const SizedBox(height: 16),
  _buildModernRadioGroup<String>(
    question: 'What is the education level of ${_childNumberController.text}?',
    groupValue: _educationLevel,
    onChanged: (String? value) {
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
        'title': "SSS/'O'-level/'A'-level (including vocational & technical training)"
      },
      {'value': 'university', 'title': 'University or higher'},
      {'value': 'not_applicable', 'title': 'Not applicable'},
    ],
  ),
],
// Add this after the education level question
if (_hasEverBeenToSchool == true || _isCurrentlyEnrolled == false) ...[
  const SizedBox(height: 16),
  _buildModernRadioGroup<String>(
    question: 'What is the main reason for the child ${_childNumberController.text} leaving school?',
    groupValue: _reasonForLeavingSchool,
    onChanged: (String? value) {
      setState(() {
        _reasonForLeavingSchool = value;
        // Clear other reason text if not selected
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
      {'value': 'cant_afford_materials', 'title': "Parents can't afford Teaching and Learning Materials"},
      {'value': 'other', 'title': 'Other'},
      {'value': 'dont_know', 'title': 'Does not know'},
    ],
  ),
  if (_reasonForLeavingSchool == 'other') ...[
    const SizedBox(height: 8),
    TextFormField(
      controller: _otherReasonForLeavingSchoolController,
      decoration: const InputDecoration(
        labelText: 'Please specify other reason',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {});
      },
    ),
  ],
],
if (_hasEverBeenToSchool == false) ...[
  const SizedBox(height: 16),
  _buildModernRadioGroup<String>(
    question: 'Why has the child ${_childNumberController.text} never been to school before?',
    groupValue: _reasonNeverAttendedSchool,
    onChanged: (String? value) {
      setState(() {
        _reasonNeverAttendedSchool = value;
        // Clear other reason text if not selected
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
      {'value': 'child_refused', 'title': "The child doesn't want to go to school"},
      {'value': 'cant_afford', 'title': "Parents can't afford TLMs and/or enrollment fees"},
      {'value': 'other', 'title': 'Other'},
    ],
  ),
  if (_reasonNeverAttendedSchool == 'other') ...[
    const SizedBox(height: 8),
    TextFormField(
      controller: _otherReasonNeverAttendedController,
      decoration: const InputDecoration(
        labelText: 'Please specify other reason',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {});
      },
    ),
  ],
],
            // School attendance in past 7 days - Only show if currently enrolled
if (_isCurrentlyEnrolled == true) ...[
  const SizedBox(height: 24),
  _buildModernRadioGroup<bool>(
    question: 'Has the child been to school in the past 7 days?',
    groupValue: _attendedSchoolLast7Days,
    onChanged: (bool? value) {
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
  _buildModernRadioGroup<String>(
    question: 'Why has the child not been to school ?',
    groupValue: _reasonNotAttendedSchool,
    onChanged: (String? value) {
      setState(() {
        _reasonNotAttendedSchool = value;
        // Clear other reason text if not selected
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
    const SizedBox(height: 8),
    TextFormField(
      controller: _otherReasonNotAttendedController,
      decoration: const InputDecoration(
        labelText: 'Please specify other reason',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {});
      },
    ),
  ],
],
            // Question about missing school days
            const SizedBox(height: 16),
            _buildModernRadioGroup<bool>(
              question:
                  'Has the child missed any school days in the past 7 days?',
              groupValue: _missedSchoolDays,
              onChanged: (bool? value) {
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
  _buildModernCheckboxGroup(
    question: 'Why has the child miss school?',
    values: _absenceReasons,
    onChanged: (String reason, bool? selected) {
      setState(() {
        _absenceReasons[reason] = selected ?? false;
      });
    },
  ),
  if (_absenceReasons['Other'] == true) ...[
    const SizedBox(height: 8),
    TextFormField(
      controller: _otherAbsenceReasonController,
      decoration: const InputDecoration(
        labelText: 'Please specify other reason',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {});
      },
    ),
  ],
          ],
        ],
      ]
    );
  }

  Widget _buildWorkInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('WORK INFORMATION'),

        // Work-related questions
        _buildModernRadioGroup<bool>(
          question:
              'In the past 7 days, has the child [${widget.childNumber}] worked in the house?',
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
        const SizedBox(height: 24),

        _buildModernRadioGroup<bool>(
          question:
              'In the past 7 days, has the child [${widget.childNumber}] been working on the cocoa farm?',
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
          const SizedBox(height: 24),
          Text(
            'Which of these tasks has child [${widget.childNumber}] performed in the last 7 Days?',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernTaskCheckbox(
                  'Collect and gather fruits, pods, seeds after harvesting'),
              _buildModernTaskCheckbox(
                  'Extracting cocoa beans after shelling by an adult'),
              _buildModernTaskCheckbox(
                  'Wash beans, fruits, vegetables or tubers'),
              _buildModernTaskCheckbox(
                  'Prepare the germinators and pour the seeds into the germinators'),
              _buildModernTaskCheckbox('Collecting firewood'),
              _buildModernTaskCheckbox(
                  'Help measure distances between plants during transplanting'),
              _buildModernTaskCheckbox(
                  'Sort and spread the beans, cereals and other vegetables for drying'),
              _buildModernTaskCheckbox(
                  'Putting cuttings on the mounds'),
              _buildModernTaskCheckbox(
                  'Holding bags or filling them with small containers for packaging'),
              _buildModernTaskCheckbox(
                  'Covering stored agricultural products with tarps'),
              _buildModernTaskCheckbox(
                  'To shell or dehusk seeds, plants and fruits by hand'),
              _buildModernTaskCheckbox('Sowing seeds'),
              _buildModernTaskCheckbox(
                  'Transplant or put in the ground the cuttings or plants'),
              _buildModernTaskCheckbox(
                  'Harvesting legumes, fruits and other leafy products (corn, beans, soybeans, various vegetables)'),
              _buildModernTaskCheckbox('None'),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Work frequency
        const SizedBox(height: 24),
        _buildModernRadioGroup<String>(
          question:
              'How often has the child worked in the past 7 days?',
          groupValue: _workFrequency,
          onChanged: (String? value) {
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
        const SizedBox(height: 24),
        _buildModernRadioGroup<bool>(
          question:
              'Did the enumerator observe the child [${widget.childNumber}] working in a real situation?',
          groupValue: _observedWorking,
          onChanged: (bool? value) {
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
          const SizedBox(height: 24),
          _buildModernRadioGroup<String>(
            question: 'For whom does the child work on cocoa farming?',
            groupValue: _workForWhom,
            onChanged: (String? value) {
              setState(() {
                _workForWhom = value;
              });
            },
            options: [
              {'value': 'parents', 'title': 'For his/her parents'},
              {
                'value': 'family_not_parents',
                'title': 'For family, not parents'
              },
              {
                'value': 'family_friends',
                'title': 'For family friends'
              },
              {'value': 'other', 'title': 'Other'},
            ],
            subtitle: 'Obligatory if the child works in cocoa farming',
          ),
          if (_workForWhom == 'other') ...[
            const SizedBox(height: 16),
            _buildModernTextField(
              label: 'Please specify',
              controller: _workForWhomOtherController,
            ),
          ],
        ],

        // Why does the child work?
        if (_workedOnCocoaFarm == true) ...[
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why does the child [${widget.childNumber}] work on cocoa farming?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  ModernCheckbox(
                    value: _whyWorkReasons.contains('own_money'),
                    onChanged: (bool? selected) {
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
                  ModernCheckbox(
                    value: _whyWorkReasons.contains('increase_income'),
                    onChanged: (bool? selected) {
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
                  ModernCheckbox(
                    value:
                        _whyWorkReasons.contains('cannot_afford_adult'),
                    onChanged: (bool? selected) {
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
                  ModernCheckbox(
                    value: _whyWorkReasons.contains('no_adult_labor'),
                    onChanged: (bool? selected) {
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
                  ModernCheckbox(
                    value: _whyWorkReasons.contains('learn_farming'),
                    onChanged: (bool? selected) {
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
                  ModernCheckbox(
                    value: _whyWorkReasons.contains('other'),
                    onChanged: (bool? selected) {
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
                    _buildModernTextField(
                      label: 'Please specify',
                      controller: _whyWorkOtherController,
                    ),
                  ],
                  ModernCheckbox(
                    value: _whyWorkReasons.contains('dont_know'),
                    onChanged: (bool? selected) {
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

  Widget _buildLightTasks7DaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('LIGHT TASKS (7 DAYS)'),

        // Light work explanation
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Light work refers to tasks that do not interfere with a child\'s education, health, or development. Light work is permissible under certain conditions, typically for children above the minimum working age (which varies by country but is often around 13 or 15 years old) under the supervision of the parents or guardians.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // Remuneration question for light tasks
       _buildModernRadioGroup<bool>(
  question: 'Did the child receive remuneration for the activity?',
  groupValue: _receivedRemunerationLighttasks7days,
  onChanged: (bool? value) {
    setState(() {
      _receivedRemunerationLighttasks7days = value;
    });
  },
  options: [
    {'value': true, 'title': 'Yes'},
    {'value': false, 'title': 'No'},
  ],
),

        // Time spent on light duty - School day
        const SizedBox(height: 24),
        _buildModernRadioGroup<String>(
          question:
              'What was the longest time spent on light duty during a SCHOOL DAY in the last 7 days?',
          groupValue:  _longestLightDutyTimeLighttasks7days,
          onChanged: (String? value) {
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
            {
              'value': 'More than 8 hours',
              'title': 'More than 8 hours'
            },
            {'value': 'Does not apply', 'title': 'Does not apply'},
          ],
        ),

        // Time spent on light duty - Non-school day
        const SizedBox(height: 24),
        _buildModernRadioGroup<String>(
          question:
              'What was the longest amount of time spent on light duty on a NON-SCHOOL DAY in the last 7 days?',
          groupValue: _longestNonSchoolDayTimeLighttasks7days,
          onChanged: (String? value) {
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
            {
              'value': 'More than 8 hours',
              'title': 'More than 8 hours'
            },
            {'value': 'Does not apply', 'title': 'Does not apply'},
          ],
        ),

        // Adult supervision question for light tasks
        const SizedBox(height: 24),
        _buildModernRadioGroup<bool>(
          question:
              'Was the child under supervision of an adult when performing light tasks?',
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

        // Task location for light tasks
        const SizedBox(height: 24),
        _buildModernRadioGroup<String>(
          question: 'Where were the light tasks done?',
          groupValue: _taskLocationLighttasks7days,
          onChanged: (String? value) {
            setState(() {
              _taskLocationLighttasks7days = value;
            });
          },
          options: [
            {'value': 'On family farm', 'title': 'On family farm'},
            {
              'value': 'As a hired labourer on another farm',
              'title': 'As a hired labourer on another farm'
            },
            {
              'value': 'School farms/compounds',
              'title': 'School farms/compounds'
            },
            {
              'value': 'Teachers farms (during communal labour)',
              'title': 'Teachers farms (during communal labour)'
            },
            {
              'value': 'Church farms or cleaning activities',
              'title': 'Church farms or cleaning activities'
            },
            {
              'value': 'Helping a community member for free',
              'title': 'Helping a community member for free'
            },
            {'value': 'Other', 'title': 'Other'},
          ],
        ),

        if (_taskLocationLighttasks7days == 'Other') ...[
          const SizedBox(height: 16),
          _buildModernTextField(
            label: 'Please specify',
            controller:  _otherLocationLighttasks7daysController,
          ),
        ],

        // Total hours on school days for light tasks
        const SizedBox(height: 24),
        _buildModernTextField(
          label:
              'How many hours in total did the child spend on light tasks during SCHOOL DAYS in the past 7 days?',
          controller: _schoolDayTaskDurationLighttasks7DaysControllerController,
          keyboardType: TextInputType.number,
          hintText: 'Enter hours (0-1016)',
        ),

        const SizedBox(height: 24),
        _buildModernTextField(
          label:
              'How many hours in total did the child spend on light tasks during SCHOOL DAYS in the past 7 days?',
          controller:_nonSchoolDayTaskDurationLighttasks7DaysControllerController,
          keyboardType: TextInputType.number,
          hintText: 'Enter hours (0-1016)',
        ),

        // Tasks in last 12 months - only show if worked on cocoa farm in past 7 days
        if (_workedOnCocoaFarm == true) ...[
          const SizedBox(height: 24),
          Text(
            'Which of these tasks has child [${widget.childNumber}] performed in the last 12 months?',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernTaskCheckbox12Months(
                  'Collect and gather fruits, pods, seeds after harvesting'),
              _buildModernTaskCheckbox12Months(
                  'Extracting cocoa beans after shelling by an adult'),
              _buildModernTaskCheckbox12Months(
                  'Wash beans, fruits, vegetables or tubers'),
              _buildModernTaskCheckbox12Months(
                  'Prepare the germinators and pour the seeds into the germinators'),
              _buildModernTaskCheckbox12Months('Collecting firewood'),
              _buildModernTaskCheckbox12Months(
                  'Help measure distances between plants during transplanting'),
              _buildModernTaskCheckbox12Months(
                  'Sort and spread the beans, cereals and other vegetables for drying'),
              _buildModernTaskCheckbox12Months(
                  'Putting cuttings on the mounds'),
              _buildModernTaskCheckbox12Months(
                  'Holding bags or filling them with small containers for packaging de produits agricoles'),
              _buildModernTaskCheckbox12Months(
                  'Covering stored agricultural products with tarps'),
              _buildModernTaskCheckbox12Months(
                  'Shell or dehusk seeds, plants and fruits by hand'),
              _buildModernTaskCheckbox12Months('Sowing seeds'),
              _buildModernTaskCheckbox12Months(
                  'Transplant or put in the ground the cuttings or plants'),
              _buildModernTaskCheckbox12Months(
                  'Harvesting legumes, fruits and other leafy products (corn, beans, soybeans, various vegetables)'),
              _buildModernTaskCheckbox12Months('None'),
            ],
          ),
        ],
      ],
    );
  }Widget _buildLightTasks12MonthsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader('LIGHT TASK (12 MONTHS)'),

      // Activity remuneration question for 12 months
      _buildModernRadioGroup<bool>(
        question: 'Did the child receive any remuneration for the activity?',
        groupValue: _receivedRemunerationLighttasks12months,
        onChanged: (bool? value) {
          setState(() {
            _receivedRemunerationLighttasks12months = value;
          });
        },
        options: [
          {'value': true, 'title': 'Yes'},
          {'value': false, 'title': 'No'},
        ],
      ),

      // School day task duration question for 12 months
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'What was the longest time spent on light tasks during a SCHOOL DAY in the last 12 months?',
        groupValue: _longestSchoolDayTimeLighttasks12months,
        onChanged: (String? value) {
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

      // Non-school day task duration question for 12 months
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'What was the longest time spent on light tasks on a NON-SCHOOL DAY in the last 12 months?',
        groupValue: _longestNonSchoolDayTimeLighttasks12months,
        onChanged: (String? value) {
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

      // Task location question for 12 months
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'Where was this task done?',
        groupValue: _taskLocationLighttasks12months,
        onChanged: (String? value) {
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

      if (_taskLocationLighttasks12months == 'Other')
        Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Please specify where the task was done',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _otherTaskLocationLighttasks12months = value;
              });
            },
          ),
        ),

      // Total hours on school days question for 12 months
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'How many hours in total did the child spend on light tasks during SCHOOL DAYS in the past 12 months?',
        groupValue: _totalSchoolDayHoursLighttasks12months,
        onChanged: (String? value) {
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

      // Total hours on non-school days question for 12 months
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'How many hours in total did the child spend on light tasks during NON-SCHOOL DAYS in the past 12 months?',
        groupValue: _totalNonSchoolDayHoursLighttasks12months,
        onChanged: (String? value) {
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

      // Adult supervision question for 12 months
      const SizedBox(height: 24),
      _buildModernRadioGroup<bool>(
        question: 'Was the child under supervision of an adult when performing this task?',
        groupValue: _wasSupervisedDuringTaskLighttasks12months,
        onChanged: (bool? value) {
          setState(() {
            _wasSupervisedDuringTaskLighttasks12months = value;
          });
        },
        options: [
          {'value': true, 'title': 'Yes'},
          {'value': false, 'title': 'No'},
        ],
      ),

      if (_workedOnCocoaFarm == true) ...[
        const SizedBox(height: 24),
        Text(
          'Which of these tasks has child [${widget.childNumber}] performed in the last 12 months?',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernTaskCheckbox12Months('Collect and gather fruits, pods, seeds after harvesting'),
            _buildModernTaskCheckbox12Months('Extracting cocoa beans after shelling by an adult'),
            _buildModernTaskCheckbox12Months('Wash beans, fruits, vegetables or tubers'),
            _buildModernTaskCheckbox12Months('Prepare the germinators and pour the seeds into the germinators'),
            _buildModernTaskCheckbox12Months('Collecting firewood'),
            _buildModernTaskCheckbox12Months('Help measure distances between plants during transplanting'),
            _buildModernTaskCheckbox12Months('Sort and spread the beans, cereals and other vegetables for drying'),
            _buildModernTaskCheckbox12Months('Putting cuttings on the mounds'),
            _buildModernTaskCheckbox12Months('Holding bags or filling them with small containers for packaging de produits agricoles'),
            _buildModernTaskCheckbox12Months('Covering stored agricultural products with tarps'),
            _buildModernTaskCheckbox12Months('Shell or dehusk seeds, plants and fruits by hand'),
            _buildModernTaskCheckbox12Months('Sowing seeds'),
            _buildModernTaskCheckbox12Months('Transplant or put in the ground the cuttings or plants'),
            _buildModernTaskCheckbox12Months('Harvesting legumes, fruits and other leafy products (corn, beans, soybeans, various vegetables)'),
            _buildModernTaskCheckbox12Months('None'),
          ],
        ),
      ],
    ],
  );
}
      
  
  
  

 Widget _buildDangerousTasksSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader('DANGEROUS TASKS (7 DAYS)'),

      // Salary question for dangerous tasks (7 days)
      const SizedBox(height: 24),
      _buildModernRadioGroup<bool>(
        question: 'Has the child [${widget.childNumber}] received a salary for this task?',
        groupValue: _hasReceivedSalaryDangeroustask7days,
        onChanged: (bool? value) {
          setState(() {
            _hasReceivedSalaryDangeroustask7days = value;
          });
        },
        options: [
          {'value': true, 'title': 'Yes'},
          {'value': false, 'title': 'No'},
        ],
      ),

      // Task location question for dangerous tasks (7 days)
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'Where was this task done?',
        groupValue: _taskLocationDangeroustask7days,
        onChanged: (String? value) {
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
        _buildModernTextField(
          label: 'Please specify',
          controller: _otherLocationDangeroustask7daysController,
        ),
      ],

      // Longest time spent on dangerous task during school day (7 days)
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'What was the longest time spent on the task during a SCHOOL DAY in the last 7 days?',
        groupValue: _longestSchoolDayTimeDangeroustask7days,
        onChanged: (String? value) {
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

      // Longest time spent on dangerous task during non-school day (7 days)
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'What was the longest time spent on the task during a NON-SCHOOL DAY in the last 7 days?',
        groupValue: _longestNonSchoolDayTimeDangeroustask7days,
        onChanged: (String? value) {
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

      // School day hours input for dangerous tasks (7 days)
      const SizedBox(height: 24),
      _buildModernTextField(
        label: 'How many hours has the child worked on DANGEROUS tasks during SCHOOL DAYS in the last 7 days?',
        controller: _schoolDayHoursDangeroustask7daysController,
        keyboardType: TextInputType.number,
        hintText: 'Enter number of hours',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the number of hours';
          }
          final hours = double.tryParse(value);
          if (hours == null || hours < 0) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),

      // Non-school day hours input for dangerous tasks (7 days)
      const SizedBox(height: 24),
      _buildModernTextField(
        label: 'How many hours has the child worked on DANGEROUS tasks during NON-SCHOOL DAYS in the last 7 days?',
        controller: _nonSchoolDayHoursDangeroustask7daysController,
        keyboardType: TextInputType.number,
        hintText: 'Enter number of hours',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the number of hours';
          }
          final hours = double.tryParse(value);
          if (hours == null || hours < 0) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),

      // Adult supervision question for dangerous tasks (7 days)
      const SizedBox(height: 24),
      _buildModernRadioGroup<bool>(
        question: 'Was the child under supervision of an adult when performing DANGEROUS tasks?',
        groupValue: _wasSupervisedByAdultDangeroustask7days,
        onChanged: (bool? value) {
          setState(() {
            _wasSupervisedByAdultDangeroustask7days = value;
          });
        },
        options: [
          {'value': true, 'title': 'Yes'},
          {'value': false, 'title': 'No'},
        ],
      ),
    
  

// Tasks in last 12 months for dangerous tasks
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Which of the following DANGEROUS tasks has the child done in the last 12 months on the cocoa farm?',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 8),
    Column(
      children: [
        _buildDangerousTaskCheckbox12Months(
          'Use of machetes for weeding or pruning (Clearing)',
          'use_machetes_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Felling of trees',
          'felling_trees_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Burning of plots',
          'burning_plots_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Game hunting with a weapon',
          'game_hunting_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Woodcutter\'s work',
          'woodcutter_work_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Charcoal production',
          'charcoal_production_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Stump removal',
          'stump_removal_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Digging holes',
          'digging_holes_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Working with a machete or any other sharp tool',
          'sharp_tools_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Handling of agrochemicals',
          'agrochemicals_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Driving motorized vehicles',
          'driving_vehicles_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Carrying heavy loads (Boys: 14-16 years old>15kg / 16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)',
          'heavy_loads_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'Night work on farm (between 6pm and 6am)',
          'night_work_dangeroustask12months'
        ),
        _buildDangerousTaskCheckbox12Months(
          'None of the above',
          'none_dangeroustask12months',
          isNoneOption: true
        ),
      ],
    ),
  ],
),
      ],
    );
  }

Widget _buildDangerousTasksSection12Months() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader('DANGEROUS TASKS (12 MONTHS)'),

      // Salary question for dangerous tasks (12 months)
      const SizedBox(height: 24),
      _buildModernRadioGroup<bool>(
        question: 'Has the child [${widget.childNumber}] received a salary for this task?',
        groupValue: _hasReceivedSalaryDangeroustask12months,
        onChanged: (bool? value) {
          setState(() {
            _hasReceivedSalaryDangeroustask12months = value;
          });
        },
        options: [
          {'value': true, 'title': 'Yes'},
          {'value': false, 'title': 'No'},
        ],
      ),

      // Task location question for dangerous tasks (12 months)
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'Where was this task done?',
        groupValue: _taskLocationDangeroustask12months,
        onChanged: (String? value) {
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
        _buildModernTextField(
          label: 'Please specify',
          controller: _otherLocationDangeroustask12monthsController,
        ),
      ],

      // Longest time spent on dangerous task during school day (12 months)
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'What was the longest time spent on the task during a SCHOOL DAY in the last 12 months?',
        groupValue: _longestSchoolDayTimeDangeroustask12months,
        onChanged: (String? value) {
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

      // Longest time spent on dangerous task during non-school day (12 months)
      const SizedBox(height: 24),
      _buildModernRadioGroup<String>(
        question: 'What was the longest time spent on the task during a NON-SCHOOL DAY in the last 12 months?',
        groupValue: _longestNonSchoolDayTimeDangeroustask12months,
        onChanged: (String? value) {
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

      // School day hours input for dangerous tasks (12 months)
      const SizedBox(height: 24),
      _buildModernTextField(
        label: 'How many hours has the child worked on DANGEROUS tasks during SCHOOL DAYS in the last 12 months?',
        controller: _schoolDayHoursDangeroustask12monthsController,
        keyboardType: TextInputType.number,
        hintText: 'Enter number of hours',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the number of hours';
          }
          final hours = double.tryParse(value);
          if (hours == null || hours < 0) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),

      // Non-school day hours input for dangerous tasks (12 months)
      const SizedBox(height: 24),
      _buildModernTextField(
        label: 'How many hours has the child worked on DANGEROUS tasks during NON-SCHOOL DAYS in the last 12 months?',
        controller: _nonSchoolDayHoursDangeroustask12monthsController,
        keyboardType: TextInputType.number,
        hintText: 'Enter number of hours',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the number of hours';
          }
          final hours = double.tryParse(value);
          if (hours == null || hours < 0) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),

      // Adult supervision question for dangerous tasks (12 months)
      const SizedBox(height: 24),
      _buildModernRadioGroup<bool>(
        question: 'Was the child under supervision of an adult when performing DANGEROUS tasks?',
        groupValue: _wasSupervisedByAdultDangeroustask12months,
        onChanged: (bool? value) {
          setState(() {
            _wasSupervisedByAdultDangeroustask12months = value;
          });
        },
        options: [
          {'value': true, 'title': 'Yes'},
          {'value': false, 'title': 'No'},
        ],
      ),

      // Tasks in last 12 months for dangerous tasks
      const SizedBox(height: 24),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which of the following DANGEROUS tasks has the child done in the last 12 months on the cocoa farm?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildDangerousTaskCheckbox12Months(
                'Use of machetes for weeding or pruning (Clearing)',
                'use_machetes'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Felling of trees',
                'felling_trees'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Burning of plots',
                'burning_plots'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Game hunting with a weapon',
                'game_hunting'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Woodcutter\'s work',
                'woodcutter_work'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Charcoal production',
                'charcoal_production'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Stump removal',
                'stump_removal'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Digging holes',
                'digging_holes'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Working with a machete or any other sharp tool',
                'sharp_tools'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Handling of agrochemicals',
                'agrochemicals'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Driving motorized vehicles',
                'driving_vehicles'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Carrying heavy loads (Boys: 14-16 years old>15kg / 16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)',
                'heavy_loads'
              ),
              _buildDangerousTaskCheckbox12Months(
                'Night work on farm (between 6pm and 6am)',
                'night_work'
              ),
              _buildDangerousTaskCheckbox12Months(
                'None of the above',
                'none',
                isNoneOption: true
              ),
            ],
         
          )
        ],
      
        
      ),
          // For whom does the child work?
      _buildModernRadioGroup<String>(
        question: 'For whom does the child work?',
        groupValue: _workRelationship,
        onChanged: (String? value) {
          setState(() {
            _workRelationship = value;
          });
        },
        options: [
          {'value': 'parents', 'title': 'For his/her parents'},
          {'value': 'family_not_parents', 'title': 'For family, not parents'},
          {'value': 'family_friends', 'title': 'For family friends'},
          {'value': 'other', 'title': 'Other'},
        ],
      ),

      // Additional field if "Other" is selected
      if (_workRelationship == 'other')
        _buildModernTextField(
          label: 'Please specify',
          controller: _otherWorkRelationshipController,
          isRequired: true,
        ),

      
    ],
    
  );
}        
    



  Widget _buildHealthAndSafetySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('HEALTH AND SAFETY'),



        // Has the child ever applied or sprayed agrochemicals on the farm?
        _buildModernRadioGroup<bool>(
          question:
              'Has the child ever applied or sprayed agrochemicals on the farm?',
          groupValue: _appliedAgrochemicals,
          onChanged: (bool? value) {
            setState(() {
              _appliedAgrochemicals = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 24),

        // Was the child on the farm during application of agrochemicals?
        _buildModernRadioGroup<bool>(
          question:
              'Was the child on the farm during application of agrochemicals?',
          groupValue: _onFarmDuringApplication,
          onChanged: (bool? value) {
            setState(() {
              _onFarmDuringApplication = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 24),

        // Recently, has the child suffered any injury?
        _buildModernRadioGroup<bool>(
          question: 'Recently, has the child suffered any injury?',
          groupValue: _sufferedInjury,
          onChanged: (bool? value) {
            setState(() {
              _sufferedInjury = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 24),

        if (_sufferedInjury == true) ...[
          const SizedBox(height: 24),
          // How did the child get wounded?
          _buildModernTextField(
            label: 'How did the child get wounded?',
            controller: _howWoundedController,
            hintText: 'Describe how the injury occurred',
            maxLines: 3,
            validator: (value) {
              if (_sufferedInjury == true && (value == null || value.trim().isEmpty)) {
                return 'Please describe how the child got wounded';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // When was the child wounded?
          _buildModernTextField(
            label: 'When was the child wounded?',
            controller: _whenWoundedController,
            readOnly: true,
            onTap: () => _selectWoundedDate(context),
            hintText: 'Select date of injury',
            validator: (value) {
              if (_sufferedInjury == true &&
                  (value == null || value.trim().isEmpty)) {
                return 'Please select when the child was wounded';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 24),

        _buildModernRadioGroup<bool>(
          question: 'Does the child often feel pains or aches?',
          groupValue: _oftenFeelPains,
          onChanged: (bool? value) {
            setState(() {
              _oftenFeelPains = value;
            });
          },
          options: [
            {'value': true, 'title': 'Yes'},
            {'value': false, 'title': 'No'},
          ],
        ),
        const SizedBox(height: 24),

        if (_sufferedInjury == true || _oftenFeelPains == true) ...[
          const SizedBox(height: 24),
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
                  ModernCheckbox(
                    value: _helpReceived.contains('adults_household'),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _helpReceived.add('adults_household');
                        } else {
                          _helpReceived.remove('adults_household');
                        }
                      });
                    },
                    title:
                        'The adults of the household looked after him/her',
                  ),
                  ModernCheckbox(
                    value: _helpReceived.contains('adults_community'),
                    onChanged: (bool? selected) {
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
                  ModernCheckbox(
                    value: _helpReceived.contains('medical_facility'),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _helpReceived.add('medical_facility');
                        } else {
                          _helpReceived.remove('medical_facility');
                        }
                      });
                    },
                    title:
                        'The child was sent to the closest medical facility',
                  ),
                  ModernCheckbox(
                    value: _helpReceived.contains('no_help'),
                    onChanged: (bool? selected) {
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
                  ModernCheckbox(
                    value: _helpReceived.contains('other'),
                    onChanged: (bool? selected) {
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
                    _buildModernTextField(
                      label: 'Please specify',
                      controller: _otherHelpController,
                      validator: (value) {
                        if (_helpReceived.contains('other') &&
                            (value == null || value.isEmpty)) {
                          return 'Please specify the help received';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),

        // Photo Consent Section
        _buildSectionHeader('PHOTO CONSENT'),

        _buildModernRadioGroup<bool>(
          question:
              'Does the parent consent to the taking of a picture of the child?',
          groupValue: _parentConsentPhoto,
          onChanged: (bool? value) {
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
          _buildModernTextField(
            label: 'If no, please specify reason',
            controller: _noConsentReasonController,
            hintText: 'Enter reason for not consenting to photo',
            validator: (value) {
              if (_parentConsentPhoto == false &&
                  (value == null || value.trim().isEmpty)) {
                return 'Please specify the reason for not consenting';
              }
              return null;
            },
          ),
        ],

        if (_parentConsentPhoto == true) ...[
          const SizedBox(height: 24),
          _buildPhotoSection(),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              debugPrint('Submit button tapped');
              _submitForm();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'SAVE CHILD DETAILS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 15),
              
              // Basic Information Section
              _buildBasicInformationSection(),
            SizedBox( height: 20,),
              
              // Family Information Section
              _buildFamilyInformationSection(),

              SizedBox( height: 20,),
              
              // Education Information Section
              _buildEducationInformationSection(),

              SizedBox( height: 20,),
              
              // Work Information Section
              _buildWorkInformationSection(),

              SizedBox( height: 20,),
              
              // Light Tasks Section (7 days)
              _buildLightTasks7DaysSection(),

              SizedBox( height: 20,),
              
              // Light Tasks Section (12 months)
              _buildLightTasks12MonthsSection(),
              SizedBox( height: 20,),
              
              // Dangerous Tasks Section
              _buildDangerousTasksSection(),

              SizedBox( height: 20,),
              _buildDangerousTasksSection12Months(),
              
              // Health and Safety Section
              _buildHealthAndSafetySection(),

              SizedBox( height: 20,),

              
              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}