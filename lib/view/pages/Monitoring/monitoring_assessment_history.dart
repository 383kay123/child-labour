import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/monitoring_db_helper.dart';
import 'package:intl/intl.dart';


import '../../../../controller/models/monitoring_model.dart';
import '../../../../utils/monitoring_dummy_data.dart';
import '../../../../controller/models/monitoring_model.dart' as controller_models;
import 'monitoring_assessment_detail_screen.dart';
import '../../theme/app_theme.dart';

class MonitoringAssessmentHistory extends StatefulWidget {
  const MonitoringAssessmentHistory({super.key});

  @override
  State<MonitoringAssessmentHistory> createState() => _MonitoringAssessmentHistoryState();
}

class _MonitoringAssessmentHistoryState extends State<MonitoringAssessmentHistory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MonitoringDBHelper _databaseHelper = MonitoringDBHelper.instance;
  List<MonitoringModel> _pendingAssessments = [];
  List<MonitoringModel> _submittedAssessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAssessments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssessments() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final pending = await _databaseHelper.getMonitoringRecordsByStatus(0);
      final submitted = await _databaseHelper.getMonitoringRecordsByStatus(1);
      
      if (mounted) {
        setState(() {
          _pendingAssessments = pending;
          _submittedAssessments = submitted;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading assessments: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Assessment History',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pending'),
                  if (_pendingAssessments.isNotEmpty) ...[
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _pendingAssessments.length.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Submitted'),
                  if (_submittedAssessments.isNotEmpty) ...[
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _submittedAssessments.length.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
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
      body: _isLoading
          ? _buildLoadingState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAssessmentList(_pendingAssessments, false),
                _buildAssessmentList(_submittedAssessments, true),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading assessments...',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentList(List<controller_models.MonitoringModel> assessments, bool isSubmitted) {
    if (assessments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSubmitted ? Icons.assignment_turned_in : Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16),
            Text(
              isSubmitted ? 'No submitted assessments' : 'No pending assessments',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAssessments,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: assessments.length,
        itemBuilder: (context, index) {
          return _buildAssessmentCard(assessments[index], isSubmitted);
        },
      ),
    );
  }

  Widget _buildAssessmentCard(controller_models.MonitoringModel assessment, bool isSubmitted) {
    DateTime createdAt = assessment.dateCreated ?? DateTime.now();
    DateTime? modifiedAt = assessment.dateModified;
    String childName = assessment.childName?.isNotEmpty == true 
        ? assessment.childName! 
        : 'Assessment #${assessment.id ?? 'N/A'}';
    int score = _calculateMonitoringScore(assessment);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonitoringAssessmentDetailScreen(assessment: assessment),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with status and date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSubmitted ? Colors.green[50] : Colors.orange[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSubmitted ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isSubmitted ? 'SUBMITTED' : 'DRAFT',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    DateFormat('MMM d, y').format(createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            childName,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ID: ${assessment.id ?? 'N/A'}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress circle
                    Container(
                      width: 40,
                      height: 40,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: score / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
                            strokeWidth: 4,
                          ),
                          Center(
                            child: Text(
                              '$score%',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _getScoreColor(score),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Additional details
                Row(
                  children: [
                    _buildDetailChip(
                      Icons.access_time, 
                      modifiedAt != null 
                          ? 'Modified ${DateFormat('MMM d').format(modifiedAt)}'
                          : 'Created ${DateFormat('MMM d').format(createdAt)}'
                    ),
                    SizedBox(width: 8),
                    _buildDetailChip(
                      Icons.description,
                      '${_getFieldCount(assessment)} fields'
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Action buttons
                if (!isSubmitted)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _submitAssessment(assessment),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: BorderSide(color: Colors.green),
                            padding: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _deleteAssessment(assessment),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red),
                            padding: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      )
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateMonitoringScore(controller_models.MonitoringModel assessment) {
    // Calculate score based on available data in your model
    int score = 30; // Base score
    
    // Add points based on filled fields that exist in your model
    if (assessment.childName?.isNotEmpty == true) score += 20;
    if (assessment.dateModified != null) score += 15;
    if (assessment.id != null) score += 10;
    if (assessment.status != null) score += 10;
    
    // Add more fields based on what exists in your MonitoringModel
    // You can add other fields that you know exist in your model
    
    return score.clamp(0, 100);
  }

  String _getFieldCount(controller_models.MonitoringModel assessment) {
    // Count how many fields are populated
    int count = 0;
    if (assessment.childName?.isNotEmpty == true) count++;
    if (assessment.dateCreated != null) count++;
    if (assessment.dateModified != null) count++;
    // Add other fields that exist in your model
    
    return count.toString();
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Future<void> _submitAssessment(controller_models.MonitoringModel assessment) async {
    try {
      // Create a copy of the assessment with status updated to 1 (submitted)
      final updatedAssessment = controller_models.MonitoringModel(
        id: assessment.id,
        visitDate: assessment.visitDate, // Required field
        dateCreated: assessment.dateCreated,
        dateModified: DateTime.now(),
        status: 1, // Set status to 1 for submitted
        communityId: assessment.communityId,
        notes: assessment.notes,
        rawData: assessment.rawData,
        
        // Section 1: Child Identification
        childId: assessment.childId,
        childName: assessment.childName,
        age: assessment.age,
        sex: assessment.sex,
        community: assessment.community,
        farmerId: assessment.farmerId,
        firstRemediationDate: assessment.firstRemediationDate,
        remediationFormProvided: assessment.remediationFormProvided,
        followUpVisitsCount: assessment.followUpVisitsCount,
        
        // Section 2: Education Progress
        classAtRemediation: assessment.classAtRemediation,
        isEnrolledInSchool: assessment.isEnrolledInSchool,
        attendanceImproved: assessment.attendanceImproved,
        receivedSchoolMaterials: assessment.receivedSchoolMaterials,
        canReadBasicText: assessment.canReadBasicText,
        canWriteBasicText: assessment.canWriteBasicText,
        canDoCalculations: assessment.canDoCalculations,
        advancedToNextGrade: assessment.advancedToNextGrade,
        academicYearEnded: assessment.academicYearEnded,
        promoted: assessment.promoted,
        academicImprovement: assessment.academicImprovement,
        promotedGrade: assessment.promotedGrade,
        recommendations: assessment.recommendations,
        
        // Section 3: Child Labour Risk
        engagedInHazardousWork: assessment.engagedInHazardousWork,
        reducedWorkHours: assessment.reducedWorkHours,
        involvedInLightWork: assessment.involvedInLightWork,
        outOfHazardousWork: assessment.outOfHazardousWork,
        hazardousWorkDetails: assessment.hazardousWorkDetails,
        reducedWorkHoursDetails: assessment.reducedWorkHoursDetails,
        lightWorkDetails: assessment.lightWorkDetails,
        hazardousWorkFreePeriodDetails: assessment.hazardousWorkFreePeriodDetails,
        
        // Section 4: Legal Documentation
        hasBirthCertificate: assessment.hasBirthCertificate,
        ongoingBirthCertProcess: assessment.ongoingBirthCertProcess,
        noBirthCertificateReason: assessment.noBirthCertificateReason,
        birthCertificateStatus: assessment.birthCertificateStatus,
        ongoingBirthCertProcessDetails: assessment.ongoingBirthCertProcessDetails,
        
        // Section 5: Family & Caregiver Engagement
        receivedAwarenessSessions: assessment.receivedAwarenessSessions,
        improvedUnderstanding: assessment.improvedUnderstanding,
        caregiversSupportSchool: assessment.caregiversSupportSchool,
        awarenessSessionsDetails: assessment.awarenessSessionsDetails,
        understandingImprovementDetails: assessment.understandingImprovementDetails,
        caregiverSupportDetails: assessment.caregiverSupportDetails,
        
        // Section 6: Additional Support Provided
        receivedFinancialSupport: assessment.receivedFinancialSupport,
        referralsMade: assessment.referralsMade,
        ongoingFollowUpPlanned: assessment.ongoingFollowUpPlanned,
        financialSupportDetails: assessment.financialSupportDetails,
        referralsDetails: assessment.referralsDetails,
        followUpPlanDetails: assessment.followUpPlanDetails,
        
        // Section 7: Overall Assessment
        consideredRemediated: assessment.consideredRemediated,
        additionalComments: assessment.additionalComments,
        
        // Section 8: Follow-up Cycle Completion
        followUpVisitsCountSinceIdentification: assessment.followUpVisitsCountSinceIdentification,
        visitsSpacedCorrectly: assessment.visitsSpacedCorrectly,
        confirmedNotInChildLabour: assessment.confirmedNotInChildLabour,
        followUpCycleComplete: assessment.followUpCycleComplete,
        
        // Additional fields
        currentSchool: assessment.currentSchool,
        currentGrade: assessment.currentGrade,
        attendanceRate: assessment.attendanceRate,
        schoolPerformance: assessment.schoolPerformance,
        challengesFaced: assessment.challengesFaced,
        supportNeeded: assessment.supportNeeded,
        attendanceNotes: assessment.attendanceNotes,
        performanceNotes: assessment.performanceNotes,
        supportNotes: assessment.supportNotes,
        otherNotes: assessment.otherNotes,
      );
      
      // Update the assessment in the database
      await _databaseHelper.updateMonitoringRecord(updatedAssessment);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assessment submitted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Reload the assessments to reflect the changes
        _loadAssessments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting assessment: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteAssessment(controller_models.MonitoringModel assessment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Assessment', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to delete this assessment? This action cannot be undone.', 
          style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Implement delete functionality
        // await _databaseHelper.deleteMonitoringAssessment(assessment.id!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Assessment deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadAssessments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting assessment: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}