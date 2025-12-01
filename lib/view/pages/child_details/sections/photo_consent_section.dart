import 'package:flutter/material.dart';
import 'base_section.dart';

class PhotoConsentSection extends StatelessWidget {
  final bool hasGivenConsent;
  final String? consentNotes;
  final bool showConsentField;
  final bool showNotesField;
  final ValueChanged<bool> onConsentChanged;
  final ValueChanged<String> onConsentNotesChanged;

  const PhotoConsentSection({
    Key? key,
    required this.hasGivenConsent,
    this.consentNotes,
    required this.showConsentField,
    required this.showNotesField,
    required this.onConsentChanged,
    required this.onConsentNotesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showConsentField) return const SizedBox.shrink();

    return BaseSection(
      title: 'Photo Consent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConsentCheckbox(context),
          const SizedBox(height: 8),
          if (showNotesField) _buildConsentNotesField(),
          const SizedBox(height: 8),
          _buildConsentTerms(),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox(BuildContext context) {
    return CheckboxListTile(
      title: const Text('I give consent for photos to be taken of the child'),
      value: hasGivenConsent,
      onChanged: (bool? value) {
        if (value != null) {
          onConsentChanged(value);
        }
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildConsentNotesField() {
    return TextFormField(
      initialValue: consentNotes,
      decoration: const InputDecoration(
        labelText: 'Notes about consent',
        border: OutlineInputBorder(),
        hintText: 'Any specific conditions or notes about photo consent',
      ),
      maxLines: 2,
      onChanged: onConsentNotesChanged,
    );
  }

  Widget _buildConsentTerms() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photo Usage Terms:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Photos will only be used for official documentation and reporting purposes\n'
            '• Personal identification will be protected when sharing photos externally\n'
            '• You may withdraw this consent at any time by contacting our office\n'
            '• Photos will be stored securely and in compliance with data protection regulations',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${DateTime.now().toString().split(' ')[0]}',
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
