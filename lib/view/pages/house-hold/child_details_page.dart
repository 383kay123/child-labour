import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../../theme/app_theme.dart';
// import 'package:surveyflow/view/pages/house-hold/pages/farm%20identification/sensitization_page.dart';

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

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
  final T value;
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
    final bool isSelected = value == groupValue;
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[50],
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Custom Radio Circle
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
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
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? primaryColor : Colors.grey[800],
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
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
          onTap: () => onChanged(!value),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: value ? primaryColor : Colors.grey[800],
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
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
  final Function(dynamic)? onComplete;

  const ChildDetailsPage({
    Key? key,
    required this.childNumber,
    required this.totalChildren,
    required this.childrenDetails,
    this.onComplete,
  }) : super(key: key);

  @override
  _ChildDetailsPageState createState() => _ChildDetailsPageState();
}

class _ChildDetailsPageState extends State<ChildDetailsPage> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // ========== BASIC CHILD INFORMATION ==========
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _childNumberController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  String? _gender;
  bool? _isFarmerChild;
  bool? _canBeSurveyedNow;
  DateTime? _selectedDate;

  // ========== SURVEY AVAILABILITY ==========
  final List<String> _surveyNotPossibleReasons = [];
  final TextEditingController _otherReasonController = TextEditingController();
  String? _respondentType;
  final TextEditingController _otherRespondentTypeController =
      TextEditingController();
  final TextEditingController _respondentNameController =
      TextEditingController();
  final TextEditingController _otherRespondentSpecifyController =
      TextEditingController();

  // ========== BIRTH AND DOCUMENTATION ==========
  bool? _hasBirthCertificate;
  final TextEditingController _noBirthCertificateReasonController =
      TextEditingController();
  bool? _bornInCommunity;
  String? _birthCountry;

  // ========== HOUSEHOLD RELATIONSHIP ==========
  String? _relationshipToHead;
  final TextEditingController _otherRelationshipController =
      TextEditingController();
  final Map<String, bool> _notLivingWithFamilyReasons = {
    'Child lives with other relatives': false,
    'Child is an orphan': false,
    'For education purposes': false,
    'Family is too poor to take care of the child': false,
    'Child is working to support family': false,
    'Other (specify)': false,
  };
  final TextEditingController _otherNotLivingWithFamilyController =
      TextEditingController();

  // ========== FAMILY DECISION INFORMATION ==========
  String? _whoDecidedChildJoin;
  final TextEditingController _otherPersonController = TextEditingController();
  bool? _childAgreedWithDecision;
  bool? _hasSpokenWithParents;
  String? _lastContactWithParents;
  String? _timeInHousehold;
  String? _whoAccompaniedChild;
  final TextEditingController _otherAccompaniedController =
      TextEditingController();

  // ========== PARENT RESIDENCE INFORMATION ==========
  String? _fatherResidence;
  String? _fatherCountry;
  final TextEditingController _otherFatherCountryController =
      TextEditingController();
  String? _motherResidence;
  String? _motherCountry;
  final TextEditingController _otherMotherCountryController =
      TextEditingController();

  // ========== EDUCATION INFORMATION ==========
  bool? _isCurrentlyEnrolled;
  bool? _hasEverBeenToSchool;
  final TextEditingController _schoolNameController = TextEditingController();
  String? _schoolType;
  String? _gradeLevel;
  String? _schoolAttendanceFrequency;
  final Set<String> _availableSchoolSupplies = {};

  final TextEditingController _leftSchoolYearController =
      TextEditingController();
  final TextEditingController _leftSchoolDateController =
      TextEditingController();
  DateTime? _leftSchoolDate;

  String? _selectedEducationLevel;
  String? _childLeaveSchoolReason;
  final TextEditingController _otherLeaveReasonController =
      TextEditingController();
  String? _neverBeenToSchoolReason;
  final TextEditingController _otherNeverSchoolReasonController =
      TextEditingController();

  // ========== SCHOOL ATTENDANCE (7 DAYS) ==========
  bool? _attendedSchoolLast7Days;
  String? _selectedLeaveReason;
  final TextEditingController _otherAbsenceReasonController =
      TextEditingController();
  bool? _missedSchoolDays;
  String? _selectedMissedReason;
  final TextEditingController _otherMissedReasonController =
      TextEditingController();

  // ========== WORK INFORMATION (7 DAYS) ==========
  bool? _workedInHouse;
  bool? _workedOnCocoaFarm;
  String? _workFrequency;
  bool? _observedWorking;
  final Set<String> _cocoaFarmTasks = {};

  // ========== LIGHT TASKS (7 DAYS) ==========
  bool? _receivedRemuneration;
  String? _longestLightDutyTime;
  String? _longestNonSchoolDayTime;
  String? _taskLocation;
  final TextEditingController _otherLocationController =
      TextEditingController();
  final TextEditingController _schoolDayTaskDurationController =
      TextEditingController();
  final TextEditingController _nonSchoolDayHoursController =
      TextEditingController();
  bool? _wasSupervisedByAdult;

  // ========== LIGHT TASKS (12 MONTHS) ==========
  final Set<String> _tasksLast12Months = {};
  bool? _activityRemuneration;
  String? _schoolDayTaskDuration;
  String? _nonSchoolDayTaskDuration;
  String? _taskLocationType;
  String? _totalSchoolDayHours;
  String? _totalNonSchoolDayHours;
  bool? _wasSupervisedDuringTask;

  // ========== DANGEROUS TASKS (7 DAYS) ==========
  final Set<String> _cocoaFarmTasksLast7DaysDangerous = {};
  bool? _hasReceivedSalary;
  String? _taskDangerousLocation;
  final TextEditingController _otherLocationDangerousController =
      TextEditingController();
  String? _longestSchoolDayTimeDangerous;
  String? _longestNonSchoolDayTimeDangerous;
  final TextEditingController _schoolDayHoursDangerousController =
      TextEditingController();
  final TextEditingController _nonSchoolDayDangerousHoursController =
      TextEditingController();
  bool? _wasSupervisedByAdultDangerous;

  // ========== DANGEROUS TASKS (12 MONTHS) ==========
  final Set<String> _cocoaFarmTasksLast12Months = {};
  bool? _hasReceivedSalary12Months;
  String? _taskDangerousLocation12Months;
  final TextEditingController _otherLocationDangerousController12Months =
      TextEditingController();
  String? _longestSchoolDayTimeDangerous12Months;
  String? _longestNonSchoolDayTimeDangerous12Months;
  final TextEditingController _schoolDayHoursDangerousController12Months =
      TextEditingController();
  final TextEditingController _nonSchoolDayDangerousHoursController12Months =
      TextEditingController();
  bool? _wasSupervisedByAdultDangerous12Months;

  // ========== WORK DETAILS ==========
  String? _workForWhom;
  final TextEditingController _workForWhomOtherController =
      TextEditingController();
  final Set<String> _whyWorkReasons = {};
  final TextEditingController _whyWorkOtherController = TextEditingController();

  // ========== HEALTH AND SAFETY ==========
  bool? _appliedAgrochemicals;
  bool? _onFarmDuringApplication;
  bool? _sufferedInjury;
  final TextEditingController _howWoundedController = TextEditingController();
  final TextEditingController _whenWoundedController = TextEditingController();
  DateTime? _woundedDate;
  bool? _oftenFeelPains;
  final Set<String> _helpReceived = {};
  final TextEditingController _otherHelpController = TextEditingController();

  // ========== PHOTO CONSENT ==========
  bool? _parentConsentPhoto;
  final TextEditingController _noConsentReasonController =
      TextEditingController();
  File? _childPhoto;

  // ========== ADDITIONAL WORK HOURS CONTROLLERS ==========
  final TextEditingController _totalHoursWorkedController =
      TextEditingController();
  final TextEditingController _totalHoursWorkedControllerDangerous =
      TextEditingController();
  final TextEditingController _totalHoursWorkedControllerNonSchoolDangerous =
      TextEditingController();
  final TextEditingController _schoolDayHoursController =
      TextEditingController();

  // ========== LISTS AND CONSTANTS ==========
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

  final List<String> _sampleNames = [
    'Kwame',
    'Ama',
    'Kofi',
    'Adwoa',
    'Kwabena',
    'Abena',
    'Kwaku',
    'Akua',
    'Yaw',
    'Yaa',
    'Kweku',
    'Efua',
    'Kwadwo',
    'Akosua',
    'Kwasi',
    'Ama'
  ];

  final List<String> _sampleSurnames = [
    'Mensah',
    'Osei',
    'Agyemang',
    'Asare',
    'Boateng',
    'Ofori',
    'Owusu',
    'Acheampong',
    'Adu',
    'Agyei',
    'Amoah',
    'Appiah',
    'Asante',
    'Baffour',
    'Bonsu',
    'Danso',
    'Gyamfi'
  ];

  // ========== ABSENCE REASONS ==========
  final Map<String, bool> _absenceReasons = {
    'It was the holidays': false,
    'He/she was sick': false,
    'He/she was working': false,
    'He/she was traveling': false,
    'Other': false,
  };
  final TextEditingController _otherReasonForSchoolController =
      TextEditingController();

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

  Widget _buildArithmeticQuestion(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Text(
          'Right answer: $answer',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildReadingSentence(String sentence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sentence,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
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

  Widget _buildModernRadioGroup<T>({
    required String question,
    required T? groupValue,
    required List<Map<String, dynamic>> options,
    required ValueChanged<T?> onChanged,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,fontSize: 14
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: _Spacing.sm),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,fontSize: 13
            ),
          ),
        ],
        const SizedBox(height: _Spacing.md),
        ...options.map((option) => ModernRadioButton<T>(
              value: option['value'] as T,
              groupValue: groupValue,
              onChanged: onChanged,
              title: option['title'] as String,
              subtitle: option['subtitle'] as String?,
            )),
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
                fontWeight: FontWeight.w600,fontSize: 14
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],fontSize: 13
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
                fontWeight: FontWeight.w500,fontSize: 14   
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
    VoidCallback? onTap,
    String? hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,fontSize: 14
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
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
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

  void _submitForm() {
    // Allow form submission without validation
    final childData = {
      'childNumber': widget.childNumber,
      'schoolDayHours': _schoolDayTaskDurationController.text.trim(),
      'isFarmerChild': _isFarmerChild,
      'childListNumber': _childNumberController.text.trim(),
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
      'missedSchoolDays': _missedSchoolDays,
      'workedInHouse': _workedInHouse,
      'workedOnCocoaFarm': _workedOnCocoaFarm,
      'cocoaFarmTasks': _cocoaFarmTasks.toList(),
      'workFrequency': _workFrequency,
      'observedWorking': _observedWorking,
      'receivedRemuneration': _receivedRemuneration,
      'wasSupervisedByAdult': _wasSupervisedByAdult,
      'longestLightDutyTime': _longestLightDutyTime,
      'longestNonSchoolDayTime': _longestNonSchoolDayTime,
      'tasksLast12Months': _tasksLast12Months.toList(),
      'taskLocation': _taskLocation,
      'otherTaskLocation': _otherLocationController.text.trim(),
      'schoolDayHours': _schoolDayHoursController.text.trim(),

      // Light tasks 12 months fields
      'activityRemuneration': _activityRemuneration,
      'schoolDayTaskDuration': _schoolDayTaskDuration,
      'nonSchoolDayTaskDuration': _nonSchoolDayTaskDuration,
      'taskLocationType': _taskLocationType,
      'totalSchoolDayHours': _totalSchoolDayHours,
      'totalNonSchoolDayHours': _totalNonSchoolDayHours,
      'wasSupervisedDuringTask': _wasSupervisedDuringTask,

      // Work information
      'workForWhom': _workForWhom,
      'otherWorkForWhom': _workForWhomOtherController.text.trim(),
      'whyWorkReasons': _whyWorkReasons.toList(),
      'otherWhyWork': _whyWorkOtherController.text.trim(),

      // Health and safety
      'appliedAgrochemicals': _appliedAgrochemicals,
      'onFarmDuringApplication': _onFarmDuringApplication,
      'sufferedInjury': _sufferedInjury,
      'howWounded': _howWoundedController.text.trim(),
      'whenWounded': _whenWoundedController.text.trim(),
      'oftenFeelPains': _oftenFeelPains,
      'helpReceived': _helpReceived.toList(),
      'otherHelp': _otherHelpController.text.trim(),

      // Photo consent
      'parentConsentPhoto': _parentConsentPhoto,
      'noConsentReason': _noConsentReasonController.text.trim(),
      'childPhotoPath': _childPhoto?.path,

      // Dangerous tasks 7 days
      'cocoaFarmTasksLast7Days': _cocoaFarmTasksLast7DaysDangerous.toList(),
      'hasReceivedSalary': _hasReceivedSalary,
      'taskDangerousLocation': _taskDangerousLocation,
      'otherLocationDangerous': _otherLocationDangerousController.text.trim(),
      'longestSchoolDayTimeDangerous': _longestSchoolDayTimeDangerous,
      'longestNonSchoolDayTimeDangerous': _longestNonSchoolDayTimeDangerous,
      'schoolDayHoursDangerous': _schoolDayHoursDangerousController.text.trim(),
      'nonSchoolDayDangerousHours':
          _nonSchoolDayDangerousHoursController.text.trim(),
      'wasSupervisedByAdultDangerous': _wasSupervisedByAdultDangerous,

      // Dangerous tasks 12 months
      'cocoaFarmTasksLast12Months': _cocoaFarmTasksLast12Months.toList(),
      'hasReceivedSalary12Months': _hasReceivedSalary12Months,
      'taskDangerousLocation12Months': _taskDangerousLocation12Months,
      'otherLocationDangerous12Months':
          _otherLocationDangerousController12Months.text.trim(),
      'longestSchoolDayTimeDangerous12Months':
          _longestSchoolDayTimeDangerous12Months,
      'longestNonSchoolDayTimeDangerous12Months':
          _longestNonSchoolDayTimeDangerous12Months,
      'schoolDayHoursDangerous12Months':
          _schoolDayHoursDangerousController12Months.text.trim(),
      'nonSchoolDayDangerousHours12Months':
          _nonSchoolDayDangerousHoursController12Months.text.trim(),
      'wasSupervisedByAdultDangerous12Months':
          _wasSupervisedByAdultDangerous12Months,

      // Education details
      'selectedEducationLevel': _selectedEducationLevel,
      'childLeaveSchoolReason': _childLeaveSchoolReason,
      'otherLeaveReason': _otherLeaveReasonController.text.trim(),
      'neverBeenToSchoolReason': _neverBeenToSchoolReason,
      'otherNeverSchoolReason': _otherNeverSchoolReasonController.text.trim(),
      'selectedLeaveReason': _selectedLeaveReason,
      'otherAbsenceReason': _otherAbsenceReasonController.text.trim(),
      'selectedMissedReason': _selectedMissedReason,
      'otherMissedReason': _otherMissedReasonController.text.trim(),

      // Family decision information
      'whoDecidedChildJoin': _whoDecidedChildJoin,
      'otherPersonDecided': _otherPersonController.text.trim(),
      'lastContactWithParents': _lastContactWithParents,
    };

    Navigator.pop(context, childData);
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
    // Trigger a rebuild when the child number changes
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _childNumberController.addListener(_onChildNumberChanged);
  }

  @override
  void dispose() {
    _childNumberController.removeListener(_onChildNumberChanged);

    // Keep all existing disposals and add missing ones:
    _otherLocationController.dispose();
    _otherReasonController.dispose();
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

    _otherAccompaniedController.dispose();
    _schoolDayTaskDurationController.dispose();
    _nonSchoolDayHoursController.dispose();
    _howWoundedController.dispose();
    _whenWoundedController.dispose();
    _otherLeaveReasonController.dispose();
    _otherHelpController.dispose();
    _noConsentReasonController.dispose();
    _otherMissedReasonController.dispose();
    _otherNeverSchoolReasonController.dispose();
    _otherPersonController.dispose();

    _workForWhomOtherController.dispose();
    _whyWorkOtherController.dispose();
    _otherNotLivingWithFamilyController.dispose();

    // Dangerous tasks controllers (only one set):
    _otherLocationDangerousController.dispose();
    _schoolDayHoursDangerousController.dispose();
    _nonSchoolDayDangerousHoursController.dispose();
    _otherLocationDangerousController12Months.dispose();
    _schoolDayHoursDangerousController12Months.dispose();
    _nonSchoolDayDangerousHoursController12Months.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Child ${widget.childNumber} of ${widget.totalChildren}'),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ========== FARMER'S CHILDREN SECTION ==========
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

              // Child Number Input - Only show if child is among farmer's children
              if (_isFarmerChild == true) ...[
                _buildModernTextField(
                  label:
                      'Enter the number attached to the child name in the cover so we can identify the child in question:',
                  controller: _childNumberController,
                  keyboardType: TextInputType.number,
                  hintText: 'Enter child number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the child number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // ========== SURVEY AVAILABILITY ==========
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

                // Respondent information
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question:
                      'Who is answering for the child since he/she is not available?',
                  groupValue: _respondentType,
                  onChanged: (value) {
                    setState(() {
                      _respondentType = value;
                    });
                  },
                  options: [
                    {
                      'value': 'the_parents_or_legal_guardians',
                      'title': 'The parents or legal guardians'
                    },
                    {
                      'value': 'another_family_member',
                      'title': 'Another family member of the child'
                    },
                    {
                      'value': 'child_siblings',
                      'title': 'One of the child\'s siblings'
                    },
                    {'value': 'other', 'title': 'Other'},
                  ],
                ),

                if (_respondentType != null) ...[
                  const SizedBox(height: 16),
                  if (_respondentType == 'other') ...[
                    _buildModernTextField(
                      label: 'Please specify',
                      controller: _otherRespondentTypeController,
                      validator: (value) {
                        if (_respondentType == 'other' &&
                            (value == null || value.isEmpty)) {
                          return 'Please specify who is answering for the child';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ],

              // ========== PERSONAL INFORMATION SECTION ==========
              // Show child details if they can be surveyed OR if we're collecting info about unavailable children
              if (_canBeSurveyedNow == true || _canBeSurveyedNow == false) ...[
                _buildSectionHeader('PERSONAL INFORMATION'),

                // Show child's name fields only if not a farmer's child
                if (_isFarmerChild == false) ...[
                  _buildModernTextField(
                    label: 'Child\'s First Name:',
                    controller: _nameController,
                    hintText: 'Enter child\'s first name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the child\'s first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: 'Child\'s Surname:',
                    controller: _surnameController,
                    hintText: 'Enter child\'s surname',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the child\'s surname';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Child's Gender
                _buildModernRadioGroup<String>(
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
                _buildModernTextField(
                  label: 'Year of Birth:',
                  controller: _birthYearController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  hintText: 'Select year of birth',
                  validator: (value) {
                    if (_selectedDate == null) {
                      return 'Please select year of birth';
                    }
                    final birthYear = _selectedDate!.year;
                    if (birthYear < 2007 || birthYear > 2020) {
                      return 'Year of birth must be between 2007 and 2020';
                    }
                    return null;
                  },
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
                    validator: (value) {
                      if (_hasBirthCertificate == false &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please specify why the child does not have a birth certificate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Born in community
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question: 'Is the child born in this community?',
                  groupValue: _bornInCommunity == null
                      ? null
                      : _bornInCommunity!
                          ? 'same_community'
                          : _birthCountry == 'same_district'
                              ? 'same_district'
                              : _birthCountry == 'same_region'
                                  ? 'same_region'
                                  : _birthCountry == 'other_ghana_region'
                                      ? 'other_ghana_region'
                                      : 'other_country',
                  onChanged: (value) {
                    setState(() {
                      _bornInCommunity = value == 'same_community';
                      if (value == 'same_community') {
                        _birthCountry = null;
                      } else if (value == 'same_district') {
                        _birthCountry = 'same_district';
                      } else if (value == 'same_region') {
                        _birthCountry = 'same_region';
                      } else if (value == 'other_ghana_region') {
                        _birthCountry = 'other_ghana_region';
                      } else if (value == 'other_country') {
                        _birthCountry = 'other_country';
                      }
                    });
                  },
                  options: [
                    {'value': 'same_community', 'title': 'Yes'},
                    {
                      'value': 'same_district',
                      'title':
                          'No, he was born in this district but different community within the district'
                    },
                    {
                      'value': 'same_region',
                      'title':
                          'No, he was born in this region but different district within the region'
                    },
                    {
                      'value': 'other_ghana_region',
                      'title': 'No, he was born in another region of Ghana'
                    },
                    {
                      'value': 'other_country',
                      'title': 'No, he was born in another country'
                    },
                  ],
                ),

                // Country of birth (shown only if born in another country)
                if (_birthCountry == 'other_country') ...[
                  const SizedBox(height: 16),
                  _buildModernDropdown<String>(
                    label: 'In which country was the child born?',
                    value:
                        _birthCountry == 'other_country' ? null : _birthCountry,
                    items: _countries
                        .where((c) => c != 'Ghana')
                        .map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _birthCountry = newValue;
                      });
                    },
                    hintText: 'Select country',
                    validator: (value) {
                      if (_birthCountry == 'other_country' &&
                          (value == null || value.isEmpty)) {
                        return 'Please select the country of birth';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Relationship to head of household
                const SizedBox(height: 24),
                _buildModernDropdown<String>(
                  label:
                      'Relationship of the child to the head of the household',
                  value: _relationshipToHead,
                  items: [
                    'Son/daughter',
                    'Brother/Sister',
                    'Son-in-law/Daughter-in-law',
                    'Grandson/Granddaughter',
                    'Niece/nephew',
                    'Cousin',
                    'Child of the worker',
                    'Child of the farm owner',
                    'Other (please specify)'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _relationshipToHead = newValue;
                    });
                  },
                  hintText: 'Select relationship',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a relationship';
                    }
                    return null;
                  },
                ),

                if (_relationshipToHead == 'Other (please specify)') ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: 'If other please specify',
                    controller: _otherRelationshipController,
                    validator: (value) {
                      if (_relationshipToHead == 'Other (please specify)' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please specify the relationship';
                      }
                      return null;
                    },
                  ),
                ],

                // Show family living situation question if child is not a direct family member
                if (_relationshipToHead == 'Child of the worker' ||
                    _relationshipToHead == 'Child of the farm owner' ||
                    _relationshipToHead == 'Other (please specify)') ...[
                  const SizedBox(height: 16),
                  Text(
                    'Why does the child [${widget.childNumber}] not live with his/her family?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._notLivingWithFamilyReasons.entries.map((entry) {
                    return ModernCheckbox(
                      value: entry.value,
                      onChanged: (bool? selected) {
                        setState(() {
                          _notLivingWithFamilyReasons[entry.key] =
                              selected ?? false;
                        });
                      },
                      title: entry.key,
                    );
                  }).toList(),
                  if (_notLivingWithFamilyReasons['Other (specify)'] ==
                      true) ...[
                    const SizedBox(height: 8),
                    _buildModernTextField(
                      label: 'Other reason',
                      controller: _otherNotLivingWithFamilyController,
                      validator: (value) {
                        if (_notLivingWithFamilyReasons['Other (specify)'] ==
                                true &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Please specify the reason';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ],

              // ========== FAMILY DECISION SECTION ==========
              // Show these questions for non-farmer children
              if (_isFarmerChild == false) ...[
                _buildSectionHeader('FAMILY DECISION INFORMATION'),

                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question:
                      'Who decided that the child [${widget.childNumber}] should come into the household?',
                  groupValue: _whoDecidedChildJoin,
                  onChanged: (String? value) {
                    setState(() {
                      _whoDecidedChildJoin = value;
                    });
                  },
                  options: [
                    {'value': 'myself', 'title': 'Myself'},
                    {'value': 'father_mother', 'title': 'Father / Mother'},
                    {'value': 'grandparents', 'title': 'Grandparents'},
                    {'value': 'other_family', 'title': 'Other family members'},
                    {
                      'value': 'external_recruiter',
                      'title': 'An external recruiter or agency external'
                    },
                    {
                      'value': 'other_person',
                      'title': 'Other person (specify)'
                    },
                  ],
                ),

                // Show text field if "Other person" is selected
                if (_whoDecidedChildJoin == 'other_person') ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: 'Please specify other person',
                    controller: _otherPersonController,
                    validator: (value) {
                      if (_whoDecidedChildJoin == 'other_person' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please specify who decided';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // Child agreement question
                if (_whoDecidedChildJoin == 'father_mother' ||
                    _whoDecidedChildJoin == 'grandparents' ||
                    _whoDecidedChildJoin == 'other_family' ||
                    _whoDecidedChildJoin == 'external_recruiter' ||
                    _whoDecidedChildJoin == 'other_person') ...[
                  const SizedBox(height: 24),
                  _buildModernRadioGroup<bool>(
                    question:
                        'Did the child [${widget.childNumber}] agree with this decision?',
                    groupValue: _childAgreedWithDecision,
                    onChanged: (bool? value) {
                      setState(() {
                        _childAgreedWithDecision = value;
                      });
                    },
                    options: [
                      {'value': true, 'title': 'Yes'},
                      {'value': false, 'title': 'No'},
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Has the child seen/spoken with parents question
                const SizedBox(height: 24),
                _buildModernRadioGroup<bool>(
                  question:
                      'Has the child [${widget.childNumber}] seen and/or spoken with his/her parents in the past year?',
                  groupValue: _hasSpokenWithParents,
                  onChanged: (bool? value) {
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

                // Last contact with parents question
                if (_hasSpokenWithParents != null) ...[
                  const SizedBox(height: 24),
                  _buildModernRadioGroup<String>(
                    question:
                        'When was the last time the child saw and/or talked with mom and/or dad?',
                    groupValue: _lastContactWithParents,
                    onChanged: (String? value) {
                      setState(() {
                        _lastContactWithParents = value;
                      });
                    },
                    options: [
                      {'value': 'max_1_week', 'title': 'Max 1 week'},
                      {'value': 'max_1_month', 'title': 'Max 1 month'},
                      {'value': 'max_1_year', 'title': 'Max 1 year'},
                      {
                        'value': 'more_than_1_year',
                        'title': 'More than 1 year'
                      },
                      {'value': 'never', 'title': 'Never'},
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ],

              // ========== FAMILY INFORMATION SECTION ==========
              _buildSectionHeader('FAMILY INFORMATION'),

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
                  {'value': 'More than 8 years', 'title': 'More than 8 years'},
                  {'value': 'Don\'t know', 'title': 'Don\'t know'},
                ],
              ),
              const SizedBox(height: 16),

              // Who accompanied the child question - only for non-farmer children
              if (_isFarmerChild == false) ...[
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question:
                      'Who accompanied the child [${widget.childNumber}] to come here?',
                  groupValue: _whoAccompaniedChild,
                  onChanged: (String? value) {
                    setState(() {
                      _whoAccompaniedChild = value;
                    });
                  },
                  options: [
                    {'value': 'came_alone', 'title': 'Came alone'},
                    {'value': 'father_mother', 'title': 'Father / Mother'},
                    {'value': 'grandparents', 'title': 'Grandparents'},
                    {
                      'value': 'other_family_member',
                      'title': 'Other family member'
                    },
                    {'value': 'with_recruit', 'title': 'With a recruit'},
                    {'value': 'other', 'title': 'Other'},
                  ],
                ),

                // Show text field if "Other" is selected
                if (_whoAccompaniedChild == 'other') ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: 'Please specify who accompanied the child',
                    controller: _otherAccompaniedController,
                    validator: (value) {
                      if (_whoAccompaniedChild == 'other' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please specify who accompanied the child';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // ========== PARENT RESIDENCE SECTION ==========
              // Father's residence
              const SizedBox(height: 24),
              _buildModernRadioGroup<String>(
                question:
                    'Where does the child\'s father live [${widget.childNumber}]?',
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
                  validator: (value) {
                    if (_fatherResidence == 'Abroad' &&
                        (value == null || value.isEmpty)) {
                      return 'Please select a country';
                    }
                    return null;
                  },
                ),
                if (_fatherCountry == 'Others to be specified') ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: 'Please specify country',
                    controller: _otherFatherCountryController,
                    validator: (value) {
                      if (_fatherCountry == 'Others to be specified' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please specify the country';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Mother's residence
              const SizedBox(height: 24),
              _buildModernRadioGroup<String>(
                question:
                    'Where does the child\'s mother live [${widget.childNumber}]?',
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
                  validator: (value) {
                    if (_motherResidence == 'Abroad' &&
                        (value == null || value.isEmpty)) {
                      return 'Please select a country';
                    }
                    return null;
                  },
                ),
                if (_motherCountry == 'Others to be specified') ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: 'Please specify country',
                    controller: _otherMotherCountryController,
                    validator: (value) {
                      if (_motherCountry == 'Others to be specified' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please specify the country';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // ========== EDUCATION SECTION ==========
              // Only show education questions if child can be surveyed now
              if (_canBeSurveyedNow == true) ...[
                _buildSectionHeader('EDUCATION INFORMATION'),

                // School enrollment
                const SizedBox(height: 24),
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
                    validator: (value) {
                      if (_isCurrentlyEnrolled == true &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter the school name';
                      }
                      return null;
                    },
                  ),
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
                  ),
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
                    validator: (value) {
                      if (_isCurrentlyEnrolled == true && value == null) {
                        return 'Please select a grade level';
                      }
                      return null;
                    },
                  ),
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
                        value: _availableSchoolSupplies.contains('School bag'),
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
                        value:
                            _availableSchoolSupplies.contains('Pen / Pencils'),
                        onChanged: (bool? selected) {
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
                              _availableSchoolSupplies.add('None of the above');
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
                  const SizedBox(height: 16),
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
                        'subtitle': null
                      },
                      {
                        'value': false,
                        'title': 'No, they have never been to school',
                        'subtitle': null
                      },
                    ],
                  ),

                  // Additional sections for children who were enrolled but stopped
                  if (_hasEverBeenToSchool == true) ...[
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      label: 'When did the child leave school?',
                      controller: _leftSchoolDateController,
                      readOnly: true,
                      onTap: () => _selectLeftSchoolDate(context),
                      hintText: 'Select date',
                      validator: (value) {
                        if (_hasEverBeenToSchool == true &&
                            (value == null || value.isEmpty)) {
                          return 'Please select the date';
                        }
                        if (_leftSchoolDate != null) {
                          final birthYear = _selectedDate?.year;
                          final currentYear = DateTime.now().year;
                          final leftSchoolYear = _leftSchoolDate!.year;

                          if (birthYear != null &&
                              leftSchoolYear <= birthYear) {
                            return 'The year cannot be before the year of birth of the child';
                          }
                          if (leftSchoolYear > currentYear) {
                            return 'The year cannot be after the current year ($currentYear)';
                          }
                          if (birthYear != null &&
                              leftSchoolYear < birthYear + 4) {
                            return 'Check that the child was at least 4 years old when he/she left school';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModernRadioGroup<String>(
                      question:
                          'What is the education level of [${widget.childNumber}]?',
                      groupValue: _selectedEducationLevel,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedEducationLevel = value;
                        });
                      },
                      options: [
                        {
                          'value': 'pre_school',
                          'title': 'Pre-school (Kindergarten)'
                        },
                        {'value': 'primary', 'title': 'Primary'},
                        {'value': 'jss_middle', 'title': 'JSS/Middle school'},
                        {
                          'value': 'sss_olevel',
                          'title':
                              'SSS/\'O\'-level/\'A\'-level (including vocational & technical training)'
                        },
                        {
                          'value': 'university',
                          'title': 'University or higher'
                        },
                        {'value': 'not_applicable', 'title': 'Not applicable'},
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildModernRadioGroup<String>(
                      question:
                          'What is the main reason for the child [${widget.childNumber}] leaving school?',
                      groupValue: _childLeaveSchoolReason,
                      onChanged: (String? value) {
                        setState(() {
                          _childLeaveSchoolReason = value;
                        });
                      },
                      options: [
                        {
                          'value': 'school_too_far',
                          'title': 'The school is too far away'
                        },
                        {
                          'value': 'tuition_fees_high',
                          'title': 'Tuition fees for private school too high'
                        },
                        {
                          'value': 'poor_academic_performance',
                          'title': 'Poor academic performance'
                        },
                        {
                          'value': 'insecurity',
                          'title': 'Insecurity in the area'
                        },
                        {'value': 'learn_trade', 'title': 'To learn a trade'},
                        {
                          'value': 'early_pregnancy',
                          'title': 'Early pregnancy'
                        },
                        {
                          'value': 'child_not_want',
                          'title':
                              'The child did not want to go to school anymore'
                        },
                        {
                          'value': 'cant_afford_materials',
                          'title':
                              'Parents can\'t afford Teaching and Learning Materials'
                        },
                        {'value': 'other', 'title': 'Other'},
                        {'value': 'does_not_know', 'title': 'Does not know'},
                      ],
                    ),
                    if (_childLeaveSchoolReason == 'other') ...[
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Please specify reason',
                        controller: _otherLeaveReasonController,
                        validator: (value) {
                          if (_childLeaveSchoolReason == 'other' &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Please specify the reason';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],

                  // Never been to school section
                  if (_hasEverBeenToSchool == false) ...[
                    const SizedBox(height: 16),
                    _buildModernRadioGroup<String>(
                      question:
                          'Why has the child [${widget.childNumber}] never been to school before?',
                      groupValue: _neverBeenToSchoolReason,
                      onChanged: (String? value) {
                        setState(() {
                          _neverBeenToSchoolReason = value;
                        });
                      },
                      options: [
                        {
                          'value': 'school_too_far',
                          'title': 'The school is too far away'
                        },
                        {
                          'value': 'tuition_fees_high',
                          'title': 'Tuition fees too high'
                        },
                        {
                          'value': 'too_young',
                          'title': 'Too young to be in school'
                        },
                        {
                          'value': 'insecurity',
                          'title': 'Insecurity in the region'
                        },
                        {
                          'value': 'learn_trade',
                          'title': 'To learn a trade (apprenticeship)'
                        },
                        {
                          'value': 'child_not_want',
                          'title': 'The child doesn\'t want to go to school'
                        },
                        {
                          'value': 'cant_afford_materials',
                          'title':
                              'Parents can\'t afford TLMs and/or enrollment fees'
                        },
                        {'value': 'other', 'title': 'Other'},
                      ],
                    ),
                    if (_neverBeenToSchoolReason == 'other') ...[
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Please specify reason',
                        controller: _otherNeverSchoolReasonController,
                        validator: (value) {
                          if (_neverBeenToSchoolReason == 'other' &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Please specify the reason';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ],

                // ========== SCHOOL ATTENDANCE (7 DAYS) ==========
                // Only show if child is currently enrolled
                if (_isCurrentlyEnrolled == true) ...[
                  const SizedBox(height: 24),
                  _buildModernRadioGroup<bool>(
                    question:
                        'Has the child been to school in the past 7 days?',
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
                  if (_attendedSchoolLast7Days == false) ...[
                    const SizedBox(height: 24),
                    _buildModernRadioGroup<String>(
                      question: 'Why has the child not been to school?',
                      groupValue: _selectedLeaveReason,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedLeaveReason = value;
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
                    if (_selectedLeaveReason == 'other') ...[
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Please specify reason',
                        controller: _otherAbsenceReasonController,
                        validator: (value) {
                          if (_selectedLeaveReason == 'other' &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Please specify the reason';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 24),
                  _buildModernRadioGroup<bool>(
                    question:
                        'Has the child [${widget.childNumber}] missed school days the past 7 days?',
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
                    const SizedBox(height: 24),
                    _buildModernRadioGroup<String>(
                      question: 'Why did the child miss school?',
                      groupValue: _selectedMissedReason,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedMissedReason = value;
                        });
                      },
                      options: [
                        {'value': 'sick', 'title': 'He/she was sick'},
                        {'value': 'working', 'title': 'He/she was working'},
                        {'value': 'traveled', 'title': 'He/she traveled'},
                        {'value': 'other', 'title': 'Other'},
                      ],
                    ),
                    if (_selectedMissedReason == 'other') ...[
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Please specify reason',
                        controller: _otherMissedReasonController,
                        validator: (value) {
                          if (_selectedMissedReason == 'other' &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Please specify the reason';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ],

                // ========== ARITHMETIC AND READING ASSESSMENT ==========
                // Only show for children who can be surveyed and have education history
                Builder(
                  builder: (context) {
                    final childAge = _selectedDate != null
                        ? DateTime.now().year - _selectedDate!.year
                        : null;
                    final showAssessment = childAge != null &&
                        _canBeSurveyedNow == true &&
                        (_isCurrentlyEnrolled == true ||
                            (_isCurrentlyEnrolled == false &&
                                _hasEverBeenToSchool == true));

                    if (showAssessment) {
                      return Column(
                        children: [
                          // Arithmetic Assessment
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Arithmetic Assessment',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color:
                                              Theme.of(context).primaryColor)),
                                  const SizedBox(height: 12),
                                  // Add arithmetic questions based on age...
                                  const Text('Reference Examples:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  const Wrap(
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        _ArithmeticItem(
                                            expression: '1 + 2 = 3'),
                                        _ArithmeticItem(
                                            expression: '2 + 3 = 5'),
                                        _ArithmeticItem(
                                            expression: '5 - 3 = 2'),
                                        _ArithmeticItem(
                                            expression: '9 - 4 = 5'),
                                        _ArithmeticItem(
                                            expression: '9 + 7 = 16'),
                                        _ArithmeticItem(
                                            expression: '3 × 7 = 21'),
                                      ]),
                                ],
                              ),
                            ),
                          ),

                          // Reading Assessment
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Reading Assessment',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color:
                                              Theme.of(context).primaryColor)),
                                  const SizedBox(height: 12),
                                  // Add reading sentences based on age...
                                  const Text('All Reference Sentences:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('1. "This is Ama"'),
                                        Text('2. "It is water"'),
                                        Text(
                                            '3. "I like to play with my friends"'),
                                        Text('4. "I am going to school"'),
                                        Text('5. "Kofi is crying loudly"'),
                                        Text(
                                            '6. "I am good at playing both Basketball and football"'),
                                      ]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],

              // ========== WORK INFORMATION SECTION ==========
              // Only show work questions if child can be surveyed
              if (_canBeSurveyedNow == true) ...[
                _buildSectionHeader('WORK INFORMATION'),

                // Work in house
                const SizedBox(height: 24),
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

                // Work on cocoa farm
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

                // Continue with the rest of your work-related questions...
                // [Add LIGHT TASKS, DANGEROUS TASKS, WORK DETAILS sections here following the same pattern]
              ],

              // ========== HEALTH AND SAFETY SECTION ==========
              _buildSectionHeader('HEALTH AND SAFETY'),

              // Health questions (show for all children)
              const SizedBox(height: 24),
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

              // Continue with other health questions...

              // ========== PHOTO CONSENT SECTION ==========
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

              // // ========== NAVIGATION BUTTONS ==========
              // const SizedBox(height: 32),
              // Row(
              //   children: [
              //     // Previous button
              //     Expanded(
              //       child: Container(
              //         height: 56,
              //         decoration: BoxDecoration(
              //           border:
              //               Border.all(color: Theme.of(context).primaryColor),
              //           borderRadius: BorderRadius.circular(16),
              //         ),
              //         child: Material(
              //           color: Colors.transparent,
              //           child: InkWell(
              //             onTap: () {
              //               Navigator.pop(context);
              //             },
              //             borderRadius: BorderRadius.circular(16),
              //             child: Center(
              //               child: Text('PREVIOUS',
              //                   style: TextStyle(
              //                       color: Theme.of(context).primaryColor,
              //                       fontSize: 16,
              //                       fontWeight: FontWeight.w600,
              //                       letterSpacing: 0.5)),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     // Next button
              //     Expanded(
              //       child: Container(
              //         height: 56,
              //         decoration: BoxDecoration(
              //           gradient: LinearGradient(
              //               colors: [
              //                 Theme.of(context).primaryColor,
              //                 Theme.of(context).primaryColor.withOpacity(0.8)
              //               ],
              //               begin: Alignment.topLeft,
              //               end: Alignment.bottomRight),
              //           borderRadius: BorderRadius.circular(16),
              //           boxShadow: [
              //             BoxShadow(
              //                 color: Theme.of(context)
              //                     .primaryColor
              //                     .withOpacity(0.3),
              //                 blurRadius: 10,
              //                 offset: const Offset(0, 4))
              //           ],
              //         ),
              //         child: Material(
              //           color: Colors.transparent,
              //           child: InkWell(
              //             onTap: () {
              //               if (_formKey.currentState?.validate() ?? false) {
              //                 _submitForm();
              //                 Navigator.push(
              //                     context,
              //                     MaterialPageRoute(
              //                         builder: (context) =>
              //                             const SensitizationPage()));
              //               }
              //             },
              //             borderRadius: BorderRadius.circular(16),
              //             child: const Center(
              //                 child: Text('NEXT',
              //                     style: TextStyle(
              //                         color: Colors.white,
              //                         fontSize: 16,
              //                         fontWeight: FontWeight.w600,
              //                         letterSpacing: 0.5))),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
