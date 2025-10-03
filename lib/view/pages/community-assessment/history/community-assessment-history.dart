import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'edit_community_assessment.dart';
import '../../../../controller/db/db.dart';
import '../../../../controller/models/community-assessment-model.dart';
import '../../../theme/app_theme.dart';

class CommunityAssessmentHistory extends StatefulWidget {
  const CommunityAssessmentHistory({super.key});

  @override
  _CommunityAssessmentHistoryState createState() =>
      _CommunityAssessmentHistoryState();
}

class _CommunityAssessmentHistoryState extends State<CommunityAssessmentHistory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocalDBHelper _dbHelper = LocalDBHelper.instance;
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
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> allAssessments =
          await _dbHelper.getCommunityAssessmentByStatus();
      debugPrint('Assessments loaded: ${allAssessments.length}');

      // Convert each map to CommunityAssessmentModel
      final communityAssessments = allAssessments
          .map((map) => CommunityAssessmentModel.fromMap(map)
          .copyWith(
      //   q7a: int.parse(map['q7a'] ?? '0'),
      // )
      ))
          .toList();

      setState(() {
        _pendingAssessments =
            communityAssessments.where((a) => a.status == 0).toList();
        _submittedAssessments =
            communityAssessments.where((a) => a.status == 1).toList();
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      debugPrint('Error loading assessments: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading assessments: $e')),
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
      appBar: AppBar(
        title: Text(
          'Community Assessment History',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Submitted'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAssessmentList(_pendingAssessments, false, context),
                _buildAssessmentList(_submittedAssessments, true, context),
              ],
            ),
    );
  }

  Widget _buildAssessmentList(List<CommunityAssessmentModel> assessments,
      bool isSubmitted, BuildContext context) {
    if (assessments.isEmpty) {
      return Center(
        child: Text(
          isSubmitted ? 'No submitted assessments' : 'No pending assessments',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAssessments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assessments.length,
        itemBuilder: (context, index) {
          return _buildAssessmentCard(assessments[index], context);
        },
      ),
    );
  }

  Future<void> _deleteAssessment(CommunityAssessmentModel assessment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assessment'),
        content: Text(
            'Are you sure you want to delete the assessment for ${assessment.communityName ?? 'this community'}\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteCommunityAssessment(assessment.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assessment deleted successfully')),
          );
          _loadAssessments(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting assessment: $e')),
          );
        }
      }
    }
  }

  Widget _buildAssessmentCard(
      CommunityAssessmentModel assessment, BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          assessment.communityName ?? 'Unnamed Assessment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Score: ${assessment.communityScore ?? 'N/A'}\n'
          'Date: ${DateFormat('MMM d, y').format(DateTime.now())}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20.0),
              onPressed: () => _navigateToEdit(assessment),
              tooltip: 'Edit Assessment',
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, size: 20.0, color: Colors.red),
              onPressed: () => _deleteAssessment(assessment),
              tooltip: 'Delete Assessment',
            ),
            // const Icon(Icons.arrow_forward_ios, size: 16.0),
          ],
        ),
        onTap: () {
          // Handle assessment tap (view details)
        },
      ),
    );
  }

  void _navigateToEdit(CommunityAssessmentModel assessment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommunityAssessmentEdit(
          assessment: assessment,
        ),
      ),
    );
  }
}
