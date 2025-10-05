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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: _Spacing.lg,
        vertical: _Spacing.md,
      ),
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

  Widget _buildResidenceConfirmation() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Do you reside in this community?',
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
        // Title and status row
        Row(
          children: [
            Expanded(
              child: Text(
                'Interview Start Time',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16, // Reduced from 16
                ),
              ),
            ),
            const SizedBox(width: _Spacing.sm),
            Text(
              widget.timeStatus,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12, // Reduced from 14
                color: widget.interviewStartTime != null
                    ? AppTheme.primaryColor
                    : textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: _Spacing.md),
        
        // Button or recorded time display
        SizedBox(
          width: double.infinity,
          child: widget.interviewStartTime == null
              ? ElevatedButton.icon(
                  onPressed: widget.onRecordTime,
                  icon: const Icon(Icons.access_time, size: 20),
                  label: const Text('Record Start Time', style: TextStyle(fontSize: 12)), // Reduced from 14
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
                          fontSize: 12, // Reduced from 14
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
        // Title and status row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('GPS Location', 
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500,fontSize: 16)),
            Text(
              widget.isGettingLocation 
                  ? 'Recording...' 
                  : widget.currentPosition != null ? 'Recorded' : 'Not recorded',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12, // Reduced from 14
                color: widget.isGettingLocation
                    ? AppTheme.accentColor
                    : widget.currentPosition != null
                        ? AppTheme.primaryColor
                        : textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
        
        // Location status text
        if (widget.currentPosition != null || widget.isGettingLocation) ...[
          const SizedBox(height: _Spacing.sm),
          Text(
            widget.locationStatus,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 10, // Reduced from 12
              fontFamily: 'RobotoMono',
              color: widget.isGettingLocation 
                  ? AppTheme.accentColor 
                  : textTheme.bodySmall?.color?.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
        
        // Button
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
              widget.isGettingLocation ? 'Recording Location...' : 'Get Current Location',
              style: const TextStyle(fontSize: 12), // Reduced from 14
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
        // Section title
        Text('Select the type of community', 
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500,fontSize: 16)),
        
        const SizedBox(height: _Spacing.sm),
        
        // Radio buttons
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
        // Section title
        Text('Does the farmer reside in this community?',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500,fontSize: 16)),
        
        const SizedBox(height: _Spacing.sm),
        
        // Radio buttons
        Column(
          children: [
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
        // Section title
        Text('Is the farmer available for the interview?', 
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500,fontSize: 16)),
        
        const SizedBox(height: _Spacing.sm),
        
        // Radio buttons
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
              // Yes option
              RadioListTile<String>(
                title: Text('Yes', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w300,fontSize: 14,)),
                value: 'Yes',
                groupValue: widget.farmerAvailable,
                onChanged: widget.onFarmerAvailableChanged,
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              
              // No option
              RadioListTile<String>(
                title: Text('No', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w300, fontSize: 14)),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
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
      padding: const EdgeInsets.all(_Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consent for Data Processing',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 17, // Reduced from 20
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
                      fontSize: 12, // Reduced from 14
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Text(
                    'I understand that the following personal data may be collected and processed:',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12, // Reduced from 14
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: _Spacing.sm),
                  Text(
                    '• Name, telephone number, e-mail address\n• Gender, date of birth, marital status\n• Level of education\n• Information on my farm and professional experience\n• Information on my household and my family\n• My standard of living and social/economic situation',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12, // Reduced from 14
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Text(
                    'The said purposes relate to the implementation of sustainable development/agricultural programs and projects initiated for the benefit of cocoa farmers and agricultural organizations, the optimization of traceability and sustainability of cocoa production and supply as well as the improvement of yields and livelihoods of cocoa farmers worldwide.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12, // Reduced from 14
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Text(
                    'I agree that CJ COMMODITIES/NANANOM can communicate my personal data to other recipients in Ghana, partner entities and service providers in Ghana that CJ COMMODITIES/NANANOM can or could engage in the realization of its purposes.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12, // Reduced from 14
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Text(
                    'CJ COMMODITIES/NANANOM shall take technical and organizational measures to ensure the security of my personal data and to protect my personal data against unauthorized or unlawful processing, against loss, destruction or accidental damage.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12, // Reduced from 14
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
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
                  'I give my consent for data collection and processing',
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 13, // Reduced from 16
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
                  'I do not give my consent for data collection and processing',
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _Spacing.lg),

        ],
      ),
    );
  }
}
