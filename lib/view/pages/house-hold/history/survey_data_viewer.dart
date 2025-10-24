import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SurveyDataViewer extends StatelessWidget {
  final Map<String, dynamic> surveyData;
  final String surveyTitle;

  const SurveyDataViewer({
    Key? key,
    required this.surveyData,
    required this.surveyTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Survey Details',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Survey Title
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surveyTitle,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (surveyData['createdAt'] != null)
                      Text(
                        'Created: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.parse(surveyData['createdAt']))}',
                        style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Survey Data
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDataItems(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDataItems() {
    final List<Widget> items = [];
    
    // Skip metadata fields we've already displayed
    final skipFields = {'createdAt', 'updatedAt', 'syncStatus', 'status'};
    
    surveyData.forEach((key, value) {
      if (skipFields.contains(key)) return;
      
      String displayKey = key
          .replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ')
          .toLowerCase();
      displayKey = '${displayKey[0].toUpperCase()}${displayKey.substring(1)}';
      
      if (value != null && value.toString().isNotEmpty) {
        items.addAll([
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '$displayKey:',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  value.toString(),
                  style: GoogleFonts.inter(
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
        ]);
      }
    });

    // Remove the last divider
    if (items.isNotEmpty) {
      items.removeLast();
    }

    return items;
  }
}

// Example of how to use it:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => SurveyDataViewer(
//       surveyData: yourSurveyDataMap,
//       surveyTitle: 'Household Survey Details',
//     ),
//   ),
// );
