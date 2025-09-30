import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'form_fields.dart';
import 'pages/farm identification/children_household_page.dart';

class ProducerDetailsPage extends StatefulWidget {
  final String personName;
  final Function(Map<String, dynamic>) onSave;

  const ProducerDetailsPage({
    super.key,
    required this.personName,
    required this.onSave,
  });

  @override
  State<ProducerDetailsPage> createState() => _ProducerDetailsPageState();
}

class _ProducerDetailsPageState extends State<ProducerDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  String? _gender;
  String? _nationality;
  final TextEditingController _yearOfBirthController = TextEditingController();
  String? _selectedCountry;
  final TextEditingController _otherCountryController = TextEditingController();

  final List<String> countries = [
    'Burkina Faso',
    'Mali',
    'Guinea',
    'Liberia',
    'Togo',
    'Benin',
    'Niger',
    'Nigeria',
    'Other (specify)'
  ];
  final TextEditingController _ghanaCardIdController = TextEditingController();
  final TextEditingController _otherIdController = TextEditingController();
  final TextEditingController _noConsentReasonController =
      TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  String? _hasGhanaCard;
  String? _selectedIdType;
  bool _consentToTakePhoto = false;
  File? _idPhoto;
  String? _relationshipToRespondent;
  String? _hasBirthCertificate;
  String? _selectedOccupation;
  final TextEditingController _otherOccupationController =
      TextEditingController();
  final List<String> _occupationOptions = [
    'Farmer (cocoa)',
    'Farmer (coffee)',
    'Farmer (other)',
    'Merchant',
    'Student',
    'Other (to specify)',
    'No activity'
  ];
  final TextEditingController _otherRelationshipController =
      TextEditingController();

  final List<Map<String, String>> relationshipOptions = [
    {'value': 'husband_wife', 'label': 'Husband/Wife'},
    {'value': 'son_daughter', 'label': 'Son/Daughter'},
    {'value': 'brother_sister', 'label': 'Brother/Sister'},
    {
      'value': 'son_in_law_daughter_in_law',
      'label': 'Son-in-law/Daughter-in-law'
    },
    {'value': 'grandson_granddaughter', 'label': 'Grandson/Granddaughter'},
    {'value': 'niece_nephew', 'label': 'Niece/Nephew'},
    {'value': 'cousin', 'label': 'Cousin'},
    {'value': 'workers_family_member', 'label': "Worker's family member"},
    {'value': 'worker', 'label': 'Worker'},
    {'value': 'father_mother', 'label': 'Father/Mother'},
    {'value': 'other', 'label': 'Other (specify)'},
  ];

  final List<Map<String, String>> idTypes = [
    {'value': 'voter_id', 'label': 'Voter ID'},
    {'value': 'nhis', 'label': 'NHIS Card'},
    {'value': 'birth_cert', 'label': 'Birth Certificate'},
    {'value': 'passport', 'label': 'Passport'},
    {'value': 'drivers_license', 'label': 'Driver\'s License'},
    {'value': 'none', 'label': 'None'},
  ];

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (photo != null) {
        setState(() {
          _idPhoto = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture image')),
        );
      }
    }
  }

  @override
  void dispose() {
    _yearOfBirthController.dispose();
    _otherCountryController.dispose();
    _ghanaCardIdController.dispose();
    _otherIdController.dispose();
    _noConsentReasonController.dispose();
    _occupationController.dispose();
    _otherRelationshipController.dispose();
    _otherOccupationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Parse year of birth safely
      int? yearOfBirth;
      if (_yearOfBirthController.text.trim().isNotEmpty) {
        yearOfBirth = int.tryParse(_yearOfBirthController.text.trim());
      }

      // Determine occupation value
      String? occupation;
      if (_selectedOccupation == 'Other (to specify)' &&
          _otherOccupationController.text.isNotEmpty) {
        occupation = _otherOccupationController.text;
      } else {
        occupation = _selectedOccupation;
      }

      final details = {
        'name': widget.personName,
        'hasGhanaCard': _hasGhanaCard == 'Yes',
        'ghanaCardId':
            _hasGhanaCard == 'Yes' ? _ghanaCardIdController.text : null,
        'otherIdType': _hasGhanaCard == 'No' ? _selectedIdType : null,
        'otherIdNumber': _hasGhanaCard == 'No' ? _otherIdController.text : null,
        'consentToTakePhoto': _consentToTakePhoto,
        'noConsentReason':
            !_consentToTakePhoto ? _noConsentReasonController.text : null,
        'idPhotoPath': _idPhoto?.path,
        'relationshipToRespondent': _relationshipToRespondent,
        'otherRelationship': _relationshipToRespondent == 'other'
            ? _otherRelationshipController.text
            : null,
        'gender': _gender,
        'nationality': _nationality,
        'yearOfBirth': yearOfBirth,
        'countryOfOrigin': _nationality == 'non_ghanaian'
            ? (_selectedCountry == 'Other (specify)'
                ? _otherCountryController.text
                : _selectedCountry)
            : null,
        'hasBirthCertificate': _hasBirthCertificate,
        'occupation': occupation,
      };

      // Call onSave first
      widget.onSave(details);

      // Then navigate
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChildrenHouseholdPage(
            producerDetails: details,
          ),
        ),
      );
    }
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value == groupValue
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.grey[50],
          border: Border.all(
            color: value == groupValue
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: value == groupValue ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: value == groupValue
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: value == groupValue
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              child: value == groupValue
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: value == groupValue
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: value == groupValue
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[800],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('PRODUCER\'S / MANAGER\'S INFORMATION - ${widget.personName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ghana Card Question Card
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Does ${widget.personName} have a Ghana card?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          _buildRadioOption(
                            value: 'Yes',
                            groupValue: _hasGhanaCard,
                            label: 'Yes',
                            onChanged: (value) {
                              setState(() {
                                _hasGhanaCard = value;
                                _otherIdController.clear();
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
                                if (_hasGhanaCard == 'No') {
                                  _ghanaCardIdController.clear();
                                } else {
                                  _selectedIdType = null;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Ghana Card ID Field (shown when 'Yes' is selected)
              if (_hasGhanaCard == 'Yes')
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ghana Card ID',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _ghanaCardIdController,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Enter Ghana Card ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          validator: (value) {
                            if (_hasGhanaCard == 'Yes' &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter Ghana Card ID';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              // Other ID Card (shown when 'No' is selected)
              if (_hasGhanaCard == 'No')
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Which other national id card is available',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedIdType,
                          decoration: InputDecoration(
                            hintText: 'Select ID type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          items: idTypes.map((idType) {
                            return DropdownMenuItem<String>(
                              value: idType['value'],
                              child: Text(idType['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedIdType = value;
                            });
                          },
                          validator: (value) {
                            if (_hasGhanaCard == 'No' &&
                                (value == null || value.isEmpty)) {
                              return 'Please select an ID type';
                            }
                            return null;
                          },
                        ),
                        if (_selectedIdType != null &&
                            _selectedIdType != 'none')
                          const SizedBox(height: 16),
                        if (_selectedIdType != null &&
                            _selectedIdType != 'none')
                          TextFormField(
                            controller: _otherIdController,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'Enter ID number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (_hasGhanaCard == 'No' &&
                                  _selectedIdType != 'none' &&
                                  (value == null || value.isEmpty)) {
                                return 'Please enter ID number';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                ),

              // Consent for taking ID photo
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Do you consent to us taking a picture of your national ID?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          _buildRadioOption(
                            value: 'Yes',
                            groupValue: _consentToTakePhoto ? 'Yes' : 'No',
                            label: 'Yes',
                            onChanged: (value) {
                              setState(() {
                                _consentToTakePhoto = value == 'Yes';
                              });
                            },
                          ),
                          _buildRadioOption(
                            value: 'No',
                            groupValue: _consentToTakePhoto ? 'Yes' : 'No',
                            label: 'No',
                            onChanged: (value) {
                              setState(() {
                                _consentToTakePhoto = value == 'Yes';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Show camera button if "Yes" is selected
              if (_consentToTakePhoto) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID Photo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: _idPhoto == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 40, color: Colors.grey[500]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to take photo of ID',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _idPhoto!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),
                    // Relationship selection
                    if (_idPhoto != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Relationship of ${widget.personName} to the respondent',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _relationshipToRespondent,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        hint: const Text('Select relationship'),
                        items: relationshipOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(option['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _relationshipToRespondent = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_relationshipToRespondent == 'worker' ||
                          _relationshipToRespondent == 'workers_family_member')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '***Make sure to interview the Worker or Family of the Worker should any of these 2 be selected above.***',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (_relationshipToRespondent == 'other') ...[
                        const SizedBox(height: 16),
                        FormFields.buildTextField(
                          context: context,
                          label: 'If Other, please specify',
                          hintText: 'Enter relationship',
                          controller: _otherRelationshipController,
                          onChanged: (value) {},
                        ),
                      ],
                    ],
                  ],
                ),
              ],

              // Show reason field if "No" is selected for consent
              if (!_consentToTakePhoto) ...[
                const SizedBox(height: 16),
                FormFields.buildTextField(
                  context: context,
                  label: 'Reason for not providing photo',
                  hintText: 'Please specify reason',
                  controller: _noConsentReasonController,
                  onChanged: (value) {},
                  maxLines: 3,
                ),
                // Relationship selection for non-consent case
                const SizedBox(height: 24),
                Text(
                  'Relationship of ${widget.personName} to the respondent',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _relationshipToRespondent,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  hint: const Text('Select relationship'),
                  items: relationshipOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option['value'],
                      child: Text(option['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _relationshipToRespondent = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                if (_relationshipToRespondent == 'worker' ||
                    _relationshipToRespondent == 'workers_family_member')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '***Make sure to interview the Worker or Family of the Worker should any of these 2 be selected above.***',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (_relationshipToRespondent == 'other') ...[
                  const SizedBox(height: 16),
                  FormFields.buildTextField(
                    context: context,
                    label: 'If Other, please specify',
                    hintText: 'Enter relationship',
                    controller: _otherRelationshipController,
                    onChanged: (value) {},
                  ),
                ],
              ],

              // Personal Information Section
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Gender Selection
                      Text(
                        'Gender of ${widget.personName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Male'),
                              value: 'male',
                              groupValue: _gender,
                              onChanged: (String? value) {
                                setState(() {
                                  _gender = value;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Female'),
                              value: 'female',
                              groupValue: _gender,
                              onChanged: (String? value) {
                                setState(() {
                                  _gender = value;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Nationality
                      Text(
                        'Nationality of ${widget.personName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Ghanaian'),
                              value: 'ghanaian',
                              groupValue: _nationality,
                              onChanged: (String? value) {
                                setState(() {
                                  _nationality = value;
                                  if (_nationality == 'ghanaian') {
                                    _selectedCountry = null;
                                    _otherCountryController.clear();
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Non-Ghanaian'),
                              value: 'non_ghanaian',
                              groupValue: _nationality,
                              onChanged: (String? value) {
                                setState(() {
                                  _nationality = value;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),

                      // Year of Birth
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now()
                                .subtract(const Duration(days: 365 * 18)),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            initialDatePickerMode: DatePickerMode.year,
                          );
                          if (picked != null) {
                            setState(() {
                              _yearOfBirthController.text =
                                  picked.year.toString();
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _yearOfBirthController,
                            decoration: InputDecoration(
                              labelText: 'Year of Birth',
                              hintText: 'Tap to select year',
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Country of Origin (Conditional)
                      if (_nationality == 'non_ghanaian') ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          decoration: InputDecoration(
                            labelText: 'Country of Origin',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          hint: const Text('Select country'),
                          items: countries.map((country) {
                            return DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCountry = value;
                            });
                          },
                        ),
                        if (_selectedCountry == 'Other (specify)')
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: FormFields.buildTextField(
                              context: context,
                              label: 'Specify Country',
                              hintText: 'Enter country name',
                              controller: _otherCountryController,
                            ),
                          ),
                      ],

                      // Birth Certificate Question
                      const SizedBox(height: 16),
                      Text(
                        'Does ${widget.personName} have a birth certificate?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Yes'),
                              value: 'yes',
                              groupValue: _hasBirthCertificate,
                              onChanged: (String? value) {
                                setState(() {
                                  _hasBirthCertificate = value;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('No'),
                              value: 'no',
                              groupValue: _hasBirthCertificate,
                              onChanged: (String? value) {
                                setState(() {
                                  _hasBirthCertificate = value;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),

                      // Occupation
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Work/main occupation of ${widget.personName}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedOccupation,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: _occupationOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedOccupation = newValue;
                              });
                            },
                          ),
                          if (_selectedOccupation == 'Other (to specify)')
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextFormField(
                                controller: _otherOccupationController,
                                decoration: InputDecoration(
                                  labelText: 'Please specify occupation',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Save Button
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('NEXT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
