import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:human_rights_monitor/controller/db/daos/cover_page_dao.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/view/pages/house-hold/components/survey_data_viewer.dart';
import 'package:human_rights_monitor/view/screen_wrapper/screen_wrapper.dart';
import 'package:image_picker/image_picker.dart';

class EndOfCollectionPage extends StatefulWidget {
  final int coverPageId;

  const EndOfCollectionPage({
    Key? key,
    required this.coverPageId,
  }) : super(key: key);

  @override
  EndOfCollectionPageState createState() => EndOfCollectionPageState();
}

class EndOfCollectionPageState extends State<EndOfCollectionPage> {
  // ==================== FORM STATE ====================
  final TextEditingController _remarksController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _respondentImage;
  File? _producerSignatureImage;
  String? _gpsCoordinates;
  bool _isLoadingGps = false;
  TimeOfDay? _endTime;
  bool _isSaving = false;

  // ==================== INITIALIZATION ====================
  @override
  void initState() {
    super.initState();
    _initializeEndTime();
  }

  void _initializeEndTime() {
    final now = TimeOfDay.now();
    setState(() {
      _endTime = now;
    });
  }

  // ==================== GPS LOCATION ====================
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingGps = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled. Please enable them.');
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied.');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final coordinates = '${position.latitude}, ${position.longitude}';
      setState(() {
        _gpsCoordinates = coordinates;
      });

      _showSnackBar('Location captured successfully!',
          backgroundColor: Colors.green);
    } catch (e) {
      _showSnackBar('Error getting location: ${e.toString()}');
    } finally {
      setState(() => _isLoadingGps = false);
    }
  }

  // ==================== IMAGE CAPTURE ====================
  Future<void> _takePicture({bool isSignature = false}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 70,
      );

      if (photo != null && mounted) {
        final file = File(photo.path);
        if (await file.exists()) {
          setState(() {
            if (isSignature) {
              _producerSignatureImage = file;
            } else {
              _respondentImage = file;
            }
          });

          _showSnackBar(
            '${isSignature ? 'Signature' : 'Image'} captured successfully',
            backgroundColor: Colors.green,
          );
        }
      }
    } catch (e) {
      _showSnackBar('Failed to capture image. Please try again.');
    }
  }

  // ==================== FORM VALIDATION ====================
  bool _validateForm() {
    if (_respondentImage == null) {
      _showSnackBar('Please take a picture of the respondent');
      return false;
    }

    if (_producerSignatureImage == null) {
      _showSnackBar('Please capture the producer\'s signature');
      return false;
    }

    if (_gpsCoordinates == null) {
      _showSnackBar('Please capture GPS coordinates');
      return false;
    }

    if (_endTime == null) {
      _showSnackBar('Please set the end time');
      return false;
    }

    return true;
  }

  // ==================== DATA SAVING ====================

  /// Submits the form and navigates to the completion page
  /// Logs all submitted data before navigation
  /// If the form is not complete, logs a warning and shows an error message to the user
  Future<void> _saveData() async {
    developer.log('Form submission initiated');

    try {
      // // Log all submitted data
      // developer.log('Form submission data:');
      // developer.log(
      //     '- Respondent image: ${_respondentImage?.path ?? 'Not provided'}',
      //     );
      // developer.log(
      //     '- Signature image: ${_producerSignatureImage?.path ?? 'Not provided'}',
      //     );
      // developer.log('- GPS Coordinates: $_gpsCoordinates');
      // developer.log('- End Time: ${_endTime?.format(context) ?? 'Not set'}',
      //     );
      // developer.log(
      //     '- Additional Remarks: ${_remarksController.text.isNotEmpty ? _remarksController.text : 'None'}',
      //     );

      final db = HouseholdDBHelper.instance;

      // Update the survey status to submitted (1)
      final coverPageDao = CoverPageDao(dbHelper: db);
      final latestSurvey = await coverPageDao.getLatestCoverPage();

      if (latestSurvey != null) {
        // Update the cover page with synced status and current timestamp
        await coverPageDao.update(latestSurvey.copyWith(
          isSynced: 1, // Mark as synced
          updatedAt: DateTime.now(),
        ));

        debugPrint('✅ Survey marked as synced in local database');
      }
      developer.log('Updated survey status to submitted');

      // Navigate to completion page
      if (mounted) {
        developer.log('Navigating to SurveyCompletionPage');
        if (mounted) {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return ScreenWrapper();
          }), (route) => false);
        }
      }
    } catch (e) {
      developer.log('Error updating survey status: $e', level: 1000); // ERROR
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating survey status. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToCompletion() {
    // Navigate to completion screen or back to main
    // Navigator.of(context).pushReplacement(...)
  }

  // ==================== UI COMPONENTS ====================
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildQuestionCard({required Widget child}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
    IconData icon = Icons.photo_camera,
  }) {
    return _buildQuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),

          // Image Preview
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No image captured',
                        style: TextStyle(color: Colors.grey),
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
          const SizedBox(height: 8),

          // Capture Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTakePicture,
              icon: Icon(icon, size: 20),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
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
  }) {
    return _buildQuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: value == null ? Colors.grey[50] : Colors.green[50],
              ),
              child: isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Getting location...'),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          icon,
                          color: value == null ? Colors.grey : Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            value ?? placeholder,
                            style: TextStyle(
                              color: value == null
                                  ? Colors.grey
                                  : Colors.green[800],
                              fontWeight: value == null
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (showCopyButton && value != null)
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: value));
                              _showSnackBar('Copied to clipboard',
                                  backgroundColor: Colors.green);
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

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  'COMPLETE SURVEY'.toTitleCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // ==================== MAIN BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('End of Collection'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                  ),

                  // End Time
                  _buildTapToCaptureSection(
                    title: '3. End Time of Survey',
                    placeholder: 'Tap to set current time',
                    value: _endTime?.format(context),
                    onTap: _initializeEndTime,
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
                  ),

                  // Remarks Section
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '5. Additional Remarks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _remarksController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Enter any additional remarks or observations...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ==================== CLEANUP ====================
  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }
}
