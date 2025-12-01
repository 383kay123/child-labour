import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/community_db_helper.dart';

import 'package:human_rights_monitor/controller/models/community-assessment-model.dart';
import 'package:intl/intl.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';
import 'package:lottie/lottie.dart';

class AnswerResult {
  final String question;
  final String answer;
  final bool isCorrect;
  final String correctAnswer;

  AnswerResult({
    required this.question,
    required this.answer,
    required this.isCorrect,
    required this.correctAnswer,
  });
}

class AssessmentScoring {
  static List<AnswerResult> evaluateAnswers(CommunityAssessmentModel assessment) {
    final results = <AnswerResult>[];

    // Define correct answers for each question
    results.add(_evaluateAnswer(
      '1. Access to protected water sources',
      assessment.q1,
      'Yes', // Correct answer
    ));

    results.add(_evaluateAnswer(
      '2. Hires adult labor for agricultural work',
      assessment.q2,
      'Yes', // Correct answer
    ));

    results.add(_evaluateAnswer(
      '3. Awareness about child labor issues',
      assessment.q3,
      'Yes', // Correct answer
    ));

    results.add(_evaluateAnswer(
      '4. Women in leadership positions',
      assessment.q4,
      'Yes', // Correct answer
    ));

    results.add(_evaluateAnswer(
      '5. Primary schools in community',
      assessment.q5,
      'Yes', // Correct answer
    ));

    // For number of schools, we'll consider 2 or more as correct
    final hasEnoughSchools = (int.tryParse(assessment.q6 ?? '0') ?? 0) >= 2;
    results.add(_evaluateAnswer(
      '6. Number of primary schools',
      assessment.q6 ?? '0',  // Provide a default value if q6 is null
      '2 or more',
    ));

    // Add school-specific questions if applicable
    if (assessment.q7a == 1) {
      results.add(_evaluateAnswer(
        '7a. Has schools',
        'Yes',
        'Yes',
      ));

      results.add(_evaluateAnswer(
        '7b. Schools with proper toilet facilities',
        (assessment.q7c?.isNotEmpty ?? false) ? 'Yes' : 'No',
        'Yes',
      ));

      results.add(_evaluateAnswer(
        '8. Schools providing meals',
        (assessment.q8?.isNotEmpty ?? false) ? 'Yes' : 'No',
        'Yes',
      ));

      results.add(_evaluateAnswer(
        '9. Trained teachers on child protection',
        (assessment.q9?.isNotEmpty ?? false) ? 'Yes' : 'No',
        'Yes',
      ));

      results.add(_evaluateAnswer(
        '10. No corporal punishment',
        (assessment.q10?.isNotEmpty ?? false) ? 'Yes' : 'No',
        'Yes',
      ));
    }

    return results;
  }

  static int calculateScore(List<AnswerResult> results) {
    if (results.isEmpty) return 0;
    final correctCount = results.where((r) => r.isCorrect).length;
    return ((correctCount / results.length) * 100).round();
  }

  static AnswerResult _evaluateAnswer(
    String question,
    String? answer,
    String correctAnswer,
  ) {
    return AnswerResult(
      question: question,
      answer: (answer?.isNotEmpty ?? false) ? answer! : 'Not answered',
      isCorrect: answer == correctAnswer,
      correctAnswer: correctAnswer,
    );
  }
}

class AssessmentDetailScreen extends StatefulWidget {
  final CommunityAssessmentModel assessment;
  final bool isReadOnly;

  const AssessmentDetailScreen({
    Key? key,
    required this.assessment,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  State<AssessmentDetailScreen> createState() => _AssessmentDetailScreenState();
}

class _AssessmentDetailScreenState extends State<AssessmentDetailScreen> {
  late CommunityAssessmentModel _editableAssessment;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _editableAssessment = CommunityAssessmentModel.fromMap(widget.assessment.toMap());
    _isEditing = !widget.isReadOnly && _editableAssessment.status != 1;
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        // If canceling edit, reset to original values
        _editableAssessment = CommunityAssessmentModel.fromMap(widget.assessment.toMap());
      }
      _isEditing = !_isEditing;
    });
  }

  bool _showSuccessAnimation = false;

  void _showSuccess() {
    setState(() {
      _showSuccessAnimation = true;
    });

    // Hide after animation completes (3 seconds)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessAnimation = false;
        });
      }
    });
  }

 Future<void> _saveChanges() async {
  // First validate the form
  if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
    return;
  }

  // Save the form state
  _formKey.currentState?.save();

  // Create a copy of the assessment with updated timestamps
  final now = DateTime.now().toIso8601String();
  final updatedAssessment = _editableAssessment.copyWith(
    dateModified: now,
    modifiedBy: 'current_user', // You might want to get this from your auth system
  );

  // Debug log the data being saved
  debugPrint('Saving assessment data:');
  debugPrint('  ID: ${updatedAssessment.id}');
  debugPrint('  Community Name: ${updatedAssessment.communityName}');
  debugPrint('  Q1: ${updatedAssessment.q1}');
  debugPrint('  Q2: ${updatedAssessment.q2}');
  debugPrint('  Status: ${updatedAssessment.status}');

  try {
    // Save to database
    final dbHelper = CommunityDBHelper.instance;
    
    // Use insert or update based on whether this is a new assessment
    int result;
    if (updatedAssessment.id == null) {
      // New assessment - insert
      result = await dbHelper.insertCommunityAssessment(updatedAssessment.toDatabaseMap());
    } else {
      // Existing assessment - update
      result = await dbHelper.updateCommunityAssessment(updatedAssessment.toDatabaseMap());
    }

    if (result > 0) {
      // Show success animation
      if (mounted) {
        _showSuccess();
      }

      // Update UI and close edit mode
      setState(() {
        _editableAssessment = updatedAssessment;
        _isEditing = false;
      });

      // Notify parent widget to refresh if needed
      if (mounted) {
        Navigator.of(context).pop(updatedAssessment);
      }
    } else {
      throw Exception('Failed to save assessment: No rows affected');
    }
  } catch (e) {
    debugPrint('Error saving assessment: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving assessment: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    // Ensure we have a valid build context
    if (!context.mounted) return Container();
    
    final results = AssessmentScoring.evaluateAnswers(_editableAssessment);
    final score = AssessmentScoring.calculateScore(results);
    final correctAnswers = results.where((r) => r.isCorrect).length;
    final totalQuestions = results.length;
    
    // Use the editable assessment for the UI
    final assessment = _editableAssessment;
    
    // Success animation overlay
    final successAnimation = Positioned.fill(
      child: AnimatedOpacity(
        opacity: _showSuccessAnimation ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/success_animation.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                    repeat: false,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Saved Successfully!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Edit Assessment' : 'Assessment Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            if (!_isEditing && !widget.isReadOnly && _editableAssessment.status != 1) ...[
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: _toggleEditMode,
                tooltip: 'Edit Assessment',
              ),
            ] else if (_isEditing) ...[
              TextButton(
                onPressed: _toggleEditMode,
                child: Text('CANCEL', style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _saveChanges,
                child: Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
            ],
          ],
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // // Header Card
                    // _buildHeaderCard(context, score, correctAnswers, totalQuestions, assessment),
                    // const SizedBox(height: 24),
                    
                    // Assessment Overview
                    _buildSectionTitle('Assessment Overview'),
                    const SizedBox(height: 12),
                    _buildOverviewCard(assessment),
                    const SizedBox(height: 24),
                    
                    // Basic Information Section
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 12),
                    _buildBasicInfoCard(assessment),
                    const SizedBox(height: 24),
                    
                    // Questions Section
                    _buildQuestionsSection(assessment),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            if (_showSuccessAnimation) successAnimation,
          ],
        ),
      ),
        ]
      )
    );
  }

  Widget _buildHeaderCard(BuildContext context, int score, int correct, int total, CommunityAssessmentModel assessment) {
    final scoreColor = _getScoreColor(score);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Community Assessment',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (!widget.isReadOnly && _editableAssessment.status != 1)
                IconButton(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
                  onPressed: _toggleEditMode,
                  tooltip: _isEditing ? 'Cancel' : 'Edit',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Score Circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: scoreColor.withOpacity(0.2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score%',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Score',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatItem('Correct Answers', '$correct/$total', Icons.check_circle_rounded),
                      const SizedBox(height: 8),
                      _buildStatItem('Completion Date', 
                        assessment.dateCreated != null 
                            ? DateFormat('MMM d, y').format(DateTime.parse(assessment.dateCreated!))
                            : 'N/A', 
                        Icons.calendar_today_rounded),
                      const SizedBox(height: 8),
                      _buildStatItem('Status', 
                        (assessment.status == 1) ? 'Submitted' : 'Draft', 
                        Icons.fact_check_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildOverviewCard(CommunityAssessmentModel assessment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow('Community Name', assessment.communityName ?? 'Not specified', Icons.location_city_rounded),
            const Divider(height: 24),
            _buildInfoRow('Assessment Date', 
                assessment.dateCreated != null 
                    ? DateFormat('MMMM d, y • h:mm a').format(DateTime.parse(assessment.dateCreated!))
                    : 'Not available', 
                Icons.date_range_rounded),
            const Divider(height: 24),
            _buildInfoRow('Assessment Status', 
                (assessment.status == 1) ? 'Submitted' : 'Draft', 
                Icons.fact_check_rounded,
                status: assessment.status),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(CommunityAssessmentModel assessment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),
            _buildQuestionRow('Community Name', 'communityName', assessment.communityName, Icons.location_city),
            
            if (assessment.status == 1)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'This assessment has been submitted and cannot be edited.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.orange[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsSection(CommunityAssessmentModel assessment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Assessment Questions'),
            const SizedBox(height: 12),
            
            // Question 1
            _buildQuestionRow(
              '1. Do most households in this community have access to a protected water source?',
              'q1',
              assessment.q1,
              Icons.water_drop,
            ),
            
            const SizedBox(height: 16),
            
            // Question 2
            _buildQuestionRow(
              '2. Do some households in this community hire adult labourers to do agricultural work?',
              'q2',
              assessment.q2,
              Icons.agriculture,
            ),
            
            const SizedBox(height: 16),
            
            // Question 3
            _buildQuestionRow(
              '3. Has at least one awareness-raising session on child labour taken place in the past year?',
              'q3',
              assessment.q3,
              Icons.campaign,
            ),
            
            const SizedBox(height: 16),
            
            // Question 4
            _buildQuestionRow(
              '4. Are there any women among the leaders of this community?',
              'q4',
              assessment.q4,
              Icons.people_alt,
            ),
            
            const SizedBox(height: 16),
            
            // Question 5
            _buildQuestionRow(
              '5. Is there at least one pre-school in this community?',
              'q5',
              assessment.q5,
              Icons.school,
            ),
            
            const SizedBox(height: 16),
            
            // Question 6
            _buildQuestionRow(
              '6. Is there at least one primary school in this community?',
              'q6',
              assessment.q6,
              Icons.school,
            ),
            
            // School-specific questions (only show if there are primary schools)
            if ((assessment.q7a ?? 0) > 0) ...[
              const SizedBox(height: 16),
              
              // Question 7a - Number of schools
              _buildQuestionRow(
                '7a. How many primary schools are in the community?',
                'q7a',
                '${assessment.q7a} school${assessment.q7a != 1 ? 's' : ''}',
                Icons.numbers,
              ),
              
              // Question 7b - List of school names (always show if q7a > 0)
              const SizedBox(height: 16),
              _buildQuestionRow(
                '7b. List of primary schools',
                'q7b',
                assessment.q7b?.isNotEmpty == true 
                    ? assessment.q7b!.split(',').map((s) => s.trim()).join('\n')
                    : 'No schools listed',
                Icons.school,
              ),
              
              // Question 7c - Schools with separate toilets
              const SizedBox(height: 16),
              _buildQuestionRow(
                '7c. Schools with separate toilets for boys and girls',
                'q7c',
                assessment.q7c?.isNotEmpty == true 
                    ? assessment.q7c!.split(',').map((s) => '• ${s.trim()}').join('\n')
                    : 'No schools selected',
                Icons.wc,
              ),
              
              // Question 8 - Schools that provide meals
              const SizedBox(height: 16),
              _buildQuestionRow(
                '8. Which schools provide meals?',
                'q8',
                assessment.q8?.isNotEmpty == true 
                    ? assessment.q8!.split(',').map((s) => '• ${s.trim()}').join('\n')
                    : 'No schools selected',
                Icons.restaurant,
              ),
              
              // Question 9 - Scholarship access (not school-specific)
              const SizedBox(height: 16),
              _buildQuestionRow(
                '9. Do some children in the community access scholarships to attend high school?',
                'q9',
                assessment.q9?.isNotEmpty == true ? assessment.q9! : 'Not answered',
                Icons.school,
              ),
              
              // Question 10 - Schools without corporal punishment
              const SizedBox(height: 16),
              _buildQuestionRow(
                '10. Which schools do not practice corporal punishment?',
                'q10',
                assessment.q10?.isNotEmpty == true 
                    ? assessment.q10!.split(',').map((s) => '• ${s.trim()}').join('\n')
                    : 'No schools selected',
                Icons.gavel,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {int? status}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (status == 1) 
                        ? Colors.green.withOpacity(0.1) 
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (status == 1) ? 'Submitted' : 'Draft',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: (status == 1) ? Colors.green : Colors.orange,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionRow(String question, String fieldName, dynamic answer, IconData icon) {
    // Convert answer to display string
    String displayText;
    if (answer == null) {
      displayText = 'Not provided';
    } else if (answer is int) {
      displayText = answer.toString();
    } else if (answer is String) {
      displayText = answer.isNotEmpty ? answer : 'Not provided';
    } else if (answer is bool) {
      displayText = answer ? 'Yes' : 'No';
    } else {
      displayText = answer.toString();
    }

    final bool isNotProvided = displayText == 'Not provided';
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey[400]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (_isEditing && fieldName.isNotEmpty)
                _buildEditableField(fieldName, answer?.toString() ?? '')
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    displayText,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: isNotProvided ? FontWeight.w400 : FontWeight.w500,
                      color: isNotProvided ? Colors.grey[500] : Colors.grey[800],
                      fontStyle: isNotProvided ? FontStyle.italic : null,
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildEditableField(String fieldName, String value) {
    // Ensure we have a valid string value
    final displayValue = value ?? '';
    // Determine keyboard type based on field type
    final isNumericField = fieldName == 'q7a' || fieldName == 'q6';
    final isMultiline = fieldName == 'q7b' || fieldName == 'q7c' || 
                       fieldName == 'notes' || fieldName == 'rawData';
    
    return TextFormField(
      initialValue: displayValue,
      style: GoogleFonts.inter(
        fontSize: 15,
        color: Colors.grey[800],
      ),
      keyboardType: isNumericField ? TextInputType.number : TextInputType.text,
      maxLines: isMultiline ? 3 : 1,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (isNumericField && int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
      onChanged: (newValue) {
        // Update the corresponding field in _editableAssessment
        setState(() {
          // Handle all field updates in a single switch statement
          switch (fieldName) {
            // Basic Information
            case 'communityName':
              _editableAssessment.communityName = newValue;
              break;
              
            // Question fields
            case 'q1':
              _editableAssessment.q1 = newValue;
              break;
            case 'q2':
              _editableAssessment.q2 = newValue;
              break;
            case 'q3':
              _editableAssessment.q3 = newValue;
              break;
            case 'q4':
              _editableAssessment.q4 = newValue;
              break;
            case 'q5':
              _editableAssessment.q5 = newValue;
              break;
            case 'q6':
              _editableAssessment.q6 = newValue;
              break;
            case 'q7a':
              _editableAssessment.q7a = int.tryParse(newValue) ?? 0;
              break;
            case 'q7b':
              _editableAssessment.q7b = newValue;
              break;
            case 'q7c':
              _editableAssessment.q7c = newValue;
              break;
            case 'q8':
              _editableAssessment.q8 = newValue;
              break;
            case 'q9':
              _editableAssessment.q9 = newValue;
              break;
            case 'q10':
              _editableAssessment.q10 = newValue;
              break;
              
            // Other fields
            case 'notes':
              _editableAssessment.notes = newValue;
              break;
            case 'rawData':
              _editableAssessment.rawData = newValue;
              break;
              
            // Fallback for any other fields (shouldn't normally be reached)
            default:
              debugPrint('Warning: Unhandled field in _buildEditableField: $fieldName');
              try {
                final field = _editableAssessment.toMap().keys.firstWhere(
                  (key) => key.toString().toLowerCase() == fieldName.toLowerCase(),
                  orElse: () => '',
                );
                if (field.isNotEmpty) {
                  // Create an updated map with the new value
                  final updatedMap = Map<String, dynamic>.from(_editableAssessment.toMap())
                    ..[field] = newValue;
                  
                  // Create a new instance with the updated values
                  _editableAssessment = CommunityAssessmentModel.fromMap(updatedMap);
                }
              } catch (e) {
                debugPrint('Error updating field $fieldName: $e');
              }
          }
        });
      },
    );
  }

  Widget _buildResultItem(AnswerResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isCorrect ? Colors.green[100]! : Colors.red[100]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            result.isCorrect ? Icons.check_circle_rounded : Icons.error_rounded,
            color: result.isCorrect ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.question,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Your answer: ${result.answer}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      if (!result.isCorrect) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green[100]!),
                          ),
                          child: Text(
                            'Expected: ${result.correctAnswer}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 90) return 'Excellent - Community meets all child protection standards';
    if (score >= 70) return 'Good - Community meets most child protection standards';
    if (score >= 50) return 'Fair - Some child protection concerns need attention';
    return 'Needs Improvement - Significant child protection concerns identified';
  }
}