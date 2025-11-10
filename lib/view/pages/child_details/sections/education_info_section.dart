import 'package:flutter/material.dart';
import 'base_section.dart';

class EducationInfoSection extends StatelessWidget {
  final bool isInSchool;
  final String? schoolName;
  final String? grade;
  final String? schoolType;
  final String? schoolLocation;
  final String? schoolDistance;
  final String? transportType;
  final String? reasonNotInSchool;
  final String? otherReasonNotInSchool;
  final bool showSchoolNameField;
  final bool showGradeField;
  final bool showSchoolTypeField;
  final bool showSchoolLocationField;
  final bool showSchoolDistanceField;
  final bool showTransportTypeField;
  final bool showReasonNotInSchoolField;
  final bool showOtherReasonField;
  final ValueChanged<bool> onIsInSchoolChanged;
  final ValueChanged<String> onSchoolNameChanged;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<String> onSchoolTypeChanged;
  final ValueChanged<String> onSchoolLocationChanged;
  final ValueChanged<String> onSchoolDistanceChanged;
  final ValueChanged<String> onTransportTypeChanged;
  final ValueChanged<String> onReasonNotInSchoolChanged;
  final ValueChanged<String> onOtherReasonChanged;

  const EducationInfoSection({
    Key? key,
    required this.isInSchool,
    this.schoolName,
    this.grade,
    this.schoolType,
    this.schoolLocation,
    this.schoolDistance,
    this.transportType,
    this.reasonNotInSchool,
    this.otherReasonNotInSchool,
    required this.showSchoolNameField,
    required this.showGradeField,
    required this.showSchoolTypeField,
    required this.showSchoolLocationField,
    required this.showSchoolDistanceField,
    required this.showTransportTypeField,
    required this.showReasonNotInSchoolField,
    required this.showOtherReasonField,
    required this.onIsInSchoolChanged,
    required this.onSchoolNameChanged,
    required this.onGradeChanged,
    required this.onSchoolTypeChanged,
    required this.onSchoolLocationChanged,
    required this.onSchoolDistanceChanged,
    required this.onTransportTypeChanged,
    required this.onReasonNotInSchoolChanged,
    required this.onOtherReasonChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseSection(
      title: 'Education Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIsInSchoolField(),
          const SizedBox(height: 16),
          if (isInSchool) ..._buildInSchoolFields(),
          if (!isInSchool && showReasonNotInSchoolField) ..._buildNotInSchoolFields(),
        ],
      ),
    );
  }

  Widget _buildIsInSchoolField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Is the child currently in school?'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInSchoolRadio(true, 'Yes'),
            const SizedBox(width: 16),
            _buildInSchoolRadio(false, 'No'),
          ],
        ),
      ],
    );
  }

  Widget _buildInSchoolRadio(bool value, String label) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: isInSchool,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              onIsInSchoolChanged(newValue);
            }
          },
        ),
        Text(label),
      ],
    );
  }

  List<Widget> _buildInSchoolFields() {
    return [
      if (showSchoolNameField)
        TextFormField(
          initialValue: schoolName,
          decoration: const InputDecoration(
            labelText: 'Name of School',
            border: OutlineInputBorder(),
          ),
          onChanged: onSchoolNameChanged,
        ),
      if (showSchoolNameField) const SizedBox(height: 16),
      
      if (showGradeField)
        TextFormField(
          initialValue: grade,
          decoration: const InputDecoration(
            labelText: 'Grade/Class',
            border: OutlineInputBorder(),
          ),
          onChanged: onGradeChanged,
        ),
      if (showGradeField) const SizedBox(height: 16),
      
      if (showSchoolTypeField)
        DropdownButtonFormField<String>(
          value: schoolType,
          decoration: const InputDecoration(
            labelText: 'Type of School',
            border: OutlineInputBorder(),
          ),
          items: ['Public', 'Private', 'Religious', 'Other'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) => onSchoolTypeChanged(value ?? ''),
        ),
      if (showSchoolTypeField) const SizedBox(height: 16),
      
      if (showSchoolLocationField)
        TextFormField(
          initialValue: schoolLocation,
          decoration: const InputDecoration(
            labelText: 'School Location',
            border: OutlineInputBorder(),
          ),
          onChanged: onSchoolLocationChanged,
        ),
      if (showSchoolLocationField) const SizedBox(height: 16),
      
      if (showSchoolDistanceField)
        TextFormField(
          initialValue: schoolDistance,
          decoration: const InputDecoration(
            labelText: 'Distance to School (km)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: onSchoolDistanceChanged,
        ),
      if (showSchoolDistanceField) const SizedBox(height: 16),
      
      if (showTransportTypeField)
        DropdownButtonFormField<String>(
          value: transportType,
          decoration: const InputDecoration(
            labelText: 'Mode of Transport to School',
            border: OutlineInputBorder(),
          ),
          items: [
            'Walking',
            'Bicycle',
            'School Bus',
            'Public Transport',
            'Private Vehicle',
            'Other'
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) => onTransportTypeChanged(value ?? ''),
        ),
    ];
  }

  List<Widget> _buildNotInSchoolFields() {
    return [
      DropdownButtonFormField<String>(
        value: reasonNotInSchool,
        decoration: const InputDecoration(
          labelText: 'Reason for not being in school',
          border: OutlineInputBorder(),
        ),
        items: [
          'Financial constraints',
          'Distance to school',
          'Child is working',
          'Early marriage',
          'Illness/Disability',
          'Lack of interest',
          'Other (specify)'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) => onReasonNotInSchoolChanged(value ?? ''),
      ),
      const SizedBox(height: 16),
      
      if (showOtherReasonField && reasonNotInSchool == 'Other (specify)')
        TextFormField(
          initialValue: otherReasonNotInSchool,
          decoration: const InputDecoration(
            labelText: 'Please specify',
            border: OutlineInputBorder(),
          ),
          onChanged: onOtherReasonChanged,
        ),
      if (showOtherReasonField && reasonNotInSchool == 'Other (specify)')
        const SizedBox(height: 16),
    ];
  }
}
