import 'package:flutter/material.dart';
import 'base_section.dart';

class WorkInfoSection extends StatelessWidget {
  final bool isWorking;
  final String? workType;
  final String? workLocation;
  final double? hoursPerDay;
  final int? daysPerWeek;
  final bool isHazardousWork;
  final String? hazardsDescription;
  final double? monthlyIncome;
  final String? otherWorkType;
  final bool showWorkTypeField;
  final bool showWorkLocationField;
  final bool showHoursField;
  final bool showDaysField;
  final bool showHazardField;
  final bool showHazardsDescriptionField;
  final bool showIncomeField;
  final bool showOtherWorkTypeField;
  final ValueChanged<bool> onIsWorkingChanged;
  final ValueChanged<String> onWorkTypeChanged;
  final ValueChanged<String> onWorkLocationChanged;
  final ValueChanged<String> onHoursPerDayChanged;
  final ValueChanged<String> onDaysPerWeekChanged;
  final ValueChanged<bool> onIsHazardousWorkChanged;
  final ValueChanged<String> onHazardsDescriptionChanged;
  final ValueChanged<String> onMonthlyIncomeChanged;
  final ValueChanged<String> onOtherWorkTypeChanged;

  const WorkInfoSection({
    Key? key,
    required this.isWorking,
    this.workType,
    this.workLocation,
    this.hoursPerDay,
    this.daysPerWeek,
    required this.isHazardousWork,
    this.hazardsDescription,
    this.monthlyIncome,
    this.otherWorkType,
    required this.showWorkTypeField,
    required this.showWorkLocationField,
    required this.showHoursField,
    required this.showDaysField,
    required this.showHazardField,
    required this.showHazardsDescriptionField,
    required this.showIncomeField,
    required this.showOtherWorkTypeField,
    required this.onIsWorkingChanged,
    required this.onWorkTypeChanged,
    required this.onWorkLocationChanged,
    required this.onHoursPerDayChanged,
    required this.onDaysPerWeekChanged,
    required this.onIsHazardousWorkChanged,
    required this.onHazardsDescriptionChanged,
    required this.onMonthlyIncomeChanged,
    required this.onOtherWorkTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseSection(
      title: 'Work Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIsWorkingField(),
          const SizedBox(height: 16),
          if (isWorking) ..._buildWorkingFields(),
        ],
      ),
    );
  }

  Widget _buildIsWorkingField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Is the child currently working?'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildWorkingRadio(true, 'Yes'),
            const SizedBox(width: 16),
            _buildWorkingRadio(false, 'No'),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkingRadio(bool value, String label) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: isWorking,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              onIsWorkingChanged(newValue);
            }
          },
        ),
        Text(label),
      ],
    );
  }

  List<Widget> _buildWorkingFields() {
    return [
      if (showWorkTypeField)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: workType,
              decoration: const InputDecoration(
                labelText: 'Type of Work',
                border: OutlineInputBorder(),
              ),
              items: [
                'Agriculture/Farming',
                'Domestic Work',
                'Street Vending',
                'Construction',
                'Mining',
                'Manufacturing',
                'Other (specify)'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => onWorkTypeChanged(value ?? ''),
            ),
            if (showOtherWorkTypeField && workType == 'Other (specify)')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  initialValue: otherWorkType,
                  decoration: const InputDecoration(
                    labelText: 'Please specify the type of work',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: onOtherWorkTypeChanged,
                ),
              ),
          ],
        ),
      if (showWorkTypeField) const SizedBox(height: 16),

      if (showWorkLocationField)
        TextFormField(
          initialValue: workLocation,
          decoration: const InputDecoration(
            labelText: 'Work Location',
            border: OutlineInputBorder(),
          ),
          onChanged: onWorkLocationChanged,
        ),
      if (showWorkLocationField) const SizedBox(height: 16),

      if (showHoursField)
        TextFormField(
          initialValue: hoursPerDay?.toString(),
          decoration: const InputDecoration(
            labelText: 'Hours per day',
            border: OutlineInputBorder(),
            suffixText: 'hours',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: onHoursPerDayChanged,
        ),
      if (showHoursField) const SizedBox(height: 16),

      if (showDaysField)
        TextFormField(
          initialValue: daysPerWeek?.toString(),
          decoration: const InputDecoration(
            labelText: 'Days per week',
            border: OutlineInputBorder(),
            suffixText: 'days',
          ),
          keyboardType: TextInputType.number,
          onChanged: onDaysPerWeekChanged,
        ),
      if (showDaysField) const SizedBox(height: 16),

      if (showHazardField)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Is the work hazardous?'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildHazardRadio(true, 'Yes'),
                const SizedBox(width: 16),
                _buildHazardRadio(false, 'No'),
              ],
            ),
          ],
        ),
      if (showHazardField) const SizedBox(height: 16),

      if (showHazardsDescriptionField && isHazardousWork)
        TextFormField(
          initialValue: hazardsDescription,
          decoration: const InputDecoration(
            labelText: 'Please describe the hazards',
            border: OutlineInputBorder(),
            hintText: 'e.g., exposure to chemicals, heavy lifting, etc.',
          ),
          maxLines: 3,
          onChanged: onHazardsDescriptionChanged,
        ),
      if (showHazardsDescriptionField && isHazardousWork) const SizedBox(height: 16),

      if (showIncomeField)
        TextFormField(
          initialValue: monthlyIncome?.toString(),
          decoration: const InputDecoration(
            labelText: 'Monthly Income (if any)',
            border: OutlineInputBorder(),
            prefixText: '\$',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: onMonthlyIncomeChanged,
        ),
    ];
  }

  Widget _buildHazardRadio(bool value, String label) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: isHazardousWork,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              onIsHazardousWorkChanged(newValue);
            }
          },
        ),
        Text(label),
      ],
    );
  }
}
