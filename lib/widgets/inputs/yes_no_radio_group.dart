import 'package:flutter/material.dart';

class YesNoRadioGroup extends StatelessWidget {
  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;
  final String? errorText;
  final bool enabled;
  final Axis direction;
  final String yesLabel;
  final String noLabel;

  const YesNoRadioGroup({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.direction = Axis.horizontal,
    this.yesLabel = 'Yes',
    this.noLabel = 'No',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            _buildRadioButton(context, true, yesLabel),
            SizedBox(width: direction == Axis.horizontal ? 24.0 : 0.0),
            _buildRadioButton(context, false, noLabel),
          ],
        ),
        if (errorText != null) ..._buildError(),
      ],
    );
  }

  Widget _buildRadioButton(BuildContext context, bool optionValue, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<bool>(
          value: optionValue,
          groupValue: value,
          onChanged: enabled
              ? (bool? newValue) {
                  onChanged(newValue);
                }
              : null,
          activeColor: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 4.0),
        GestureDetector(
          onTap: enabled
              ? () {
                  onChanged(optionValue);
                }
              : null,
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? null : Theme.of(context).disabledColor,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildError() {
    return [
      const SizedBox(height: 4.0),
      Text(
        errorText!,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12.0,
        ),
      ),
    ];
  }
}
