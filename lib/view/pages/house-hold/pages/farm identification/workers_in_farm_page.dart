import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import 'adults_information_page.dart';

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class WorkersInFarmPage extends StatefulWidget {
  const WorkersInFarmPage({super.key});

  @override
  State<WorkersInFarmPage> createState() => _WorkersInFarmPageState();
}

class _WorkersInFarmPageState extends State<WorkersInFarmPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _agreementSectionKey = GlobalKey();
  String? _hasRecruitedWorker;
  String? _everRecruitedWorker; // For the follow-up question
  String? _workerAgreementType; // For the agreement type question
  String? _tasksClarified; // For task clarification question
  String? _additionalTasks; // For tracking if worker performs additional tasks
  String? _refusalAction; // For tracking action when worker refuses tasks
  String?
      _salaryPaymentFrequency; // For tracking how often workers receive full salaries

  // Track agreement responses for statements
  final Map<String, String?> _agreementResponses = {
    // Salary and Debt Related
    'salary_workers': null,
    'recruit_1': null,
    'recruit_2': null,
    'recruit_3': null,

    // Working Conditions
    'conditions_1': null,
    'conditions_2': null,
    'conditions_3': null,
    'conditions_4': null,
    'conditions_5': null,

    // Leaving Employment
    'leaving_1': null,
    'leaving_2': null,
  };

  final TextEditingController _otherAgreementController =
      TextEditingController();
  bool _permanentLabor = false;
  bool _casualLabor = false;

  @override
  void initState() {
    super.initState();
    _hasRecruitedWorker = '0'; // Default to 'No'
    _everRecruitedWorker = 'No'; // Default to 'No' for ever recruited
  }

  @override
  void dispose() {
    _otherAgreementController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Check if all required form fields are complete
  bool get _isFormComplete {
    // Check if the main recruitment question is answered
    if (_hasRecruitedWorker == null) return false;

    // If recruited workers in past year, check if at least one type is selected
    if (_hasRecruitedWorker == '1') {
      if (!_permanentLabor && !_casualLabor) return false;

      // Check if all agreement responses are filled
      if (_agreementResponses.values.any((response) => response == null)) {
        return false;
      }
    }

    // If not recruited in past year, check if ever recruited question is answered
    if (_hasRecruitedWorker == '0') {
      if (_everRecruitedWorker == null) return false;

      // If they have recruited before, check agreement responses
      if (_everRecruitedWorker == 'Yes' &&
          _agreementResponses.values.any((response) => response == null)) {
        return false;
      }
    }
    // If 'Other' is selected, check if text is provided
    if (_refusalAction == 'Other' &&
        _otherAgreementController.text.trim().isEmpty) {
      return false;
    }

    // Check if salary payment frequency is answered
    if (_salaryPaymentFrequency == null) return false;

    // Check if all agreement statements are answered
    for (var response in _agreementResponses.values) {
      if (response == null) return false;
    }

    return true;
  }

  // Validate the form before proceeding
  bool _validateForm() {
    if (!_isFormComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Widget _buildRecruitmentTypeCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CheckboxListTile(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RadioListTile<String>(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      tileColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  // Helper method to create a consistent card widget
  Widget _buildCard({
    required Widget child,
    double? elevation,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: elevation ?? 0,
      margin: const EdgeInsets.only(bottom: _Spacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: child,
      ),
    );
  }

  // Helper method to build a section of agreement statements
  Widget _buildAgreementSection({
    required List<String> statements,
    required List<String> ids,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _Spacing.md),
        ...List.generate(statements.length, (index) {
          return _buildAgreementCard(
            statement: '${index + 1}. ${statements[index]}',
            statementId: ids[index],
          );
        }),
      ],
    );
  }

  Widget _buildAgreementCard({
    required String statement,
    required String statementId,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statement,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: _Spacing.md),
          Row(
            children: [
              _buildAgreementButton(
                label: 'Agree',
                isSelected: _agreementResponses[statementId] == 'Agree',
                onPressed: () {
                  setState(() {
                    _agreementResponses[statementId] = 'Agree';
                  });
                },
              ),
              const SizedBox(width: 16),
              _buildAgreementButton(
                label: 'Disagree',
                isSelected: _agreementResponses[statementId] == 'Disagree',
                onPressed: () {
                  setState(() {
                    _agreementResponses[statementId] = 'Disagree';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          side: BorderSide(
            color: isSelected
                ? AppTheme.primaryColor
                : isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: _Spacing.md),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isSelected
                ? AppTheme.primaryColor
                : isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Workers in the farm',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(_Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Card: Recruitment Question
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Have you recruited at least one worker during the past year?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: _Spacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRadioOption(
                          value: '1',
                          groupValue: _hasRecruitedWorker,
                          label: 'Yes',
                          onChanged: (value) {
                            setState(() {
                              _hasRecruitedWorker = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: '0',
                          groupValue: _hasRecruitedWorker,
                          label: 'No',
                          onChanged: (value) {
                            setState(() {
                              _hasRecruitedWorker = value;
                              _permanentLabor = false;
                              _casualLabor = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Worker Recruitment Type Card (Conditional)
              if (_hasRecruitedWorker == '1') ...[
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Do you recruit workers for...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: _Spacing.md),
                      _buildRecruitmentTypeCheckbox(
                        value: _permanentLabor,
                        label: 'Permanent labor',
                        onChanged: (value) {
                          setState(() {
                            _permanentLabor = value ?? false;
                          });
                        },
                      ),
                      _buildRecruitmentTypeCheckbox(
                        value: _casualLabor,
                        label: 'Casual labor',
                        onChanged: (value) {
                          setState(() {
                            _casualLabor = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Second Card: Follow-up question when 'No' is selected in the first question
              if (_hasRecruitedWorker == '0')
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have you ever recruited a worker before?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: _Spacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRadioOption(
                            value: 'Yes',
                            groupValue: _everRecruitedWorker,
                            label: 'Yes',
                            onChanged: (value) {
                              setState(() {
                                _everRecruitedWorker = value;
                              });
                            },
                          ),
                          _buildRadioOption(
                            value: 'No',
                            groupValue: _everRecruitedWorker,
                            label: 'No',
                            onChanged: (value) {
                              setState(() {
                                _everRecruitedWorker = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Workers Recruitment Title
              Padding(
                padding: const EdgeInsets.only(
                    top: _Spacing.lg, bottom: _Spacing.sm),
                child: Text(
                  'Workers Recruitment',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
              ),

              // Worker Agreement Type Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What kind of agreement do you have with your workers?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: _Spacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRadioOption(
                          value: 'Verbal agreement without witness',
                          groupValue: _workerAgreementType,
                          label: 'Verbal agreement without witness',
                          onChanged: (value) {
                            setState(() {
                              _workerAgreementType = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'Verbal agreement with witness',
                          groupValue: _workerAgreementType,
                          label: 'Verbal agreement with witness',
                          onChanged: (value) {
                            setState(() {
                              _workerAgreementType = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'Written agreement without witness',
                          groupValue: _workerAgreementType,
                          label: 'Written agreement without witness',
                          onChanged: (value) {
                            setState(() {
                              _workerAgreementType = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'Written contract with witness',
                          groupValue: _workerAgreementType,
                          label: 'Written contract with witness',
                          onChanged: (value) {
                            setState(() {
                              _workerAgreementType = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'Other (specify)',
                          groupValue: _workerAgreementType,
                          label: 'Other (specify)',
                          onChanged: (value) {
                            setState(() {
                              _workerAgreementType = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Other Agreement Type Specification Card
              if (_workerAgreementType == 'Other (specify)')
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'If other,please specify',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: _Spacing.md),
                      TextFormField(
                        controller: _otherAgreementController,
                        decoration: InputDecoration(
                          hintText: 'Enter agreement type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 10.0,
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

              // Task Clarification Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Were the tasks to be performed by the worker clarified with them during the recruitment?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: _Spacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRadioOption(
                          value: 'Yes',
                          groupValue: _tasksClarified,
                          label: 'Yes',
                          onChanged: (value) {
                            setState(() {
                              _tasksClarified = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'No',
                          groupValue: _tasksClarified,
                          label: 'No',
                          onChanged: (value) {
                            setState(() {
                              _tasksClarified = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Additional tasks question
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Does the worker perform tasks for you or your family members other than those agreed upon?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: _Spacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRadioOption(
                          value: 'Yes',
                          groupValue: _additionalTasks,
                          label: 'Yes',
                          onChanged: (value) {
                            setState(() {
                              _additionalTasks = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'No',
                          groupValue: _additionalTasks,
                          label: 'No',
                          onChanged: (value) {
                            setState(() {
                              _additionalTasks = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Refusal Action Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What do you do when a worker refuses to perform a task?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: _Spacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRadioOption(
                          value: 'I find a compromise',
                          groupValue: _refusalAction,
                          label: 'I find a compromise',
                          onChanged: (value) {
                            setState(() {
                              _refusalAction = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'I withdraw part of their salary',
                          groupValue: _refusalAction,
                          label: 'I withdraw part of their salary',
                          onChanged: (value) {
                            setState(() {
                              _refusalAction = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'I issue a warning',
                          groupValue: _refusalAction,
                          label: 'I issue a warning',
                          onChanged: (value) {
                            setState(() {
                              _refusalAction = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'Other',
                          groupValue: _refusalAction,
                          label: 'Other',
                          onChanged: (value) {
                            setState(() {
                              _refusalAction = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'Not applicable',
                          groupValue: _refusalAction,
                          label: 'Not applicable',
                          onChanged: (value) {
                            setState(() {
                              _refusalAction = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Additional card for 'Other' specification
              if (_refusalAction == 'Other')
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'If other,please specify',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: _Spacing.md),
                      TextFormField(
                        controller: _otherAgreementController,
                        decoration: InputDecoration(
                          hintText: 'Enter your response',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 12.0,
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

              // Salary payment frequency question
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Do your workers receive their full salaries?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: _Spacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRadioOption(
                          value: 'Always',
                          groupValue: _salaryPaymentFrequency,
                          label: 'Always',
                          onChanged: (value) {
                            setState(() {
                              _salaryPaymentFrequency = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'Sometimes',
                          groupValue: _salaryPaymentFrequency,
                          label: 'Sometimes',
                          onChanged: (value) {
                            setState(() {
                              _salaryPaymentFrequency = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'Rarely',
                          groupValue: _salaryPaymentFrequency,
                          label: 'Rarely',
                          onChanged: (value) {
                            setState(() {
                              _salaryPaymentFrequency = value;
                            });
                          },
                        ),
                        _buildRadioOption(
                          value: 'Never',
                          groupValue: _salaryPaymentFrequency,
                          label: 'Never',
                          onChanged: (value) {
                            setState(() {
                              _salaryPaymentFrequency = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Show agreement section if:
              // 1. Have recruited during the past year (Yes), or
              // 2. Haven't recruited in past year but have recruited before (Yes)
              if (_hasRecruitedWorker == '1' ||
                  (_hasRecruitedWorker == '0' &&
                      _everRecruitedWorker == 'Yes')) ...[
                // Note for the respondent
                Padding(
                  padding: const EdgeInsets.only(bottom: _Spacing.lg),
                  child: Text(
                    'For the following section, please read the statements to the respondent, and ask him/her if he/she agrees or disagrees.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),

                // Agreement Statements Section - Salary and Debt
                _buildAgreementSection(
                  statements: [
                    'It is acceptable to withhold a worker\'s salary without their consent.',
                    'It is acceptable for a person who cannot pay their debts to work for the creditor to reimburse the debt.',
                  ],
                  ids: ['salary_workers', 'recruit_1'],
                ),

                // Agreement Statements Section - Recruitment
                _buildAgreementSection(
                  statements: [
                    'It is acceptable for an employer not to reveal the true nature of the work during the recruitment.',
                    'A worker is obliged to work whenever he is called upon by his employer.',
                  ],
                  ids: ['recruit_2', 'recruit_3'],
                ),

                // Agreement Statements Section - Working Conditions
                _buildAgreementSection(
                  statements: [
                    'A worker is not entitled to move freely.',
                    'A worker must be free to communicate with his or her family and friends.',
                    'A worker is obliged to adapt to any living conditions imposed by the employer.',
                    'It is acceptable for an employer and their family to interfere in a worker\'s private life.',
                    'A worker should not have the freedom to leave work whenever they wish.',
                  ],
                  ids: [
                    'conditions_1',
                    'conditions_2',
                    'conditions_3',
                    'conditions_4',
                    'conditions_5',
                  ],
                ),

                // Agreement Statements Section - Leaving Employment
                _buildAgreementSection(
                  statements: [
                    'A worker should be required to stay longer than expected while waiting for unpaid salary.',
                    'A worker should not be able to leave their employer when they owe money to their employer.',
                  ],
                  ids: ['leaving_1', 'leaving_2'],
                ),
              ],

              const SizedBox(height: _Spacing.xxl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Previous Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.green.shade600, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_ios,
                            size: 18, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Previous',
                          style: GoogleFonts.inter(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Next Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isFormComplete
                        ? () {
                            if (_validateForm()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdultsInformationPage(),
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormComplete
                          ? Colors.green.shade600
                          : Colors.grey[400],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.green.shade600.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.white),
                      ],
                    ),
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
