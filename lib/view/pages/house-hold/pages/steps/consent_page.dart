import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../form_fields.dart';

class ConsentPage extends StatefulWidget {
  final DateTime? interviewStartTime;
  final String timeStatus;
  final Position? currentPosition;
  final String locationStatus;
  final bool isGettingLocation;
  final String? communityType;
  final String? residesInCommunityConsent;
  final String? farmerAvailable;
  final String? farmerStatus;
  final String? availablePerson;
  final String? otherSpecification;
  final String? otherCommunityName;
  final bool consentGiven;
  final TextEditingController otherSpecController;
  final TextEditingController otherCommunityController;
  final VoidCallback onRecordTime;
  final VoidCallback onGetLocation;
  final ValueChanged<String?> onCommunityTypeChanged;
  final ValueChanged<String?> onResidesInCommunityChanged;
  final ValueChanged<String?> onFarmerAvailableChanged;
  final ValueChanged<String?> onFarmerStatusChanged;
  final ValueChanged<String?> onAvailablePersonChanged;
  final ValueChanged<bool> onConsentChanged;
  final ValueChanged<String> onOtherSpecChanged;
  final ValueChanged<String> onOtherCommunityChanged;
  final VoidCallback onNext;

  const ConsentPage({
    Key? key,
    required this.interviewStartTime,
    required this.timeStatus,
    required this.currentPosition,
    required this.locationStatus,
    required this.isGettingLocation,
    required this.communityType,
    required this.residesInCommunityConsent,
    required this.farmerAvailable,
    required this.farmerStatus,
    required this.availablePerson,
    required this.otherSpecification,
    required this.otherCommunityName,
    required this.consentGiven,
    required this.otherSpecController,
    required this.otherCommunityController,
    required this.onRecordTime,
    required this.onNext,
    required this.onGetLocation,
    required this.onCommunityTypeChanged,
    required this.onResidesInCommunityChanged,
    required this.onFarmerAvailableChanged,
    required this.onFarmerStatusChanged,
    required this.onAvailablePersonChanged,
    required this.onConsentChanged,
    required this.onOtherSpecChanged,
    required this.onOtherCommunityChanged,
  }) : super(key: key);

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  bool _consentGiven = false;
  bool _declinedConsent = false;
  // Reusable card widget for form questions
  Widget _buildQuestionCard({required Widget child}) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100, left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionCard(child: _buildTimePickerField()),
          const SizedBox(height: 8),
          _buildQuestionCard(child: _buildGPSField()),
          const SizedBox(height: 8),
          _buildQuestionCard(child: _buildCommunityTypeSection()),
          const SizedBox(height: 8),
          _buildQuestionCard(child: _buildResidenceConfirmation()),

          // Show community name field if resident is not in this community
          if (widget.residesInCommunityConsent == 'No')
            ..._buildNonResidentFields()
                .map((widget) => _buildQuestionCard(child: widget))
                .toList(),

          _buildQuestionCard(child: _buildFarmerAvailability()),
          if (widget.farmerAvailable == 'No')
            ..._buildFarmerNotAvailableFields()
                .map((widget) => _buildQuestionCard(child: widget))
                .toList(),
          const SizedBox(height: 8),
          const SizedBox(height: 8),
          _buildQuestionCard(child: _buildConsentSection()),
        ],
      ),
    );
  }

  Widget _buildTimePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Interview Start Time',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.timeStatus,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: widget.interviewStartTime != null
                    ? Colors.green
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onRecordTime,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 1,
            ),
            icon: const Icon(Icons.access_time, size: 20),
            label: Text(
              widget.interviewStartTime == null
                  ? 'Record Start Time'
                  : 'Update Time',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGPSField() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GPS Location',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  widget.currentPosition != null ? 'Recorded' : 'Not recorded',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: widget.currentPosition != null
                        ? Colors.green
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (widget.currentPosition != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.locationStatus,
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    widget.isGettingLocation ? null : widget.onGetLocation,
                icon: widget.isGettingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.gps_fixed, size: 20),
                label: Text(
                  widget.isGettingLocation
                      ? 'Getting Location...'
                      : 'Get Current Location',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor:
                      widget.currentPosition != null ? Colors.green : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the type of community',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FormFields.buildRadioGroup<String>(
                context: context,
                label: '',
                value: widget.communityType,
                items: const [
                  MapEntry('Town', 'Town'),
                  MapEntry('Village', 'Village'),
                  MapEntry('Camp', 'Camp'),
                ],
                onChanged: widget.onCommunityTypeChanged,
                isRequired: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResidenceConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFields.buildRadioGroup<String>(
          context: context,
          label: 'Does the farmer reside in this community? *',
          value: widget.residesInCommunityConsent,
          items: const [
            MapEntry('Yes', 'Yes'),
            MapEntry('No', 'No'),
          ],
          onChanged: widget.onResidesInCommunityChanged,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildFarmerAvailability() {
    return FormFields.buildRadioGroup<String>(
      context: context,
      label: 'Is the farmer available for the interview? *',
      value: widget.farmerAvailable,
      items: const [
        MapEntry('Yes', 'Yes'),
        MapEntry('No', 'No'),
      ],
      onChanged: widget.onFarmerAvailableChanged,
      isRequired: true,
    );
  }

  List<Widget> _buildNonResidentFields() {
    return [
      FormFields.buildTextField(
        context: context,
        label: 'If No, what is the name of the community where the farmer '
            'resides in? ',
        controller: widget.otherCommunityController,
        onChanged: widget.onOtherCommunityChanged,
        isRequired: true,
      ),
      if (widget.availablePerson == 'Other')
        FormFields.buildTextField(
          context: context,
          label: 'Please specify',
          controller: widget.otherSpecController,
          onChanged: widget.onOtherSpecChanged,
          isRequired: true,
        ),
    ];
  }

  List<Widget> _buildFarmerNotAvailableFields() {
    return [
      const SizedBox(height: 16),
      FormFields.buildRadioGroup<String>(
        context: context,
        label: 'If No, for what reason? *',
        value: widget.farmerStatus,
        items: const [
          MapEntry('Non-resident', 'Non-resident'),
          MapEntry('Deceased', 'Deceased'),
          MapEntry('Doesn\'t work with TOUTON anymore',
              'Doesn\'t work with TOUTON anymore'),
          MapEntry('Other', 'Other'),
        ],
        onChanged: widget.onFarmerStatusChanged,
        isRequired: true,
      ),
      if (widget.farmerStatus == 'Other')
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: FormFields.buildTextField(
            context: context,
            label: 'Other to specify',
            controller: widget.otherSpecController,
            onChanged: widget.onOtherSpecChanged,
            isRequired: true,
          ),
        ),
      if (widget.farmerStatus == 'Non-resident' ||
          widget.farmerStatus == 'Other') ...[
        const SizedBox(height: 16),
        FormFields.buildRadioGroup<String>(
          context: context,
          label: 'Who is available for the interview? ',
          value: widget.availablePerson,
          items: const [
            MapEntry('Caretaker', 'Caretaker'),
            MapEntry('Spouse', 'Spouse'),
            MapEntry('Nobody', 'Nobody'),
          ],
          onChanged: widget.onAvailablePersonChanged,
          isRequired: true,
        ),
      ],
    ];
  }

  @override
  void initState() {
    super.initState();
    // Initialize with the parent's consent value
    setState(() {
      _consentGiven = widget.consentGiven;
      _declinedConsent = !widget.consentGiven;
    });
  }

  void _handleConsentChange(bool? value) {
    if (value != null) {
      setState(() {
        _consentGiven = value;
        _declinedConsent = !value;
        widget.onConsentChanged(_consentGiven);
      });
    }
  }

  void _handleDeclineChange(bool? value) {
    if (value != null) {
      setState(() {
        _declinedConsent = value;
        _consentGiven = !value;
        widget.onConsentChanged(_consentGiven);
      });
    }
  }

  Widget _buildConsentSection() {
    // Skip consent if farmer is not available or doesn't work with TOUTON anymore
    bool shouldSkipConsent = false;
    if (widget.farmerAvailable == 'No' ||
        widget.farmerStatus == 'Doesn\'t work with TOUTON anymore') {
      shouldSkipConsent = true;
    }

    if (shouldSkipConsent) {
      return const SizedBox.shrink();
    }

    // Show the consent UI
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consent for Data Processing',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'By selecting « Yes, I confirm », I hereby give my free, explicit and unequivocal consent to the processing of my personal data for purposes below ("Purpose") and in accordance with the principles set out in this note ("Note").',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'I agree to the purpose envisaged that CJ COMMODITIES/NANANOM can collect and process these types of personal data including the following data:',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        '• Name, telephone number, e-mail address\n• Gender, date of birth, marital status\n• Level of education\n• Information on my farm and professional experience\n• Information on my household and my family\n• My standard of living and social/economic situation',
                        style: TextStyle(
                            fontSize: 14, color: Colors.black87, height: 1.5),
                      ),
                    ),
                    const Text(
                      'The said purposes relate to the implementation of sustainable development/agricultural programs and projects initiated for the benefit of cocoa farmers and agricultural organizations, the optimization of traceability and sustainability of cocoa production and supply as well as the improvement of yields and livelihoods of cocoa farmers worldwide.',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'I agree that CJ COMMODITIES/NANANOM can communicate my personal data to other recipients in Ghana, partner entities and service providers in Ghana that CJ COMMODITIES/NANANOM can or could engage in the realization of its purposes.',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'CJ COMMODITIES/NANANOM shall take technical and organizational measures to ensure the security of my personal data and to protect my personal data against unauthorized or unlawful processing, against loss, destruction or accidental damage.',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'I recognize and understand that, with regard to my personal data, I have the right to:',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                          fontWeight: FontWeight.bold),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        '• Know what personal data concerning me are processed and to object to their use\n• Request access, rectification and erasure of my personal data\n• Restrict the processing of my personal data and the right to data portability\n• Withdraw my consent to the processing of my personal data at any time\n• Lodge a complaint with the competent supervisory authority',
                        style: TextStyle(
                            fontSize: 14, color: Colors.black87, height: 1.5),
                      ),
                    ),
                    const Text(
                      'I confirm that before accepting the present note, I have received reading and explanation of its content, and confirm that, insofar as I have provided CJ COMMODITIES/NANANOM with personal data on one of my family members, I have been authorized to do so by the family member concerned.',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'I accept that my consent to the present note can be given electronically, and that this electronic consent has the same legal value as my consent given by hand.',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Accept checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _consentGiven,
                  onChanged: _handleConsentChange,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'I accept the above conditions',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            // Decline checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _declinedConsent,
                  onChanged: _handleDeclineChange,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'No i refuse and end the survey',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_declinedConsent)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle survey refusal submission
                    // You might want to add your submission logic here
                    Navigator.of(context)
                        .pop(); // Or navigate to a thank you screen
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    elevation: 2,
                  ),
                  child: const Text(
                    'Submit Refusal',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            else if (_consentGiven)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 2,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ));
  }
}
