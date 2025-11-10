import 'package:flutter/material.dart';

/// A modern, customizable radio button widget with support for title and subtitle.
///
/// This widget provides a modern, touch-friendly radio button that can be used
/// in forms and selection dialogs. It includes support for a title and an optional
/// subtitle, with smooth animations and visual feedback.
class ModernRadioButton<T> extends StatelessWidget {
  /// The value represented by this radio button.
  final T value;

  /// The currently selected value for the group of radio buttons.
  final T? groupValue;

  /// Called when the user selects this radio button.
  final ValueChanged<T?> onChanged;

  /// The primary text to display.
  final String title;

  /// Optional secondary text to display below the title.
  final String? subtitle;

  /// Creates a modern radio button.
  const ModernRadioButton({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[50],
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Custom Radio Circle
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? primaryColor : Colors.grey[800],
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? primaryColor.withOpacity(0.8)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
