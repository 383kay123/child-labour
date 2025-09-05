// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:surveyflow/pages/remediation.dart';
// import 'package:surveyflow/pages/sensitization.dart';
//
// import '../fields/radiobuttons.dart';
// import 'Consent.dart';
// import 'cover.dart';
// import 'endcollection.dart';
// import 'farmerident.dart';
//
// class FarmerIdentification extends StatelessWidget {
//   const FarmerIdentification({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'FARM IDENTIFICATION',
//           style: GoogleFonts.poppins(
//               fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF006A4E),
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu, color: Colors.white),
//             onPressed: () {
//               Scaffold.of(context).openDrawer();
//             },
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.sync,
//                 color: Colors.white), // Change the icon here
//             onPressed: () {
//               // Add functionality here
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: Column(
//           children: [
//             SizedBox(
//               height: 140, // Adjust this height as needed
//               child: DrawerHeader(
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF00754B),
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerLeft, // Align text to the left
//                   child: Text(
//                     'REVIEW GHA - CLMRS Household profiling - 24-25',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14, // Reduce font size if needed
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             ListTile(
//               title: Text(
//                 'COVER',
//                 style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => Questionnaire()),
//                 );
//               },
//             ),
//             ListTile(
//               title: Text(
//                 'CONSENT AND LOCATION',
//                 style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => Consent(
//                             survey: {},
//                           )),
//                 );
//               },
//             ),
//             ListTile(
//               title: Text(
//                 'FARMER IDENTIFICATION',
//                 style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => Farmerident()),
//                 );
//               },
//             ),
//             ListTile(
//               title: Text(
//                 'REMEDIATION',
//                 style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => Remediation()),
//                 );
//               },
//             ),
//             ListTile(
//               title: Text(
//                 'SENSITIZATION',
//                 style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => Sensitization()),
//                 );
//               },
//             ),
//             ListTile(
//               title: Text(
//                 'END OF COLLECTION',
//                 style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => Endcollection()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.grey[100],
//       body: Stack(children: [
//         Padding(
//             padding: const EdgeInsets.only(
//                 bottom: 70), // Add padding to make room for bottom buttons
//             child: SingleChildScrollView(
//                 child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Center(
//                             child: Text(
//                               'Fill out the survey',
//                               style: GoogleFonts.poppins(
//                                   fontWeight: FontWeight.w500, fontSize: 14),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           RadioButtonField(
//                             question: 'Is the name of the respondent correct?',
//                             options: [
//                               'Yes',
//                               'No',
//                             ],
//                             onChanged: (value) {
//                               // Handle the selected value here
//                               // You can update your state or form data
//                             },
//                           ),
//                         ]))))
//       ]),
//     );
//   }
// }
