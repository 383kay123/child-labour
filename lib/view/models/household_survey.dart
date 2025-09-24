import 'package:flutter/foundation.dart';

class SurveyQuestion {
  final String id;
  final String question;
  final String type; // text, yes_no, multiple_choice, checkbox, date, picture, gps
  final List<String>? options;
  final bool isRequired;
  final String? section;
  final String? hint;
  final bool showIf;
  final String? showIfQuestionId;
  final String? showIfValue;

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.isRequired = true,
    this.section,
    this.hint,
    this.showIf = false,
    this.showIfQuestionId,
    this.showIfValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options,
      'isRequired': isRequired ? 1 : 0,
      'section': section,
      'hint': hint,
      'showIf': showIf ? 1 : 0,
      'showIfQuestionId': showIfQuestionId,
      'showIfValue': showIfValue,
    };
  }

  factory SurveyQuestion.fromMap(Map<String, dynamic> map) {
    return SurveyQuestion(
      id: map['id'],
      question: map['question'],
      type: map['type'],
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      isRequired: map['isRequired'] == 1,
      section: map['section'],
      hint: map['hint'],
      showIf: map['showIf'] == 1,
      showIfQuestionId: map['showIfQuestionId'],
      showIfValue: map['showIfValue'],
    );
  }
}

class SurveyResponse {
  final int? id;
  final String surveyId;
  final String questionId;
  final dynamic response;
  final DateTime timestamp;
  final String? section;
  final String? metadata; // For additional data like image paths, etc.

  SurveyResponse({
    this.id,
    required this.surveyId,
    required this.questionId,
    required this.response,
    DateTime? timestamp,
    this.section,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surveyId': surveyId,
      'questionId': questionId,
      'response': response is List ? response.join('||') : response.toString(),
      'timestamp': timestamp.toIso8601String(),
      'section': section,
      'metadata': metadata,
    };
  }

  factory SurveyResponse.fromMap(Map<String, dynamic> map) {
    return SurveyResponse(
      id: map['id'],
      surveyId: map['surveyId'],
      questionId: map['questionId'],
      response: map['response'],
      timestamp: DateTime.parse(map['timestamp']),
      section: map['section'],
      metadata: map['metadata'],
    );
  }
}

class SurveyProgress {
  final int surveyId;
  final String currentSection;
  final int currentQuestionIndex;
  final bool isCompleted;
  final DateTime lastUpdated;

  SurveyProgress({
    required this.surveyId,
    required this.currentSection,
    required this.currentQuestionIndex,
    this.isCompleted = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'surveyId': surveyId,
      'currentSection': currentSection,
      'currentQuestionIndex': currentQuestionIndex,
      'isCompleted': isCompleted ? 1 : 0,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory SurveyProgress.fromMap(Map<String, dynamic> map) {
    return SurveyProgress(
      surveyId: map['surveyId'],
      currentSection: map['currentSection'],
      currentQuestionIndex: map['currentQuestionIndex'],
      isCompleted: map['isCompleted'] == 1,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}
