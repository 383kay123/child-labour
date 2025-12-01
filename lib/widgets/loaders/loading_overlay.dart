import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final bool isOpaque;
  final Color? color;
  final double opacity;
  final Widget child;
  final Widget? loadingIndicator;
  final String? message;
  final TextStyle? messageStyle;
  final double indicatorSize;
  final Color? indicatorColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.isOpaque = false,
    this.color,
    this.opacity = 0.5,
    this.loadingIndicator,
    this.message,
    this.messageStyle,
    this.indicatorSize = 40.0,
    this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        child,
        
        // Loading overlay
        if (isLoading) ..._buildLoadingOverlay(context),
      ],
    );
  }

  List<Widget> _buildLoadingOverlay(BuildContext context) {
    final theme = Theme.of(context);
    
    return [
      // Background
      Positioned.fill(
        child: Container(
          color: isOpaque
              ? color ?? theme.scaffoldBackgroundColor
              : (color ?? Colors.black).withOpacity(opacity),
        ),
      ),
      
      // Loading indicator and message
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom loading indicator or default CircularProgressIndicator
            loadingIndicator ??
                SizedBox(
                  width: indicatorSize,
                  height: indicatorSize,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      indicatorColor ?? theme.primaryColor,
                    ),
                    strokeWidth: 3.0,
                  ),
                ),
            
            // Optional message
            if (message != null) ..._buildMessage(theme),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildMessage(ThemeData theme) {
    return [
      const SizedBox(height: 16.0),
      Text(
        message!,
        style: messageStyle ??
            theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
        textAlign: TextAlign.center,
      ),
    ];
  }

  static Widget showLoadingOverlay<T>(
    BuildContext context, {
    required Future<T> future,
    required WidgetBuilder builder,
    WidgetBuilder? loadingBuilder,
    Widget Function(BuildContext, dynamic)? errorBuilder,
    bool isOpaque = false,
    Color? color,
    double opacity = 0.5,
    String? loadingMessage,
    String? errorMessage,
  }) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingOverlay(
            isLoading: true,
            isOpaque: isOpaque,
            color: color,
            opacity: opacity,
            message: loadingMessage,
            child: loadingBuilder?.call(context) ?? const SizedBox(),
          );
        }

        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return errorBuilder(context, snapshot.error);
          }
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage ?? 'An error occurred: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return builder(context);
      },
    );
  }
}
