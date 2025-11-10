import 'package:flutter/material.dart';

/// A modern, customizable checkbox widget with support for title and subtitle.
///
/// This widget provides a modern, touch-friendly checkbox that can be used
/// in forms and selection dialogs. It includes support for a title and an optional
/// subtitle, with smooth animations and visual feedback.
class ModernCheckbox extends StatelessWidget {
  /// Whether this checkbox is checked.
  final bool value;

  /// Called when the value of the checkbox should change.
  final ValueChanged<bool?> onChanged;

  /// The primary text to display.
  final String title;

  /// Optional secondary text to display below the title.
  final String? subtitle;

  /// Creates a modern checkbox.
  const ModernCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: value ? primaryColor.withOpacity(0.1) : Colors.grey[50],
              border: Border.all(
                color: value ? primaryColor : Colors.grey[300]!,
                width: value ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Custom Checkbox
                Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: value ? primaryColor : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: value ? primaryColor : Colors.transparent,
                  ),
                  child: value
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
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
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w200,
                    ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                         style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
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
