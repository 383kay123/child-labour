import 'package:flutter/material.dart';

/// A styled card widget for displaying informational messages.
///
/// This widget provides a consistent look for informational messages
/// with a light background and border.
class InfoCard extends StatelessWidget {
  /// The text to display in the card.
  final String text;

  /// Optional icon to display before the text.
  final IconData? icon;

  /// The color of the card's border and icon.
  final Color? color;

  /// The background color of the card.
  final Color? backgroundColor;

  /// Creates an info card.
  const InfoCard({
    Key? key,
    required this.text,
    this.icon,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.primaryColor;
    final bgColor = backgroundColor ?? primaryColor.withOpacity(0.05);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
