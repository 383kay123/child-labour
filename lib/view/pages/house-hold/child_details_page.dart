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
                          fontSize: 16,
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

  const ChildDetailsPage({
    Key? key,
    required this.childNumber,
    required this.totalChildren,
    required this.childrenDetails,
  }) : super(key: key);

  @override
  _ChildDetailsPageState createState() => _ChildDetailsPageState();
}

class _ChildDetailsPageState extends State<ChildDetailsPage> {
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
  bool? _wasSupervisedByAdultDangerous;
  bool? _receivedSalaryForTasks;
  String? _longestSchoolDayTimeDangerous;
  String? _longestNonSchoolDayTimeDangerous;
  final TextEditingController _totalHoursWorkedControllerDangerous =
      TextEditingController();
  final TextEditingController _totalHoursWorkedControllerNonSchoolDangerous =
      TextEditingController();
  String? _whereTaskDone;
  final TextEditingController _otherLocationController =
      TextEditingController();
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
  String? _selectedSchoolDayTime;
  bool? _workedOnCocoaFarm;
  String? _workFrequency;
  bool? _observedWorking;
  bool? _receivedRemuneration;
  bool? _activityRemuneration;
  bool? _wasSupervisedByAdult;
  String? _longestLightDutyTime;
  String? _longestNonSchoolDayTime;
  String? _taskLocation;
  String? _schoolDayTaskDuration;
  String? _nonSchoolDayTaskDuration;
  String? _taskLocationType;
  String? _totalSchoolDayHours;
  String? _totalNonSchoolDayHours;
  bool? _wasSupervisedDuringTask;
  final Set<String> _cocoaFarmTasksLast7Days = {};
  bool? _hasReceivedSalary;
  final TextEditingController _schoolDayTaskDurationController =
      TextEditingController();
  final Set<String> _cocoaFarmTasks = {};
  final Set<String> _tasksLast12Months = {};
  final Map<String, bool> _absenceReasons = {
    'It was the holidays': false,
    'He/she was sick': false,
    'He/she was working': false,
    'He/she was traveling': false,
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

  final List<String> _surveyNotPossibleReasons = [];
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

  Widget _buildModernRadioGroup<T>({
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
        const SizedBox(height: 12),
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
    if (_formKey.currentState!.validate()) {
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
        'parentConsentPhoto': _parentConsentPhoto,
        'childPhotoPath': _childPhoto?.path,
      };

      Navigator.pop(context, childData);
    }
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
    _otherNotWithFamilyController.dispose();
    _otherAccompaniedController.dispose();
    _otherLocationController.dispose();
    _schoolDayTaskDurationController.dispose();
    _nonSchoolDayHoursController.dispose();
    _howWoundedController.dispose();
    _whenWoundedController.dispose();
    _otherHelpController.dispose();
    _noConsentReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child ${widget.childNumber} of ${widget.totalChildren}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child number';
                  }
                  return null;
                },
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

              // Show child details if they can be surveyed or if we're collecting info about them
              if (_canBeSurveyedNow == true || _canBeSurveyedNow == false) ...[
                _buildSectionHeader('PERSONAL INFORMATION'),

                // Child's basic information
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

                // Child's Gender
                _buildModernRadioGroup<String>(
                  question: 'Child\'s Gender:',
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
                _buildModernRadioGroup<bool>(
                  question: 'Was the child born in this community?',
                  groupValue: _bornInCommunity,
                  onChanged: (value) {
                    setState(() {
                      _bornInCommunity = value;
                    });
                  },
                  options: [
                    {'value': true, 'title': 'Yes'},
                    {'value': false, 'title': 'No'},
                  ],
                ),

                // Country of birth (shown only if not born in this community)
                if (_bornInCommunity == false) ...[
                  const SizedBox(height: 24),
                  _buildModernDropdown<String>(
                    label: 'In which country was the child born?',
                    value: _birthCountry,
                    items: _countries.map((String country) {
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
                      if (_bornInCommunity == false &&
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
                    label: 'Please specify relationship',
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

                // Family Information Section
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
                    {
                      'value': 'More than 8 years',
                      'title': 'More than 8 years'
                    },
                    {'value': 'Don\'t know', 'title': 'Don\'t know'},
                  ],
                ),
                const SizedBox(height: 16),

                // Father's residence
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
                const SizedBox(height: 24),

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
                const SizedBox(height: 24),

                // Education Section
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
                    validator: (value) {
                      if (_isCurrentlyEnrolled == true &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter the school name';
                      }
                      return null;
                    },
                  ),
                ],
                if (_isCurrentlyEnrolled == true &&
                    _schoolNameController.text.trim().isNotEmpty) ...[
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
                    validator: (value) {
                      if (_isCurrentlyEnrolled == true && value == null) {
                        return 'Please select a grade level';
                      }
                      return null;
                    },
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
                  ), // <-- Changed from ], to ),
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
                    ], // <-- This is the closing bracket for options
                  ),

                  // Additional sections for children who were enrolled but stopped
                  if (_hasEverBeenToSchool == true) ...[
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      label: 'When did the child leave school?',
                      controller: _leftSchoolYearController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (_hasEverBeenToSchool == true &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter the year';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      label: 'Or select exact date:',
                      controller: _leftSchoolDateController,
                      readOnly: true,
                      onTap: () => _selectLeftSchoolDate(context),
                      hintText: 'Select date',
                      validator: (value) {
                        if (_hasEverBeenToSchool == true &&
                            (value == null || value.isEmpty)) {
                          return 'Please select the date';
                        }
                        return null;
                      },
                    ),

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
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
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

                    // School attendance in past 7 days
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
                        question: 'Why has the child missed school days?',
                        values: _absenceReasons,
                        onChanged: (String reason, bool? selected) {
                          setState(() {
                            _absenceReasons[reason] = selected ?? false;
                          });
                        },
                      ),
                    ],
                  ],
                ],

                // Work Section
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

                // LIGHT TASKS Section
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
                  question:
                      'Did the child receive remuneration for light tasks?',
                  groupValue: _receivedRemuneration,
                  onChanged: (value) {
                    setState(() {
                      _receivedRemuneration = value;
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
                  groupValue: _longestLightDutyTime,
                  onChanged: (String? value) {
                    setState(() {
                      _longestLightDutyTime = value;
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
                  groupValue: _longestNonSchoolDayTime,
                  onChanged: (String? value) {
                    setState(() {
                      _longestNonSchoolDayTime = value;
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
                  groupValue: _wasSupervisedByAdult,
                  onChanged: (value) {
                    setState(() {
                      _wasSupervisedByAdult = value;
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
                  groupValue: _taskLocation,
                  onChanged: (String? value) {
                    setState(() {
                      _taskLocation = value;
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

                if (_taskLocation == 'Other') ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: 'Please specify',
                    controller: _otherLocationController,
                  ),
                ],

                // Total hours on school days for light tasks
                const SizedBox(height: 24),
                _buildModernTextField(
                  label:
                      'How many hours in total did the child spend on light tasks during SCHOOL DAYS in the past 7 days?',
                  controller: _schoolDayTaskDurationController,
                  keyboardType: TextInputType.number,
                  hintText: 'Enter hours (0-1016)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of hours';
                    }
                    final hours = int.tryParse(value);
                    if (hours == null || hours < 0 || hours > 1016) {
                      return 'Please enter a number between 0 and 1016';
                    }
                    return null;
                  },
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

                // LIGHT TASK (12 MONTHS) Section
                _buildSectionHeader('LIGHT TASK (12 MONTHS)'),

                // Activity remuneration question for 12 months
                _buildModernRadioGroup<bool>(
                  question:
                      'Did the child receive any remuneration for light tasks in the past 12 months?',
                  groupValue: _activityRemuneration,
                  onChanged: (bool? value) {
                    setState(() {
                      _activityRemuneration = value;
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
                  question:
                      'What was the longest time spent on light tasks during a SCHOOL DAY in the past 12 months?',
                  groupValue: _schoolDayTaskDuration,
                  onChanged: (String? value) {
                    setState(() {
                      _schoolDayTaskDuration = value;
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

                // Non-school day task duration question for 12 months
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question:
                      'What was the longest time spent on light tasks on a NON-SCHOOL DAY in the past 12 months?',
                  groupValue: _nonSchoolDayTaskDuration,
                  onChanged: (String? value) {
                    setState(() {
                      _nonSchoolDayTaskDuration = value;
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
                  ],
                ),

                // Task location question for 12 months
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question:
                      'Where were the light tasks done in the past 12 months?',
                  groupValue: _taskLocationType,
                  onChanged: (String? value) {
                    setState(() {
                      _taskLocationType = value;
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

                // Total hours on school days question for 12 months
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question:
                      'How many hours in total did the child spend on light tasks during SCHOOL DAYS in the past 12 months?',
                  groupValue: _totalSchoolDayHours,
                  onChanged: (String? value) {
                    setState(() {
                      _totalSchoolDayHours = value;
                    });
                  },
                  options: [
                    {'value': 'Less than 1 hour', 'title': 'Less than 1 hour'},
                    {'value': '1-2 hours', 'title': '1-2 hours'},
                    {'value': '2-4 hours', 'title': '2-4 hours'},
                    {'value': '4-6 hours', 'title': '4-6 hours'},
                    {'value': '6-8 hours', 'title': '6-8 hours'},
                    {
                      'value': 'More than 8 hours',
                      'title': 'More than 8 hours'
                    },
                    {'value': 'Not applicable', 'title': 'Not applicable'},
                  ],
                ),

                // Total hours on non-school days question for 12 months
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question:
                      'How many hours in total did the child spend on light tasks during NON-SCHOOL DAYS in the past 12 months?',
                  groupValue: _totalNonSchoolDayHours,
                  onChanged: (String? value) {
                    setState(() {
                      _totalNonSchoolDayHours = value;
                    });
                  },
                  options: [
                    {'value': 'Less than 1 hour', 'title': 'Less than 1 hour'},
                    {'value': '1-2 hours', 'title': '1-2 hours'},
                    {'value': '2-4 hours', 'title': '2-4 hours'},
                    {'value': '4-6 hours', 'title': '4-6 hours'},
                    {'value': '6-8 hours', 'title': '6-8 hours'},
                    {
                      'value': 'More than 8 hours',
                      'title': 'More than 8 hours'
                    },
                    {'value': 'Not applicable', 'title': 'Not applicable'},
                  ],
                ),

                // Adult supervision question for 12 months
                const SizedBox(height: 24),
                _buildModernRadioGroup<bool>(
                  question:
                      'Was the child under supervision of an adult when performing light tasks in the past 12 months?',
                  groupValue: _wasSupervisedDuringTask,
                  onChanged: (bool? value) {
                    setState(() {
                      _wasSupervisedDuringTask = value;
                    });
                  },
                  options: [
                    {'value': true, 'title': 'Yes'},
                    {'value': false, 'title': 'No'},
                  ],
                ),

                // DANGEROUS TASKS Section
                _buildSectionHeader('DANGEROUS TASKS (7 DAYS)'),

                // Cocoa farm tasks question for dangerous tasks (7 days)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Which of the following DANGEROUS tasks has the child [${widget.childNumber}] done in the last 7 days on the cocoa farm?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days.contains(
                              'Use of machetes for weeding or pruning (Clearing)'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days.add(
                                    'Use of machetes for weeding or pruning (Clearing)');
                              } else {
                                _cocoaFarmTasksLast7Days.remove(
                                    'Use of machetes for weeding or pruning (Clearing)');
                              }
                            });
                          },
                          title:
                              'Use of machetes for weeding or pruning (Clearing)',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days
                              .contains('Felling of trees'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days
                                    .add('Felling of trees');
                              } else {
                                _cocoaFarmTasksLast7Days
                                    .remove('Felling of trees');
                              }
                            });
                          },
                          title: 'Felling of trees',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days
                              .contains('Burning of plots'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days
                                    .add('Burning of plots');
                              } else {
                                _cocoaFarmTasksLast7Days
                                    .remove('Burning of plots');
                              }
                            });
                          },
                          title: 'Burning of plots',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days
                              .contains('Game hunting with a weapon'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days
                                    .add('Game hunting with a weapon');
                              } else {
                                _cocoaFarmTasksLast7Days
                                    .remove('Game hunting with a weapon');
                              }
                            });
                          },
                          title: 'Game hunting with a weapon',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days
                              .contains('Woodcutter\'s work'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days
                                    .add('Woodcutter\'s work');
                              } else {
                                _cocoaFarmTasksLast7Days
                                    .remove('Woodcutter\'s work');
                              }
                            });
                          },
                          title: 'Woodcutter\'s work',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days
                              .contains('Charcoal production'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days
                                    .add('Charcoal production');
                              } else {
                                _cocoaFarmTasksLast7Days
                                    .remove('Charcoal production');
                              }
                            });
                          },
                          title: 'Charcoal production',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days
                              .contains('Stump removal'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days.add('Stump removal');
                              } else {
                                _cocoaFarmTasksLast7Days
                                    .remove('Stump removal');
                              }
                            });
                          },
                          title: 'Stump removal',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days
                              .contains('Digging holes'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days.add('Digging holes');
                              } else {
                                _cocoaFarmTasksLast7Days
                                    .remove('Digging holes');
                              }
                            });
                          },
                          title: 'Digging holes',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days.contains(
                              'Working with a machete or any other sharp tool'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days.add(
                                    'Working with a machete or any other sharp tool');
                              } else {
                                _cocoaFarmTasksLast7Days.remove(
                                    'Working with a machete or any other sharp tool');
                              }
                            });
                          },
                          title:
                              'Working with a machete or any other sharp tool',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days
                              .contains('Handling of agrochemicals'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days
                                    .add('Handling of agrochemicals');
                              } else {
                                _cocoaFarmTasksLast7Days
                                    .remove('Handling of agrochemicals');
                              }
                            });
                          },
                          title: 'Handling of agrochemicals',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days
                              .contains('Driving motorized vehicles'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days
                                    .add('Driving motorized vehicles');
                              } else {
                                _cocoaFarmTasksLast7Days
                                    .remove('Driving motorized vehicles');
                              }
                            });
                          },
                          title: 'Driving motorized vehicles',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days.contains(
                              'Carrying heavy loads (Boys: 14-16 years old>15kg /16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days.add(
                                    'Carrying heavy loads (Boys: 14-16 years old>15kg /16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)');
                              } else {
                                _cocoaFarmTasksLast7Days.remove(
                                    'Carrying heavy loads (Boys: 14-16 years old>15kg /16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)');
                              }
                            });
                          },
                          title:
                              'Carrying heavy loads (Boys: 14-16 years old>15kg /16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days.contains(
                              'Night work on farm (between 6pm and 6am)'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days.add(
                                    'Night work on farm (between 6pm and 6am)');
                              } else {
                                _cocoaFarmTasksLast7Days.remove(
                                    'Night work on farm (between 6pm and 6am)');
                              }
                            });
                          },
                          title: 'Night work on farm (between 6pm and 6am)',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast7Days
                              .contains('None of the above'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast7Days.clear();
                                _cocoaFarmTasksLast7Days
                                    .add('None of the above');
                              } else {
                                _cocoaFarmTasksLast7Days
                                    .remove('None of the above');
                              }
                            });
                          },
                          title: 'None of the above',
                        ),
                      ],
                    ),
                  ],
                ),

                // Salary question for dangerous tasks (7 days)
                const SizedBox(height: 24),
                _buildModernRadioGroup<bool>(
                  question:
                      'Has the child [${widget.childNumber}] received a salary for DANGEROUS tasks in the last 7 days?',
                  groupValue: _hasReceivedSalary,
                  onChanged: (bool? value) {
                    setState(() {
                      _hasReceivedSalary = value;
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
                  question:
                      'Where were the DANGEROUS tasks done in the last 7 days?',
                  groupValue: _taskLocationType,
                  onChanged: (String? value) {
                    setState(() {
                      _taskLocationType = value;
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

                if (_taskLocationType == 'Other') ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: 'Please specify',
                    controller: _otherLocationController,
                  ),
                ],

                // Longest time spent on dangerous task during school day (7 days)
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question:
                      'What was the longest time spent on DANGEROUS tasks during a SCHOOL DAY in the last 7 days?',
                  groupValue: _longestSchoolDayTime,
                  onChanged: (String? value) {
                    setState(() {
                      _longestSchoolDayTime = value;
                    });
                  },
                  options: [
                    {
                      'value': 'Less than one hour',
                      'title': 'Less than one hour'
                    },
                    {'value': '1 hour', 'title': '1 hour'},
                    {'value': '2 hours', 'title': '2 hours'},
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

                // Longest time spent on dangerous task during non-school day (7 days)
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question:
                      'What was the longest time spent on DANGEROUS tasks during a NON-SCHOOL DAY in the last 7 days?',
                  groupValue: _longestNonSchoolDayTime,
                  onChanged: (String? value) {
                    setState(() {
                      _longestNonSchoolDayTime = value;
                    });
                  },
                  options: [
                    {
                      'value': 'Less than one hour',
                      'title': 'Less than one hour'
                    },
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

                // School day hours input for dangerous tasks (7 days)
                const SizedBox(height: 24),
                _buildModernTextField(
                  label:
                      'How many hours has the child worked on DANGEROUS tasks during SCHOOL DAYS in the last 7 days?',
                  controller: _schoolDayHoursDangerousController,
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
                  label:
                      'How many hours has the child worked on DANGEROUS tasks during NON-SCHOOL DAYS in the last 7 days?',
                  controller: _nonSchoolDayHoursController,
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
                  question:
                      'Was the child under supervision of an adult when performing DANGEROUS tasks?',
                  groupValue: _wasSupervisedByAdult,
                  onChanged: (bool? value) {
                    setState(() {
                      _wasSupervisedByAdult = value;
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
                      validator: (value) {
                        if (_workForWhom == 'other' &&
                            (value == null || value.isEmpty)) {
                          return 'Please specify for whom the child works';
                        }
                        return null;
                      },
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
                              validator: (value) {
                                if (_whyWorkReasons.contains('other') &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please specify the reason';
                                }
                                return null;
                              },
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
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months.contains(
                              'Use of machetes for weeding or pruning (Clearing)'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months.add(
                                    'Use of machetes for weeding or pruning (Clearing)');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months.remove(
                                    'Use of machetes for weeding or pruning (Clearing)');
                              }
                            });
                          },
                          title:
                              'Use of machetes for weeding or pruning (Clearing)',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months
                              .contains('Felling of trees'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months
                                    .add('Felling of trees');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months
                                    .remove('Felling of trees');
                              }
                            });
                          },
                          title: 'Felling of trees',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months
                              .contains('Burning of plots'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months
                                    .add('Burning of plots');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months
                                    .remove('Burning of plots');
                              }
                            });
                          },
                          title: 'Burning of plots',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months
                              .contains('Game hunting with a weapon'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months
                                    .add('Game hunting with a weapon');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months
                                    .remove('Game hunting with a weapon');
                              }
                            });
                          },
                          title: 'Game hunting with a weapon',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months
                              .contains('Woodcutter\'s work'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months
                                    .add('Woodcutter\'s work');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months
                                    .remove('Woodcutter\'s work');
                              }
                            });
                          },
                          title: 'Woodcutter\'s work',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months
                              .contains('Charcoal production'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months
                                    .add('Charcoal production');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months
                                    .remove('Charcoal production');
                              }
                            });
                          },
                          title: 'Charcoal production',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months
                              .contains('Stump removal'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months
                                    .add('Stump removal');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months
                                    .remove('Stump removal');
                              }
                            });
                          },
                          title: 'Stump removal',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months
                              .contains('Digging holes'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months
                                    .add('Digging holes');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months
                                    .remove('Digging holes');
                              }
                            });
                          },
                          title: 'Digging holes',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months.contains(
                              'Working with a machete or any other sharp tool'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months.add(
                                    'Working with a machete or any other sharp tool');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months.remove(
                                    'Working with a machete or any other sharp tool');
                              }
                            });
                          },
                          title:
                              'Working with a machete or any other sharp tool',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months
                              .contains('Handling of agrochemicals'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months
                                    .add('Handling of agrochemicals');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months
                                    .remove('Handling of agrochemicals');
                              }
                            });
                          },
                          title: 'Handling of agrochemicals',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months
                              .contains('Driving motorized vehicles'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months
                                    .add('Driving motorized vehicles');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months
                                    .remove('Driving motorized vehicles');
                              }
                            });
                          },
                          title: 'Driving motorized vehicles',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months.contains(
                              'Carrying heavy loads (Boys: 14-16 years old>15kg / 16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months.add(
                                    'Carrying heavy loads (Boys: 14-16 years old>15kg / 16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months.remove(
                                    'Carrying heavy loads (Boys: 14-16 years old>15kg / 16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)');
                              }
                            });
                          },
                          title:
                              'Carrying heavy loads (Boys: 14-16 years old>15kg / 16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months.contains(
                              'Night work on farm (between 6pm and 6am)'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months.add(
                                    'Night work on farm (between 6pm and 6am)');
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months.remove(
                                    'Night work on farm (between 6pm and 6am)');
                              }
                            });
                          },
                          title: 'Night work on farm (between 6pm and 6am)',
                        ),
                        ModernCheckbox(
                          value: _cocoaFarmTasksLast12Months
                              .contains('None of the above'),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _cocoaFarmTasksLast12Months.clear();
                                _cocoaFarmTasksLast12Months
                                    .add('None of the above');
                              } else {
                                _cocoaFarmTasksLast12Months
                                    .remove('None of the above');
                              }
                            });
                          },
                          title: 'None of the above',
                        ),
                      ],
                    ),
                  ],
                ),
                // DANGEROUS TASKS (12 MONTHS) Section
                _buildSectionHeader('DANGEROUS TASKS (12 MONTHS)'),

                // Salary question for dangerous tasks (12 months)
                const SizedBox(height: 24),
                _buildModernRadioGroup<bool>(
                  question:
                      'Has the child [${widget.childNumber}] received a salary for DANGEROUS tasks in the past 12 months?',
                  groupValue: _receivedSalaryForTasks,
                  onChanged: (bool? value) {
                    setState(() {
                      _receivedSalaryForTasks = value;
                    });
                  },
                  options: [
                    {'value': true, 'title': 'Yes'},
                    {'value': false, 'title': 'No'},
                  ],
                ),
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  question: 'Where was this task done?',
                  groupValue: _whereTaskDone,
                  onChanged: (String? value) {
                    setState(() {
                      _whereTaskDone = value;
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
                if (_whereTaskDone == 'Other') ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: 'Please specify',
                    controller:
                        _otherLocationController, // Make sure you have this controller defined
                    validator: (value) {
                      if (_whereTaskDone == 'Other' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please specify where the task was done';
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(
                  height: 24,
                ),
                _buildModernRadioGroup<String>(
                  question:
                      'What was the longest time spent on the task during a SCHOOL DAY in the last 7 days?',
                  groupValue: _longestSchoolDayTimeDangerous,
                  onChanged: (String? value) {
                    setState(() {
                      _longestSchoolDayTimeDangerous = value;
                    });
                  },
                  options: [
                    {
                      'value': 'Less than one hour',
                      'title': 'Less than one hour'
                    },
                    {'value': '1 hour', 'title': '1 hour'},
                    {'value': '2 hours', 'title': '2 hours'},
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
                SizedBox(
                  height: 24,
                ),
                _buildModernRadioGroup<String>(
                  question:
                      'What was the longest time spent on the task during a non school day these last 7 days?',
                  groupValue: _longestNonSchoolDayTimeDangerous,
                  onChanged: (String? value) {
                    setState(() {
                      _longestNonSchoolDayTimeDangerous = value;
                    });
                  },
                  options: [
                    {
                      'value': 'Less than one hour',
                      'title': 'Less than one hour'
                    },
                    {'value': '1-2 hours', 'title': '1-2 hours'},
                    {'value': '2-3 hours', 'title': '2-3 hours'},
                    {'value': '3-4 hours', 'title': '3-4 hours'},
                    {'value': '4-6 hours', 'title': '4-6 hours'},
                    {'value': '6-8 hours', 'title': '6-8 hours'},
                    {
                      'value': 'More than 8 hours',
                      'title': 'More than 8 hours'
                    },
                  ],
                ),

                SizedBox(
                  height: 24,
                ),

                _buildModernTextField(
                  label:
                      'How many hours has the child worked on during the last 7 days?',
                  controller: _totalHoursWorkedControllerDangerous,
                  keyboardType: TextInputType.number,
                  hintText: 'Enter total hours worked',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the total hours worked';
                    }
                    final hours = double.tryParse(value);
                    if (hours == null || hours < 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),

                SizedBox(
                  height: 24,
                ),
                _buildModernTextField(
                  label:
                      'How many hours has the child  been working on during non school days, during the last 7 days ?',
                  controller: _totalHoursWorkedControllerNonSchoolDangerous,
                  keyboardType: TextInputType.number,
                  hintText: 'Enter total hours worked',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the total hours worked';
                    }
                    final hours = double.tryParse(value);
                    if (hours == null || hours < 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 24,
                ),
                _buildModernRadioGroup<bool>(
                  question:
                      'Was the child under supervision of an adult when performing this task?',
                  groupValue: _wasSupervisedByAdultDangerous,
                  onChanged: (bool? value) {
                    setState(() {
                      _wasSupervisedByAdult = value;
                    });
                  },
                  options: [
                    {'value': true, 'title': 'Yes'},
                    {'value': false, 'title': 'No'},
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                if (_workedOnCocoaFarm == true) ...[
                  _buildModernRadioGroup<String>(
                    question:
                        'For whom does the child [${widget.childNumber}] work?',
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
                      validator: (value) {
                        if (_workForWhom == 'other' &&
                            (value == null || value.isEmpty)) {
                          return 'Please specify for whom the child works';
                        }
                        return null;
                      },
                    ),
                  ],
                ],

                // NEXT QUESTION: Why does the child work?
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why does the child [${widget.childNumber}] work?',
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
                            validator: (value) {
                              if (_whyWorkReasons.contains('other') &&
                                  (value == null || value.isEmpty)) {
                                return 'Please specify the reason';
                              }
                              return null;
                            },
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
              SizedBox(
                height: 24,
              ),
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
                    if (_sufferedInjury == true &&
                        (value == null || value.trim().isEmpty)) {
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
              SizedBox(
                height: 24,
              ),
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
              SizedBox(
                height: 24,
              ),
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
              SizedBox(
                height: 24,
              ),

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

              // Submit button with modern design
              const SizedBox(height: 32),
              Container(
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _submitForm,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
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
          ),
        ),
      ),
    );
  }
}
