import 'package:flutter/material.dart';
import 'base_section.dart';

class FamilyDecisionSection extends StatelessWidget {
  final String? educationDecisionMaker;
  final String? workDecisionMaker;
  final String? healthDecisionMaker;
  final String? otherEducationDecisionMaker;
  final String? otherWorkDecisionMaker;
  final String? otherHealthDecisionMaker;
  final bool showEducationDecisionField;
  final bool showWorkDecisionField;
  final bool showHealthDecisionField;
  final bool showOtherEducationField;
  final bool showOtherWorkField;
  final bool showOtherHealthField;
  final ValueChanged<String> onEducationDecisionChanged;
  final ValueChanged<String> onWorkDecisionChanged;
  final ValueChanged<String> onHealthDecisionChanged;
  final ValueChanged<String> onOtherEducationChanged;
  final ValueChanged<String> onOtherWorkChanged;
  final ValueChanged<String> onOtherHealthChanged;

  const FamilyDecisionSection({
    Key? key,
    this.educationDecisionMaker,
    this.workDecisionMaker,
    this.healthDecisionMaker,
    this.otherEducationDecisionMaker,
    this.otherWorkDecisionMaker,
    this.otherHealthDecisionMaker,
    required this.showEducationDecisionField,
    required this.showWorkDecisionField,
    required this.showHealthDecisionField,
    required this.showOtherEducationField,
    required this.showOtherWorkField,
    required this.showOtherHealthField,
    required this.onEducationDecisionChanged,
    required this.onWorkDecisionChanged,
    required this.onHealthDecisionChanged,
    required this.onOtherEducationChanged,
    required this.onOtherWorkChanged,
    required this.onOtherHealthChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showEducationDecisionField && !showWorkDecisionField && !showHealthDecisionField) {
      return const SizedBox.shrink();
    }

    return BaseSection(
      title: 'Family Decision Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showEducationDecisionField) ..._buildEducationDecisionFields(),
          if (showWorkDecisionField) ..._buildWorkDecisionFields(),
          if (showHealthDecisionField) ..._buildHealthDecisionFields(),
        ],
      ),
    );
  }

  List<Widget> _buildEducationDecisionFields() {
    return [
      const Text('Who makes decisions about the child\'s education?'),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: educationDecisionMaker,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Select decision maker',
        ),
        items: [
          'Mother',
          'Father',
          'Both Parents',
          'Grandparent(s)',
          'Other relative',
          'Other (specify)'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) => onEducationDecisionChanged(value ?? ''),
      ),
      if (showOtherEducationField) ..._buildOtherField(
        controller: TextEditingController(text: otherEducationDecisionMaker),
        onChanged: onOtherEducationChanged,
        label: 'Please specify who makes education decisions',
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildWorkDecisionFields() {
    return [
      const Text('Who makes decisions about the child\'s work?'),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: workDecisionMaker,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Select decision maker',
        ),
        items: [
          'Mother',
          'Father',
          'Both Parents',
          'Grandparent(s)',
          'Other relative',
          'Other (specify)'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) => onWorkDecisionChanged(value ?? ''),
      ),
      if (showOtherWorkField) ..._buildOtherField(
        controller: TextEditingController(text: otherWorkDecisionMaker),
        onChanged: onOtherWorkChanged,
        label: 'Please specify who makes work decisions',
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildHealthDecisionFields() {
    return [
      const Text('Who makes decisions about the child\'s health?'),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: healthDecisionMaker,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Select decision maker',
        ),
        items: [
          'Mother',
          'Father',
          'Both Parents',
          'Grandparent(s)',
          'Other relative',
          'Other (specify)'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) => onHealthDecisionChanged(value ?? ''),
      ),
      if (showOtherHealthField) ..._buildOtherField(
        controller: TextEditingController(text: otherHealthDecisionMaker),
        onChanged: onOtherHealthChanged,
        label: 'Please specify who makes health decisions',
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildOtherField({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required String label,
  }) {
    return [
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    ];
  }
}
