import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'identification_of_owner.dart';
import 'visit_information_page.dart';

class FarmerIdentificationPage extends StatefulWidget {
  const FarmerIdentificationPage({super.key});

  @override
  State<FarmerIdentificationPage> createState() =>
      _FarmerIdentificationPageState();
}

class _FarmerIdentificationPageState extends State<FarmerIdentificationPage> {
  // Track completion status for each section
  bool isVisitInfoComplete = false;
  bool isOwnerIdentificationComplete = false;
  bool isWorkersComplete =
      false; // Will be used when implementing Workers section
  bool isAdultHouseholdComplete =
      false; // Will be used when implementing Adult Household section

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
              isComplete: isVisitInfoComplete,
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VisitInformationPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    isVisitInfoComplete = result;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '2. Identification of the Owner',
              isComplete: isOwnerIdentificationComplete,
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IdentificationOfOwnerPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    isOwnerIdentificationComplete = result;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '3. Workers in the farm',
              isComplete: isWorkersComplete,
              onTap: () {
                // Navigate to workers in farm page
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkersInFarmPage()));
              },
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '3. Adult of the respondent\'s household',
              isComplete: isAdultHouseholdComplete,
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

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required bool isComplete,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: isComplete ? Colors.green : Colors.grey.shade200,
          width: isComplete ? 2 : 1,
        ),
      ),
      elevation: isComplete ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (isComplete)
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child:
                      Icon(Icons.check_circle, color: Colors.green, size: 24),
                ),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: isComplete ? FontWeight.w700 : FontWeight.w600,
                    color: isComplete
                        ? Colors.green[800]
                        : Theme.of(context).primaryColor,
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
