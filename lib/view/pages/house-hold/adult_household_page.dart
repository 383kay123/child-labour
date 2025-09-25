import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'adults_information_page.dart';

class AdultHouseholdPage extends StatefulWidget {
  const AdultHouseholdPage({super.key});

  @override
  State<AdultHouseholdPage> createState() => _AdultHouseholdPageState();
}

class _AdultHouseholdPageState extends State<AdultHouseholdPage> {
  bool isAdultsComplete = false;
  bool isChildrenComplete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              context: context,
              title: 'Information on adults living in the household',
              isComplete: isAdultsComplete,
              onTap: () async {
                final result = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdultsInformationPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    isAdultsComplete = true;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '2. Children in the Household',
              isComplete: isChildrenComplete,
              onTap: () {
                // TODO: Navigate to Children form
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
