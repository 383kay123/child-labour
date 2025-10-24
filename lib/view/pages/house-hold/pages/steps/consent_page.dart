import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../../controller/household_controller.dart';
import '../../../../../controller/models/consent_model.dart';
import '../../../../theme/app_theme.dart';
import '../../form_fields.dart';

/// Enhanced error messages and debug tags
class _ErrorMessages {
  static const String locationPermissionDenied = 'Location permission denied';
  static const String locationServiceDisabled =
      'Location services are disabled';
  static const String locationTimeout = 'Location request timed out';
  static const String locationError = 'Error getting location';
  static const String formValidationError =
      'Please fill in all required fields';
  static const String unexpectedError = 'An unexpected error occurred';
  static const String surveyEndError = 'Failed to end survey';
  static const String consentRequired =
      'Please either accept or decline the consent';
  static const String refusalReasonRequired =
      'Please provide a reason for declining';
  static const String communityTypeRequired = 'Please select community type';
  static const String residenceRequired =
      'Please specify if farmer resides in community';
  static const String availabilityRequired =
      'Please specify farmer availability';
  static const String farmerStatusRequired = 'Please specify farmer status';
  static const String availablePersonRequired =
      'Please specify available person';
  static const String otherCommunityRequired = 'Please provide community name';
  static const String otherSpecRequired = 'Please provide specification';
}

class _DebugTags {
  static const String consent = 'CONSENT';
  static const String location = 'LOCATION';
  static const String navigation = 'NAVIGATION';
  static const String state = 'STATE';
  static const String validation = 'VALIDATION';
  static const String userInput = 'USER_INPUT';
  static const String error = 'ERROR';
}

class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class ConsentPage extends StatefulWidget {
  final ConsentData data;
  final ValueChanged<ConsentData> onDataChanged;
  final VoidCallback onRecordTime;
  final Future<void> Function() onGetLocation;
  final FutureOr<void> Function() onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onSurveyEnd;

  const ConsentPage({
    Key? key,
    required this.data,
    required this.onDataChanged,
    required this.onRecordTime,
    required this.onGetLocation,
    required this.onNext,
    this.onPrevious,
    this.onSurveyEnd,
  }) : super(key: key);

  @override
  _ConsentPageState createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _consentGiven = false;
  bool _declinedConsent = false;
  final TextEditingController _refusalReasonController =
      TextEditingController();
  final FocusNode _reasonFocusNode = FocusNode();

  // Validation state tracking
  final Map<String, String?> _fieldErrors = {};
  bool _isValidating = false;

  /// Enhanced debug logging for user inputs
  void _logUserInput(String question, dynamic value,
      {String? fieldType, List<String>? options}) {
    developer.log(
      'USER INPUT CAPTURED',
      name: _DebugTags.userInput,
      time: DateTime.now(),
    );

    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'question': question,
      'selected_value': value?.toString() ?? 'null',
      'field_type': fieldType ?? 'radio',
      'available_options': options?.join(', ') ?? 'N/A',
    };

    developer.log(
      jsonEncode(logData),
      name: _DebugTags.userInput,
    );

    // Also print to console for immediate visibility
    debugPrint('🎯 USER SELECTION: $question → $value');
  }

  /// Log validation events
  void _logValidation(String field, String status, {String? message}) {
    developer.log(
      'VALIDATION: $field - $status${message != null ? ' - $message' : ''}',
      name: _DebugTags.validation,
    );
  }

  /// Comprehensive form validation
  String? _validateForm() {
    _fieldErrors.clear();
    _logValidation('FORM', 'STARTED');

    // 1. Validate basic information
    if (widget.data.interviewStartTime == null) {
      _fieldErrors['interviewStartTime'] = 'Interview start time is required';
      _logValidation('interviewStartTime', 'FAILED', message: 'Not recorded');
    }

    if (widget.data.currentPosition == null) {
      _fieldErrors['gpsLocation'] = 'GPS location is required';
      _logValidation('gpsLocation', 'FAILED', message: 'Not recorded');
    }

    // 2. Validate community type
    if (widget.data.communityType == null) {
      _fieldErrors['communityType'] = _ErrorMessages.communityTypeRequired;
      _logValidation('communityType', 'FAILED', message: 'Not selected');
    }

    // 3. Validate residence in community
    if (widget.data.residesInCommunityConsent == null) {
      _fieldErrors['residesInCommunity'] = _ErrorMessages.residenceRequired;
      _logValidation('residesInCommunity', 'FAILED', message: 'Not selected');
    }

    // 4. If not residing in community, validate other community name
    if (widget.data.residesInCommunityConsent == 'No' &&
        (widget.data.otherCommunityName == null ||
            widget.data.otherCommunityName!.isEmpty)) {
      _fieldErrors['otherCommunity'] = _ErrorMessages.otherCommunityRequired;
      _logValidation('otherCommunity', 'FAILED',
          message: 'Required when not residing in community');
    }

    // 5. Validate farmer availability
    if (widget.data.farmerAvailable == null) {
      _fieldErrors['farmerAvailable'] = _ErrorMessages.availabilityRequired;
      _logValidation('farmerAvailable', 'FAILED', message: 'Not selected');
    }

    // 6. Validate farmer status if not available
    if (widget.data.farmerAvailable == 'No' &&
        widget.data.farmerStatus == null) {
      _fieldErrors['farmerStatus'] = _ErrorMessages.farmerStatusRequired;
      _logValidation('farmerStatus', 'FAILED',
          message: 'Required when farmer not available');
    }

    // 7. Validate other specification if status is "Other"
    if (widget.data.farmerStatus == 'Other' &&
        (widget.data.otherSpecification == null ||
            widget.data.otherSpecification!.isEmpty)) {
      _fieldErrors['otherSpecification'] = _ErrorMessages.otherSpecRequired;
      _logValidation('otherSpecification', 'FAILED',
          message: 'Required when status is "Other"');
    }

    // 8. Validate available person for non-resident or other status
    if ((widget.data.farmerStatus == 'Non-resident' ||
            widget.data.farmerStatus == 'Other') &&
        widget.data.availablePerson == null) {
      _fieldErrors['availablePerson'] = _ErrorMessages.availablePersonRequired;
      _logValidation('availablePerson', 'FAILED',
          message: 'Required for non-resident/other status');
    }

    // 9. Validate consent section (only if should show)
    if (_shouldShowConsentSection()) {
      if (!_consentGiven && !_declinedConsent) {
        _fieldErrors['consent'] = _ErrorMessages.consentRequired;
        _logValidation('consent', 'FAILED',
            message: 'Neither accepted nor declined');
      }

      if (_declinedConsent && _refusalReasonController.text.isEmpty) {
        _fieldErrors['refusalReason'] = _ErrorMessages.refusalReasonRequired;
        _logValidation('refusalReason', 'FAILED',
            message: 'Required when declining consent');
      }
    }

    // Log validation summary
    if (_fieldErrors.isEmpty) {
      _logValidation('FORM', 'PASSED');
      developer.log('✅ ALL VALIDATIONS PASSED', name: _DebugTags.validation);
      return null;
    } else {
      _logValidation('FORM', 'FAILED',
          message: '${_fieldErrors.length} errors found');
      developer.log('❌ VALIDATION ERRORS: ${_fieldErrors.keys.join(', ')}',
          name: _DebugTags.validation);
      return 'Please fix all validation errors';
    }
  }

  /// Enhanced consent handling with validation
  void _handleConsentChange(bool? value) {
    try {
      if (value != null) {
        _logUserInput(
          'Do you consent to participate?',
          value ? 'Yes' : 'No',
          options: ['Yes', 'No'],
        );

        setState(() {
          _consentGiven = value;
          _declinedConsent = !value;
          // Clear refusal reason if consent is given
          if (value) {
            _refusalReasonController.clear();
            _fieldErrors.remove('refusalReason');
          }
        });

        widget.onDataChanged(widget.data.updateConsent(value));

        // Trigger validation
        _validateForm();
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error in _handleConsentChange',
        name: _DebugTags.error,
        error: e,
        stackTrace: stackTrace,
      );
      _showErrorSnackBar(_ErrorMessages.unexpectedError);
    }
  }

  void _handleDeclineChange(bool? value) {
    if (value != null) {
      _logUserInput(
        'Do you decline consent?',
        value ? 'Yes' : 'No',
        options: ['Yes', 'No'],
      );

      setState(() {
        _declinedConsent = value;
        _consentGiven = !value;
      });

      // Update the model with the current refusal reason if declining
      if (value) {
        widget.onDataChanged(
          widget.data.updateConsent(false).copyWith(
                otherSpecification: _refusalReasonController.text.isNotEmpty
                    ? _refusalReasonController.text
                    : null,
              ),
        );
        _showEndSurveyConfirmation();
      } else {
        widget.onDataChanged(
          widget.data.updateConsent(true).copyWith(
                otherSpecification: null,
              ),
        );
        _refusalReasonController.clear();
        _fieldErrors.remove('refusalReason');
      }

      // Trigger validation
      _validateForm();
    }
  }

  /// Enhanced field handlers with validation
  void _handleCommunityTypeChanged(String? value) {
    _logUserInput(
      'Select the type of community',
      value ?? 'Cleared',
      options: ['rural', 'urban', 'semi_urban'],
    );

    setState(() {
      // Pass value directly (including null for clearing)
      widget.onDataChanged(widget.data.updateCommunityType(value));
      if (value == null) {
        // Clear error when clearing selection
        _fieldErrors.remove('communityType');
      }
    });
    _validateForm();
  }

  void _handleResidesInCommunityChanged(String? value) {
    _logUserInput(
      'Does the farmer reside in the community stated on the cover?',
      value ?? 'Cleared',
      options: ['Yes', 'No'],
    );

    setState(() {
      // Pass value directly (including null for clearing)
      widget.onDataChanged(widget.data.updateResidesInCommunity(value));
      if (value == null) {
        _fieldErrors.remove('residesInCommunity');
        _fieldErrors.remove('otherCommunity');
      }
    });
    _validateForm();
  }

  void _handleFarmerAvailableChanged(String? value) {
    _logUserInput(
      'Is the farmer available for the interview?',
      value ?? 'Cleared',
      options: ['Yes', 'No'],
    );

    setState(() {
      // Pass value directly (including null for clearing)
      widget.onDataChanged(widget.data.updateFarmerAvailable(value));
      if (value == null) {
        _fieldErrors.remove('farmerAvailable');
        _fieldErrors.remove('farmerStatus');
        _fieldErrors.remove('availablePerson');
      }
    });
    _validateForm();
  }

  Future<void> _handleFarmerStatusChanged(String? value) async {
    _logUserInput(
      'If No, for what reason?',
      value ?? 'Cleared',
      options: [
        'Non-resident',
        'Deceased',
        'Doesn\'t work with TOUTON anymore',
        'Other'
      ],
    );

    // Handle clearing
    if (value == null) {
      setState(() {
        widget.onDataChanged(widget.data.updateFarmerStatus(null));
        _fieldErrors.remove('farmerStatus');
        _fieldErrors.remove('availablePerson');
      });
      _validateForm();
      return;
    }

    // Handle special statuses that end the survey
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
        widget.onSurveyEnd?.call();
        return;
      } else {
        // If user cancels, don't update the status and re-validate
        _validateForm();
        return;
      }
    }

    setState(() {
      widget.onDataChanged(widget.data.updateFarmerStatus(value));
      _fieldErrors.remove('farmerStatus');
      _fieldErrors.remove('availablePerson');
    });
    _validateForm();
  }

  void _handleAvailablePersonChanged(String? value) {
    _logUserInput(
      'Who is available for the interview?',
      value ?? 'Cleared',
      options: ['Caretaker', 'Spouse', 'Nobody'],
    );

    setState(() {
      // Pass value directly (including null for clearing)
      widget.onDataChanged(widget.data.updateAvailablePerson(value));
      if (value == null) {
        _fieldErrors.remove('availablePerson');
      }
    });
    _validateForm();
  }

  void _handleOtherSpecChanged(String value) {
    _logUserInput(
      'If other, please specify',
      value,
      fieldType: 'text_input',
    );

    widget.onDataChanged(widget.data.updateOtherSpecification(value));
    if (value.isNotEmpty) {
      _fieldErrors.remove('otherSpecification');
    }
    _validateForm();
  }

  void _handleOtherCommunityChanged(String value) {
    _logUserInput(
      'Provide the name of the community the farmer resides in',
      value,
      fieldType: 'text_input',
    );

    widget.onDataChanged(widget.data.updateOtherCommunityName(value));
    if (value.isNotEmpty) {
      _fieldErrors.remove('otherCommunity');
    }
    _validateForm();
  }

  void _handleRecordTime() {
    _logUserInput(
      'Record interview start time',
      DateTime.now().toIso8601String(),
      fieldType: 'timestamp',
    );
    widget.onRecordTime();
    _fieldErrors.remove('interviewStartTime');
    _validateForm();
  }

  /// Enhanced location handling with validation
  Future<void> _handleGetLocation() async {
    try {
      developer.log('Initiating location capture', name: _DebugTags.location);

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final loadingSnackBar = SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(value: null, strokeWidth: 2.0),
            const SizedBox(width: 16.0),
            Text(
              'Getting location...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[800],
        duration: const Duration(seconds: 30),
      );

      scaffoldMessenger.showSnackBar(loadingSnackBar);

      try {
        await widget.onGetLocation();
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Location captured successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        developer.log('Location captured successfully',
            name: _DebugTags.location);
        _fieldErrors.remove('gpsLocation');
        _validateForm();
      } catch (e, stackTrace) {
        scaffoldMessenger.hideCurrentSnackBar();

        String errorMessage = _ErrorMessages.locationError;
        if (e is PermissionDeniedException) {
          errorMessage = _ErrorMessages.locationPermissionDenied;
        } else if (e is LocationServiceDisabledException) {
          errorMessage = _ErrorMessages.locationServiceDisabled;
        } else if (e is TimeoutException) {
          errorMessage = _ErrorMessages.locationTimeout;
        }

        developer.log('Error getting location: $e',
            name: _DebugTags.error, error: e, stackTrace: stackTrace);
        _showErrorSnackBar(errorMessage);
      }
    } catch (e, stackTrace) {
      developer.log('Unexpected error in _handleGetLocation',
          name: _DebugTags.error, error: e, stackTrace: stackTrace);
      _showErrorSnackBar(_ErrorMessages.unexpectedError);
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show validation errors snackbar
  void _showValidationErrors() {
    if (!mounted || _fieldErrors.isEmpty) return;

    final errorCount = _fieldErrors.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '$errorCount validation error${errorCount > 1 ? 's' : ''} need${errorCount > 1 ? '' : 's'} to be fixed'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'SHOW',
          textColor: Colors.white,
          onPressed: () {
            _showValidationDetailsDialog();
          },
        ),
      ),
    );
  }

  /// Show detailed validation errors dialog
  void _showValidationDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Errors'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _fieldErrors.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('• ${entry.value}'),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Enhanced next button handler with validation
  Future<void> _handleNext() async {
    if (_isValidating) return;

    setState(() => _isValidating = true);

    try {
      final validationError = _validateForm();

      if (validationError == null) {
        developer.log('✅ Validation passed - proceeding to next page',
            name: _DebugTags.validation);
        await widget.onNext();
      } else {
        developer.log('❌ Validation failed - showing errors',
            name: _DebugTags.validation);
        _showValidationErrors();
      }
    } catch (e, stackTrace) {
      developer.log('Error during validation',
          name: _DebugTags.error, error: e, stackTrace: stackTrace);
      _showErrorSnackBar(_ErrorMessages.unexpectedError);
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  Widget _buildQuestionCard({required Widget child, String? errorKey}) {
    final hasError = errorKey != null && _fieldErrors.containsKey(errorKey);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: _Spacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            if (hasError) ...[
              const SizedBox(height: _Spacing.sm),
              Text(
                _fieldErrors[errorKey]!,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
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
    String? errorKey,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = errorKey != null && _fieldErrors.containsKey(errorKey);

    return _buildQuestionCard(
      errorKey: errorKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: hasError
                      ? Colors.red
                      : (isDark ? Colors.white70 : Colors.black87),
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
                        : (hasError
                            ? Colors.red
                            : (isDark ? Colors.white60 : Colors.grey.shade600)),
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
                  color: hasError
                      ? Colors.red
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  width: hasError ? 2 : 1,
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
                              ? (hasError
                                  ? Colors.red
                                  : (isDark
                                      ? Colors.white60
                                      : Colors.grey.shade600))
                              : AppTheme.primaryColor,
                        ),
                        const SizedBox(width: _Spacing.lg),
                        Expanded(
                          child: Text(
                            value ?? placeholder,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: value == null
                                  ? (hasError
                                      ? Colors.red
                                      : (isDark
                                          ? Colors.white60
                                          : Colors.grey.shade600))
                                  : (isDark
                                      ? Colors.green.shade300
                                      : Colors.green.shade800),
                              fontWeight: value == null
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (hasError && value == null)
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                      ],
                    ),
            ),
          ),
        ],
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
    final isSelected = groupValue == value;

    return Container(
      margin: const EdgeInsets.only(bottom: _Spacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected
            ? (isDark
                ? AppTheme.primaryColor.withOpacity(0.2)
                : AppTheme.primaryColor.withOpacity(0.1))
            : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            // Radio button
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),

            // Label area - tappable to select/deselect
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  if (isSelected) {
                    onChanged(null); // Deselect if already selected
                  } else {
                    onChanged(value); // Select if not selected
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _Spacing.sm,
                    vertical: _Spacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),

                      // Clear button - only show when selected
                      if (isSelected)
                        GestureDetector(
                          onTap: () {
                            onChanged(null); // Clear the selection
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.clear,
                              size: 16,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNonResidentFields() {
    developer.log(
      'Building non-resident fields',
      name: _DebugTags.state,
    );

    return [
      _buildQuestionCard(
        errorKey: 'otherCommunity',
        child: FormFields.buildTextField(
          context: context,
          label:
              'If no, provide the name of the community the farmer resides in',
          controller: widget.data.otherCommunityController,
          hintText: 'Enter community name',
          onChanged: _handleOtherCommunityChanged,
          isRequired: true,
        ),
      ),
    ];
  }

  List<Widget> _buildFarmerNotAvailableFields() {
    developer.log(
      'Building farmer not available fields',
      name: _DebugTags.state,
    );

    return [
      _buildQuestionCard(
        errorKey: 'farmerStatus',
        child: FormFields.buildRadioGroup<String>(
          context: context,
          label: 'If No, for what reason?',
          value: widget.data.farmerStatus,
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
      if (widget.data.farmerStatus == 'Other')
        _buildQuestionCard(
          errorKey: 'otherSpecification',
          child: FormFields.buildTextField(
            context: context,
            label: 'If other, please specify',
            controller: widget.data.otherSpecController,
            hintText: 'Specify reason',
            onChanged: _handleOtherSpecChanged,
            isRequired: true,
          ),
        ),
      if (widget.data.farmerStatus == 'Non-resident' ||
          widget.data.farmerStatus == 'Other')
        _buildQuestionCard(
          errorKey: 'availablePerson',
          child: FormFields.buildRadioGroup<String>(
            context: context,
            label: 'Who is available for the interview?',
            value: widget.data.availablePerson,
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

  bool _shouldShowConsentSection() {
    bool shouldShowConsent = false;

    if (widget.data.farmerAvailable == 'Yes') {
      shouldShowConsent = true;
    } else if (widget.data.farmerStatus == 'Non-resident' &&
        widget.data.availablePerson != null &&
        widget.data.availablePerson != 'Nobody') {
      shouldShowConsent = true;
    } else if (widget.data.farmerStatus == 'Other' &&
        widget.data.availablePerson != null &&
        widget.data.availablePerson != 'Nobody') {
      shouldShowConsent = true;
    }

    developer.log(
      'Consent section visibility: $shouldShowConsent',
      name: _DebugTags.state,
    );
    developer.log(
      '  - Farmer Available: ${widget.data.farmerAvailable}',
      name: _DebugTags.state,
    );
    developer.log(
      '  - Farmer Status: ${widget.data.farmerStatus}',
      name: _DebugTags.state,
    );
    developer.log(
      '  - Available Person: ${widget.data.availablePerson}',
      name: _DebugTags.state,
    );

    return shouldShowConsent;
  }

  Widget _buildConsentSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_shouldShowConsentSection()) {
      developer.log(
        'Skipping consent section build - conditions not met',
        name: _DebugTags.state,
      );
      return const SizedBox.shrink();
    }

    developer.log(
      'Building consent section',
      name: _DebugTags.state,
    );

    return Column(
      children: [
        _buildQuestionCard(
          errorKey: 'consent',
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
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
                        style: TextStyle(
                          fontWeight: _consentGiven
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _Spacing.md),

              // Decline Checkbox
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _declinedConsent,
                      onChanged: _handleDeclineChange,
                    ),
                    const SizedBox(width: _Spacing.sm),
                    Expanded(
                      child: Text(
                        'No, I refuse and end the survey',
                        style: TextStyle(
                          fontWeight: _declinedConsent
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Refusal Reason Field
        if (_declinedConsent) ...[
          const SizedBox(height: _Spacing.lg),
          _buildQuestionCard(
            errorKey: 'refusalReason',
            child: FormFields.buildTextField(
              context: context,
              label: 'What is your reason for refusing to participate?',
              controller: _refusalReasonController,
              hintText: 'Please provide your reason',
              onChanged: (value) {
                // Update the data
                widget.onDataChanged(
                  widget.data.copyWith(
                    otherSpecification: value.isNotEmpty ? value : null,
                  ),
                );

                // Log the update
                developer.log(
                  'Refusal reason updated: $value',
                  name: _DebugTags.userInput,
                );

                // Update validation state
                if (value.isNotEmpty) {
                  _fieldErrors.remove('refusalReason');
                }
                _validateForm();
              },
              validator: (value) {
                if (_declinedConsent &&
                    (value == null ||
                        value.isEmpty ||
                        (widget.data.otherSpecification?.isEmpty ?? true))) {
                  return 'Please provide a reason for declining';
                }
                return null;
              },
              maxLines: 3,
              isRequired: true,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showEndSurveyConfirmation() async {
    if (_refusalReasonController.text.trim().isEmpty) {
      developer.log(
        'Refusal reason is empty - showing warning',
        name: _DebugTags.validation,
      );

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

    developer.log(
      'Showing end survey confirmation dialog',
      name: _DebugTags.navigation,
    );

    final shouldEndSurvey = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('End Survey'),
            content: const Text(
                'Are you sure you want to end the survey? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () {
                  developer.log('User cancelled survey end',
                      name: _DebugTags.navigation);
                  Navigator.pop(context, false);
                },
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  developer.log('User confirmed survey end',
                      name: _DebugTags.navigation);
                  Navigator.pop(context, true);
                },
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
      developer.log('Survey ended by user', name: _DebugTags.navigation);
      widget.onSurveyEnd?.call();
    } else if (mounted) {
      developer.log('User changed mind - keeping survey active',
          name: _DebugTags.navigation);
      setState(() {
        _declinedConsent = true;
        _consentGiven = false;
      });
      widget.onDataChanged(widget.data.updateConsent(_consentGiven));
    }
  }

  void _debugPrintInitialState() {
    developer.log('=== CONSENT PAGE INITIAL STATE ===', name: _DebugTags.state);
    developer.log('Interview Start Time: ${widget.data.interviewStartTime}',
        name: _DebugTags.state);
    developer.log('GPS Position: ${widget.data.currentPosition}',
        name: _DebugTags.state);
    developer.log('Community Type: ${widget.data.communityType}',
        name: _DebugTags.state);
    developer.log(
        'Resides in Community: ${widget.data.residesInCommunityConsent}',
        name: _DebugTags.state);
    developer.log('Farmer Available: ${widget.data.farmerAvailable}',
        name: _DebugTags.state);
    developer.log('Farmer Status: ${widget.data.farmerStatus}',
        name: _DebugTags.state);
    developer.log('Available Person: ${widget.data.availablePerson}',
        name: _DebugTags.state);
    developer.log('Other Specification: ${widget.data.otherSpecification}',
        name: _DebugTags.state);
    developer.log('Other Community Name: ${widget.data.otherCommunityName}',
        name: _DebugTags.state);
    developer.log('Consent Given: ${widget.data.consentGiven}',
        name: _DebugTags.state);
    developer.log('===================================',
        name: _DebugTags.state);
  }

  // Initialize the controller properly in the state
  late final HouseHoldController controller;

  @override
  void initState() {
    super.initState();
    _consentGiven = widget.data.consentGiven;
    _declinedConsent = !widget.data.consentGiven;
    controller = Get.put(HouseHoldController());
    _debugPrintInitialState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    developer.log(
      '=== CONSENT PAGE BUILD ===',
      name: _DebugTags.state,
    );

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_Spacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Interview Start Time
                    _buildTapToCaptureSection(
                      title: 'Interview Start Time',
                      placeholder: 'Tap to record start time',
                      value: widget.data.interviewStartTime != null
                          ? '${widget.data.interviewStartTime!.hour}:${widget.data.interviewStartTime!.minute.toString().padLeft(2, '0')}'
                          : null,
                      onTap: _handleRecordTime,
                      icon: Icons.access_time,
                      statusText: widget.data.timeStatus,
                      errorKey: 'interviewStartTime',
                    ),

                    // GPS Location
                    _buildTapToCaptureSection(
                      title: 'GPS Location',
                      placeholder: 'Tap to capture GPS coordinates',
                      value: widget.data.currentPosition != null
                          ? 'Location Recorded'
                          : null,
                      onTap: _handleGetLocation,
                      icon: Icons.gps_fixed,
                      isLoading: widget.data.isGettingLocation,
                      statusText: widget.data.isGettingLocation
                          ? 'Recording...'
                          : widget.data.currentPosition != null
                              ? 'Recorded'
                              : 'Not recorded',
                      errorKey: 'gpsLocation',
                    ),

                    // Community Type
                    _buildQuestionCard(
                      errorKey: 'communityType',
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
                                groupValue: widget.data.communityType,
                                label: 'Rural',
                                onChanged: _handleCommunityTypeChanged,
                              ),
                              _buildRadioOption(
                                value: 'urban',
                                groupValue: widget.data.communityType,
                                label: 'Urban',
                                onChanged: _handleCommunityTypeChanged,
                              ),
                              _buildRadioOption(
                                value: 'semi_urban',
                                groupValue: widget.data.communityType,
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
                      errorKey: 'residesInCommunity',
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
                                groupValue:
                                    widget.data.residesInCommunityConsent,
                                label: 'Yes',
                                onChanged: _handleResidesInCommunityChanged,
                              ),
                              _buildRadioOption(
                                value: 'No',
                                groupValue:
                                    widget.data.residesInCommunityConsent,
                                label: 'No',
                                onChanged: _handleResidesInCommunityChanged,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Show community name field if resident is not in this community
                    if (widget.data.residesInCommunityConsent == 'No')
                      ..._buildNonResidentFields(),

                    // Farmer Availability
                    _buildQuestionCard(
                      errorKey: 'farmerAvailable',
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
                                groupValue: widget.data.farmerAvailable,
                                label: 'Yes',
                                onChanged: _handleFarmerAvailableChanged,
                              ),
                              _buildRadioOption(
                                value: 'No',
                                groupValue: widget.data.farmerAvailable,
                                label: 'No',
                                onChanged: _handleFarmerAvailableChanged,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Farmer Not Available Fields
                    if (widget.data.farmerAvailable == 'No')
                      ..._buildFarmerNotAvailableFields(),

                    // Consent Section
                    _buildConsentSection(),

                    const SizedBox(
                        height: 120), // Extra space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: Container(
      //   margin: const EdgeInsets.only(bottom: 16),
      //   child: FloatingActionButton.extended(
      //     onPressed: _isValidating ? null : _handleNext,
      //     backgroundColor: _isValidating ? Colors.grey : AppTheme.primaryColor,
      //     label: _isValidating
      //         ? const SizedBox(
      //             width: 20,
      //             height: 20,
      //             child: CircularProgressIndicator(
      //               strokeWidth: 2,
      //               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      //             ),
      //           )
      //         : const Text(
      //             'Next',
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //               fontSize: 16,
      //             ),
      //           ),
      //     icon: _isValidating
      //         ? const SizedBox.shrink()
      //         : const Icon(Icons.arrow_forward_rounded),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    developer.log('ConsentPage disposed', name: _DebugTags.state);
    _refusalReasonController.dispose();
    _reasonFocusNode.dispose();
    super.dispose();
  }
}
