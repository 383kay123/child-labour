import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:human_rights_monitor/view/pages/house-hold/house_hold_controller.dart';

import '../../../../theme/app_theme.dart';
import '../../form_fields.dart';

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
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
    _consentGiven = widget.consentGiven;
    _declinedConsent = !widget.consentGiven;

    // Debug prints for initial state
    _debugPrintInitialState();
  }

  void _debugPrintInitialState() {
    debugPrint('=== CONSENT PAGE INITIAL STATE ===');
    debugPrint('Interview Start Time: ${widget.interviewStartTime}');
    debugPrint('GPS Position: ${widget.currentPosition}');
    debugPrint('Community Type: ${widget.communityType}');
    debugPrint('Resides in Community: ${widget.residesInCommunityConsent}');
    debugPrint('Farmer Available: ${widget.farmerAvailable}');
    debugPrint('Farmer Status: ${widget.farmerStatus}');
    debugPrint('Available Person: ${widget.availablePerson}');
    debugPrint('Other Specification: ${widget.otherSpecification}');
    debugPrint('Other Community Name: ${widget.otherCommunityName}');
    debugPrint('Consent Given: ${widget.consentGiven}');
    debugPrint('===================================');
  }

  void _handleConsentChange(bool? value) {
    if (value != null) {
      debugPrint('=== QUESTION RESPONSE ===');
      debugPrint('Question: Do you consent to participate in this interview?');
      debugPrint('Selected: ${value ? 'Yes' : 'No'}');
      debugPrint('Options: [Yes, No]');
      debugPrint('=========================');
      setState(() {
        _consentGiven = value;
        _declinedConsent = !value;
      });
      widget.onConsentChanged(value);
    }
  }

  void _handleDeclineChange(bool? value) {
    if (value != null) {
      debugPrint('=== QUESTION RESPONSE ===');
      debugPrint('Question: Do you consent to participate in this interview?');
      debugPrint('Selected: ${value ? 'No' : 'Yes'}');
      debugPrint('Options: [Yes, No]');
      debugPrint('=========================');

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

  void _handleCommunityTypeChanged(String? value) {
    debugPrint('=== QUESTION RESPONSE ===');
    debugPrint('Question: Select the type of community');
    debugPrint('Selected: $value');
    debugPrint('Options: [rural, urban, semi_urban]');
    debugPrint('=========================');
    widget.onCommunityTypeChanged(value);
  }

  void _handleResidesInCommunityChanged(String? value) {
    debugPrint('=== QUESTION RESPONSE ===');
    debugPrint(
        'Question: Does the farmer reside in the community stated on the cover?');
    debugPrint('Selected: $value');
    debugPrint('Options: [Yes, No]');
    debugPrint('=========================');
    widget.onResidesInCommunityChanged(value);
  }

  void _handleFarmerAvailableChanged(String? value) {
    debugPrint('=== QUESTION RESPONSE ===');
    debugPrint('Question: Is the farmer available for the interview?');
    debugPrint('Selected: $value');
    debugPrint('Options: [Yes, No]');
    debugPrint('=========================');
    widget.onFarmerAvailableChanged(value);
  }

  Future<void> _handleFarmerStatusChanged(String? value) async {
    debugPrint('=== QUESTION RESPONSE ===');
    debugPrint('Question: If No, for what reason?');
    debugPrint('Selected: $value');
    debugPrint(
        'Options: [Non-resident, Deceased, Doesn\'t work with TOUTON anymore, Other]');
    debugPrint('=========================');

    if (value == 'Deceased' || value == 'Doesn\'t work with TOUTON anymore') {
      final shouldEndSurvey = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('End Survey?'),
              content: Text(
                'You have selected "$value" as the reason. This will end the survey. Are you sure?',
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('END SURVEY'),
                ),
              ],
            ),
          ) ??
          false;

      if (shouldEndSurvey && mounted) {
        if (widget.onSurveyEnd != null) {
          widget.onSurveyEnd!();
        }
        return;
      } else {
        // If user cancels, don't update the status
        return;
      }
    }

    widget.onFarmerStatusChanged(value);
  }

  void _handleAvailablePersonChanged(String? value) {
    debugPrint('=== QUESTION RESPONSE ===');
    debugPrint('Question: Who is available for the interview?');
    debugPrint('Selected: $value');
    debugPrint('Options: [Caretaker, Spouse, Nobody]');
    debugPrint('=========================');
    widget.onAvailablePersonChanged(value);
  }

  void _handleOtherSpecChanged(String value) {
    debugPrint('=== QUESTION RESPONSE ===');
    debugPrint('Question: If other, please specify');
    debugPrint('Entered: $value');
    debugPrint('Field Type: Text Input');
    debugPrint('=========================');
    widget.onOtherSpecChanged(value);
  }

  void _handleOtherCommunityChanged(String value) {
    debugPrint('=== QUESTION RESPONSE ===');
    debugPrint(
        'Question: Provide the name of the community the farmer resides in');
    debugPrint('Entered: $value');
    debugPrint('Field Type: Text Input');
    debugPrint('=========================');
    widget.onOtherCommunityChanged(value);
  }

  void _handleRecordTime() {
    debugPrint('=== QUESTION RESPONSE ===');
    debugPrint('Action: Recorded interview start time');
    debugPrint('Time: ${DateTime.now().toIso8601String()}');
    debugPrint('=========================');
    widget.onRecordTime();
  }

  void _handleGetLocation() {
    debugPrint('=== QUESTION RESPONSE ===');
    debugPrint('Action: Getting GPS location');
    debugPrint('Time: ${DateTime.now().toIso8601String()}');
    debugPrint('=========================');
    widget.onGetLocation();
  }

  Future<void> _showEndSurveyConfirmation() async {
    if (_refusalReasonController.text.trim().isEmpty) {
      debugPrint('Refusal reason is empty - showing warning');
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

    debugPrint('Showing end survey confirmation dialog');
    final shouldEndSurvey = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('End Survey'),
            content: const Text(
                'Are you sure you want to end the survey? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () {
                  debugPrint('User cancelled survey end');
                  Navigator.pop(context, false);
                },
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  debugPrint('User confirmed survey end');
                  Navigator.pop(context, true);
                },
                child: const Text('END SURVEY'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldEndSurvey && mounted) {
      debugPrint('Survey ended by user');
      widget.onSurveyEnd?.call();
    } else if (mounted) {
      debugPrint('User changed mind - keeping survey active');
      setState(() {
        _declinedConsent = true;
        _consentGiven = false;
      });
      widget.onConsentChanged(_consentGiven);
    }
  }

  Widget _buildQuestionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: _Spacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: child,
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RadioListTile<String>(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      tileColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildTapToCaptureSection({
    required String title,
    required String placeholder,
    required String? value,
    required VoidCallback onTap,
    required IconData icon,
    bool isLoading = false,
    String? statusText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _buildQuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (statusText != null)
                Text(
                  statusText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: value != null
                        ? AppTheme.primaryColor
                        : (isDark ? Colors.white60 : Colors.grey.shade600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: _Spacing.md),
          InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(_Spacing.lg),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
                color: value == null
                    ? (isDark ? Colors.grey.shade800 : Colors.grey.shade50)
                    : (isDark
                        ? Colors.green.shade900.withOpacity(0.3)
                        : Colors.green.shade50),
              ),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: _Spacing.md),
                        Text(
                          'Recording...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          icon,
                          color: value == null
                              ? (isDark ? Colors.white60 : Colors.grey.shade600)
                              : AppTheme.primaryColor,
                        ),
                        const SizedBox(width: _Spacing.lg),
                        Expanded(
                          child: Text(
                            value ?? placeholder,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: value == null
                                  ? (isDark
                                      ? Colors.white60
                                      : Colors.grey.shade600)
                                  : (isDark
                                      ? Colors.green.shade300
                                      : Colors.green.shade800),
                              fontWeight: value == null
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNonResidentFields() {
    debugPrint('Building non-resident fields');
    return [
      _buildQuestionCard(
        child: FormFields.buildTextField(
          context: context,
          label:
              'If no, provide the name of the community the farmer resides in',
          controller: widget.otherCommunityController,
          onChanged: _handleOtherCommunityChanged,
          isRequired: true,
        ),
      ),
    ];
  }

  List<Widget> _buildFarmerNotAvailableFields() {
    debugPrint('Building farmer not available fields');
    return [
      _buildQuestionCard(
        child: FormFields.buildRadioGroup<String>(
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
          onChanged: _handleFarmerStatusChanged,
          isRequired: true,
        ),
      ),
      if (widget.farmerStatus == 'Other')
        _buildQuestionCard(
          child: FormFields.buildTextField(
            context: context,
            label: 'If other, please specify',
            controller: widget.otherSpecController,
            onChanged: _handleOtherSpecChanged,
            isRequired: true,
          ),
        ),
      // if (widget.farmerStatus == 'Non-resident' ||
      //     widget.farmerStatus == 'Other')
      //   _buildQuestionCard(
      //     child: FormFields.buildTextField(
      //       context: context,
      //       label:
      //           'Please specify the name of the community the farmer resides in',
      //       controller: widget.otherCommunityController,
      //       onChanged: _handleOtherCommunityChanged,
      //       isRequired: true,
      //     ),
      //   ),
      if (widget.farmerStatus == 'Non-resident' ||
          widget.farmerStatus == 'Other')
        _buildQuestionCard(
          child: FormFields.buildRadioGroup<String>(
            context: context,
            label: 'Who is available for the interview?',
            value: widget.availablePerson,
            items: const [
              MapEntry('Caretaker', 'Caretaker'),
              MapEntry('Spouse', 'Spouse'),
              MapEntry('Nobody', 'Nobody'),
            ],
            onChanged: _handleAvailablePersonChanged,
            isRequired: true,
          ),
        ),
    ];
  }

  final controller = Get.put(HouseHoldController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    debugPrint('=== CONSENT PAGE BUILD ===');
    debugPrint('Should show consent: ${_shouldShowConsentSection()}');
    debugPrint('==========================');

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Interview Start Time
                  _buildTapToCaptureSection(
                    title: 'Interview Start Time',
                    placeholder: 'Tap to record start time',
                    value: widget.interviewStartTime != null
                        ? '${widget.interviewStartTime!.hour}:${widget.interviewStartTime!.minute.toString().padLeft(2, '0')}'
                        : null,
                    onTap: _handleRecordTime,
                    icon: Icons.access_time,
                    statusText: widget.timeStatus,
                  ),

                  // GPS Location
                  _buildTapToCaptureSection(
                    title: 'GPS Location',
                    placeholder: 'Tap to capture GPS coordinates',
                    value: widget.currentPosition != null
                        ? 'Location Recorded'
                        : null,
                    onTap: _handleGetLocation,
                    icon: Icons.gps_fixed,
                    isLoading: widget.isGettingLocation,
                    statusText: widget.isGettingLocation
                        ? 'Recording...'
                        : widget.currentPosition != null
                            ? 'Recorded'
                            : 'Not recorded',
                  ),

                  // Community Type
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select the type of community',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: _Spacing.md),
                        Column(
                          children: [
                            _buildRadioOption(
                              value: 'rural',
                              groupValue: widget.communityType,
                              label: 'Rural',
                              onChanged: _handleCommunityTypeChanged,
                            ),
                            _buildRadioOption(
                              value: 'urban',
                              groupValue: widget.communityType,
                              label: 'Urban',
                              onChanged: _handleCommunityTypeChanged,
                            ),
                            _buildRadioOption(
                              value: 'semi_urban',
                              groupValue: widget.communityType,
                              label: 'Semi-Urban',
                              onChanged: _handleCommunityTypeChanged,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Residence Confirmation
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Does the farmer reside in the community stated on the cover?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: _Spacing.md),
                        Column(
                          children: [
                            _buildRadioOption(
                              value: 'Yes',
                              groupValue: widget.residesInCommunityConsent,
                              label: 'Yes',
                              onChanged: _handleResidesInCommunityChanged,
                            ),
                            _buildRadioOption(
                              value: 'No',
                              groupValue: widget.residesInCommunityConsent,
                              label: 'No',
                              onChanged: _handleResidesInCommunityChanged,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Show community name field if resident is not in this community
                  if (widget.residesInCommunityConsent == 'No')
                    ..._buildNonResidentFields(),

                  // Farmer Availability
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Is the farmer available?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: _Spacing.md),
                        Column(
                          children: [
                            _buildRadioOption(
                              value: 'Yes',
                              groupValue: widget.farmerAvailable,
                              label: 'Yes',
                              onChanged: _handleFarmerAvailableChanged,
                            ),
                            _buildRadioOption(
                              value: 'No',
                              groupValue: widget.farmerAvailable,
                              label: 'No',
                              onChanged: _handleFarmerAvailableChanged,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Farmer Not Available Fields
                  if (widget.farmerAvailable == 'No')
                    ..._buildFarmerNotAvailableFields(),

                  // Consent Section
                  _buildConsentSection(),

                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowConsentSection() {
    bool shouldShowConsent = false;

    if (widget.farmerAvailable == 'Yes') {
      shouldShowConsent = true;
    } else if (widget.farmerStatus == 'Non-resident' &&
        widget.availablePerson != null &&
        widget.availablePerson != 'Nobody') {
      shouldShowConsent = true;
    } else if (widget.farmerStatus == 'Other' &&
        widget.availablePerson != null &&
        widget.availablePerson != 'Nobody') {
      shouldShowConsent = true;
    }

    debugPrint('Consent section visibility: $shouldShowConsent');
    debugPrint('  - Farmer Available: ${widget.farmerAvailable}');
    debugPrint('  - Farmer Status: ${widget.farmerStatus}');
    debugPrint('  - Available Person: ${widget.availablePerson}');

    return shouldShowConsent;
  }

  Widget _buildConsentSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_shouldShowConsentSection()) {
      debugPrint('Skipping consent section build - conditions not met');
      return const SizedBox.shrink();
    }

    debugPrint('Building consent section');

    return _buildQuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consent for Data Processing',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: _Spacing.lg),
          Container(
            height: 300,
            padding: const EdgeInsets.all(_Spacing.lg),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By selecting « Yes, I confirm », I hereby give my free, explicit and unequivocal consent to the processing of my personal data for purposes below ("Purpose") and in accordance with the principles set out in this note ("Note").',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Text(
                    'I understand that the following personal data may be collected and processed:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: _Spacing.sm),
                  Text(
                    '• Name, telephone number, e-mail address\n• Gender, date of birth, marital status\n• Level of education\n• Information on my farm and professional experience\n• Information on my household and my family\n• My standard of living and social/economic situation',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Text(
                    'The said purposes relate to the implementation of sustainable development/agricultural programs and projects initiated for the benefit of cocoa farmers and agricultural organizations, the optimization of traceability and sustainability of cocoa production and supply as well as the improvement of yields and livelihoods of cocoa farmers worldwide.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: _Spacing.xl),

          // Consent Checkbox
          Row(
            children: [
              Checkbox(
                value: _consentGiven,
                onChanged: _handleConsentChange,
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: _Spacing.sm),
              Expanded(
                child: Text(
                  'Yes, I accept the above conditions',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          // Decline Checkbox
          Row(
            children: [
              Checkbox(
                value: _declinedConsent,
                onChanged: _handleDeclineChange,
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: _Spacing.sm),
              Expanded(
                child: Text(
                  'No, I refuse and end the survey',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          // Refusal Reason Field
          if (_declinedConsent) ...[
            const SizedBox(height: _Spacing.lg),
            TextField(
              controller: _refusalReasonController,
              focusNode: _reasonFocusNode,
              decoration: InputDecoration(
                labelText: 'What is your reason for refusing to participate?',
                hintText: 'Please provide your reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                debugPrint('Refusal reason updated: $value');
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('ConsentPage disposed');
    _refusalReasonController.dispose();
    _reasonFocusNode.dispose();
    super.dispose();
  }
}
