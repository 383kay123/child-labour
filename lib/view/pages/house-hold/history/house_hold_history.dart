// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:human_rights_monitor/view/pages/house-hold/history/survey_data_viewer.dart';
// import 'package:intl/intl.dart';

// import '../../../../controller/db/db.dart';
// import '../../../../controller/models/cover_page_model.dart';
// import '../../../theme/app_theme.dart';

// class HouseHoldHistory extends StatefulWidget {
//   const HouseHoldHistory({super.key});

//   @override
//   _HouseHoldHistoryState createState() => _HouseHoldHistoryState();
// }

// class _HouseHoldHistoryState extends State<HouseHoldHistory>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final LocalDBHelper _dbHelper = LocalDBHelper.instance;
//   List<CoverPageModel> _pendingSurveys = [];
//   List<CoverPageModel> _submittedSurveys = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadSurveys();
//   }

//   Future<void> _loadSurveys() async {
//     setState(() => _isLoading = true);
//     try {
//       final allSurveys = await _dbHelper.();


//       setState(() {
//         _pendingSurveys = allSurveys
//             .where((s) => (s['status'] as int?) == 0)
//             .map((e) => CoverPageModel.fromMap(e))
//             .toList();
//         _submittedSurveys = allSurveys
//             .where((s) => (s['status'] as int?) == 1)
//             .map((e) => CoverPageModel.fromMap(e))
//             .toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       debugPrint('Error loading surveys: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   // Future<void> _loadAssessments() async {
//   //   setState(() => _isLoading = true);
//   //   try {
//   //     final allAssessments = await _dbHelper.getResponses();
//   //     setState(() {
//   //       _pendingAssessments = allAssessments.where((a) => (a.status ?? 0) == 0).toList();
//   //       _submittedAssessments = allAssessments.where((a) => (a.status ?? 0) == 1).toList();
//   //       _isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     debugPrint('Error loading assessments: $e');
//   //     Get.snackbar(
//   //       'Error',
//   //       'Failed to load assessments',
//   //       backgroundColor: AppTheme.errorColor,
//   //       colorText: Colors.white,
//   //     );
//   //     setState(() => _isLoading = false);
//   //   }
//   // }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'House Hold Survey History',
//           style: GoogleFonts.poppins(color: Colors.white),
//         ),
//         backgroundColor: AppTheme.primaryColor,
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           tabs: const [
//             Tab(text: 'Pending'),
//             Tab(text: 'Submitted'),
//           ],
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildSurveyList(_pendingSurveys, false, context),
//                 _buildSurveyList(_submittedSurveys, true, context),
//               ],
//             ),
//     );
//   }

//   Widget _buildSurveyList(
//       List<CoverPageModel> surveys, bool isSubmitted, BuildContext context) {
//     if (surveys.isEmpty) {
//       return Center(
//         child: Text(
//           isSubmitted ? 'No submitted surveys' : 'No pending surveys',
//           style: GoogleFonts.poppins(color: AppTheme.textSecondary),
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _loadSurveys,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: surveys.length,
//         itemBuilder: (context, index) {
//           return _buildSurveyCard(surveys[index], context);
//         },
//       ),
//     );
//   }

//   Widget _buildSurveyCard(CoverPageModel survey, BuildContext context) {
//     final date = survey.createdAt != null
//         ? DateTime.parse(survey.createdAt!)
//         : DateTime.now();

//     return Card(
//         margin: const EdgeInsets.only(bottom: 16),
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: ListTile(
//           title: Text(
//             survey.selectedTownName ?? 'Unnamed Survey',
//             style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//           ),
//           subtitle: Text(
//             '${survey.selectedFarmerName ?? 'No farmer selected'} • ${DateFormat('MMM d, y - h:mm a').format(date)}',
//             style: GoogleFonts.poppins(fontSize: 12),
//           ),
//           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => SurveyDataViewer(
//                   surveyData: survey.toMap(),
//                   surveyTitle: 'Household Survey Details',
//                 ),
//               ),
//             );
//           },
//         ));
//   }
// }
