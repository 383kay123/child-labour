// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../models/survey_response.dart';
// import '../providers/survey_provider.dart';
// import '../pages/survey_form_page.dart';
//
// class SurveyHomeScreen extends StatefulWidget {
//   const SurveyHomeScreen({Key? key}) : super(key: key);
//
//   @override
//   _SurveyHomeScreenState createState() => _SurveyHomeScreenState();
// }
//
// class _SurveyHomeScreenState extends State<SurveyHomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Load surveys when the screen is first displayed
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<SurveyProvider>(context, listen: false).loadSurveys();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'ChildSafe Surveys',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color(0xFF006A4E),
//         elevation: 0,
//       ),
//       body: Consumer<SurveyProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading && provider.surveys.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (provider.error != null) {
//             return Center(
//               child: Text(
//                 'Error loading surveys: ${provider.error}',
//                 style: GoogleFonts.poppins(color: Colors.red),
//               ),
//             );
//           }
//
//           if (provider.surveys.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.assignment_outlined,
//                     size: 64,
//                     color: Colors.grey[400],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No surveys yet',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Tap the + button to create a new survey',
//                     style: GoogleFonts.poppins(
//                       color: Colors.grey[500],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: provider.surveys.length,
//             itemBuilder: (context, index) {
//               final survey = provider.surveys[index];
//               return _buildSurveyCard(survey, context);
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           // Navigate to the survey form to create a new survey
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const SurveyFormPage(),
//             ),
//           );
//         },
//         backgroundColor: const Color(0xFF006A4E),
//         label: Text(
//           'New Survey',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         icon: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildSurveyCard(SurveyResponse survey, BuildContext context) {
//     final dateFormat = DateFormat('MMM d, y • hh:mm a');
//     final status = survey.status.replaceAll('_', ' ').toUpperCase();
//
//     Color statusColor;
//     switch (survey.status) {
//       case 'completed':
//         statusColor = Colors.green;
//         break;
//       case 'in_progress':
//         statusColor = Colors.orange;
//         break;
//       case 'draft':
//       default:
//         statusColor = Colors.grey;
//     }
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: () {
//           // Navigate to edit the survey
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SurveyFormPage(surveyResponse: survey),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Survey #${survey.id ?? 'New'}',
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       status,
//                       style: GoogleFonts.poppins(
//                         color: statusColor,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Created: ${dateFormat.format(survey.createdAt)}',
//                 style: GoogleFonts.poppins(
//                   color: Colors.grey[600],
//                   fontSize: 12,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Last Updated: ${dateFormat.format(survey.updatedAt)}',
//                 style: GoogleFonts.poppins(
//                   color: Colors.grey[600],
//                   fontSize: 12,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       // Show delete confirmation
//                       _showDeleteDialog(context, survey);
//                     },
//                     style: TextButton.styleFrom(
//                       foregroundColor: Colors.red,
//                     ),
//                     child: Text(
//                       'Delete',
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Continue editing
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SurveyFormPage(surveyResponse: survey),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF006A4E),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       'Continue',
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showDeleteDialog(
//       BuildContext context, SurveyResponse survey) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'Delete Survey',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'Are you sure you want to delete this survey? This action cannot be undone.',
//           style: GoogleFonts.poppins(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text(
//               'Cancel',
//               style: GoogleFonts.poppins(
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: Text(
//               'Delete',
//               style: GoogleFonts.poppins(
//                 color: Colors.red,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true && context.mounted) {
//       try {
//         await Provider.of<SurveyProvider>(context, listen: false)
//             .deleteSurvey(survey.id!);
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Survey deleted successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to delete survey: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }
// }
