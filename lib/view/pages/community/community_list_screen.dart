import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../farmers/farmer_list_screen.dart';

class CommunityListScreen extends StatelessWidget {
  const CommunityListScreen({Key? key}) : super(key: key);

  // Mock data - replace with your actual data source
  final List<Map<String, dynamic>> communities = const [
    {
      'id': '1',
      'name': 'Dadieso',
      'totalFarmers': 5,
      'atRiskCount': 3,
      'totalChildren': 12,
    },
    {
      'id': '2',
      'name': 'Dunkwa',
      'totalFarmers': 3,
      'atRiskCount': 0,
      'totalChildren': 8,
    },
    {
      'id': '3',
      'name': 'Elluokrom',
      'totalFarmers': 7,
      'atRiskCount': 2,
      'totalChildren': 15,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Communities',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: communities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final community = communities[index];
          final hasRisk = community['atRiskCount'] > 0;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FarmerListScreen(
                      communityId: community['id'],
                      communityName: community['name'],
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          community['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                hasRisk ? Colors.orange[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hasRisk ? 'At Risk' : 'All Safe',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: hasRisk
                                  ? Colors.orange[800]
                                  : Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatChip(
                          '${community['totalFarmers']} farmers',
                          Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          '${community['totalChildren']} children',
                          Colors.blue,
                        ),
                        const Spacer(),
                        if (hasRisk)
                          _buildStatChip(
                            '${community['atRiskCount']} at risk',
                            Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
