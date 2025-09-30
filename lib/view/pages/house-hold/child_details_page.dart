import 'package:flutter/material.dart';

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

class ChildDetailsPage extends StatefulWidget {
  final int childNumber;
  final int totalChildren;

  const ChildDetailsPage({
    Key? key,
    required this.childNumber,
    required this.totalChildren,
  }) : super(key: key);

  @override
  _ChildDetailsPageState createState() => _ChildDetailsPageState();
}

class _ChildDetailsPageState extends State<ChildDetailsPage> {
  bool? _attendedSchoolLast7Days;
  bool? _missedSchoolDays;
  bool? _workedInHouse;
  bool? _workedOnCocoaFarm;
  String? _workFrequency;
  bool? _observedWorking;
  bool? _receivedRemuneration;
  bool? _activityRemuneration;
  bool? _wasSupervisedByAdult;
  String? _longestLightDutyTime;
  String? _longestNonSchoolDayTime;
  String? _taskLocation;
  String? _schoolDayTaskDuration; // Tracks the longest time spent on task during school day
  String? _nonSchoolDayTaskDuration; // Tracks the longest time spent on task during non-school day
  String? _taskLocationType; // Tracks where the task was performed
  String? _totalSchoolDayHours; // Tracks total hours spent on task during school days
  String? _totalNonSchoolDayHours; // Tracks total hours spent on task during non-school days
  bool? _wasSupervisedDuringTask; // Tracks if child was supervised by an adult during the task
  final Set<String> _cocoaFarmTasksLast7Days = {}; // Tracks tasks done on cocoa farm in last 7 days
  final TextEditingController _otherLocationController =
      TextEditingController();
  final TextEditingController _schoolDayHoursController =
      TextEditingController();
  final Set<String> _cocoaFarmTasks = {};
  final Set<String> _tasksLast12Months =
      {}; // Tracks tasks performed in the last 12 months
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
      };

      Navigator.pop(context, childData);
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

  @override
  void dispose() {
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
    _schoolDayHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child ${widget.childNumber} of ${widget.totalChildren}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Question about farmer's children
              Text(
                'Is the child among the list of children declared in the cover to be the farmer\'s children?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Yes'),
                      value: true,
                      groupValue: _isFarmerChild,
                      onChanged: (value) {
                        setState(() {
                          _isFarmerChild = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('No'),
                      value: false,
                      groupValue: _isFarmerChild,
                      onChanged: (value) {
                        setState(() {
                          _isFarmerChild = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Note about farmer's children list
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Text(
                  'FARMER CHILDREN LIST',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
              ),

              // Child number input
              Text(
                'Enter the number attached to the child name in the cover so we can identify the child in question:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _childNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter child number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Question about surveying the child now
              Text(
                'Can the child be surveyed now?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Yes'),
                      value: true,
                      groupValue: _canBeSurveyedNow,
                      onChanged: (value) {
                        setState(() {
                          _canBeSurveyedNow = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('No'),
                      value: false,
                      groupValue: _canBeSurveyedNow,
                      onChanged: (value) {
                        setState(() {
                          _canBeSurveyedNow = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Show reasons if survey is not possible
              if (_canBeSurveyedNow == false) ...[
                const SizedBox(height: 24),
                Text(
                  'If not, what are the reasons?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                ..._buildUnavailableReasons(),

                // Respondent information
                const SizedBox(height: 24),
                Text(
                  'Who is answering for the child since he/she is not available?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                ...[
                  'The parents or legal guardians',
                  'Another family member of the child',
                  'One of the child\'s siblings',
                  'Other'
                ].map((type) {
                  return RadioListTile<String>(
                    title: Text(type),
                    value: type.toLowerCase(),
                    groupValue: _respondentType,
                    onChanged: (value) {
                      setState(() {
                        _respondentType = value;
                      });
                    },
                  );
                }).toList(),

                if (_respondentType != null) ...[
                  const SizedBox(height: 16),
                  if (_respondentType == 'other') ...[
                    TextFormField(
                      controller: _otherRespondentTypeController,
                      decoration: InputDecoration(
                        labelText: 'Please specify',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
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
                // Child's basic information section
                const SizedBox(height: 24),
                Text(
                  'Child\'s First Name:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter child\'s first name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the child\'s first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  'Child\'s Surname:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    hintText: 'Enter child\'s surname',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the child\'s surname';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  'Child\'s Gender:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Male'),
                        value: 'Male',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Female'),
                        value: 'Female',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  'Year of Birth:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _birthYearController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    hintText: 'Select year of birth',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
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

                // Birth certificate question
                const SizedBox(height: 24),
                Text(
                  'Does the child have a birth certificate?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Yes'),
                        value: true,
                        groupValue: _hasBirthCertificate,
                        onChanged: (value) {
                          setState(() {
                            _hasBirthCertificate = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('No'),
                        value: false,
                        groupValue: _hasBirthCertificate,
                        onChanged: (value) {
                          setState(() {
                            _hasBirthCertificate = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // Show reason field if no birth certificate
                if (_hasBirthCertificate == false) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noBirthCertificateReasonController,
                    decoration: InputDecoration(
                      labelText: 'If no, please specify why',
                      hintText:
                          'Enter reason for not having a birth certificate',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
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

                // Born in community question
                const SizedBox(height: 24),
                Text(
                  'Was the child born in this community?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Yes'),
                        value: true,
                        groupValue: _bornInCommunity,
                        onChanged: (value) {
                          setState(() {
                            _bornInCommunity = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('No'),
                        value: false,
                        groupValue: _bornInCommunity,
                        onChanged: (value) {
                          setState(() {
                            _bornInCommunity = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // Country of birth (shown only if not born in this community)
                if (_bornInCommunity == false) ...[
                  const SizedBox(height: 24),
                  Text(
                    'In which country was the child born?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _birthCountry,
                    decoration: InputDecoration(
                      hintText: 'Select country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
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
                Text(
                  'Relationship of the child to the head of the household',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _relationshipToHead,
                  decoration: InputDecoration(
                    hintText: 'Select relationship',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a relationship';
                    }
                    return null;
                  },
                ),
                if (_relationshipToHead == 'Other (please specify)') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otherRelationshipController,
                    decoration: InputDecoration(
                      labelText: 'Please specify relationship',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) {
                      if (_relationshipToHead == 'Other (please specify)' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please specify the relationship';
                      }
                      return null;
                    },
                  ),
                ],

                // Reason for not living with family (shown for specific relationships)
                if (_relationshipToHead != null &&
                    [
                      'Child of the worker',
                      'Child of the farm owner',
                      'Other (please specify)'
                    ].contains(_relationshipToHead)) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Why does the child not live with their family?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...[
                    'Parents deceased',
                    'Can\'t take care of me',
                    'Abandoned',
                    'School reasons',
                    'A recruitment agency brought me here',
                    'I did not want to live with my parents',
                    'Other (specify)',
                    'Don\'t know'
                  ].map((reason) {
                    final isOther = reason == 'Other (specify)';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: Text(reason),
                          value: _notWithFamilyReasons.contains(reason),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _notWithFamilyReasons.add(reason);
                              } else {
                                _notWithFamilyReasons.remove(reason);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (isOther &&
                            _notWithFamilyReasons.contains(reason)) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 40.0, bottom: 12, right: 16),
                            child: TextFormField(
                              controller: _otherNotWithFamilyController,
                              decoration: InputDecoration(
                                labelText: 'Please specify',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              validator: (value) {
                                if (_notWithFamilyReasons
                                        .contains('Other (specify)') &&
                                    (value == null || value.trim().isEmpty)) {
                                  return 'Please specify the reason';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 16),

                  // Did the child agree with this decision?
                  const SizedBox(height: 16),
                  Text(
                    'Did the child agree with this decision?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Yes'),
                          value: true,
                          groupValue: _childAgreedWithDecision,
                          onChanged: (value) {
                            setState(() {
                              _childAgreedWithDecision = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('No'),
                          value: false,
                          groupValue: _childAgreedWithDecision,
                          onChanged: (value) {
                            setState(() {
                              _childAgreedWithDecision = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Has the child spoken with his/her parents in the past year?
                  if (_respondentType != null &&
                      _respondentType!.isNotEmpty &&
                      _respondentType!.toLowerCase() != 'myself') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Has the child spoken with his/her parents in the past year?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Yes'),
                            value: true,
                            groupValue: _hasSpokenWithParents,
                            onChanged: (bool? value) {
                              setState(() {
                                _hasSpokenWithParents = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('No'),
                            value: false,
                            groupValue: _hasSpokenWithParents,
                            onChanged: (bool? value) {
                              setState(() {
                                _hasSpokenWithParents = value;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: 16),

                // How long has the child been living in the household?
                Text(
                  'For how long has the child been living in the household?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                ...[
                  'Born in the household',
                  'Less than 1 year',
                  '1-2 years',
                  '2-4 years old',
                  '4-6 years old',
                  '6-8 years old',
                  'More than 8 years',
                  'Don\'t know'
                ]
                    .map((option) => RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: _timeInHousehold,
                          onChanged: (String? value) {
                            setState(() {
                              _timeInHousehold = value;
                            });
                          },
                        ))
                    .toList(),
                const SizedBox(height: 16),

                // Who accompanied the child to come here?
                const SizedBox(height: 24),
                Text(
                  'Who accompanied the child to come here?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                ...[
                  'Came alone',
                  'Father / Mother',
                  'Grandparents',
                  'Other family member',
                  'With a recruit',
                  'Other'
                ].map((option) {
                  final isOther = option == 'Other';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: _whoAccompaniedChild,
                        onChanged: (String? value) {
                          setState(() {
                            _whoAccompaniedChild = value;
                          });
                        },
                      ),
                      if (isOther && _whoAccompaniedChild == option)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 40.0, bottom: 12, right: 16),
                          child: TextFormField(
                            controller: _otherAccompaniedController,
                            decoration: InputDecoration(
                              labelText: 'Please specify',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (_whoAccompaniedChild == 'Other' &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please specify who accompanied the child';
                              }
                              return null;
                            },
                          ),
                        ),
                    ],
                  );
                }).toList(),
                const SizedBox(height: 16),

                // Father's residence
                const SizedBox(height: 24),
                Text(
                  'Where does the child\'s father live?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                ...[
                  'In the same household',
                  'In another household in the same village',
                  'In another household in the same region',
                  'In another household in another region',
                  'Abroad',
                  'Parents deceased',
                  'Don\'t know/Don\'t want to answer'
                ]
                    .map((option) => RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: _fatherResidence,
                          onChanged: (String? value) {
                            setState(() {
                              _fatherResidence = value;
                            });
                          },
                        ))
                    .toList(),

                // Show country selection if father is abroad
                if (_fatherResidence == 'Abroad') ...[
                  const SizedBox(height: 16),
                  Text(
                    'Father\'s country of residence',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _fatherCountry,
                    decoration: InputDecoration(
                      hintText: 'Select country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
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
                    TextFormField(
                      controller: _otherFatherCountryController,
                      decoration: InputDecoration(
                        labelText: 'Please specify country',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
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
                Text(
                  'Where does the child\'s mother live?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                ...[
                  'In the same household',
                  'In another household in the same village',
                  'In another household in the same region',
                  'In another household in another region',
                  'Abroad',
                  'Parents deceased',
                  'Don\'t know/Don\'t want to answer'
                ]
                    .map((option) => RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: _motherResidence,
                          onChanged: (String? value) {
                            setState(() {
                              _motherResidence = value;
                            });
                          },
                        ))
                    .toList(),

                // Show country selection if mother is abroad
                if (_motherResidence == 'Abroad') ...[
                  const SizedBox(height: 16),
                  Text(
                    'Mother\'s country of residence',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _motherCountry,
                    decoration: InputDecoration(
                      hintText: 'Select country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
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
                    TextFormField(
                      controller: _otherMotherCountryController,
                      decoration: InputDecoration(
                        labelText: 'Please specify country',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
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

                // School enrollment
                Text(
                  'Is the child currently enrolled in school?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Yes'),
                        value: true,
                        groupValue: _isCurrentlyEnrolled,
                        onChanged: (bool? value) {
                          setState(() {
                            _isCurrentlyEnrolled = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('No'),
                        value: false,
                        groupValue: _isCurrentlyEnrolled,
                        onChanged: (bool? value) {
                          setState(() {
                            _isCurrentlyEnrolled = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // Currently enrolled section
                if (_isCurrentlyEnrolled == true) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _schoolNameController,
                    decoration: InputDecoration(
                      labelText: 'What is the name of the school?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    validator: (value) {
                      if (_isCurrentlyEnrolled == true &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter the school name';
                      }
                      return null;
                    },
                  ),
                  if (_schoolNameController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Is the school a public or private school?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Public'),
                            value: 'Public',
                            groupValue: _schoolType,
                            onChanged: (String? value) {
                              setState(() {
                                _schoolType = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Private'),
                            value: 'Private',
                            groupValue: _schoolType,
                            onChanged: (String? value) {
                              setState(() {
                                _schoolType = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_schoolType != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'What grade is the child enrolled in?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _gradeLevel,
                        decoration: InputDecoration(
                          hintText: 'Select grade level',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
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
                        validator: (value) {
                          if (_isCurrentlyEnrolled == true && value == null) {
                            return 'Please select a grade level';
                          }
                          return null;
                        },
                      ),
                    ],
                    if (_gradeLevel != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'How many times does the child go to school in a week?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...['Once', 'Twice', 'Thrice', 'Four times', 'Five times']
                          .map((option) => RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: _schoolAttendanceFrequency,
                                onChanged: (String? value) {
                                  setState(() {
                                    _schoolAttendanceFrequency = value;
                                  });
                                },
                              ))
                          .toList(),
                    ],
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
                    ...[
                      'Books',
                      'School bag',
                      'Pen / Pencils',
                      'School Uniforms',
                      'Shoes and Socks',
                      'None of the above'
                    ]
                        .map((item) => CheckboxListTile(
                              title: Text(item),
                              value: _availableSchoolSupplies.contains(item),
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    if (item == 'None of the above') {
                                      _availableSchoolSupplies.clear();
                                    } else {
                                      _availableSchoolSupplies
                                          .remove('None of the above');
                                    }
                                    _availableSchoolSupplies.add(item);
                                  } else {
                                    _availableSchoolSupplies.remove(item);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ))
                        .toList(),
                  ],
                ],

                // Not currently enrolled section
                if (_isCurrentlyEnrolled == false) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Has the child ever been to school?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text(
                              'Yes, they went to school but stopped'),
                          value: true,
                          groupValue: _hasEverBeenToSchool,
                          onChanged: (bool? value) {
                            setState(() {
                              _hasEverBeenToSchool = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title:
                              const Text('No, they have never been to school'),
                          value: false,
                          groupValue: _hasEverBeenToSchool,
                          onChanged: (bool? value) {
                            setState(() {
                              _hasEverBeenToSchool = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Additional sections for children who were enrolled but stopped
                  if (_hasEverBeenToSchool == true) ...[
                    const SizedBox(height: 16),
                    Text(
                      'When did the child leave school?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _leftSchoolYearController,
                      decoration: InputDecoration(
                        labelText: 'Enter year',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
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
                    Text(
                      'Or select exact date:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _leftSchoolDateController,
                      readOnly: true,
                      onTap: () => _selectLeftSchoolDate(context),
                      decoration: InputDecoration(
                        labelText: 'Left School Date',
                        hintText: 'Select date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
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
                    Text(
                      'Has the child been to school in the past 7 days?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _attendedSchoolLast7Days,
                          onChanged: (bool? value) {
                            setState(() {
                              _attendedSchoolLast7Days = value;
                            });
                          },
                        ),
                        const Text('Yes'),
                        const SizedBox(width: 20),
                        Radio<bool>(
                          value: false,
                          groupValue: _attendedSchoolLast7Days,
                          onChanged: (bool? value) {
                            setState(() {
                              _attendedSchoolLast7Days = value;
                            });
                          },
                        ),
                        const Text('No'),
                      ],
                    ),

                    // Question about missing school days
                    const SizedBox(height: 16),
                    Text(
                      'Has the child missed any school days in the past 7 days?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _missedSchoolDays,
                          onChanged: (bool? value) {
                            setState(() {
                              _missedSchoolDays = value;
                            });
                          },
                        ),
                        const Text('Yes'),
                        const SizedBox(width: 20),
                        Radio<bool>(
                          value: false,
                          groupValue: _missedSchoolDays,
                          onChanged: (bool? value) {
                            setState(() {
                              _missedSchoolDays = value;
                            });
                          },
                        ),
                        const Text('No'),
                      ],
                    ),

                    if (_missedSchoolDays == true) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Why has the child missed school days?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ..._absenceReasons.entries.map((entry) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: entry.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _absenceReasons[entry.key] =
                                          value ?? false;
                                    });
                                  },
                                ),
                                Text(entry.key),
                              ],
                            ),
                            if (entry.key == 'Other' &&
                                _absenceReasons['Other'] == true)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 40, right: 16, bottom: 8),
                                child: TextFormField(
                                  controller: _otherAbsenceReasonController,
                                  decoration: const InputDecoration(
                                    hintText: 'Please specify',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ],
                  ],
                ],

                // Work-related questions
                const SizedBox(height: 24),
                Text(
                  'In the past 7 days, has the child [${widget.childNumber}] worked in the house?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _workedInHouse,
                      onChanged: (bool? value) {
                        setState(() {
                          _workedInHouse = value;
                        });
                      },
                    ),
                    const Text('Yes'),
                    const SizedBox(width: 20),
                    Radio<bool>(
                      value: false,
                      groupValue: _workedInHouse,
                      onChanged: (bool? value) {
                        setState(() {
                          _workedInHouse = value;
                        });
                      },
                    ),
                    const Text('No'),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'In the past 7 days, has the child [${widget.childNumber}] been working on the cocoa farm?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _workedOnCocoaFarm,
                      onChanged: (bool? value) {
                        setState(() {
                          _workedOnCocoaFarm = value;
                        });
                      },
                    ),
                    const Text('Yes'),
                    const SizedBox(width: 20),
                    Radio<bool>(
                      value: false,
                      groupValue: _workedOnCocoaFarm,
                      onChanged: (bool? value) {
                        setState(() {
                          _workedOnCocoaFarm = value;
                        });
                      },
                    ),
                    const Text('No'),
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
                      _buildTaskCheckbox(
                          'Collect and gather fruits, pods, seeds after harvesting'),
                      _buildTaskCheckbox(
                          'Extracting cocoa beans after shelling by an adult'),
                      _buildTaskCheckbox(
                          'Wash beans, fruits, vegetables or tubers'),
                      _buildTaskCheckbox(
                          'Prepare the germinators and pour the seeds into the germinators'),
                      _buildTaskCheckbox('Collecting firewood'),
                      _buildTaskCheckbox(
                          'Help measure distances between plants during transplanting'),
                      _buildTaskCheckbox(
                          'Sort and spread the beans, cereals and other vegetables for drying'),
                      _buildTaskCheckbox('Putting cuttings on the mounds'),
                      _buildTaskCheckbox(
                          'Holding bags or filling them with small containers for packaging'),
                      _buildTaskCheckbox(
                          'Covering stored agricultural products with tarps'),
                      _buildTaskCheckbox(
                          'To shell or dehusk seeds, plants and fruits by hand'),
                      _buildTaskCheckbox('Sowing seeds'),
                      _buildTaskCheckbox(
                          'Transplant or put in the ground the cuttings or plants'),
                      _buildTaskCheckbox(
                          'Harvesting legumes, fruits and other leafy products (corn, beans, soybeans, various vegetables)'),
                      _buildTaskCheckbox('None'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Work frequency
                const SizedBox(height: 24),
                const Text(
                  'How often has the child worked in the past 7 days?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    _buildFrequencyOption('Every day'),
                    _buildFrequencyOption('4-5 days'),
                    _buildFrequencyOption('2-3 days'),
                    _buildFrequencyOption('Once'),
                  ],
                ),

                // Observer question
                const SizedBox(height: 24),
                Text(
                  'Did the enumerator observe the child [${widget.childNumber}] working in a real situation?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _observedWorking,
                      onChanged: (bool? value) {
                        setState(() {
                          _observedWorking = value;
                        });
                      },
                    ),
                    const Text('Yes'),
                    const SizedBox(width: 20),
                    Radio<bool>(
                      value: false,
                      groupValue: _observedWorking,
                      onChanged: (bool? value) {
                        setState(() {
                          _observedWorking = value;
                        });
                      },
                    ),
                    const Text('No'),
                  ],
                ),

                // LIGHT TASKS header
                const SizedBox(height: 24),
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    child: Text(
                      'LIGHT TASKS (7 DAYS)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

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

                // Remuneration question
                const Text(
                  'Did the child receive remuneration for the activity?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _receivedRemuneration,
                      onChanged: (bool? value) {
                        setState(() {
                          _receivedRemuneration = value;
                        });
                      },
                    ),
                    const Text('Yes'),
                    const SizedBox(width: 20),
                    Radio<bool>(
                      value: false,
                      groupValue: _receivedRemuneration,
                      onChanged: (bool? value) {
                        setState(() {
                          _receivedRemuneration = value;
                        });
                      },
                    ),
                    const Text('No'),
                  ],
                ),

                // Time spent on light duty - School day
                const SizedBox(height: 24),
                const Text(
                  'What was the longest time spent on light duty during a SCHOOL DAY in the last 7 days?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeOption('Less than 1 hour', isSchoolDay: true),
                    _buildTimeOption('1-2 hours', isSchoolDay: true),
                    _buildTimeOption('2-3 hours', isSchoolDay: true),
                    _buildTimeOption('3-4 hours', isSchoolDay: true),
                    _buildTimeOption('4-6 hours', isSchoolDay: true),
                    _buildTimeOption('6-8 hours', isSchoolDay: true),
                    _buildTimeOption('More than 8 hours', isSchoolDay: true),
                    _buildTimeOption('Does not apply', isSchoolDay: true),
                  ],
                ),

                // Time spent on light duty - Non-school day
                const SizedBox(height: 24),
                const Text(
                  'What was the longest amount of time spent on light duty on a NON-SCHOOL DAY in the last 7 days?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeOption('1-2 hours', isSchoolDay: false),
                    _buildTimeOption('2-3 hours', isSchoolDay: false),
                    _buildTimeOption('3-4 hours', isSchoolDay: false),
                    _buildTimeOption('4-6 hours', isSchoolDay: false),
                    _buildTimeOption('6-8 hours', isSchoolDay: false),
                    _buildTimeOption('More than 8 hours', isSchoolDay: false),
                    _buildTimeOption('Does not apply', isSchoolDay: false),
                  ],
                ),

                // Task location
                const SizedBox(height: 24),

                // Adult supervision question
                const Text(
                  'Was the child under supervision of an adult when performing this task?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _wasSupervisedByAdult,
                      onChanged: (bool? value) {
                        setState(() {
                          _wasSupervisedByAdult = value;
                        });
                      },
                    ),
                    const Text('Yes'),
                    const SizedBox(width: 20),
                    Radio<bool>(
                      value: false,
                      groupValue: _wasSupervisedByAdult,
                      onChanged: (bool? value) {
                        setState(() {
                          _wasSupervisedByAdult = value;
                        });
                      },
                    ),
                    const Text('No'),
                  ],
                ),

                // Task location
                const SizedBox(height: 24),
                const Text(
                  'Where was this task done?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationOption('On family farm'),
                    _buildLocationOption('As a hired labourer on another farm'),
                    _buildLocationOption('School farms/compounds'),
                    _buildLocationOption(
                        'Teachers farms (during communal labour)'),
                    _buildLocationOption('Church farms or cleaning activities'),
                    _buildLocationOption('Helping a community member for free'),
                    _buildLocationOption('Other'),
                  ],
                ),

                // Total hours on school days
                const SizedBox(height: 24),
                const Text(
                  'How many hours in total did the child spend on this task during SCHOOL DAYS in the past 7 days?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _schoolDayHoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter hours (0-1016)',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
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
                const SizedBox(height: 8),
                const Text(
                  'Note: 1016 hours is the maximum possible in 7 days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                // Adult supervision question
                const SizedBox(height: 24),
                const Text(
                  'Was the child under supervision of an adult when performing this task?',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _wasSupervisedByAdult,
                      onChanged: (bool? value) {
                        setState(() {
                          _wasSupervisedByAdult = value;
                        });
                      },
                    ),
                    const Text('Yes'),
                    const SizedBox(width: 20),
                    Radio<bool>(
                      value: false,
                      groupValue: _wasSupervisedByAdult,
                      onChanged: (bool? value) {
                        setState(() {
                          _wasSupervisedByAdult = value;
                        });
                      },
                    ),
                    const Text('No'),
                  ],
                ),

                // Tasks in last 12 months - only show if worked on cocoa farm in past 7 days
                if (_workedOnCocoaFarm == true) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Which of these tasks has child [${widget.childNumber}] performed in the last 12 months?',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTaskCheckbox12Months(
                          'Collect and gather fruits, pods, seeds after harvesting'),
                      _buildTaskCheckbox12Months(
                          'Extracting cocoa beans after shelling by an adult'),
                      _buildTaskCheckbox12Months(
                          'Wash beans, fruits, vegetables or tubers'),
                      _buildTaskCheckbox12Months(
                          'Prepare the germinators and pour the seeds into the germinators'),
                      _buildTaskCheckbox12Months('Collecting firewood'),
                      _buildTaskCheckbox12Months(
                          'Help measure distances between plants during transplanting'),
                      _buildTaskCheckbox12Months(
                          'Sort and spread the beans, cereals and other vegetables for drying'),
                      _buildTaskCheckbox12Months(
                          'Putting cuttings on the mounds'),
                      _buildTaskCheckbox12Months(
                          'Holding bags or filling them with small containers for packaging de produits agricoles'),
                      _buildTaskCheckbox12Months(
                          'Covering stored agricultural products with tarps'),
                      _buildTaskCheckbox12Months(
                          'Shell or dehusk seeds, plants and fruits by hand'),
                      _buildTaskCheckbox12Months('Sowing seeds'),
                      _buildTaskCheckbox12Months(
                          'Transplant or put in the ground the cuttings or plants'),
                      _buildTaskCheckbox12Months(
                          'Harvesting legumes, fruits and other leafy products (corn, beans, soybeans, various vegetables)'),
                      _buildTaskCheckbox12Months('None'),
                    ],
                  ),
                ],
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.blue[300],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'LIGHT TASK (12 MONTHS)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.blue[300],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Activity remuneration question
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Did the child receive any remuneration for this specific activity?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _activityRemuneration,
                            onChanged: (bool? value) {
                              setState(() {
                                _activityRemuneration = value;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: 20),
                          Radio<bool>(
                            value: false,
                            groupValue: _activityRemuneration,
                            onChanged: (bool? value) {
                              setState(() {
                                _activityRemuneration = value;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                    ],
                  ),
                ),

                // School day task duration question
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What was the longest time spent on this task during a SCHOOL DAY in the last 7 days?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...<String>[
                        'Less than 1 hour',
                        '1-2 hours',
                        '2-3 hours',
                        '3-4 hours',
                        '4-6 hours',
                        '6-8 hours',
                        'More than 8 hours',
                        'Does not apply'
                      ]
                          .map((option) => RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: _schoolDayTaskDuration,
                                onChanged: (String? value) {
                                  setState(() {
                                    _schoolDayTaskDuration = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ))
                          .toList(),
                    ],
                  ),
                ),

                // Non-school day task duration question
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What was the longest time spent on this task on a NON-SCHOOL DAY in the last 7 days?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...<String>[
                        'Less than 1 hour',
                        '1-2 hours',
                        '2-3 hours',
                        '3-4 hours',
                        '4-6 hours',
                        '6-8 hours',
                        'More than 8 hours'
                      ].map((option) => RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _nonSchoolDayTaskDuration,
                            onChanged: (String? value) {
                              setState(() {
                                _nonSchoolDayTaskDuration = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          )).toList(),
                    ],
                  ),
                ),

                // Task location question
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Where was this task done?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...<String>[
                        'On family farm',
                        'As a hired labourer on another farm',
                        'School farms/compounds',
                        'Teachers farms (during communal labour)',
                        'Church farms or cleaning activities',
                        'Helping a community member for free',
                        'Other'
                      ].map((option) => RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _taskLocationType,
                            onChanged: (String? value) {
                              setState(() {
                                _taskLocationType = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          )).toList(),
                      if (_taskLocationType == 'Other')
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0, top: 8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Please specify',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              // You can store this value if needed
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Total hours on school days question
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How many hours in total did the child spend on this task during SCHOOL DAYS in the past 7 days?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...<String>[
                        'Less than 1 hour',
                        '1-2 hours',
                        '2-4 hours',
                        '4-6 hours',
                        '6-8 hours',
                        'More than 8 hours',
                        'Not applicable'
                      ].map((option) => RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _totalSchoolDayHours,
                            onChanged: (String? value) {
                              setState(() {
                                _totalSchoolDayHours = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          )).toList(),
                    ],
                  ),
                ),
                
                // Total hours on non-school days question
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How many hours in total did the child spend on this task during NON-SCHOOL DAYS in the last 7 days?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...<String>[
                        'Less than 1 hour',
                        '1-2 hours',
                        '2-4 hours',
                        '4-6 hours',
                        '6-8 hours',
                        'More than 8 hours',
                        'Not applicable'
                      ].map((option) => RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _totalNonSchoolDayHours,
                            onChanged: (String? value) {
                              setState(() {
                                _totalNonSchoolDayHours = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          )).toList(),
                    ],
                  ),
                ),
                
                // Adult supervision question
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Was the child under supervision of an adult when performing this task?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _wasSupervisedDuringTask,
                            onChanged: (bool? value) {
                              setState(() {
                                _wasSupervisedDuringTask = value;
                              });
                            },
                          ),
                          const Text('Yes'),
                          const SizedBox(width: 20),
                          Radio<bool>(
                            value: false,
                            groupValue: _wasSupervisedDuringTask,
                            onChanged: (bool? value) {
                              setState(() {
                                _wasSupervisedDuringTask = value;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Cocoa farm tasks question
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Which of the following tasks has the child [${widget.childNumber}] done in the last 7 days on the cocoa farm?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...<String>[
                        'Use of machetes for weeding or pruning (Clearing)',
                        'Felling of trees',
                        'Burning of plots',
                        'Game hunting with a weapon',
                        'Woodcutter\'s work',
                        'Charcoal production',
                        'Stump removal',
                        'Digging holes',
                        'Working with a machete or any other sharp tool',
                        'Handling of agrochemicals',
                        'Driving motorized vehicles',
                        'Carrying heavy loads (Boys: 14-16 years old>15kg /16-17 years old>20kg; Girls: 14-16 years old>8Kg/16-17 years old>10Kg)',
                        'Night work on farm (between 6pm and 6am)',
                        'None of the above'
                      ].map((task) => CheckboxListTile(
                            title: Text(task),
                            value: _cocoaFarmTasksLast7Days.contains(task),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _cocoaFarmTasksLast7Days.add(task);
                                } else {
                                  _cocoaFarmTasksLast7Days.remove(task);
                                }
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          )).toList(),
                    ],
                  ),
                ),
                
                // Submit button
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('SAVE CHILD DETAILS'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget for building task checkboxes for tasks in last 12 months
  Widget _buildTaskCheckbox12Months(String task) {
    return CheckboxListTile(
      title: Text(task),
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
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  // Widget for building task checkboxes
  Widget _buildTaskCheckbox(String task) {
    return CheckboxListTile(
      title: Text(task),
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
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLocationOption(String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String>(
          title: Text(location),
          value: location,
          groupValue: _taskLocation,
          onChanged: (String? value) {
            setState(() {
              _taskLocation = value;
              if (value != 'Other') {
                _otherLocationController.clear();
              }
            });
          },
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        if (location == 'Other' && _taskLocation == 'Other')
          Padding(
            padding:
                const EdgeInsets.only(left: 40.0, right: 16.0, bottom: 8.0),
            child: TextFormField(
              controller: _otherLocationController,
              decoration: const InputDecoration(
                labelText: 'Please specify',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeOption(String timeRange, {required bool isSchoolDay}) {
    return RadioListTile<String>(
      title: Text(timeRange),
      value: timeRange,
      groupValue:
          isSchoolDay ? _longestLightDutyTime : _longestNonSchoolDayTime,
      onChanged: (String? value) {
        setState(() {
          if (isSchoolDay) {
            _longestLightDutyTime = value;
          } else {
            _longestNonSchoolDayTime = value;
          }
        });
      },
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildFrequencyOption(String frequency) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Radio<String>(
            value: frequency,
            groupValue: _workFrequency,
            onChanged: (String? value) {
              setState(() {
                _workFrequency = value;
              });
            },
          ),
          Text(frequency),
        ],
      ),
    );
  }

  List<Widget> _buildReasonCheckbox(
    String title,
    String value, {
    bool showTextField = false,
  }) {
    return [
      Row(
        children: [
          Checkbox(
            value: _surveyNotPossibleReasons.contains(value),
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  _surveyNotPossibleReasons.add(value);
                } else {
                  _surveyNotPossibleReasons.remove(value);
                }
              });
            },
          ),
          Expanded(
            child: Text(title),
          ),
        ],
      ),
      if (showTextField && _surveyNotPossibleReasons.contains(value))
        Padding(
          padding: const EdgeInsets.only(left: 40.0, bottom: 12, right: 16),
          child: TextFormField(
            controller: _otherReasonController,
            decoration: InputDecoration(
              hintText: 'Please specify reason',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (_surveyNotPossibleReasons.contains('other') &&
                  (value == null || value.trim().isEmpty)) {
                return 'Please specify the reason';
              }
              return null;
            },
          ),
        ),
    ];
  }

  List<Widget> _buildUnavailableReasons() {
    final reasons = [
      {'title': 'The child is at school', 'value': 'at_school'},
      {
        'title': 'The child has gone to work on the cocoa farm',
        'value': 'working_cocoa_farm'
      },
      {'title': 'Child is busy doing housework', 'value': 'doing_housework'},
      {
        'title': 'Child works outside the household',
        'value': 'working_outside'
      },
      {'title': 'The child is too young', 'value': 'too_young'},
      {'title': 'The child is sick', 'value': 'sick'},
      {'title': 'The child has travelled', 'value': 'travelled'},
      {'title': 'The child has gone out to play', 'value': 'playing'},
      {'title': 'The child is sleeping', 'value': 'sleeping'},
      {'title': 'Other reasons', 'value': 'other', 'showTextField': true},
    ];

    return reasons
        .map((reason) {
          return _buildReasonCheckbox(
            reason['title'] as String,
            reason['value'] as String,
            showTextField: reason['showTextField'] == true,
          );
        })
        .expand((e) => e)
        .toList();
  }
}
