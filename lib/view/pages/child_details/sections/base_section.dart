import 'package:flutter/material.dart';

class BaseSection extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const BaseSection({
    Key? key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: padding!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
