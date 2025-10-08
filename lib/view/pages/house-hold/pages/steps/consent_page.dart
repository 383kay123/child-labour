import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/view/theme/app_theme.dart';

import '../../form_fields.dart';

// Reusable spacing constants
class _Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

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
  final VoidCallback? onPrevious;
  final VoidCallback? onSurveyEnd;

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
    this.onPrevious,
    this.onSurveyEnd,
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
  _ConsentPageState createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  bool _consentGiven = false;
  bool _declinedConsent = false;
  final TextEditingController _refusalReasonController =
      TextEditingController();
  final FocusNode _reasonFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize with the parent's consent value
    _consentGiven = widget.consentGiven;
    _declinedConsent = !widget.consentGiven;
  }

  void _handleConsentChange(bool? value) {
    if (value != null) {
      setState(() {
        _consentGiven = value;
        _declinedConsent = !value;
      });
      widget.onConsentChanged(value);
    }
  }

  void _handleDeclineChange(bool? value) {
    if (value != null) {
      setState(() {
        _declinedConsent = value;
        _consentGiven = !value;
      });
      widget.onConsentChanged(!value);

      if (value) {
        _showEndSurveyConfirmation();
      }
    }
  }

  Future<void> _showEndSurveyConfirmation() async {
    if (_refusalReasonController.text.trim().isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reason Required'),
          content: const Text(
              'Please provide a reason for declining to participate in the survey.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final shouldEndSurvey = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('End Survey'),
            content: const Text(
                'Are you sure you want to end the survey? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('END SURVEY'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldEndSurvey && mounted) {
      widget.onSurveyEnd?.call();
    } else if (mounted) {
      setState(() {
        _declinedConsent = true;
        _consentGiven = false;
      });
      widget.onConsentChanged(_consentGiven);
    }
  }

  // Reusable card widget for form questions
  Widget _buildQuestionCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: _Spacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: child,
      ),
    );
  }

  // Reusable radio button widget
  Widget _buildRadioListTile({
    required String title,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNonResidentFields() {
    return [
      FormFields.buildTextField(
        context: context,
        label: 'If no, provide the name of the community the farmer resides in',
        controller: widget.otherCommunityController,
        onChanged: widget.onOtherCommunityChanged,
        isRequired: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
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
                .map((fieldWidget) => _buildQuestionCard(child: fieldWidget))
                .toList(),

          _buildQuestionCard(child: _buildFarmerAvailability()),
          if (widget.farmerAvailable == 'No')
            ..._buildFarmerNotAvailableFields()
                .map((fieldWidget) => _buildQuestionCard(child: fieldWidget))
                .toList(),
          _buildQuestionCard(child: _buildConsentSection()),
        ],
      ),
    );
  }

  Widget _buildResidenceConfirmation() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Does the farmer reside in the community stated on the cover?',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        _buildRadioListTile(
          title: 'Yes',
          value: 'Yes',
          groupValue: widget.residesInCommunityConsent,
          onChanged: widget.onResidesInCommunityChanged,
        ),
        _buildRadioListTile(
          title: 'No',
          value: 'No',
          groupValue: widget.residesInCommunityConsent,
          onChanged: widget.onResidesInCommunityChanged,
        ),
      ],
    );
  }

  Widget _buildTimePickerField() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Interview Start Time',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: _Spacing.sm),
            Text(
              widget.timeStatus,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: widget.interviewStartTime != null
                    ? AppTheme.primaryColor
                    : textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: _Spacing.md),
        SizedBox(
          width: double.infinity,
          child: widget.interviewStartTime == null
              ? ElevatedButton.icon(
                  onPressed: widget.onRecordTime,
                  icon: const Icon(Icons.access_time, size: 20),
                  label: const Text('Record Start Time',
                      style: TextStyle(fontSize: 12)),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: _Spacing.md,
                    horizontal: _Spacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: _Spacing.sm),
                      Text(
                        'Time recorded at ${widget.interviewStartTime!.hour}:${widget.interviewStartTime!.minute.toString().padLeft(2, '0')}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildGPSField() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // if (widget.onPrevious != null)
            //   ElevatedButton(
            //     onPressed: widget.onPrevious,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.grey[300],
            //       foregroundColor: Colors.black87,
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //     child: const Text('Back'),
            //   )
            // else
            const SizedBox(width: 100), // Placeholder to maintain spacing

            Text('GPS Location',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w500, fontSize: 16)),
            Text(
              widget.isGettingLocation
                  ? 'Recording...'
                  : widget.currentPosition != null
                      ? 'Recorded'
                      : 'Not recorded',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: widget.isGettingLocation
                    ? AppTheme.accentColor
                    : widget.currentPosition != null
                        ? AppTheme.primaryColor
                        : textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
        if (widget.currentPosition != null || widget.isGettingLocation) ...[
          const SizedBox(height: _Spacing.sm),
          Text(
            widget.locationStatus,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontFamily: 'RobotoMono',
              color: widget.isGettingLocation
                  ? AppTheme.accentColor
                  : textTheme.bodySmall?.color?.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: _Spacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.isGettingLocation ? null : widget.onGetLocation,
            icon: widget.isGettingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.gps_fixed, size: 18),
            label: Text(
              widget.isGettingLocation
                  ? 'Recording Location...'
                  : 'Get Current Location',
              style: const TextStyle(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.currentPosition != null
                  ? AppTheme.primaryColor
                  : widget.isGettingLocation
                      ? AppTheme.accentColor
                      : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityTypeSection() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select the type of community',
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: _Spacing.sm),
        Column(
          children: [
            _buildRadioListTile(
              title: 'Rural',
              value: 'rural',
              groupValue: widget.communityType,
              onChanged: widget.onCommunityTypeChanged,
            ),
            _buildRadioListTile(
              title: 'Urban',
              value: 'urban',
              groupValue: widget.communityType,
              onChanged: widget.onCommunityTypeChanged,
            ),
            _buildRadioListTile(
              title: 'Semi-Urban',
              value: 'semi_urban',
              groupValue: widget.communityType,
              onChanged: widget.onCommunityTypeChanged,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFarmerAvailability() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Is the farmer available?',
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: _Spacing.sm),
        Theme(
          data: theme.copyWith(
            radioTheme: RadioThemeData(
              fillColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return theme.disabledColor;
                  }
                  return AppTheme.primaryColor;
                },
              ),
            ),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                title: Text('Yes',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                    )),
                value: 'Yes',
                groupValue: widget.farmerAvailable,
                onChanged: widget.onFarmerAvailableChanged,
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              RadioListTile<String>(
                title: Text('No',
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w300, fontSize: 14)),
                value: 'No',
                groupValue: widget.farmerAvailable,
                onChanged: widget.onFarmerAvailableChanged,
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFarmerNotAvailableFields() {
    return [
      FormFields.buildRadioGroup<String>(
        context: context,
        label: 'If No, for what reason?',
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
            label: 'If other, please specify',
            controller: widget.otherSpecController,
            onChanged: widget.onOtherSpecChanged,
            isRequired: true,
          ),
        ),
      if (widget.farmerStatus == 'Non-resident' ||
          widget.farmerStatus == 'Other')
        FormFields.buildTextField(
          context: context,
          label:
              'Please specify the name of the community the farmer resides in',
          controller: widget.otherCommunityController,
          onChanged: widget.onOtherCommunityChanged,
          isRequired: true,
        ),
      if (widget.farmerStatus == 'Non-resident' ||
          widget.farmerStatus == 'Other')
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
    ];
  }

  Widget _buildConsentSection() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Debug logging
    debugPrint('Farmer Available: ${widget.farmerAvailable}');
    debugPrint('Farmer Status: ${widget.farmerStatus}');
    debugPrint('Available Person: ${widget.availablePerson}');

    // Show consent only under these conditions:
    bool shouldShowConsent = false;

    if (widget.farmerAvailable == 'Yes') {
      shouldShowConsent = true;
      debugPrint('Showing consent: Farmer is available');
    } else if (widget.farmerStatus == 'Non-resident' &&
        widget.availablePerson != null &&
        widget.availablePerson != 'Nobody') {
      shouldShowConsent = true;
      debugPrint('Showing consent: Non-resident with available person');
    } else if (widget.farmerStatus == 'Other' &&
        widget.availablePerson != null &&
        widget.availablePerson != 'Nobody') {
      shouldShowConsent = true;
      debugPrint('Showing consent: Other reason with available person');
    } else {
      debugPrint('Skipping consent section');
    }

    if (!shouldShowConsent) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(_Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consent for Data Processing',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: _Spacing.lg),
          Container(
            height: 300,
            padding: const EdgeInsets.all(_Spacing.lg),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By selecting « Yes, I confirm », I hereby give my free, explicit and unequivocal consent to the processing of my personal data for purposes below ("Purpose") and in accordance with the principles set out in this note ("Note").',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.6,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Text(
                    'I understand that the following personal data may be collected and processed:',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.6,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: _Spacing.sm),
                  Text(
                    '• Name, telephone number, e-mail address\n• Gender, date of birth, marital status\n• Level of education\n• Information on my farm and professional experience\n• Information on my household and my family\n• My standard of living and social/economic situation',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.6,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Text(
                    'The said purposes relate to the implementation of sustainable development/agricultural programs and projects initiated for the benefit of cocoa farmers and agricultural organizations, the optimization of traceability and sustainability of cocoa production and supply as well as the improvement of yields and livelihoods of cocoa farmers worldwide.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.6,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Text(
                    'I agree that CJ COMMODITIES/NANANOM can communicate my personal data to other recipients in Ghana, partner entities and service providers in Ghana that CJ COMMODITIES/NANANOM can or could engage in the realization of its purposes.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.6,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Text(
                    'CJ COMMODITIES/NANANOM shall take technical and organizational measures to ensure the security of my personal data and to protect my personal data against unauthorized or unlawful processing, against loss, destruction or accidental damage.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.6,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: _Spacing.xl),
          // Consent checkbox
          Row(
            children: [
              Theme(
                data: theme.copyWith(
                  checkboxTheme: theme.checkboxTheme.copyWith(
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return AppTheme.primaryColor;
                        }
                        return theme.disabledColor.withOpacity(0.3);
                      },
                    ),
                  ),
                ),
                child: Checkbox(
                  value: _consentGiven,
                  onChanged: _handleConsentChange,
                ),
              ),
              const SizedBox(width: _Spacing.sm),
              Expanded(
                child: Text(
                  'Yes, I accept the above conditions',
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _Spacing.md),
          // Decline checkbox
          Row(
            children: [
              Theme(
                data: theme.copyWith(
                  checkboxTheme: theme.checkboxTheme.copyWith(
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return AppTheme.primaryColor;
                        }
                        return theme.disabledColor.withOpacity(0.3);
                      },
                    ),
                  ),
                ),
                child: Checkbox(
                  value: _declinedConsent,
                  onChanged: _handleDeclineChange,
                ),
              ),
              const SizedBox(width: _Spacing.sm),
              Expanded(
                child: Text(
                  'No, I refuse and end the survey',
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // Show refusal reason field when declined
          if (_declinedConsent) ...[
            const SizedBox(height: _Spacing.lg),
            TextField(
              controller: _refusalReasonController,
              focusNode: _reasonFocusNode,
              decoration: InputDecoration(
                labelText: 'What is your reason for refusing to participate?',
                hintText: 'Please provide your reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () {
                    _reasonFocusNode.unfocus();
                    _showEndSurveyConfirmation();
                  },
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                _showEndSurveyConfirmation();
              },
            ),
          ],
          const SizedBox(height: _Spacing.lg),

          // // Navigation Buttons
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     if (widget.onPrevious != null)
          //       ElevatedButton(
          //         onPressed: widget.onPrevious,
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Colors.grey[200],
          //           foregroundColor: Colors.black87,
          //           padding: const EdgeInsets.symmetric(
          //               horizontal: 24, vertical: 12),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //         ),
          //         child: const Text('Back'),
          //       )
          //     else
          //       const SizedBox(width: 100), // Placeholder to maintain spacing
          //
          //     const Spacer(),
          //
          //     if (widget.onSurveyEnd != null)
          //       ElevatedButton(
          //         onPressed: _declinedConsent
          //             ? _showEndSurveyConfirmation
          //             : widget.onSurveyEnd,
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor:
          //               _declinedConsent ? Colors.red : Colors.grey,
          //           foregroundColor: Colors.white,
          //           padding: const EdgeInsets.symmetric(
          //               horizontal: 24, vertical: 12),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //         ),
          //         child: Text(_declinedConsent ? 'END SURVEY' : 'NEXT'),
          //       ),
          //   ],
          // ),
          const SizedBox(height: _Spacing.lg),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refusalReasonController.dispose();
    _reasonFocusNode.dispose();
    super.dispose();
  }
}
