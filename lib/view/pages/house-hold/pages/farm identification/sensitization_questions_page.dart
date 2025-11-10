import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/daos/sensitization_questions_dao.dart';
import 'package:human_rights_monitor/controller/models/sensitization_questions_model.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/app_theme.dart';

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class SensitizationQuestionsPage extends StatefulWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool validateOnly;

  const SensitizationQuestionsPage({
    Key? key,
    required this.onPrevious,
    required this.onNext,
    this.validateOnly = false,
  }) : super(key: key);

  @override
  SensitizationQuestionsPageState createState() =>
      SensitizationQuestionsPageState();
}

class SensitizationQuestionsPageState extends State<SensitizationQuestionsPage> {
  // Form key for validation and form state management
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _femaleAdultsController = TextEditingController();
  final TextEditingController _maleAdultsController = TextEditingController();
  final TextEditingController _consentReasonController = TextEditingController();
  final TextEditingController _reactionController = TextEditingController();
  
  // Form state variables
  bool? hasSensitizedHousehold;
  bool? hasSensitizedOnProtection;
  bool? hasSensitizedOnSafeLabour;
  bool? _consentForPicture;
  
  // Image handling
  File? _sensitizationImage;
  File? _householdWithUserImage;
  final ImagePicker _picker = ImagePicker();
  
  // For logging
  static const String _logTag = 'SensitizationQuestionsPage';

 
  /// Validates the form and returns true if all fields are valid
  /// [silent] - If true, won't show error messages (used for parent validation)
  bool validateForm({bool silent = false}) {
    // First validate the form state
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      if (!silent) {
        _showErrorSnackBar('Please fill in all required fields');
      }
      return false;
    }

    bool isValid = true;
    String? firstError;
    
    // Check each required field and track the first error
    if (hasSensitizedHousehold == null) {
      firstError ??= 'Please indicate if you have sensitized the household members';
      isValid = false;
    }
    
    if (hasSensitizedOnProtection == null) {
      firstError ??= 'Please indicate if you have sensitized on protection';
      isValid = false;
    }
    
    if (hasSensitizedOnSafeLabour == null) {
      firstError ??= 'Please indicate if you have sensitized on safe labor';
      isValid = false;
    }
    
    if (_femaleAdultsController.text.isEmpty) {
      firstError ??= 'Please enter the number of female adults';
      isValid = false;
    }
    
    if (_maleAdultsController.text.isEmpty) {
      firstError ??= 'Please enter the number of male adults';
      isValid = false;
    }
    
    if (_consentForPicture == null) {
      firstError ??= 'Please indicate if consent for picture was given';
      isValid = false;
    } else if (_consentForPicture == false && _consentReasonController.text.isEmpty) {
      firstError ??= 'Please provide a reason for not giving consent';
      isValid = false;
    }
    
    if (_sensitizationImage == null) {
      firstError ??= 'Please take a sensitization picture';
      isValid = false;
    }
    
    if (_householdWithUserImage == null) {
      firstError ??= 'Please take a picture with the household';
      isValid = false;
    }
    
    if (_reactionController.text.isEmpty) {
      firstError ??= 'Please provide your reaction/feedback';
      isValid = false;
    }
    
    // Only show error message if not in silent mode and there's an error
    if (!silent && !isValid && firstError != null) {
      _showErrorSnackBar(firstError);
    }
    
    developer.log('Form validation - Valid: $isValid', name: _logTag);
    return isValid;
  }
  
  /// Saves the sensitization questions data to the database
  /// [farmIdentificationId] - The ID of the farm identification record to associate with this data
  Future<bool> saveData(int farmIdentificationId) async {
    try {
      // First validate the form
      if (!validateForm(silent: true)) {
        developer.log('Form validation failed, not saving data', name: _logTag);
        return false;
      }

      // Get the database helper instance
      final questionsDao = SensitizationQuestionsDao(dbHelper: LocalDBHelper.instance);
      
      // Create a SensitizationQuestionsData model with the current state
      final model = SensitizationQuestionsData(
        hasSensitizedHousehold: hasSensitizedHousehold,
        hasSensitizedOnProtection: hasSensitizedOnProtection,
        hasSensitizedOnSafeLabour: hasSensitizedOnSafeLabour,
        femaleAdultsCount: _femaleAdultsController.text,
        maleAdultsCount: _maleAdultsController.text,
        consentForPicture: _consentForPicture,
        consentReason: _consentForPicture == false ? _consentReasonController.text : '',
        sensitizationImagePath: _sensitizationImage?.path,
        householdWithUserImagePath: _householdWithUserImage?.path,
        parentsReaction: _reactionController.text,
      );

      // Check if a record already exists for this farm identification
      final existingRecord = await questionsDao.getByFarmIdentificationId(farmIdentificationId);
      
      // Save the data
      if (existingRecord == null) {
        // Insert new record
        await questionsDao.insert(model, farmIdentificationId);
      } else {
        // Update existing record - use the ID from the existing record
        // Note: This assumes the SensitizationQuestionsDao.update method takes a farmId parameter
        await questionsDao.update(model, farmIdentificationId);
      }
      
      developer.log('✅ Sensitization questions data saved successfully', name: _logTag);
      return true;
    } catch (e) {
      developer.log('❌ Error saving sensitization questions data: $e', name: _logTag);
      return false;
    }
  }
  
  /// Shows an error message to the user
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Captures an image using the device camera
  ///
  /// [isHouseholdWithUser] - If true, stores as household with user image,
  /// otherwise stores as sensitization image
  @override
  Future<void> _takePicture(bool isHouseholdWithUser) async {
    developer.log(
        'Initiating image capture. Type: ${isHouseholdWithUser ? 'Household with user' : 'Sensitization'}',
        name: _logTag);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (photo != null) {
        developer.log('Image captured successfully: ${photo.path}',
            name: _logTag);

        setState(() {
          if (isHouseholdWithUser) {
            _householdWithUserImage = File(photo.path);
            developer.log('Household with user image updated', name: _logTag);
          } else {
            _sensitizationImage = File(photo.path);
            developer.log('Sensitization image updated', name: _logTag);
          }
        });
      } else {
        developer.log('Image capture was cancelled by user', name: _logTag);
      }
    } catch (e, stackTrace) {
      developer.log('Error capturing image: $e',
          name: _logTag, error: e, stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to capture image. Please try again.'),
          backgroundColor: Colors.red,
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
  }

  @override
  void dispose() {
    developer.log('Disposing resources', name: _logTag);

    // Dispose all controllers to prevent memory leaks
    try {
      _femaleAdultsController.dispose();
      _maleAdultsController.dispose();
      _consentReasonController.dispose();
      _reactionController.dispose();
      developer.log('All controllers disposed successfully', name: _logTag);
    } catch (e) {
      developer.log('Error disposing controllers: $e', name: _logTag, error: e);
    }

    super.dispose();
  }

  /// Builds a consistent card widget for form questions
  ///
  /// [child] - The widget to be wrapped in the card
  Widget _buildQuestionCard({required Widget child}) {
    developer.log('Building question card', name: _logTag);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: _Spacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.lg),
        child: child,
      ),
    );
  }

  Widget _buildRadioOption({
    required bool value,
    required bool? groupValue,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RadioListTile<bool>(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      tileColor: isDark ? AppTheme.darkCard : Colors.white,
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
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.md),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _Spacing.lg,
              vertical: _Spacing.md,
            ),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildImageSection({
    required String title,
    required String note,
    required File? image,
    required VoidCallback onTakePicture,
    required String buttonText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _buildQuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: _Spacing.sm),
          Text(
            note,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: _Spacing.md),

          // Image Preview
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? AppTheme.darkBackground : Colors.grey[100],
            ),
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 48,
                        color:
                            isDark ? AppTheme.darkTextSecondary : Colors.grey,
                      ),
                      const SizedBox(height: _Spacing.sm),
                      Text(
                        'No image captured',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              isDark ? AppTheme.darkTextSecondary : Colors.grey,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
          ),
          const SizedBox(height: _Spacing.md),

          // Capture Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTakePicture,
              icon: const Icon(Icons.camera_alt, size: 20),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Sensitization Questions'),
      //   backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      //   elevation: 0,
      //   iconTheme: IconThemeData(
      //     color: isDark ? Colors.white : AppTheme.primaryColor,
      //   ),
      // ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 100.0, // Space for bottom buttons
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question 1: Sensitization Status
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. Have you sensitized the household members?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: _Spacing.md),
                        Wrap(
                          spacing: 20,
                          children: [
                            _buildRadioOption(
                              value: true,
                              groupValue: hasSensitizedHousehold,
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  hasSensitizedHousehold = value;
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: false,
                              groupValue: hasSensitizedHousehold,
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  hasSensitizedHousehold = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Question 2: Child Protection Sensitization
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2. Have you sensitized the household members on Child Protection?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: _Spacing.md),
                        Wrap(
                          spacing: 20,
                          children: [
                            _buildRadioOption(
                              value: true,
                              groupValue: hasSensitizedOnProtection,
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  hasSensitizedOnProtection = value;
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: false,
                              groupValue: hasSensitizedOnProtection,
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  hasSensitizedOnProtection = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Question 3: Safe Labour Practices Sensitization
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3. Have you sensitized the household members on Safe Labour Practices?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: _Spacing.md),
                        Wrap(
                          spacing: 20,
                          children: [
                            _buildRadioOption(
                              value: true,
                              groupValue: hasSensitizedOnSafeLabour,
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  hasSensitizedOnSafeLabour = value;
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: false,
                              groupValue: hasSensitizedOnSafeLabour,
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  hasSensitizedOnSafeLabour = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Question 4: Female Adults Count
                  _buildQuestionCard(
                    child: _buildTextField(
                      label:
                          '4. How many female adults were present during the sensitization?',
                      controller: _femaleAdultsController,
                      hintText: 'Enter number of female adults',
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  // Question 5: Male Adults Count
                  _buildQuestionCard(
                    child: _buildTextField(
                      label:
                          '5. How many male adults were present during the sensitization?',
                      controller: _maleAdultsController,
                      hintText: 'Enter number of male adults',
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  // Question 6: Picture Consent
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '6. Does the producer consent to taking a picture of his household?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: _Spacing.md),
                        Wrap(
                          spacing: 20,
                          children: [
                            _buildRadioOption(
                              value: true,
                              groupValue: _consentForPicture,
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  _consentForPicture = value;
                                  _consentReasonController.clear();
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: false,
                              groupValue: _consentForPicture,
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  _consentForPicture = value;
                                });
                              },
                            ),
                          ],
                        ),

                        // Reason field for denied consent
                        if (_consentForPicture == false) ...[
                          const SizedBox(height: _Spacing.lg),
                          _buildTextField(
                            label:
                                'Please specify the reason for not consenting:',
                            controller: _consentReasonController,
                            hintText: 'Enter reason...',
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Show image sections only if consent was given
                  if (_consentForPicture == true) ...[
                    // Question 7: Sensitization Session Picture
                    _buildImageSection(
                      title:
                          '7. Please take a picture of the **sensitization being done** with the your back facing the camera and the faces of the household showing',
                      note:
                          'Note: Please take a picture of the household with your face showing as well as the household members',
                      image: _sensitizationImage,
                      onTakePicture: () => _takePicture(false),
                      buttonText: _sensitizationImage == null
                          ? 'Take Picture of Session'
                          : 'Retake Session Picture',
                    ),

                    // Question 8: Household with User Picture
                    _buildImageSection(
                      title:
                          '8. Please take a picture of the household with your face showing',
                      note:
                          'Note: Ensure your face is clearly visible along with the household members',
                      image: _householdWithUserImage,
                      onTakePicture: () => _takePicture(true),
                      buttonText: _householdWithUserImage == null
                          ? 'Take Picture with Household'
                          : 'Retake Household Picture',
                    ),
                  ],

                  // Question 9: Parents' Reaction
                  _buildQuestionCard(
                    child: _buildTextField(
                      label:
                          '9. What are your observations regarding the reaction from the parents on the sensitization provided?',
                      controller: _reactionController,
                      hintText:
                          'Describe the parents\' reactions, concerns, or feedback...',
                      maxLines: 4,
                    ),
                  ),

                  const SizedBox(height: 20), // Extra space before the bottom buttons
                ],
              ),
            ),
          ),
          
        
        ],
      ),
    );
  }
}
