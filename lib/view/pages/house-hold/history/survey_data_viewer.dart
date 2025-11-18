// // view/pages/house-hold/history/full_survey_detail_page.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:human_rights_monitor/controller/models/fullsurveymodel.dart';

// import 'package:intl/intl.dart';

// class FullSurveyDetailPage extends StatelessWidget {
//   final FullSurveyModel survey;

//   const FullSurveyDetailPage({Key? key, required this.survey}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: _getTabCount(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             survey.farmer?.fullName ?? 'Survey #${survey.surveyId}',
//             style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
//           ),
//           backgroundColor: const Color(0xFF4CAF50),
//           iconTheme: const IconThemeData(color: Colors.white),
//           bottom: TabBar(
//             isScrollable: _getTabCount() > 3,
//             tabs: _buildTabs(),
//             labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
//           ),
//         ),
//         body: TabBarView(
//           children: _buildTabViews(context),
//         ),
//       ),
//     );
//   }

//   int _getTabCount() {
//     int count = 1; // Cover always exists
//     if (survey.consent != null) count++;
//     if (survey.farmer != null) count++;
//     if (survey.combinedFarm != null) count++;
//     if (survey.childrenHousehold != null) count++;
//     if (survey.remediation != null) count++;
//     if (survey.sensitization != null) count++;
//     if (survey.endOfCollection != null) count++;
//     return count;
//   }

//   List<Tab> _buildTabs() {
//     final tabs = <Tab>[];
//     tabs.add(const Tab(text: 'Cover Page'));
//     if (survey.consent != null) tabs.add(const Tab(text: 'Consent'));
//     if (survey.farmer != null) tabs.add(const Tab(text: 'Farmer ID'));
//     if (survey.combinedFarm != null) tabs.add(const Tab(text: 'Farm'));
//     if (survey.childrenHousehold != null) tabs.add(const Tab(text: 'Children'));
//     if (survey.remediation != null) tabs.add(const Tab(text: 'Remediation'));
//     if (survey.sensitization != null) tabs.add(const Tab(text: 'Sensitization'));
//     if (survey.endOfCollection != null) tabs.add(const Tab(text: 'End'));
//     return tabs;
//   }

//   List<Widget> _buildTabViews(BuildContext context) {
//     final views = <Widget>[];
//     views.add(_buildSection('Cover Page Information', _coverFields()));
//     if (survey.consent != null) views.add(_buildSection('Consent Information', _consentFields()));
//     if (survey.farmer != null) views.add(_buildSection('Farmer Identification', _farmerFields()));
//     if (survey.combinedFarm != null) views.add(_buildSection('Farm Details', _combinedFields()));
//     if (survey.childrenHousehold != null) views.add(_buildSection('Children in Household', _childrenFields()));
//     if (survey.remediation != null) views.add(_buildSection('Remediation Support', _remediationFields()));
//     if (survey.sensitization != null) views.add(_buildSection('Sensitization', _sensitizationFields()));
//     if (survey.endOfCollection != null) views.add(_buildSection('End of Collection', _endFields()));
//     return views;
//   }

//   Widget _buildSection(String title, List<Widget> fields) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Card(
//             elevation: 4,
//             margin: const EdgeInsets.only(bottom: 20),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Created: ${_formatDate(survey.createdAt)}',
//                     style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(children: fields),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Widget> _coverFields() => _buildFields({
//         'Town': survey.cover.selectedTownCode,
//         'Farmer Code': survey.cover.selectedFarmerCode,
       
//       });

//   List<Widget> _consentFields() => _buildFields({
//         'Consent Given': survey.consent!.consentGiven ? 'Yes' : 'No',
//         'Declined': survey.consent!.declinedConsent ? 'Yes' : 'No',
//         'Location': survey.consent!.locationStatus,
//         'Time': survey.consent!.timeStatus,
//       });

//   List<Widget> _farmerFields() => _buildFields({
//         'Full Name': survey.farmer!.fullName,
//         'Ghana Card': survey.farmer!.ghanaCardNumber,
//         'Contact': survey.farmer!.contactNumber,
//         'Children (5-17)': survey.farmer!.childrenCount?.toString(),
//         'Community': survey.farmer!.community,
//       });

//   List<Widget> _combinedFields() => _buildFields({
//         'Farm Size': survey.combinedFarm!.farmSize,
//         'Cocoa Variety': survey.combinedFarm!.cocoaVariety,
//         'Workers': survey.combinedFarm!.numberOfWorkers,
//       });

//   List<Widget> _childrenFields() => _buildFields({
//         'Has Children': survey.childrenHousehold!.hasChildrenInHousehold ? 'Yes' : 'No',
//         'Total Children': survey.childrenHousehold!.numberOfChildren?.toString(),
//         'Aged 5-17': survey.childrenHousehold!.children5To17?.toString(),
//       });

//   List<Widget> _remediationFields() => _buildFields({
//         'School Fees': survey.remediation!.hasSchoolFees == true ? 'Yes' : 'No',
//         'School Kits': survey.remediation!.schoolKitsSupport == true ? 'Yes' : 'No',
//         'IGA Support': survey.remediation!.igaSupport == true ? 'Yes' : 'No',
//       });

//   List<Widget> _sensitizationFields() => _buildFields({
//         'Acknowledged': survey.sensitization!.isAcknowledged ? 'Yes' : 'No',
//       });

//   List<Widget> _endFields() => _buildFields({
//         'Completed': survey.endOfCollection!.isComplete ? 'Yes' : 'No',
//         'Notes': survey.endOfCollection!.collectorNotes,
//       });

//   List<Widget> _buildFields(Map<String, String?> data) {
//     final items = <Widget>[];
//     data.forEach((key, value) {
//       if (value == null || value.isEmpty) return;
//       items.addAll([
//         const SizedBox(height: 12),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               flex: 2,
//               child: Text(
//                 '$key:',
//                 style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey[800]),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               flex: 3,
//               child: Text(
//                 value,
//                 style: GoogleFonts.inter(color: Colors.grey[700]),
//                 textAlign: TextAlign.right,
//               ),
//             ),
//           ],
//         ),
//         const Divider(height: 24, thickness: 1),
//       ]);
//     });
//     if (items.isNotEmpty) items.removeLast();
//     if (items.isEmpty) {
//       items.add(Center(child: Text('No data', style: GoogleFonts.inter(color: Colors.grey))));
//     }
//     return items;
//   }

//   String _formatDate(DateTime date) {
//     return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
//   }
// }