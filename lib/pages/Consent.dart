import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/fields/drawer.dart';
import 'package:surveyflow/fields/dropdown.dart';
import 'package:surveyflow/fields/gpsfield.dart';
import 'package:surveyflow/fields/radiobuttons.dart';
import 'package:surveyflow/fields/timepicker.dart';
import 'package:surveyflow/pages/cover.dart';
import 'package:surveyflow/pages/farmerident.dart';

class Consent extends StatefulWidget {
  final Map<String, dynamic> survey;

  const Consent({super.key, required this.survey});

  @override
  State<Consent> createState() => _ConsentState();
}

class _ConsentState extends State<Consent> {
  // State variables for radio buttons
  String? _communityType;
  String? _residesInCommunity;
  String? _farmerAvailable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CONSENT AND LOCATION',
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
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
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: () {
              // Add functionality here
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      drawer: CustomDrawer(currentPage: 'CONSENT'),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
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
                        TimePickerField(
                            question: 'Record the interview start time'),
                        const SizedBox(height: 16),
                        GPSField(question: 'GPS point of the household'),
                        const SizedBox(height: 16),
                        RadioButtonField(
                          question: 'Select the type of community',
                          options: ['Town', 'Village', 'Camp'],
                          value: _communityType,
                          onChanged: (value) {
                            setState(() {
                              _communityType = value;
                            });
                          },
                        ),
                        RadioButtonField(
                          question:
                              'Does the farmer reside in the community stated on the cover?',
                          options: ['Yes', 'No'],
                          value: _residesInCommunity,
                          onChanged: (value) {
                            setState(() {
                              _residesInCommunity = value;
                            });
                          },
                        ),
                        if (_residesInCommunity == 'No')
                          _buildQuestionField(
                              'If No, provide the name of the community the farmer resides in'),
                        RadioButtonField(
                          question: 'Is the farmer available?',
                          options: ['Yes', 'No'],
                          value: _farmerAvailable,
                          onChanged: (value) {
                            setState(() {
                              _farmerAvailable = value;
                            });
                          },
                        ),
                        DropdownField(
                          question: 'Farmer status',
                          options: [
                            'Non-Resident',
                            'Deceased',
                            'Doesn\'t work with Touton anymore',
                            'Other',
                          ],
                        ),
                        _buildQuestionField('Other to specify'),
                        _buildQuestionField(
                            'Who is available to answer for farmer?'),
                        DropdownField(
                          question: 'Select respondent',
                          options: ['Caretaker', 'Spouse', 'Nobody'],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Questionnaire()),
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
                        MaterialPageRoute(builder: (context) => Farmerident()),
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

  Widget _buildQuestionField(String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style:
                GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            ),
          ),
        ],
      ),
    );
  }
}
