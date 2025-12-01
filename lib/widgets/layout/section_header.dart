import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool showDivider;
  final Color? dividerColor;
  final double dividerHeight;
  final double dividerThickness;
  final double dividerIndent;
  final double dividerEndIndent;
  final MainAxisAlignment mainAxisAlignment;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.action,
    this.spacing = 8.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.titleStyle,
    this.subtitleStyle,
    this.showDivider = false,
    this.dividerColor,
    this.dividerHeight = 1.0,
    this.dividerThickness = 1.0,
    this.dividerIndent = 0.0,
    this.dividerEndIndent = 0.0,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (showDivider)
          Divider(
            height: dividerHeight,
            thickness: dividerThickness,
            color: dividerColor ?? theme.dividerColor,
            indent: dividerIndent,
            endIndent: dividerEndIndent,
          ),
        Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  children: [
                    Text(
                      title,
                      style: titleStyle ??
                          textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: crossAxisAlignment == CrossAxisAlignment.start
                          ? TextAlign.left
                          : crossAxisAlignment == CrossAxisAlignment.end
                              ? TextAlign.right
                              : TextAlign.center,
                    ),
                    if (subtitle != null) ..._buildSubtitle(theme, textTheme),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSubtitle(ThemeData theme, TextTheme textTheme) {
    return [
      const SizedBox(height: 4.0),
      Text(
        subtitle!,
        style: subtitleStyle ??
            textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
      ),
    ];
  }
}
