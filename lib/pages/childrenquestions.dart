import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/fields/dropcheckbox.dart';
import 'package:surveyflow/fields/questionfield.dart';
import 'package:surveyflow/fields/radiobuttons.dart';
import 'package:surveyflow/pages/surveylogic.dart';

class ChildQuestionsPage extends StatefulWidget {
  final int? childNumber;
  final int? totalChildren;

  const ChildQuestionsPage({
    super.key,
    this.childNumber,
    this.totalChildren,
  });
  @override
  _ChildQuestionsPageState createState() => _ChildQuestionsPageState();
}

class _ChildQuestionsPageState extends State<ChildQuestionsPage> {
  final SurveyLogic surveyLogic = SurveyLogic();

  void onFieldChanged(String fieldName, dynamic value) {
    setState(() {
      surveyLogic.updateValue(fieldName, value);
    });
  }

  // Helper method to check if we should show the "Why does the child not live with family" question
  bool shouldShowFamilyQuestion(int childNumber) {
    // Show the question for "Other (to specify)", "Child of the worker", or "Child of the farm owner"
    if (surveyLogic.formState['hh_head$childNumber']?["Other (to specify)"] ==
            true ||
        surveyLogic.formState['hh_head$childNumber']?["Child of the worker"] ==
            true ||
        surveyLogic.formState['hh_head$childNumber']?[
                "Child of the farm owner(only if the respondent is the caretaker)"] ==
            true) {
      return true;
    }

    // Don't show for any other relationship options
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF006A4E),
        title: Text(
          'Children of the Household',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              RadioButtonField(
                question:
                    "Is the child among the list of children declared in the cover to be the farmers children?",
                cautionText:
                    "Check the farmer children already captured field in the cover to confirm.",
                options: ["Yes", "No"],
                value: surveyLogic
                    .formState['isChildDeclared_${widget.childNumber}'],
                onChanged: (value) {
                  onFieldChanged(
                      'isChildDeclared_${widget.childNumber}', value);
                },
              ),
              // Show "Enter the number..." only if "Yes" is selected
              if (surveyLogic
                      .formState['isChildDeclared_${widget.childNumber}'] ==
                  'Yes')
                Column(children: [
                  SizedBox(height: 20),
                  QuestionField(
                    question:
                        "Enter the number attached to the child name in the cover so we can identify the child in question.",
                    keyboardType: TextInputType.number,
                    cautionText:
                        "Check the farmer children already captured field in the cover to confirm. Input the number attached to the child name in question",
                    onChanged: (value) {
                      onFieldChanged(
                          'childnumber_${widget.childNumber}', value);
                    },
                  ),
                ]),

              // This section will always show regardless if "Yes" or "No" is selected
              if (surveyLogic
                          .formState['isChildDeclared_${widget.childNumber}'] ==
                      'Yes' ||
                  surveyLogic
                          .formState['isChildDeclared_${widget.childNumber}'] ==
                      'No')
                Column(children: [
                  SizedBox(height: 20),
                  RadioButtonField(
                    question: "Can the child be surveyed now",
                    options: ["Yes", "No"],
                    value: surveyLogic
                        .formState['canBeSurveyed_${widget.childNumber}'],
                    onChanged: (value) {
                      onFieldChanged(
                          'canBeSurveyed_${widget.childNumber}', value);
                    },
                  ),
                  if (surveyLogic
                          .formState['canBeSurveyed_${widget.childNumber}'] ==
                      'No')
                    Column(
                      children: [
                        SizedBox(height: 20),
                        DropdownCheckboxField(
                          question: "If No, what are the reasons?",
                          options: [
                            "The child is at school",
                            "The child has gone to work on the cocoa farm",
                            "Child is busy doing housework",
                            "Child works outside the household",
                            "The child is too young",
                            "The child is sick",
                            "The child has travelled",
                            "The child has gone out to play",
                            "The child is sleeping",
                            "Other reasons",
                          ],
                          onChanged: (Map<String, bool> selectedOptions) {
                            setState(() {
                              surveyLogic.updateValue(
                                  'reasons_${widget.childNumber}',
                                  selectedOptions);
                            });
                          },
                          singleSelect: true,
                        ),
                        if (surveyLogic
                                    .formState['reasons_${widget.childNumber}']
                                ?["Other reasons"] ==
                            true)
                          QuestionField(
                            question: "Other reasons",
                            cautionText: "In capital letters",
                            keyboardType: TextInputType.text,
                            onChanged: (value) {
                              onFieldChanged(
                                  'otherReasons_${widget.childNumber}', value);
                            },
                          ),
                        SizedBox(height: 20),
                        DropdownCheckboxField(
                          question:
                              "Who is answering for the child since he/she is not available?",
                          options: [
                            "The parents or legal guardians",
                            "Another family member of the child",
                            "One of the child's siblings",
                            "Other",
                          ],
                          onChanged: (Map<String, bool> selectedOptions) {
                            setState(() {
                              surveyLogic.updateValue(
                                  'answering_${widget.childNumber}',
                                  selectedOptions);
                            });
                          },
                          singleSelect: true,
                        ),
                        if (surveyLogic.formState[
                                'answering_${widget.childNumber}']?["Other"] ==
                            true)
                          QuestionField(
                              question: "In other, please specify",
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                onFieldChanged(
                                    'otherAnswering_${widget.childNumber}',
                                    value);
                              }),
                      ],
                    ),
                  Column(children: [
                    SizedBox(height: 20),
                    QuestionField(
                      question: "Child's first name",
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        onFieldChanged(
                            'childFirstName_${widget.childNumber}', value);
                      },
                    ),
                    if (surveyLogic
                            .formState['childFirstName_${widget.childNumber}']
                            ?.isNotEmpty ??
                        false) ...[
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      const SizedBox(height: 20),
                      QuestionField(
                        question: "Child's surname",
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          onFieldChanged(
                              'childSurName_${widget.childNumber}', value);
                        },
                      ),
                      if (surveyLogic
                              .formState['childSurName_${widget.childNumber}']
                              ?.isNotEmpty ??
                          false) ...[
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        const SizedBox(height: 20),
                        RadioButtonField(
                          question: "Gender of Child ${widget.childNumber}?",
                          cautionText: 'Mandatory',
                          options: ["Boy", "Girl"],
                          value: surveyLogic
                              .formState['child_gender${widget.childNumber}'],
                          onChanged: (value) {
                            onFieldChanged(
                                'child_gender${widget.childNumber}', value);
                          },
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        const SizedBox(height: 20),
                        // Main container for birth year and subsequent questions
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Year of birth picker
                              Text(
                                "Year of birth of Child ${widget.childNumber}?",
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Mandatory. Our target for this survey is 'Children ages 5-17'.Therefore, the year of birth must be between 2007 and 2020",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Year picker container
                              InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: Text('Select Year of Birth',
                                          style: GoogleFonts.poppins()),
                                      content: SizedBox(
                                        height: 300,
                                        width: 300,
                                        child: YearPicker(
                                          firstDate: DateTime(2007),
                                          lastDate: DateTime(2020),
                                          selectedDate: DateTime.now(),
                                          onChanged: (DateTime dateTime) {
                                            setState(() {
                                              onFieldChanged(
                                                  'childBirthYear_${widget.childNumber}',
                                                  dateTime.year.toString());
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Color(0xFF006A4E)),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        surveyLogic.formState[
                                                'childBirthYear_${widget.childNumber}'] ??
                                            'Select Year',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: surveyLogic.formState[
                                                      'childBirthYear_${widget.childNumber}'] !=
                                                  null
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: surveyLogic.formState[
                                                      'childBirthYear_${widget.childNumber}'] !=
                                                  null
                                              ? Color(0xFF006A4E)
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              color: Color(0xFF006A4E),
                                              size: 20),
                                          SizedBox(width: 8),
                                          if (surveyLogic.formState[
                                                  'childBirthYear_${widget.childNumber}'] !=
                                              null)
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  onFieldChanged(
                                                      'childBirthYear_${widget.childNumber}',
                                                      null);
                                                });
                                              },
                                              child: Icon(Icons.clear,
                                                  color: Color(0xFF006A4E),
                                                  size: 20),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Birth certificate section appears after year selection
                              if (surveyLogic.formState[
                                      'childBirthYear_${widget.childNumber}'] !=
                                  null) ...[
                                const SizedBox(height: 20),
                                const Divider(
                                    height: 1, color: Color(0xFFE0E0E0)),
                                const SizedBox(height: 20),
                                // Birth certificate questions
                                Column(
                                  children: [
                                    RadioButtonField(
                                      question:
                                          "Does child ${widget.childNumber} have a birth certificate?",
                                      cautionText: "Mandatory",
                                      options: ["Yes", "No"],
                                      value: surveyLogic.formState[
                                          'child_birth_certificates${widget.childNumber}'],
                                      onChanged: (value) {
                                        onFieldChanged(
                                            'child_birth_certificates${widget.childNumber}',
                                            value);
                                      },
                                    ),
                                    if (surveyLogic.formState[
                                            'child_birth_certificates${widget.childNumber}'] ==
                                        'Yes') ...[
                                      const SizedBox(height: 20),
                                      const Divider(
                                          height: 1, color: Color(0xFFE0E0E0)),
                                      const SizedBox(height: 20),
                                      DropdownCheckboxField(
                                        question:
                                            "Is child ${widget.childNumber} born in this community?",
                                        cautionText: "Mandatory",
                                        options: [
                                          "Yes",
                                          "No, he was born in this district but different community within the district",
                                          "No, he was born in this region but different district within the region",
                                          "No, he was born in another region of Ghana",
                                          "No, he was born in another country",
                                        ],
                                        onChanged: (Map<String, bool>
                                            selectedOptions) {
                                          setState(() {
                                            surveyLogic.updateValue(
                                                'child_community${widget.childNumber}',
                                                selectedOptions);
                                          });
                                        },
                                        singleSelect: true,
                                      ),
                                    ],
                                    if (surveyLogic.formState[
                                            'child_birth_certificates${widget.childNumber}'] ==
                                        'No') ...[
                                      const SizedBox(height: 20),
                                      const Divider(
                                          height: 1, color: Color(0xFFE0E0E0)),
                                      const SizedBox(height: 20),
                                      QuestionField(
                                        question: "If No, please specify why",
                                        cautionText: "Mandatory",
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          onFieldChanged(
                                              'child_birth_certificates_why${widget.childNumber}',
                                              value);
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      DropdownCheckboxField(
                                        question:
                                            "Is child ${widget.childNumber} born in this community?",
                                        cautionText: "Mandatory",
                                        options: [
                                          "Yes",
                                          "No, he was born in this district but different community within the district",
                                          "No, he was born in this region but different district within the region",
                                          "No, he was born in another region of Ghana",
                                          "No, he was born in another country",
                                        ],
                                        onChanged: (Map<String, bool>
                                            selectedOptions) {
                                          setState(() {
                                            surveyLogic.updateValue(
                                                'child_community${widget.childNumber}',
                                                selectedOptions);
                                          });
                                        },
                                        singleSelect: true,
                                      ),
                                    ],
                                  ],
                                )
                              ],
                            ],
                          ),
                        )
                      ]
                    ]
                  ])
                ]),
              if (surveyLogic.formState['child_community${widget.childNumber}']
                      ?["No, he was born in another country"] ==
                  true)
                DropdownCheckboxField(
                  question:
                      "In which country was child ${widget.childNumber} born?",
                  cautionText: 'Mandatory',
                  options: [
                    "Benin",
                    "Burkina Faso",
                    "Ivory Coast",
                    "Mali",
                    "Niger",
                    "Togo",
                    "Other",
                  ],
                  onChanged: (Map<String, bool> selectedOptions) {
                    setState(() {
                      surveyLogic.updateValue(
                          'child_birthCountry${widget.childNumber}',
                          selectedOptions);
                    });
                  },
                  singleSelect: true,
                ),
              if (surveyLogic
                      .formState['child_community${widget.childNumber}']?.values
                      .contains(true) ??
                  false)
                DropdownCheckboxField(
                  question:
                      'Relationship of child ${widget.childNumber} to the head of the household',
                  options: [
                    'Son/daughter',
                    'Brother/sister',
                    'Son-in-law/daughter-in-law',
                    'Grandson/granddaughter',
                    'Niece/nephew',
                    'Cousin',
                    'Child of the worker',
                    'Child of the farm owner(only if the respondent is the caretaker)',
                    'Other (to specify)',
                  ],
                  onChanged: (Map<String, bool> selectedOptions) {
                    setState(() {
                      surveyLogic.updateValue(
                          'hh_head${widget.childNumber}', selectedOptions);
                    });
                  },
                  singleSelect: true,
                ),
              // Only show the "Please specify the relationship" text field if "Other" is selected
              if (surveyLogic.formState['hh_head${widget.childNumber}']
                      ?["Other (to specify)"] ==
                  true) ...[
                const SizedBox(height: 20),
                QuestionField(
                  question: "Please specify the relationship",
                  cautionText: "Mandatory",
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    onFieldChanged('hh_head_other${widget.childNumber}', value);
                  },
                ),
              ],
              // Show the family question if any of the specified options are selected
              if (widget.childNumber != null &&
                  shouldShowFamilyQuestion(widget.childNumber!)) ...[
                const SizedBox(height: 20),
                DropdownCheckboxField(
                  question:
                      'Why does the child ${widget.childNumber} not live with his/her family',
                  options: [
                    'Parents deceased',
                    'Cant take care of me',
                    'Abandoned',
                    'School reasons',
                    'A recruitment agency brought me here',
                    'I did not want to live with my parents',
                    'Other (to specify)',
                    'Dont know',
                  ],
                  onChanged: (Map<String, bool> selectedOptions) {
                    setState(() {
                      surveyLogic.updateValue(
                          'child_parent${widget.childNumber}', selectedOptions);
                    });
                  },
                  singleSelect: true,
                ),
              ],
              if (surveyLogic.formState['child_parent${widget.childNumber}']
                      ?["Other (to specify)"] ==
                  true)
                QuestionField(
                  question: "Other reasons",
                  cautionText: 'IN CAPITAL LETTERS',
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    onFieldChanged(
                        'child_parentOther${widget.childNumber}', value);
                  },
                ),

              if (surveyLogic.formState['child_parent${widget.childNumber}'] !=
                      null &&
                  surveyLogic.formState['child_parent${widget.childNumber}']!
                      .containsValue(true) &&
                  surveyLogic.formState['child_parent${widget.childNumber}']![
                          "Parents deceased"] !=
                      true &&
                  surveyLogic.formState['child_parent${widget.childNumber}']![
                          "Other (to specify)"] !=
                      true)
                DropdownCheckboxField(
                  question:
                      'Who decided that the child ${widget.childNumber} to come into the household?',
                  options: [
                    'Myself',
                    'Father/Mother',
                    'Grandparents',
                    'Other family members',
                    'An external recruiter or agency external',
                    'Other(specify)',
                  ],
                  onChanged: (Map<String, bool> selectedOptions) {
                    setState(() {
                      surveyLogic.updateValue(
                          'child_family_decided${widget.childNumber}',
                          selectedOptions);
                    });
                  },
                  singleSelect: true,
                ),
              if (surveyLogic.formState[
                      'child_birth_certificates${widget.childNumber}'] ==
                  'No')
                QuestionField(
                  question: "If No, please specify why",
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    onFieldChanged(
                        'child_birth_certificates_why${widget.childNumber}',
                        value);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
