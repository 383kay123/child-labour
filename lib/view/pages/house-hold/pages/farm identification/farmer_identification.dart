import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../controller/models/farmeridentification_model.dart';

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class FarmerIdentification1Page extends StatefulWidget {
  final Function(FarmerIdentificationData)?
      onComplete; // Changed from Map<String, dynamic> to FarmerIdentificationData
  final FarmerIdentificationData data;
  final ValueChanged<FarmerIdentificationData> onDataChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const FarmerIdentification1Page({
    Key? key,
    this.onComplete,
    required this.data,
    required this.onDataChanged,
    this.onPrevious,
    this.onNext,
  }) : super(key: key);

  @override
  _FarmerIdentification1PageState createState() =>
      _FarmerIdentification1PageState();
}

class _FarmerIdentification1PageState extends State<FarmerIdentification1Page> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _takeIdPicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        widget.onDataChanged(widget.data.updateIdImagePath(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: ${e.toString()}')),
        );
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate using model methods
      final errors = widget.data.validate();
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(firstError)),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Prepare the data for submission
      widget.data.prepareSubmissionData();
      
      // Pass the data object directly to the callback
      widget.onComplete?.call(widget.data);

      if (widget.onNext != null) {
        widget.onNext!();
      }

      setState(() {
        _isLoading = false;
      });
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
          color: isDark ? Colors.grey[700]! : Colors.grey.shade200,
          width: 1,
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
      onChanged: onChanged,
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
    String? Function(String?)? validator,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: _Spacing.md),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.green.shade600,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[900] : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _Spacing.lg,
              vertical: _Spacing.md,
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final childrenCount = widget.data.childrenCount;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(_Spacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ghana Card Question
                          _buildQuestionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Does the farmer have a Ghana Card?',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: _Spacing.md),
                                Wrap(
                                  spacing: 20,
                                  children: [
                                    _buildRadioOption(
                                      value: 'Yes',
                                      groupValue: widget.data.hasGhanaCard,
                                      label: 'Yes',
                                      onChanged: (value) {
                                        widget.onDataChanged(
                                            widget.data.updateGhanaCard(value));
                                      },
                                    ),
                                    _buildRadioOption(
                                      value: 'No',
                                      groupValue: widget.data.hasGhanaCard,
                                      label: 'No',
                                      onChanged: (value) {
                                        widget.onDataChanged(
                                            widget.data.updateGhanaCard(value));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Alternative ID Options (only show if no Ghana Card)
                          if (widget.data.hasGhanaCard == 'No')
                            _buildQuestionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Which other national id card is available?',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
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
                                          widget.onDataChanged(
                                              widget.data.updateIdType(value));
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'drivers_license',
                                        groupValue: widget.data.selectedIdType,
                                        label: 'Driver\'s License',
                                        onChanged: (value) {
                                          widget.onDataChanged(
                                              widget.data.updateIdType(value));
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'nhis_card',
                                        groupValue: widget.data.selectedIdType,
                                        label: 'NHIS Card',
                                        onChanged: (value) {
                                          widget.onDataChanged(
                                              widget.data.updateIdType(value));
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'passport',
                                        groupValue: widget.data.selectedIdType,
                                        label: 'Passport',
                                        onChanged: (value) {
                                          widget.onDataChanged(
                                              widget.data.updateIdType(value));
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'ssnit',
                                        groupValue: widget.data.selectedIdType,
                                        label: 'SSNIT',
                                        onChanged: (value) {
                                          widget.onDataChanged(
                                              widget.data.updateIdType(value));
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'birth_certificate',
                                        groupValue: widget.data.selectedIdType,
                                        label: 'Birth Certificate',
                                        onChanged: (value) {
                                          widget.onDataChanged(
                                              widget.data.updateIdType(value));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          // CONSENT QUESTION - Show after Ghana Card selection OR alternative ID selection
                          if ((widget.data.hasGhanaCard == 'Yes') ||
                              (widget.data.hasGhanaCard == 'No' &&
                                  widget.data.selectedIdType != null))
                            _buildQuestionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.data.hasGhanaCard == 'Yes'
                                        ? 'Do you consent to us taking a picture of your Ghana Card and recording the card number?'
                                        : 'Do you consent to us taking a picture of your ${widget.data.selectedIdTypeDisplayName} and recording the ID number?',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: _Spacing.md),
                                  Wrap(
                                    spacing: 20,
                                    children: [
                                      _buildRadioOption(
                                        value: 'Yes',
                                        groupValue:
                                            widget.data.idPictureConsent,
                                        label: 'Yes',
                                        onChanged: (value) {
                                          widget.onDataChanged(widget.data
                                              .updatePictureConsent(value));
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'No',
                                        groupValue:
                                            widget.data.idPictureConsent,
                                        label: 'No',
                                        onChanged: (value) {
                                          widget.onDataChanged(widget.data
                                              .updatePictureConsent(value));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          // Ghana Card Number Field (only show if they have Ghana Card AND consent)
                          if (widget.data.hasGhanaCard == 'Yes' &&
                              widget.data.idPictureConsent == 'Yes')
                            _buildQuestionCard(
                              child: _buildTextField(
                                label: 'Ghana Card Number',
                                controller:
                                    widget.data.ghanaCardNumberController,
                                hintText: 'Enter your Ghana Card number',
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) =>
                                    widget.data.validateGhanaCardNumber(),
                                onChanged: (value) {
                                  widget.onDataChanged(
                                      widget.data.updateGhanaCardNumber(value));
                                },
                              ),
                            ),

                          // Alternative ID Number Field (only show if no Ghana Card AND consent)
                          if (widget.data.hasGhanaCard == 'No' &&
                              widget.data.selectedIdType != null &&
                              widget.data.idPictureConsent == 'Yes')
                            _buildQuestionCard(
                              child: _buildTextField(
                                label:
                                    '${widget.data.selectedIdTypeDisplayName} Number',
                                controller: widget.data.idNumberController,
                                hintText:
                                    'Enter your ${widget.data.selectedIdTypeDisplayName} number',
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) =>
                                    widget.data.validateIdNumber(),
                                onChanged: (value) {
                                  widget.onDataChanged(
                                      widget.data.updateIdNumber(value));
                                },
                              ),
                            ),

                          // ID Picture Capture (only show if consented)
                          if (widget.data.idPictureConsent == 'Yes')
                            _buildQuestionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.data.hasGhanaCard == 'Yes'
                                        ? 'Ghana Card Picture'
                                        : '${widget.data.selectedIdTypeDisplayName} Picture',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: _Spacing.md),
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[100],
                                    ),
                                    child: widget.data.idImagePath == null
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                                      icon: const Icon(Icons.camera_alt,
                                          size: 20),
                                      label: Text(
                                        widget.data.idImagePath == null
                                            ? 'Take Picture of ID'
                                            : 'Retake Picture',
                                        style: GoogleFonts.inter(fontSize: 14),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Reason for No Consent (only show if declined consent)
                          if (widget.data.idPictureConsent == 'No')
                            _buildQuestionCard(
                              child: _buildTextField(
                                label: 'Please specify reason',
                                controller: widget.data.reasonController,
                                hintText: 'Enter reason for not consenting',
                                maxLines: 2,
                                validator: (value) =>
                                    widget.data.validateNoConsentReason(),
                                onChanged: (value) {
                                  widget.onDataChanged(
                                      widget.data.updateNoConsentReason(value));
                                },
                              ),
                            ),

                          // Contact Number
                          _buildQuestionCard(
                            child: _buildTextField(
                              label: 'Contact Number',
                              controller: widget.data.contactNumberController,
                              hintText: 'Enter 10-digit phone number',
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              validator: (value) =>
                                  widget.data.validateContactNumber(),
                              onChanged: (value) {
                                widget.onDataChanged(
                                    widget.data.updateContactNumber(value));
                              },
                            ),
                          ),

                          // Number of Children
                          _buildQuestionCard(
                            child: _buildTextField(
                              label: 'Number of Children (Aged 5-17)',
                              controller: widget.data.childrenCountController,
                              hintText: 'Enter number of children',
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  widget.data.validateChildrenCount(),
                              onChanged: (value) {
                                widget.onDataChanged(
                                    widget.data.updateChildrenCount(value));
                              },
                            ),
                          ),

                          // Children Details
                          if (childrenCount > 0)
                            _buildQuestionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.child_care,
                                          color: Colors.green.shade600),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Farmer\'s Children (Aged 5-17)',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: _Spacing.md),
                                  Text(
                                    'Total Children: ${widget.data.childrenCountController.text.isEmpty ? "0" : widget.data.childrenCountController.text}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: _Spacing.sm),
                                  ...List.generate(
                                    childrenCount,
                                    (index) {
                                      final childNumber = index + 1;
                                      // Create controllers for each child field
                                      final firstNameController =
                                          TextEditingController();
                                      final surnameController =
                                          TextEditingController();

                                      // Set initial values if they exist
                                      if (index < widget.data.children.length) {
                                        firstNameController.text = widget
                                            .data.children[index].firstName;
                                        surnameController.text =
                                            widget.data.children[index].surname;
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: _Spacing.lg),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.grey[800]
                                                  : Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Child $childNumber Details',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                // First Name Field
                                                _buildTextField(
                                                  label:
                                                      'Enter first name of child No. $childNumber',
                                                  controller:
                                                      firstNameController,
                                                  hintText: 'First name',
                                                  onChanged: (value) {
                                                    widget.onDataChanged(
                                                      widget.data
                                                          .updateChildName(
                                                              index,
                                                              'firstName',
                                                              value),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                // Surname Field
                                                _buildTextField(
                                                  label:
                                                      'Enter surname of child No. $childNumber',
                                                  controller: surnameController,
                                                  hintText: 'Surname',
                                                  onChanged: (value) {
                                                    widget.onDataChanged(
                                                      widget.data
                                                          .updateChildName(
                                                              index,
                                                              'surname',
                                                              value),
                                                    );
                                                  },
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
                            ),

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
}
