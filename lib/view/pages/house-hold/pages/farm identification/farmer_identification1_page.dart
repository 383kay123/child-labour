import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class FarmerChild {
  final int childNumber;
  String firstName;
  String surname;

  FarmerChild({
    required this.childNumber,
    required this.firstName,
    required this.surname,
  });

  Map<String, dynamic> toJson() => {
        'child_number': childNumber,
        'first_name': firstName,
        'surname': surname,
      };
}

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class FarmerIdentification1Page extends StatefulWidget {
  final Function(Map<String, dynamic>)? onComplete;
  final Map<String, dynamic>? initialData;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const FarmerIdentification1Page({
    Key? key,
    this.onComplete,
    this.initialData,
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
  String? _hasGhanaCard;
  String? _selectedIdType;
  String? _idPictureConsent;
  final TextEditingController _ghanaCardNumberController =
      TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  String? _idImagePath;
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _childrenCountController =
      TextEditingController();
  final List<FarmerChild> _children = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      if (widget.initialData!['farmer_gh_card_available'] == 'yes') {
        _hasGhanaCard = 'Yes';
      } else if (widget.initialData!['farmer_gh_card_available'] == 'no') {
        _hasGhanaCard = 'No';
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _ghanaCardNumberController.dispose();
    _idNumberController.dispose();
    _contactNumberController.dispose();
    _childrenCountController.dispose();
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
        setState(() {
          _idImagePath = image.path;
        });
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
      if (_hasGhanaCard == 'Yes' &&
          _idPictureConsent == 'Yes' &&
          (_ghanaCardNumberController.text.isEmpty ||
              _ghanaCardNumberController.text.trim().length < 6)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enter a valid Ghana Card number')),
        );
        return;
      }

      if (_idPictureConsent == 'Yes' && _idImagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please take a picture of the ID')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final formData = {
        'farmer_gh_card_available': _hasGhanaCard == 'Yes' ? 'yes' : 'no',
        'farmer_nat_id_available':
            _hasGhanaCard == 'Yes' ? 'ghana_card' : _getSelectedIdTypeValue(),
        'id_picture_consent': _idPictureConsent,
        'id_image_path': _idImagePath,
        'ghana_card_number':
            _hasGhanaCard == 'Yes' && _idPictureConsent == 'Yes'
                ? _ghanaCardNumberController.text.trim()
                : null,
        'id_rejection_reason':
            _idPictureConsent == 'No' ? _reasonController.text.trim() : null,
        'contact_number': _contactNumberController.text.trim(),
        'children_5_17_count':
            int.tryParse(_childrenCountController.text.trim()) ?? 0,
        'children': _children.map((child) => child.toJson()).toList(),
      };

      widget.onComplete?.call(formData);

      if (widget.onNext != null) {
        widget.onNext!();
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getSelectedIdTypeValue() {
    if (_selectedIdType == null) return '';

    switch (_selectedIdType) {
      case 'voter_id':
        return 'voter';
      case 'nhis_card':
        return 'nhis';
      case 'passport':
        return 'passport';
      case 'drivers_license':
        return 'driver';
      case 'ssnit':
        return 'ssnit';
      case 'birth_certificate':
        return 'birth';
      default:
        return 'other';
    }
  }

  String _getSelectedIdTypeDisplayName() {
    switch (_selectedIdType) {
      case 'voter_id':
        return 'Voter ID';
      case 'nhis_card':
        return 'NHIS Card';
      case 'passport':
        return 'Passport';
      case 'drivers_license':
        return "Driver's License";
      case 'ssnit':
        return 'SSNIT';
      case 'birth_certificate':
        return 'Birth Certificate';
      default:
        return 'ID';
    }
  }

  void _updateChildrenList(int count) {
    if (count > _children.length) {
      for (int i = _children.length; i < count; i++) {
        _children.add(FarmerChild(
          childNumber: i + 1,
          firstName: '',
          surname: '',
        ));
      }
    } else if (count < _children.length) {
      _children.removeRange(count, _children.length);
    }
  }

  void _updateChildName(int index, String field, String value) {
    if (index >= _children.length) {
      _children.add(FarmerChild(
        childNumber: index + 1,
        firstName: field == 'firstName' ? value : '',
        surname: field == 'surname' ? value : '',
      ));
    }

    setState(() {
      if (field == 'firstName') {
        _children[index].firstName = value;
      } else {
        _children[index].surname = value;
      }
    });
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
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  bool get _isFormComplete {
    return _hasGhanaCard != null &&
            (_hasGhanaCard == 'Yes' ||
                (_hasGhanaCard == 'No' && _selectedIdType != null)) &&
            ((_hasGhanaCard == 'Yes' && _hasGhanaCard != null) ||
                (_hasGhanaCard == 'No' && _selectedIdType != null))
        ? _idPictureConsent != null
        : true &&
            _contactNumberController.text.isNotEmpty &&
            _childrenCountController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final childrenCount = int.tryParse(_childrenCountController.text) ?? 0;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      // appBar: AppBar(
      //   title: Text(
      //     'Farmer Identification',
      //     style: GoogleFonts.inter(
      //       fontSize: 18,
      //       fontWeight: FontWeight.w600,
      //       color: Colors.white,
      //     ),
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Colors.green.shade600,
      //   automaticallyImplyLeading: false,
      // ),
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
                                  'Do you have a Ghana Card?',
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
                                      groupValue: _hasGhanaCard,
                                      label: 'Yes',
                                      onChanged: (value) {
                                        setState(() {
                                          _hasGhanaCard = value;
                                          _selectedIdType = null;
                                        });
                                      },
                                    ),
                                    _buildRadioOption(
                                      value: 'No',
                                      groupValue: _hasGhanaCard,
                                      label: 'No',
                                      onChanged: (value) {
                                        setState(() {
                                          _hasGhanaCard = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Ghana Card Number Field
                          if (_hasGhanaCard == 'Yes')
                            _buildQuestionCard(
                              child: _buildTextField(
                                label: 'Ghana Card Number',
                                controller: _ghanaCardNumberController,
                                hintText: 'Enter Ghana Card number',
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your Ghana Card number';
                                  }
                                  return null;
                                },
                              ),
                            ),

                          // Alternative ID Options
                          if (_hasGhanaCard == 'No')
                            _buildQuestionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Which of the following ID cards do you have?',
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
                                        groupValue: _selectedIdType,
                                        label: 'Voter ID',
                                        onChanged: (value) {
                                          setState(
                                              () => _selectedIdType = value);
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'drivers_license',
                                        groupValue: _selectedIdType,
                                        label: 'Driver\'s License',
                                        onChanged: (value) {
                                          setState(
                                              () => _selectedIdType = value);
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'nhis_card',
                                        groupValue: _selectedIdType,
                                        label: 'NHIS Card',
                                        onChanged: (value) {
                                          setState(
                                              () => _selectedIdType = value);
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'passport',
                                        groupValue: _selectedIdType,
                                        label: 'Passport',
                                        onChanged: (value) {
                                          setState(
                                              () => _selectedIdType = value);
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'ssnit',
                                        groupValue: _selectedIdType,
                                        label: 'SSNIT',
                                        onChanged: (value) {
                                          setState(
                                              () => _selectedIdType = value);
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'birth_certificate',
                                        groupValue: _selectedIdType,
                                        label: 'Birth Certificate',
                                        onChanged: (value) {
                                          setState(
                                              () => _selectedIdType = value);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          // ID Number Field for Alternative IDs
                          if (_hasGhanaCard == 'No' && _selectedIdType != null)
                            _buildQuestionCard(
                              child: _buildTextField(
                                label:
                                    'Enter ${_getSelectedIdTypeDisplayName()} Number',
                                controller: _idNumberController,
                                hintText:
                                    'Enter your ${_getSelectedIdTypeDisplayName()} number',
                                keyboardType: TextInputType.text,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your ${_getSelectedIdTypeDisplayName()} number';
                                  }
                                  return null;
                                },
                              ),
                            ),

                          // Consent Question
                          if ((_hasGhanaCard == 'Yes' &&
                                  _hasGhanaCard != null) ||
                              (_hasGhanaCard == 'No' &&
                                  _selectedIdType != null))
                            _buildQuestionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Do you consent to us taking a picture of your national ID and taking ID number?',
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
                                        groupValue: _idPictureConsent,
                                        label: 'Yes',
                                        onChanged: (value) {
                                          setState(
                                              () => _idPictureConsent = value);
                                        },
                                      ),
                                      _buildRadioOption(
                                        value: 'No',
                                        groupValue: _idPictureConsent,
                                        label: 'No',
                                        onChanged: (value) {
                                          setState(
                                              () => _idPictureConsent = value);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          // Reason for No Consent
                          if (_idPictureConsent == 'No')
                            _buildQuestionCard(
                              child: _buildTextField(
                                label: 'Please specify reason',
                                controller: _reasonController,
                                hintText: 'Enter reason for not consenting',
                                maxLines: 2,
                                validator: (value) {
                                  if (_idPictureConsent == 'No' &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Please specify a reason';
                                  }
                                  return null;
                                },
                              ),
                            ),

                          // ID Picture Capture
                          if (_idPictureConsent == 'Yes')
                            _buildQuestionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID Picture',
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
                                    child: _idImagePath == null
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
                                              File(_idImagePath!),
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
                                        _idImagePath == null
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

                          // Contact Number
                          _buildQuestionCard(
                            child: _buildTextField(
                              label: 'Contact Number',
                              controller: _contactNumberController,
                              hintText: 'Enter 10-digit phone number',
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter contact number';
                                }
                                if (value.length != 10) {
                                  return 'Please enter a valid 10-digit number';
                                }
                                return null;
                              },
                            ),
                          ),

                          // Number of Children
                          _buildQuestionCard(
                            child: _buildTextField(
                              label: 'Number of Children (Aged 5-17)',
                              controller: _childrenCountController,
                              hintText: 'Enter number of children',
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final count = int.tryParse(value) ?? 0;
                                _updateChildrenList(count);
                                setState(() {});
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter number of children';
                                }
                                final number = int.tryParse(value);
                                if (number == null) {
                                  return 'Please enter a valid number';
                                }
                                if (number < 0) {
                                  return 'Number cannot be negative';
                                }
                                if (number > 20) {
                                  return 'Please enter a reasonable number';
                                }
                                return null;
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
                                    'Total Children: ${_childrenCountController.text.isEmpty ? "0" : _childrenCountController.text}',
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
                                      if (index < _children.length) {
                                        firstNameController.text =
                                            _children[index].firstName;
                                        surnameController.text =
                                            _children[index].surname;
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
                                                  onChanged: (value) =>
                                                      _updateChildName(index,
                                                          'firstName', value),
                                                ),
                                                const SizedBox(height: 16),
                                                // Surname Field
                                                _buildTextField(
                                                  label:
                                                      'Enter surname of child No. $childNumber',
                                                  controller: surnameController,
                                                  hintText: 'Surname',
                                                  onChanged: (value) =>
                                                      _updateChildName(index,
                                                          'surname', value),
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
