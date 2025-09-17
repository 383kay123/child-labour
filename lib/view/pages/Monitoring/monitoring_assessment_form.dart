import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Model to track yes/no question state
class YesNoQuestion {
  final String id;
  final String question;
  final List<String>? options;
  final String? selectedValue;
  final String? additionalInfo;
  final bool showAdditionalField;

  YesNoQuestion({
    required this.id,
    required this.question,
    this.options,
    this.selectedValue,
    this.additionalInfo,
    this.showAdditionalField = false,
  });

  YesNoQuestion copyWith({
    String? selectedValue,
    String? additionalInfo,
    bool? showAdditionalField,
  }) {
    return YesNoQuestion(
      id: id,
      question: question,
      options: options,
      selectedValue: selectedValue ?? this.selectedValue,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      showAdditionalField: showAdditionalField ?? this.showAdditionalField,
    );
  }
}

class MonitoringAssessmentForm extends StatefulWidget {
  const MonitoringAssessmentForm({super.key});

  @override
  State<MonitoringAssessmentForm> createState() =>
      _MonitoringAssessmentFormState();
}

class _MonitoringAssessmentFormState extends State<MonitoringAssessmentForm> {
  final Map<String, String> _answers = {};
  final RxInt _monitoringScore = 0.obs;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _childIdController = TextEditingController();
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _communityController = TextEditingController();
  final TextEditingController _farmerIdController = TextEditingController();
  final TextEditingController _interventionDateController =
      TextEditingController();
  final TextEditingController _remediationTypeController =
      TextEditingController();
  final TextEditingController _followUpVisitsController =
      TextEditingController();
  final TextEditingController _currentSchoolController =
      TextEditingController();
  final TextEditingController _gradeLevelController = TextEditingController();
  final TextEditingController _attendanceRateController =
      TextEditingController();
  final TextEditingController _schoolPerformanceController =
      TextEditingController();
  final TextEditingController _challengesController = TextEditingController();
  final TextEditingController _supportNeededController =
      TextEditingController();
  final TextEditingController _attendanceNotesController =
      TextEditingController();
  final TextEditingController _performanceNotesController =
      TextEditingController();
  final TextEditingController _supportNotesController = TextEditingController();
  final TextEditingController _otherNotesController = TextEditingController();
  final TextEditingController _recommendationsController =
      TextEditingController();

  String? _selectedGender;
  String? _selectedAttendanceStatus;
  String? _selectedPerformanceStatus;
  String? _selectedSupportStatus;
  DateTime? _interventionDate;
  // Track promotion and academic status
  bool? _promoted =
      null; // true = promoted, false = not promoted, null = not answered
  bool? _academicImprovement;

  // Child Labour Risk section state
  String? _hazardousWork;
  String? _reducedWorkHours;
  String? _lightWorkInLimits;
  String? _hazardousWorkFreePeriod;

  // Legal Documentation section state
  String? _hasBirthCertificate;
  String? _ongoingBirthCertProcess;
  final TextEditingController _noBirthCertReasonController =
      TextEditingController();

  // List of all classes/grades for dropdown
  final List<String> _classLevels = [
    'Nursery',
    'PP1',
    'PP2',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Form 1',
    'Form 2',
    'Form 3',
    'Form 4',
    'College/University'
  ];
  String? _selectedRemediationClass;
  String? _selectedCurrentGrade;

  // Track academic year status
  String? _academicYearEnded;

  // Education Progress Questions
  final List<YesNoQuestion> _educationQuestions = [
    YesNoQuestion(
      id: 'enrolled_in_school',
      question: '21. Is the child currently enrolled in school?',
    ),
    YesNoQuestion(
      id: 'attendance_improved',
      question: '22. Has school attendance improved since remediation?',
    ),
    YesNoQuestion(
      id: 'received_materials',
      question:
          '23. Has the child received any school materials (uniforms, books, '
          'etc.)?',
    ),
    YesNoQuestion(
      id: 'can_read_write',
      question: '24. Can the child now read and write basic text?',
    ),
    YesNoQuestion(
      id: 'advanced_grade',
      question: '25. Has the child advanced to the next grade level?',
    ),
  ];

  // Family & Caregiver Engagement Questions
  final List<YesNoQuestion> _familyEngagementQuestions = [
    YesNoQuestion(
      id: 'awareness_sessions',
      question:
          '29. Has the household received awareness-raising sessions on child labour risks?',
    ),
    YesNoQuestion(
      id: 'caregiver_understanding',
      question:
          '30. Do caregivers demonstrate improved understanding of child protection?',
    ),
    YesNoQuestion(
      id: 'school_support',
      question:
          '31. Have caregivers taken steps to keep the child in school (e.g., paying fees, providing materials)?',
    ),
  ];

  // Additional Support Provided Questions
  final List<YesNoQuestion> _additionalSupportQuestions = [
    YesNoQuestion(
      id: 'received_support',
      question:
          '32. Has the child or household received financial or material support (cash transfer, farm input, etc.)?',
    ),
    YesNoQuestion(
      id: 'referrals_made',
      question:
          '33. Were referrals made to other services (health, legal, social)?',
    ),
    YesNoQuestion(
      id: 'follow_up_planned',
      question: '34. Are there ongoing follow-up visits planned?',
    ),
  ];

  // Overall Assessment Questions
  final List<YesNoQuestion> _overallAssessmentQuestions = [
    YesNoQuestion(
      id: 'remediated_status',
      question:
          '35. Based on progress, is the child considered remediated (no longer in child labour)?',
    ),
  ];

  // Follow-up Cycle Questions
  final List<YesNoQuestion> _followUpCycleQuestions = [
    YesNoQuestion(
      id: 'visits_spaced_correctly',
      question: '38. Were the visits spaced between 3-6 months apart?',
    ),
    YesNoQuestion(
      id: 'no_child_labour_last_two_visits',
      question:
          '39. At the last two consecutive visits, was the child confirmed '
          'not to be in child labour?',
    ),
    YesNoQuestion(
      id: 'follow_up_cycle_complete',
      question:
          '40.	Based on this, can the follow-up cycle for this child be considered complete? ',
    ),
  ];

  // Controllers for additional fields
  final TextEditingController _additionalCommentsController =
      TextEditingController();
  final TextEditingController _followUpVisitsCountController =
      TextEditingController();

  @override
  void dispose() {
    _childIdController.dispose();
    _childNameController.dispose();
    _ageController.dispose();
    _communityController.dispose();
    _farmerIdController.dispose();
    _interventionDateController.dispose();
    _remediationTypeController.dispose();
    _followUpVisitsController.dispose();
    _currentSchoolController.dispose();
    _gradeLevelController.dispose();
    _attendanceRateController.dispose();
    _schoolPerformanceController.dispose();
    _challengesController.dispose();
    _supportNeededController.dispose();
    _attendanceNotesController.dispose();
    _performanceNotesController.dispose();
    _supportNotesController.dispose();
    _otherNotesController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }

  // Auto-populate sample data (replace with actual data source)
  void _autoPopulateData() {
    // This is sample data - replace with actual data source
    _childNameController.text = 'John Doe';
    _ageController.text = '12';
    _communityController.text = 'Sample Community';
    _farmerIdController.text = 'FARM123';
    _currentSchoolController.text = 'Sample Primary School';
    _gradeLevelController.text = 'Class 5';
    _attendanceRateController.text = '85';
  }

  @override
  void initState() {
    super.initState();
    _autoPopulateData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _interventionDate) {
      setState(() {
        _interventionDate = picked;
        _interventionDateController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Monitoring Assessment Form'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 16.0),
              child: Obx(
                () => Text(
                  'Score: ${_monitoringScore.value}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          backgroundColor: theme.primaryColor,
        ),
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Child Identification
                Text(
                  'Section 1: Child Identification',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Child ID/Code
                _buildFormField(
                  context: context,
                  label: '1. Child ID/Code',
                  controller: _childIdController,
                  hintText: 'Enter child ID/code',
                  isRequired: true,
                ),

                // Child Name (auto-populated)
                _buildFormField(
                  context: context,
                  label: '2. Child Name',
                  controller: _childNameController,
                  hintText: 'Auto-populated',
                  enabled: false,
                ),

                // Age and Sex Row
                Row(
                  children: [
                    // Age
                    Expanded(
                      flex: 2,
                      child: _buildFormField(
                        context: context,
                        label: '3. Age',
                        controller: _ageController,
                        hintText: 'Age',
                        keyboardType: TextInputType.number,
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sex
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sex *',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: theme.cardColor,
                            ),
                            hint: const Text('Select gender'),
                            items: ['Male', 'Female', 'Other']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedGender = value;
                                _answers['gender'] = value ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select gender';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Community
                _buildFormField(
                  context: context,
                  label: '4. Community',
                  controller: _communityController,
                  hintText: 'Enter community name',
                  isRequired: true,
                ),

                // Farmer ID/Code
                _buildFormField(
                  context: context,
                  label: '5. Farmer ID/Code',
                  controller: _farmerIdController,
                  hintText: 'Enter farmer ID/code',
                  isRequired: true,
                ),

                // Date of first remediation intervention
                _buildDateField(
                  context: context,
                  label: '6. Date of first remediation intervention',
                  controller: _interventionDateController,
                  onTap: () => _selectDate(context),
                ),

                // Form of remediation provided
                _buildFormField(
                  context: context,
                  label: '7. What form of remediation was provided?',
                  controller: _remediationTypeController,
                  hintText: 'Describe the remediation provided',
                  maxLines: 2,
                ),

                // Follow up visits
                _buildFormField(
                  context: context,
                  label: '8. How many follow up visits have been conducted so '
                      'far?',
                  controller: _followUpVisitsController,
                  hintText: 'Enter number of visits',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                const SizedBox(height: 32),

                // Section 2: Education Progress
                Text(
                  'Section 2: Education Progress',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Education Progress Questions
                _buildQuestionCard(
                  context,
                  '9. Is the child currently enrolled in school?',
                  'enrolled_in_school',
                ),
                const SizedBox(height: 12),
                _buildQuestionCard(
                  context,
                  '10. Has school attendance improved since remediation?',
                  'attendance_improved',
                ),
                const SizedBox(height: 12),
                _buildQuestionCard(
                  context,
                  '11. Has the child received any school materials (uniforms, '
                      'books, etc.)?',
                  'received_materials',
                ),
                const SizedBox(height: 12),

                // Numeracy Assessment
                Text(
                  'Ask the child to perform these calculations based on their age:',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: '• What is 1 + 2? (Right answer: 3) ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[Age ≤ 7]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '• What is 2 + 3? (Right answer: 5) ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[Age ≤ 7]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '• What is 5 - 3? (Right answer: 2) ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[8 ≤ Age ≤ 13]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '• What is 9 - 4? (Right answer: 5) ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[8 ≤ Age ≤ 13]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '• What is 9 + 7? (Right answer: 16) ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[Age ≥ 14]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '• What is 3 × 7? (Right answer: 21) ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[Age ≥ 14]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Literacy Assessment
                Text(
                  'Ask the child to read and write the following text:',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: '• "This is Ama" ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[Age ≤ 7]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '• "It is water" ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[Age ≤ 7]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '• "I like to play with my friends" ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[8 ≤ Age ≤ 13]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '• "I am going to school" ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[8 ≤ Age ≤ 13]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '• "Kofi is crying loudly" ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[Age ≥ 14]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text:
                        '• "I am good at playing both Basketball and football" ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[Age ≥ 14]',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _buildQuestionCard(
                  context,
                  '12. Can the child now read basic text? ',
                  'received_materials',
                ),
                const SizedBox(height: 12),
                _buildQuestionCard(
                  context,
                  '13. Can the child now write basic text? ',
                  'received_materials',
                ),
                _buildQuestionCard(
                  context,
                  '14. Can the child now perform basic calculations? ',
                  'received_materials',
                ),
                const SizedBox(height: 12),
                _buildQuestionCard(
                  context,
                  '15. Has the child advanced to the next grade level?  ',
                  'received_materials',
                ),
                // 1. Class at time of remediation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '16. At the time of remediation, what class was the '
                      'child enrolled in?',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedRemediationClass,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        hintText: 'Select class/grade',
                      ),
                      items: _classLevels.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRemediationClass = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a class/grade';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Academic year ended question
                _buildQuestionCard(
                  context,
                  '17. \tHas the academic year ended?',
                  'academic_year_ended',
                  onAnswerChanged: (answer) {
                    setState(() {
                      _academicYearEnded = answer;
                      // Reset promotion status when academic year answer changes
                      if (answer != 'Yes') {
                        _promoted = null;
                        _selectedCurrentGrade =
                            null; // Reset grade when academic year changes
                      }
                    });
                  },
                ),

                // Promotion question (only shown if academic year has ended)
                if (_academicYearEnded == 'Yes')
                  _buildQuestionCard(
                    context,
                    '18. Has the child been promoted?',
                    'child_promoted',
                    onAnswerChanged: (answer) {
                      setState(() {
                        _promoted = answer == 'Yes';
                        _answers['child_promoted'] = answer;
                        _academicImprovement = null;
                        if (!_promoted!) {
                          _selectedCurrentGrade = null;
                        }
                      });
                    },
                    initialAnswer: _answers['child_promoted'],
                  ),
                const SizedBox(height: 20),

                // 4. If promoted, show current grade dropdown
                if (_promoted == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '19. What is the new grade?',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCurrentGrade,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          hintText: 'Select new grade',
                        ),
                        items: _classLevels.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCurrentGrade = newValue;
                          });
                        },
                        validator: (value) {
                          if (_promoted == true &&
                              (value == null || value.isEmpty)) {
                            return 'Please select the new grade';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                // 5. If not promoted, show improvement question
                if (_promoted == false)
                  _buildQuestionCard(
                    context,
                    '20. Has there been an improvement in reading, writing and '
                        'calculations?',
                    'academic_improvement',
                    onAnswerChanged: (answer) {
                      setState(() {
                        _academicImprovement = answer == 'Yes';
                      });
                    },
                  ),

                // 6. Show recommendations field only if improvement is 'No'
                if (_academicImprovement == false) ...[
                  const SizedBox(height: 20),
                  _buildFormField(
                    context: context,
                    label: '21. What are the recommendations?',
                    controller: _recommendationsController,
                    hintText: 'Enter recommendations for improvement...',
                    maxLines: 3,
                    isRequired: true,
                  ),
                ],
                const SizedBox(height: 24),

                // Section 3: Child Labour Risk
                Text(
                  'Section 3: Child Labour Risk',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Hazardous work question
                _buildQuestionCard(
                  context,
                  '22. Is the child currently engaged in any hazardous work?',
                  'hazardous_work',
                  onAnswerChanged: (answer) {
                    setState(() {
                      _hazardousWork = answer;
                    });
                  },
                ),

                // 2. Reduced work hours question
                _buildQuestionCard(
                  context,
                  '23. Has the child reduced hours spent on farm or '
                      'work-related tasks?',
                  'reduced_work_hours',
                  onAnswerChanged: (answer) {
                    setState(() {
                      _reducedWorkHours = answer;
                    });
                  },
                ),

                // 3. Light work question
                _buildQuestionCard(
                  context,
                  '24. Is the child involved in any permitted light work '
                      'within acceptable limits?',
                  'light_work_in_limits',
                  onAnswerChanged: (answer) {
                    setState(() {
                      _lightWorkInLimits = answer;
                    });
                  },
                ),

                // 4. Hazardous work free period question
                _buildQuestionCard(
                  context,
                  '25. Has the child remained out of hazardous work for at '
                      'least two consecutive visits?',
                  'hazardous_work_free_period',
                  onAnswerChanged: (answer) {
                    setState(() {
                      _hazardousWorkFreePeriod = answer;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Section 4: Legal Documentation
                Text(
                  'Section 4: Legal Documentation',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Birth certificate question
                _buildQuestionCard(
                  context,
                  '26. Does the child now have a birth certificate?',
                  'has_birth_certificate',
                  onAnswerChanged: (answer) {
                    setState(() {
                      _hasBirthCertificate = answer;
                      // Reset related fields when answer changes
                      if (answer == 'Yes') {
                        _ongoingBirthCertProcess = null;
                        _noBirthCertReasonController.clear();
                      }
                    });
                  },
                ),

                // 2. Ongoing process question (only shown if no birth certificate)
                if (_hasBirthCertificate == 'No')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionCard(
                        context,
                        '27. Is there an ongoing process to obtain one?',
                        'ongoing_birth_cert_process',
                        onAnswerChanged: (answer) {
                          setState(() {
                            _ongoingBirthCertProcess = answer;
                            // Clear reason if process is ongoing
                            if (answer == 'Yes') {
                              _noBirthCertReasonController.clear();
                            }
                          });
                        },
                      ),

                      // 3. Reason for no birth certificate (only shown if no and no ongoing process)
                      if (_ongoingBirthCertProcess == 'No')
                        _buildFormField(
                          context: context,
                          label: '28. If no, why?',
                          controller: _noBirthCertReasonController,
                          hintText: 'Enter the reason...',
                          maxLines: 2,
                          isRequired: true,
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                const SizedBox(height: 24),

                // Section 5: Family & Caregiver Engagement
                Text(
                  'Section 5: Family & Caregiver Engagement',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Family & Caregiver Engagement Questions
                ..._familyEngagementQuestions.map((q) => _buildQuestionCard(
                      context,
                      q.question,
                      q.id,
                    )),
                const SizedBox(height: 24),

                // Section 6: Additional Support Provided
                Text(
                  'Section 6: Additional Support Provided',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Additional Support Questions
                ..._additionalSupportQuestions.map((q) => _buildQuestionCard(
                      context,
                      q.question,
                      q.id,
                    )),
                const SizedBox(height: 24),

                // Section 7: Overall Assessment
                Text(
                  'Section 7: Overall Assessment',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Overall Assessment Questions
                ..._overallAssessmentQuestions.map((q) => _buildQuestionCard(
                      context,
                      q.question,
                      q.id,
                    )),
                const SizedBox(height: 16),

                // Additional comments field
                _buildFormField(
                  context: context,
                  label: 'Additional comments or observations',
                  controller: _additionalCommentsController,
                  hintText: 'Enter any additional comments or observations...',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Section 8: Follow-up Cycle Completion
                Text(
                  'Section 8: Follow-up Cycle Completion',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Follow-up visits count
                _buildFormField(
                  context: context,
                  label: '37. How many follow-up visits have been conducted '
                      'since the child was first identified?',
                  controller: _followUpVisitsCountController,
                  hintText: 'Enter number of visits',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Follow-up Cycle Questions
                ..._followUpCycleQuestions.map((q) => _buildQuestionCard(
                      context,
                      q.question,
                      q.id,
                    )),
                const SizedBox(height: 24),

                // Submit Buttons
                _buildFormButtons(context),
              ],
            ),
          ),
        )));
  }

  /// Builds each question card with Yes/No full-width buttons
  Widget _buildQuestionCard(
    BuildContext context,
    String question,
    String key, {
    Function(String)? onAnswerChanged,
    String? initialAnswer,
  }) {
    final theme = Theme.of(context);
    final isYesSelected = _answers[key] == "Yes" || initialAnswer == "Yes";
    final isNoSelected = _answers[key] == "No" ||
        (initialAnswer == "No" && _answers[key] == null);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Yes button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _answers[key] = "Yes";
                      });
                      if (onAnswerChanged != null) {
                        onAnswerChanged('Yes');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isYesSelected
                            ? theme.primaryColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isYesSelected
                              ? Colors.white
                              : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // No button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _answers[key] = "No";
                      });
                      if (onAnswerChanged != null) {
                        onAnswerChanged('No');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isNoSelected
                            ? theme.colorScheme.error
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "No",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isNoSelected
                              ? Colors.white
                              : theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Update answers map when a question is answered
  void _updateAnswers(String questionId, String answer) {
    _answers[questionId] = answer;
    // Update score if needed
    if (answer == 'Yes') {
      _monitoringScore.value++;
    }
  }

  Widget _buildSubmitButton(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saveAsDraft,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.primaryColor),
                ),
                child: Text(
                  'Save as Draft',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Submit',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _saveAsDraft() {
    // TODO: Implement save as draft functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form saved as draft')),
    );
  }

  void _submitForm() {
    // Collect all form data
    final formData = {
      'childId': _childIdController.text,
      'childName': _childNameController.text,
      'age': _ageController.text,
      'gender': _selectedGender,
      'community': _communityController.text,
      'farmerId': _farmerIdController.text,
      'interventionDate': _interventionDateController.text,
      'remediationType': _remediationTypeController.text,
      'followUpVisits': _followUpVisitsController.text,
      'education': {
        'currentSchool': _currentSchoolController.text,
        'gradeLevel': _gradeLevelController.text,
        'attendanceRate': _attendanceRateController.text,
        'attendingSchool': _educationQuestions[0].selectedValue,
        'regularAttendance': _educationQuestions[1].selectedValue,
        'satisfactoryPerformance': _educationQuestions[2].selectedValue,
        'receivingSupport': _educationQuestions[3].selectedValue,
        'attendanceNotes': _attendanceNotesController.text,
        'performanceNotes': _performanceNotesController.text,
        'supportNotes': _supportNotesController.text,
        'challenges': _challengesController.text,
        'supportNeeded': _supportNeededController.text,
        'additionalNotes': _otherNotesController.text,
      },
    };

    // TODO: Submit form data to API
    print('Form submitted: $formData');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form submitted successfully')),
    );

    // Navigate back or reset form
    Navigator.of(context).pop();
  }

  // Build the form buttons row
  Widget _buildFormButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.save),
              label: const Text("Save Draft"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveAsDraft();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.send),
              label: const Text("Submit"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _submitForm();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Form field widget for text input
Widget _buildFormField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  String? hintText,
  bool isRequired = false,
  bool enabled = true,
  int maxLines = 1,
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
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
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: enabled ? Theme.of(context).cardColor : Colors.grey[100],
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    ),
  );
}

// Date picker field widget
Widget _buildDateField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required VoidCallback onTap,
  bool isRequired = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
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
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: 'Select date',
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    ),
  );
}
