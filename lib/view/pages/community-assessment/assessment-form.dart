import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/society_repo.dart';
import 'package:human_rights_monitor/controller/models/societies/societies_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:get/get.dart';

import 'community-assessment-controller.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/districts_repo.dart';
import 'package:human_rights_monitor/controller/models/districts/districts_model.dart';


class CommunityAssessmentForm extends StatefulWidget {
  const CommunityAssessmentForm({super.key});

  @override
  State<CommunityAssessmentForm> createState() =>
      _CommunityAssessmentFormState();
}

class _CommunityAssessmentFormState extends State<CommunityAssessmentForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  final Map<String, dynamic> _answers = {};
  bool get _hasPrimarySchools => _answers["q6"] == "Yes";
  final CommunityAssessmentController _controller =
      CommunityAssessmentController();
 final SocietyRepository _societyRepo = SocietyRepository();
final RxList<Society> _societies = <Society>[].obs;
final RxBool _isLoadingSocieties = false.obs;
final RxnInt _selectedSocietyId = RxnInt();
  final List<String> _schools = [];
  final List<TextEditingController> _schoolControllers = [];
  final Map<String, bool> _schoolToilets = {};
  final Map<String, bool> _schoolFood = {};
  final Map<String, bool> _schoolNoCorporalPunishment = {};
  String? _selectedCommunity;

  @override
  void initState() {
    super.initState();
    _loadSocieties(); // Changed from _loadDistricts to _loadSocieties
  }

  @override
  void dispose() {
    for (var controller in _schoolControllers) {
      controller.dispose();
    }
    _isLoadingSocieties.close();
    _societies.close();
    _selectedSocietyId.close();
    super.dispose();
  }

    Future<void> _loadSocieties() async {
    try {
      _isLoadingSocieties.value = true;
      final societies = await _societyRepo.getAllSocieties();
      _societies.value = societies;
    } catch (e) {
      debugPrint('Error loading societies: $e');
      Get.snackbar('Error', 'Failed to load societies');
    } finally {
      _isLoadingSocieties.value = false;
    }
  }

  /// Updates the controller's observable value based on the answer
  void _updateControllerValue(String key, String value) {
    _controller.updateScore(key, value);
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

  // Update state
  setState(() {
    // Keep existing school names if any
    final existingSchools = <String>[];
    for (int i = 0; i < _schoolControllers.length; i++) {
      if (i < _schools.length) {
        existingSchools.add(_schools[i]);
      } else {
        existingSchools.add('');
      }
    }
    _schools
      ..clear()
      ..addAll(existingSchools);
  });

  // Update answers
  _updateCheckboxAnswers();
}
  
  void _updateSchoolName(int index, String value) {
  final newSchool = value.trim();
  final oldSchool = index < _schools.length ? _schools[index] : '';

  // Update the school name in the list
  if (index < _schools.length) {
    _schools[index] = newSchool;
  } else {
    _schools.add(newSchool);
  }

  // Update the checkbox states if the school name changed
  if (oldSchool.isNotEmpty && oldSchool != newSchool) {
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

  // Update the answer with all non-empty school names
  final validSchools = _schools.where((s) => s.trim().isNotEmpty).toList();
  _answers["q7b"] = validSchools.join(', ');
  
  setState(() {});
  _updateCheckboxAnswers();
}
  void _updateCheckboxAnswers() {
    // Get only non-empty school names
    final validSchools = _schools.where((s) => s.trim().isNotEmpty).toList();
    
    // Update q7c (toilets)
    _answers["q7c"] = _schoolToilets.entries
        .where((e) => e.value && validSchools.contains(e.key))
        .map((e) => e.key)
        .join(', ');

    // Update q8 (food)
    _answers["q8"] = _schoolFood.entries
        .where((e) => e.value && validSchools.contains(e.key))
        .map((e) => e.key)
        .join(', ');

    // Update q10 (no corporal punishment)
    _answers["q10"] = _schoolNoCorporalPunishment.entries
        .where((e) => e.value && validSchools.contains(e.key))
        .map((e) => e.key)
        .join(', ');
        
    // Update the form state if it exists and is valid
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
      }
    }
  }

  // Future<void> _submitForm() async {
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   setState(() {
  //     _isSubmitting = true;
  //   });

  //   try {
  //     _updateCheckboxAnswers();
      
  //     final now = DateTime.now();
  //     final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      
  //     final schoolCount = int.tryParse(_answers['q7a'] ?? '0') ?? 0;
  //     final schools = _schools.where((s) => s.isNotEmpty).toList();
  //     final schoolNames = schools.isNotEmpty 
  //         ? schools.join(';') 
  //         : _answers['q7b']?.toString() ?? '';
      
  //     final assessmentData = {
  //       'date_created': formattedDate,
  //       'date_modified': formattedDate,
  //       'status': 1, // Submitted
  //       'community_name': _selectedCommunity ?? 'Unnamed Community',
  //       'region': _answers['region'] ?? '',
  //       'district': _answers['district'] ?? '',
  //       'sub_county': _answers['sub_county'] ?? '',
  //       'parish': _answers['parish'] ?? '',
  //       'village': _answers['village'] ?? '',
  //       'gps_coordinates': _answers['gps_coordinates'] ?? '',
  //       'total_households': int.tryParse(_answers['total_households']?.toString() ?? '0') ?? 0,
  //       'total_population': int.tryParse(_answers['total_population']?.toString() ?? '0') ?? 0,
  //       'total_children': int.tryParse(_answers['total_children']?.toString() ?? '0') ?? 0,
  //       'primary_schools_count': schoolCount,
  //       'schools': schoolNames,
  //       'has_protected_water': _answers['q1'] == 'Yes' ? 1 : 0,
  //       'hires_adult_labor': _answers['q2'] == 'Yes' ? 1 : 0,
  //       'child_labor_awareness': _answers['q3'] == 'Yes' ? 1 : 0,
  //       'has_women_leaders': _answers['q4'] == 'Yes' ? 1 : 0,
  //       'has_preschool': _answers['q5'] == 'Yes' ? 1 : 0,
  //       'has_primary_school': _answers['q6'] == 'Yes' ? 1 : 0,
  //       'schools_with_toilets': _answers['q7c'] ?? '',
  //       'schools_with_food': _answers['q8'] ?? '',
  //       'schools_no_corporal_punishment': _answers['q10'] ?? '',
  //       'notes': _answers['notes']?.toString() ?? '',
  //       'raw_data': jsonEncode(_answers),
  //     };

  //     final dbHelper = CommunityDBHelper.instance;
  //     await dbHelper.insertCommunityAssessment(assessmentData);

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Community assessment submitted!')),
  //       );
  //       Navigator.of(context).pop(true);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error saving assessment: ${e.toString()}')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isSubmitting = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _controller.communityAssessmentContext = context;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Assessment'),
        centerTitle: true,
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Community Name Dropdown
              _buildCommunityDropdown(),
              const SizedBox(height: 16),
              
              // Questions
              _buildQuestionCard(
                context,
                "1. Do most households in this community have access to a protected water source?",
                "q1"
              ),
              _buildQuestionCard(
                context,
                "2. Do some households in this community hire adult labourers to do agricultural work?",
                "q2"
              ),
              _buildQuestionCard(
                context,
                "3. Has at least one awareness-raising session on child labour taken place in the past year?",
                "q3"
              ),
              _buildQuestionCard(
                context,
                "4. Are there any women among the leaders of this community?",
                "q4"
              ),
              _buildQuestionCard(
                context,
                "5. Is there at least one pre-school in this community?",
                "q5"
              ),
              _buildQuestionCard(
                context,
                "6. Is there at least one primary school in this community?",
                "q6"
              ),
              
              // School-related questions
              if (_hasPrimarySchools) ..._buildSchoolQuestions(),
              
              _buildQuestionCard(
                context,
                "9. Do some children in the community access scholarships to attend high school?",
                "q9"
              ),
              
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildCommunityDropdown() {
  return Obx(() {
    if (_isLoadingSocieties.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_societies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No societies available. Please sync data first.'),
      );
    }

    return DropdownButtonFormField<int>(
      value: _selectedSocietyId.value,
      decoration: const InputDecoration(
        labelText: 'Select Society *',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: _societies.map((society) {
        return DropdownMenuItem<int>(
          value: society.id,
          child: Text(society.society ?? 'Unnamed Society'),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return 'Please select a society';
        }
        return null;
      },
      onChanged: (int? newId) {
        _selectedSocietyId.value = newId; // RxnInt can handle null values
        if (newId != null) {
          // Update the community name when a society is selected
          final selectedSociety = _societies.firstWhereOrNull((s) => s.id == newId);
          if (selectedSociety != null) {
            _controller.communityName.value = selectedSociety.society ?? '';
            _controller.communityId.value = selectedSociety.id; // Store the society ID in communityId
          }
        }
      },
    );
  }
  );
}

  List<Widget> _buildSchoolQuestions() {
    return [
      // School count
      Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              TextFormField(
                initialValue: _answers["q7a"]?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter number of primary schools",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of schools';
                  }
                  final count = int.tryParse(value);
                  if (count == null || count < 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: _updateSchoolCount,
              ),
            ],
          ),
        ),
      ),
      
      // School names - only show if number of schools > 0
      if ((int.tryParse(_answers["q7a"]?.toString() ?? '0') ?? 0) > 0)
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  // Set the controller value from _schools if available
                  if (index < _schools.length && _schools[index].isNotEmpty) {
                    controller.text = _schools[index];
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'School ${index + 1} name *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter school name';
                        }
                        return null;
                      },
                      onChanged: (value) => _updateSchoolName(index, value),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      
      // School toilets - only show if there are schools with names
      if (_schools.any((s) => s.trim().isNotEmpty))
        _buildSchoolCheckboxSection(
          "7c. Which of the schools have separate toilets for boys and girls?",
          _schoolToilets,
          (school, value) {
            setState(() {
              _schoolToilets[school] = value ?? false;
              _updateCheckboxAnswers();
            });
          },
        ),
      
      // School food
      if (_schools.any((s) => s.isNotEmpty))
        _buildSchoolCheckboxSection(
          "8. Which of the schools provide food?",
          _schoolFood,
          (school, value) {
            setState(() {
              _schoolFood[school] = value ?? false;
              _updateCheckboxAnswers();
            });
          },
        ),
      
      // School corporal punishment
      if (_schools.any((s) => s.isNotEmpty))
        _buildSchoolCheckboxSection(
          "10. Which of the schools has an absence of corporal punishment?",
          _schoolNoCorporalPunishment,
          (school, value) {
            setState(() {
              _schoolNoCorporalPunishment[school] = value ?? false;
              _updateCheckboxAnswers();
            });
          },
        ),
    ];
  }

  Widget _buildSchoolCheckboxSection(
    String title,
    Map<String, bool> checkboxMap,
    Function(String, bool?) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
            ),
            const SizedBox(height: 12),
            ..._schools.where((s) => s.isNotEmpty).map((school) => CheckboxListTile(
                  title: Text(school),
                  value: checkboxMap[school] ?? false,
                  onChanged: (bool? value) => onChanged(school, value),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size.fromHeight(50),
      ),
      icon: const Icon(Icons.save),
      label: const Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      onPressed: _isSubmitting ? null : _saveAsDraft,
    );
  }
Future<void> _saveAsDraft() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    _updateCheckboxAnswers();
    
    final answers = Map<String, dynamic>.from(_answers);
    
    // Use the society ID from the controller
    final societyId = _controller.communityId.value;
    if (societyId != null) {
      answers['society_id'] = societyId;
      debugPrint('ℹ️ Using society ID from controller: $societyId');
    } else {
      debugPrint('⚠️ No society ID available in controller');
    }
    
    // Use the community name from the controller
    if (_controller.communityName.value.isNotEmpty) {
      answers['community'] = _controller.communityName.value;
    }
    
    answers['q7b'] = _schools.join(', ');
    answers['q7c'] = _schools.where((s) => _schoolToilets[s] == true).join(', ');
    
    final success = await _controller.saveFormOffline(answers, status: 0);
      
      if (success && context.mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Success!',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Community Assessment successfully done',
                    textAlign: TextAlign.center,
                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context).pop(true); // Close the form
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error saving form: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving form: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Builds each question card with Yes/No full-width buttons
  Widget _buildQuestionCard(BuildContext context, String question, String key) {
    final theme = Theme.of(context);
    _answers[key] ??= '';

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
                        _updateControllerValue(key, "Yes");
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
                        _updateControllerValue(key, "No");
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
