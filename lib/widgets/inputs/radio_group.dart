import 'package:flutter/material.dart';

class RadioGroup<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<RadioOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String? errorText;
  final Axis direction;
  final double spacing;
  final bool enabled;

  const RadioGroup({
    Key? key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
    this.direction = Axis.vertical,
    this.spacing = 12.0,
    this.enabled = true,
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
        if (direction == Axis.vertical)
          _buildVerticalLayout(context)
        else
          _buildHorizontalLayout(context),
        if (errorText != null) ..._buildError(),
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildRadioTiles(),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _buildRadioTiles(),
      ),
    );
  }

  List<Widget> _buildRadioTiles() {
    return options.map((option) {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<T>(
              value: option.value,
              groupValue: value,
              onChanged: enabled
                  ? (T? newValue) {
                      onChanged(newValue);
                    }
                  : null,
              activeColor: Theme.of(option.context).primaryColor,
            ),
            const SizedBox(width: 4.0),
            GestureDetector(
              onTap: enabled
                  ? () {
                      onChanged(option.value);
                    }
                  : null,
              child: Text(
                option.label,
                style: TextStyle(
                  color: enabled ? null : Theme.of(option.context).disabledColor,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
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

class RadioOption<T> {
  final T value;
  final String label;
  final BuildContext context;

  RadioOption({
    required this.value,
    required this.label,
    required this.context,
  });
}
