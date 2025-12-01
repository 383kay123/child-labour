import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final MainAxisAlignment mainAxisAlignment;
  final List<Widget>? additionalActions;

  const PageHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.action,
    this.showBackButton = false,
    this.onBackPressed,
    this.spacing = 8.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.titleStyle,
    this.subtitleStyle,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.additionalActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBackButton) ..._buildBackButton(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  children: [
                    Text(
                      title,
                      style: titleStyle ??
                          textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
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
              ...?additionalActions,
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBackButton(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      const SizedBox(width: 8.0),
    ];
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
