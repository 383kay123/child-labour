import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPreviewDialog extends StatefulWidget {
  final String title;
  final String? description;
  final VoidCallback? onRetake;
  final VoidCallback? onConfirm;
  final XFile? imageFile;
  final File? imageFileLocal;
  final bool showControls;
  final String confirmButtonText;
  final String retakeButtonText;
  final double maxHeight;
  final double maxWidth;
  final BoxFit fit;
  final Color? backgroundColor;
  final Color? barrierColor;
  final bool useRootNavigator;
  final RouteSettings? routeSettings;
  final bool dismissible;
  final bool enableDrag;
  final EdgeInsets insetPadding;
  final Clip clipBehavior;

  const CameraPreviewDialog({
    Key? key,
    required this.title,
    this.description,
    this.onRetake,
    this.onConfirm,
    this.imageFile,
    this.imageFileLocal,
    this.showControls = true,
    this.confirmButtonText = 'Confirm',
    this.retakeButtonText = 'Retake',
    this.maxHeight = double.infinity,
    this.maxWidth = double.infinity,
    this.fit = BoxFit.contain,
    this.backgroundColor,
    this.barrierColor,
    this.useRootNavigator = true,
    this.routeSettings,
    this.dismissible = true,
    this.enableDrag = true,
    this.insetPadding = const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
    this.clipBehavior = Clip.none,
  })  : assert(imageFile != null || imageFileLocal != null, 'Either imageFile or imageFileLocal must be provided'),
        super(key: key);

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? description,
    XFile? imageFile,
    File? imageFileLocal,
    VoidCallback? onRetake,
    VoidCallback? onConfirm,
    bool showControls = true,
    String confirmButtonText = 'Confirm',
    String retakeButtonText = 'Retake',
    double maxHeight = double.infinity,
    double maxWidth = double.infinity,
    BoxFit fit = BoxFit.contain,
    Color? backgroundColor,
    Color? barrierColor,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    bool dismissible = true,
    bool enableDrag = true,
    EdgeInsets? insetPadding,
    Clip clipBehavior = Clip.none,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      barrierDismissible: dismissible,
      builder: (context) => CameraPreviewDialog(
        title: title,
        description: description,
        imageFile: imageFile,
        imageFileLocal: imageFileLocal,
        onRetake: onRetake,
        onConfirm: onConfirm,
        showControls: showControls,
        confirmButtonText: confirmButtonText,
        retakeButtonText: retakeButtonText,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        fit: fit,
        backgroundColor: backgroundColor,
        useRootNavigator: useRootNavigator,
        routeSettings: routeSettings,
        dismissible: dismissible,
        enableDrag: enableDrag,
        insetPadding: insetPadding ?? const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        clipBehavior: clipBehavior,
      ),
    );
  }

  @override
  _CameraPreviewDialogState createState() => _CameraPreviewDialogState();
}

class _CameraPreviewDialogState extends State<CameraPreviewDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;

    final maxHeight = widget.maxHeight == double.infinity
        ? size.height - padding.top - padding.bottom - 120
        : widget.maxHeight;
    final maxWidth = widget.maxWidth == double.infinity
        ? size.width - 80
        : widget.maxWidth;

    return Dialog(
      backgroundColor: widget.backgroundColor ?? theme.dialogBackgroundColor,
      insetPadding: widget.insetPadding,
      clipBehavior: widget.clipBehavior,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: maxWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      widget.description!,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            // Image preview
            Expanded(
              child: ClipRect(
                child: widget.imageFile != null
                    ? Image.file(
                        File(widget.imageFile!.path),
                        fit: widget.fit,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : widget.imageFileLocal != null
                        ? Image.file(
                            widget.imageFileLocal!,
                            fit: widget.fit,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : const Center(child: Text('No image available')),
              ),
            ),

            // Controls
            if (widget.showControls) ..._buildControls(theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildControls(ThemeData theme) {
    return [
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                widget.onRetake?.call();
              },
              child: Text(widget.retakeButtonText),
            ),
            const SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                widget.onConfirm?.call();
              },
              child: Text(widget.confirmButtonText),
            ),
          ],
        ),
      ),
    ];
  }
}
