import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surveyflow/view/theme/app_theme.dart';

import 'end_of_collection_page.dart';

class SensitizationQuestionsPage extends StatefulWidget {
  const SensitizationQuestionsPage({Key? key}) : super(key: key);

  @override
  _SensitizationQuestionsPageState createState() =>
      _SensitizationQuestionsPageState();
}

class _SensitizationQuestionsPageState
    extends State<SensitizationQuestionsPage> {
  final _formKey = GlobalKey<FormState>();
  bool? hasSensitizedHousehold;
  bool? hasSensitizedOnProtection;
  bool? hasSensitizedOnSafeLabour;
  final TextEditingController _femaleAdultsController = TextEditingController();
  final TextEditingController _maleAdultsController = TextEditingController();
  bool? _consentForPicture;
  final TextEditingController _consentReasonController =
      TextEditingController();
  File? _sensitizationImage;
  File? _householdWithUserImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _reactionController = TextEditingController();

  @override
  Future<void> _takePicture(bool isHouseholdWithUser) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          if (isHouseholdWithUser) {
            _householdWithUserImage = File(photo.path);
          } else {
            _sensitizationImage = File(photo.path);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to capture image. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _femaleAdultsController.dispose();
    _maleAdultsController.dispose();
    _consentReasonController.dispose();
    _reactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sensitization Questions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Question 1
              Text(
                '1. Have you sensitized the household members on Good Parenting?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(
                        'Yes',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: true,
                      groupValue: hasSensitizedHousehold,
                      onChanged: (bool? value) {
                        setState(() {
                          hasSensitizedHousehold = value;
                        });
                      },
                      activeColor: const Color(0xFF1A5F7A),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(
                        'No',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: false,
                      groupValue: hasSensitizedHousehold,
                      onChanged: (bool? value) {
                        setState(() {
                          hasSensitizedHousehold = value;
                        });
                      },
                      activeColor: const Color(0xFF1A5F7A),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Question 2
              Text(
                '2. Have you sensitized the household members on Child Protection?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(
                        'Yes',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: true,
                      groupValue: hasSensitizedOnProtection,
                      onChanged: (bool? value) {
                        setState(() {
                          hasSensitizedOnProtection = value;
                        });
                      },
                      activeColor: const Color(0xFF1A5F7A),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(
                        'No',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: false,
                      groupValue: hasSensitizedOnProtection,
                      onChanged: (bool? value) {
                        setState(() {
                          hasSensitizedOnProtection = value;
                        });
                      },
                      activeColor: const Color(0xFF1A5F7A),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Question 3
              Text(
                '3. Have you sensitized the household members on Safe Labour Practices?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(
                        'Yes',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: true,
                      groupValue: hasSensitizedOnSafeLabour,
                      onChanged: (bool? value) {
                        setState(() {
                          hasSensitizedOnSafeLabour = value;
                        });
                      },
                      activeColor: const Color(0xFF1A5F7A),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(
                        'No',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: false,
                      groupValue: hasSensitizedOnSafeLabour,
                      onChanged: (bool? value) {
                        setState(() {
                          hasSensitizedOnSafeLabour = value;
                        });
                      },
                      activeColor: const Color(0xFF1A5F7A),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Question 4 - Number of Female Adults
              Text(
                '4. How many female adults were present during the sensitization?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _femaleAdultsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter number of female adults',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Question 5 - Number of Male Adults
              Text(
                '5. How many male adults were present during the sensitization?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _maleAdultsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter number of male adults',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Question 6 - Picture Consent
              Text(
                '6. Does the producer consent to taking a picture of his household?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(
                        'Yes',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: true,
                      groupValue: _consentForPicture,
                      onChanged: (bool? value) {
                        setState(() {
                          _consentForPicture = value;
                          _consentReasonController.clear();
                        });
                      },
                      activeColor: const Color(0xFF1A5F7A),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(
                        'No',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: false,
                      groupValue: _consentForPicture,
                      onChanged: (bool? value) {
                        setState(() {
                          _consentForPicture = value;
                        });
                      },
                      activeColor: const Color(0xFF1A5F7A),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              // Show reason field only if consent is denied
              if (_consentForPicture == false) ...[
                const SizedBox(height: 16),
                Text(
                  'Please specify the reason for not consenting:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _consentReasonController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Enter reason...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (_consentForPicture == false &&
                        (value == null || value.isEmpty)) {
                      return 'Please specify the reason for not consenting';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 16),

              // Sensitization Picture Section
              Text(
                '7. Please take a picture of the sensitization session',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Note: Please take a picture of the household with your face showing as well as the household members',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 12),

              // Image Preview or Placeholder
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: _sensitizationImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.photo_camera,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No image captured',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _sensitizationImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
              ),
              const SizedBox(height: 12),

              // Capture/Retake Button for Sensitization Session
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _takePicture(false),
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: Text(
                    _sensitizationImage == null
                        ? 'Take Picture of Session'
                        : 'Retake Session Picture',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
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

              const SizedBox(height: 24),

              // Household with User Picture Section
              Text(
                '8. Please take a picture of the household with your face showing',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Note: Ensure your face is clearly visible along with the household members',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 12),

              // Household with User Image Preview or Placeholder
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: _householdWithUserImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.photo_camera,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No image captured',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _householdWithUserImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
              ),
              const SizedBox(height: 12),

              // Capture/Retake Button for Household with User
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _takePicture(true),
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: Text(
                    _householdWithUserImage == null
                        ? 'Take Picture with Household'
                        : 'Retake Household Picture',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
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

              const SizedBox(height: 24),

              // Question 9 - Parents' Reaction
              Text(
                '9. What are your observations regarding the reaction from the parents on the sensitization provided?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reactionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Describe the parents\' reactions, concerns, or feedback...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide your observations';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (hasSensitizedHousehold == null ||
                        hasSensitizedOnProtection == null ||
                        hasSensitizedOnSafeLabour == null ||
                        _femaleAdultsController.text.isEmpty ||
                        _maleAdultsController.text.isEmpty ||
                        _consentForPicture == null ||
                        (_consentForPicture == false &&
                            _consentReasonController.text.isEmpty) ||
                        _sensitizationImage == null ||
                        _householdWithUserImage == null ||
                        _reactionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please answer the question'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      // Handle form submission
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EndOfCollectionPage(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
