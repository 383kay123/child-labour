import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/districts_repo.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/farmers_repo.dart';
import 'package:human_rights_monitor/controller/models/districts/districts_model.dart';
import 'package:human_rights_monitor/controller/models/farmers/farmers_model.dart';
import 'package:intl/intl.dart';

// Import the controller
import 'monitoring_assessment_form_controller.dart';

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
  final _formKey = GlobalKey<FormState>();
  late final MonitoringAssessmentFormController _controller;

  // Form controllers
  final TextEditingController _childIdController = TextEditingController();
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _communityController = TextEditingController();
  final TextEditingController _farmerIdController = TextEditingController();
  final TextEditingController _interventionDateController = TextEditingController();
  final TextEditingController _remediationTypeController = TextEditingController();
  final TextEditingController _followUpVisitsController = TextEditingController();
  final TextEditingController _recommendationsController = TextEditingController();
  final TextEditingController _noBirthCertReasonController = TextEditingController();
  final TextEditingController _additionalCommentsController = TextEditingController();
  final TextEditingController _followUpVisitsCountController = TextEditingController();

  // Selection state
  String? _selectedGender;
  String? _selectedCommunity;
  String? _selectedFarmerId;
  
  // District repository and state
  final DistrictRepository _districtRepo = DistrictRepository();
  final RxList<District> _districts = <District>[].obs;
  final RxBool _isLoadingDistricts = false.obs;
  
  // Farmers list
  final FarmerRepository _farmerRepo = FarmerRepository();
  final RxList<Farmer> _farmers = <Farmer>[].obs;
  final RxBool _isLoadingFarmers = false.obs;
  

  // Child Labour Risk section state
  String? _hazardousWork;
  String? _reducedWorkHours;
  String? _lightWorkInLimits;
  String? _hazardousWorkFreePeriod;

  // Legal Documentation section state
  String? _hasBirthCertificate;
  String? _ongoingBirthCertProcess;
  
  // Academic status
  bool? _promoted;
  bool? _academicImprovement;
  String? _selectedCurrentGrade;
  bool? _academicYearEnded;

  // Answers map to track question responses
  final Map<String, String> _answers = {};
  final RxInt _monitoringScore = 0.obs;

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
    _recommendationsController.dispose();
    _noBirthCertReasonController.dispose();
    _additionalCommentsController.dispose();
    _followUpVisitsCountController.dispose();
    _isLoadingDistricts.close();
    _districts.close();
    _isLoadingFarmers.close();
    _farmers.close();
    super.dispose();
  }

  // Load districts from database
  Future<void> _loadDistricts() async {
    _isLoadingDistricts.value = true;
    try {
      final districts = await _districtRepo.getAllDistricts();
      _districts.assignAll(districts);
    } catch (e) {
      debugPrint('Error loading districts: $e');
    } finally {
      _isLoadingDistricts.value = false;
    }
  }

  Future<void> _loadFarmers() async {
    _isLoadingFarmers.value = true;
    try {
      final farmers = await _farmerRepo.getFirst10Farmers();
      _farmers.assignAll(farmers);
    } catch (e) {
      debugPrint('Error loading farmers: $e');
    } finally {
      _isLoadingFarmers.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.put(MonitoringAssessmentFormController());
    _loadDistricts();
    _loadFarmers();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _interventionDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Update answers map when a question is answered and update controller
  void _updateAnswers(String questionId, String answer) {
    setState(() {
      _answers[questionId] = answer;
      _updateScore();
    });
    
    // Update the controller based on the question
    _updateControllerData(questionId, answer == 'Yes');
  }

  void _updateControllerData(String questionId, bool value) {
    switch (questionId) {
      case 'enrolled_in_school':
        _controller.updateFormData(isEnrolledInSchool: value);
        break;
      case 'attendance_improved':
        _controller.updateFormData(attendanceImproved: value);
        break;
      case 'received_materials':
        _controller.updateFormData(receivedSchoolMaterials: value);
        break;
      case 'can_read_text':
        _controller.updateFormData(canReadBasicText: value);
        break;
      case 'can_write_text':
        _controller.updateFormData(canWriteBasicText: value);
        break;
      case 'can_do_calculations':
        _controller.updateFormData(canDoCalculations: value);
        break;
      case 'advanced_grade_level':
        _controller.updateFormData(advancedToNextGrade: value);
        break;
      case 'academic_year_ended':
        _controller.updateFormData(academicYearEnded: value);
        break;
      case 'child_promoted':
        _controller.updateFormData(promoted: value);
        break;
      case 'academic_improvement':
        _controller.updateFormData(academicImprovement: value);
        break;
      case 'hazardous_work':
        _controller.updateFormData(engagedInHazardousWork: value);
        break;
      case 'reduced_work_hours':
        _controller.updateFormData(reducedWorkHours: value);
        break;
      case 'light_work_in_limits':
        _controller.updateFormData(involvedInLightWork: value);
        break;
      case 'hazardous_work_free_period':
        _controller.updateFormData(outOfHazardousWork: value);
        break;
      case 'has_birth_certificate':
        _controller.updateFormData(hasBirthCertificate: value);
        break;
      case 'ongoing_birth_cert_process':
        _controller.updateFormData(ongoingBirthCertProcess: value);
        break;
      case 'awareness_sessions':
        _controller.updateFormData(receivedAwarenessSessions: value);
        break;
      case 'caregiver_understanding':
        _controller.updateFormData(improvedUnderstanding: value);
        break;
      case 'school_support':
        _controller.updateFormData(caregiversSupportSchool: value);
        break;
      case 'received_support':
        _controller.updateFormData(receivedFinancialSupport: value);
        break;
      case 'referrals_made':
        _controller.updateFormData(referralsMade: value);
        break;
      case 'follow_up_planned':
        _controller.updateFormData(ongoingFollowUpPlanned: value);
        break;
      case 'remediated_status':
        _controller.updateFormData(consideredRemediated: value);
        break;
      case 'visits_spaced_correctly':
        _controller.updateFormData(visitsSpacedCorrectly: value);
        break;
      case 'no_child_labour_last_two_visits':
        _controller.updateFormData(confirmedNotInChildLabour: value);
        break;
      case 'follow_up_cycle_complete':
        _controller.updateFormData(followUpCycleComplete: value);
        break;
    }
  }

  void _updateScore() {
    int score = 0;
    
    // Education Progress (questions 9-15)
    if (_answers['enrolled_in_school'] == 'Yes') score += 10;
    if (_answers['attendance_improved'] == 'Yes') score += 10;
    if (_answers['received_materials'] == 'Yes') score += 10;
    if (_answers['can_read_text'] == 'Yes') score += 10;
    if (_answers['can_write_text'] == 'Yes') score += 10;
    if (_answers['can_do_calculations'] == 'Yes') score += 10;
    if (_answers['advanced_grade_level'] == 'Yes') score += 10;
    
    // Child Labour Risk (questions 22-25)
    if (_answers['hazardous_work'] == 'No') score += 10;
    if (_answers['reduced_work_hours'] == 'Yes') score += 10;
    if (_answers['light_work_in_limits'] == 'Yes') score += 5;
    if (_answers['hazardous_work_free_period'] == 'Yes') score += 10;
    
    // Legal Documentation (questions 26-28)
    if (_answers['has_birth_certificate'] == 'Yes') score += 10;
    if (_answers['ongoing_birth_cert_process'] == 'Yes') score += 5;
    
    _monitoringScore.value = score;
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

                // Child ID/Code Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Child ID/Code *',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Select a child'),
                          value: _controller.selectedChildCode.value.isEmpty ? null : _controller.selectedChildCode.value,
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Select a child'),
                            ),
                            ..._controller.childOptions.map((child) {
                              return DropdownMenuItem<String>(
                                value: child['code'],
                                child: Text('${child['code']} - ${child['name']}'),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _controller.setSelectedChild(value);
                              if (value != null) {
                                final selectedChild = _controller.childOptions.firstWhere(
                                  (child) => child['code'] == value,
                                  orElse: () => {'code': value, 'name': 'Unknown'},
                                );
                                _childNameController.text = selectedChild['name'] ?? '';
                                _ageController.text = '12';
                              } else {
                                _childNameController.clear();
                                _ageController.clear();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    if (_controller.selectedChildCode.value.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                        child: Text(
                          'Please select a child',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
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
                              });
                              _controller.selectedGender.value = value ?? '';
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

                // Community Dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '4. District',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          children: const [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (_isLoadingDistricts.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (_districts.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('No districts available. Please sync data first.'),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: _selectedCommunity,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                          hint: const Text('Select District'),
                          isExpanded: true,
                          items: _districts.map<DropdownMenuItem<String>>((District district) {
                            return DropdownMenuItem<String>(
                              value: district.district,
                              child: Text(district.district),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCommunity = newValue;
                                _communityController.text = newValue;
                              });
                              _controller.selectedCommunity.value = newValue;
                              _controller.communityController.text = newValue;
                              
                              // Store the selected district ID for reference if needed
                              final selectedDistrict = _districts.firstWhereOrNull(
                                (d) => d.district == newValue
                              );
                              if (selectedDistrict != null) {
                                _controller.formData.value.communityId = selectedDistrict.id;
                              }
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a district';
                            }
                            return null;
                          },
                        );
                      }),
                    ],
                  ),
                ),

                // Farmer ID/Code Dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '5. Farmer ID/Code',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          children: const [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (_isLoadingFarmers.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (_farmers.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('No farmers available. Please sync data first.'),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: _selectedFarmerId,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outlineVariant,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outlineVariant,
                                width: 1.0,
                              ),
                            ),
                            suffixIcon: _isLoadingFarmers.value
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : null,
                          ),
                          hint: const Text('Select Farmer Code'),
                          isExpanded: true,
                          items: _farmers.map<DropdownMenuItem<String>>((Farmer farmer) {
                            return DropdownMenuItem<String>(
                              value: farmer.farmerCode,
                              child: Text('${farmer.farmerCode} - ${farmer.firstName} ${farmer.lastName}'),
                            );
                          }).toList(),
                          onChanged: _isLoadingFarmers.value
                              ? null
                              : (String? newValue) {
                                  setState(() {
                                    _selectedFarmerId = newValue;
                                    _farmerIdController.text = newValue ?? '';
                                  });
                                  _controller.selectedFarmerId.value = newValue ?? '';
                                  _controller.farmerIdController.text = newValue ?? '';
                                },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a farmer ID';
                            }
                            return null;
                          },
                        );
                      }),
                        
                      
                    ],
                  ),
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
                  label: '8. How many follow up visits have been conducted so far?',
                  controller: _followUpVisitsController,
                  hintText: 'Enter number of visits',
                  keyboardType: TextInputType.number,
                ),

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
                  '11. Has the child received any school materials (uniforms, books, etc.)?',
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '• "I am good at playing both Basketball and football" ',
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '[Age ≥ 14]',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _buildQuestionCard(
                  context,
                  '12. Can the child now read basic text?',
                  'can_read_text',
                ),
                const SizedBox(height: 12),
                _buildQuestionCard(
                  context,
                  '13. Can the child now write basic text?',
                  'can_write_text',
                ),
                _buildQuestionCard(
                  context,
                  '14. Can the child now perform basic calculations?',
                  'can_do_calculations',
                ),
                const SizedBox(height: 12),
                _buildQuestionCard(
                  context,
                  '15. Has the child advanced to the next grade level?',
                  'advanced_grade_level',
                ),

                // Class at time of remediation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '16. At the time of remediation, what class was the child enrolled in?',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedRemediationClass,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        _controller.selectedRemediationClass.value = newValue ?? '';
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Academic year ended question
                _buildQuestionCard(
                  context,
                  '17. Has the academic year ended?',
                  'academic_year_ended',
                  onAnswerChanged: (answer) {
                    setState(() {
                      _academicYearEnded = answer == 'Yes';
                      if (answer != 'Yes') {
                        _promoted = null;
                        _selectedCurrentGrade = null;
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
                        _academicImprovement = null;
                        if (!_promoted!) {
                          _selectedCurrentGrade = null;
                        }
                      });
                    },
                  ),
                const SizedBox(height: 20),

                // If promoted, show current grade dropdown
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          _controller.selectedCurrentGrade.value = newValue ?? '';
                        },
                      ),
                    ],
                  ),

                // If not promoted, show improvement question
                if (_promoted == false)
                  _buildQuestionCard(
                    context,
                    '20. Has there been an improvement in reading, writing and calculations?',
                    'academic_improvement',
                    onAnswerChanged: (answer) {
                      setState(() {
                        _academicImprovement = answer == 'Yes';
                      });
                    },
                  ),

                // Show recommendations field only if improvement is 'No'
                if (_academicImprovement == false) ...[
                  const SizedBox(height: 20),
                  _buildFormField(
                    context: context,
                    label: '21. What are the recommendations?',
                    controller: _recommendationsController,
                    hintText: 'Enter recommendations for improvement...',
                    maxLines: 3,
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

                // Hazardous work question
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

                // Reduced work hours question
                _buildQuestionCard(
                  context,
                  '23. Has the child reduced hours spent on farm or work-related tasks?',
                  'reduced_work_hours',
                  onAnswerChanged: (answer) {
                    setState(() {
                      _reducedWorkHours = answer;
                    });
                  },
                ),

                // Light work question
                _buildQuestionCard(
                  context,
                  '24. Is the child involved in any permitted light work within acceptable limits?',
                  'light_work_in_limits',
                  onAnswerChanged: (answer) {
                    setState(() {
                      _lightWorkInLimits = answer;
                    });
                  },
                ),

                // Hazardous work free period question
                _buildQuestionCard(
                  context,
                  '25. Has the child remained out of hazardous work for at least two consecutive visits?',
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

                // Birth certificate question
                _buildQuestionCard(
                  context,
                  '26. Does the child now have a birth certificate?',
                  'has_birth_certificate',
                  onAnswerChanged: (answer) {
                    setState(() {
                      _hasBirthCertificate = answer;
                      if (answer == 'Yes') {
                        _ongoingBirthCertProcess = null;
                        _noBirthCertReasonController.clear();
                      }
                    });
                  },
                ),

                // Ongoing process question (only shown if no birth certificate)
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
                            if (answer == 'Yes') {
                              _noBirthCertReasonController.clear();
                            }
                          });
                        },
                      ),

                      // Reason for no birth certificate (only shown if no and no ongoing process)
                      if (_ongoingBirthCertProcess == 'No')
                        _buildFormField(
                          context: context,
                          label: '28. If no, why?',
                          controller: _noBirthCertReasonController,
                          hintText: 'Enter the reason...',
                          maxLines: 2,
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
                _buildQuestionCard(
                  context,
                  '29. Has the household received awareness-raising sessions on child labour risks?',
                  'awareness_sessions',
                ),
                _buildQuestionCard(
                  context,
                  '30. Do caregivers demonstrate improved understanding of child protection?',
                  'caregiver_understanding',
                ),
                _buildQuestionCard(
                  context,
                  '31. Have caregivers taken steps to keep the child in school (e.g., paying fees, providing materials)?',
                  'school_support',
                ),
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
                _buildQuestionCard(
                  context,
                  '32. Has the child or household received financial or material support (cash transfer, farm input, etc.)?',
                  'received_support',
                ),
                _buildQuestionCard(
                  context,
                  '33. Were referrals made to other services (health, legal, social)?',
                  'referrals_made',
                ),
                _buildQuestionCard(
                  context,
                  '34. Are there ongoing follow-up visits planned?',
                  'follow_up_planned',
                ),
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
                _buildQuestionCard(
                  context,
                  '35. Based on progress, is the child considered remediated (no longer in child labour)?',
                  'remediated_status',
                ),
                const SizedBox(height: 16),

                // Additional comments field
                _buildFormField(
                  context: context,
                  label: '36. Additional comments or observations',
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
                  label: '37. How many follow-up visits have been conducted since the child was first identified?',
                  controller: _followUpVisitsCountController,
                  hintText: 'Enter number of visits',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Follow-up Cycle Questions
                _buildQuestionCard(
                  context,
                  '38. Were the visits spaced between 3-6 months apart?',
                  'visits_spaced_correctly',
                ),
                _buildQuestionCard(
                  context,
                  '39. At the last two consecutive visits, was the child confirmed not to be in child labour?',
                  'no_child_labour_last_two_visits',
                ),
                _buildQuestionCard(
                  context,
                  '40. Based on this, can the follow-up cycle for this child be considered complete?',
                  'follow_up_cycle_complete',
                ),
                const SizedBox(height: 24),

                // Submit Buttons
                _buildFormButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds each question card with Yes/No full-width buttons
  Widget _buildQuestionCard(
    BuildContext context,
    String question,
    String key, {
    Function(String)? onAnswerChanged,
  }) {
    final theme = Theme.of(context);
    final isYesSelected = _answers[key] == "Yes";
    final isNoSelected = _answers[key] == "No";

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
                      _updateAnswers(key, "Yes");
                      if (onAnswerChanged != null) {
                        onAnswerChanged('Yes');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isYesSelected ? theme.primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isYesSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
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
                      _updateAnswers(key, "No");
                      if (onAnswerChanged != null) {
                        onAnswerChanged('No');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isNoSelected ? theme.colorScheme.error : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "No",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isNoSelected ? Colors.white : theme.colorScheme.error,
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

  Future<void> _saveAsDraft() async {
    try {
      // Update text controllers in the controller
      _controller.childIdController.text = _childIdController.text;
      _controller.childNameController.text = _childNameController.text;
      _controller.ageController.text = _ageController.text;
      _controller.interventionDateController.text = _interventionDateController.text;
      _controller.remediationTypeController.text = _remediationTypeController.text;
      _controller.followUpVisitsController.text = _followUpVisitsController.text;
      _controller.recommendationsController.text = _recommendationsController.text;
      _controller.noBirthCertReasonController.text = _noBirthCertReasonController.text;
      _controller.additionalCommentsController.text = _additionalCommentsController.text;
      _controller.followUpVisitsCountController.text = _followUpVisitsCountController.text;

      // Save as draft
      final saveDraftSuccess = await _controller.saveAsDraft();
      
      if (saveDraftSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form saved as draft'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving draft: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    try {
      // Update text controllers in the controller
      _controller.childIdController.text = _childIdController.text;
      _controller.childNameController.text = _childNameController.text;
      _controller.ageController.text = _ageController.text;
      _controller.interventionDateController.text = _interventionDateController.text;
      _controller.remediationTypeController.text = _remediationTypeController.text;
      _controller.followUpVisitsController.text = _followUpVisitsController.text;
      _controller.recommendationsController.text = _recommendationsController.text;
      _controller.noBirthCertReasonController.text = _noBirthCertReasonController.text;
      _controller.additionalCommentsController.text = _additionalCommentsController.text;
      _controller.followUpVisitsCountController.text = _followUpVisitsCountController.text;

      // Submit the form
      final submitSuccess = await _controller.submitForm();
      
      if (submitSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Error submitting form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting form: $e')),
        );
      }
    }
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
              onPressed: _saveAsDraft,
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