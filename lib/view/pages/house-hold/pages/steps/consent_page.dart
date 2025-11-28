import 'dart:async';
import 'dart:developer' as devtools;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';

import '../../../../theme/app_theme.dart';
import '../../form_fields.dart';

/// Enhanced error messages and debug tags
class _ErrorMessages {
  static const String locationPermissionDenied = 'Location permission denied';
  static const String locationServiceDisabled = 'Location services are disabled';
  static const String locationTimeout = 'Location request timed out';
  static const String locationError = 'Error getting location';
  static const String formValidationError = 'Please fill in all required fields';
  static const String unexpectedError = 'An unexpected error occurred';
  static const String surveyEndError = 'Failed to end survey';
  static const String consentRequired = 'Please either accept or decline the consent';
  static const String refusalReasonRequired = 'Please provide a reason for declining';
  static const String communityTypeRequired = 'Please select community type';
  static const String residenceRequired = 'Please specify if farmer resides in community';
  static const String availabilityRequired = 'Please specify farmer availability';
  static const String farmerStatusRequired = 'Please specify farmer status';
  static const String availablePersonRequired = 'Please specify available person';
  static const String otherCommunityRequired = 'Please provide community name';
  static const String otherSpecRequired = 'Please provide specification';
}

/// Debug tags for logging
class _DebugTags {
  static const String state = 'state';
  static const String error = 'error';
  static const String validation = 'validation';
  static const String userInput = 'user_input';
  static const String navigation = 'navigation';
  static const String location = 'location';
  static const String debug = 'debug';
}

class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);
  
  @override
  String toString() => message;
}

class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);
  
  @override
  String toString() => message;
}

class ConsentPage extends StatefulWidget {
  final ConsentData data;
  final ValueChanged<ConsentData> onDataChanged;
  final VoidCallback onRecordTime;
  final Future<void> Function() onGetLocation;
  final FutureOr<void> Function() onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onSurveyEnd;
  final GlobalKey<ConsentPageState>? pageKey;
  final int? coverPageId;

  const ConsentPage({
    Key? key,
    required this.data,
    required this.onDataChanged,
    required this.onRecordTime,
    required this.onGetLocation,
    required this.onNext,
    this.onPrevious,
    this.onSurveyEnd,
    this.pageKey,
    this.coverPageId,
  }) : super(key: key);

  @override
  ConsentPageState createState() => ConsentPageState();
}

class ConsentPageState extends State<ConsentPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _fieldErrors = {};
  
  // State for resident status
  bool? _residesInCommunity;
  String? _nonResidentCommunity;
  bool _hasGivenConsent = false;
  bool _declinedConsent = false;
  
  // Track if we're currently getting location
  bool _isGettingLocation = false;

  // Controllers
  late final TextEditingController _refusalReasonController;
  late final TextEditingController _otherCommunityController;
  late final TextEditingController _otherSpecController;

  // Focus nodes
  final FocusNode _reasonFocusNode = FocusNode();
  final FocusNode _otherCommunityFocusNode = FocusNode();
  final FocusNode _otherSpecFocusNode = FocusNode();

  // Validation state tracking
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();

    // Initialize consent states - default to false for new surveys
    _hasGivenConsent = widget.data.consentGiven ?? false;
    _declinedConsent = widget.data.declinedConsent ?? false;

    // Initialize controllers with current values
    _refusalReasonController = TextEditingController(
      text: widget.data.refusalReason,
    );
    _otherCommunityController = TextEditingController(
      text: widget.data.otherCommunityName,
    );
    _otherSpecController = TextEditingController(
      text: widget.data.otherSpecification,
    );

    // Add listeners
    _refusalReasonController.addListener(() {
      // Update the data when refusal reason changes
      if (mounted) {
        widget.onDataChanged(widget.data.copyWith(
          refusalReason: _refusalReasonController.text.isNotEmpty ? _refusalReasonController.text : null,
        ));
      }
    });
    
    _otherCommunityController.addListener(_handleOtherCommunityChanged);
    _otherSpecController.addListener(_handleOtherSpecChangedListener);

    _debugPrintInitialState();

    // Initialize interview time and GPS location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.data.interviewStartTime == null) {
        // Initialize interview time
        widget.onRecordTime();
      }
      if (widget.data.currentPosition == null) {
        // Initialize location
        widget.onGetLocation();
      }
    });
  }

  void _debugPrintInitialState() {
    if (kDebugMode) {
      devtools.log('Consent Form Initialized', name: 'consent');
    }
  }

  @override
  void didUpdateWidget(ConsentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (!mounted) return;
    
    // Update controllers when widget data changes
    if (widget.data.refusalReason != oldWidget.data.refusalReason) {
      _refusalReasonController.text = widget.data.refusalReason ?? '';
    }
    if (widget.data.otherCommunityName != oldWidget.data.otherCommunityName) {
      _otherCommunityController.text = widget.data.otherCommunityName ?? '';
    }
    if (widget.data.otherSpecification != oldWidget.data.otherSpecification) {
      _otherSpecController.text = widget.data.otherSpecification ?? '';
    }
    
    // Update local state from widget data
    if (widget.data.consentGiven != oldWidget.data.consentGiven) {
      _hasGivenConsent = widget.data.consentGiven ?? false;
    }
    if (widget.data.declinedConsent != oldWidget.data.declinedConsent) {
      _declinedConsent = widget.data.declinedConsent ?? false;
    }
  }

  @override
  void dispose() {
    _otherCommunityController.removeListener(_handleOtherCommunityChanged);
    _otherSpecController.removeListener(_handleOtherSpecChangedListener);
    
    // Dispose controllers
    _refusalReasonController.dispose();
    _otherCommunityController.dispose();
    _otherSpecController.dispose();
    
    // Dispose focus nodes
    _reasonFocusNode.dispose();
    _otherCommunityFocusNode.dispose();
    _otherSpecFocusNode.dispose();
    
    super.dispose();
  }

  /// Saves the current consent data to the local database
 Future<bool> saveData() async {
  if (!mounted) return false;
  
  try {
    // First try to get coverPageId from widget.coverPageId
    int? coverPageId = widget.coverPageId;
    
    // If not available in widget, try to get it from the data
    if (coverPageId == null && widget.data.coverPageId != null) {
      coverPageId = widget.data.coverPageId;
    }
    
    // If we don't have a coverPageId, we can't proceed
    if (coverPageId == null) {
      debugPrint('Error: coverPageId is null when saving consent data');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Missing cover page reference. Please save the cover page first.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return false;
    }

    // Create a copy of the current data with updated values from the form
    final updatedData = widget.data.copyWith(
      coverPageId: coverPageId, // Use the resolved coverPageId
      communityType: widget.data.communityType,
      residesInCommunityConsent: _residesInCommunity == true ? 'Yes' : 'No',
      farmerAvailable: widget.data.farmerAvailable,
      farmerStatus: widget.data.farmerStatus,
      availablePerson: widget.data.availablePerson,
      otherSpecification: _otherSpecController.text.trim(),
      otherCommunityName: _otherCommunityController.text.trim(),
      consentGiven: _hasGivenConsent,
      declinedConsent: _declinedConsent,
      refusalReason: _declinedConsent ? _refusalReasonController.text.trim() : null,
      consentTimestamp: DateTime.now(),
      interviewStartTime: widget.data.interviewStartTime ?? DateTime.now(),
      timeStatus: widget.data.timeStatus ?? 'Started at ${TimeOfDay.now().format(context)}',
      currentPosition: widget.data.currentPosition,
      locationStatus: widget.data.locationStatus,
    );
    
    debugPrint('Saving consent data with coverPageId: $coverPageId');
    debugPrint('Consent data to save: ${updatedData.toMap()}');

    // Use HouseholdDBHelper which has the table existence checks
    final dbHelper = HouseholdDBHelper.instance;
    
    try {
      // Save the data using HouseholdDBHelper
      int? id;
      if (updatedData.id == null) {
        // Insert new record
        id = await dbHelper.insertConsent(updatedData);
        devtools.log('✅ Consent data saved with ID: $id', name: 'database');
      } else {
        // Update existing record
        await dbHelper.updateConsent(updatedData);
        id = updatedData.id;
        devtools.log('🔄 Consent data updated for ID: ${updatedData.id}', name: 'database');
      }
      
      // Verify the data was saved
      if (id != null && id > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Consent data saved successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return true;
      }
      
      throw Exception('Failed to save consent data: No valid ID returned');
    } catch (e) {
      devtools.log('❌ Database error in save operation: $e', name: 'database', error: true);
      rethrow;
    }
  } catch (e, stackTrace) {
    devtools.log('❌ Error in saveData: $e', name: 'database', error: true, stackTrace: stackTrace);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving consent data: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    return false;
  }  
}
  // Helper method to build consistent question cards with error handling
  Widget _buildQuestionCard({
    required String errorKey,
    required Widget child,
    bool showError = true,
  }) {
    final hasError = _fieldErrors.containsKey(errorKey);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            if (hasError && showError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _fieldErrors[errorKey] ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleOtherCommunityChanged() {
    if (!mounted) return;
    final value = _otherCommunityController.text;
    widget.onDataChanged(widget.data.copyWith(otherCommunityName: value));
    validateForm();
  }

  void _handleOtherSpecChangedListener() {
    if (!mounted) return;
    _handleOtherSpecChanged(_otherSpecController.text);
  }

  void _handleOtherSpecChanged(String value) {
    if (!mounted) return;
    
    _logUserInput(
      'If other, please specify',
      value,
      fieldType: 'text_input',
    );

    widget.onDataChanged(widget.data.copyWith(otherSpecification: value));
    if (value.isNotEmpty) {
      _fieldErrors.remove('otherSpecification');
    }
    validateForm();
  }

  /// Enhanced debug logging for user inputs
  void _logUserInput(String question, dynamic value, {String? fieldType, List<String>? options}) {
    // Only log in debug mode
    if (kDebugMode) {
      devtools.log('Input: $question = $value', name: 'user_input');
    }
  }

  /// Form validation disabled
  String? validateForm() {
    // Clear any existing errors
    if (mounted) {
      setState(() {
        _fieldErrors.clear();
      });
    }
    return null; // Always return null to indicate no errors
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    // Hide any existing snackbar before showing a new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    final theme = Theme.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _handleConsentChange(bool value) {
    if (!mounted) return;

    // If unchecking, just update the state
    if (!value) {
      setState(() {
        _hasGivenConsent = false;
      });
      return;
    }

    // If checking, ensure declined is false
    setState(() {
      _hasGivenConsent = true;
      _declinedConsent = false;
    });

    try {
      _logUserInput('Do you consent to participate?', 
          true ? 'Yes' : 'No', 
          options: ['Yes', 'No']);

      // Create the updated data
      final updatedData = widget.data.copyWith(
        consentGiven: true,
        declinedConsent: false,
        refusalReason: null,
      );

      // Notify parent
      try {
        // First, print a clear message that we're about to save
        debugPrint('\n🚀 CONSENT DATA BEING SAVED 🚀');
        debugPrint('--------------------------------');
        
        // Save the data
        widget.onDataChanged(updatedData);
        
        // Log the saved data in a very visible way
        final timestamp = DateTime.now().toIso8601String();
        final consentStatus = '✅ CONSENT GIVEN';
        
        debugPrint('🔄 $consentStatus');
        debugPrint('📅 Timestamp: $timestamp');
        debugPrint('✔️ Consent Given: true');
        debugPrint('✖️ Declined Consent: false');
        
        debugPrint('--------------------------------');
        debugPrint('Data saved successfully! 🎉\n');
        
        // Also log to devtools for more detailed inspection
        devtools.log(
          'Consent data saved',
          name: 'ConsentPage',
          time: DateTime.now(),
          error: {
            'consentGiven': true,
            'declinedConsent': false,
            'refusalReason': 'N/A',
            'timestamp': timestamp,
          },
        );
      } catch (e, stackTrace) {
        if (!mounted) return;
        devtools.log('Error in onDataChanged: $e', 
            name: 'error', error: e, stackTrace: stackTrace);
        _showErrorSnackBar('Failed to save consent. Please try again.');
        
        // Revert the UI state
        setState(() {
          _hasGivenConsent = false;
          _declinedConsent = false;
        });
        return;
      }

      // Validate the form
      if (mounted) {
        validateForm();
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      devtools.log('Unexpected error in _handleConsentChange: $e', 
          name: 'error', error: e, stackTrace: stackTrace);
      _showErrorSnackBar(_ErrorMessages.unexpectedError);
      
      // Revert the UI state
      setState(() {
        _hasGivenConsent = false;
        _declinedConsent = false;
      });
    }
  }

  Future<void> _showEndSurveyConfirmation() async {
    if (!mounted) return;
    
    // Show the confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('End Survey'),
        content: const Text('Are you sure you want to decline and end the survey?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('End Survey'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // If user confirms, call the survey end callback
      widget.onSurveyEnd?.call();
    } else if (mounted) {
      // If user cancels, uncheck the decline option
      setState(() {
        _declinedConsent = false;
        _refusalReasonController.clear();
      });
    }
  }

  void _handleDeclineChange(bool? value) {
    if (value == null) return;
    if (!mounted) return;
    
    setState(() {
      _declinedConsent = value;
      if (value) {
        _hasGivenConsent = false;
      }
    });
    
    if (value) {
      // Show the end survey confirmation if declining
      _showEndSurveyConfirmation();
    } else {
      // Clear refusal reason when unchecking decline
      setState(() {
        _fieldErrors.remove('refusalReason');
      });
    }
  }

  void _handleCommunityTypeChanged(String? value) {
    if (!mounted) return;
    
    _logUserInput('Select the type of community', value ?? 'Cleared', options: ['rural', 'urban', 'semi_urban']);

    setState(() {
      widget.onDataChanged(widget.data.copyWith(communityType: value));
      if (value == null) {
        _fieldErrors.remove('communityType');
      }
    });
    validateForm();
  }

  void _handleResidesInCommunityChanged(String? value) {
    if (!mounted) return;
    
    _logUserInput(
      'Does the farmer reside in the community stated on the cover?',
      value ?? 'Cleared',
      options: ['Yes', 'No'],
    );

    setState(() {
      _residesInCommunity = value == 'Yes';
      if (_residesInCommunity == true) {
        _nonResidentCommunity = null;
      }
      widget.onDataChanged(widget.data.copyWith(residesInCommunityConsent: value));
      if (value == null) {
        _fieldErrors.remove('residesInCommunity');
        _fieldErrors.remove('otherCommunity');
      }
    });
    validateForm();
  }

  void _handleFarmerAvailableChanged(String? value) {
    if (!mounted) return;
    
    _logUserInput('Is the farmer available for the interview?', value ?? 'Cleared', options: ['Yes', 'No']);

    setState(() {
      widget.onDataChanged(widget.data.copyWith(farmerAvailable: value));
      if (value == null) {
        _fieldErrors.remove('farmerAvailable');
        _fieldErrors.remove('farmerStatus');
        _fieldErrors.remove('availablePerson');
      }
    });
    validateForm();
  }

  Future<void> _handleFarmerStatusChanged(String? value) async {
    if (!mounted) return;
    
    _logUserInput(
      'If No, for what reason?',
      value ?? 'Cleared',
      options: ['Non-resident', 'Deceased', 'Doesn\'t work with TOUTON anymore', 'Other'],
    );

    if (value == null) {
      if (mounted) {
        setState(() {
          widget.onDataChanged(widget.data.copyWith(farmerStatus: null));
          _fieldErrors.remove('farmerStatus');
          _fieldErrors.remove('availablePerson');
        });
        validateForm();
      }
      return;
    }

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
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        if (mounted) {
          validateForm();
        }
        return;
      }
    }

    if (mounted) {
      setState(() {
        widget.onDataChanged(widget.data.copyWith(farmerStatus: value));
        _fieldErrors.remove('farmerStatus');
        _fieldErrors.remove('availablePerson');
      });
      validateForm();
    }
  }

  void _handleAvailablePersonChanged(String? value) {
    if (!mounted) return;
    
    _logUserInput('Who is available for the interview?', value ?? 'Cleared', options: ['Caretaker', 'Spouse', 'Nobody']);

    setState(() {
      widget.onDataChanged(widget.data.copyWith(availablePerson: value));
      if (value == null) {
        _fieldErrors.remove('availablePerson');
      }
    });
    validateForm();
  }

  bool _shouldShowConsentSection() {
    if (widget.data.farmerStatus == null) {
      return true;
    }

    final nonConsentStatuses = ['Deceased', 'Doesn\'t work with TOUTON anymore', 'Not available', 'Refused'];

    return !nonConsentStatuses.contains(widget.data.farmerStatus);
  }

  Future<void> _handleRecordTime() async {
    if (!mounted) return;
    
    try {
      final now = DateTime.now();
      _logUserInput('Record interview start time', now.toIso8601String(), fieldType: 'timestamp');
      
      if (!mounted) return;
      
      setState(() {
        _fieldErrors.remove('interviewStartTime');
      });
      
      // Create a new ConsentData with the updated time
      final updatedData = widget.data.copyWith(
        interviewStartTime: now,
        timeStatus: 'Recorded at ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      );
      
      // Update the data through the parent
      widget.onDataChanged(updatedData);
      
      // Call the parent's callback
      widget.onRecordTime();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Interview start time recorded'),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      devtools.log('Error recording time: $e', 
          name: _DebugTags.error, 
          error: e, 
          stackTrace: stackTrace);
      
      if (mounted) {
        setState(() {
          _fieldErrors['interviewStartTime'] = 'Failed to record time';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to record time. Please try again.'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
      validateForm();
    }
  }

  Widget _buildRadioOption<T>({
    required T value,
    required T? groupValue,
    required String label,
    required ValueChanged<T?> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      horizontalTitleGap: 8.0,
      leading: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      onTap: () => onChanged(value),
    );
  }

  List<Widget> _buildNonResidentFields() {
    if (widget.data.residesInCommunityConsent != 'No') {
      return [];
    }

    return [
      const SizedBox(height: _Spacing.md),
       
      _buildQuestionCard(
        errorKey: 'otherCommunity',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
          Text('Please specify the community', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),),
                  const SizedBox(height: 16,),
         TextFormField(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
            controller: _otherCommunityController,
            focusNode: _otherCommunityFocusNode,
            decoration: const InputDecoration(
              labelText: 'Please specify the community',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        ),
      ),
    ];
  }

  Future<void> _handleGetLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isGettingLocation = true;
      _fieldErrors.remove('gpsLocation'); // Clear any previous errors
    });
    
    final currentContext = context;
    if (!currentContext.mounted) {
      _isGettingLocation = false;
      return;
    }

    try {
      // Call the parent's location handler
      await widget.onGetLocation();
      
      if (!mounted) return;
      
      // Update form validation state
      if (widget.data.currentPosition != null) {
        setState(() {
          _fieldErrors.remove('gpsLocation');
        });
        
        // Show success message
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Location captured successfully'),
              ],
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      
      if (mounted) {
        validateForm();
      }
    } on PermissionDeniedException catch (e) {
      if (!mounted) return;
      
      final errorMessage = 'Location permission denied. Please enable location permissions in settings.';
      
      setState(() {
        _fieldErrors['gpsLocation'] = errorMessage;
      });
      
      ScaffoldMessenger.of(currentContext)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'SETTINGS',
              textColor: Colors.white,
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
    } on LocationServiceDisabledException catch (e) {
      if (!mounted) return;
      
      final errorMessage = 'Location services are disabled. Please enable them to continue.';
      
      setState(() {
        _fieldErrors['gpsLocation'] = errorMessage;
        validateForm();
      });
      
      ScaffoldMessenger.of(currentContext)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.location_off, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'SETTINGS',
              textColor: Colors.white,
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ),
        );
    } on TimeoutException {
      if (!mounted) return;
      
      final errorMessage = 'Location request timed out. Please try again.';
      
      setState(() {
        _fieldErrors['gpsLocation'] = errorMessage;
        validateForm();
      });
      
      ScaffoldMessenger.of(currentContext)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.timer_off, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: _handleGetLocation,
            ),
          ),
        );
    } catch (e, stackTrace) {
      devtools.log('Error getting location: $e', 
                  name: _DebugTags.error, 
                  error: e, 
                  stackTrace: stackTrace);
      
      if (!mounted) return;
      
      final errorMessage = 'Failed to get location: ${e.toString().replaceAll('Exception: ', '')}';
      
      setState(() {
        _fieldErrors['gpsLocation'] = errorMessage;
        validateForm();
      });
      
      ScaffoldMessenger.of(currentContext)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: _handleGetLocation,
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  List<Widget> _buildFarmerNotAvailableFields() {
    if (widget.data.farmerAvailable != 'No') {
      return [];
    }

    return [
      _buildQuestionCard(
        errorKey: 'farmerStatus',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If No, for what reason?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: _Spacing.md),
            _buildRadioOption(
              value: 'Non-resident',
              groupValue: widget.data.farmerStatus,
              label: 'Non-resident',
              onChanged: _handleFarmerStatusChanged,
            ),
            _buildRadioOption(
              value: 'Deceased',
              groupValue: widget.data.farmerStatus,
              label: 'Deceased',
              onChanged: _handleFarmerStatusChanged,
            ),
            _buildRadioOption(
              value: 'Doesn\'t work with TOUTON anymore',
              groupValue: widget.data.farmerStatus,
              label: 'Doesn\'t work with TOUTON anymore',
              onChanged: _handleFarmerStatusChanged,
            ),
            _buildRadioOption(
              value: 'Other',
              groupValue: widget.data.farmerStatus,
              label: 'Other',
              onChanged: _handleFarmerStatusChanged,
            ),
          ],
        ),
      ),
      if (widget.data.farmerStatus == 'Other') ...[
        const SizedBox(height: _Spacing.md),
        _buildQuestionCard(
          errorKey: 'otherSpecification',
          child: TextFormField(
            controller: _otherSpecController,
            focusNode: _otherSpecFocusNode,
            decoration: const InputDecoration(
              labelText: 'If other, please specify',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
      if (widget.data.farmerStatus == 'Non-resident' || widget.data.farmerStatus == 'Other') ...[
        const SizedBox(height: _Spacing.md),
        _buildQuestionCard(
          errorKey: 'availablePerson',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Who is available for the interview?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: _Spacing.md),
              _buildRadioOption(
                value: 'Caretaker',
                groupValue: widget.data.availablePerson,
                label: 'Caretaker',
                onChanged: _handleAvailablePersonChanged,
              ),
              _buildRadioOption(
                value: 'Spouse',
                groupValue: widget.data.availablePerson,
                label: 'Spouse',
                onChanged: _handleAvailablePersonChanged,
              ),
              _buildRadioOption(
                value: 'Nobody',
                groupValue: widget.data.availablePerson,
                label: 'Nobody',
                onChanged: _handleAvailablePersonChanged,
              ),
            ],
          ),
        ),
      ],
    ];
  }

 Widget _buildConsentSection() {
  if (!_shouldShowConsentSection()) {
    return const SizedBox.shrink();
  }

  return _buildQuestionCard(
    errorKey: 'consent',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consent for Data Processing',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: _Spacing.lg),
        
        // Consent Text Container
        Container(
          height: 300,
          padding: const EdgeInsets.all(_Spacing.lg),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade700 
                  : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey.shade800 
                : Colors.grey.shade50,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'By selecting « Yes, I confirm », I hereby give my free, explicit and unequivocal consent to the processing of my personal data for purposes below ("Purpose") and in accordance with the principles set out in this note ("Note").',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    height: 1.6,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Text(
                  'I understand that the following personal data may be collected and processed:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    height: 1.6,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: _Spacing.sm),
                Text(
                  '• Name, telephone number, e-mail address\n• Gender, date of birth, marital status\n• Level of education\n• Information on my farm and professional experience\n• Information on my household and my family\n• My standard of living and social/economic situation',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    height: 1.6,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Text(
                  'The said purposes relate to the implementation of sustainable development/agricultural programs and projects initiated for the benefit of cocoa farmers and agricultural organizations, the optimization of traceability and sustainability of cocoa production and supply as well as the improvement of yields and livelihoods of cocoa farmers worldwide.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    height: 1.6,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: _Spacing.lg),

        // Consent Checkbox
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _hasGivenConsent,
                onChanged: (value) {
                  _handleConsentChange(value ?? false);
                },
              ),
              const SizedBox(width: _Spacing.sm),
              Expanded(
                child: Text(
                  'Yes, I accept the above conditions',
                  style: TextStyle(fontSize: 13,
                    fontWeight: _hasGivenConsent ? FontWeight.w600 : FontWeight.normal
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
                onChanged: (value) {
                  _handleDeclineChange(value ?? false);
                },
              ),
              const SizedBox(width: _Spacing.sm),
              Expanded(
                child: Text(
                  'No, I refuse and end the survey',
                  style: TextStyle(fontSize: 13,
                    fontWeight: _declinedConsent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Refusal Reason Field (only shown when declined)
        if (_declinedConsent) ...[
          const SizedBox(height: _Spacing.lg),
          TextFormField(
            controller: _refusalReasonController,
            focusNode: _reasonFocusNode,
            decoration: InputDecoration(
              labelText: 'What is your reason for refusing to participate?',
              border: const OutlineInputBorder(),
              errorText: _fieldErrors['refusalReason'],
            ),
            maxLines: 3,
            onChanged: (value) {
              // Update the data
              widget.onDataChanged(widget.data.copyWith(
                refusalReason: value.isNotEmpty ? value : null,
              ));

              // Log the update
              _logUserInput(
                'Refusal reason',
                value,
                fieldType: 'text_input',
              );

              // Update validation state
              if (value.isNotEmpty) {
                setState(() {
                  _fieldErrors.remove('refusalReason');
                });
              }
              validateForm();
            },
          ),
        ],
      ],
    ),
  );
}

  Future<void> _handleNext() async {
    if (_isValidating || !mounted) return;
    
    setState(() => _isValidating = true);

    try {
      // First validate the form
      final validationError = validateForm();
      
      if (validationError != null) {
        // Show the first error in the snackbar
        final firstError = _fieldErrors.values.firstWhere(
          (error) => error != null && error.isNotEmpty,
          orElse: () => null
        );
        
        if (mounted) {
          _showErrorSnackBar(firstError ?? validationError);
        }
        
        return;
      }

      // If we get here, validation passed
      await widget.onNext();
    } catch (e, stackTrace) {
      devtools.log('Error in _handleNext: $e', 
        name: _DebugTags.error, 
        error: e, 
        stackTrace: stackTrace
      );
      if (mounted) {
        _showErrorSnackBar(_ErrorMessages.unexpectedError);
      }
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Consent Form'),
      //   elevation: 0,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interview Time and Location Section
              _buildQuestionCard(
                errorKey: 'interviewStartTime',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interview Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: _Spacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Time:',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                widget.data.interviewStartTime != null
                                    ? '${widget.data.interviewStartTime!.hour.toString().padLeft(2, '0')}:${widget.data.interviewStartTime!.minute.toString().padLeft(2, '0')}'
                                    : 'Not recorded',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _handleRecordTime,
                          icon: const Icon(Icons.access_time),
                          label: const Text('Record Time'),
                        ),
                      ],
                    ),
                    const SizedBox(height: _Spacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GPS Location:',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                widget.data.currentPosition != null
                                    ? 'Captured'
                                    : 'Not captured',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _handleGetLocation,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Get Location'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _Spacing.lg),

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
                          groupValue: widget.data.residesInCommunityConsent,
                          label: 'Yes',
                          onChanged: _handleResidesInCommunityChanged,
                        ),
                        _buildRadioOption(
                          value: 'No',
                          groupValue: widget.data.residesInCommunityConsent,
                          label: 'No',
                          onChanged: _handleResidesInCommunityChanged,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Show community name field if resident is not in this community
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
              ..._buildFarmerNotAvailableFields(),

              // Consent Section
              _buildConsentSection(),

              // const SizedBox(height: 24),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     if (widget.onPrevious != null)
              //       ElevatedButton(
              //         onPressed: widget.onPrevious,
              //         child: const Text('Back'),
              //       )
              //     else
              //       const SizedBox(),
              //     ElevatedButton(
              //       onPressed: _handleNext,
              //       child: const Text('Next'),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 24), // Extra space for bottom button
            ],
          ),
        ),
      ),
    );
  }
}