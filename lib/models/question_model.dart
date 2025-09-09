import 'package:flutter/material.dart';

enum QuestionType {
  radio,
  dropdown,
  text,
  checkbox,
  date,
  image,
}

class Question {
  final String question;
  final QuestionType type;
  final List<String>? options;
  final String? hint;
  final String? fieldName;
  final bool isRequired;
  final String? dependsOn;
  final String? dependsOnValue;

  Question({
    required this.question,
    required this.type,
    this.options,
    this.hint,
    this.fieldName,
    this.isRequired = false,
    this.dependsOn,
    this.dependsOnValue,
  });
}
