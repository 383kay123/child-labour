import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/fields/checkbox.dart';
import 'package:surveyflow/fields/datepickerfield.dart';
import 'package:surveyflow/fields/dropdown.dart';
import 'package:surveyflow/fields/gpsfield.dart';
import 'package:surveyflow/fields/image_picker.dart';
import 'package:surveyflow/fields/radiobuttons.dart';
import 'package:surveyflow/pages/Consent.dart';
import 'package:surveyflow/pages/cover.dart';
import 'package:surveyflow/pages/endcollection.dart';
import 'package:surveyflow/pages/remediation.dart';
import 'package:surveyflow/pages/sensitization.dart';

class Farmerident extends StatelessWidget {
  const Farmerident({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FARM IDENTIFICATION',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF006A4E),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync,
                color: Colors.white), // Change the icon here
            onPressed: () {
              // Add functionality here
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: 140, // Adjust this height as needed
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF00754B),
                ),
                child: Align(
                  alignment: Alignment.centerLeft, // Align text to the left
                  child: Text(
                    'REVIEW GHA - CLMRS Household profiling - 24-25',
                    style: GoogleFonts.poppins(
                      fontSize: 14, // Reduce font size if needed
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(
                'COVER',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Questionnaire()),
                );
              },
            ),
            ListTile(
              title: Text(
                'CONSENT AND LOCATION',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Consent()),
                );
              },
            ),
            ListTile(
              title: Text(
                'FARMER IDENTIFICATION',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Farmerident()),
                );
              },
            ),
            ListTile(
              title: Text(
                'REMEDIATION',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Remediation()),
                );
              },
            ),
            ListTile(
              title: Text(
                'SENSITIZATION',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Sensitization()),
                );
              },
            ),
            ListTile(
              title: Text(
                'END OF COLLECTION',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Endcollection()),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: 70), // Add padding to make room for bottom buttons
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Fill out the survey',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RadioButtonField(
                      question: 'Is the name of the respondent correct?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'If No, fill in the exact name and surname of the producer?',
                    ]),
                    RadioButtonField(
                      question: 'What is the nationality of the respondent?',
                      options: [
                        'Ghanaian',
                        'Non Ghanaian',
                      ],
                    ),
                    DropdownField(
                      question:
                          'If Non Ghanaian, specify the country of origin',
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
                        'Other (to be specified)',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to Specify',
                    ]),
                    RadioButtonField(
                      question: 'Is the respondent the owner of the farm?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    RadioButtonField(
                      question: 'Which of these best describes you?',
                      options: [
                        'Complete Owner',
                        'Sharecropper',
                        'Owner/Sharecropper',
                      ],
                    ),
                    RadioButtonField(
                      question: 'Which of these best describes you?',
                      options: [
                        'Caretaker/Manager of the Farm',
                        'Sharecropper',
                      ],
                    ),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1.5, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'IDENTIFICATION OF THE OWNER',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    ..._buildQuestionFields([
                      'Name of the owner?',
                    ]),
                    ..._buildQuestionFields([
                      'First name of the owner?',
                    ]),
                    RadioButtonField(
                      question: 'What is the nationality of the owner?',
                      options: [
                        'Ghanaian',
                        'Non Ghanaian',
                      ],
                    ),
                    DropdownField(
                      question:
                          'If Non Ghanaian, please indicate the country they are from',
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
                        'Other (to be specified)',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to Specify',
                    ]),
                    ..._buildQuestionFields([
                      'For how many years has the respondent been working for the owner?',
                    ]),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1.5, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'WORKERS IN THE FARM',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    RadioButtonField(
                      question:
                          'Have you recruited at least one worker during the past year?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    CheckboxField(
                      question: "Do you recruit workers for...",
                      options: [
                        "Permanent Labor",
                        "Casual labor",
                      ],
                    ),
                    DropdownField(
                      question:
                          'What king of agreement do you have with your workers?',
                      options: [
                        'Verbal agreement without witness',
                        'Verbal agreement with witness',
                        'Written agreement without witness',
                        'Written contract with witness',
                        'Other (specify)'
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to Specify',
                    ]),
                    RadioButtonField(
                      question:
                          'Were the tasks to be performed by the worker clarified with them during the recruitment?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'Does the worker perform tasks for you or your family members other than those agreed upon?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    DropdownField(
                      question:
                          'What do you do when a worker refuses to perform a task?',
                      options: [
                        'I find a compromise',
                        'I withdraw part of their salary',
                        'I issue a warning',
                        'Other',
                        'Not applicable',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to Specify',
                    ]),
                    DropdownField(
                      question: 'Do your workers receive their full salaries?',
                      options: [
                        'Always',
                        'Sometimes',
                        'Rarely',
                        'Never',
                      ],
                    ),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1.5, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'For the following section, please read the statements to the respondent, and ask him/her if he/she agrees or disagrees.',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RadioButtonField(
                      question:
                          'It is acceptable to recruit someone for work without their consent',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'It is acceptable for a person who cannot pay their debts to work for the creditor to reimburse the debt.',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'It is acceptable for an employer not to reveal the true nature of the work during the recruitment.',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'A worker is obliged to work whenever he is called upon by his employer',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    RadioButtonField(
                      question: 'A worker is not entitled to move freely',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'A worker must be free to communicate with his or her family and friends',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'A worker is obliged to adapt to any living conditions imposed by the employer',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'It is acceptable for an employer and their family to interfere in a workers private life',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'A worker should not have the freedom to leave work whenever they wish',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'A worker should be required to stay longer than expected while waiting for unpaid salary',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'A worker should not be able to leave their employer when they owe money to their employer',
                      options: [
                        'Agree',
                        'Disagree',
                      ],
                    ),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1.5, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'ADULT OF THE RESPONDENTS HOUSEHOLD',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'INFORMATIONS ON THE ADULTS LIVING IN THE HOUSEHOLD',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ..._buildQuestionFields([
                      'Total number of adults in the household(producer/manager/owner not included)',
                    ]),
                    ..._buildQuestionFields([
                      'Full  name of household members',
                    ]),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'ADULT OF THE RESPONDENTS HOUSEHOLD/ INFORMATIONS ON THE ADULTS LIVING IN THE HOUSEHOLD',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 10),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Tableau: PRODUCERS/MANAGERS HOUSEHOLD INFRORMATION - %ROSTERTITLE%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DropdownField(
                      question:
                          'Relationship of %rostertitle% to the respondent (Farmer/Manager/CareTaker)',
                      options: [
                        'Husband/wife',
                        'Son/daughter',
                        'Brother/sister',
                        'Son-in-law/daughter-in-law',
                        'Grandson/granddaughter',
                        'Niece/nephew',
                        'Cousin',
                        'A workers family member',
                        'Worker',
                        'Father/Mother',
                        'Other (to specify)',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to specify',
                    ]),
                    Text(
                      'Make sure to interview the Worker or Family of the Worker should any of these 2 be selected above',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          fontStyle: FontStyle.italic),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RadioButtonField(
                      question: 'Gender of %rostertitle%',
                      options: [
                        'Male',
                        'Female',
                      ],
                    ),
                    RadioButtonField(
                      question: 'Nationality of %rostertitle%',
                      options: [
                        'Ghanaian',
                        'Non Ghanaian',
                      ],
                    ),
                    DropdownField(
                      question:
                          'If Non Ghanaian, please specify the country of origin',
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
                        'Other (to be specified)',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to specify',
                    ]),
                    ..._buildQuestionFields([
                      'Year of birth of %rostertitle%',
                    ]),
                    RadioButtonField(
                      question: 'Does %rostertitle% have a birth certificate?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    DropdownField(
                      question: 'Work/ main  occupation of %rostertitle%',
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
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1.5, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'CHILDREN OF THE HOUSEHOLD',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    RadioButtonField(
                      question:
                          'Are there children livng in the respondents household?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Out of the number of children stated above, How many are between the ages of 5 and 17?',
                    ]),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1.5, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'CHILDREN OF THE HOUSEHOLD',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 10),
                    ),
                    Text(
                      'Tableau: CHILDREN OF THE HOUSEHOLD - %ROSTERTITLE%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RadioButtonField(
                      question:
                          'Is the child among the list of children declared in the cover to be the farmers children',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Enter the number attached to the child name in the cover so we can identify the child in question',
                    ]),
                    RadioButtonField(
                      question: 'Can the child be surveyed now?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    CheckboxField(
                      question: 'If not, what are the reasons?',
                      options: [
                        'The child is at school',
                        'The child has gobe to work on the cocoa farm',
                        'Child is busy doing homework',
                        'Child works outside the household',
                        'The child is too young',
                        'The child is sick',
                        'The child has travelled',
                        'The child has gone out to play',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other reasons',
                    ]),
                    DropdownField(
                      question:
                          'Who is answering for the child since he/she is not available?',
                      options: [
                        'The parents or legal guardians',
                        'Another family member of the child',
                        'One of the childs siblings',
                        'Other'
                      ],
                    ),
                    ..._buildQuestionFields([
                      'If other, please specify',
                    ]),
                    ..._buildQuestionFields([
                      'Child first name',
                    ]),
                    ..._buildQuestionFields([
                      'Child surname',
                    ]),
                    RadioButtonField(
                      question: 'Gender of the child %rostertitle%',
                      options: [
                        'Boy',
                        'Girl',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Year of birth of the child %rostertitle%',
                    ]),
                    RadioButtonField(
                      question:
                          'Does the child %rostertitle% have a birth certificate?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'If no, please specify why',
                    ]),
                    DropdownField(
                      question:
                          'Is the child %rostertitle% born in this community?',
                      options: [
                        'Yes',
                        'No, he was born in this district but different community within the district',
                        'No, he was born in this region but different district within the region',
                        'No, he was born in another region of Ghana',
                        'No, he was born in another country',
                      ],
                    ),
                    DropdownField(
                      question:
                          'In which country is the child %rostertitle% born?',
                      options: [
                        'Benin',
                        'Burkina Faso',
                        'Ivory Coast',
                        'Mali',
                        'Togo',
                        'Niger',
                        'Togo',
                        'Other ',
                      ],
                    ),
                    DropdownField(
                      question:
                          'Relationship of %rostertitle% to the head of the  household',
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
                    ),
                    ..._buildQuestionFields([
                      'Other',
                    ]),
                    DropdownField(
                      question:
                          'Why does the %rostertitle% not live with his/her family?',
                      options: [
                        'Parents deceased',
                        'Cant take care of me',
                        'Abandoned',
                        'School reasons',
                        'A recruitment agency brought me here',
                        'I did not want to live with my parents',
                        'Other(specify)',
                        'Dont know',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other reasons',
                    ]),
                    DropdownField(
                      question:
                          'Who decided that the child %rostertitle% to come into the household?',
                      options: [
                        'Myself',
                        'Father/Mother',
                        'Grandparents',
                        'Other family members',
                        'An external recruiter or agency external',
                        'Other(specify)',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other person',
                    ]),
                    RadioButtonField(
                      question:
                          'Did the %rostertitle% child agree with this decision?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    RadioButtonField(
                      question:
                          'Has the %rostertitle% child seen and/or spoken with his/her parents in the past year?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    DropdownField(
                      question:
                          'When was the last time the child saw and/or talked with mom and/or dad?',
                      options: [
                        'Max 1 week',
                        'Max 1 month',
                        'Max 1 year',
                        'More than 1 year',
                        'Never',
                      ],
                    ),
                    DropdownField(
                      question:
                          'For how long has the %rostertitle% child been livng in the household?',
                      options: [
                        'Born in the household',
                        'Less than 1 year',
                        '1-2 years',
                        '2-4 years old',
                        '4-6 years old',
                        '6-8 years old',
                        'More than 8 years ',
                        'Dont know',
                      ],
                    ),
                    DropdownField(
                      question:
                          'Who accompanied the child %rostertitle% to come here',
                      options: [
                        'Came alone',
                        'Father/Mother',
                        'Grandparents',
                        'Other family member',
                        'With a recruit',
                        'Other'
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other person',
                    ]),
                    DropdownField(
                      question:
                          'Where does the childs father live %rostertitle%?',
                      options: [
                        'In the same household',
                        'In another household in the same village',
                        'In another household in the same region',
                        'In another household in another region',
                        'Abroad',
                        'Parents deceased',
                        'Dont know/Dont want to answer',
                      ],
                    ),
                    DropdownField(
                      question: 'Fathers country of residence',
                      options: [
                        'Benin',
                        'Burkina Faso',
                        'Ghana',
                        'Guinea',
                        'Guinea-Bissau',
                        'Liberia',
                        'Mauriitania',
                        'Mali',
                        'Nigeria',
                        'Niger',
                        'Senegal',
                        'Sierra Leone',
                        'Togo',
                        'Dont know',
                        'Others to be specified',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other country',
                    ]),
                    DropdownField(
                      question:
                          'Where does the childs mother live %rostertitle%?',
                      options: [
                        'In the same household',
                        'In another household in the same village',
                        'In another household in the same region',
                        'In another household in another region',
                        'Abroad',
                        'Parents deceased',
                        'Dont know/Dont want to answer',
                      ],
                    ),
                    DropdownField(
                      question: 'Country of residence of the mother',
                      options: [
                        'Benin',
                        'Burkina Faso',
                        'Ghana',
                        'Guinea',
                        'Guinea-Bissau',
                        'Liberia',
                        'Mauriitania',
                        'Mali',
                        'Nigeria',
                        'Niger',
                        'Senegal',
                        'Sierra Leone',
                        'Togo',
                        'Dont know',
                        'Others to be specified',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other country',
                    ]),
                    RadioButtonField(
                      question:
                          'Is the child %rostertitle% currently enrolled in school?',
                      options: [
                        'Yes',
                        'No',
                      ],
                    ),
                    ..._buildQuestionFields([
                      'What is the name of the school?',
                    ]),
                    RadioButtonField(
                      question: 'Is the school a public or private school?',
                      options: [
                        'Public',
                        'Private',
                      ],
                    ),
                    DropdownField(
                      question:
                          "What grade is the child %rostertitle% enrolled in?",
                      options: [
                        "Kindergarten 1",
                        "Kindergarten 2",
                        "Primary 1",
                        "Primary 2",
                        "Primary 3",
                        "Primary 4",
                        "Primary 5",
                        "Primary 6",
                        "JHS/JSS 1",
                        "JHS/JSS 2",
                        "JHS/JSS 3",
                        "SSS/SHS 1",
                        "SSS/SHS 2",
                        "SSS/SHS 3"
                      ],
                    ),
                    DropdownField(
                      question:
                          "How many times does the child go to school in a week?",
                      options: [
                        "Once",
                        "Twice",
                        "Thrice",
                        "Four times",
                        "Five times"
                      ],
                    ),
                    CheckboxField(
                      question:
                          "Select the basic school needs that are available to the child %rostertitle%",
                      options: [
                        "Books",
                        "School bag",
                        "Pen / Pencils",
                        "School Uniforms",
                        "Shoes and Socks",
                        "None of the above"
                      ],
                    ),
                    RadioButtonField(
                      question:
                          "Has the child %rostertitle% ever been to school?",
                      options: [
                        "Yes, they went to school but stopped",
                        "No, they have never been to school"
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Which year did the child %rostertitle% leave school?',
                    ]),
                    DropdownField(
                      question:
                          "Please ask the child to calculate the question above",
                      options: [
                        "Yes, the child gave the right answer for both calculations.",
                        "Yes, the child gave the right answer for one calculation.",
                        "No, the child does not know how to answer and gave wrong answers.",
                        "The child refuses to try."
                      ],
                    ),
                    DropdownField(
                      question:
                          "Please ask the child to read the above sentences",
                      options: [
                        "Yes,(he/she can read the sentences)",
                        "Only the simple text(text 1.)",
                        "No",
                        "The child refuses to try."
                      ],
                    ),
                    DropdownField(
                      question:
                          "Please ask the child to write any of the above statements",
                      options: [
                        "Yes,(he/she can write both sentences)",
                        "Only the simple text(text 1.)",
                        "No",
                        "The child refuses to try."
                      ],
                    ),
                    DropdownField(
                      question: "What is the education level of %rostertitle%",
                      options: [
                        "Pre-school (Kindergarten)",
                        "Primary",
                        "JSS/Middle school",
                        "SSS/'O'-level/'A'-level (including vocational & technical training)",
                        "University or higher",
                        "Not applicable"
                      ],
                    ),
                    DropdownField(
                      question:
                          "What is the main reason for the child %rostertitle% leaving school?",
                      options: [
                        "The school is too far away",
                        "Tuition fees for private school too high",
                        "Poor academic performance",
                        "Insecurity in the area",
                        "To learn a trade",
                        "Early pregnancy",
                        "The child did not want to go to school anymore",
                        "Parents can't afford Teaching and Learning Materials",
                        "Other",
                        "Does not know"
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other reason',
                    ]),
                    DropdownField(
                      question:
                          "Why has the child %rostertitle% never been to school before?",
                      options: [
                        "The school is too far away",
                        "Tuition fees too high",
                        "Too young to be in school",
                        "Insecurity in the region",
                        "To learn a trade (apprenticeship)",
                        "The child did not want to go to school ",
                        "Parents can't afford TLMs and/or enrolllment fees",
                        "Other",
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other reason',
                    ]),
                    RadioButtonField(
                      question:
                          "Has the child been to school in the past 7 days?",
                      options: ["Yes", "No"],
                    ),
                    DropdownField(
                      question:
                          "Why has the child %rostertitle% never been to school before?",
                      options: [
                        "It was the holidays.",
                        "He/she was sick.",
                        "He/she was working.",
                        "He/she was traveling.",
                        "Other"
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to specify',
                    ]),
                    RadioButtonField(
                      question:
                          "Has the child %rostertitle% missed school days the past 7 days?",
                      options: ["Yes", "No"],
                    ),
                    DropdownField(
                      question:
                          "Why has the child %rostertitle% never been to school before?",
                      options: [
                        "He/she was sick",
                        "He/she was working",
                        "He/she traveled",
                        "Other"
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to specify',
                    ]),
                    RadioButtonField(
                      question:
                          "In the past 7 days, has the child %rostertitle% worked in the house?",
                      options: ["Yes", "No"],
                    ),
                    RadioButtonField(
                      question:
                          "In the past 7 days, has the child %rostertitle% been working on the cocoa farm?",
                      options: ["Yes", "No"],
                    ),
                    DropdownField(
                      question:
                          "How often has the child worked in the past 7 days?",
                      options: ["Every day", "4-5 days", "2-3 days", "Once"],
                    ),
                    RadioButtonField(
                      question:
                          "Which of these tasks has child %rostertitle% performed in the last 7 days?",
                      options: ["Yes", "No"],
                    ),
                    CheckboxField(
                      question:
                          "How often has the child worked in the past 7 days?",
                      options: [
                        "Collect and gather fruits, pods, seeds after harvesting",
                        "Extracting cocoa beans after shelling by an adult",
                        "Wash beans, fruits, vegetables or tubers",
                        "Prepare the germinators and pour the seeds into the germinators",
                        "Collecting firewood",
                        "To help measure distances between plants during transplanting",
                        "Sort and spread the beans, cereals and other vegetables for drying",
                        "Putting cuttings on the mounds",
                        "Holding bags or filling them with small containers for packaging agricultural products",
                        "Covering stored agricultural products with tarps",
                        "To shell or dehusk seeds, plants, and fruits by hand",
                        "Sowing seeds",
                        "Transplant or put in the ground the cuttings or plants",
                        "Harvesting legumes, fruits, and other leafy products (corn, beans, soybeans, etc.)"
                      ],
                    ),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1.5, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'CHILDREN OF THE HOUSEHOLD/ CHILDREN OF THE HOUSEHOLD - %ROSTERTITLE%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 10),
                    ),
                    Text(
                      'Tableau: LIGHT TASKS - %ROSTERTITLE%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RadioButtonField(
                      question:
                          "Did the child receive renumeration for the activity %rostertitle%?",
                      options: ["Yes", "No"],
                    ),
                    DropdownField(
                      question:
                          "What was the longest time spent on light duty %rostertitle% during a SCHOOL DAY in the last 7 days?",
                      options: [
                        "Less than 1 hour",
                        "1-2 hours",
                        "2-3 hours",
                        "3-4 hours",
                        "4-6 hours",
                        "6-8 hours",
                        "More than 8 hours",
                        "Does not apply"
                      ],
                    ),
                    DropdownField(
                      question:
                          "What was the longest time spent on light duty %rostertitle% during a NON SCHOOL DAY in the last 7 days?",
                      options: [
                        "Less than 1 hour",
                        "1-2 hours",
                        "2-3 hours",
                        "3-4 hours",
                        "4-6 hours",
                        "6-8 hours",
                        "More than 8 hours",
                      ],
                    ),
                    DropdownField(
                      question: "Where was this task %rostertitle done?",
                      options: [
                        "On family farm",
                        "As a hired labourer on another farm",
                        "School farms/compounds",
                        "Teachers' farms (during communal labour)",
                        "Church farms or cleaning activities",
                        "Helping a community member for free",
                        "Other"
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to specify',
                    ]),
                    ..._buildQuestionFields([
                      'How many hours in total did the child spend on light duty %rostertitle% during NON-SCHOOL DAYS in the last 7 days?',
                    ]),
                    RadioButtonField(
                      question:
                          "Was the child under supervision of an adult when performing this task?",
                      options: ["Yes", "No"],
                    ),
                    CheckboxField(
                      question:
                          "Which of these tasks has child %rostertitle% performed in the last 12 months?",
                      options: [
                        "Collect and gather fruits, pods, seeds after harvesting",
                        "Extracting cocoa beans after shelling by an adult",
                        "Wash beans, fruits, vegetables or tubers",
                        "Prepare the germinators and pour the seeds into the germinators",
                        "Collecting firewood",
                        "To help measure distances between plants during transplanting",
                        "Sort and spread the beans, cereals and other vegetables for drying",
                        "Putting cuttings on the mounds",
                        "Holding bags or filling them with small containers for packaging agricultural products",
                        "Covering stored agricultural products with tarps",
                        "To shell or dehusk seeds, plants, and fruits by hand",
                        "Sowing seeds",
                        "Transplant or put in the ground the cuttings or plants",
                        "Harvesting legumes, fruits, and other leafy products (corn, beans, soybeans, various vegetables)",
                        "None"
                      ],
                    ),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1.5, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'CHILDREN OF THE HOUSEHOLD/ CHILDREN OF THE HOUSEHOLD - %ROSTERTITLE%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 10),
                    ),
                    Text(
                      'Tableau: LIGHT TASKS - %ROSTERTITLE%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RadioButtonField(
                      question:
                          "Did the child receive renumeration for the activity %rostertitle%?",
                      options: ["Yes", "No"],
                    ),
                    DropdownField(
                      question:
                          "What was the longest time spent on light duty %rostertitle% during a SCHOOL DAY in the last 7 days?",
                      options: [
                        "Less than 1 hour",
                        "1-2 hours",
                        "2-3 hours",
                        "3-4 hours",
                        "4-6 hours",
                        "6-8 hours",
                        "More than 8 hours",
                        "Does not apply"
                      ],
                    ),
                    DropdownField(
                      question:
                          "What was the longest time spent on worklight %rostertitle% on a NON SCHOOL DAY in the last 7 days?",
                      options: [
                        "Less than 1 hour",
                        "1-2 hours",
                        "2-3 hours",
                        "3-4 hours",
                        "4-6 hours",
                        "6-8 hours",
                        "More than 8 hours",
                      ],
                    ),
                    DropdownField(
                      question: "Where was this task %rostertitle done?",
                      options: [
                        "On family farm",
                        "As a hired labourer on another farm",
                        "School farms/compounds",
                        "Teachers' farms (during communal labour)",
                        "Church farms or cleaning activities",
                        "Helping a community member for free",
                        "Other"
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to specify',
                    ]),
                    ..._buildQuestionFields([
                      'How many hours in total did the child spend in light work %rostertitle% during SCHOOL DAYS in the last 7 days?',
                    ]),
                    ..._buildQuestionFields([
                      'How many hours in total did the child spend on lightduty work %rostertitle% during NON-SCHOOL DAYS in the last 7 days?',
                    ]),
                    RadioButtonField(
                      question:
                          "Was the child under supervision of an adult when performing this task?",
                      options: ["Yes", "No"],
                    ),
                    CheckboxField(
                      question:
                          "Which of the following tasks has the child %rostertitle% done in the last 7 days on the cocoa farm?",
                      options: [
                        "Use of machetes for weeding or pruning (Clearing)",
                        "Felling of trees",
                        "Burning of plots",
                        "Game hunting with a weapon",
                        "Woodcutter's work",
                        "Charcoal production",
                        "Stump removal",
                        "Digging holes",
                        "Working with a machete or any other sharp tool",
                        "Handling of agrochemicals",
                        "Driving motorized vehicles",
                        "Carrying heavy loads (Boys: 14-16 years old >15kg / 16-17 years old >20kg; Girls: 14-16 years old >8kg / 16-17 years old >10kg)",
                        "Night work on farm (between 6pm and 6am)",
                        "None of the above"
                      ],
                    ),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1.5, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'CHILDREN OF THE HOUSEHOLD/ CHILDREN OF THE HOUSEHOLD - %ROSTERTITLE%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 10),
                    ),
                    Text(
                      'Tableau: Q40 DANGEROUS TASKS - %ROSTERTITLE%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RadioButtonField(
                      question:
                          "Has the child %rostertitle% received a salary for this task?",
                      options: ["Yes", "No"],
                    ),
                    DropdownField(
                      question: "Where was this task %rostertitle done?",
                      options: [
                        "On family farm",
                        "As a hired labourer on another farm",
                        "School farms/compounds",
                        "Teachers' farms (during communal labour)",
                        "Church farms or cleaning activities",
                        "Helping a community member for free",
                        "Other"
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to specify',
                    ]),
                    DropdownField(
                      question:
                          "What was the longest time spent on the task %rostertitle% during a SCHOOL DAY in the last 7 days?",
                      options: [
                        "Less than 1 hour",
                        "1-2 hours",
                        "2-3 hours",
                        "3-4 hours",
                        "4-6 hours",
                        "6-8 hours",
                        "More than 8 hours",
                        "Does not apply"
                      ],
                    ),
                    DropdownField(
                      question:
                          "What was the longest time spent on the task %rostertitle% during a non school day these last 7 days?",
                      options: [
                        "Less than 1 hour",
                        "1-2 hours",
                        "2-3 hours",
                        "3-4 hours",
                        "4-6 hours",
                        "6-8 hours",
                        "More than 8 hours",
                      ],
                    ),
                    ..._buildQuestionFields([
                      'How many hours has the child %rostertitle% worked on during SCHOOL DAYS during the last 7 days?',
                    ]),
                    ..._buildQuestionFields([
                      'How many hours has the child %rostertitle% worked on during SCHOOL DAYS during the last 7 days?',
                    ]),
                    RadioButtonField(
                      question:
                          "Was the child under supervision of an adult when performing this task?",
                      options: ["Yes", "No"],
                    ),
                    CheckboxField(
                      question:
                          "Which of the following tasks has the child %rostertitle% done in the last 12 months on the cocoa farm?",
                      options: [
                        "Use of machetes for weeding or pruning (Clearing)",
                        "Felling of trees",
                        "Burning of plots",
                        "Game hunting with a weapon",
                        "Woodcutter's work",
                        "Charcoal production",
                        "Stump removal",
                        "Digging holes",
                        "Working with a machete or any other sharp tool",
                        "Handling of agrochemicals",
                        "Driving motorized vehicles",
                        "Carrying heavy loads (Boys: 14-16 years old >15kg / 16-17 years old >20kg; Girls: 14-16 years old >8kg / 16-17 years old >10kg)",
                        "Night work on farm (between 6pm and 6am)",
                        "None of the above"
                      ],
                    ),
                    Divider(
                      color: Colors.grey, // Color of the divider
                      thickness: 1.5, // Thickness of the line
                      height: 20, // Space above and below
                      indent: 10, // Left padding
                      endIndent: 10, // Right padding
                    ),
                    Text(
                      'CHILDREN OF THE HOUSEHOLD/ CHILDREN OF THE HOUSEHOLD - %ROSTERTITLE%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 10),
                    ),
                    Text(
                      'Tableau: Q40 DANGEROUS TASKS - %ROSTERTITLE%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RadioButtonField(
                      question:
                          "Has the child %rostertitle% received a salary for this task?",
                      options: ["Yes", "No"],
                    ),
                    DropdownField(
                      question: "Where was this task %rostertitle done?",
                      options: [
                        "On family farm",
                        "As a hired labourer on another farm",
                        "School farms/compounds",
                        "Teachers' farms (during communal labour)",
                        "Church farms or cleaning activities",
                        "Helping a community member for free",
                        "Other"
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other to specify',
                    ]),
                    DropdownField(
                      question:
                          "What was the longest time spent on the task %rostertitle% during a SCHOOL DAY in the last 7 days?",
                      options: [
                        "Less than 1 hour",
                        "1-2 hours",
                        "2-3 hours",
                        "3-4 hours",
                        "4-6 hours",
                        "6-8 hours",
                        "More than 8 hours",
                        "Does not apply"
                      ],
                    ),
                    DropdownField(
                      question:
                          "What was the longest time spent on the task %rostertitle% during a non school day these last 7 days?",
                      options: [
                        "Less than 1 hour",
                        "1-2 hours",
                        "2-3 hours",
                        "3-4 hours",
                        "4-6 hours",
                        "6-8 hours",
                        "More than 8 hours",
                      ],
                    ),
                    ..._buildQuestionFields([
                      'How many hours has the child %rostertitle% worked on during SCHOOL DAYS during the last 7 days?',
                    ]),
                    ..._buildQuestionFields([
                      'How many hours has the child %rostertitle% worked on during SCHOOL DAYS during the last 7 days?',
                    ]),
                    RadioButtonField(
                      question:
                          "Was the child under supervision of an adult when performing this task?",
                      options: ["Yes", "No"],
                    ),
                    DropdownField(
                      question: "For whom does the child %rostertitle% work?",
                      options: [
                        "For his/her parents",
                        "For family, not parents",
                        "For family friends",
                        "Other"
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other specify',
                    ]),
                    DropdownField(
                      question: "Why does the child %rostertitle% work?",
                      options: [
                        "To have his/her own money",
                        "To increase household income",
                        "Household cannot afford adult's work",
                        "Household cannot find adult labor",
                        "To learn cocoa farming",
                        "Other (specify)",
                        "Does not know"
                      ],
                    ),
                    ..._buildQuestionFields([
                      'Other specify',
                    ]),
                    RadioButtonField(
                      question:
                          "Has the child ever applied or sprayed agrochemicals on the farm?",
                      options: ["Yes", "No"],
                    ),
                    RadioButtonField(
                      question:
                          "Was the child on the farm during application of agrochemicals?",
                      options: ["Yes", "No"],
                    ),
                    RadioButtonField(
                      question: "Recently, has the child suffered any injury?",
                      options: ["Yes", "No"],
                    ),
                    DropdownField(
                      question: "How did the child get wounded?",
                      options: [
                        "Playing outside",
                        "Doing household chores",
                        "Helping on the farm",
                        "Falling off a bicycle, scooter, or tricycle",
                        "Animal or insect bite or scratch",
                        "Fighting with someone else",
                        "Other",
                      ],
                    ),
                    DropdownField(
                      question: "When was the child wounded?",
                      options: [
                        "Less than a week ago",
                        "More than one week and less than a month",
                        "More than 2 months and less than 6 months",
                        "More than 6 months"
                      ],
                    ),
                    RadioButtonField(
                      question: "Does the child often feel pains or aches?",
                      options: ["Yes", "No"],
                    ),
                    CheckboxField(
                      question:
                          "What help did the child receive to get better?",
                      options: [
                        'The adults of the household',
                        'Adults of the community looked after him/her',
                        'The child was sent to the closest medical facility',
                        'The child did not receive any help',
                        'Other ',
                      ],
                    ),
                    Text(
                      'Child photo ',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    PictureField(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.grey[100], // Match your background color
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Consent()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00754B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text('PREV',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w400)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Remediation()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00754B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text('NEXT',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionFields(List<String> questions) {
    return questions
        .map((question) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: QuestionField(question: question),
            ))
        .toList();
  }
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
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
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
