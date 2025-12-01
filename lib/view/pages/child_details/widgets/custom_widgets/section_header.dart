import 'package:flutter/material.dart';

/// A styled section header widget for form sections.
///
/// This widget provides a consistent look for section headers in forms,
/// with a colored background and bold text.
class SectionHeader extends StatelessWidget {
  /// The text to display in the header.
  final String title;

  /// Optional child widget to display below the title.
  final Widget? child;

  /// Creates a section header.
  const SectionHeader({
    Key? key,
    required this.title,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (child != null) ...[
            const SizedBox(height: 8),
            child!,
          ],
        ],
      ),
    );
  }
}
