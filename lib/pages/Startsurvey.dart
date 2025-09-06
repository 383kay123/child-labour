import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart'; // make sure to import your AppTheme
import 'Consent.dart';
import 'community-assessment/assessment-form.dart';
import 'community-assessment/history/community-assessment-history.dart';

class SurveyListPage extends StatelessWidget {
  const SurveyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example survey data with navigation targets
    final List<Map<String, dynamic>> surveys = [
      {
        'title': 'REVIEW GHA - CLMRS Household Profiling -24 - 25',
        'description': 'Click here to proceed',
        'page': const Consent(),
        // 'historyPage': const ConsentHistory(),
      },
      {
        'title': 'COMMUNITY ASSESSMENT',
        'description': 'Click here to proceed',
        'page': const CommunityAssessmentForm(),
        'historyPage': const CommunityAssessmentHistory(),
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Surveys',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: surveys.length,
              itemBuilder: (context, index) {
                final survey = surveys[index];
                return Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      survey['title'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    subtitle: Text(
                      survey['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: AppTheme.primaryDark,
                    ),
                    onTap: () {
                      _showSurveyOptions(context, survey['page'], survey['historyPage']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSurveyOptions(BuildContext context, Widget page, Widget historyPage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                title: Text(
                  "Add New",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                },
              ),
              Divider(color: AppTheme.textSecondary.withOpacity(0.3)),
              ListTile(
                leading: const Icon(Icons.history, color: AppTheme.secondaryColor),
                title: Text(
                  "View History",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => historyPage),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
