import 'package:flutter/material.dart';
import 'base_section.dart';

class HealthSafetySection extends BaseSection {
  final bool hasHealthIssues;
  final String? healthIssuesDescription;
  final bool hasAccessToMedicalCare;
  final bool hasSafetyConcerns;
  final String? safetyConcernsDescription;
  final bool showHealthIssuesField;
  final bool showHealthIssuesDescriptionField;
  final bool showMedicalCareField;
  final bool showSafetyConcernsField;
  final bool showSafetyConcernsDescriptionField;
  final ValueChanged<bool> onHasHealthIssuesChanged;
  final ValueChanged<String> onHealthIssuesDescriptionChanged;
  final ValueChanged<bool> onHasAccessToMedicalCareChanged;
  final ValueChanged<bool> onHasSafetyConcernsChanged;
  final ValueChanged<String> onSafetyConcernsDescriptionChanged;

  const HealthSafetySection({
    Key? key,
    required this.hasHealthIssues,
    this.healthIssuesDescription,
    required this.hasAccessToMedicalCare,
    required this.hasSafetyConcerns,
    this.safetyConcernsDescription,
    required this.showHealthIssuesField,
    required this.showHealthIssuesDescriptionField,
    required this.showMedicalCareField,
    required this.showSafetyConcernsField,
    required this.showSafetyConcernsDescriptionField,
    required this.onHasHealthIssuesChanged,
    required this.onHealthIssuesDescriptionChanged,
    required this.onHasAccessToMedicalCareChanged,
    required this.onHasSafetyConcernsChanged,
    required this.onSafetyConcernsDescriptionChanged,
  }) : super(
          key: key,
          title: 'Health and Safety',
          child: const SizedBox.shrink(), // Placeholder, will be built in build method
        );
        
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHealthIssuesField) _buildHealthIssuesField(),
        if (showHealthIssuesDescriptionField && hasHealthIssues) ..._buildHealthIssuesDescriptionField(),
        if (showMedicalCareField && hasHealthIssues) _buildMedicalCareField(),
        if (showSafetyConcernsField) _buildSafetyConcernsField(),
        if (showSafetyConcernsDescriptionField && hasSafetyConcerns) ..._buildSafetyConcernsDescriptionField(),
      ],
    );
  }

  Widget _buildHealthIssuesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Does the child have any health issues?'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildHealthIssuesRadio(true, 'Yes'),
            const SizedBox(width: 16),
            _buildHealthIssuesRadio(false, 'No'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildHealthIssuesDescriptionField() {
    return [
      TextFormField(
        initialValue: healthIssuesDescription,
        decoration: const InputDecoration(
          labelText: 'Please describe the health issues',
          border: OutlineInputBorder(),
          hintText: 'e.g., chronic illness, disability, etc.',
        ),
        maxLines: 3,
        onChanged: onHealthIssuesDescriptionChanged,
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildMedicalCareField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Does the child have access to medical care?'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildMedicalCareRadio(true, 'Yes'),
            const SizedBox(width: 16),
            _buildMedicalCareRadio(false, 'No'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSafetyConcernsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Are there any safety concerns for this child?'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSafetyConcernsRadio(true, 'Yes'),
            const SizedBox(width: 16),
            _buildSafetyConcernsRadio(false, 'No'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildSafetyConcernsDescriptionField() {
    return [
      TextFormField(
        initialValue: safetyConcernsDescription,
        decoration: const InputDecoration(
          labelText: 'Please describe the safety concerns',
          border: OutlineInputBorder(),
          hintText: 'e.g., unsafe working conditions, abuse, etc.',
        ),
        maxLines: 3,
        onChanged: onSafetyConcernsDescriptionChanged,
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildHealthIssuesRadio(bool value, String label) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: hasHealthIssues,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              onHasHealthIssuesChanged(newValue);
            }
          },
        ),
        Text(label),
      ],
    );
  }

  Widget _buildMedicalCareRadio(bool value, String label) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: hasAccessToMedicalCare,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              onHasAccessToMedicalCareChanged(newValue);
            }
          },
        ),
        Text(label),
      ],
    );
  }

  Widget _buildSafetyConcernsRadio(bool value, String label) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: hasSafetyConcerns,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              onHasSafetyConcernsChanged(newValue);
            }
          },
        ),
        Text(label),
      ],
    );
  }
}
