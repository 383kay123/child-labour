import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../controller/db/db_tables/community_assessment_table.dart';
import '../../../../controller/api/api.dart';
import '../../../../controller/db/community_db_helper.dart';
import '../../../../controller/models/community-assessment-model.dart';
import '../../../theme/app_theme.dart';
import '../assessment_detail_screen.dart';

class CommunityAssessmentHistory extends StatefulWidget {
  const CommunityAssessmentHistory({super.key});

  @override
  _CommunityAssessmentHistoryState createState() =>
      _CommunityAssessmentHistoryState();
}

class _CommunityAssessmentHistoryState extends State<CommunityAssessmentHistory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityDBHelper _dbHelper = CommunityDBHelper.instance;
  List<CommunityAssessmentModel> _pendingAssessments = [];
  List<CommunityAssessmentModel> _submittedAssessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final allAssessments = await _dbHelper.getAllCommunityAssessments();

      final pending =
          allAssessments.where((a) => (a['status'] ?? 0) == 0).map((e) {
        final communityName = e['communityName'] ??
            e['community_name'] ??
            e['village'] ??
            e['parish'] ??
            e['sub_county'] ??
            'Community Assessment';

        return CommunityAssessmentModel.fromMap({
          'id': e['id'],
          'communityName': communityName,
          'communityScore': e['communityScore'] ?? 0,
          'status': e['status'] ?? 0,
          'q1': e['q1'] ?? e['region'] ?? '',
          'q2': e['q2'] ?? e['total_population']?.toString() ?? '',
          'q3': e['q3'] ?? e['total_children']?.toString() ?? '',
          'q4': e['q4'] ?? e['primary_schools_count']?.toString() ?? '',
          'q5': e['q5'] ?? (e['has_protected_water'] == 1 ? 'Yes' : 'No'),
          'q6': e['q6'] ?? (e['hires_adult_labor'] == 1 ? 'Yes' : 'No'),
          'q7a': e['q7a'] ?? (e['child_labor_awareness'] == 1 ? 1 : 0),
          'q7b': e['q7b'] ?? '',
          'q7c': e['q7c'] ?? '',
          'q8': e['q8'] ?? (e['has_women_leaders'] == 1 ? 'Yes' : 'No'),
          'q9': e['q9'] ?? '',
          'q10': e['q10'] ?? '',
          'date_created': e['date_created'] ?? DateTime.now().toIso8601String(),
        });
      }).toList();

      final submitted =
          allAssessments.where((a) => (a['status'] ?? 0) == 1).map((e) {
        final communityName = e['communityName'] ??
            e['community_name'] ??
            e['village'] ??
            e['parish'] ??
            e['sub_county'] ??
            'Community Assessment';

        return CommunityAssessmentModel.fromMap({
          'id': e['id'],
          'communityName': communityName,
          'communityScore': e['communityScore'] ?? 0,
          'status': e['status'] ?? 1,
          'q1': e['q1'] ?? e['region'] ?? '',
          'q2': e['q2'] ?? e['total_population']?.toString() ?? '',
          'q3': e['q3'] ?? e['total_children']?.toString() ?? '',
          'q4': e['q4'] ?? e['primary_schools_count']?.toString() ?? '',
          'q5': e['q5'] ?? (e['has_protected_water'] == 1 ? 'Yes' : 'No'),
          'q6': e['q6'] ?? (e['hires_adult_labor'] == 1 ? 'Yes' : 'No'),
          'q7a': e['q7a'] ?? (e['child_labor_awareness'] == 1 ? 1 : 0),
          'q7b': e['q7b'] ?? '',
          'q7c': e['q7c'] ?? '',
          'q8': e['q8'] ?? (e['has_women_leaders'] == 1 ? 'Yes' : 'No'),
          'q9': e['q9'] ?? '',
          'q10': e['q10'] ?? '',
          'date_created': e['date_created'] ?? DateTime.now().toIso8601String(),
        });
      }).toList();

      if (mounted) {
        setState(() {
          _pendingAssessments = pending;
          _submittedAssessments = submitted;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading assessments: $e');
      Get.snackbar(
        'Error',
        'Failed to load assessments: $e',
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Community Assessment History',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.white70,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_note, size: 18),
                        const SizedBox(width: 6),
                        const Text('Pending'),
                        if (_pendingAssessments.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
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
                ),
                Tab(
                  child: Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 18),
                        const SizedBox(width: 6),
                        const Text('Submitted'),
                        if (_submittedAssessments.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
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
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAssessmentList(_pendingAssessments, false, context),
                _buildAssessmentList(_submittedAssessments, true, context),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Assessments...',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentList(List<CommunityAssessmentModel> assessments,
      bool isSubmitted, BuildContext context) {
    if (assessments.isEmpty) {
      return _buildEmptyState(isSubmitted);
    }

    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: AppTheme.primaryColor,
      onRefresh: _loadAssessments,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: assessments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildAssessmentCard(assessments[index], context);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isSubmitted) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSubmitted
                  ? Icons.assignment_turned_in
                  : Icons.assignment_outlined,
              size: 50,
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSubmitted ? 'No Submitted Assessments' : 'No Pending Assessments',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isSubmitted
                  ? 'All completed assessments will appear here'
                  : 'Start a new community assessment to see it here',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(CommunityAssessmentModel assessment) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AssessmentDetailScreen(
          assessment: assessment,
          isReadOnly: assessment.status == 1,
        ),
      ),
    )
        .then((_) {
      _loadAssessments();
    });
  }

  Future<void> _deleteAssessment(CommunityAssessmentModel assessment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              // Add this
              child: Text(
                'Delete Assessment',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis, // Add this
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the assessment for ${assessment.communityName ?? 'this community'}? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success =
            await _dbHelper.deleteCommunityAssessment(assessment.id!);
        if (success == true && mounted) {
          setState(() {
            if (assessment.status == 0) {
              _pendingAssessments.removeWhere((a) => a.id == assessment.id);
            } else {
              _submittedAssessments.removeWhere((a) => a.id == assessment.id);
            }
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Assessment deleted successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting assessment: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    }
  }

  // Helper method to check if device has internet access
  Future<bool> _isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  Future<void> _submitAssessment(CommunityAssessmentModel assessment) async {
    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Checking internet connection...'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    // Check internet connectivity
    final hasInternet = await _isInternetAvailable();

    if (!hasInternet) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'No internet connection. Please check your connection and try again.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
      return;
    }

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Submitting assessment...'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

      // First try to submit to the API
      try {
        // // final api = ApiService();
        // final apiSuccess = await api.submitCommunityAssessment(assessment);

        // if (apiSuccess) {
        //   // If API submission is successful, update local status to submitted (2)
        //   await _dbHelper.updateAssessmentStatus(assessment.id!, 2);

        //   if (mounted) {
        //     setState(() {
        //       _pendingAssessments.removeWhere((a) => a.id == assessment.id);
        //       _submittedAssessments.add(assessment.copyWith(status: 2));
        //     });

        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: const Text('Assessment submitted and synced successfully'),
        //         backgroundColor: Colors.green,
        //         behavior: SnackBarBehavior.floating,
        //         duration: const Duration(seconds: 3),
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        //       ),
        //     );
        //   }
        // } else {
        //   throw Exception('Failed to submit to server');
        // }
      } catch (e) {
        debugPrint('Error submitting to API: $e');
        // If API fails, save as pending (status 1)
        final success =
            await _dbHelper.updateAssessmentStatus(assessment.id!, 1);

        if (success && mounted) {
          setState(() {
            _pendingAssessments.removeWhere((a) => a.id == assessment.id);
            _submittedAssessments.add(assessment.copyWith(status: 1));
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Assessment saved locally. Will sync when online.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        } else {
          throw Exception('Failed to save assessment locally');
        }
      }
    } catch (e) {
      debugPrint('Error in _submitAssessment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting assessment: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Widget _buildAssessmentCard(
      CommunityAssessmentModel assessment, BuildContext context) {
    final isSubmitted = assessment.status == 1;
    final statusColor = isSubmitted ? Colors.green : Colors.orange;

    final score = _calculateScore(assessment);

    DateTime createdAt;
    try {
      createdAt = assessment.dateCreated != null
          ? DateTime.parse(assessment.dateCreated!)
          : DateTime.now();
    } catch (e) {
      createdAt = DateTime.now();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSubmitted ? Icons.check_circle : Icons.edit,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isSubmitted ? 'SUBMITTED' : 'DRAFT',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, y • h:mm a').format(createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Main content
          InkWell(
            onTap: () => _navigateToDetail(assessment),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Community name and score
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getDisplayName(assessment),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey[800],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Score with progress bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Assessment Score',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '$score%',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: _getScoreColor(score),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Stack(
                                    children: [
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            width: constraints.maxWidth *
                                                (score / 100),
                                            decoration: BoxDecoration(
                                              color: _getScoreColor(score),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Assessment details in grid
                  if (_hasAssessmentDetails(assessment))
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (assessment.q2?.isNotEmpty == true)
                            Expanded(
                              child: _buildDetailItem(
                                  '👥', 'Population', assessment.q2!),
                            ),
                          if (assessment.q3?.isNotEmpty == true)
                            Expanded(
                              child: _buildDetailItem(
                                  '👶', 'Children', assessment.q3!),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Action buttons for pending assessments
          if (!isSubmitted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Submit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _submitAssessment(assessment),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        side: BorderSide(color: Colors.red[700]!),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _deleteAssessment(assessment),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Fixed score calculation with proper null checking
  int _calculateScore(CommunityAssessmentModel assessment) {
    int score = 0;

    // Use null-safe checks with == true comparison
    if ((assessment.q1 == 'Yes') == true) score++;
    if ((assessment.q2 == 'Yes') == true) score++;
    if ((assessment.q3 == 'Yes') == true) score++;
    if ((assessment.q4 == 'Yes') == true) score++;
    if ((assessment.q5 == 'Yes') == true) score++;
    if ((assessment.q6 == 'Yes') == true) score++;
    if (assessment.q7a == 1) score++;
    if ((assessment.q8 == 'Yes') == true) score++;
    if ((assessment.q9 == 'Yes') == true) score++;
    if ((assessment.q10 == 'Yes') == true) score++;

    return (score / 10 * 100).round();
  }

  // Helper method to check if assessment has details to display
  bool _hasAssessmentDetails(CommunityAssessmentModel assessment) {
    return assessment.q2?.isNotEmpty == true ||
        assessment.q3?.isNotEmpty == true;
  }

  // Helper method to get the most specific available location name
  String _getDisplayName(CommunityAssessmentModel assessment) {
    return assessment.communityName?.trim().isNotEmpty == true
        ? assessment.communityName!
        : assessment.village?.trim().isNotEmpty == true
            ? assessment.village!
            : assessment.parish?.trim().isNotEmpty == true
                ? '${assessment.parish} Parish'
                : assessment.subCounty?.trim().isNotEmpty == true
                    ? '${assessment.subCounty} Sub-county'
                    : assessment.district?.trim().isNotEmpty == true
                        ? '${assessment.district} District'
                        : 'Unnamed Community';
  }

  Widget _buildDetailItem(String emoji, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.blueGrey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
