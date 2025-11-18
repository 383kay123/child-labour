import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:image_picker/image_picker.dart';

// Alias FarmerChild to Child for backward compatibility
typedef Child = FarmerChild;



/// A utility class for consistent spacing throughout the UI
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// Extension to replace firstOrNull which doesn't exist on Iterable by default
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// A widget that displays and collects farmer identification information.
class FarmerIdentification1Page extends StatefulWidget {
  final Function(FarmerIdentificationData)? onComplete;
  final FarmerIdentificationData data;
  final ValueChanged<FarmerIdentificationData> onDataChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Map<String, String>? validationErrors;

  FarmerIdentification1Page({
    Key? key,
    this.onComplete,
    required this.data,
    required this.onDataChanged,
    this.onPrevious,
    this.onNext,
    this.validationErrors,
  }) : super(key: key);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

 @override
State<FarmerIdentification1Page> createState() => FarmerIdentification1PageState();


  /// Validates the form and returns true if all validations pass
  bool validateForm() {
    final isValid = formKey.currentState?.validate() ?? false;
    // Get the state using the global key if available
    if (formKey.currentContext != null) {
      final state = formKey.currentContext!.findAncestorStateOfType<FarmerIdentification1PageState>();
      if (state != null) {
        return isValid && state.validateForm();
      }
    }
    return isValid;
  }
}

class FarmerIdentification1PageState extends State<FarmerIdentification1Page> {
  static const String _tag = 'FarmerIdentification1Page';
  
  // Map to store validation errors
  final Map<String, String> _validationErrors = {};
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Getter for validation errors
  Map<String, String> get validationErrors => _validationErrors;
  
  // Form field controllers
  late final TextEditingController _ghanaCardNumberController;
  late final TextEditingController _idNumberController;
  late final TextEditingController _contactNumberController;
  late final TextEditingController _childrenCountController;
  late final TextEditingController _noConsentReasonController;
  
  // For managing child inputs
  final Map<int, TextEditingController> _childFirstNameControllers = {};
  final Map<int, TextEditingController> _childSurnameControllers = {};
  
  // Focus nodes for text fields
  late final FocusNode _ghanaCardNumberFocus;
  late final FocusNode _idNumberFocus;
  late final FocusNode _contactNumberFocus;
  late final FocusNode _childrenCountFocus;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with data values
    _ghanaCardNumberController = TextEditingController(
      text: widget.data.ghanaCardNumber ?? ''
    );
    _idNumberController = TextEditingController(
      text: widget.data.idNumber ?? ''
    );
    _contactNumberController = TextEditingController(
      text: widget.data.contactNumber ?? ''
    );
    _childrenCountController = TextEditingController(
      text: widget.data.childrenCount > 0 ? widget.data.childrenCount.toString() : ''
    );
    _noConsentReasonController = TextEditingController(
      text: widget.data.noConsentReason ?? ''
    );
    
    // Initialize focus nodes
    _ghanaCardNumberFocus = FocusNode();
    _idNumberFocus = FocusNode();
    _contactNumberFocus = FocusNode();
    _childrenCountFocus = FocusNode();
    
    // Add listeners for real-time validation and data updates
    _ghanaCardNumberController.addListener(_onGhanaCardNumberChanged);
    _idNumberController.addListener(_onIdNumberChanged);
    _contactNumberController.addListener(_onContactNumberChanged);
    _childrenCountController.addListener(_onChildrenCountChanged);
    _noConsentReasonController.addListener(_onNoConsentReasonChanged);
    
    // Initialize child controllers
    _initializeChildControllers();
    
    developer.log('[$_tag] Page initialized', name: _tag);
  }

  @override
  void dispose() {
    // Dispose all controllers
    _ghanaCardNumberController.dispose();
    _idNumberController.dispose();
    _contactNumberController.dispose();
    _childrenCountController.dispose();
    _noConsentReasonController.dispose();
    
    // Dispose focus nodes
    _ghanaCardNumberFocus.dispose();
    _idNumberFocus.dispose();
    _contactNumberFocus.dispose();
    _childrenCountFocus.dispose();
    
    // Dispose child controllers
    for (final controller in _childFirstNameControllers.values) {
      controller.dispose();
    }
    for (final controller in _childSurnameControllers.values) {
      controller.dispose();
    }
    
    super.dispose();
  }

  // ==================== Initialization Methods ====================
  
  void _initializeChildControllers() {
    for (int i = 0; i < widget.data.children.length; i++) {
      final child = widget.data.children[i];
      _childFirstNameControllers[i] = TextEditingController(text: child.firstName);
      _childSurnameControllers[i] = TextEditingController(text: child.surname);
    }
  }

  // ==================== Validation Methods ====================
  
  String? _validateGhanaCardNumber(String? value) {
    // Only validate Ghana Card number if consent is given
    if (widget.data.idPictureConsent == 1) {
      if (value == null || value.isEmpty) {
        return 'Ghana Card number is required when consent is given';
      }
      if (!RegExp(r'^GHA-\d{9}-\d$').hasMatch(value)) {
        return 'Invalid Ghana Card number format (GHA-XXXXXXXXX-X)';
      }
    }
    return null;
  }

  String? _validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'ID number is required';
    }
    return null;
  }

  String? _validateContactNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact number is required';
    }
    // Ghana phone numbers: must be exactly 10 digits starting with 0
    final phoneRegex = RegExp(r'^0[2345]\d{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid 10-digit Ghanaian phone number (e.g., 0241234567)';
    }
    return null;
  }

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName[0].toUpperCase()}${fieldName.substring(1)} is required';
    }
    
    // Check for minimum length (at least 2 characters)
    if (value.trim().length < 2) {
      return '${fieldName[0].toUpperCase()}${fieldName.substring(1)} must be at least 2 characters long';
    }
    
   
    return null;
  }

  /// Validates the entire form and returns true if all validations pass.
  /// Saves the form data after validation
  /// Returns true if save was successful, false otherwise
  Future<bool> saveForm() async {
    try {
      // Validate the form first
      final isValid = validateForm();
      if (!isValid) {
        return false;
      }
      
      // Get the latest form data
      final updatedData = getData();
      
      // Update the data through the callback with the latest values
      widget.onDataChanged(updatedData);
      return true;
    } catch (e) {
      developer.log('[$_tag] Error saving form: $e', name: _tag);
      return false;
    }
  }

  bool validateForm() {
    developer.log('[$_tag] Starting form validation', name: _tag);
    _validationErrors.clear();

    // First check if consent is given for ID picture
    if (widget.data.idPictureConsent == 'No') {
      // If no consent, skip ID validation entirely
      developer.log('[$_tag] No consent given, skipping ID validation', name: _tag);
    } else {
      // Check if user has specified Ghana Card status
      if (widget.data.hasGhanaCard == null) {
        _validationErrors['ghanaCard'] = 'Please specify if you have a Ghana Card';
        developer.log('[$_tag] Validation failed: Ghana Card not specified', name: _tag);
      } 
      // If user has a Ghana Card and has given consent
      else if (widget.data.hasGhanaCard == 1) {
        // Validate Ghana Card number if Ghana Card is selected and consent is given
        final ghanaCardError = _validateGhanaCardNumber(_ghanaCardNumberController.text);
        if (ghanaCardError != null) {
          _validationErrors['ghanaCardNumber'] = ghanaCardError;
          developer.log('[$_tag] Validation failed for Ghana Card number', name: _tag);
        }
      } 
      // If user doesn't have a Ghana Card
      else if (widget.data.hasGhanaCard == 0) {
        // Only require alternative ID if consent is given
        if (widget.data.idPictureConsent == 'Yes') {
          if (widget.data.selectedIdType == null || widget.data.selectedIdType!.isEmpty) {
            _validationErrors['idType'] = 'Please select an alternative ID type';
            developer.log('[$_tag] Validation failed: No alternative ID type selected', name: _tag);
          } else {
            final idNumberError = _validateIdNumber(_idNumberController.text);
            if (idNumberError != null) {
              _validationErrors['idNumber'] = idNumberError;
              developer.log('[$_tag] Validation failed: Invalid ID number', name: _tag);
            }
            
            // Only require ID image if consent is given
            if (widget.data.idImagePath == null) {
              _validationErrors['idImage'] = 'Please capture a picture of the ID';
              developer.log('[$_tag] Validation failed: ID image not captured', name: _tag);
            }
          }
        }
      }
    }

    // Validate contact number
    final contactNumberError = _validateContactNumber(_contactNumberController.text);
    if (contactNumberError != null) {
      _validationErrors['contactNumber'] = contactNumberError;
      developer.log('[$_tag] Validation failed: Invalid contact number', name: _tag);
    }

    // Validate children count
    final childrenCountText = _childrenCountController.text.trim();
    if (childrenCountText.isEmpty) {
      _validationErrors['childrenCount'] = 'Please enter the number of children';
      developer.log('[$_tag] Validation failed: Children count is required', name: _tag);
    } else {
      final childrenCount = int.tryParse(childrenCountText);
      if (childrenCount == null) {
        _validationErrors['childrenCount'] = 'Please enter a valid number';
        developer.log('[$_tag] Validation failed: Invalid children count format', name: _tag);
      } else if (childrenCount < 0) {
        _validationErrors['childrenCount'] = 'Number of children cannot be negative';
        developer.log('[$_tag] Validation failed: Negative children count', name: _tag);
      }

    // Validate no consent reason
    if (widget.data.idPictureConsent == 'No' && _noConsentReasonController.text.trim().isEmpty) {
      _validationErrors['noConsentReason'] = 'Please provide a reason for not consenting';
      developer.log('[$_tag] Validation failed: No consent reason missing', name: _tag);
    }

    // Validate children's names if there are children
    if (childrenCountText.isNotEmpty) {
      final childrenCount = int.tryParse(childrenCountText) ?? 0;
      for (int i = 0; i < childrenCount; i++) {
        final firstName = _childFirstNameControllers[i]?.text.trim() ?? '';
        final surname = _childSurnameControllers[i]?.text.trim() ?? '';
        
        final firstNameError = _validateName(firstName, 'first name');
        if (firstNameError != null) {
          _validationErrors['child_${i}_firstName'] = firstNameError;
          developer.log('[$_tag] Validation failed for child $i first name', name: _tag);
        }
        
        final surnameError = _validateName(surname, 'surname');
        if (surnameError != null) {
          _validationErrors['child_${i}_surname'] = surnameError;
          developer.log('[$_tag] Validation failed for child $i surname', name: _tag);
        }
      }
    }
    }

    final isValid = _validationErrors.isEmpty;
    developer.log('[$_tag] Form validation ${isValid ? 'succeeded' : 'failed'}. Errors: $_validationErrors', name: _tag);
    
    if (mounted) {
      setState(() {}); // Refresh UI to show validation errors
    }
    return isValid;
  }

  // ==================== Change Handlers ====================
  
  void _onGhanaCardNumberChanged() {
    final newValue = _ghanaCardNumberController.text;
    
    // Update the model with the new value
    widget.onDataChanged(
      widget.data.copyWith(ghanaCardNumber: newValue),
    );
    
    // Clear validation error when user starts typing
    if (_validationErrors.containsKey('ghanaCardNumber')) {
      setState(() {
        _validationErrors.remove('ghanaCardNumber');
      });
    }
  }

  void _onIdNumberChanged() {
    final newValue = _idNumberController.text.trim();
    
    widget.onDataChanged(
      widget.data.copyWith(idNumber: newValue),
    );
    
    // Clear validation error when user starts typing
    if (_validationErrors.containsKey('idNumber')) {
      setState(() {
        _validationErrors.remove('idNumber');
      });
    }
  }
  
  void _onContactNumberChanged() {
    final newValue = _contactNumberController.text;
    
    // Update the model with the new value
    widget.onDataChanged(
      widget.data.copyWith(contactNumber: newValue),
    );
    
    // Clear validation error when user starts typing
    if (_validationErrors.containsKey('contactNumber')) {
      setState(() {
        _validationErrors.remove('contactNumber');
      });
    }
  }
  
  void _onChildrenCountChanged() {
    final count = int.tryParse(_childrenCountController.text) ?? 0;
    
    widget.onDataChanged(
      widget.data.copyWith(childrenCount: count),
    );
    
    // Update child controllers if count changes
    if (count > _childFirstNameControllers.length) {
      // Add new controllers
      for (int i = _childFirstNameControllers.length; i < count; i++) {
        _childFirstNameControllers[i] = TextEditingController();
        _childSurnameControllers[i] = TextEditingController();
      }
    } else if (count < _childFirstNameControllers.length) {
      // Remove extra controllers
      final keysToRemove = _childFirstNameControllers.keys.where((key) => key >= count).toList();
      for (final key in keysToRemove) {
        _childFirstNameControllers[key]?.dispose();
        _childSurnameControllers[key]?.dispose();
        _childFirstNameControllers.remove(key);
        _childSurnameControllers.remove(key);
      }
    }
    
    if (mounted) setState(() {});
  }

  void _onNoConsentReasonChanged() {
    final newValue = _noConsentReasonController.text.trim();
    
    widget.onDataChanged(
      widget.data.copyWith(noConsentReason: newValue),
    );
    
    // Clear validation error when user starts typing
    if (_validationErrors.containsKey('noConsentReason')) {
      setState(() {
        _validationErrors.remove('noConsentReason');
      });
    }
  }

  void _onChildNameChanged(int index, String field, String value) {
    widget.onDataChanged(
      widget.data.updateChildName(index, field, value),
    );
    
    // Clear validation error when user starts typing
    final errorKey = 'child_${index}_${field.toLowerCase()}';
    if (_validationErrors.containsKey(errorKey)) {
      setState(() {
        _validationErrors.remove(errorKey);
      });
    }
  }

  // ==================== Action Handlers ====================

  /// Takes a picture of the ID using the device's camera.
  Future<void> _takeIdPicture() async {
    try {
      developer.log('[$_tag] Starting to take ID picture', name: _tag);
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        developer.log('[$_tag] ID picture captured successfully', name: _tag);
        widget.onDataChanged(widget.data.updateIdImagePath(image.path));
        // Clear image validation error
        _validationErrors.remove('idImage');
        setState(() {}); // Refresh UI to show new image
      } else {
        developer.log('[$_tag] User cancelled image capture', name: _tag);
      }
    } catch (e, stackTrace) {
      developer.log(
        '[$_tag] Error taking picture: $e',
        error: e,
        stackTrace: stackTrace,
        name: _tag,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking picture: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Handles the next button press event.
  /// Returns true if validation passes, false otherwise
  bool _handleNext() {
    developer.log('[$_tag] Next button pressed', name: _tag);
    
    // Run validation and check if form is valid
    final isValid = validateForm();
    
    // Update the UI to show validation errors
    if (mounted) {
      setState(() {});
    }
    
    if (!isValid) {
      // Show first validation error
      final firstError = _validationErrors.values.firstOrNull;
      developer.log('[$_tag] Validation failed with errors: $_validationErrors', name: _tag);
      
      if (mounted) {
        // Show error message for the first validation error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(firstError ?? 'Please fill in all required fields'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
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
      return false; // Validation failed
    }

    try {
      // If we reach here, form is valid
      developer.log('[$_tag] Form validation passed', name: _tag);
      
      // Prepare data and call onComplete
      final submissionData = widget.data.toMap();
    // Prepare data and call onComplete
widget.onComplete?.call(widget.data);
      developer.log('[$_tag] Form submitted successfully', name: _tag);
      
      // Only proceed with navigation if we're still mounted
      if (mounted) {
        widget.onNext?.call();
      }
      return true; // Validation passed
    } catch (e, stackTrace) {
      developer.log(
        '[$_tag] Error submitting form: $e',
        error: e,
        stackTrace: stackTrace,
        name: _tag,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while saving your information. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return false;
    }
  }

  /// REQUIRED: Returns full current data
  FarmerIdentificationData getData() {
    final childrenCount = int.tryParse(_childrenCountController.text) ?? 0;
    final children = <Child>[];

    for (int i = 0; i < childrenCount; i++) {
      final firstName = _childFirstNameControllers[i]?.text.trim() ?? '';
      final surname = _childSurnameControllers[i]?.text.trim() ?? '';
      if (firstName.isNotEmpty || surname.isNotEmpty) {
        children.add(Child(
          childNumber: i + 1, // 1-based index for child numbers
          firstName: firstName, 
          surname: surname,
        ));
      }
    }

    return widget.data.copyWith(
      ghanaCardNumber: _ghanaCardNumberController.text.isEmpty ? null : _ghanaCardNumberController.text.trim(),
      idNumber: _idNumberController.text.isEmpty ? null : _idNumberController.text.trim(),
      contactNumber: _contactNumberController.text.isEmpty ? null : _contactNumberController.text.trim(),
      childrenCount: childrenCount,
      children: children,
      noConsentReason: _noConsentReasonController.text.isEmpty ? null : _noConsentReasonController.text.trim(),
    );
  }

  // ==================== UI Builder Methods ====================

  /// Builds a card widget to display a form question with consistent styling.
  Widget _buildQuestionCard({required Widget child, String? errorKey}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey.shade200,
          width: 1.0,
        ),
      ),
      color: isDark ? Colors.grey[900] : Colors.white,
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
    String? errorKey,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RadioListTile<String>(
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        if (!mounted) return;  // Check if widget is still mounted
        onChanged(newValue);
        // Clear validation error when user makes selection
        if (errorKey != null && _validationErrors.containsKey(errorKey)) {
          if (mounted) {  // Check again before setState
            setState(() {
              _validationErrors.remove(errorKey);
            });
          }
        }
      },
      activeColor: Colors.green.shade600,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      tileColor: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    String? errorKey,
    bool enabled = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = errorKey != null && _validationErrors.containsKey(errorKey);
    final errorMessage = hasError ? _validationErrors[errorKey] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          enabled: enabled,
          textCapitalization: textCapitalization,
          
          // Cursor styling
          cursorColor: isDark ? Colors.white : Colors.black87,
          cursorWidth: 2.0,
          
          // Text styling for visibility
          style: GoogleFonts.inter(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w400,
          ),
          
          onChanged: (value) {
            if (onChanged != null) {
              onChanged(value);
            }
            
            // Clear validation error when user starts typing
            if (errorKey != null && _validationErrors.containsKey(errorKey)) {
              setState(() {
                _validationErrors.remove(errorKey);
              });
            }
          },
          
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
            
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 1.0,
              ),
            ),
            
            counterText: '',
            
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Section Builders ====================

  Widget _buildGhanaCardSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Initialize as null to ensure no option is pre-selected
    final hasGhanaCard = widget.data.hasGhanaCard == null ? null : (widget.data.hasGhanaCard == 1 ? 'Yes' : 'No');

    return _buildQuestionCard(
      errorKey: 'ghanaCard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Does the farmer have a Ghana Card?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
          ),
          const SizedBox(height: _Spacing.md),
          Column(
            children: [
              _buildRadioOption(
                value: 'Yes',
                groupValue: hasGhanaCard,
                label: 'Yes',
                onChanged: (value) {
                  widget.onDataChanged(widget.data.updateGhanaCard(1));
                },
                errorKey: 'ghanaCard',
              ),
              _buildRadioOption(
                value: 'No',
                groupValue: hasGhanaCard,
                label: 'No',
                onChanged: (value) {
                  widget.onDataChanged(widget.data.updateGhanaCard(0));
                },
                errorKey: 'ghanaCard',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeIdSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.data.hasGhanaCard == 1) return const SizedBox.shrink();

    return _buildQuestionCard(
      errorKey: 'idType',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which other national id card is available?',
           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
          ),
          const SizedBox(height: _Spacing.md),
          Column(
            children: [
              _buildRadioOption(
                value: 'voter_id',
                groupValue: widget.data.selectedIdType,
                label: 'Voter ID',
                onChanged: (value) {
                  if (!mounted) return;
                  try {
                    widget.onDataChanged(widget.data.updateIdType(value));
                  } catch (e) {
                    developer.log('Error updating ID type: $e', name: _tag);
                  }
                },
                errorKey: 'idType',
              ),
              _buildRadioOption(
                value: 'drivers_license',
                groupValue: widget.data.selectedIdType,
                label: 'Driver\'s License',
                onChanged: (value) {
                  if (!mounted) return;
                  try {
                    widget.onDataChanged(widget.data.updateIdType(value));
                  } catch (e) {
                    developer.log('Error updating ID type: $e', name: _tag);
                  }
                },
                errorKey: 'idType',
              ),
              _buildRadioOption(
                value: 'nhis_card',
                groupValue: widget.data.selectedIdType,
                label: 'NHIS Card',
                onChanged: (value) {
                  if (!mounted) return;
                  try {
                    widget.onDataChanged(widget.data.updateIdType(value));
                  } catch (e) {
                    developer.log('Error updating ID type: $e', name: _tag);
                  }
                },
                errorKey: 'idType',
              ),
              _buildRadioOption(
                value: 'passport',
                groupValue: widget.data.selectedIdType,
                label: 'Passport',
                onChanged: (value) {
                  if (!mounted) return;
                  try {
                    widget.onDataChanged(widget.data.updateIdType(value));
                  } catch (e) {
                    developer.log('Error updating ID type: $e', name: _tag);
                  }
                },
                errorKey: 'idType',
              ),
              _buildRadioOption(
                value: 'ssnit',
                groupValue: widget.data.selectedIdType,
                label: 'SSNIT',
                onChanged: (value) {
                  widget.onDataChanged(widget.data.updateIdType(value));
                },
                errorKey: 'idType',
              ),
              _buildRadioOption(
                value: 'birth_certificate',
                groupValue: widget.data.selectedIdType,
                label: 'Birth Certificate',
                onChanged: (value) {
                  widget.onDataChanged(widget.data.updateIdType(value));
                },
                errorKey: 'idType',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsentSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Only show this section if we have a valid selection
    if (widget.data.hasGhanaCard == null) {
      return const SizedBox.shrink();
    }
    
    final hasGhanaCard = widget.data.hasGhanaCard == 1;

    // Only show if we have a valid ID type when Ghana Card is not selected
    if (!hasGhanaCard && widget.data.selectedIdType == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildQuestionCard(
          errorKey: 'consent',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasGhanaCard
                    ? 'Do you consent to us taking a picture of your Ghana Card and recording the card number?'
                    : 'Do you consent to us taking a picture of your ${_getIdTypeDisplayName(widget.data.selectedIdType)} and recording the ID number?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: _Spacing.md),
              Column(
                children: [
                  _buildRadioOption(
                    value: 'Yes',
                    groupValue: widget.data.idPictureConsent == 1 ? 'Yes' : 'No',
                    label: 'Yes',
                    onChanged: (value) {
                      widget.onDataChanged(widget.data.updatePictureConsent(value));
                    },
                    errorKey: 'consent',
                  ),
                  _buildRadioOption(
                    value: 'No',
                    groupValue: widget.data.idPictureConsent == 1 ? 'Yes' : 'No',
                    label: 'No',
                    onChanged: (value) {
                      widget.onDataChanged(widget.data.updatePictureConsent(value));
                    },
                    errorKey: 'consent',
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Show reason field only when consent is 'No'
        if (widget.data.idPictureConsent == 0)
          Padding(
            padding: const EdgeInsets.only(top: _Spacing.md),
            child: _buildQuestionCard(
              errorKey: 'noConsentReason',
              child: _buildTextField(
                label: 'Please specify reason',
                controller: _noConsentReasonController,
                hintText: 'Enter your reason for not providing consent',
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                onChanged: (value) {
                  // Handled by listener
                },
                errorKey: 'noConsentReason',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIdNumberSection() {
    // Ghana Card Number Field - Only show if consent is given
    if (widget.data.hasGhanaCard == 1 && widget.data.idPictureConsent == 1) {
      return _buildQuestionCard(
        errorKey: 'ghanaCardNumber',
        child: _buildTextField(
          label: 'Ghana Card Number (GHA-XXXXXXXXX-X)',
          controller: _ghanaCardNumberController,
          hintText: 'Enter Ghana Card number (e.g., GHA-123456789-0)',
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) {
            // Handled by listener
          },
          errorKey: 'ghanaCardNumber',
        ),
      );
    }

    // Alternative ID Number Field
    if (widget.data.hasGhanaCard == 0 &&
        widget.data.selectedIdType != null) {
      return _buildQuestionCard(
        errorKey: 'idNumber',
        child: _buildTextField(
          label: '${_getIdTypeDisplayName(widget.data.selectedIdType)} Number',
          controller: _idNumberController,
          hintText: 'Enter your ${_getIdTypeDisplayName(widget.data.selectedIdType)} number',
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) {
            // Handled by listener
          },
          errorKey: 'idNumber',
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildIdPictureSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.data.idPictureConsent != 1) return const SizedBox.shrink();

    return _buildQuestionCard(
      errorKey: 'idImage',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.data.hasGhanaCard == 1
                ? 'Ghana Card Picture'
                : '${_getIdTypeDisplayName(widget.data.selectedIdType)} Picture',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: _Spacing.md),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.grey[800] : Colors.grey[100],
            ),
            child: widget.data.idImagePath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No image captured',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.data.idImagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
          ),
          const SizedBox(height: _Spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _takeIdPicture,
              icon: const Icon(Icons.camera_alt, size: 20),
              label: Text(
                widget.data.idImagePath == null
                    ? 'Take Picture of ID'
                    : 'Retake Picture',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactNumberSection() {
    return _buildQuestionCard(
      errorKey: 'contactNumber',
      child: _buildTextField(
        label: 'Contact Number',
        controller: _contactNumberController,
        hintText: 'Enter 10-digit phone number (e.g., 0241234567)',
        keyboardType: TextInputType.phone,
        maxLength: 10,
        onChanged: (value) {
          // Handled by listener
        },
        errorKey: 'contactNumber',
      ),
    );
  }

  Widget _buildChildrenCountSection() {
    return _buildQuestionCard(
      errorKey: 'childrenCount',
      child: _buildTextField(
        label: 'Number of Children (Aged 5-17)',
        controller: _childrenCountController,
        hintText: 'Enter number of children',
        keyboardType: TextInputType.number,
        onChanged: (value) {
          // Handled by listener
        },
        errorKey: 'childrenCount',
      ),
    );
  }

  Widget _buildChildrenDetailsSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final childrenCount = widget.data.childrenCount;

    if (childrenCount <= 0) return const SizedBox.shrink();

    return _buildQuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.child_care, color: Colors.green.shade600),
              const SizedBox(width: 12),
              Text(
                'Farmer\'s Children (Aged 5-17)',
             style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: _Spacing.md),
          Text(
            'Total Children: $childrenCount',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: _Spacing.sm),
          ...List.generate(
            childrenCount,
            (index) {
              final childNumber = index + 1;
              
              // Get or create controllers for this child
              final firstNameController = _childFirstNameControllers.putIfAbsent(
                index, 
                () => TextEditingController(
                  text: index < widget.data.children.length 
                      ? widget.data.children[index].firstName 
                      : ''
                )
              );
              final surnameController = _childSurnameControllers.putIfAbsent(
                index, 
                () => TextEditingController(
                  text: index < widget.data.children.length 
                      ? widget.data.children[index].surname 
                      : ''
                )
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: _Spacing.lg),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Child $childNumber',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                        ),
                        const SizedBox(height: _Spacing.md),
                        _buildTextField(
                          label: 'First Name',
                          controller: firstNameController,
                          hintText: 'Enter first name',
                          onChanged: (value) {
                            _onChildNameChanged(index, 'firstName', value);
                          },
                          errorKey: 'child_${index}_firstName',
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: _Spacing.md),
                        _buildTextField(
                          label: 'Surname',
                          controller: surnameController,
                          hintText: 'Enter surname',
                          onChanged: (value) {
                            _onChildNameChanged(index, 'surname', value);
                          },
                          errorKey: 'child_${index}_surname',
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== Main Build Method ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_Spacing.lg),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ghana Card Question
                    _buildGhanaCardSection(),

                    // Alternative ID Options
                    _buildAlternativeIdSection(),

                    // Consent Question
                    _buildConsentSection(),

                    // ID Number Field (Ghana Card or Alternative)
                    _buildIdNumberSection(),

                    // ID Picture Capture
                    _buildIdPictureSection(),

                    // Contact Number
                    _buildContactNumberSection(),

                    // Number of Children
                    _buildChildrenCountSection(),

                    // Children Details
                    _buildChildrenDetailsSection(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Helper Methods ====================

  /// Helper method to convert ID type key to display name
  String _getIdTypeDisplayName(String? idType) {
    switch (idType) {
      case 'voter_id':
        return 'Voter ID';
      case 'drivers_license':
        return 'Driver\'s License';
      case 'nhis_card':
        return 'NHIS Card';
      case 'passport':
        return 'Passport';
      case 'ssnit':
        return 'SSNIT';
      case 'birth_certificate':
        return 'Birth Certificate';
      default:
        return 'ID';
    }
  }
} 