import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/fields/checkbox.dart';
import 'package:surveyflow/fields/datepickerfield.dart';
import 'package:surveyflow/fields/dropcheckbox.dart';
import 'package:surveyflow/fields/dropdown.dart';
import 'package:surveyflow/fields/radiobuttons.dart';

class DynamicSurveyPage extends StatefulWidget {
  @override
  _DynamicSurveyPageState createState() => _DynamicSurveyPageState();
}

class _DynamicSurveyPageState extends State<DynamicSurveyPage> {
  int totalMembers = 0;
  List<String> householdMembers = [];
  Map<String, Map<String, String>> responses = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Household Survey',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF006A4E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Total number of household members'),
              onChanged: (value) {
                setState(() {
                  totalMembers = int.tryParse(value) ?? 0;
                  householdMembers = List.generate(totalMembers, (index) => '');
                  responses.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            if (totalMembers > 0)
              Column(
                children: List.generate(totalMembers, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          labelText:
                              'Full name of household member ${index + 1}'),
                      onChanged: (value) {
                        setState(() {
                          householdMembers[index] = value;
                          responses[value] = {};
                        });
                      },
                    ),
                  );
                }),
              ),
            if (householdMembers.any((name) => name.isNotEmpty))
              Column(
                children: householdMembers
                    .where((name) => name.isNotEmpty)
                    .map((name) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tableau: PRODUCERS/MANAGERS HOUSEHOLD INFORMATION - $name',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      DropdownField(
                        question: 'Relationship of $name to the respondent',
                        options: [
                          'Husband/wife',
                          'Son/daughter',
                          'Brother/sister',
                          'Son-in-law/daughter-in-law',
                          'Grandson/granddaughter',
                          'Niece/nephew',
                          'Cousin',
                          'A worker’s family member',
                          'Worker',
                          'Father/Mother',
                          'Other (to specify)',
                        ],
                      ),
                      ..._buildQuestionFields([
                        'Age of $name',
                      ]),
                      RadioButtonField(
                        question: 'Gender of $name',
                        options: ['Male', 'Female', 'Other'],
                      ),
                      ..._buildQuestionFields([
                        'Other to specify',
                      ]),
                      RadioButtonField(
                        question: 'Nationality of $name?',
                        options: [
                          'Ghanaian',
                          'Non Ghanaian',
                        ],
                      ),
                      DropdownField(
                        question: 'Nationality of $name',
                        options: [
                          'Burkina Faso',
                          'Mali',
                          'Guinea',
                          'Ivory Coast',
                          'Liberia',
                          'Togo',
                          'Benin',
                          'Niger',
                          'Nigeria',
                          'Other (to specify)'
                        ],
                      ),
                      SizedBox(height: 16),
                      DatePickerField(
                        question: 'Year of birth of $name',
                      ),
                      const SizedBox(height: 16),
                      RadioButtonField(
                        question: 'Does $name have a birth certificate?',
                        options: [
                          'Yes ',
                          'No',
                        ],
                      ),
                      DropdownField(
                        question: 'Work/main occupation of $name',
                        options: [
                          'Farmer (cocoa)',
                          'Farmer (coffee)',
                          'Farmer (other)',
                          'Merchant',
                          'Student',
                          'Other (to specify)',
                          'No activity',
                        ],
                      ),
                      ..._buildQuestionFields([
                        'Other to specify',
                      ]),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _buildQuestionFields(List<String> questions) {
  return questions
      .map((question) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: QuestionField(question: question),
          ))
      .toList();
}

class QuestionField extends StatelessWidget {
  final String question;

  const QuestionField({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),
        ),
      ],
    );
  }
}
