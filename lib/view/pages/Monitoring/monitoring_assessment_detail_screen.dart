import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/models/monitoring_model.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';
import 'package:intl/intl.dart';

class MonitoringAssessmentDetailScreen extends StatefulWidget {
  final MonitoringModel assessment;
  
  const MonitoringAssessmentDetailScreen({
    Key? key,
    required this.assessment,
  }) : super(key: key);

  @override
  _MonitoringAssessmentDetailScreenState createState() => _MonitoringAssessmentDetailScreenState();
}

class _MonitoringAssessmentDetailScreenState extends State<MonitoringAssessmentDetailScreen> {
  bool _isEditing = false;
  late MonitoringModel _editableAssessment;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _editableAssessment = widget.assessment;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to original values if canceling edit
        _editableAssessment = widget.assessment;
      }
    });
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // TODO: Save changes to database
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
    }
  }

  String _getYesNoAnswer(bool? value) {
    if (value == null) return 'Not answered';
    return value ? 'Yes' : 'No';
  }

  String _getNullableText(String? value) {
    return value?.isNotEmpty == true ? value! : 'Not specified';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Assessment Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEditMode,
          ),
          if (_isEditing)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 16),
              
              // Section 1: Child Identification
              _buildSectionTitle('Section 1: Child Identification'),
              _buildChildInfoCard(),
              const SizedBox(height: 16),
              
              // Section 2: Education Progress
              _buildSectionTitle('Section 2: Education Progress'),
              _buildEducationDetailsCard(),
              const SizedBox(height: 16),
              
              // Section 3: Child Labour Risk
              _buildSectionTitle('Section 3: Child Labour Risk'),
              _buildChildLabourRiskCard(),
              const SizedBox(height: 16),
              
              // Section 4: Legal Documentation
              _buildSectionTitle('Section 4: Legal Documentation'),
              _buildLegalDocumentationCard(),
              const SizedBox(height: 16),
              
              // Section 5: Family & Caregiver Engagement
              _buildSectionTitle('Section 5: Family & Caregiver Engagement'),
              _buildFamilyEngagementCard(),
              const SizedBox(height: 16),
              
              // Section 6: Additional Support Provided
              _buildSectionTitle('Section 6: Additional Support Provided'),
              _buildAdditionalSupportCard(),
              const SizedBox(height: 16),
              
              // Section 7: Overall Assessment
              _buildSectionTitle('Section 7: Overall Assessment'),
              _buildOverallAssessmentCard(),
              const SizedBox(height: 16),
              
              // Section 8: Follow-up Cycle Completion
              _buildSectionTitle('Section 8: Follow-up Cycle Completion'),
              _buildFollowUpCycleCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final formattedDate = _editableAssessment.visitDate != null
        ? DateFormat('MMM dd, yyyy').format(_editableAssessment.visitDate!)
        : 'Not specified';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: const Icon(Icons.assignment, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editableAssessment.childName.isNotEmpty 
                            ? _editableAssessment.childName 
                            : 'Unnamed Assessment',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visit Date: $formattedDate',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _editableAssessment.status == 1 
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _editableAssessment.status == 1 ? 'Submitted' : 'Pending',
                    style: GoogleFonts.poppins(
                      color: _editableAssessment.status == 1 
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildChildInfoCard() {
    return _buildInfoCard([
      _buildInfoRow('1. Child ID', _getNullableText(_editableAssessment.childId), Icons.person_outline),
      _buildInfoRow('2. Child Name', _getNullableText(_editableAssessment.childName), Icons.person),
      _buildInfoRow('3. Age', _getNullableText(_editableAssessment.age), Icons.cake_outlined),
      _buildInfoRow('4. Gender', _getNullableText(_editableAssessment.sex), Icons.transgender),
      _buildInfoRow('5. Community', _getNullableText(_editableAssessment.community), Icons.location_on_outlined),
      _buildInfoRow('6. Farmer ID', _getNullableText(_editableAssessment.farmerId), Icons.assignment_ind_outlined),
      _buildInfoRow('7. First Remediation Date', _getNullableText(_editableAssessment.firstRemediationDate), Icons.calendar_today_outlined),
      _buildInfoRow('8. Remediation Form Provided', _getNullableText(_editableAssessment.remediationFormProvided), Icons.description_outlined),
      _buildInfoRow('Follow-up Visits Since Identification', _getNullableText(_editableAssessment.followUpVisitsCountSinceIdentification), Icons.update_outlined),
      _buildInfoRow('9. Follow-up Visits Count', _getNullableText(_editableAssessment.followUpVisitsCount), Icons.update_outlined),
    ]);
  }

  Widget _buildEducationDetailsCard() {
    return _buildInfoCard([
      _buildInfoRow('10. Is the child currently enrolled in school?', 
          _getYesNoAnswer(_editableAssessment.isEnrolledInSchool), Icons.school_outlined),
      _buildInfoRow('11. Has school attendance improved since remediation?', 
          _getYesNoAnswer(_editableAssessment.attendanceImproved), Icons.event_available),
      _buildInfoRow('12. Has the child received any school materials (uniforms, books, etc.)?', 
          _getYesNoAnswer(_editableAssessment.receivedSchoolMaterials), Icons.school),
      _buildInfoRow('13. Can the child now read basic text?', 
          _getYesNoAnswer(_editableAssessment.canReadBasicText), Icons.menu_book),
      _buildInfoRow('14. Can the child now write basic text?', 
          _getYesNoAnswer(_editableAssessment.canWriteBasicText), Icons.edit),
      _buildInfoRow('15. Can the child now perform basic calculations?', 
          _getYesNoAnswer(_editableAssessment.canDoCalculations), Icons.calculate),
      _buildInfoRow('16. Has the child advanced to the next grade level?', 
          _getYesNoAnswer(_editableAssessment.advancedToNextGrade), Icons.trending_up_outlined),
      _buildInfoRow('17. At the time of remediation, what class was the child enrolled in?', 
          _getNullableText(_editableAssessment.classAtRemediation), Icons.class_outlined),
      _buildInfoRow('18. Has the academic year ended?', 
          _getYesNoAnswer(_editableAssessment.academicYearEnded), Icons.calendar_today),
      
      if (_editableAssessment.academicYearEnded) ...[
        _buildInfoRow('19. Has the child been promoted?', 
            _getYesNoAnswer(_editableAssessment.promoted), Icons.trending_up),
        
        if (_editableAssessment.promoted == true)
          _buildInfoRow('20. What is the new grade?', 
              _getNullableText(_editableAssessment.promotedGrade), Icons.grade),
        
        if (_editableAssessment.promoted == false)
          _buildInfoRow('21. Has there been an improvement in reading, writing and calculations?', 
              _getYesNoAnswer(_editableAssessment.academicImprovement), Icons.psychology_outlined),
        
        if (_editableAssessment.academicImprovement == false)
          _buildInfoRow('22. What are the recommendations?', 
              _getNullableText(_editableAssessment.recommendations), Icons.recommend),
      ],
    ]);
  }

  Widget _buildChildLabourRiskCard() {
    return _buildInfoCard([
      _buildInfoRow('23. Is the child currently engaged in any hazardous work?', 
          _getYesNoAnswer(_editableAssessment.engagedInHazardousWork), Icons.warning_amber_outlined),
      if (_editableAssessment.hazardousWorkDetails?.isNotEmpty ?? false)
        _buildInfoRow('Hazardous Work Details', _editableAssessment.hazardousWorkDetails!, Icons.info_outline),
      
      _buildInfoRow('24. Has the child reduced hours spent on farm or work-related tasks?', 
          _getYesNoAnswer(_editableAssessment.reducedWorkHours), Icons.timer_outlined),
      if (_editableAssessment.reducedWorkHoursDetails?.isNotEmpty ?? false)
        _buildInfoRow('Reduced Work Hours Details', _editableAssessment.reducedWorkHoursDetails!, Icons.info_outline),
      
      _buildInfoRow('25. Is the child involved in any permitted light work within acceptable limits?', 
          _getYesNoAnswer(_editableAssessment.involvedInLightWork), Icons.work_outline),
      if (_editableAssessment.lightWorkDetails?.isNotEmpty ?? false)
        _buildInfoRow('Light Work Details', _editableAssessment.lightWorkDetails!, Icons.info_outline),
      
      _buildInfoRow('26. Has the child remained out of hazardous work for at least two consecutive visits?', 
          _getYesNoAnswer(_editableAssessment.outOfHazardousWork), Icons.verified_outlined),
      if (_editableAssessment.hazardousWorkFreePeriodDetails?.isNotEmpty ?? false)
        _buildInfoRow('Hazardous Work Free Period Details', _editableAssessment.hazardousWorkFreePeriodDetails!, Icons.timer_off_outlined),
    ]);
  }

  Widget _buildLegalDocumentationCard() {
    return _buildInfoCard([
      _buildInfoRow('27. Does the child now have a birth certificate?', 
          _getYesNoAnswer(_editableAssessment.hasBirthCertificate), Icons.badge_outlined),
      
      if (!_editableAssessment.hasBirthCertificate) ...[
        _buildInfoRow('28. Is there an ongoing process to obtain one?', 
            _getYesNoAnswer(_editableAssessment.ongoingBirthCertProcess), Icons.pending_actions_outlined),
        
        if (_editableAssessment.ongoingBirthCertProcessDetails?.isNotEmpty ?? false)
          _buildInfoRow('Ongoing Process Details', _editableAssessment.ongoingBirthCertProcessDetails!, Icons.info_outline),
        
        if (_editableAssessment.ongoingBirthCertProcess == false)
          _buildInfoRow('29. If no, why?', 
              _getNullableText(_editableAssessment.noBirthCertificateReason), Icons.help_outline),
      ],
    ]);
  }

  Widget _buildFamilyEngagementCard() {
    return _buildInfoCard([
   _buildInfoRow('30. Has the household received awareness-raising sessions on child labour risks?', 
    _getYesNoAnswer(_editableAssessment.receivedAwarenessSessions), Icons.record_voice_over_outlined),
      if (_editableAssessment.awarenessSessionsDetails?.isNotEmpty ?? false)
        _buildInfoRow('Awareness Sessions Details', _editableAssessment.awarenessSessionsDetails!, Icons.details_outlined),
      
      _buildInfoRow('31. Do caregivers demonstrate improved understanding of child protection?', 
          _getYesNoAnswer(_editableAssessment.improvedUnderstanding), Icons.psychology_outlined),
      if (_editableAssessment.understandingImprovementDetails?.isNotEmpty ?? false)
        _buildInfoRow('Understanding Improvement Details', _editableAssessment.understandingImprovementDetails!, Icons.lightbulb_outline),
      
      _buildInfoRow('32. Have caregivers taken steps to keep the child in school (e.g., paying fees, providing materials)?', 
          _getYesNoAnswer(_editableAssessment.caregiversSupportSchool), Icons.school_outlined),
      if (_editableAssessment.caregiverSupportDetails?.isNotEmpty ?? false)
        _buildInfoRow('Caregiver Support Details', _editableAssessment.caregiverSupportDetails!, Icons.family_restroom_outlined),
    ]);
  }

  Widget _buildAdditionalSupportCard() {
    return _buildInfoCard([
      _buildInfoRow('33. Has the child or household received financial or material support (cash transfer, farm input, etc.)?', 
          _getYesNoAnswer(_editableAssessment.receivedFinancialSupport), Icons.attach_money_outlined),
      if (_editableAssessment.financialSupportDetails?.isNotEmpty ?? false)
        _buildInfoRow('Financial Support Details', _editableAssessment.financialSupportDetails!, Icons.receipt_outlined),
      
      _buildInfoRow('34. Were referrals made to other services (health, legal, social)?', 
          _getYesNoAnswer(_editableAssessment.referralsMade), Icons.mediation_outlined),
      if (_editableAssessment.referralsDetails?.isNotEmpty ?? false)
        _buildInfoRow('Referrals Details', _editableAssessment.referralsDetails!, Icons.contact_support_outlined),
      
      _buildInfoRow('35. Are there ongoing follow-up visits planned?', 
          _getYesNoAnswer(_editableAssessment.ongoingFollowUpPlanned), Icons.update_outlined),
      if (_editableAssessment.followUpPlanDetails?.isNotEmpty ?? false)
        _buildInfoRow('Follow-up Plan Details', _editableAssessment.followUpPlanDetails!, Icons.note_outlined),
    ]);
  }

  Widget _buildOverallAssessmentCard() {
    return _buildInfoCard([
      _buildInfoRow('36. Based on progress, is the child considered remediated (no longer in child labour)?', 
          _getYesNoAnswer(_editableAssessment.consideredRemediated), Icons.assessment_outlined),
      
      _buildInfoRow('Additional comments or observations', 
          _getNullableText(_editableAssessment.additionalComments), Icons.comment_outlined),
    ]);
  }

  Widget _buildFollowUpCycleCard() {
    return _buildInfoCard([
      _buildInfoRow('37. How many follow-up visits have been conducted since the child was first identified?', 
          _getNullableText(_editableAssessment.followUpVisitsCountSinceIdentification), Icons.format_list_numbered),
      
      _buildInfoRow('38. Were the visits spaced between 3-6 months apart?', 
          _getYesNoAnswer(_editableAssessment.visitsSpacedCorrectly), Icons.timeline_outlined),
      
      _buildInfoRow('39. At the last two consecutive visits, was the child confirmed not to be in child labour?', 
          _getYesNoAnswer(_editableAssessment.confirmedNotInChildLabour), Icons.verified_user_outlined),
      
      _buildInfoRow('40. Based on this, can the follow-up cycle for this child be considered complete?', 
          _getYesNoAnswer(_editableAssessment.followUpCycleComplete), Icons.done_all_outlined),
    ]);
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}