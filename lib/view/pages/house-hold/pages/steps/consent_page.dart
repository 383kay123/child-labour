import 'dart:async';
import 'dart:developer' as devtools;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/models/consent_model.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
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
  bool _hasGivenConsent = true;
  bool _declinedConsent = false;

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

    // Initialize consent states from widget.data with default values if null
    _hasGivenConsent = widget.data.consentGiven ?? true;
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
    _refusalReasonController.addListener(_handleRefusalReasonChanged);
    _otherCommunityController.addListener(_handleOtherCommunityChanged);
    _otherSpecController.addListener(_handleOtherSpecChangedListener);

    _debugPrintInitialState();

    // Automatically record interview time and GPS location on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.data.interviewStartTime == null) {
        _handleRecordTime();
      }
      if (widget.data.currentPosition == null) {
        _handleGetLocation();
      }
    });
  }

  void _debugPrintInitialState() {
    if (kDebugMode) {
      print('=== Consent Form Initial State ===');
      print('Consent Given: ${widget.data.consentGiven}');
      print('Refusal Reason: ${widget.data.refusalReason}');
      print('Community Type: ${widget.data.communityType}');
      print('Other Community: ${widget.data.otherCommunityName}');
      print('Other Specification: ${widget.data.otherSpecification}');
      print('Resides in Community: ${widget.data.residesInCommunityConsent}');
      print('Interview Start Time: ${widget.data.interviewStartTime}');
      print('GPS Location: ${widget.data.currentPosition}');
      print('==============================');
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
      _hasGivenConsent = widget.data.consentGiven ?? true;
    }
    if (widget.data.declinedConsent != oldWidget.data.declinedConsent) {
      _declinedConsent = widget.data.declinedConsent ?? false;
    }
    
    devtools.log('ConsentPage updated', name: 'state');
  }

  @override
  void dispose() {
    // CRITICAL: Remove listeners BEFORE disposing controllers
    _refusalReasonController.removeListener(_handleRefusalReasonChanged);
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
    
    devtools.log('ConsentPage disposed', name: 'state');
    super.dispose();
  }

  /// Saves the current consent data to the local database
  Future<bool> saveData() async {
    try {
      if (!mounted) return false;
      
      // Create a copy of the current data with updated values from the form
      final updatedData = widget.data.copyWith(
        communityType: widget.data.communityType,
        residesInCommunityConsent: _residesInCommunity == true ? 'Yes' : 'No',
        farmerAvailable: widget.data.farmerAvailable,
        farmerStatus: widget.data.farmerStatus,
        availablePerson: widget.data.availablePerson,
        otherSpecification: _otherSpecController.text.trim(),
        otherCommunityName: _otherCommunityController.text.trim(),
        consentGiven: _hasGivenConsent,
        declinedConsent: _declinedConsent,
        refusalReason: _refusalReasonController.text.trim(),
        consentTimestamp: DateTime.now(),
      );

      // Get the database instance
      final db = await LocalDBHelper.instance.database;
        
      try {
        // Save the data
        int? id;
        if (updatedData.id == null) {
          // Insert new record
          id = await db.insert(TableNames.consentTBL, updatedData.toMap());
          debugPrint('✅ Consent data inserted successfully with ID: $id');
        } else {
          // Update existing record
          id = await db.update(
            TableNames.consentTBL,
            updatedData.toMap(),
            where: 'id = ?',
            whereArgs: [updatedData.id],
          );
          debugPrint('✅ Consent data updated successfully for ID: ${updatedData.id}');
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
        } else {
          debugPrint('❌ Failed to save consent data: No valid ID returned');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save consent data: No ID returned'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return false;
        }
      } catch (e) {
        debugPrint('❌ Database error: $e');
        rethrow;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in saveData: $e');
      debugPrint('Stack trace: $stackTrace');
      
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

  // void _handleRefusalReasonChanged() {
  //   if (!mounted) return;
  //   final value = _refusalReasonController.text;
  //   widget.onDataChanged(widget.data.copyWith(refusalReason: value));
  //   validateForm();
  // }

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
    devtools.log('USER INPUT CAPTURED - $question: $value', name: 'user_input');

    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'action': 'user_input',
      'question': question,
      'value': value.toString(),
      'field_type': fieldType ?? 'unspecified',
      'available_options': options?.join(', ') ?? 'N/A',
    };

    devtools.log(jsonEncode(logData), name: 'user_input');
    devtools.log('🎯 USER SELECTION: $question → $value', name: 'user_input');
  }

  /// Log validation events
  void _logValidation(String field, String status, {String? message}) {
    devtools.log(
      'VALIDATION: $field - $status${message != null ? ' - $message' : ''}',
      name: 'validation',
    );
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

  // Use a local variable to track the new state
  final newConsentGiven = value;
  final newDeclinedConsent = !value;

  try {
    _logUserInput('Do you consent to participate?', 
        newConsentGiven ? 'Yes' : 'No', 
        options: ['Yes', 'No']);

    // First update the local state
    setState(() {
      _hasGivenConsent = newConsentGiven;
      _declinedConsent = newDeclinedConsent;
      if (_hasGivenConsent) {
        _refusalReasonController.clear();
        _fieldErrors.remove('refusalReason');
      }
    });

    // Create the updated data
    final updatedData = widget.data.copyWith(
      consentGiven: newConsentGiven,
      declinedConsent: newDeclinedConsent,
      refusalReason: newConsentGiven ? null : _refusalReasonController.text,
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
      final consentStatus = newConsentGiven ? '✅ CONSENT GIVEN' : '❌ CONSENT DECLINED';
      
      debugPrint('🔄 $consentStatus');
      debugPrint('📅 Timestamp: $timestamp');
      debugPrint('✔️ Consent Given: $newConsentGiven');
      debugPrint('✖️ Declined Consent: $newDeclinedConsent');
      
      if (!newConsentGiven) {
        debugPrint('📝 Refusal Reason: "${_refusalReasonController.text}"');
      }
      
      debugPrint('--------------------------------');
      debugPrint('Data saved successfully! 🎉\n');
      
      // Also log to devtools for more detailed inspection
      devtools.log(
        'Consent data saved',
        name: 'ConsentPage',
        time: DateTime.now(),
        error: {
          'consentGiven': newConsentGiven,
          'declinedConsent': newDeclinedConsent,
          'refusalReason': newConsentGiven ? 'N/A' : _refusalReasonController.text,
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
        _hasGivenConsent = !newConsentGiven;
        _declinedConsent = !newDeclinedConsent;
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
      _hasGivenConsent = !newConsentGiven;
      _declinedConsent = !newDeclinedConsent;
    });
  }
}

void _handleDeclineChange(bool value) {
  if (!mounted) return;
  
  if (value == true) {
    // If declining, uncheck consent given if it was checked
    if (_hasGivenConsent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasGivenConsent = false;
          });
        }
      });
    }
    
    // Update the declined consent state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _declinedConsent = true;
        });
      }
    });
    
    // Focus on the reason field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_reasonFocusNode);
      }
    });
  } else {
    // If unchecking the decline option
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _declinedConsent = false;
          _refusalReasonController.clear();
          _fieldErrors.remove('refusalReason');
        });
        // Update parent widget
        widget.onDataChanged(widget.data.copyWith(
          declinedConsent: false,
          refusalReason: null,
        ));
        validateForm();
      }
    });
  }
}

// Update the refusal reason field to show end survey confirmation when submitted
void _handleRefusalReasonChanged() {
  final reason = _refusalReasonController.text.trim();
  if (reason.isNotEmpty) {
    // Clear any existing error
    setState(() {
      _fieldErrors.remove('refusalReason');
    });
    
    // Update parent with the reason
    widget.onDataChanged(widget.data.copyWith(
      declinedConsent: true,
      refusalReason: reason,
    ));
    
    // Show the end survey confirmation
    _showEndSurveyConfirmation();
  } else {
    // Show error if reason is empty
    setState(() {
      _fieldErrors['refusalReason'] = 'Please provide a reason for declining';
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
          child: const Text(
            'Decline & End',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirm == true && mounted) {
    // Update the parent widget
    widget.onDataChanged(widget.data.copyWith(
      declinedConsent: true,
      refusalReason: _refusalReasonController.text,
      consentGiven: false,
    ));
    
    // Call the survey end callback
    widget.onSurveyEnd?.call();
  } else if (mounted) {
    // If user cancels, uncheck the decline option
    setState(() {
      _declinedConsent = false;
      _refusalReasonController.clear();
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

  void _handleRecordTime() {
    if (!mounted) return;
    
    _logUserInput('Record interview start time', DateTime.now().toIso8601String(), fieldType: 'timestamp');
    widget.onRecordTime();
    if (mounted) {
      _fieldErrors.remove('interviewStartTime');
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
                  SizedBox(height: 16,),
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
    
    try {
      devtools.log('Initiating location capture', name: _DebugTags.location);
      
      // Store context in a local variable to use in callbacks
      final currentContext = context;
      if (!currentContext.mounted) return;
      
      // Show loading SnackBar
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 16),
              Text('Getting your location...'),
            ],
          ),
          duration: Duration(seconds: 30),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.blue,
        ),
      );

      try {
        // Call the parent's location handler
        await widget.onGetLocation();
        
        if (!mounted) return;
        
        // Dismiss the loading SnackBar
        ScaffoldMessenger.of(currentContext).removeCurrentSnackBar();
        
        // Update form validation state
        if (widget.data.currentPosition != null) {
          setState(() {
            _fieldErrors.remove('gpsLocation');
          });
          
          // Show success message
          if (mounted) {
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
        }
        
        if (mounted) {
          validateForm();
        }
      } catch (e, stackTrace) {
        devtools.log('Error getting location: $e', 
                     name: _DebugTags.error, 
                     error: e, 
                     stackTrace: stackTrace);
        
        if (!mounted) return;
        
        // Dismiss the loading SnackBar
        ScaffoldMessenger.of(currentContext).removeCurrentSnackBar();
        
        // Show error message
        final errorMessage = e is PermissionDeniedException
            ? 'Location permission denied. Please enable location permissions in settings.'
            : e is LocationServiceDisabledException
                ? 'Location services are disabled. Please enable them to continue.'
                : 'Failed to get location: ${e.toString()}';
        
        setState(() {
          _fieldErrors['gpsLocation'] = errorMessage;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
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
      }
    } catch (e, stackTrace) {
      devtools.log('Unexpected error in _handleGetLocation: $e', 
                  name: _DebugTags.error, 
                  error: e, 
                  stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred while getting location'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  } on LocationServiceDisabledException catch (e) {
      devtools.log('Location services disabled: $e', name: _DebugTags.error);
      
      if (!mounted) return;
      
      // Store context in a local variable to use in callbacks
      final currentContext = context;
      
      // Update form validation state first
      setState(() {
        _fieldErrors['gpsLocation'] = 'Location services are disabled';
        validateForm();
      });
      
      // Then show the snackbar
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.location_off, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Location services are disabled. Please enable them in settings.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
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
      }
    } catch (e, stackTrace) {
      devtools.log('Location error: $e', name: _DebugTags.error, error: e, stackTrace: stackTrace);
      
      if (!mounted) return;
      
      final errorMessage = e is TimeoutException
          ? 'Location request timed out. Please try again.'
          : 'Error getting location: ${e.toString().replaceAll('Exception: ', '')}';
      
      // Store context in a local variable to use in callbacks
      final currentContext = context;
      
      // Update form validation state first
      setState(() {
        _fieldErrors['gpsLocation'] = errorMessage;
        validateForm();
      });
      
      // Then show the snackbar
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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

                    const SizedBox(height: 120), // Extra space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}