import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'visit_information_page.dart';

class FarmerIdentificationPage extends StatelessWidget {
  const FarmerIdentificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              context: context,
              title: '1. Information on the visit',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VisitInformationPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '2. Workers in the farm',
              onTap: () {
                // Navigate to workers in farm page
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkersInFarmPage()));
              },
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '3. Adult of the respondent\'s household',
              onTap: () {
                // Navigate to adult household page
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const AdultHouseholdPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
