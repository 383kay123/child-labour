import 'package:flutter/material.dart';

class SelectField<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? errorText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final FormFieldValidator<T>? validator;
  final Widget? prefixIcon;
  final bool isExpanded;
  final String? Function(T?)? validationError;

  const SelectField({
    Key? key,
    required this.label,
    this.hintText,
    this.errorText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.validator,
    this.prefixIcon,
    this.isExpanded = false,
    this.validationError,
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
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          isExpanded: isExpanded,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
            errorText: errorText ?? (validationError != null ? validationError!(value) : null),
            errorMaxLines: 2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: enabled
                ? Theme.of(context).cardColor
                : Theme.of(context).disabledColor.withOpacity(0.1),
            prefixIcon: prefixIcon,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class SelectOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SelectOption({
    required this.value,
    required this.label,
    this.icon,
  });
}
