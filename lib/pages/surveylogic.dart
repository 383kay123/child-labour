import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/fields/dropcheckbox.dart';
import 'package:surveyflow/fields/questionfield.dart';
import 'package:surveyflow/fields/radiobuttons.dart';
import 'package:surveyflow/pages/childrenquestions.dart';
import 'package:surveyflow/surveymodel.dart';
// This implementation provides the logic for the Children of Household survey form
// It handles field visibility, validation, skip patterns, and data consistency

class SurveyLogic {
  // Main form state object to track all responses
  final Map<String, dynamic> formState = {
    'canChildBeSurveyed': null,
    'surveyNotPossibleReasons': <String>[], // Explicitly type as List<String>
    'showSurveyNotPossibleReasons': false,
    'otherReason': '', // Stores user input for "Other reasons"
    'showOtherReasonField': false, // Controls visibility of "Other reasons"
  };

// Update the updateValue method to handle List<String> for surveyNotPossibleReasons
  void updateValue(String fieldName, dynamic value) {
    if (fieldName == 'surveyNotPossibleReasons') {
      formState[fieldName] = List<String>.from(value);
    } else {
      formState[fieldName] = value;
    }
    updateVisibility();
    validateField(fieldName);
  }

  // Form sections visibility tracking
  final Map<String, bool> sectionVisibility = {
    'basicInfo': true,
    'birthInfo': true,
    'householdRelationship': true,
    'parentalInfo': true,
    'educationInfo': true,
    'schoolAttendance': false,
    'nonSchoolReason': false,
    'workActivities': true,
    'lightTasksSection': false,
  };

  // Initialize form with default visibility and validation rules
  void initializeForm() {
    // Set initial visible sections based on form design
    updateVisibility();
  }

  // Main logic for determining field and section visibility
  void updateVisibility() {
    // Child availability logic
    bool childAvailable = formState['canChildBeSurveyed'] == 'Yes';
    sectionVisibility['unavailabilityReasons'] = !childAvailable;

    if (formState['canChildBeSurveyed'] == 'No') {
      // Show the checkbox field for reasons
      formState['showSurveyNotPossibleReasons'] = true;
    } else {
      // Hide and clear selection
      formState['showSurveyNotPossibleReasons'] = false;
      formState['surveyNotPossibleReasons'] = [];
      formState['showOtherReasonField'] = false;
      formState['otherReason'] = '';
    }

    // Proxy respondent logic - only show if child not available
    bool showProxyFields = !childAvailable;
    sectionVisibility['proxyRespondent'] = showProxyFields;

    // Birth certificate logic
    bool hasBirthCertificate = formState['hasBirthCertificate'] == 'Yes';
    sectionVisibility['noBirthCertificateReason'] = !hasBirthCertificate;

    // Birth location logic
    String birthLocation = formState['birthLocation'] ?? '';
    bool bornInAnotherCountry =
        birthLocation == 'No, he was born in another country';
    sectionVisibility['birthCountry'] = bornInAnotherCountry;

    // Relationship logic - only show "other" field if "Other" is selected
    bool showOtherRelationship =
        formState['relationshipToHead'] == 'Other (to specify)';
    sectionVisibility['otherRelationship'] = showOtherRelationship;

    // Non-family living logic
    bool notLivingWithFamily = !['Son/daughter', 'Grandson/granddaughter']
        .contains(formState['relationshipToHead']);
    sectionVisibility['reasonNotWithFamily'] = notLivingWithFamily;

    // Child placement decision logic
    bool showOtherDecisionMaker =
        formState['childPlacementDecider'] == 'Other(specify)';
    sectionVisibility['otherDecisionMaker'] = showOtherDecisionMaker;

    // Parental contact logic
    bool hasParentalContact = formState['parentalContactLastYear'] == 'Yes';
    sectionVisibility['lastParentalContact'] = hasParentalContact;

    // Child accompaniment logic
    bool showOtherAccompaniment = formState['childAccompaniment'] == 'Other';
    sectionVisibility['otherAccompaniment'] = showOtherAccompaniment;

    // Father residence logic
    bool fatherAbroad = formState['fatherResidence'] == 'Abroad';
    sectionVisibility['fatherCountry'] = fatherAbroad;
    bool otherFatherCountry =
        formState['fatherCountry'] == 'Others to be specified';
    sectionVisibility['otherFatherCountry'] = otherFatherCountry;

    // Mother residence logic
    bool motherAbroad = formState['motherResidence'] == 'Abroad';
    sectionVisibility['motherCountry'] = motherAbroad;
    bool otherMotherCountry =
        formState['motherCountry'] == 'Others to be specified';
    sectionVisibility['otherMotherCountry'] = otherMotherCountry;

    // Education enrollment logic
    bool currentlyEnrolled = formState['currentlyEnrolled'] == 'Yes';
    sectionVisibility['schoolInfo'] = currentlyEnrolled;
    sectionVisibility['schoolAttendance'] = currentlyEnrolled;

    // Previous education logic
    bool everBeenToSchool =
        formState['everBeenToSchool'] == 'Yes, they went to school but stopped';
    sectionVisibility['schoolLeavingYear'] = everBeenToSchool;
    sectionVisibility['reasonLeftSchool'] = everBeenToSchool;

    bool neverBeenToSchool =
        formState['everBeenToSchool'] == 'No, they have never been to school';
    sectionVisibility['reasonNeverAttended'] = neverBeenToSchool;

    // Recent school attendance logic
    bool recentSchoolAttendance = formState['attendedLast7Days'] == 'Yes';
    sectionVisibility['missedSchoolDays'] = recentSchoolAttendance;
    sectionVisibility['reasonNoSchoolLast7Days'] = !recentSchoolAttendance;

    // Missed school days logic
    bool missedSchoolDays = formState['missedSchoolDays'] == 'Yes';
    sectionVisibility['reasonMissedSchool'] = missedSchoolDays;

    // Work activities logic
    bool workedInHouse = formState['workedInHouseLast7Days'] == 'Yes';
    bool workedOnCocoaFarm = formState['workedOnCocoaFarmLast7Days'] == 'Yes';
    sectionVisibility['workFrequency'] = workedInHouse || workedOnCocoaFarm;

    // Light tasks section logic
    bool performedLightTasks =
        (formState['lightTasksPerformed'] ?? []).isNotEmpty;
    sectionVisibility['lightTasksSection'] = performedLightTasks;

    // Remuneration logic
    bool receivedRemuneration = formState['receivedRemuneration'] == 'Yes';
    sectionVisibility['remunerationDetails'] = receivedRemuneration;
  }

  // Validate a specific field based on rules
  Map<String, String?> validateField(String fieldName) {
    Map<String, String?> errors = {};

    switch (fieldName) {
      case 'childFirstName':
      case 'childSurname':
        if (formState[fieldName] == null ||
            formState[fieldName].toString().trim().isEmpty) {
          errors[fieldName] = 'This field is required';
        }
        break;

      case 'yearOfBirth':
        int? birthYear = int.tryParse(formState[fieldName]?.toString() ?? '');
        int currentYear = DateTime.now().year;
        if (birthYear == null) {
          errors[fieldName] = 'Please enter a valid year';
        } else if (birthYear < currentYear - 18 || birthYear > currentYear) {
          errors[fieldName] =
              'Birth year must be between ${currentYear - 18} and $currentYear';
        }
        break;

      case 'schoolLeavingYear':
        int? leavingYear = int.tryParse(formState[fieldName]?.toString() ?? '');
        int currentYear = DateTime.now().year;
        if (leavingYear == null) {
          errors[fieldName] = 'Please enter a valid year';
        } else if (leavingYear < currentYear - 15 ||
            leavingYear > currentYear) {
          errors[fieldName] =
              'School leaving year must be between ${currentYear - 15} and $currentYear';
        }
        break;

      case 'lightTaskHoursNonSchoolDays':
        int? hours = int.tryParse(formState[fieldName]?.toString() ?? '');
        if (hours == null) {
          errors[fieldName] = 'Please enter a valid number';
        } else if (hours < 0 || hours > 168) {
          // 24 hours * 7 days = 168 max hours per week
          errors[fieldName] = 'Hours must be between 0 and 168';
        }
        break;
    }

    return errors;
  }

  // Check for inconsistencies in the form data
  List<String> checkDataConsistency() {
    List<String> inconsistencies = [];

    // Check age consistency with educational level
    int? birthYear = int.tryParse(formState['yearOfBirth']?.toString() ?? '');
    int currentYear = DateTime.now().year;
    int age = birthYear != null ? currentYear - birthYear : 0;

    String educationLevel = formState['educationLevel'] ?? '';
    if (age < 5 &&
        educationLevel != 'Not applicable' &&
        educationLevel != 'Pre-school (Kindergarten)') {
      inconsistencies.add('Child\'s age and education level seem inconsistent');
    }

    // Check if child in school matches with education enrollment status
    bool currentlyEnrolled = formState['currentlyEnrolled'] == 'Yes';
    bool attendedLast7Days = formState['attendedLast7Days'] == 'Yes';
    if (currentlyEnrolled &&
        !attendedLast7Days &&
        formState['reasonNoSchoolLast7Days'] == null) {
      inconsistencies.add(
          'Child is enrolled but didn\'t attend school in last 7 days - reason required');
    }

    // Check work hours consistency
    String longestWorkTime = formState['longestLightDutyTimeNonSchool'] ?? '';
    int? totalHours = int.tryParse(
        formState['lightTaskHoursNonSchoolDays']?.toString() ?? '');

    if (longestWorkTime == 'More than 8 hours' &&
        totalHours != null &&
        totalHours < 8) {
      inconsistencies
          .add('Longest work time and total hours reported are inconsistent');
    }

    return inconsistencies;
  }

  // Get calculated fields
  Map<String, dynamic> getCalculatedFields() {
    Map<String, dynamic> calculatedFields = {};

    // Calculate child's age
    int? birthYear = int.tryParse(formState['yearOfBirth']?.toString() ?? '');
    int currentYear = DateTime.now().year;
    calculatedFields['childAge'] =
        birthYear != null ? currentYear - birthYear : null;

    // Calculate status - whether child is at risk based on multiple factors
    bool atRisk = false;

    // Child not in school and under 15
    if (formState['currentlyEnrolled'] == 'No' &&
        calculatedFields['childAge'] != null &&
        calculatedFields['childAge'] < 15) {
      atRisk = true;
    }

    // Child working on cocoa farm
    if (formState['workedOnCocoaFarmLast7Days'] == 'Yes') {
      atRisk = true;
    }

    // Child working long hours
    String longestWorkTime = formState['longestLightDutyTimeNonSchool'] ?? '';
    if (['6-8 hours', 'More than 8 hours'].contains(longestWorkTime)) {
      atRisk = true;
    }

    calculatedFields['childAtRisk'] = atRisk;

    return calculatedFields;
  }

  // Submit form logic - perform final validation before submission
  Map<String, dynamic> prepareSubmission() {
    // Perform all validations
    Map<String, String?> allErrors = {};
    formState.keys.forEach((field) {
      Map<String, String?> fieldErrors = validateField(field);
      allErrors.addAll(fieldErrors);
    });

    // Check consistency
    List<String> inconsistencies = checkDataConsistency();

    // Add calculated fields
    Map<String, dynamic> calculatedFields = getCalculatedFields();

    // Prepare final submission data
    Map<String, dynamic> submissionData = {
      'formData': {...formState},
      'calculatedFields': calculatedFields,
      'validationErrors': allErrors,
      'dataInconsistencies': inconsistencies,
      'isValid': allErrors.isEmpty && inconsistencies.isEmpty,
    };

    return submissionData;
  }
}

// Example implementation of form interaction in Flutter
class ChildrenOfHouseholdPage extends StatefulWidget {
  @override
  _ChildrenOfHouseholdPageState createState() =>
      _ChildrenOfHouseholdPageState();
}

class _ChildrenOfHouseholdPageState extends State<ChildrenOfHouseholdPage> {
  final SurveyLogic surveyLogic = SurveyLogic();

  void onFieldChanged(String fieldName, dynamic value) {
    setState(() {
      surveyLogic.updateValue(fieldName, value);
    });
  }

  List<Widget> getQuestionWidgets() {
    return [
      Column(
        children: [
          RadioButtonField(
            question:
                "Are there children living in the respondent's household ?",
            options: ['Yes', 'No'],
            value: surveyLogic.formState['isChildOfFarmer'],
            onChanged: (value) {
              onFieldChanged('isChildOfFarmer', value);
              if (value == 'No') {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text('Survey End'),
                    content: Text(
                        'No children in household. Survey cannot continue.'),
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
          if (surveyLogic.formState['isChildOfFarmer'] == 'Yes')
            Column(
              children: [
                SizedBox(height: 20),
                QuestionField(
                  question:
                      'Out of the number of children stated above, How many are between the ages of 5 and 17?',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    onFieldChanged('childrenBetween5And17', value);
                  },
                  cautionText:
                      "Required. Count the producer's children as well as other children living in the farmer's household",
                ),
                if (surveyLogic.formState['childrenBetween5And17'] != null)
                  Column(
                    children: List.generate(
                      int.tryParse(surveyLogic
                              .formState['childrenBetween5And17']
                              .toString()) ??
                          0,
                      (index) => Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF006A4E),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildQuestionsPage(
                                  childNumber: index + 1,
                                  totalChildren: int.parse(surveyLogic
                                      .formState['childrenBetween5And17']),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Children of the household ${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isNoSelected = surveyLogic.formState['isChildOfFarmer'] == 'No';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: isNoSelected ? Color(0xFF006A4E) : Colors.blue,
        title: Text(
          'Children of the Household',
          style: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: getQuestionWidgets(),
          ),
        ),
      ),
    );
  }
}
// Let's also define the widget components used in the form
// These are simplified versions - you'll need to implement them fully

class CheckboxField extends StatelessWidget {
  final String question;
  final List<String> options;
  final List<dynamic> value; // Changed to List<dynamic>
  final Function(List<String>) onChanged;

  const CheckboxField({
    Key? key,
    required this.question,
    required this.options,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question),
        ...options.map((option) => CheckboxListTile(
              title: Text(option),
              value: value.contains(option),
              onChanged: (bool? checked) {
                if (checked == true) {
                  if (!value.contains(option)) {
                    onChanged([...value.map((e) => e.toString()), option]);
                  }
                } else {
                  onChanged(value
                      .where((item) => item != option)
                      .map((e) => e.toString())
                      .toList());
                }
              },
            )),
        SizedBox(height: 16),
      ],
    );
  }
}

class DropdownField extends StatelessWidget {
  final String question;
  final List<String> options;
  final String? value;
  final Function(String) onChanged;

  const DropdownField({
    super.key,
    required this.question,
    required this.options,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8), // Adds spacing between question and dropdown
        SizedBox(
          height: 50, // Ensures the dropdown doesn't overlap the question
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
            hint: Text('Select an option'),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class DatePickerField extends StatefulWidget {
  final String childFirstName;
  final String childSurname;

  const DatePickerField({
    super.key,
    required this.childFirstName,
    required this.childSurname,
  });

  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015),
      firstDate: DateTime(2007),
      lastDate: DateTime(2020),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF00754B),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00754B),
              onPrimary: Colors.white,
              onSurface: Colors.black54,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00754B),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String childName = "${widget.childFirstName} ${widget.childSurname}".trim();
    String question = "Year of birth of $childName";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(
              selectedDate == null
                  ? "Select Date"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: selectedDate == null
                    ? const Color(0xFF00754B)
                    : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
