import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../fields/dropdown.dart';
import 'community-assessment-controller.dart';

class CommunityAssessmentForm extends StatefulWidget {
  const CommunityAssessmentForm({super.key});

  @override
  State<CommunityAssessmentForm> createState() =>
      _CommunityAssessmentFormState();
}

class _CommunityAssessmentFormState extends State<CommunityAssessmentForm> {
  final Map<String, dynamic> _answers = {};
  bool get _hasPrimarySchools => _answers["q6"] == "Yes";
  final CommunityAssessmentController _controller =
      CommunityAssessmentController();
  final List<String> _communities = [
    "Community A",
    "Community B",
    "Community C",
    "Community D"
  ];
  final List<String> _schools = [];
  final List<TextEditingController> _schoolControllers = [];
  final Map<String, bool> _schoolToilets = {};
  final Map<String, bool> _schoolFood = {};
  final Map<String, bool> _schoolNoCorporalPunishment = {};
  String? _selectedCommunity;

  @override
  void dispose() {
    for (var controller in _schoolControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateSchoolCount(String value) {
    final count = int.tryParse(value) ?? 0;
    _answers["q7a"] = value;

    // Update controllers list
    while (_schoolControllers.length > count) {
      final removedController = _schoolControllers.removeLast();
      final removedSchool = removedController.text.trim();
      if (removedSchool.isNotEmpty) {
        _schools.remove(removedSchool);
        _schoolToilets.remove(removedSchool);
        _schoolFood.remove(removedSchool);
        _schoolNoCorporalPunishment.remove(removedSchool);
      }
      removedController.dispose();
    }

    while (_schoolControllers.length < count) {
      _schoolControllers.add(TextEditingController());
    }

    // Update schools list with current controller values
    final newSchools = <String>[];
    for (int i = 0; i < _schoolControllers.length; i++) {
      final school = _schoolControllers[i].text.trim();
      if (school.isNotEmpty) {
        newSchools.add(school);
        // Initialize checkbox states for new schools
        _schoolToilets.putIfAbsent(school, () => false);
        _schoolFood.putIfAbsent(school, () => false);
        _schoolNoCorporalPunishment.putIfAbsent(school, () => false);
      }
    }

    // Update state
    setState(() {
      _schools
        ..clear()
        ..addAll(newSchools);
    });

    // Update answers
    _answers["q7b"] = _schools.join(', ');
    _updateCheckboxAnswers();
  }

  void _updateSchoolName(int index, String value) {
    final newSchool = value.trim();
    final oldSchool = index < _schools.length ? _schools[index] : null;

    // Update the school name in the list
    if (index < _schools.length) {
      _schools[index] = newSchool;
    } else if (newSchool.isNotEmpty) {
      _schools.add(newSchool);
    }

    // Update the checkbox states if the school name changed
    if (oldSchool != null && oldSchool != newSchool && oldSchool.isNotEmpty) {
      // If school name was changed, update the maps with the new name
      final toiletValue = _schoolToilets[oldSchool] ?? false;
      final foodValue = _schoolFood[oldSchool] ?? false;
      final punishmentValue = _schoolNoCorporalPunishment[oldSchool] ?? false;

      _schoolToilets.remove(oldSchool);
      _schoolFood.remove(oldSchool);
      _schoolNoCorporalPunishment.remove(oldSchool);

      if (newSchool.isNotEmpty) {
        _schoolToilets[newSchool] = toiletValue;
        _schoolFood[newSchool] = foodValue;
        _schoolNoCorporalPunishment[newSchool] = punishmentValue;
      }
    } else if (newSchool.isNotEmpty) {
      // For new schools, initialize the checkbox states
      _schoolToilets.putIfAbsent(newSchool, () => false);
      _schoolFood.putIfAbsent(newSchool, () => false);
      _schoolNoCorporalPunishment.putIfAbsent(newSchool, () => false);
    }

    // Update the answers and trigger UI update
    setState(() {
      _answers["q7b"] = _schools.where((s) => s.isNotEmpty).join(', ');
    });
    _updateCheckboxAnswers();
  }

  void _updateCheckboxAnswers() {
    _answers["q7c"] = _schoolToilets.entries
        .where((e) => e.value && _schools.contains(e.key))
        .map((e) => e.key)
        .join(', ');

    _answers["q8"] = _schoolFood.entries
        .where((e) => e.value && _schools.contains(e.key))
        .map((e) => e.key)
        .join(', ');

    _answers["q10"] = _schoolNoCorporalPunishment.entries
        .where((e) => e.value && _schools.contains(e.key))
        .map((e) => e.key)
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    _controller.communityAssessmentContext = context;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Community Assessment",
          style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: GoogleFonts.poppins().fontFamily,
              color: theme.colorScheme.onPrimary,
              fontSize: 18),
        ),
        backgroundColor: theme.primaryColor,
        actions: [
          // Display current score in the app bar
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0),
            child: Obx(() => Text(
                  'Score: ${_controller.communityScore.value}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Community Name Dropdown
            DropdownField(
              question: "Select Community",
              options: _communities,
              onChanged: (val) {
                setState(() {
                  _controller.communityName.value = val ?? "";
                  _answers["community"] = val ?? "";
                });
              },
            ),

            /// Questions
            _buildQuestionCard(
                context,
                "1. Do most households in this community have access to a "
                    "protected water source?",
                "q1"),
            _buildQuestionCard(
                context,
                "2. Do some households in this community hire adult labourers "
                    "to do agricultural work?",
                "q2"),
            _buildQuestionCard(
                context,
                "3. Has at least one awareness-raising session on child labour "
                    "taken place in the past year?",
                "q3"),
            _buildQuestionCard(
                context,
                "4. Are there any women among the leaders of this community?",
                "q4"),
            _buildQuestionCard(context,
                "5. Is there at least one pre-school in this community?", "q5"),
            _buildQuestionCard(
                context,
                "6. Is there at least one primary school in this community?",
                "q6"),
            if (_hasPrimarySchools) ...[
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "7a. How many primary schools are in the community?",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter number of primary schools",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          _updateSchoolCount(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_hasPrimarySchools) ...[
              // School names list field
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "7b. List the names of the schools",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ..._schoolControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'School ${index + 1} name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            onChanged: (value) =>
                                _updateSchoolName(index, value),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              // School toilets checkboxes
              if (_schools.any((s) => s.isNotEmpty))
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "7c. Which of the schools has separate toilets for boys and girls?",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ..._schools
                            .where((s) => s.isNotEmpty)
                            .map((school) => CheckboxListTile(
                                  title: Text(school),
                                  value: _schoolToilets[school] ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _schoolToilets[school] = value ?? false;
                                      _updateCheckboxAnswers();
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                )),
                      ],
                    ),
                  ),
                ),
              // School food checkboxes
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "8a. Which of the schools provide food?",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ..._schools
                          .where((s) => s.isNotEmpty)
                          .map((school) => CheckboxListTile(
                                title: Text(school),
                                value: _schoolFood[school] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _schoolFood[school] = value ?? false;
                                    _updateCheckboxAnswers();
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              )),
                    ],
                  ),
                ),
              ),
            ],
            _buildQuestionCard(
                context,
                "9. Do some children in the community access scholarships to "
                    "attend high school?",
                "q9"),
            // School corporal punishment checkboxes
            if (_hasPrimarySchools && _schools.any((s) => s.isNotEmpty))
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "10. Which of the schools has an absence of corporal punishment?",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ..._schools.where((s) => s.isNotEmpty).map((school) =>
                          CheckboxListTile(
                            title: Text(school),
                            value: _schoolNoCorporalPunishment[school] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                _schoolNoCorporalPunishment[school] =
                                    value ?? false;
                                _updateCheckboxAnswers();
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          )),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),

            /// Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                    onPressed: () async {
                      // Convert all values to strings before saving
                      final stringAnswers = _answers.map((key, value) =>
                          MapEntry(key, value?.toString() ?? ''));
                      await _controller.saveFormOffline(stringAnswers);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text("Submit"),
                    onPressed: () async {
                      debugPrint(_answers.toString());
                      // Convert all values to strings before submitting
                      final stringAnswers = _answers.map((key, value) =>
                          MapEntry(key, value?.toString() ?? ''));
                      await _controller.submit(stringAnswers);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Builds each question card with Yes/No full-width buttons
  Widget _buildQuestionCard(BuildContext context, String question, String key) {
    final theme = Theme.of(context);

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
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        final previousAnswer = _answers[key];
                        _answers[key] = "Yes";
                        // Update score only if answer changed
                        if (previousAnswer != "Yes") {
                          _controller.updateScore(key, "Yes");
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _answers[key] == "Yes"
                            ? theme.primaryColor
                            : theme.cardColor,
                        border: Border.all(color: theme.primaryColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _answers[key] == "Yes"
                              ? Colors.white
                              : theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        final previousAnswer = _answers[key];
                        _answers[key] = "No";
                        // Update score only if answer changed from Yes to No
                        if (previousAnswer == "Yes") {
                          _controller.updateScore(key, "No");
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _answers[key] == "No"
                            ? theme.colorScheme.error
                            : theme.cardColor,
                        border: Border.all(color: theme.colorScheme.error),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "No",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _answers[key] == "No"
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
}
