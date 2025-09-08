// import 'dart:typed_data' show Uint8List;
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// class FarmerReportScreen extends StatelessWidget {
//   final Map<String, dynamic> farmerData;
//
//   const FarmerReportScreen({
//     Key? key,
//     required this.farmerData,
//   }) : super(key: key);
//
//   Future<Uint8List> _generatePdf(PdfPageFormat format) async {
//     final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
//     final font = await PdfGoogleFonts.poppinsRegular();
//     final fontBold = await PdfGoogleFonts.poppinsBold();
//     final pdfData = Uint8List(0); // Initialize with empty bytes
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: format,
//         build: (pw.Context context) {
//           return pw.Padding(
//             padding: const pw.EdgeInsets.all(24.0),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Header(
//                   level: 0,
//                   child: pw.Text(
//                     'Farmer Report',
//                     style: pw.TextStyle(
//                       fontSize: 24,
//                       fontWeight: pw.FontWeight.bold,
//                       font: fontBold,
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   'Farmer Information',
//                   style: pw.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pw.FontWeight.bold,
//                     font: fontBold,
//                   ),
//                 ),
//                 pw.Divider(),
//                 pw.SizedBox(height: 10),
//                 _buildInfoRow('Name', farmerData['name'], font, fontBold),
//                 _buildInfoRow('Location', farmerData['location'], font, fontBold),
//                 _buildInfoRow('Total Children', farmerData['totalChildren'].toString(), font, fontBold),
//                 _buildInfoRow('Children at Risk', farmerData['childrenAtRisk'].toString(), font, fontBold),
//                 pw.SizedBox(height: 20),
//                 pw.Text(
//                   'Risk Assessment',
//                   style: pw.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pw.FontWeight.bold,
//                     font: fontBold,
//                   ),
//                 ),
//                 pw.Divider(),
//                 pw.SizedBox(height: 10),
//                 _buildRiskAssessment(font, fontBold),
//                 pw.SizedBox(height: 30),
//                 pw.Text(
//                   'Generated on: ${DateTime.now().toString().substring(0, 10)}',
//                   style: pw.TextStyle(
//                     fontSize: 10,
//                     color: const PdfColor.fromInt(0xFF666666),
//                     font: font,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//
//     final result = await pdf.save();
//     return Uint8List.fromList(result);
//   }
//
//   pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font fontBold) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 8.0),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.SizedBox(
//             width: 120,
//             child: pw.Text(
//               '$label:',
//               style: pw.TextStyle(
//                 fontWeight: pw.FontWeight.bold,
//                 font: fontBold,
//               ),
//             ),
//           ),
//           pw.Expanded(
//             child: pw.Text(
//               value,
//               style: pw.TextStyle(font: font),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   pw.Widget _buildRiskAssessment(pw.Font font, pw.Font fontBold) {
//     final isAtRisk = farmerData['childrenAtRisk'] > 0;
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Text(
//           isAtRisk ? 'Risk Status: At Risk' : 'Risk Status: No Risk',
//           style: pw.TextStyle(
//             fontWeight: pw.FontWeight.bold,
//             color: isAtRisk ? PdfColors.orange : PdfColors.green,
//             font: fontBold,
//           ),
//         ),
//         pw.SizedBox(height: 10),
//         pw.Text(
//           isAtRisk
//               ? 'This farmer has ${farmerData['childrenAtRisk']} children identified as being at risk of child labor.'
//               : 'No children at risk identified for this farmer.',
//           style: pw.TextStyle(font: font),
//         ),
//         if (isAtRisk) ...[
//           pw.SizedBox(height: 10),
//           pw.Text(
//             'Recommended Actions:',
//             style: pw.TextStyle(
//               fontWeight: pw.FontWeight.bold,
//               font: fontBold,
//             ),
//           ),
//           pw.Bullet(
//             text: 'Conduct follow-up visit',
//             style: pw.TextStyle(font: font),
//           ),
//           pw.Bullet(
//             text: 'Provide family support resources',
//             style: pw.TextStyle(font: font),
//           ),
//           pw.Bullet(
//             text: 'Monitor children\'s school attendance',
//             style: pw.TextStyle(font: font),
//           ),
//         ],
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Generate Report',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         backgroundColor: Theme.of(context).primaryColor,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: PdfPreview(
//         build: (format) => _generatePdf(format),
//         canChangeOrientation: false,
//         canChangePageFormat: false,
//         canDebug: false,
//         pdfFileName: 'farmer_report_${farmerData['id']}.pdf',
//       ),
//     );
//   }
// }
