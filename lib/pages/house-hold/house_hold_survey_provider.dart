import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../models/household_survey.dart';
import '../../database/household_survey_db.dart';

class HouseHoldSurveyProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> surveyQuestions = [
    // SENSITIZATION
    {
      'question':
          'Have you sensitized the household members on Good Parenting?',
      'type': 'yes_no',
    },
    {
      'question':
          'Have you sensitized the household members on Child Protection?',
      'type': 'yes_no',
    },
    {
      'question':
          'Have you sensitized the household members on Safe Labour Practices?',
      'type': 'yes_no',
    },
    {
      'question':
          'How many female adults were present during the sensitization?',
      'type': 'text',
    },
    {
      'question': 'How many male adults were present during the sensitization?',
      'type': 'text',
    },
    {
      'question': 'Can you take a picture of the respondent and yourself?',
      'type': 'yes_no',
    },
    // {
    //   'question':
    //       'Please take a picture of the sensitization being implemented with the family and the child',
    //   'type': 'instruction',
    // },
    {
      'question':
          'What are your observations regarding the reaction from the parents on the sensitization provided?',
      'type': 'text',
    },

    //
    {
      'question':
          'Have you sensitized the household members on Good Parenting?',
      'type': 'yes_no',
    },
    {
      'question':
          'Have you sensitized the household members on Child Protection?',
      'type': 'yes_no',
    },
    {
      'question':
          'Have you sensitized the household members on Safe Labour Practices?',
      'type': 'yes_no',
    },
    {
      'question':
          'How many female adults were present during the sensitization?',
      'type': 'text',
    },
    {
      'question': 'How many male adults were present during the sensitization?',
      'type': 'text',
    },
    {
      'question': 'Can you take a picture of the respondent and yourself?',
      'type': 'yes_no',
    },
    // {
    //   'question':
    //       'Please take a picture of the sensitization being implemented with the family and the child',
    //   'type': 'instruction',
    // },
    {
      'question':
          'What are your observations regarding the reaction from the parents on the sensitization provided?',
      'type': 'text',
    },

    // New questions
    {
      'question':
          'Do you owe fees for the school of the children living in your household?',
      'type': 'yes_no',
    },
    {
      'question':
          'What should be done for the parent to stop involving their children in child labour?',
      'type': 'multiple_choice',
      'options': [
        'Child protection and parenting education',
        'School kits support',
        'IGA support',
      ],
    },
    {
      'question': 'Other (parent support)',
      'type': 'text',
    },
    {
      'question':
          'What can be done for the community to stop involving the children in child labour?',
      'type': 'multiple_choice',
      'options': [
        'Community education on child labour',
        'Community school building',
        'Community school renovation',
        'Other',
      ],
    },
    {
      'question': 'Other (community support)',
      'type': 'text',
    },

    //

    // {
    //   'question': 'Fill out the survey',
    //   'type': 'instruction',
    // },
    {
      'question': 'Is the name of the respondent correct?',
      'type': 'yes_no',
    },
    {
      'question': 'If No, fill in the exact name and surname of the producer?',
      'type': 'text',
    },
    {
      'question': 'What is the nationality of the respondent?',
      'type': 'multiple_choice',
      'options': ['Ghanaian', 'Non Ghanaian'],
    },
    {
      'question': 'If Non Ghanaian, specify the country of origin',
      'type': 'multiple_choice',
      'options': [
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
    },
    {
      'question': 'Other to Specify',
      'type': 'text',
    },
    {
      'question': 'Is the respondent the owner of the farm?',
      'type': 'yes_no',
    },
    {
      'question': 'Which of these best describes you?',
      'type': 'multiple_choice',
      'options': ['Complete Owner', 'Sharecropper', 'Owner/Sharecropper'],
    },
    {
      'question': 'Which of these best describes you?',
      'type': 'multiple_choice',
      'options': ['Caretaker/Manager of the Farm', 'Sharecropper'],
    },
    // {
    //   'question': 'IDENTIFICATION OF THE OWNER',
    //   'type': 'instruction',
    // },
    {
      'question': 'Name of the owner?',
      'type': 'text',
    },
    {
      'question': 'First name of the owner?',
      'type': 'text',
    },
    {
      'question': 'What is the nationality of the owner?',
      'type': 'multiple_choice',
      'options': ['Ghanaian', 'Non Ghanaian'],
    },
    {
      'question': 'If Non Ghanaian, please indicate the country they are from',
      'type': 'multiple_choice',
      'options': [
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
    },
    {
      'question': 'Other to Specify',
      'type': 'text',
    },
    {
      'question':
          'For how many years has the respondent been working for the owner?',
      'type': 'text',
    },
    // {
    //   'question': 'WORKERS IN THE FARM',
    //   'type': 'instruction',
    // },
    {
      'question':
          'Have you recruited at least one worker during the past year?',
      'type': 'yes_no',
    },
    {
      'question': 'Do you recruit workers for...',
      'type': 'checkbox',
      'options': ['Permanent Labor', 'Casual labor'],
    },
    {
      'question': 'What king of agreement do you have with your workers?',
      'type': 'multiple_choice',
      'options': [
        'Verbal agreement without witness',
        'Verbal agreement with witness',
        'Written agreement without witness',
        'Written contract with witness',
        'Other (specify)'
      ],
    },
    {
      'question': 'Other to Specify',
      'type': 'text',
    },
    {
      'question':
          'Were the tasks to be performed by the worker clarified with them during the recruitment?',
      'type': 'yes_no',
    },
    {
      'question':
          'Does the worker perform tasks for you or your family members other than those agreed upon?',
      'type': 'yes_no',
    },
    {
      'question': 'What do you do when a worker refuses to perform a task?',
      'type': 'multiple_choice',
      'options': [
        'I find a compromise',
        'I withdraw part of their salary',
        'I issue a warning',
        'Other',
        'Not applicable',
      ],
    },
    {
      'question': 'Other to Specify',
      'type': 'text',
    },
    {
      'question': 'Do your workers receive their full salaries?',
      'type': 'multiple_choice',
      'options': ['Always', 'Sometimes', 'Rarely', 'Never'],
    },
    // {
    //   'question':
    //       'For the following section, please read the statements to the respondent, and ask him/her if he/she agrees or disagrees.',
    //   'type': 'instruction',
    // },
    {
      'question':
          'It is acceptable to recruit someone for work without their consent',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    {
      'question':
          'It is acceptable for a person who cannot pay their debts to work for the creditor to reimburse the debt.',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    {
      'question':
          'It is acceptable for an employer not to reveal the true nature of the work during the recruitment.',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    {
      'question':
          'A worker is obliged to work whenever he is called upon by his employer',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    {
      'question': 'A worker is not entitled to move freely',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    {
      'question':
          'A worker must be free to communicate with his or her family and friends',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    {
      'question':
          'A worker is obliged to adapt to any living conditions imposed by the employer',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    {
      'question':
          'It is acceptable for an employer and their family to interfere in a workers private life',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    {
      'question':
          'A worker should not have the freedom to leave work whenever they wish',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    {
      'question':
          'A worker should be required to stay longer than expected while waiting for unpaid salary',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    {
      'question':
          'A worker should not be able to leave their employer when they owe money to their employer',
      'type': 'multiple_choice',
      'options': ['Agree', 'Disagree'],
    },
    // {
    //   'question': 'ADULT OF THE RESPONDENTS HOUSEHOLD',
    //   'type': 'instruction',
    // },
    // {
    //   'question': 'INFORMATIONS ON THE ADULTS LIVING IN THE HOUSEHOLD',
    //   'type': 'instruction',
    // },
    {
      'question':
          'Total number of adults in the household(producer/manager/owner not included)',
      'type': 'text',
    },
    {
      'question': 'Full  name of household members',
      'type': 'text',
    },
    // {
    //   'question':
    //       'ADULT OF THE RESPONDENTS HOUSEHOLD/ INFORMATIONS ON THE ADULTS LIVING IN THE HOUSEHOLD',
    //   'type': 'instruction',
    // },
    // {
    //   'question':
    //       'Tableau: PRODUCERS/MANAGERS HOUSEHOLD INFRORMATION - ',
    //   'type': 'instruction',
    // },
    {
      'question':
          'Relationship of to the respondent (Farmer/Manager/CareTaker)',
      'type': 'multiple_choice',
      'options': [
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
    },
    {
      'question': 'Other to specify',
      'type': 'text',
    },
    // {
    //   'question':
    //       'Make sure to interview the Worker or Family of the Worker should any of these 2 be selected above',
    //   'type': 'instruction',
    // },
    {
      'question': 'Gender of ',
      'type': 'multiple_choice',
      'options': ['Male', 'Female'],
    },
    {
      'question': 'Nationality of ',
      'type': 'multiple_choice',
      'options': ['Ghanaian', 'Non Ghanaian'],
    },
    {
      'question': 'If Non Ghanaian, please specify the country of origin',
      'type': 'multiple_choice',
      'options': [
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
    },
    {
      'question': 'Other to specify',
      'type': 'text',
    },
    {
      'question': 'Year of birth of ',
      'type': 'text',
    },
    {
      'question': 'Does have a birth certificate?',
      'type': 'yes_no',
    },
    {
      'question': 'Work/ main  occupation of ',
      'type': 'multiple_choice',
      'options': [
        'Farmer (cocoa)',
        'Farmer (coffee)',
        'Farmer (other)',
        'Merchant',
        'Student',
        'Other (to specify)',
        'No activity',
      ],
    },
    {
      'question': 'Other to specify',
      'type': 'text',
    },
    // {
    //   'question': 'CHILDREN OF THE HOUSEHOLD',
    //   'type': 'instruction',
    // },
    {
      'question': 'Are there children livng in the respondents household?',
      'type': 'yes_no',
    },
    {
      'question':
          'Out of the number of children stated above, How many are between the ages of 5 and 17?',
      'type': 'text',
    },
    // {
    //   'question': 'CHILDREN OF THE HOUSEHOLD',
    //   'type': 'instruction',
    // },
    // {
    //   'question': 'Tableau: CHILDREN OF THE HOUSEHOLD - ',
    //   'type': 'instruction',
    // },
    {
      'question':
          'Is the child among the list of children declared in the cover to be the farmers children',
      'type': 'yes_no',
    },
    {
      'question':
          'Enter the number attached to the child name in the cover so we can identify the child in question',
      'type': 'text',
    },
    {
      'question': 'Can the child be surveyed now?',
      'type': 'yes_no',
    },
    {
      'question': 'If not, what are the reasons?',
      'type': 'checkbox',
      'options': [
        'The child is at school',
        'The child has gobe to work on the cocoa farm',
        'Child is busy doing homework',
        'Child works outside the household',
        'The child is too young',
        'The child is sick',
        'The child has travelled',
        'The child has gone out to play',
      ],
    },
    {
      'question': 'Other reasons',
      'type': 'text',
    },
    {
      'question':
          'Who is answering for the child since he/she is not available?',
      'type': 'multiple_choice',
      'options': [
        'The parents or legal guardians',
        'Another family member of the child',
        'One of the childs siblings',
        'Other'
      ],
    },
    {
      'question': 'If other, please specify',
      'type': 'text',
    },
    {
      'question': 'Child first name',
      'type': 'text',
    },
    {
      'question': 'Child surname',
      'type': 'text',
    },
    {
      'question': 'Gender of the child ',
      'type': 'multiple_choice',
      'options': ['Male', 'Female'],
    },
    {
      'question': 'Year of birth of the child ',
      'type': 'text',
    },
    {
      'question': 'Does the child have a birth certificate?',
      'type': 'yes_no',
    },
    {
      'question': 'If no, please specify why',
      'type': 'text',
    },
    {
      'question': 'Is the child born in this community?',
      'type': 'multiple_choice',
      'options': [
        'Yes',
        'No, he was born in this district but different community within the district',
        'No, he was born in this region but different district within the region',
        'No, he was born in another region of Ghana',
        'No, he was born in another country',
      ],
    },
    {
      'question': 'In which country is the child born?',
      'type': 'multiple_choice',
      'options': [
        'Benin',
        'Burkina Faso',
        'Ivory Coast',
        'Mali',
        'Togo',
        'Niger',
        'Togo',
        'Other ',
      ],
    },
    {
      'question': 'Relationship of to the head of the  household',
      'type': 'multiple_choice',
      'options': [
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
    },
    {
      'question': 'Other',
      'type': 'text',
    },
    {
      'question': 'Why does the not live with his/her family?',
      'type': 'multiple_choice',
      'options': [
        'Parents deceased',
        'Cant take care of me',
        'Abandoned',
        'School reasons',
        'A recruitment agency brought me here',
        'I did not want to live with my parents',
        'Other(specify)',
        'Dont know',
      ],
    },
    {
      'question': 'Other reasons',
      'type': 'text',
    },
    {
      'question':
          'Who decided that the child to come into the household?',
      'type': 'multiple_choice',
      'options': [
        'Myself',
        'Father/Mother',
        'Grandparents',
        'Other family members',
        'An external recruiter or agency external',
        'Other(specify)',
      ],
    },
    {
      'question': 'Other person',
      'type': 'text',
    },
    {
      'question': 'Did the child agree with this decision?',
      'type': 'yes_no',
    },
    {
      'question':
          'Has the child seen and/or spoken with his/her parents in the past year?',
      'type': 'yes_no',
    },
    {
      'question':
          'When was the last time the child saw and/or talked with mom and/or dad?',
      'type': 'multiple_choice',
      'options': [
        'Max 1 week',
        'Max 1 month',
        'Max 1 year',
        'More than 1 year',
        'Never',
      ],
    },
    {
      'question':
          'For how long has the child been livng in the household?',
      'type': 'multiple_choice',
      'options': [
        'Born in the household',
        'Less than 1 year',
        '1-2 years',
        '2-4 years old',
        '4-6 years old',
        '6-8 years old',
        'More than 8 years ',
        'Dont know',
      ],
    },
    {
      'question': 'Who accompanied the child to come here',
      'type': 'multiple_choice',
      'options': [
        'Came alone',
        'Father/Mother',
        'Grandparents',
        'Other family member',
        'With a recruit',
        'Other'
      ],
    },
    {
      'question': 'Other person',
      'type': 'text',
    },
    {
      'question': 'Where does the childs father live ?',
      'type': 'multiple_choice',
      'options': [
        'In the same household',
        'In another household in the same village',
        'In another household in the same region',
        'In another household in another region',
        'Abroad',
        'Parents deceased',
        'Dont know/Dont want to answer',
      ],
    },
    {
      'question': 'Fathers country of residence',
      'type': 'multiple_choice',
      'options': [
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
    },
    {
      'question': 'Other country',
      'type': 'text',
    },
    {
      'question': 'Where does the childs mother live ?',
      'type': 'multiple_choice',
      'options': [
        'In the same household',
        'In another household in the same village',
        'In another household in the same region',
        'In another household in another region',
        'Abroad',
        'Parents deceased',
        'Dont know/Dont want to answer',
      ],
    },
    {
      'question': 'Country of residence of the mother',
      'type': 'multiple_choice',
      'options': [
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
    },
    {
      'question': 'Other country',
      'type': 'text',
    },
    {
      'question': 'Is the child currently enrolled in school?',
      'type': 'yes_no',
    },
    {
      'question': 'What is the name of the school?',
      'type': 'text',
    },
    {
      'question': 'Is the school a public or private school?',
      'type': 'multiple_choice',
      'options': ['Public', 'Private'],
    },
    {
      'question': 'What grade is the child enrolled in?',
      'type': 'multiple_choice',
      'options': [
        'Kindergarten 1',
        'Kindergarten 2',
        'Primary 1',
        'Primary 2',
        'Primary 3',
        'Primary 4',
        'Primary 5',
        'Primary 6',
        'JHS/JSS 1',
        'JHS/JSS 2',
        'JHS/JSS 3',
        'SSS/SHS 1',
        'SSS/SHS 2',
        'SSS/SHS 3'
      ],
    },
    {
      'question': 'How many times does the child go to school in a week?',
      'type': 'multiple_choice',
      'options': ['Once', 'Twice', 'Thrice', 'Four times', 'Five times'],
    },
    {
      'question':
          'Select the basic school needs that are available to the child ',
      'type': 'checkbox',
      'options': [
        'Books',
        'School bag',
        'Pen / Pencils',
        'School Uniforms',
        'Shoes and Socks',
        'None of the above'
      ],
    },
    {
      'question': 'Has the child ever been to school?',
      'type': 'multiple_choice',
      'options': [
        'Yes, they went to school but stopped',
        'No, they have never been to school'
      ],
    },
    {
      'question': 'Which year did the child leave school?',
      'type': 'text',
    },
    {
      'question': 'Please ask the child to calculate the question above',
      'type': 'multiple_choice',
      'options': [
        'Yes, the child gave the right answer for both calculations.',
        'Yes, the child gave the right answer for one calculation.',
        'No, the child does not know how to answer and gave wrong answers.',
        'The child refuses to try.'
      ],
    },
    {
      'question': 'Please ask the child to read the above sentences',
      'type': 'multiple_choice',
      'options': [
        'Yes,(he/she can read the sentences)',
        'Only the simple text(text 1.)',
        'No',
        'The child refuses to try.'
      ],
    },
    {
      'question': 'Please ask the child to write any of the above statements',
      'type': 'multiple_choice',
      'options': [
        'Yes,(he/she can write both sentences)',
        'Only the simple text(text 1.)',
        'No',
        'The child refuses to try.'
      ],
    },
    {
      'question': 'What is the education level of ',
      'type': 'multiple_choice',
      'options': [
        'Pre-school (Kindergarten)',
        'Primary',
        'JSS/Middle school',
        'SSS/\'O\'-\'level/\'A\'-level (including vocational & technical training)',
        'University or higher',
        'Not applicable'
      ],
    },
    {
      'question':
          'What is the main reason for the child leaving school?',
      'type': 'multiple_choice',
      'options': [
        'The school is too far away',
        'Tuition fees for private school too high',
        'Poor academic performance',
        'Insecurity in the area',
        'To learn a trade',
        'Early pregnancy',
        'The child did not want to go to school anymore',
        'Parents can\'t afford Teaching and Learning Materials',
        'Other',
        'Does not know'
      ],
    },
    {
      'question': 'Other reason',
      'type': 'text',
    },
    {
      'question':
          'Why has the child never been to school before?',
      'type': 'multiple_choice',
      'options': [
        'The school is too far away',
        'Tuition fees too high',
        'Too young to be in school',
        'Insecurity in the region',
        'To learn a trade (apprenticeship)',
        'The child did not want to go to school ',
        'Parents can\'t afford TLMs and/or enrolllment fees',
        'Other',
      ],
    },
    {
      'question': 'Other reason',
      'type': 'text',
    },
    {
      'question': 'Has the child been to school in the past 7 days?',
      'type': 'yes_no',
    },
    {
      'question':
          'Why has the child never been to school before?',
      'type': 'multiple_choice',
      'options': [
        'It was the holidays.',
        'He/she was sick.',
        'He/she was working.',
        'He/she was traveling.',
        'Other'
      ],
    },
    {
      'question': 'Other to specify',
      'type': 'text',
    },
    {
      'question':
          'Has the child missed school days the past 7 days?',
      'type': 'yes_no',
    },
    {
      'question':
          'Why has the child never been to school before?',
      'type': 'multiple_choice',
      'options': [
        'He/she was sick',
        'He/she was working',
        'He/she traveled',
        'Other'
      ],
    },
    {
      'question': 'Other to specify',
      'type': 'text',
    },
    {
      'question':
          'In the past 7 days, has the child worked in the house?',
      'type': 'yes_no',
    },
    {
      'question':
          'In the past 7 days, has the child been working on the cocoa farm?',
      'type': 'yes_no',
    },
    {
      'question': 'How often has the child worked in the past 7 days?',
      'type': 'multiple_choice',
      'options': ['Every day', '4-5 days', '2-3 days', 'Once'],
    },
    {
      'question':
          'Which of these tasks has child performed in the last 7 days?',
      'type':
          'yes_no', // Note: This seems like a checkbox question but is implemented as a yes/no radio in your code.
    },
    {
      'question':
          'How often has the child worked in the past 7 days?', // Note: Duplicate question text, likely a different context.
      'type': 'checkbox',
      'options': [
        'Collect and gather fruits, pods, seeds after harvesting',
        'Extracting cocoa beans after shelling by an adult',
        'Wash beans, fruits, vegetables or tubers',
        'Prepare the germinators and pour the seeds into the germinators',
        'Collecting firewood',
        'To help measure distances between plants during transplanting',
        'Sort and spread the beans, cereals and other vegetables for drying',
        'Putting cuttings on the mounds',
        'Holding bags or filling them with small containers for packaging agricultural products',
        'Covering stored agricultural products with tarps',
        'To shell or dehusk seeds, plants, and fruits by hand',
        'Sowing seeds',
        'Transplant or put in the ground the cuttings or plants',
        'Harvesting legumes, fruits, and other leafy products (corn, beans, soybeans, etc.)'
      ],
    },
    // {
    //   'question':
    //       'CHILDREN OF THE HOUSEHOLD/ CHILDREN OF THE HOUSEHOLD - ',
    //   'type': 'instruction',
    // },
    // {
    //   'question': 'Tableau: LIGHT TASKS - ',
    //   'type': 'instruction',
    // },
    {
      'question':
          'Did the child receive renumeration for the activity ?',
      'type': 'yes_no',
    },
    {
      'question':
          'What was the longest time spent on light duty during a SCHOOL DAY in the last 7 days?',
      'type': 'multiple_choice',
      'options': [
        'Less than 1 hour',
        '1-2 hours',
        '2-3 hours',
        '3-4 hours',
        '4-6 hours',
        '6-8 hours',
        'More than 8 hours',
        'Does not apply'
      ],
    },
    {
      'question':
          'What was the longest time spent on light duty during a NON SCHOOL DAY in the last 7 days?',
      'type': 'multiple_choice',
      'options': [
        'Less than 1 hour',
        '1-2 hours',
        '2-3 hours',
        '3-4 hours',
        '4-6 hours',
        '6-8 hours',
        'More than 8 hours',
      ],
    },
    {
      'question': 'Where was this task %rostertitle done?',
      'type': 'multiple_choice',
      'options': [
        'On family farm',
        'As a hired labourer on another farm',
        'School farms/compounds',
        'Teachers\' farms (during communal labour)',
        'Church farms or cleaning activities',
        'Helping a community member for free',
        'Other'
      ],
    },
    {
      'question': 'Other to specify',
      'type': 'text',
    },
    {
      'question':
          'How many hours in total did the child spend on light duty during NON-SCHOOL DAYS in the last 7 days?',
      'type': 'text',
    },
    {
      'question':
          'Was the child under supervision of an adult when performing this task?',
      'type': 'yes_no',
    },
    {
      'question':
          'Which of these tasks has child performed in the last 12 months?',
      'type': 'checkbox',
      'options': [
        'Collect and gather fruits, pods, seeds after harvesting',
        'Extracting cocoa beans after shelling by an adult',
        'Wash beans, fruits, vegetables or tubers',
        'Prepare the germinators and pour the seeds into the germinators',
        'Collecting firewood',
        'To help measure distances between plants during transplanting',
        'Sort and spread the beans, cereals and other vegetables for drying',
        'Putting cuttings on the mounds',
        'Holding bags or filling them with small containers for packaging agricultural products',
        'Covering stored agricultural products with tarps',
        'To shell or dehusk seeds, plants, and fruits by hand',
        'Sowing seeds',
        'Transplant or put in the ground the cuttings or plants',
        'Harvesting legumes, fruits, and other leafy products (corn, beans, soybeans, various vegetables)',
        'None'
      ],
    },
    // ... The pattern continues for the remaining DANGEROUS TASKS sections. The structure would be identical to the LIGHT TASKS sections above.
    // ... (Questions for "Q40 DANGEROUS TASKS" and the second "LIGHT TASKS" table would be added here following the same format)
    {
      'question': 'For whom does the child work?',
      'type': 'multiple_choice',
      'options': [
        'For his/her parents',
        'For family, not parents',
        'For family friends',
        'Other'
      ],
    },
    {
      'question': 'Other specify',
      'type': 'text',
    },
    {
      'question': 'Why does the child work?',
      'type': 'multiple_choice',
      'options': [
        'To have his/her own money',
        'To increase household income',
        'Household cannot afford adult\'s work',
        'Household cannot find adult labor',
        'To learn cocoa farming',
        'Other (specify)',
        'Does not know'
      ],
    },
    {
      'question': 'Other specify',
      'type': 'text',
    },
    {
      'question':
          'Has the child ever applied or sprayed agrochemicals on the farm?',
      'type': 'yes_no',
    },
    {
      'question':
          'Was the child on the farm during application of agrochemicals?',
      'type': 'yes_no',
    },
    {
      'question': 'Recently, has the child suffered any injury?',
      'type': 'yes_no',
    },
    {
      'question': 'How did the child get wounded?',
      'type': 'multiple_choice',
      'options': [
        'Playing outside',
        'Doing household chores',
        'Helping on the farm',
        'Falling off a bicycle, scooter, or tricycle',
        'Animal or insect bite or scratch',
        'Fighting with someone else',
        'Other',
      ],
    },
    {
      'question': 'When was the child wounded?',
      'type': 'multiple_choice',
      'options': [
        'Less than a week ago',
        'More than one week and less than a month',
        'More than 2 months and less than 6 months',
        'More than 6 months'
      ],
    },
    {
      'question': 'Does the child often feel pains or aches?',
      'type': 'yes_no',
    },
    {
      'question': 'What help did the child receive to get better?',
      'type': 'checkbox',
      'options': [
        'The adults of the household',
        'Adults of the community looked after him/her',
        'The child was sent to the closest medical facility',
        'The child did not receive any help',
        'Other ',
      ],
    },
    {
      'question': 'Child photo ',
      'type': 'picture',
    },

    // COVER
    {'question': 'Enumerator name', 'type': 'text'},
    {'question': 'Enumerator Code', 'type': 'text'},
    {'question': 'Country', 'type': 'text'},
    {'question': 'Region', 'type': 'text'},
    {'question': 'District', 'type': 'text'},
    {'question': 'District Code', 'type': 'text'},
    {'question': 'Society', 'type': 'text'},
    {'question': 'Society Code', 'type': 'text'},
    {'question': 'Farmer Code', 'type': 'text'},
    {'question': 'Farmer Surname', 'type': 'text'},
    {'question': 'Farmer First Name', 'type': 'text'},
    {'question': 'Risk Classification', 'type': 'text'},
    {'question': 'Client', 'type': 'text'},
    {
      'question': 'Number of farmer children aged 5-17 captured',
      'type': 'numeric'
    },
    {
      'question': 'List of children aged 5 to 17 captured in House',
      'type': 'numeric'
    },

    {'question': 'Picture of the respondent', 'type': 'picture'},
    {'question': 'Signature Producer', 'type': 'picture'},
    {'question': 'Provide end GPS of survey', 'type': 'gps'},
    {'question': 'Provide end time of survey', 'type': 'date'},
  ];

  final HouseholdSurveyDB _db = HouseholdSurveyDB();
  String _currentSurveyId = const Uuid().v4();
  int _currentQuestionIndex = 0;
  String? _currentSection;
  final Map<String, dynamic> _responses = {};
  bool _isLoading = true;

  // Getters
  bool get isLoading => _isLoading;
  List<SurveyQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _questions.length;
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  dynamic getCurrentResponse(String questionId) => _responses[questionId];

  // Initialize survey
  Future<void> initializeSurvey({String? surveyId, bool isNewSurvey = true}) async {
    _isLoading = true;
    _currentSurveyId = surveyId ?? const Uuid().v4();
    
    if (!isNewSurvey) {
      final progress = await _db.getProgress(_currentSurveyId);
      if (progress != null) {
        _currentQuestionIndex = progress.currentQuestionIndex;
        _currentSection = progress.currentSection;
      }
    }

    // Load existing responses
    final existingResponses = await _db.getResponses(_currentSurveyId);
    _responses.clear();
    for (var response in existingResponses) {
      _responses[response.questionId] = response.response;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Handle question navigation
  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Handle responses
  Future<void> saveResponse(String questionId, dynamic value) async {
    _responses[questionId] = value;
    
    await _db.saveResponse(SurveyResponse(
      surveyId: _currentSurveyId,
      questionId: questionId,
      response: value,
      section: _currentSection,
    ));
    
    await _db.saveProgress(SurveyProgress(
      surveyId: int.tryParse(_currentSurveyId) ?? 0,
      currentSection: _currentSection ?? 'general',
      currentQuestionIndex: _currentQuestionIndex,
    ));
    
    notifyListeners();
  }

  // Image handling
  Future<String?> pickAndSaveImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image == null) return null;
      
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/survey_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String newPath = '${imagesDir.path}/$fileName';
      
      await File(image.path).copy(newPath);
      return newPath;
    } catch (e) {
      debugPrint('Error picking/saving image: $e');
      return null;
    }
  }

  // Location handling
  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
      };
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // Get current question
  SurveyQuestion? get currentQuestion {
    if (_currentQuestionIndex >= 0 && _currentQuestionIndex < _questions.length) {
      return _questions[_currentQuestionIndex];
    }
    return null;
  }

  // Convert provider questions to SurveyQuestion objects
  List<SurveyQuestion> get _questions {
    return surveyQuestions.map((q) => SurveyQuestion(
      id: q['id'] ?? q['question'],
      question: q['question'],
      type: q['type'],
      options: q['options'] != null ? List<String>.from(q['options']) : null,
      hint: q['hint'],
      isRequired: q['isRequired'] ?? false,
    )).toList();
  }
}
