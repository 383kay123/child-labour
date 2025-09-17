import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/Monitoring/monitoring_assessment_form.dart';
import '../pages/community-assessment/assessment-form.dart';
import '../pages/community-assessment/history/community-assessment-history.dart';

import '../pages/house-hold/history/house_hold_history.dart';
import '../pages/house-hold/house_hold_survey.dart';

class SurveyListPage extends StatelessWidget {
  const SurveyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Child-friendly survey data with emojis and better descriptions
    final List<Map<String, dynamic>> surveys = [
      {
        'title': 'House Hold Survey',
        'subtitle': 'REVIEW GHA - CLMRS Household Profiling - 24/25',
        'description': 'Help us gather information about household',
        'emoji': '🏠',
        'color': Theme.of(context).primaryColor,
        'lightColor': Theme.of(context).primaryColor.withOpacity(0.2),
        'page': const HouseHoldSurveyScreen(),
        'historyPage': const HouseHoldHistory(),
        'icon': Icons.home_rounded,
      },
      {
        'title': 'Community Assessment',
        'subtitle': 'Community Assessment Survey',
        'description': 'Help us gather information about community',
        'emoji': '🌍',
        'color': const Color(0xFF2196F3),
        'lightColor': const Color(0xFFE3F2FD),
        'page': const CommunityAssessmentForm(),
        'historyPage': const CommunityAssessmentHistory(),
        'icon': Icons.people_rounded,
      },

      {
        'title': 'Monitoring',
        'subtitle': 'Community monitoring',
        'description': 'Help us monitor community',
        'emoji': '📊',
        'color': Theme.of(context).primaryColor,
        'lightColor': Theme.of(context).primaryColor.withOpacity(0.2),
        'page': MonitoringAssessmentForm(),
        'historyPage': const CommunityAssessmentHistory(),
        'icon': Icons.people_rounded,
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📋 ', style: TextStyle(fontSize: 20)),
            Text(
              'Available Surveys',
              style: GoogleFonts.comicNeue(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Hero section with encouraging message
          // Padding(
          //   padding: const EdgeInsets.all(20.0),
          //   child: Container(
          //     padding: const EdgeInsets.all(40),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(20),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.1),
          //           blurRadius: 15,
          //           offset: const Offset(0, 8),
          //         ),
          //       ],
          //     ),
          //     child: Column(
          //       children: [
          //         Text('🛡️', style: TextStyle(fontSize: 32)),
          //         const SizedBox(height: 12),
          //         Text(
          //           'Choose Your Mission',
          //           style: GoogleFonts.comicNeue(
          //             fontSize: 18,
          //             fontWeight: FontWeight.w800,
          //             color: const Color(0xFF2E7D32),
          //           ),
          //           textAlign: TextAlign.center,
          //         ),
          //         const SizedBox(height: 8),
          //         Text(
          //           'Help us create safer spaces for children everywhere',
          //           style: GoogleFonts.nunito(
          //             fontSize: 13,
          //             color: Colors.grey[600],
          //           ),
          //           textAlign: TextAlign.center,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Surveys list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                itemCount: surveys.length,
                itemBuilder: (context, index) {
                  final survey = surveys[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildSurveyCard(context, survey, index),
                  );
                },
              ),
            ),
          ),

          // Bottom encouragement
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFFF3E0)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Text('⭐', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Thank you for your help in this exercise',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyCard(BuildContext context, Map<String, dynamic> survey, int index) {
    return GestureDetector(
      onTap: () => _showSurveyOptions(context, survey),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: survey['color'].withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: survey['color'].withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Emoji and icon container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: survey['lightColor'],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(survey['emoji'], style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Icon(
                          survey['icon'],
                          color: survey['color'],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey['title'],
                          style: GoogleFonts.comicNeue(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: survey['color'],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          survey['subtitle'],
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          survey['description'],
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: survey['lightColor'],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: survey['color'].withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: survey['color'],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to Start Survey',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: survey['color'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSurveyOptions(BuildContext context, Map<String, dynamic> survey) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: survey['lightColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(survey['emoji'], style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        survey['title'],
                        style: GoogleFonts.comicNeue(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: survey['color'],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Options
                _buildOptionItem(
                  context,
                  '🆕 Start New Survey',
                  'Begin collecting important information',
                  Icons.add_circle_rounded,
                  const Color(0xFF4CAF50),
                  const Color(0xFFE8F5E8),
                      () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => survey['page']),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildOptionItem(
                  context,
                  '📚 View Past Surveys',
                  'See your previous contributions and impact',
                  Icons.history_rounded,
                  const Color(0xFF2196F3),
                  const Color(0xFFE3F2FD),
                      () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => survey['historyPage']),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      Color lightColor,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.comicNeue(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}