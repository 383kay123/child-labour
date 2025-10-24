import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/view/pages/house-hold/pages/farm%20identification/workers_in_farm_page.dart';

import '../farm identification/adults_information_page.dart';
import '../farm identification/identification_of_owner.dart';
import '../farm identification/visit_information_page.dart';

class FarmerIdentificationPage extends StatefulWidget {
  final VoidCallback? onPrevious;

  const FarmerIdentificationPage({super.key, this.onPrevious});

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
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: widget.onPrevious ?? () => Navigator.of(context).pop(),
      //   ),
      //   title: const Text('Farmer Identification'),
      // ),
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
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkersInFarmPage(),
                  ),
                );

                // Navigate to workers in farm page
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkersInFarmPage()));
              },
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '4. Adult of the respondent\'s household',
              isComplete: isAdultHouseholdComplete,
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdultsInformationPage(),
                  ),
                );
                // Navigate to adult household page
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const AdultHouseholdPage()));
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  bool _isSectionComplete(Map<String, dynamic> data, String section) {
    // Add your validation logic for each section here
    // For now, just check if the data map is not empty
    return data.isNotEmpty;
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
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComplete ? Colors.green : Colors.grey.shade200,
                ),
                child: isComplete
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: isComplete ? FontWeight.w700 : FontWeight.w500,
                    color: isComplete
                        ? Colors.green[800]
                        : Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isComplete ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
