import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class MonitoringAssessmentForm extends StatefulWidget {
  const MonitoringAssessmentForm({super.key});

  @override
  State<MonitoringAssessmentForm> createState() => _MonitoringAssessmentFormState();
}

class _MonitoringAssessmentFormState extends State<MonitoringAssessmentForm> {
  final Map<String, String> _answers = {};
  final RxInt _monitoringScore = 0.obs;
  
  final List<String> _monitoringLocations = [
    "Location A",
    "Location B",
    "Location C",
    "Location D"
  ];

  String? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Monitoring Assessment",
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: GoogleFonts.poppins().fontFamily,
            color: theme.colorScheme.onPrimary,
            fontSize: 18,
          ),
        ),
        backgroundColor: theme.primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 16.0),
            child: Obx(
              () => Text(
                'Score: ${_monitoringScore.value}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Location Dropdown
            _buildDropdownField(
              context: context,
              hint: "Select Monitoring Location",
              items: _monitoringLocations,
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                  _answers["location"] = value ?? "";
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Questions will be added here
            // Example:
            // _buildQuestionCard(
            //   context,
            //   "Sample question 1?",
            //   "q1",
            // ),
            
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                    onPressed: () {
                      // TODO: Implement save functionality
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text("Submit"),
                    onPressed: () {
                      // TODO: Implement submit functionality
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    String question,
    String key, {
    List<String>? options,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // Will be implemented based on the question type
            // Example: Yes/No buttons or custom input fields
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      value: _selectedLocation,
    );
  }
}
