import 'package:flutter/material.dart';

class SurveyQuestion {
  final String id;
  final String question;
  final String type;
  final List<String>? options;
  final bool required;
  final String? dependsOn;
  final String? dependsOnValue;
  final Function(BuildContext, dynamic)? logic;

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.required = true,
    this.dependsOn,
    this.dependsOnValue,
    this.logic,
  });
}

final List<SurveyQuestion> surveyQuestions = [
  SurveyQuestion(
    id: 'isChildOfFarmer',
    question: "Are there children living in the respondent's household?",
    type: 'radio',
    options: ['Yes', 'No'],
    logic: (context, value) {
      if (value == 'No') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Survey End'),
            content: Text('No children in household. Survey cannot continue.'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF006A4E),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Close Survey'),
              ),
            ],
          ),
        );
      }
    },
  ),
  SurveyQuestion(
    id: 'isChildDeclared',
    question:
        "Is the child among the list of children declared in the cover to be the farmers children?",
    type: 'radio',
    options: ['Yes', 'No'],
    dependsOn: 'isChildOfFarmer',
    dependsOnValue: 'Yes',
  ),
  SurveyQuestion(
    id: 'childrenBetween5And17',
    question:
        'Out of the number of children stated above, How many are between the ages of 5 and 17?',
    type: 'number',
    dependsOn: 'isChildOfFarmer',
    dependsOnValue: 'Yes',
  ),
  // Add more questions here
];
