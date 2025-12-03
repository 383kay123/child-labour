import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/api/auth/auth_api.dart';
import 'package:human_rights_monitor/controller/api/get_methods.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/community_db_helper.dart';
import 'package:human_rights_monitor/controller/db/db_tables/repositories/society_repo.dart';
import 'package:human_rights_monitor/controller/models/auth/user_model.dart';
import 'package:human_rights_monitor/controller/models/community-assessment-model.dart';
import 'package:human_rights_monitor/controller/models/societies/societies_model.dart';
import 'package:human_rights_monitor/view/pages/community-assessment/community-assessment-controller.dart';
import 'package:intl/intl.dart';

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
  final CommunityAssessmentController controller =
      Get.put(CommunityAssessmentController());
  List<CommunityAssessmentModel> _pendingAssessments = [];
  List<CommunityAssessmentModel> _submittedAssessments = [];
  bool _isLoading = true;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
      print('All assessments from DB:');
      allAssessments.forEach((a) {
        print(
            'ID: ${a['id']}, Community: ${a['community_name']}, Status: ${a['status']}, Raw data: ${a['raw_data']}');
      });

      final pending = allAssessments
          .where((a) => (a['status'] ?? 0) == 0)
          .map((e) {
            // FIXED: Properly extract community name with better fallback logic
            String? communityName = e['community_name'];

            // If community_name is null or empty, try to extract from raw_data
            if (communityName == null || communityName.isEmpty) {
              try {
                final rawData = e['raw_data'];
                if (rawData != null && rawData is String && rawData.isNotEmpty) {
                  final parsedData = jsonDecode(rawData);
                  if (parsedData is Map) {
                    communityName = parsedData['community'] ??
                        parsedData['communityName'] ??
                        parsedData['community_name'];
                  }
                }
              } catch (e) {
                debugPrint('Error parsing raw_data: $e');
              }
            }

            // Final fallback
            communityName = communityName ?? 'Community Assessment';

            return CommunityAssessmentModel.fromMap({
              'id': e['id'],
              'community_name': communityName, // FIXED: Use snake_case key
              'community_score': e['community_score'] ?? e['communityScore'] ?? 0,
              'status': e['status'] ?? 0,
              'region': e['region'],
              'total_population': e['total_population'],
              'total_children': e['total_children'],
              'primary_schools_count': e['primary_schools_count'],
              'has_protected_water': e['has_protected_water'],
              'hires_adult_labor': e['hires_adult_labor'],
              'child_labor_awareness': e['child_labor_awareness'],
              'has_women_leaders': e['has_women_leaders'],
              'q1': e['q1'],
              'q2': e['q2'],
              'q3': e['q3'],
              'q4': e['q4'],
              'q5': e['q5'],
              'q6': e['q6'],
              'q7a': e['q7a'],
              'q7b': e['q7b'],
              'q7c': e['q7c'],
              'q8': e['q8'],
              'q9': e['q9'],
              'q10': e['q10'],
              'date_created': e['date_created'],
            });
          })
          .toList();

      final submitted = allAssessments
          .where((a) => (a['status'] ?? 0) == 1)
          .map((e) {
            // FIXED: Same logic for submitted assessments
            String? communityName = e['community_name'];

            if (communityName == null || communityName.isEmpty) {
              try {
                final rawData = e['raw_data'];
                if (rawData != null && rawData is String && rawData.isNotEmpty) {
                  final parsedData = jsonDecode(rawData);
                  if (parsedData is Map) {
                    communityName = parsedData['community'] ??
                        parsedData['communityName'] ??
                        parsedData['community_name'];
                  }
                }
              } catch (e) {
                debugPrint('Error parsing raw_data: $e');
              }
            }

            communityName = communityName ?? 'Community Assessment';

            return CommunityAssessmentModel.fromMap({
              'id': e['id'],
              'community_name': communityName, // FIXED: Use snake_case key
              'community_score': e['community_score'] ?? e['communityScore'] ?? 0,
              'status': e['status'] ?? 1,
              'region': e['region'],
              'total_population': e['total_population'],
              'total_children': e['total_children'],
              'primary_schools_count': e['primary_schools_count'],
              'has_protected_water': e['has_protected_water'],
              'hires_adult_labor': e['hires_adult_labor'],
              'child_labor_awareness': e['child_labor_awareness'],
              'has_women_leaders': e['has_women_leaders'],
              'q1': e['q1'],
              'q2': e['q2'],
              'q3': e['q3'],
              'q4': e['q4'],
              'q5': e['q5'],
              'q6': e['q6'],
              'q7a': e['q7a'],
              'q7b': e['q7b'],
              'q7c': e['q7c'],
              'q8': e['q8'],
              'q9': e['q9'],
              'q10': e['q10'],
              'date_created': e['date_created'],
            });
          })
          .toList();

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
        _showSnackBar(
          'Error',
          'Failed to load assessments: $e',
          Colors.red,
        );
      }
      setState(() => _isLoading = false);
    }
  }

  // Helper method to safely show snackbars
  void _showSnackBar(String title, String message, Color backgroundColor) {
    if (!mounted) return;
    
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error showing snackbar: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Don't dispose the controller here if it's shared with other widgets
    // Get.delete<CommunityAssessmentController>();
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
            fontSize: 15,
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
      if (mounted) {
        _loadAssessments();
      }
    });
  }

  Future<void> _deleteAssessment(CommunityAssessmentModel assessment) async {
    if (!mounted) return;

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
              child: Text(
                'Delete Assessment',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
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
            _showSnackBar(
              'Success',
              'Assessment deleted successfully',
              Colors.green,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar(
            'Error',
            'Error deleting assessment: $e',
            Colors.red,
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
    // Store context locally before async operations
    final localContext = context;
    if (!mounted) return;

    // Show loading indicator
    _showSnackBar('Info', 'Submitting assessment...', Colors.blue);

    UserModel? user = await AuthService.getCurrentStaff();

    // Get society ID from assessment data
    int? societyId;
    try {
      // First try to get it from the assessment's raw data
      if (assessment.rawData != null) {
        final rawData = jsonDecode(assessment.rawData!);
        societyId = rawData['society_id'] ??
            rawData['society'] ??
            (rawData['societyId'] is int ? rawData['societyId'] : null);

        // If societyId is still null, try to find it in the raw_data string if it exists
        if (societyId == null && rawData['raw_data'] is String) {
          try {
            final nestedData = jsonDecode(rawData['raw_data']);
            societyId = nestedData['society_id'] ?? nestedData['society'];
          } catch (e) {
            debugPrint('Error parsing nested raw_data: $e');
          }
        }
      }

      // If we still don't have a society ID, try to get it from the selected society
      if (societyId == null) {
        final societyRepo = SocietyRepository();
        final societies = await societyRepo.getAllSocieties();
        if (societies.isNotEmpty) {
          // Try to find a society that matches the assessment's community name
          final matchingSociety = societies.firstWhere(
            (s) =>
                s.society?.toLowerCase() ==
                assessment.communityName?.toLowerCase(),
            orElse: () => Society(),
          );
          societyId = matchingSociety.id;
        }
      }

      // If we still don't have a society ID, show an error
      if (societyId == null) {
        if (mounted) {
          _showSnackBar(
            'Error',
            'Could not determine society. Please sync societies first.',
            Colors.red,
          );
        }
        return;
      }

      debugPrint('ℹ️ Using society ID: $societyId');
    } catch (e) {
      debugPrint('Error getting society ID: $e');
      if (mounted) {
        _showSnackBar('Error', 'Error: ${e.toString()}', Colors.red);
      }
      return;
    }

    if (user == null) {
      if (mounted) {
        _showSnackBar(
          'Error',
          'User not found. Please log in again.',
          Colors.red,
        );
      }
      return;
    }

    // Create a map with the required fields in snake_case
    final pciData = {
      'enumerator': user.id.toString(),
      'society': societyId,
      'access_to_protected_water': assessment.q1 == 'Yes' ? 1.0 : 0.0,
      'hire_adult_labourers': assessment.q2 == 'Yes' ? 1.0 : 0.0,
      'awareness_raising_session': assessment.q3 == 'Yes' ? 1.0 : 0.0,
      'women_leaders': assessment.q4 == 'Yes' ? 1.0 : 0.0,
      'pre_school': assessment.q5 == 'Yes' ? 1.0 : 0.0,
      'primary_school': (assessment.q7a ?? 0).toDouble(),
      'separate_toilets':
          (assessment.schoolsWithToilets ?? 'No') == 'Yes' ? 1.0 : 0.0,
      'provide_food': (assessment.schoolsWithFood ?? 'No') == 'Yes' ? 1.0 : 0.0,
      'scholarships': assessment.q9 == 'Yes' ? 1.0 : 0.0,
      'corporal_punishment':
          (assessment.schoolsNoCorporalPunishment ?? 'No') == 'Yes' ? 1.0 : 0.0,
      'total_index': _calculateScore(assessment).toDouble(),
    };

    debugPrint('Submitting data: $pciData');

    try {
      // Submit the data
      final api = GetService();
      final apiSuccess = await api.postPCIData(pciData);

      if (apiSuccess) {
        // Only update status if API call was successful
        await _dbHelper.updateAssessmentStatus(assessment.id!, 2);

        if (mounted) {
          setState(() {
            _pendingAssessments.removeWhere((a) => a.id == assessment.id);
            // Create a new instance with updated status
            final submittedAssessment = assessment.copyWith(status: 2);
            _submittedAssessments.add(submittedAssessment);
          });

          if (mounted) {
            _showSnackBar(
              'Success',
              'Assessment submitted and synced successfully',
              Colors.green,
            );
          }
        }
      } else if (mounted) {
        // If API call failed but didn't throw an exception
        _showSnackBar(
          'Error',
          'Failed to submit assessment. Please try again.',
          Colors.red,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _submitAssessment: $e');
      debugPrint('Stack trace: $stackTrace');

      // If API fails, save as pending (status 1)
      await _dbHelper.updateAssessmentStatus(assessment.id!, 1);

      if (mounted) {
        setState(() {
          // Update the assessment status in the UI
          final index =
              _pendingAssessments.indexWhere((a) => a.id == assessment.id);
          if (index != -1) {
            _pendingAssessments[index] =
                _pendingAssessments[index].copyWith(status: 1);
          }
        });

        if (mounted) {
          _showSnackBar(
            'Info',
            'Error: ${e.toString()}. Saved as draft.',
            Colors.orange,
          );
        }
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
                                      '$score/10',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: _getScoreColor(score * 10),
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
                                                (score / 10),
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

  // Calculate score out of 10
  int _calculateScore(CommunityAssessmentModel assessment) {
    int score = 0;

    // Each "Yes" answer or q7a == 1 adds 1 to the score
    if (assessment.q1 == 'Yes') score++;
    if (assessment.q2 == 'Yes') score++;
    if (assessment.q3 == 'Yes') score++;
    if (assessment.q4 == 'Yes') score++;
    if (assessment.q5 == 'Yes') score++;
    if (assessment.q6 == 'Yes') score++;
    if (assessment.q7a == 1) score++;
    if (assessment.q8 == 'Yes') score++;
    if (assessment.q9 == 'Yes') score++;
    if (assessment.q10 == 'Yes') score++;

    // Return the raw score out of 10
    return score;
  }

  // Helper method to check if assessment has details to display
  bool _hasAssessmentDetails(CommunityAssessmentModel assessment) {
    return assessment.q2?.isNotEmpty == true ||
        assessment.q3?.isNotEmpty == true;
  }

  // Get the community name
  String _getDisplayName(CommunityAssessmentModel assessment) {
    return assessment.communityName?.trim().isNotEmpty == true
        ? assessment.communityName!
        : 'Community Assessment';
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
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }
}