import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/pages/cover.dart';

class SurveyListPage extends StatelessWidget {
  const SurveyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example survey data
    final List<Map<String, String>> surveys = [
      {
        'title': 'REVIEW GHA - CLMRS Household Profiling -24 - 25',
        'description': 'Click here to proceed',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Surveys',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF006A4E),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Information banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: const Color(0xFF00754B).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFF00754B), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select a survey to begin data collection',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF00754B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: surveys.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00754B).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment,
                            color: Color(0xFF00754B), size: 20),
                      ),
                      title: Text(surveys[index]['title']!,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: const Color(0xFF00754B))),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(surveys[index]['description']!,
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey[600])),
                      ),
                      trailing: const Icon(Icons.arrow_forward,
                          color: Color(0xFF00754B)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Questionnaire()), // Pass the survey data to Consent
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
