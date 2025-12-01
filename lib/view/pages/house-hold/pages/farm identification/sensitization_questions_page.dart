import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/daos/sensitization_questions_dao.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
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
  final int? coverPageId;

  const SensitizationQuestionsPage({
    Key? key,
    required this.onPrevious,
    required this.onNext,
    this.validateOnly = false,
    this.coverPageId,
  }) : super(key: key);

  @override
  SensitizationQuestionsPageState createState() =>
      SensitizationQuestionsPageState();
}

class SensitizationQuestionsPageState extends State<SensitizationQuestionsPage> {
  static const String _logTag = 'SensitizationQuestionsPage';
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _femaleAdultsController = TextEditingController();
  final TextEditingController _maleAdultsController = TextEditingController();
  final TextEditingController _consentReasonController = TextEditingController();
  final TextEditingController _reactionController = TextEditingController();
  
  // Form state variables - INITIALIZE WITH NULL to track unanswered state
  bool? hasSensitizedHousehold;
  bool? hasSensitizedOnProtection;
  bool? hasSensitizedOnSafeLabour;
  bool? _consentForPicture;
  
  // Image handling
  File? _sensitizationImage;
  File? _householdWithUserImage;
  final ImagePicker _picker = ImagePicker();
  
  bool _isDisposed = false;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSensitizationQuestionsData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we're being removed from the navigation stack
    if (ModalRoute.of(context)?.isCurrent == false &&
        ModalRoute.of(context)?.isActive == false) {
      _saveBeforeDispose();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _femaleAdultsController.dispose();
    _maleAdultsController.dispose();
    _consentReasonController.dispose();
    _reactionController.dispose();
    super.dispose();
  }

  /// Loads the sensitization questions data from the database
  Future<void> _loadSensitizationQuestionsData() async {
    if (widget.coverPageId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      developer.log('🔍 Loading sensitization questions data for coverPageId: ${widget.coverPageId}', 
          name: _logTag);
      
      final questionsDao = SensitizationQuestionsDao(dbHelper: LocalDBHelper.instance);
      
      // Add a small delay to ensure the UI has time to render the loading state
      await Future.delayed(const Duration(milliseconds: 100));
      
      final existingData = await questionsDao.getByCoverPageId(widget.coverPageId!);
      
      if (!mounted) return;
      
      if (existingData.isNotEmpty) {
        final data = existingData.first;
        developer.log('📋 Loaded sensitization questions: ${data.toMap()}', name: _logTag);
        
        // Load images if paths exist and are accessible
        File? sensitizationImage;
        File? householdWithUserImage;
        
        if (data.sensitizationImagePath != null && data.sensitizationImagePath!.isNotEmpty) {
          try {
            final file = File(data.sensitizationImagePath!);
            if (await file.exists()) {
              sensitizationImage = file;
            } else {
              developer.log('⚠️ Sensitization image file not found at path: ${data.sensitizationImagePath}', 
                  name: _logTag);
            }
          } catch (e) {
            developer.log('❌ Error loading sensitization image: $e', name: _logTag);
          }
        }
        
        if (data.householdWithUserImagePath != null && data.householdWithUserImagePath!.isNotEmpty) {
          try {
            final file = File(data.householdWithUserImagePath!);
            if (await file.exists()) {
              householdWithUserImage = file;
            } else {
              developer.log('⚠️ Household with user image file not found at path: ${data.householdWithUserImagePath}', 
                  name: _logTag);
            }
          } catch (e) {
            developer.log('❌ Error loading household with user image: $e', name: _logTag);
          }
        }
        
        if (!mounted) return;
        setState(() {
          try {
            // Set boolean values with null checks
            hasSensitizedHousehold = data.hasSensitizedHousehold;
            hasSensitizedOnProtection = data.hasSensitizedOnProtection;
            hasSensitizedOnSafeLabour = data.hasSensitizedOnSafeLabour;
            _consentForPicture = data.consentForPicture;
            
            // Set text field values with null checks and default values
            _femaleAdultsController.text = data.femaleAdultsCount?.isNotEmpty == true 
                ? data.femaleAdultsCount! 
                : '0';
                
            _maleAdultsController.text = data.maleAdultsCount?.isNotEmpty == true 
                ? data.maleAdultsCount! 
                : '0';
                
            _consentReasonController.text = data.consentReason ?? '';
            _reactionController.text = data.parentsReaction ?? '';
            
            // Set the images after they've been loaded
            _sensitizationImage = sensitizationImage;
            _householdWithUserImage = householdWithUserImage;
            
            developer.log('✅ Successfully loaded and set sensitization questions data', 
                name: _logTag);
                
          } catch (e, stackTrace) {
            developer.log('❌ Error in setState while loading data: $e', 
                name: _logTag, error: e, stackTrace: stackTrace);
          }
        });
      } else {
        developer.log('ℹ️ No existing sensitization questions data found for coverPageId: ${widget.coverPageId}', 
            name: _logTag);
            
        // Initialize default values if no data exists
        if (mounted) {
          setState(() {
            _femaleAdultsController.text = '0';
            _maleAdultsController.text = '0';
            _consentReasonController.clear();
            _reactionController.clear();
          });
        }
      }
    } catch (e, stackTrace) {
      developer.log('❌ Error loading sensitization questions: $e', 
          name: _logTag, error: e, stackTrace: stackTrace);
          
      if (mounted) {
        _showErrorSnackBar('Failed to load sensitization data. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Enhanced validation with better error tracking
  bool validateForm({bool silent = false}) {
    final errors = <String>[];
    
    // Track exactly which fields are missing
    if (hasSensitizedHousehold == null) {
      errors.add('Please indicate if you have sensitized the household members');
    }
    
    if (hasSensitizedOnProtection == null) {
      errors.add('Please indicate if you have sensitized on protection');
    }
    
    if (hasSensitizedOnSafeLabour == null) {
      errors.add('Please indicate if you have sensitized on safe labor');
    }
    
    if (_femaleAdultsController.text.trim().isEmpty) {
      errors.add('Please enter the number of female adults');
    } else {
      final femaleCount = int.tryParse(_femaleAdultsController.text.trim());
      if (femaleCount == null || femaleCount < 0) {
        errors.add('Please enter a valid number for female adults');
      }
    }
    
    if (_maleAdultsController.text.trim().isEmpty) {
      errors.add('Please enter the number of male adults');
    } else {
      final maleCount = int.tryParse(_maleAdultsController.text.trim());
      if (maleCount == null || maleCount < 0) {
        errors.add('Please enter a valid number for male adults');
      }
    }
    
    if (_consentForPicture == null) {
      errors.add('Please indicate if consent for picture was given');
    } else if (_consentForPicture == false && _consentReasonController.text.trim().isEmpty) {
      errors.add('Please provide a reason for not giving consent');
    }
    
    // Image validation only if consent was given
    if (_consentForPicture == true) {
      if (_sensitizationImage == null) {
        errors.add('Please take a sensitization session picture');
      }
      
      if (_householdWithUserImage == null) {
        errors.add('Please take a picture with the household');
      }
    }
    
    if (_reactionController.text.trim().isEmpty) {
      errors.add('Please provide your observations about parents\' reactions');
    }
    
    // Show first error if not in silent mode
    if (!silent && errors.isNotEmpty) {
      _showErrorSnackBar(errors.first);
      
      // Also log all errors for debugging
      debugPrint('🔍 Validation errors: $errors');
    }
    
    return errors.isEmpty;
  }

  /// Enhanced save method with better error handling and data validation
  Future<bool> saveData([int? coverPageId]) async {
    if (_isDisposed || _isSaving) {
      debugPrint('⚠️ Save operation prevented - already saving or disposed');
      return false;
    }
    
    _isSaving = true;
    
    try {
      final effectiveCoverPageId = coverPageId ?? widget.coverPageId;
      
      if (effectiveCoverPageId == null) {
        _showErrorSnackBar('Error: Missing cover page ID');
        return false;
      }

      // Validate form before saving
      if (!validateForm(silent: widget.validateOnly)) {
        return false;
      }

      final questionsDao = SensitizationQuestionsDao(dbHelper: LocalDBHelper.instance);
      final now = DateTime.now().toUtc();
      
      // Check if record exists
      final existingRecords = await questionsDao.getByCoverPageId(effectiveCoverPageId);
      final existingRecord = existingRecords.isNotEmpty ? existingRecords.first : null;
      
      // Prepare data for saving
      final femaleCount = _femaleAdultsController.text.trim().isEmpty ? '0' : _femaleAdultsController.text.trim();
      final maleCount = _maleAdultsController.text.trim().isEmpty ? '0' : _maleAdultsController.text.trim();
      final consentReason = _consentForPicture == true ? '' : _consentReasonController.text.trim();
      
      // Create the model with all required fields
      final model = SensitizationQuestionsData(
        id: existingRecord?.id,
        coverPageId: effectiveCoverPageId,
        hasSensitizedHousehold: hasSensitizedHousehold ?? false,
        hasSensitizedOnProtection: hasSensitizedOnProtection ?? false,
        hasSensitizedOnSafeLabour: hasSensitizedOnSafeLabour ?? false,
        femaleAdultsCount: femaleCount,
        maleAdultsCount: maleCount,
        consentForPicture: _consentForPicture ?? false,
        consentReason: consentReason,
        sensitizationImagePath: _sensitizationImage?.path,
        householdWithUserImagePath: _householdWithUserImage?.path,
        parentsReaction: _reactionController.text.trim(),
        submittedAt: existingRecord?.submittedAt ?? now,
        createdAt: existingRecord?.createdAt ?? now,
        updatedAt: now,
        isSynced: existingRecord?.isSynced ?? false,
        syncStatus: existingRecord?.syncStatus ?? 0,
      );

      debugPrint('💾 Saving sensitization questions: ${model.toMap()}');

      // Save to database
      int result;
      if (existingRecord == null) {
        result = await questionsDao.insert(model, effectiveCoverPageId);
        debugPrint('✅ Inserted new sensitization questions with ID: $result');
      } else {
        result = await questionsDao.update(model, effectiveCoverPageId);
        debugPrint('✅ Updated sensitization questions, rows affected: $result');
      }

      // Verify the data was saved
      if (result > 0) {
        final savedRecords = await questionsDao.getByCoverPageId(effectiveCoverPageId);
        if (savedRecords.isEmpty) {
          debugPrint('⚠️ Warning: Failed to verify saved data - no records found after save');
        } else {
          debugPrint('✅ Verified ${savedRecords.length} records in database');
        }
      }

      if (!widget.validateOnly && result > 0) {
        _showSuccessSnackBar('Sensitization questions saved successfully!');
      } else if (!widget.validateOnly) {
        _showErrorSnackBar('Failed to save data. Please try again.');
        return false;
      }
      
      return result > 0;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving sensitization questions: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (!widget.validateOnly) {
        _showErrorSnackBar('Failed to save sensitization questions. Please try again.');
      }
      return false;
    } finally {
      _isSaving = false;
    }
  }

  /// Shows a success message to the user
  void _showSuccessSnackBar(String message) {
    if (!mounted || _isDisposed) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
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

  Future<void> _saveBeforeDispose() async {
    if (_isSaving || _isDisposed) return;
    _isSaving = true;
    
    try {
      developer.log('🔄 Attempting to save before dispose...', name: _logTag);
      await saveData();
      developer.log('✅ Successfully saved before dispose', name: _logTag);
    } catch (e, stackTrace) {
      developer.log('❌ Error saving before dispose: $e', 
          name: _logTag, error: e, stackTrace: stackTrace);
    } finally {
      _isSaving = false;
    }
  }

  /// Builds a consistent card widget for form questions
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
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
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
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
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
                        color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
                      ),
                      const SizedBox(height: _Spacing.sm),
                      Text(
                        'No image captured',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
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

  

  Future<void> _handleSave() async {
    final success = await saveData();
    if (success && mounted) {
      widget.onNext();
    }
  }

  String? _validateNumberField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final number = int.tryParse(value);
    if (number == null || number < 0) {
      return 'Please enter a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensitization Questions'),
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppTheme.primaryColor,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
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
                            label: '4. How many female adults were present during the sensitization?',
                            controller: _femaleAdultsController,
                            hintText: 'Enter number of female adults',
                            keyboardType: TextInputType.number,
                            validator: _validateNumberField,
                          ),
                        ),

                        // Question 5: Male Adults Count
                        _buildQuestionCard(
                          child: _buildTextField(
                            label: '5. How many male adults were present during the sensitization?',
                            controller: _maleAdultsController,
                            hintText: 'Enter number of male adults',
                            keyboardType: TextInputType.number,
                            validator: _validateNumberField,
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
                                  label: 'Please specify the reason for not consenting:',
                                  controller: _consentReasonController,
                                  hintText: 'Enter reason...',
                                  maxLines: 2,
                                  validator: (value) {
                                    if (_consentForPicture == false &&
                                        (value == null || value.trim().isEmpty)) {
                                      return 'Please provide a reason for not giving consent';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Show image sections only if consent was given
                        if (_consentForPicture == true) ...[
                          // Question 7: Sensitization Session Picture
                          _buildImageSection(
                            title: '7. Please take a picture of the sensitization being done with your back facing the camera and the faces of the household showing',
                            note: 'Note: Please take a picture of the household with your face showing as well as the household members',
                            image: _sensitizationImage,
                            onTakePicture: () => _takePicture(false),
                            buttonText: _sensitizationImage == null
                                ? 'Take Picture of Session'
                                : 'Retake Session Picture',
                          ),

                          // Question 8: Household with User Picture
                          _buildImageSection(
                            title: '8. Please take a picture of the household with your face showing',
                            note: 'Note: Ensure your face is clearly visible along with the household members',
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
                            label: '9. What are your observations regarding the reaction from the parents on the sensitization provided?',
                            controller: _reactionController,
                            hintText: 'Describe the parents\' reactions, concerns, or feedback...',
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please provide the reaction of parents/guardians';
                              }
                              return null;
                            },
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