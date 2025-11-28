import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:human_rights_monitor/controller/db/daos/cover_page_dao.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';

import '../../../../../controller/db/db.dart';
import '../survey_completion_page.dart';

/// This file contains the end-of-collection form for the farm identification survey.
/// It captures final details including respondent's photo, signature, GPS coordinates, and end time.

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class EndOfCollectionPage extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious;
  final HouseholdDBHelper householdDBHelper;
  
  const EndOfCollectionPage({
    Key? key,
    required this.onComplete,
    required this.onPrevious,
    required this.householdDBHelper,
  }) : super(key: key);

  @override
  State<EndOfCollectionPage> createState() => EndOfCollectionPageState();
}

class EndOfCollectionPageState extends State<EndOfCollectionPage> {
  // Form controllers and state
  final TextEditingController _remarksController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  /// Image file of the respondent
  File? _respondentImage;

  /// Image file of the producer's signature
  File? _producerSignatureImage;

  /// String containing the GPS coordinates in 'latitude, longitude' format
  String? _gpsCoordinates;

  /// Flag to track if GPS location is being fetched
  bool _isLoadingGps = false;

  /// Time when the survey was completed
  TimeOfDay? _endTime;

  /// Tag for logging purposes
  static const String _logTag = 'EndOfCollectionPage';
  
  // Public getters for private fields
  File? get respondentImage => _respondentImage;
  File? get producerSignatureImage => _producerSignatureImage;
  String? get gpsCoordinates => _gpsCoordinates;
  TimeOfDay? get endTime => _endTime;
  TextEditingController get remarksController => _remarksController;

  /// Validates if all required fields are filled
  /// Returns true if all required fields have values, false otherwise
  bool get isFormComplete {
    final isComplete = _respondentImage != null &&
        _producerSignatureImage != null &&
        _gpsCoordinates != null &&
        _endTime != null;

    developer.log('Form validation - Complete: $isComplete',
        name: _logTag,
        level: isComplete ? 800 : 500 // INFO for complete, FINE for incomplete
        );

    if (!isComplete) {
      developer.log('Missing fields:', name: _logTag);
      if (_respondentImage == null)
        developer.log('- Respondent image', name: _logTag);
      if (_producerSignatureImage == null)
        developer.log('- Producer signature', name: _logTag);
      if (_gpsCoordinates == null)
        developer.log('- GPS coordinates', name: _logTag);
      if (_endTime == null) developer.log('- End time', name: _logTag);
    }

    return isComplete;
  }
  
  /// Returns the form data as a map that can be used for saving to the database
  Map<String, dynamic> getData() {
    final now = DateTime.now();
    final time = _endTime ?? TimeOfDay.now();
    final endTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    // Parse latitude and longitude from _gpsCoordinates if available
    double? latitude;
    double? longitude;
    if (_gpsCoordinates != null && _gpsCoordinates!.contains(',')) {
      final parts = _gpsCoordinates!.split(',');
      if (parts.length == 2) {
        latitude = double.tryParse(parts[0].trim());
        longitude = double.tryParse(parts[1].trim());
      }
    }
    
    return {
      'respondentImagePath': _respondentImage?.path,
      'producerSignaturePath': _producerSignatureImage?.path,
      'gpsCoordinates': _gpsCoordinates,
      'latitude': latitude,
      'longitude': longitude,
      'endTime': endTime.toIso8601String(),
      'remarks': _remarksController.text,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
  }

  /// Fetches the current device location using GPS
  /// Updates the _gpsCoordinates state if successful
  /// Shows error messages if location services are disabled or permissions are denied
  Future<void> _getCurrentLocation() async {
    developer.log('Initiating location fetch', name: _logTag);

    setState(() {
      _isLoadingGps = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('Location services are disabled',
            name: _logTag, level: 900); // WARNING
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Location services are disabled. Please enable them.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'SETTINGS',
              textColor: Colors.white,
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final coordinates = '${position.latitude}, ${position.longitude}';
      developer.log('Location fetched successfully: $coordinates',
          name: _logTag, level: 800 // INFO
          );

      setState(() {
        _gpsCoordinates = coordinates;
      });
    } catch (e) {
      developer.log('Error fetching location: $e',
          name: _logTag, level: 1000); // ERROR
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGps = false;
        });
      }
    }
  }

  /// Submits the form and navigates to the completion page
  /// Logs all submitted data before navigation
  /// If the form is not complete, logs a warning and shows an error message to the user
  Future<void> submitForm() async {
    developer.log('Form submission initiated', name: _logTag);

    if (isFormComplete) {
      try {
        // Log all submitted data
        developer.log('Form submission data:', name: _logTag);
        developer.log(
            '- Respondent image: ${_respondentImage?.path ?? 'Not provided'}',
            name: _logTag);
        developer.log(
            '- Signature image: ${_producerSignatureImage?.path ?? 'Not provided'}',
            name: _logTag);
        developer.log('- GPS Coordinates: $_gpsCoordinates', name: _logTag);
        developer.log('- End Time: ${_endTime?.format(context) ?? 'Not set'}',
            name: _logTag);
        developer.log(
            '- Additional Remarks: ${_remarksController.text.isNotEmpty ? _remarksController.text : 'None'}',
            name: _logTag);

        // Update the survey status to submitted (1)
        final coverPageDao = CoverPageDao(dbHelper: widget.householdDBHelper);
        final latestSurvey = await coverPageDao.getLatestCoverPage();

        if (latestSurvey != null) {
          // Update the cover page with synced status and current timestamp
          await coverPageDao.update(latestSurvey.copyWith(
            isSynced: 1, // Mark as synced
            updatedAt: DateTime.now(),
          ));
          
          debugPrint('✅ Survey marked as synced in local database');
        } 
        developer.log('Updated survey status to submitted', name: _logTag);

          // Navigate to completion page
        if (mounted) {
          developer.log('Navigating to SurveyCompletionPage', name: _logTag);
          if (mounted) {
            // Navigate to the start survey page, clearing all previous routes
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/household',  // This should be your start survey route
              (route) => false, // Remove all previous routes from the stack
            );
          }
        }
      } catch (e) {
        developer.log('Error updating survey status: $e',
            name: _logTag, level: 1000); // ERROR
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error updating survey status. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      developer.log(
          'Form submission failed: Not all required fields are filled',
          name: _logTag,
          level: 900 // WARNING
          );

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please complete all required fields before submitting.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    developer.log('Disposing resources', name: _logTag);
    _remarksController.dispose();
    super.dispose();
  }

  /// Captures an image using the device camera
  /// [isSignature] determines if this is for signature capture (different icon and styling)
  Future<void> _takePicture({bool isSignature = false}) async {
    developer.log('Taking picture - isSignature: $isSignature', name: _logTag);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (photo != null) {
        developer.log('Picture captured successfully: ${photo.path}',
            name: _logTag);
        setState(() {
          if (isSignature) {
            _producerSignatureImage = File(photo.path);
          } else {
            _respondentImage = File(photo.path);
          }
        });
      } else {
        developer.log('Picture capture cancelled by user', name: _logTag);
      }
    } catch (e) {
      developer.log('Error capturing picture: $e', name: _logTag, level: 1000);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to capture image. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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

  Widget _buildImageSection({
    required String title,
    required String note,
    required File? image,
    required VoidCallback onTakePicture,
    required String buttonText,
    IconData? icon,
    double imageHeight = 200,
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
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: _Spacing.sm),
          Text(
            note,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: _Spacing.md),

          // Image Preview
          Container(
            width: double.infinity,
            height: imageHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon ?? Icons.photo_camera,
                        size: 48,
                        color: isDark ? Colors.white60 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: _Spacing.sm),
                      Text(
                        'No image captured',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
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
              icon: Icon(icon ?? Icons.camera_alt, size: 20),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
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

  Widget _buildTapToCaptureSection({
    required String title,
    required String placeholder,
    required String? value,
    required VoidCallback onTap,
    required IconData icon,
    bool isLoading = false,
    bool showCopyButton = false,
    String? timestamp,
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
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
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
                          'Getting location...',
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
                              : const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: _Spacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
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
                              if (timestamp != null && value != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: _Spacing.xs),
                                  child: Text(
                                    timestamp,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (showCopyButton && value != null)
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: value));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Coordinates copied to clipboard'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            tooltip: 'Copy to clipboard',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
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
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      // appBar: AppBar(
      //   title: Text(
      //     'End of Collection',
      //     style: theme.textTheme.titleLarge?.copyWith(
      //       color: Colors.white,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   backgroundColor: const Color(0xFF4CAF50),
      //   elevation: 0,
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      // ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Respondent's Photo
                  _buildImageSection(
                    title: '1. Take a picture of the respondent',
                    note: 'Ensure the respondent\'s face is clearly visible',
                    image: _respondentImage,
                    onTakePicture: _takePicture,
                    buttonText: _respondentImage == null
                        ? 'Take Picture of Respondent'
                        : 'Retake Picture',
                    icon: Icons.photo_camera,
                  ),

                  // Producer's Signature
                  _buildImageSection(
                    title: '2. Signature of Respondent',
                    note:
                        'Please take a clear picture of the producer\'s signature',
                    image: _producerSignatureImage,
                    onTakePicture: () => _takePicture(isSignature: true),
                    buttonText: _producerSignatureImage == null
                        ? 'Capture Signature'
                        : 'Retake Signature',
                    icon: Icons.sign_language,
                    imageHeight: 150,
                  ),

                  // End Time
                  _buildTapToCaptureSection(
                    title: '3. End Time of Survey',
                    placeholder: 'Tap to select end time',
                    value: _endTime?.format(context),
                    onTap: () {
                      setState(() {
                        _endTime = TimeOfDay.now();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'End time recorded at ${_endTime!.format(context)}'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icons.access_time,
                  ),

                  // GPS Coordinates
                  _buildTapToCaptureSection(
                    title: '4. End GPS Coordinates',
                    placeholder: 'Tap to capture GPS coordinates',
                    value: _gpsCoordinates,
                    onTap: _getCurrentLocation,
                    icon: Icons.location_on,
                    isLoading: _isLoadingGps,
                    showCopyButton: true,
                    timestamp: _gpsCoordinates != null
                        ? 'Captured at: ${DateTime.now().toString().substring(0, 19)}'
                        : null,
                  ),

                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.all(_Spacing.lg),
      //   decoration: BoxDecoration(
      //     color: Theme.of(context).scaffoldBackgroundColor,
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.1),
      //         blurRadius: 10,
      //         offset: const Offset(0, -2),
      //       ),
      //     ],
      //   ),
      //   child: SafeArea(
      //     child: Padding(
      //       padding: const EdgeInsets.all(16.0),
      //       child: Row(
      //         children: [
      //           // Previous Button
      //           Expanded(
      //             child: OutlinedButton(
      //               onPressed: () {
      //                 developer.log('Previous button pressed', name: _logTag);
      //                 Navigator.pop(context);
      //               },
      //               style: OutlinedButton.styleFrom(
      //                 padding: const EdgeInsets.symmetric(vertical: 16),
      //                 side: BorderSide(color: Colors.green.shade600, width: 2),
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(12),
      //                 ),
      //               ),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   Icon(Icons.arrow_back_ios,
      //                       size: 18, color: Colors.green.shade600),
      //                   const SizedBox(width: 8),
      //                   Text(
      //                     'Previous',
      //                     style: GoogleFonts.inter(
      //                       color: Colors.green.shade600,
      //                       fontWeight: FontWeight.w600,
      //                       fontSize: 16,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //           const SizedBox(width: 16),
      //           // Submit Button
      //           Expanded(
      //             child: ElevatedButton(
      //               onPressed: _isFormComplete ? _submitForm : null,
      //               style: ElevatedButton.styleFrom(
      //                 backgroundColor: _isFormComplete
      //                     ? Colors.green.shade600
      //                     : Colors.grey[400],
      //                 padding: const EdgeInsets.symmetric(vertical: 16),
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(12),
      //                 ),
      //                 elevation: 2,
      //                 shadowColor: Colors.green.shade600.withOpacity(0.3),
      //               ),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   Text(
      //                     'Submit & Finish',
      //                     style: GoogleFonts.inter(
      //                       color: Colors.white,
      //                       fontWeight: FontWeight.w600,
      //                       fontSize: 16,
      //                     ),
      //                   ),
      //                   const SizedBox(width: 8),
      //                   const Icon(Icons.check_circle,
      //                       size: 18, color: Colors.white),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
