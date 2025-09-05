import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/pages/Startsurvey.dart';
import 'package:surveyflow/pages/cover.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: Text(
          'Child Labour Data Collection',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1976D2),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'SURVEYFLOW',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Child Labour Initiative',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home, color: Color(0xFF1976D2)),
                      title: Text(
                        'HOME',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Homepage()),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFF90CAF9)),
                    ListTile(
                      leading: const Icon(Icons.assignment,
                          color: Color(0xFF1976D2)),
                      title: Text(
                        'SURVEYS',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SurveyListPage()),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFF90CAF9)),
                    ListTile(
                      leading:
                          const Icon(Icons.analytics, color: Color(0xFF1976D2)),
                      title: Text(
                        'ANALYTICS',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Color(0xFF90CAF9)),
                    ListTile(
                      leading: const Icon(Icons.info, color: Color(0xFF1976D2)),
                      title: Text(
                        'ABOUT',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // Header Section with Image
            // Container(
            //   width: double.infinity,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(12),
            //     color: Colors.white,
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withOpacity(0.1),
            //         blurRadius: 6,
            //         offset: const Offset(0, 3),
            //       ),
            //     ],
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       // // Image placeholder - would be replaced with actual image
            // Container(
            //   height: 160,
            //   width: double.infinity,
            //   decoration: const BoxDecoration(
            //     borderRadius: BorderRadius.only(
            //       topLeft: Radius.circular(12),
            //       topRight: Radius.circular(12),
            //     ),
            //     color: Color(0xFFE3F2FD),
            //   ),
            //   child: const Icon(
            //     Icons.child_care,
            //     size: 60,
            //     color: Color(0xFF1976D2),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            // child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(
            //       'End Child Labour',
            //       style: GoogleFonts.poppins(
            //         fontSize: 18,
            //         fontWeight: FontWeight.w700,
            //         color: const Color(0xFF1976D2),
            //       ),
            //     ),
            //     const SizedBox(height: 8),
            //     Text(
            //       'Child labor deprives children of their childhood, potential, and dignity. It harms their physical and mental development and interferes with their schooling.',
            //       style: GoogleFonts.poppins(
            //         fontSize: 13,
            //         fontWeight: FontWeight.w400,
            //         color: const Color(0xFF666666),
            //       ),
            //     ),
            //         //   ],
            //         // ),
            //       ),
            //     ],
            //   ),
            // ),

            const SizedBox(height: 24),

            // Stats Overview
            Text(
              'Overview',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard1(
                    'Surveys Completed',
                    '24',
                    Icons.check_circle,
                    const [Color(0xFF1976D2), Color(0xFF0D47A1)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard2(
                    'Pending',
                    '8',
                    Icons.pending_actions,
                    [const Color(0xFFFF9800), const Color(0xFFF57C00)],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: 2,
              itemBuilder: (context, index) {
                final List<Map<String, dynamic>> cardData = [
                  {
                    'title': 'Start Survey',
                    'subtitle': 'Begin data collection',
                    'icon': Icons.assignment,
                    'colors': [
                      const Color(0xFF1976D2),
                      const Color(0xFF0D47A1)
                    ],
                    'page': const SurveyListPage(),
                  },
                  {
                    'title': 'View Data',
                    'subtitle': 'Check survey results',
                    'icon': Icons.bar_chart,
                    'colors': [
                      const Color(0xFF4CAF50),
                      const Color(0xFF2E7D32)
                    ],
                    'page': const Questionnaire(),
                  },
                ];

                return _buildActionCard(
                  context,
                  cardData[index]['title']!,
                  cardData[index]['subtitle']!,
                  cardData[index]['icon'] as IconData,
                  cardData[index]['colors'] as List<Color>,
                  cardData[index]['page'] as Widget,
                );
              },
            ),

            const SizedBox(height: 24),

            // Recent Activity
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActivityItem('New survey submitted', '2 hours ago',
                      Icons.assignment_turned_in),
                  _buildActivityItem(
                      'Data analysis completed', 'Yesterday', Icons.analytics),
                  _buildActivityItem(
                      'Field report uploaded', '2 days ago', Icons.description),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Call to Action
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.child_care, size: 36, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Make a Difference Today',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your participation helps protect children from labor exploitation',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SurveyListPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Start Survey Now',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fiber_manual_record,
              size: 8, color: Color(0xFF1976D2)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard1(
      String title, String value, IconData icon, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard2(
      String title, String value, IconData icon, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: colors[0],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors[0],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle,
      IconData icon, List<Color> colors, Widget destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 11.0, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF1976D2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(activity,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF333333),
                )),
          ),
          Text(time,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF666666),
              )),
        ],
      ),
    );
  }
}
