import 'package:flutter/material.dart';
import 'base_section.dart';

class FamilyInfoSection extends StatelessWidget {
  final String? livingDuration;
  final bool? isOrphan;
  final List<String>? orphanedParents;
  final bool showOrphanedParentsField;
  final ValueChanged<String> onLivingDurationChanged;
  final ValueChanged<bool> onIsOrphanChanged;
  final ValueChanged<List<String>> onOrphanedParentsChanged;

  const FamilyInfoSection({
    Key? key,
    this.livingDuration,
    this.isOrphan,
    this.orphanedParents = const [],
    required this.showOrphanedParentsField,
    required this.onLivingDurationChanged,
    required this.onIsOrphanChanged,
    required this.onOrphanedParentsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseSection(
      title: 'Family Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // How long has the child been living in the household?
          const Text('How long has the child been living in the household?'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: livingDuration,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select duration',
            ),
            items: [
              'Less than 1 year',
              '1-2 years',
              '3-5 years',
              '6-10 years',
              'More than 10 years',
              'Whole life'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) => onLivingDurationChanged(value ?? ''),
          ),
          
          const SizedBox(height: 16),
          
          // Is the child an orphan?
          const Text('Is the child an orphan?'),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildOrphanRadio(true, 'Yes'),
              const SizedBox(width: 16),
              _buildOrphanRadio(false, 'No'),
            ],
          ),
          
          if (showOrphanedParentsField && (isOrphan == true)) ..._buildOrphanedParentsFields(),
        ],
      ),
    );
  }

  Widget _buildOrphanRadio(bool value, String label) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: isOrphan,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              onIsOrphanChanged(newValue);
            }
          },
        ),
        Text(label),
      ],
    );
  }

  List<Widget> _buildOrphanedParentsFields() {
    final List<String> parents = ['Father', 'Mother'];
    
    return [
      const SizedBox(height: 16),
      const Text('Which parent(s) has passed away?'),
      const SizedBox(height: 8),
      ...parents.map((parent) => _buildParentCheckbox(parent)).toList(),
      const SizedBox(height: 8),
    ];
  }

  Widget _buildParentCheckbox(String parent) {
    final isSelected = orphanedParents?.contains(parent) ?? false;
    
    return CheckboxListTile(
      title: Text(parent),
      value: isSelected,
      onChanged: (bool? value) {
        if (value == null) return;
        
        final updatedList = List<String>.from(orphanedParents ?? []);
        if (value) {
          updatedList.add(parent);
        } else {
          updatedList.remove(parent);
        }
        onOrphanedParentsChanged(updatedList);
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
