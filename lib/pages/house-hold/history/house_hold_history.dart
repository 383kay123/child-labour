

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../controller/db/db.dart';
import '../../../controller/models/community-assessment-model.dart';
import '../../../theme/app_theme.dart';

class HouseHoldHistory extends StatefulWidget {
  const HouseHoldHistory({super.key});

  @override
  _HouseHoldHistoryState createState() => _HouseHoldHistoryState();
}

class _HouseHoldHistoryState extends State<HouseHoldHistory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocalDBHelper _dbHelper = LocalDBHelper.instance;
  List<CommunityAssessmentModel> _pendingAssessments = [];
  List<CommunityAssessmentModel> _submittedAssessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _loadAssessments();
  }

  // Future<void> _loadAssessments() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final allAssessments = await _dbHelper.getResponses();
  //     setState(() {
  //       _pendingAssessments = allAssessments.where((a) => (a.status ?? 0) == 0).toList();
  //       _submittedAssessments = allAssessments.where((a) => (a.status ?? 0) == 1).toList();
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     debugPrint('Error loading assessments: $e');
  //     Get.snackbar(
  //       'Error',
  //       'Failed to load assessments',
  //       backgroundColor: AppTheme.errorColor,
  //       colorText: Colors.white,
  //     );
  //     setState(() => _isLoading = false);
  //   }
  // }

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
          'House Hold Survey History',
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

  Widget _buildAssessmentList(List<CommunityAssessmentModel> assessments, bool isSubmitted, BuildContext context) {
    if (assessments.isEmpty) {
      return Center(
        child: Text(
          isSubmitted ? 'No submitted assessments' : 'No pending assessments',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: (){
        setState(() {

        });
        return Future.delayed(const Duration(seconds: 1));
      },
      // onRefresh: _loadAssessments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assessments.length,
        itemBuilder: (context, index) {
          return _buildAssessmentCard(assessments[index], context);
        },
      ),
    );
  }

  Widget _buildAssessmentCard(CommunityAssessmentModel assessment, BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(assessment.id! * 1000);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          assessment.communityName ?? 'Unnamed Assessment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Score: ${assessment.communityScore ?? 'N/A'} • ${DateFormat('MMM d, y - h:mm a').format(date)}',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navigate to assessment detail view
        },
      ),
    );
  }
}
