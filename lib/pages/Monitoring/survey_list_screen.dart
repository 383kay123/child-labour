import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SurveyListScreen extends StatelessWidget {
  const SurveyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Sample survey data - replace with your actual data
    final List<Map<String, dynamic>> surveys = [
      {
        'title': 'Farm Monitoring Survey',
        'description': 'Assess farm conditions and child labor risks',
        'icon': Icons.agriculture,
        'count': 24,
        'color': Colors.blue,
      },
      {
        'title': 'Community Assessment',
        'description': 'Evaluate community-level child labor risks',
        'icon': Icons.people,
        'count': 18,
        'color': Colors.green,
      },
      {
        'title': 'School Attendance',
        'description': 'Monitor school enrollment and attendance',
        'icon': Icons.school,
        'count': 42,
        'color': Colors.orange,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Surveys',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: surveys.length,
        itemBuilder: (context, index) {
          final survey = surveys[index];
          return _buildSurveyCard(context, survey);
        },
      ),
    );
  }

  Widget _buildSurveyCard(BuildContext context, Map<String, dynamic> survey) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Handle survey tap
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Starting ${survey['title']}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: survey['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  survey['icon'] as IconData,
                  size: 32,
                  color: survey['color'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      survey['description'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: survey['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${survey['count']}',
                  style: GoogleFonts.poppins(
                    color: survey['color'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
