import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../controller/models/community-assessment-model.dart';
import '../../../fields/dropdown.dart';
import '../community-assessment-controller.dart';

class CommunityAssessmentEdit extends StatefulWidget {
  final CommunityAssessmentModel? assessment;
  final VoidCallback? onUpdate;

  const CommunityAssessmentEdit({
    super.key,
    this.assessment,
    this.onUpdate,
  });

  @override
  State<CommunityAssessmentEdit> createState() =>
      _CommunityAssessmentEditState();
}

class _CommunityAssessmentEditState extends State<CommunityAssessmentEdit> {
  final Map<String, dynamic> _answers = {};
  bool get _hasPrimarySchools => _answers["q6"] == "Yes";
  final CommunityAssessmentController _controller =
      CommunityAssessmentController();
  final q7aController = TextEditingController();


  late final List<TextEditingController> _schoolControllers = [];
  final List<String> _schools = [];
  final Map<String, bool> _schoolToilets = {};
  final Map<String, bool> _schoolFood = {};
  final Map<String, bool> _schoolNoCorporalPunishment = {};
  final List<String> _communities = [
    "Community A",
    "Community B",
    "Community C",
    "Community D"
  ];

  String? _selectedCommunity;

  @override
  void initState() {

    super.initState();
    _initializeFormData();
  }

  @override
  void dispose() {
    for (var controller in _schoolControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeFormData() {
    if (widget.assessment != null) {
      final assessment = widget.assessment!;
      q7aController.text = assessment.q7a.toString();

      _controller.communityScore.value = assessment.communityScore!;

      // Initialize basic answers
      _answers.addAll({
        'community': assessment.communityName ?? '',
        'q1': assessment.q1,
        'q2': assessment.q2,
        'q3': assessment.q3,
        'q4': assessment.q4,
        'q5': assessment.q5,
        'q6': assessment.q6,
        'q7a': assessment.q7a.toString(),
        'q7b': assessment.q7b,
        'q7c': assessment.q7c,
        'q8': assessment.q8,
        'q9': assessment.q9,
        'q10': assessment.q10,
      });

      // Initialize school data if exists
      if (assessment.q7b.isNotEmpty) {
        final schoolNames = assessment.q7b
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        for (var school in schoolNames) {
          _schools.add(school);
          _schoolControllers.add(TextEditingController(text: school));
          _schoolToilets[school] = assessment.q7c.contains(school);
          _schoolFood[school] = assessment.q8.contains(school);
          _schoolNoCorporalPunishment[school] = assessment.q10.contains(school);
        }
      }
    } else {
      // Initialize with default values for new assessment
      _answers.addAll({
        'q1': 'No',
        'q2': 'No',
        'q3': 'No',
        'q4': 'No',
        'q5': 'No',
        'q6': 'No',
        'q7a': '0',
        'q7b': '',
        'q7c': '',
        'q8': '',
        'q9': 'No',
        'q10': '',
      });
    }
  }

  void _updateSchoolCount(String value) {
    final count = int.tryParse(value) ?? 0;
    _answers["q7a"] = value;

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

    final newSchools = <String>[];
    for (int i = 0; i < _schoolControllers.length; i++) {
      final school = _schoolControllers[i].text.trim();
      if (school.isNotEmpty) {
        newSchools.add(school);
        _schoolToilets.putIfAbsent(school, () => false);
        _schoolFood.putIfAbsent(school, () => false);
        _schoolNoCorporalPunishment.putIfAbsent(school, () => false);
      }
    }

    setState(() {
      _schools
        ..clear()
        ..addAll(newSchools);
    });

    _answers["q7b"] = _schools.join(', ');
    _updateCheckboxAnswers();
  }

  void _updateSchoolName(int index, String value) {
    final newSchool = value.trim();
    final oldSchool = index < _schools.length ? _schools[index] : null;

    if (index < _schools.length) {
      _schools[index] = newSchool;
    } else if (newSchool.isNotEmpty) {
      _schools.add(newSchool);
    }

    if (oldSchool != null && oldSchool != newSchool && oldSchool.isNotEmpty) {
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
      _schoolToilets.putIfAbsent(newSchool, () => false);
      _schoolFood.putIfAbsent(newSchool, () => false);
      _schoolNoCorporalPunishment.putIfAbsent(newSchool, () => false);
    }

    setState(() {
      _answers["q7b"] = _schools.where((s) => s.isNotEmpty).join(', ');
    });
    _updateCheckboxAnswers();
  }

  void _updateCheckboxAnswers() {
    setState(() {
      _answers["q7c"] = _schoolToilets.entries
          .where((e) => e.value && _schools.contains(e.key))
          .map((e) => e.key)
          .join(',');

      _answers["q8"] = _schoolFood.entries
          .where((e) => e.value && _schools.contains(e.key))
          .map((e) => e.key)
          .join(',');

      _answers["q10"] = _schoolNoCorporalPunishment.entries
          .where((e) => e.value && _schools.contains(e.key))
          .map((e) => e.key)
          .join(',');
    });
  }

  @override
  Widget build(BuildContext context) {
    _controller.communityAssessmentContext = context;
    final theme = Theme.of(context);

    debugPrint("${widget.assessment!.toMap()}");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Community Assessment",
          style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: GoogleFonts.comicNeue().fontFamily,
              color: theme.colorScheme.onPrimary,
              fontSize: 18),
        ),
        backgroundColor: theme.primaryColor,
        actions: [
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
            DropdownField(
              question: "Select Community",
              options: _communities,
              defaultValue: widget.assessment?.communityName,
              onChanged: (val) {
                setState(() {
                  _controller.communityName.value = val ?? "";
                  _answers["community"] = val ?? "";
                });
              },
            ),
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
                              fontFamily: GoogleFonts.comicNeue().fontFamily,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: q7aController,
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
                              fontFamily: GoogleFonts.comicNeue().fontFamily,
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
                      }),
                    ],
                  ),
                ),
              ),
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
                                fontFamily: GoogleFonts.comicNeue().fontFamily,
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
                              fontFamily: GoogleFonts.comicNeue().fontFamily,
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
                              fontFamily: GoogleFonts.comicNeue().fontFamily,
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
                      final stringAnswers = _answers.map((key, value) =>
                          MapEntry(key, value?.toString() ?? ''));

                      final assessment = CommunityAssessmentModel(
                        id: widget.assessment?.id,
                        communityName: _answers['community'] ?? '',
                        q1: _answers['q1'] ?? 'No',
                        q2: _answers['q2'] ?? 'No',
                        q3: _answers['q3'] ?? 'No',
                        q4: _answers['q4'] ?? 'No',
                        q5: _answers['q5'] ?? 'No',
                        q6: _answers['q6'] ?? 'No',
                        q7a: int.tryParse(_answers['q7a'] ?? '0') ?? 0,
                        q7b: _answers['q7b'] ?? '',
                        q7c: _answers['q7c'] ?? '',
                        q8: _answers['q8'] ?? '',
                        q9: _answers['q9'] ?? 'No',
                        q10: _answers['q10'] ?? '',
                        status: 1, // Mark as saved
                      );

                      await _controller.saveFormOffline(assessment.toMap());

                      if (widget.onUpdate != null) {
                        widget.onUpdate!();
                      }

                      if (mounted) {
                        Navigator.of(context).pop();
                      }
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
                      final assessment = CommunityAssessmentModel(
                        id: widget.assessment?.id,
                        communityName: _answers['community'] ?? '',
                        q1: _answers['q1'] ?? '',
                        q2: _answers['q2'] ?? '',
                        q3: _answers['q3'] ?? '',
                        q4: _answers['q4'] ?? '',
                        q5: _answers['q5'] ?? '',
                        q6: _answers['q6'] ?? '',
                        q7a: int.tryParse(_answers['q7a'] ?? '0') ?? 0,
                        q7b: _answers['q7b'] ?? '',
                        q7c: _answers['q7c'] ?? '',
                        q8: _answers['q8'] ?? '',
                        q9: _answers['q9'] ?? '',
                        q10: _answers['q10'] ?? '',
                        status:
                            widget.assessment?.status ?? 0, // Mark as submitted
                      );

                      await _controller.submit(assessment.toMap());

                      if (widget.onUpdate != null) {
                        widget.onUpdate!();
                      }

                      if (mounted) {
                        Navigator.of(context).pop();
                      }
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
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600
                      // fontFamily: GoogleFonts.comicNeue().fontFamily,
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
