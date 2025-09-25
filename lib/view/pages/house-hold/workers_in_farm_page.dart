import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'adult_household_page.dart';

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
    'salary_workers':
        null, // It is acceptable to withhold a worker's salary without their consent
    'recruit_1':
        null, // It is acceptable for a person who cannot pay their debts to work for the creditor
    'recruit_2':
        null, // It is acceptable for an employer not to reveal the true nature of the work
    'recruit_3':
        null, // A worker is obliged to work whenever called upon by employer

    // Working Conditions
    'conditions_1': null, // A worker is not entitled to move freely
    'conditions_2':
        null, // A worker must be free to communicate with family/friends
    'conditions_3':
        null, // A worker must adapt to any living conditions imposed
    'conditions_4': null, // Employer can interfere in worker's private life
    'conditions_5': null, // Worker should not have freedom to leave work

    // Leaving Employment
    'leaving_1':
        null, // Worker should stay longer while waiting for unpaid salary
    'leaving_2':
        null, // Worker should not leave when they owe money to employer
  };
  final TextEditingController _otherAgreementController =
      TextEditingController();
  bool _permanentLabor = false;
  bool _casualLabor = false;

  @override
  void initState() {
    super.initState();
    _hasRecruitedWorker = '0'; // Default to 'No'
  }

  @override
  void dispose() {
    _otherAgreementController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildRecruitmentTypeCheckbox({
    required BuildContext context,
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required BuildContext context,
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 3.0), // Align radio with first line of text
            child: Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: theme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workers in Farm'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // First Card: Recruitment Question
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Have you recruited at least one worker during the past year?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRadioOption(
                        context: context,
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
                        context: context,
                        value: '0',
                        groupValue: _hasRecruitedWorker,
                        label: 'No',
                        onChanged: (value) {
                          setState(() {
                            _hasRecruitedWorker = value;
                            _permanentLabor = false;
                            _casualLabor = false;
                          });
                          
                          // Scroll to the agreement statements section after a short delay
                          // to allow the UI to update first
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Worker Recruitment Type Card (Conditional)
          if (_hasRecruitedWorker == '1') ...[  // Only show if 'Yes' was selected
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Do you recruit workers for...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildRecruitmentTypeCheckbox(
                      context: context,
                      value: _permanentLabor,
                      label: 'Permanent labor',
                      onChanged: (value) {
                        setState(() {
                          _permanentLabor = value ?? false;
                        });
                      },
                    ),
                    _buildRecruitmentTypeCheckbox(
                      context: context,
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
            ),
          ],

          // Second Card: Follow-up question when 'No' is selected
          if (_hasRecruitedWorker == '0')
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have you ever recruited a worker before?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRadioOption(
                            context: context,
                            value: '1',
                            groupValue: _everRecruitedWorker,
                            label: 'Yes',
                            onChanged: (value) {
                              setState(() {
                                _everRecruitedWorker = value;
                              });
                            },
                          ),
                          _buildRadioOption(
                            context: context,
                            value: '0',
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
              ),
            ),

          // Worker Types Card (Conditional)
          if (_hasRecruitedWorker == '1') ...[
            // Agreement Type Card
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What kind of agreement do you have with your workers?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRadioOption(
                            context: context,
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
                            context: context,
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
                            context: context,
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
                            context: context,
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
                            context: context,
                            value: 'Other (specify)',
                            groupValue: _workerAgreementType,
                            label: 'Other (specify)',
                            onChanged: (value) {
                              setState(() {
                                _workerAgreementType = value;
                                if (value != 'Other (specify)') {
                                  _otherAgreementController.clear();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Show 'Other to specify' field when 'Other (specify)' is selected
            if (_workerAgreementType == 'Other (specify)')
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Other to specify',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _otherAgreementController,
                              decoration: InputDecoration(
                                labelText: 'Specify',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Tasks clarification question that follows after agreement type
            if (_workerAgreementType != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Were the tasks to be performed by the worker clarified with them during the recruitment?',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRadioOption(
                              context: context,
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
                              context: context,
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
                ),
              ),

            // Additional tasks question in a separate card
            if (true)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Does the worker perform tasks for you or your family members other than those agreed upon?',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRadioOption(
                              context: context,
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
                              context: context,
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
                ),
              ),

            // Additional tasks follow-up question
            if (true)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What do you do when a worker refuses to perform a task?',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRadioOption(
                              context: context,
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
                              context: context,
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
                              context: context,
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
                              context: context,
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
                              context: context,
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
                ),
              ),

            // Additional card for 'Other' specification
            if (_refusalAction == 'Other')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Other to Specify',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 12),
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
                ),
              ),

            // Salary payment frequency question
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Do your workers receive their full salaries?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRadioOption(
                            context: context,
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
                            context: context,
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
                            context: context,
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
                            context: context,
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
              ),
            ),

            // Agreement Statements Section - Salary and Debt
            _buildAgreementSection(
              context,
              statements: [
                'It is acceptable to withhold a worker\'s salary without their consent.',
                'It is acceptable for a person who cannot pay their debts to work for the creditor to reimburse the debt.',
              ],
              ids: ['salary_workers', 'recruit_1'],
            ),

            // Agreement Statements Section - Recruitment
            _buildAgreementSection(
              context,
              statements: [
                'It is acceptable for an employer not to reveal the true nature of the work during the recruitment.',
                'A worker is obliged to work whenever he is called upon by his employer.',
              ],
              ids: ['recruit_2', 'recruit_3'],
            ),

            // Agreement Statements Section - Working Conditions
            _buildAgreementSection(
              context,
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
                'conditions_5'
              ],
            ),

            // Agreement Statements Section - Leaving Employment
            _buildAgreementSection(
              context,
              statements: [
                'A worker should be required to stay longer than expected while waiting for unpaid salary.',
                'A worker should not be able to leave their employer when they owe money to their employer.',
              ],
              ids: ['leaving_1', 'leaving_2'],
            ),
            
            // Next Button
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 32.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdultHouseholdPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Next: Adults in Household',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  // Helper method to build a section of agreement statements
  Widget _buildAgreementSection(
    BuildContext context, {
    required List<String> statements,
    required List<String> ids,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ...List.generate(statements.length, (index) {
            return _buildAgreementCard(
              context,
              statement: '${index + 1}. ${statements[index]}',
              statementId: ids[index],
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAgreementCard(
    BuildContext context, {
    required String statement,
    required String statementId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statement,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAgreementButton(
                    context,
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
                    context,
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
        ),
      ),
    );
  }

  Widget _buildAgreementButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}
