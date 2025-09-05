import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/fields/drawer.dart';
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
  String? _farmerStatus;
  String? _availablePerson;
  String? _otherCommunityName;
  String? _otherSpecification;
  final TextEditingController _communityNameController =
      TextEditingController();
  final TextEditingController _otherSpecController = TextEditingController();
  bool _consentGiven = false;

  @override
  void initState() {
    super.initState();
    _communityNameController.addListener(() {
      setState(() {
        _otherCommunityName = _communityNameController.text;
      });
    });
    _otherSpecController.addListener(() {
      setState(() {
        _otherSpecification = _otherSpecController.text;
      });
    });
  }

  @override
  void dispose() {
    _communityNameController.dispose();
    _otherSpecController.dispose();
    super.dispose();
  }

  bool get _allRequiredFieldsFilled {
    // Check basic required fields
    if (_communityType == null ||
        _residesInCommunity == null ||
        _farmerAvailable == null) {
      return false;
    }

    // Check if farmer is not available
    if (_farmerAvailable == 'No') {
      if (_farmerStatus == null) return false;

      // Check "Other" specification
      if (_farmerStatus == 'Other' &&
          (_otherSpecification == null || _otherSpecification!.isEmpty)) {
        return false;
      }

      // Check non-resident case
      if (_farmerStatus == 'Non-Resident' && _availablePerson == null) {
        return false;
      }

      // Check consent for unavailable farmers
      if (!_consentGiven) {
        return false;
      }
    }

    // Check community name if farmer doesn't reside in community
    if (_residesInCommunity == 'No' &&
        (_otherCommunityName == null || _otherCommunityName!.isEmpty)) {
      return false;
    }

    return true;
  }

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
                            question: 'Record the interview start time*'),
                        const SizedBox(height: 16),
                        GPSField(question: 'GPS point of the household*'),
                        const SizedBox(height: 16),
                        RadioButtonField(
                          question: 'Select the type of community*',
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
                              'Does the farmer reside in the community stated on the cover?*',
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
                              'If No, provide the name of the community the farmer resides in*',
                              _communityNameController),
                        RadioButtonField(
                          question: 'Is the farmer available?*',
                          options: ['Yes', 'No'],
                          value: _farmerAvailable,
                          onChanged: (value) {
                            setState(() {
                              _farmerAvailable = value;
                              // Reset dependent fields when availability changes
                              if (value == 'Yes') {
                                _farmerStatus = null;
                                _availablePerson = null;
                                _otherSpecController.clear();
                                _consentGiven = false;
                              }
                            });
                          },
                        ),

                        if (_farmerAvailable == 'No') ...[
                          RadioButtonField(
                            question: 'If No, for what reason?*',
                            options: [
                              'Non-Resident',
                              'Deceased',
                              'Doesn\'t work with Touton anymore',
                              'Other',
                            ],
                            value: _farmerStatus,
                            onChanged: (newValue) {
                              setState(() {
                                _farmerStatus = newValue;
                                // Reset available person when status changes
                                _availablePerson = null;
                              });
                            },
                          ),
                          if (_farmerStatus == 'Other')
                            _buildQuestionField(
                                'Other to specify*', _otherSpecController),
                          if (_farmerStatus == 'Non-Resident')
                            RadioButtonField(
                              question:
                                  'Who is available to answer for farmer?*',
                              options: ['Caretaker', 'Spouse', 'Nobody'],
                              value: _availablePerson,
                              onChanged: (value) {
                                setState(() {
                                  _availablePerson = value;
                                });
                              },
                            ),
                          const Divider(),
                          Center(
                            child: Text(
                              'CONSENT TO THE PROCESSING OF PERSONAL DATA*',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF006A4E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Consent text part 1
                                const Text(
                                  'By selecting « Yes, I confirm », I hereby give my free, explicit and unequivocal consent to the processing of my personal data for purposes below ("Purpose") and in accordance with the principles set out in this note ("Note").',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),

                                // Consent text part 2
                                const Text(
                                  'I agree to the purpose envisaged that CJ COMMODITIES/NANANOM can collect and process these types of personal data including the following data: name, telephone number, e-mail address, gender, date of birth, marital status, level of education, information on my farm, professional experience, information on my household and my family, my standard of living and my social and economic situation.',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),

                                // Consent text part 3
                                const Text(
                                  'The said purposes relate to the implementation of sustainable development/agricultural programs and projects initiated for the benefit of cocoa farmers and agricultural organizations, the optimization of traceability and sustainability of cocoa production and supply as well as the improvement of yields and livelihoods of cocoa farmers worldwide.',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),

                                // Consent text part 4
                                const Text(
                                  'I agree that CJ COMMODITIES/NANANOM can communicate my personal data to other recipients in Ghana, partner entities and service providers in Ghana that CJ COMMODITIES/NANANOM can or could engage in the realization of its purposes.',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),

                                // Consent text part 5
                                const Text(
                                  'I agree that CJ COMMODITIES/NANANOM can save and process the personal data collected. CJ COMMODITIES/NANANOM will ensure that all processing of my personal data is in accordance with the laws applicable to the protection of personal data. CJ COMMODITIES/NANANOM shall take technical and organizational measures to ensure the security of my personal data and to protect my personal data against unauthorized or unlawful processing, against loss, destruction or accidental damage.',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),

                                // Consent text part 6
                                const Text(
                                  'In addition, CJ COMMODITIES/NANANOM shall restrict access to my personal data to persons and entities with a need to know such data in accordance with the purposes. CJ COMMODITIES/NANANOM will keep my personal data in accordance with the legal obligations in force and as long as necessary for the purposes for which they were collected.',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),

                                // Rights section
                                const Text(
                                  'I recognize and understand that, with regard to my personal data, I have the right to:',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '(i) Know what personal data concerning me are processed and to object to the use you make of them;'),
                                      SizedBox(height: 4),
                                      Text(
                                          '(ii) Request access, rectification and erasure of my personal data;'),
                                      SizedBox(height: 4),
                                      Text(
                                          '(iii) Restrict the processing of my personal data and the right to data portability;'),
                                      SizedBox(height: 4),
                                      Text(
                                          '(iv) Withdraw my consent to the processing of my personal data at any time; and'),
                                      SizedBox(height: 4),
                                      Text(
                                          '(v) Lodge a complaint with the competent supervisory authority responsible for enforcing the rules on the protection of personal data.'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Final confirmation
                                const Text(
                                  'I confirm that before accepting the present note, I have received reading and explanation of its content by another person and confirm that, insofar as I have provided CJ COMMODITIES/NANANOM with personal data on one of my family members, I have been authorized to do so by the family member concerned.',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'I accept that my consent to the present note can be given by electronic means, and that this electronic consent has the same legal value as my consent given by hand.',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _consentGiven,
                                      onChanged: (value) {
                                        setState(() {
                                          _consentGiven = value ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xFF00754B),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'I agree to the terms - « Yes, I confirm »',
                                        style:
                                            GoogleFonts.poppins(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                        ],
                        Center(
                          child: Text(
                            'CONSENT TO THE PROCESSING OF PERSONAL DATA*',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF006A4E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Consent text part 1
                              const Text(
                                'By selecting « Yes, I confirm », I hereby give my free, explicit and unequivocal consent to the processing of my personal data for purposes below ("Purpose") and in accordance with the principles set out in this note ("Note").',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),

                              // Consent text part 2
                              const Text(
                                'I agree to the purpose envisaged that CJ COMMODITIES/NANANOM can collect and process these types of personal data including the following data: name, telephone number, e-mail address, gender, date of birth, marital status, level of education, information on my farm, professional experience, information on my household and my family, my standard of living and my social and economic situation.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),

                              // Consent text part 3
                              const Text(
                                'The said purposes relate to the implementation of sustainable development/agricultural programs and projects initiated for the benefit of cocoa farmers and agricultural organizations, the optimization of traceability and sustainability of cocoa production and supply as well as the improvement of yields and livelihoods of cocoa farmers worldwide.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),

                              // Consent text part 4
                              const Text(
                                'I agree that CJ COMMODITIES/NANANOM can communicate my personal data to other recipients in Ghana, partner entities and service providers in Ghana that CJ COMMODITIES/NANANOM can or could engage in the realization of its purposes.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),

                              // Consent text part 5
                              const Text(
                                'I agree that CJ COMMODITIES/NANANOM can save and process the personal data collected. CJ COMMODITIES/NANANOM will ensure that all processing of my personal data is in accordance with the laws applicable to the protection of personal data. CJ COMMODITIES/NANANOM shall take technical and organizational measures to ensure the security of my personal data and to protect my personal data against unauthorized or unlawful processing, against loss, destruction or accidental damage.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),

                              // Consent text part 6
                              const Text(
                                'In addition, CJ COMMODITIES/NANANOM shall restrict access to my personal data to persons and entities with a need to know such data in accordance with the purposes. CJ COMMODITIES/NANANOM will keep my personal data in accordance with the legal obligations in force and as long as necessary for the purposes for which they were collected.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),

                              // Rights section
                              const Text(
                                'I recognize and understand that, with regard to my personal data, I have the right to:',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '(i) Know what personal data concerning me are processed and to object to the use you make of them;'),
                                    SizedBox(height: 4),
                                    Text(
                                        '(ii) Request access, rectification and erasure of my personal data;'),
                                    SizedBox(height: 4),
                                    Text(
                                        '(iii) Restrict the processing of my personal data and the right to data portability;'),
                                    SizedBox(height: 4),
                                    Text(
                                        '(iv) Withdraw my consent to the processing of my personal data at any time; and'),
                                    SizedBox(height: 4),
                                    Text(
                                        '(v) Lodge a complaint with the competent supervisory authority responsible for enforcing the rules on the protection of personal data.'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Final confirmation
                              const Text(
                                'I confirm that before accepting the present note, I have received reading and explanation of its content by another person and confirm that, insofar as I have provided CJ COMMODITIES/NANANOM with personal data on one of my family members, I have been authorized to do so by the family member concerned.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'I accept that my consent to the present note can be given by electronic means, and that this electronic consent has the same legal value as my consent given by hand.',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Yes, I confirm option
                                  Row(
                                    children: [
                                      Radio<bool>(
                                        value: true,
                                        groupValue: _consentGiven ? true : null,
                                        onChanged: (value) {
                                          setState(() {
                                            _consentGiven = true;
                                          });
                                        },
                                        activeColor: const Color(0xFF00754B),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Yes, I confirm',
                                          style: GoogleFonts.poppins(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // No, I do not consent option
                                  Row(
                                    children: [
                                      Radio<bool>(
                                        value: false,
                                        groupValue: _consentGiven ? null : false,
                                        onChanged: (value) {
                                          setState(() {
                                            _consentGiven = false;
                                          });
                                        },
                                        activeColor: const Color(0xFF00754B),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'No, I do not consent',
                                          style: GoogleFonts.poppins(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Show validation error message
                        if (!_allRequiredFieldsFilled) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Please answer all required questions (*) before proceeding',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                            builder: (context) => const Questionnaire()),
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
                    onPressed: _allRequiredFieldsFilled
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Farmerident()),
                            );
                          }
                        : null, // Disable button if not all fields are filled
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allRequiredFieldsFilled
                          ? const Color(0xFF00754B)
                          : Colors.grey[400],
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

  Widget _buildQuestionField(
      String question, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              errorText: (question.contains('*') && (controller.text.isEmpty))
                  ? 'This field is required'
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
