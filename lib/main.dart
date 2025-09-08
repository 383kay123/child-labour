import 'package:flutter/material.dart';

import 'home/home.dart';

void main() {
  runApp(const Surveyflow());
}

class Surveyflow extends StatelessWidget {
  const Surveyflow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}
