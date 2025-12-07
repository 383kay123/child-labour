import 'dart:io';
import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/db/db.dart';
import 'package:human_rights_monitor/controller/db/daos/sensitization_questions_dao.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/end/end_of_collection_page.dart';
import 'package:image_picker/image_picker.dart';

class SensitizationQuestionsPage extends StatefulWidget {
  final int coverPageId;

  const SensitizationQuestionsPage({
    Key? key,
    required this.coverPageId,
  }) : super(key: key);

  @override
  SensitizationQuestionsPageState createState() => SensitizationQuestionsPageState();
}

class SensitizationQuestionsPageState extends State<SensitizationQuestionsPage> {
  // ==================== FORM STATE ====================
  final TextEditingController _femaleAdultsController = TextEditingController();
  final TextEditingController _maleAdultsController = TextEditingController();
  final TextEditingController _consentReasonController = TextEditingController();
  final TextEditingController _reactionController = TextEditingController();

  bool? _hasSensitizedHousehold;
  bool? _hasSensitizedOnProtection;
  bool? _hasSensitizedOnSafeLabour;
  bool? _consentForPicture;

  File? _sensitizationImage;
  File? _householdWithUserImage;
  final ImagePicker _picker = ImagePicker();

  // ==================== TRACKING STATE ====================
  bool _isSaving = false;
  bool _isLoading = true;

  // ==================== INITIALIZATION ====================
  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // ==================== DATA LOADING ====================
  Future<void> _loadSavedData() async {
    try {
      final questionsDao = SensitizationQuestionsDao(dbHelper: LocalDBHelper.instance);
      final existingData = await questionsDao.getByCoverPageId(widget.coverPageId);

      if (existingData.isNotEmpty) {
        final data = existingData.first;

        setState(() {
          _hasSensitizedHousehold = data.hasSensitizedHousehold;
          _hasSensitizedOnProtection = data.hasSensitizedOnProtection;
          _hasSensitizedOnSafeLabour = data.hasSensitizedOnSafeLabour;
          _consentForPicture = data.consentForPicture;

          _femaleAdultsController.text = data.femaleAdultsCount?.isNotEmpty == true
              ? data.femaleAdultsCount!
              : '0';

          _maleAdultsController.text = data.maleAdultsCount?.isNotEmpty == true
              ? data.maleAdultsCount!
              : '0';

          _consentReasonController.text = data.consentReason ?? '';
          _reactionController.text = data.parentsReaction ?? '';

          // Try to load images from paths
          if (data.sensitizationImagePath != null && data.sensitizationImagePath!.isNotEmpty) {
            final file = File(data.sensitizationImagePath!);
            if (file.existsSync()) {
              _sensitizationImage = file;
            }
          }

          if (data.householdWithUserImagePath != null && data.householdWithUserImagePath!.isNotEmpty) {
            final file = File(data.householdWithUserImagePath!);
            if (file.existsSync()) {
              _householdWithUserImage = file;
            }
          }
        });
      } else {
        // Set default values
        setState(() {
          _femaleAdultsController.text = '0';
          _maleAdultsController.text = '0';
        });
      }
    } catch (e) {
      debugPrint('Error loading sensitization questions: $e');
      _showSnackBar('Failed to load data. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==================== FORM VALIDATION ====================
  bool _validateForm() {
    // Check required boolean fields
    if (_hasSensitizedHousehold == null ||
        _hasSensitizedOnProtection == null ||
        _hasSensitizedOnSafeLabour == null ||
        _consentForPicture == null) {
      _showSnackBar('Please answer all questions');
      return false;
    }

    // Validate number fields
    if (_femaleAdultsController.text.trim().isEmpty ||
        _maleAdultsController.text.trim().isEmpty) {
      _showSnackBar('Please enter the number of adults present');
      return false;
    }

    final femaleCount = int.tryParse(_femaleAdultsController.text.trim());
    final maleCount = int.tryParse(_maleAdultsController.text.trim());

    if (femaleCount == null || femaleCount < 0 || maleCount == null || maleCount < 0) {
      _showSnackBar('Please enter valid numbers for adults');
      return false;
    }

    // Validate consent reason if consent denied
    if (_consentForPicture == false && _consentReasonController.text.trim().isEmpty) {
      _showSnackBar('Please provide a reason for not giving consent');
      return false;
    }

    // Validate images if consent given
    if (_consentForPicture == true) {
      if (_sensitizationImage == null) {
        _showSnackBar('Please take a sensitization session picture');
        return false;
      }

      if (_householdWithUserImage == null) {
        _showSnackBar('Please take a picture with the household');
        return false;
      }
    }

    // Validate reaction field
    if (_reactionController.text.trim().isEmpty) {
      _showSnackBar('Please provide observations about parents\' reactions');
      return false;
    }

    return true;
  }

  // ==================== DATA SAVING ====================
  Future<void> _saveData() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Validate form
      if (!_validateForm()) {
        return;
      }

      final questionsDao = SensitizationQuestionsDao(dbHelper: LocalDBHelper.instance);
      final now = DateTime.now().toUtc();

      // Check if record exists
      final existingRecords = await questionsDao.getByCoverPageId(widget.coverPageId);
      final existingRecord = existingRecords.isNotEmpty ? existingRecords.first : null;

      // Prepare data for saving
      final model = SensitizationQuestionsData(
        id: existingRecord?.id,
        coverPageId: widget.coverPageId,
        hasSensitizedHousehold: _hasSensitizedHousehold ?? false,
        hasSensitizedOnProtection: _hasSensitizedOnProtection ?? false,
        hasSensitizedOnSafeLabour: _hasSensitizedOnSafeLabour ?? false,
        femaleAdultsCount: _femaleAdultsController.text.trim(),
        maleAdultsCount: _maleAdultsController.text.trim(),
        consentForPicture: _consentForPicture ?? false,
        consentReason: _consentForPicture == true ? '' : _consentReasonController.text.trim(),
        sensitizationImagePath: _sensitizationImage?.path,
        householdWithUserImagePath: _householdWithUserImage?.path,
        parentsReaction: _reactionController.text.trim(),
        submittedAt: existingRecord?.submittedAt ?? now,
        createdAt: existingRecord?.createdAt ?? now,
        updatedAt: now,
        isSynced: existingRecord?.isSynced ?? false,
        syncStatus: existingRecord?.syncStatus ?? 0,
      );

      // Save to database
      int result;
      if (existingRecord == null) {
        result = await questionsDao.insert(model, widget.coverPageId);
      } else {
        result = await questionsDao.update(model, widget.coverPageId);
      }

      if (result > 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return EndOfCollectionPage(
            coverPageId: widget.coverPageId,
          );
        }));
        _showSnackBar('Sensitization questions saved successfully!', backgroundColor: Colors.green);
      } else {
        _showSnackBar('Failed to save data. Please try again.');
      }

    } catch (e) {
      debugPrint('Error saving sensitization questions: $e');
      _showSnackBar('Failed to save sensitization questions. Please try again.');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ==================== IMAGE HANDLING ====================
  Future<void> _takePicture(bool isHouseholdWithUser) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (photo != null && mounted) {
        setState(() {
          if (isHouseholdWithUser) {
            _householdWithUserImage = File(photo.path);
          } else {
            _sensitizationImage = File(photo.path);
          }
        });
      }
    } catch (e) {
      _showSnackBar('Failed to capture image. Please try again.');
    }
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

  Widget _buildRadioOption({
    required bool value,
    required bool? groupValue,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return RadioListTile<bool>(
      title: Text(
        label,
        style: const TextStyle(fontSize: 14),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
                  Icons.photo_camera,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
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
              icon: const Icon(Icons.camera_alt, size: 20),
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
              : const Text(
            'Continue',
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
        title: const Text('Sensitization Questions'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question 1: Sensitization Status
                  _buildQuestionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1. Have you sensitized the household members?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 20,
                          children: [
                            _buildRadioOption(
                              value: true,
                              groupValue: _hasSensitizedHousehold,
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  _hasSensitizedHousehold = value;
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: false,
                              groupValue: _hasSensitizedHousehold,
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  _hasSensitizedHousehold = value;
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
                        const Text(
                          '2. Have you sensitized the household members on Child Protection?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 20,
                          children: [
                            _buildRadioOption(
                              value: true,
                              groupValue: _hasSensitizedOnProtection,
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  _hasSensitizedOnProtection = value;
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: false,
                              groupValue: _hasSensitizedOnProtection,
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  _hasSensitizedOnProtection = value;
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
                        const Text(
                          '3. Have you sensitized the household members on Safe Labour Practices?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 20,
                          children: [
                            _buildRadioOption(
                              value: true,
                              groupValue: _hasSensitizedOnSafeLabour,
                              label: 'Yes',
                              onChanged: (value) {
                                setState(() {
                                  _hasSensitizedOnSafeLabour = value;
                                });
                              },
                            ),
                            _buildRadioOption(
                              value: false,
                              groupValue: _hasSensitizedOnSafeLabour,
                              label: 'No',
                              onChanged: (value) {
                                setState(() {
                                  _hasSensitizedOnSafeLabour = value;
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
                    ),
                  ),

                  // Question 5: Male Adults Count
                  _buildQuestionCard(
                    child: _buildTextField(
                      label: '5. How many male adults were present during the sensitization?',
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
                        const Text(
                          '6. Does the producer consent to taking a picture of his household?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Please specify the reason for not consenting:',
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
    _femaleAdultsController.dispose();
    _maleAdultsController.dispose();
    _consentReasonController.dispose();
    _reactionController.dispose();
    super.dispose();
  }
}