import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final double? elevation;
  final bool expanded;
  final bool hasBorder;
  final Color? borderColor;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 48.0,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.padding,
    this.icon,
    this.elevation,
    this.expanded = false,
    this.hasBorder = false,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = backgroundColor ?? theme.primaryColor;
    final disabledColor = theme.disabledColor;
    final textTheme = theme.textTheme;

    Widget content = isLoading
        ? SizedBox(
            height: 24.0,
            width: 24.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? Colors.white,
              ),
              strokeWidth: 2.0,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8.0)],
              Text(
                text,
                style: textTheme.labelLarge?.copyWith(
                  color: isDisabled
                      ? theme.colorScheme.onSurface.withOpacity(0.38)
                      : textColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    if (expanded) {
      content = Expanded(child: content);
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? disabledColor : buttonColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: hasBorder
                ? BorderSide(
                    color: borderColor ?? theme.primaryColor,
                    width: 1.0,
                  )
                : BorderSide.none,
          ),
          padding: padding,
        ),
        child: content,
      ),
    );
  }
}
