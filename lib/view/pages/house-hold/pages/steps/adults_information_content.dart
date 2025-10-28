import 'dart:io';

import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/models/adult_info_model.dart';
import 'package:image_picker/image_picker.dart';

class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AdultsInformationContent extends StatefulWidget {
  final AdultsInformationData data;
  final ValueChanged<AdultsInformationData> onDataChanged;
  final List<String> validationErrors;

  const AdultsInformationContent({
    Key? key,
    required this.data,
    required this.onDataChanged,
    this.validationErrors = const [],
  }) : super(key: key);

  @override
  State<AdultsInformationContent> createState() => _AdultsInformationContentState();
}

class _AdultsInformationContentState extends State<AdultsInformationContent> {
  late TextEditingController _adultsCountController;
  late List<TextEditingController> _nameControllers;
  late List<bool> _showProducerDetailsList;
  late List<ProducerDetailsModel> _producerDetailsList;

  @override
  void initState() {
    super.initState();
    _adultsCountController = TextEditingController(
      text: widget.data.numberOfAdults?.toString() ?? '',
    );
    _initializeFromExistingData();
  }

  void _initializeFromExistingData() {
    _nameControllers = [];
    _showProducerDetailsList = [];
    _producerDetailsList = [];

    if (widget.data.members.isNotEmpty) {
      for (final member in widget.data.members) {
        _nameControllers.add(TextEditingController(text: member.name));
        _showProducerDetailsList.add(false);
        _producerDetailsList.add(member.producerDetails);
      }
    } else if (widget.data.numberOfAdults != null) {
      for (int i = 0; i < widget.data.numberOfAdults!; i++) {
        _nameControllers.add(TextEditingController());
        _showProducerDetailsList.add(false);
        _producerDetailsList.add(ProducerDetailsModel());
      }
    }
  }

  void _updateParentData() {
    final members = List.generate(_nameControllers.length, (index) {
      return HouseholdMember(
        name: _nameControllers[index].text,
        producerDetails: _producerDetailsList[index],
      );
    });

    widget.onDataChanged(
      AdultsInformationData(
        numberOfAdults: _nameControllers.isEmpty ? null : _nameControllers.length,
        members: members,
      ),
    );
  }

  void _onCountChanged(String value) {
    final count = int.tryParse(value);

    if (count == null || count < 0) {
      setState(() {
        _nameControllers.clear();
        _showProducerDetailsList.clear();
        _producerDetailsList.clear();
      });
      _updateParentData();
      return;
    }

    // Dispose old controllers
    for (var controller in _nameControllers) {
      controller.dispose();
    }

    // Initialize new lists
    final newNameControllers = <TextEditingController>[];
    final newShowDetailsList = <bool>[];
    final newProducerDetails = <ProducerDetailsModel>[];

    for (int i = 0; i < count; i++) {
      if (i < _nameControllers.length) {
        // Keep existing data
        newNameControllers.add(_nameControllers[i]);
        newShowDetailsList.add(_showProducerDetailsList[i]);
        newProducerDetails.add(_producerDetailsList[i]);
      } else {
        // Add new entries
        newNameControllers.add(TextEditingController());
        newShowDetailsList.add(false);
        newProducerDetails.add(ProducerDetailsModel());
      }
    }

    setState(() {
      _nameControllers = newNameControllers;
      _showProducerDetailsList = newShowDetailsList;
      _producerDetailsList = newProducerDetails;
    });

    _updateParentData();
  }

  void _toggleProducerDetails(int index) {
    if (index < _nameControllers.length &&
        index < _showProducerDetailsList.length &&
        _isNameValid(_nameControllers[index].text)) {
      setState(() {
        _showProducerDetailsList[index] = !_showProducerDetailsList[index];
      });
    }
  }

  void _updateProducerDetails(int index, ProducerDetailsModel details) {
    if (index < _producerDetailsList.length) {
      setState(() {
        _producerDetailsList[index] = details;
      });
      _updateParentData();
    }
  }

  bool _isNameValid(String name) {
    return name.trim().isNotEmpty && name.trim().split(' ').length >= 2;
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    bool? isValid,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.md),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: (isValid == true)
                    ? Colors.green.shade400
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                width: (isValid == true) ? 2.0 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: (isValid == true)
                    ? Colors.green.shade600
                    : theme.primaryColor,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _Spacing.lg,
              vertical: _Spacing.md,
            ),
            suffixIcon: (isValid == true)
                ? Icon(Icons.check_circle, color: Colors.green.shade600)
                : null,
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _adultsCountController.dispose();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number of adults input
          _buildQuestionCard(
            child: _buildTextField(
              label: 'Total number of adults in the household '
                  '(Producer/manager/owner not included). '
                  'Include the manager\'s family only if they live in the producer\'s household. *',
              controller: _adultsCountController,
              hintText: 'Enter number of adults',
              keyboardType: TextInputType.number,
              onChanged: _onCountChanged,
            ),
          ),

          // Household members section
          if (_nameControllers.isNotEmpty) ...[
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full name of household members',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: _Spacing.sm),
                  Text(
                    'List all members of the producer\'s household. Do not include the manager/farmer. '
                    'Include the manager\'s family only if they live in the producer\'s household. '
                    'Write the first and last names of household members.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Individual household member cards
            ...List.generate(_nameControllers.length, (index) {
              final nameController = _nameControllers[index];
              final isNameValid = _isNameValid(nameController.text);
              final producerDetails = _producerDetailsList[index];
              final isDetailsComplete = producerDetails.isComplete;

              return Column(
                children: [
                  _buildQuestionCard(
                    child: _buildTextField(
                      label: 'Full Name of Household Member ${index + 1}',
                      controller: nameController,
                      hintText: 'Enter first and last name',
                      isValid: isNameValid,
                      onChanged: (value) {
                        setState(() {});
                        _updateParentData();
                      },
                    ),
                  ),

                  // Producer details section
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: _Spacing.lg),
                      color: isNameValid
                          ? (isDark
                              ? Colors.green.shade900.withOpacity(0.3)
                              : Colors.green.shade50)
                          : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: isNameValid
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'PRODUCER DETAILS - ${nameController.text.isNotEmpty ? nameController.text.toUpperCase() : 'ENTER FULL NAME'}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isNameValid
                                          ? Colors.green.shade800
                                          : Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                if (isNameValid)
                                  Icon(
                                    isDetailsComplete
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: isDetailsComplete
                                        ? Colors.green
                                        : Colors.orange,
                                    size: 16,
                                  ),
                              ],
                            ),
                            trailing: Icon(
                              _showProducerDetailsList[index]
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: isNameValid
                                  ? Colors.green.shade800
                                  : Colors.grey.shade600,
                            ),
                            onTap: () => _toggleProducerDetails(index),
                          ),

                          // Producer details form
                          if (_showProducerDetailsList[index] && isNameValid)
                            Padding(
                              padding: const EdgeInsets.all(_Spacing.lg),
                              child: _ProducerDetailsForm(
                                personName: nameController.text,
                                details: producerDetails,
                                onDetailsUpdated: (details) =>
                                    _updateProducerDetails(index, details),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],

          // Show validation errors if any
          if (widget.validationErrors.isNotEmpty) ...[
            const SizedBox(height: _Spacing.lg),
            ...widget.validationErrors.map((error) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            )).toList(),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// Producer Details Form for Adults Information Page
class _ProducerDetailsForm extends StatefulWidget {
  final String personName;
  final ProducerDetailsModel details;
  final ValueChanged<ProducerDetailsModel> onDetailsUpdated;

  const _ProducerDetailsForm({
    required this.personName,
    required this.details,
    required this.onDetailsUpdated,
  });

  @override
  State<_ProducerDetailsForm> createState() => __ProducerDetailsFormState();
}

class __ProducerDetailsFormState extends State<_ProducerDetailsForm> {
  late TextEditingController _yearOfBirthController;
  late TextEditingController _ghanaCardIdController;
  late TextEditingController _otherIdNumberController;
  late TextEditingController _noConsentReasonController;
  late TextEditingController _otherRelationshipController;
  late TextEditingController _otherOccupationController;
  late TextEditingController _otherCountryController;

  File? _idPhoto;

  // Update the _getGhanaCardStatus method to:
String? _getGhanaCardStatus() {
  if (widget.details.ghanaCardId == null || widget.details.ghanaCardId!.isEmpty) {
    return 'No';
  } else {
    return 'Yes';
  }
}
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _getInitialDate(),
      firstDate: DateTime(1910),
      lastDate: DateTime(DateTime.now().year - 18),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[800]! 
                  : Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : null,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _yearOfBirthController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _updateParentDetails();
      });
    }
  }

  DateTime _getInitialDate() {
    if (_yearOfBirthController.text.isNotEmpty) {
      final date = DateTime.tryParse(_yearOfBirthController.text);
      if (date != null) return date;
    }
    // Default to 30 years ago if no date is set
    return DateTime(DateTime.now().year - 30);
  }

  String _calculateAge(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';
    
    final now = DateTime.now();
    int age = now.year - date.year;
    
    // Adjust age if birthday hasn't occurred yet this year
    if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
      age--;
    }
    
    return 'Age: $age years';
  }

  @override
  void initState() {
    super.initState();
    _yearOfBirthController = TextEditingController(
        text: widget.details.yearOfBirth?.toString() ?? '');
    _ghanaCardIdController =
        TextEditingController(text: widget.details.ghanaCardId ?? '');
    _otherIdNumberController =
        TextEditingController(text: widget.details.otherIdNumber ?? '');
    _noConsentReasonController =
        TextEditingController(text: widget.details.noConsentReason ?? '');
    _otherRelationshipController =
        TextEditingController(text: widget.details.otherRelationship ?? '');
    _otherOccupationController =
        TextEditingController(text: widget.details.otherOccupation ?? '');
    
    // Initialize other country controller with the selected country if it's not one of the predefined options
    final predefinedCountries = ['Burkina Faso', 'Mali', 'Guinea', 'Ivory Coast', 'Liberia', 'Togo', 'Benin', 'Other'];
    final selectedCountry = widget.details.selectedCountry;
    if (selectedCountry != null && !predefinedCountries.contains(selectedCountry)) {
      _otherCountryController = TextEditingController(text: selectedCountry);
      // Update the selectedCountry to 'Other' to show the text field
      widget.onDetailsUpdated(widget.details.copyWith(selectedCountry: 'Other'));
    } else {
      _otherCountryController = TextEditingController(text: '');
    }
  }

  void _updateParentDetails() {
    int? yearOfBirth;
    if (_yearOfBirthController.text.isNotEmpty) {
      final date = DateTime.tryParse(_yearOfBirthController.text);
      if (date != null) {
        yearOfBirth = date.year;
      }
    }

    // If 'Other' is selected, use the text from _otherCountryController
    String? selectedCountry = widget.details.selectedCountry;
    if (selectedCountry == 'Other' && _otherCountryController.text.isNotEmpty) {
      selectedCountry = _otherCountryController.text;
    }

    final newDetails = widget.details.copyWith(
      yearOfBirth: yearOfBirth,
      ghanaCardId: _ghanaCardIdController.text.isEmpty
          ? null
          : _ghanaCardIdController.text,
      otherIdNumber: _otherIdNumberController.text.isEmpty
          ? null
          : _otherIdNumberController.text,
      noConsentReason: _noConsentReasonController.text.isEmpty
          ? null
          : _noConsentReasonController.text,
      otherRelationship: _otherRelationshipController.text.isEmpty
          ? null
          : _otherRelationshipController.text,
      otherOccupation: _otherOccupationController.text.isEmpty
          ? null
          : _otherOccupationController.text,
      selectedCountry: _otherCountryController.text.isEmpty
          ? null
          : _otherCountryController.text,
      idPhotoPath: _idPhoto?.path,
    );

    widget.onDetailsUpdated(newDetails);
  }

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
          _updateParentDetails();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to capture image'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildQuestionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: _Spacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(_Spacing.md),
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
    final isSelected = groupValue == value;

    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: (value) {
        onChanged(value);
        if (mounted) {
          setState(() {});
        }
      },
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? Colors.white70 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      activeColor: theme.colorScheme.primary,
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
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) => _updateParentDetails(),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
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
            fillColor: isDark ? Colors.grey.shade800 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _Spacing.md,
              vertical: _Spacing.sm,
            ),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              width: 1,
            ),
            color: isDark ? Colors.grey.shade800 : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: _Spacing.md),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select an option',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
              iconSize: 24,
              elevation: 16,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              onChanged: (String? newValue) {
                if (newValue != value) {
                  onChanged(newValue);
                  _updateParentDetails();
                }
              },
              dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
              items: items.map<DropdownMenuItem<String>>((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(
                    item['display'] ?? item['label'] ?? item['value'] ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ghana Card Question - FIXED VERSION
       _buildQuestionCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Does ${widget.personName} have a Ghana card?',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      const SizedBox(height: _Spacing.sm),
      Wrap(
        spacing: 20,
        children: [
          _buildRadioOption(
            value: 'Yes',
            groupValue: widget.details.ghanaCardId != null ? 'Yes' : 'No',
            label: 'Yes',
            onChanged: (value) {
              setState(() {
                widget.onDetailsUpdated(widget.details.copyWith(
                  ghanaCardId: 'ghana-card',
                  otherIdType: null,
                  otherIdNumber: null,
                ));
              });
            },
          ),
          _buildRadioOption(
            value: 'No',
            groupValue: widget.details.ghanaCardId != null ? 'Yes' : 'No',
            label: 'No',
            onChanged: (value) {
              setState(() {
                widget.onDetailsUpdated(widget.details.copyWith(
                  ghanaCardId: null,
                  otherIdType: null,
                  otherIdNumber: null,
                ));
              });
            },
          ),
        ],
      ),
    ],
  ),
),
        // Other ID Type (if No Ghana Card)
        if (_getGhanaCardStatus() == 'No')
          _buildQuestionCard(
            child: Column(
              children: [
                _buildDropdownField(
                  label: 'Which other national id card is available',
                  value: widget.details.otherIdType,
                  items: [
                    {'value': 'voter_id', 'label': 'Voter ID'},
                    {'value': 'nhis', 'label': 'NHIS Card'},
                    {'value': 'birth_cert', 'label': 'Birth Certificate'},
                    {'value': 'passport', 'label': 'Passport'},
                    {'value': 'drivers_license', 'label': 'Driver\'s License'},
                    {'value': 'none', 'label': 'None'},
                  ],
                  onChanged: (value) {
                    setState(() {
                      widget.onDetailsUpdated(widget.details.copyWith(
                        otherIdType: value,
                        otherIdNumber: value != 'none' ? '' : null,
                      ));
                    });
                  },
                ),
                if (widget.details.otherIdType != null &&
                    widget.details.otherIdType != 'none') ...[
                  const SizedBox(height: _Spacing.md),
                  _buildTextField(
                    label: 'ID Number',
                    controller: _otherIdNumberController,
                    hintText: 'Enter ID number',
                  ),
                ],
              ],
            ),
          ),

        // Gender
        _buildQuestionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gender',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: _Spacing.sm),
              Wrap(
                spacing: 20,
                children: [
                  _buildRadioOption(
                    value: 'male',
                    groupValue: widget.details.gender,
                    label: 'Male',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(
                            widget.details.copyWith(gender: value));
                      });
                    },
                  ),
                  _buildRadioOption(
                    value: 'female',
                    groupValue: widget.details.gender,
                    label: 'Female',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(
                            widget.details.copyWith(gender: value));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Nationality
        _buildQuestionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nationality',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: _Spacing.sm),
              Wrap(
                spacing: 20,
                children: [
                  _buildRadioOption(
                    value: 'ghanaian',
                    groupValue: widget.details.nationality,
                    label: 'Ghanaian',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(widget.details.copyWith(
                          nationality: value,
                          selectedCountry: null,
                        ));
                      });
                    },
                  ),
                  _buildRadioOption(
                    value: 'non_ghanaian',
                    groupValue: widget.details.nationality,
                    label: 'Non-Ghanaian',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(
                            widget.details.copyWith(nationality: value));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Country of Origin (for non-Ghanaians)
        if (widget.details.nationality == 'non_ghanaian')
          _buildQuestionCard(
            child: Column(
              children: [
                _buildDropdownField(
                  label: 'If Non Ghanaian, specify country of origin',
                  value: widget.details.selectedCountry,
                  items: [
                    {'value': 'Burkina Faso', 'display': 'Burkina Faso'},
                    {'value': 'Mali', 'display': 'Mali'},
                    {'value': 'Guinea', 'display': 'Guinea'},
                    {'value': 'Ivory Coast', 'display': 'Ivory Coast'},
                    {'value': 'Liberia', 'display': 'Liberia'},
                    {'value': 'Togo', 'display': 'Togo'},
                    {'value': 'Benin', 'display': 'Benin'},
                    {'value': 'Other', 'display': 'Other (specify)'},
                  ],
                  onChanged: (value) {
                    widget.onDetailsUpdated(
                      widget.details.copyWith(
                        selectedCountry: value,
                      ),
                    );
                    // Update the UI to show/hide the 'Other' text field
                    setState(() {});
                  },
                ),
                if (widget.details.selectedCountry == 'Other') ...[
                  const SizedBox(height: _Spacing.md),
                  _buildTextField(
                    label: 'If Other, please specify',
                    controller: _otherCountryController,
                    hintText: 'Enter country name',
                    onChanged: (value) {
                      // Update the selected country when the text field changes
                      if (value.isNotEmpty) {
                        widget.onDetailsUpdated(
                          widget.details.copyWith(selectedCountry: value),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),

        // Year of Birth with Date Picker
        _buildQuestionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date of Birth',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: _Spacing.sm),
              GestureDetector(
                onTap: () => _selectDateOfBirth(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _yearOfBirthController,
                    decoration: InputDecoration(
                      hintText: 'Tap to select date',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white54
                                : Colors.grey.shade600,
                          ),
                      suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: _Spacing.md,
                        vertical: _Spacing.sm,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select date of birth';
                      }
                      final date = DateTime.tryParse(value);
                      if (date == null) return 'Invalid date format';
                      
                      final now = DateTime.now();
                      final minDate = DateTime(1910, 1, 1);
                      final maxDate = DateTime(now.year - 18, now.month, now.day);
                      
                      if (date.isBefore(minDate)) {
                        return 'Date must be after 1910';
                      }
                      if (date.isAfter(maxDate)) {
                        return 'Person must be at least 18 years old';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _updateParentDetails();
                    },
                  ),
                ),
              ),
              if (_yearOfBirthController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _calculateAge(_yearOfBirthController.text),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
            ],
          ),
        ),

        // Consent to Take Photo
        if ((_getGhanaCardStatus() == 'Yes' && _ghanaCardIdController.text.isNotEmpty) ||
            (widget.details.otherIdType != null &&
                widget.details.otherIdType != 'none'))
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do you consent to us taking a picture of your identification document?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: _Spacing.sm),
                Wrap(
                  spacing: 20,
                  children: [
                    _buildRadioOption(
                      value: 'Yes',
                      groupValue: widget.details.consentToTakePhoto == true
                          ? 'Yes'
                          : widget.details.consentToTakePhoto == false
                              ? 'No'
                              : null,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          widget.onDetailsUpdated(widget.details.copyWith(
                            consentToTakePhoto: value == 'Yes',
                            noConsentReason: null,
                          ));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'No',
                      groupValue: widget.details.consentToTakePhoto == true
                          ? 'Yes'
                          : widget.details.consentToTakePhoto == false
                              ? 'No'
                              : null,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          widget.onDetailsUpdated(widget.details.copyWith(
                            consentToTakePhoto: value == 'Yes',
                          ));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

        // ID Photo Section (if consent is given)
        if (widget.details.consentToTakePhoto == true &&
            ((_getGhanaCardStatus() == 'Yes' && _ghanaCardIdController.text.isNotEmpty) ||
                (widget.details.otherIdType != null &&
                    widget.details.otherIdType != 'none')))
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Photo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: _Spacing.sm),
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey[100],
                    ),
                    child: _idPhoto == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 30,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey[500]),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to take photo of ID',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.grey[600],
                                    ),
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
              ],
            ),
          ),

        // No Consent Reason (if consent is false)
        if (widget.details.consentToTakePhoto == false)
          _buildQuestionCard(
            child: _buildTextField(
              label: 'Reason for not providing photo',
              controller: _noConsentReasonController,
              hintText: 'Please specify reason',
              maxLines: 2,
            ),
          ),

        // Relationship to Respondent
        _buildQuestionCard(
          child: Column(
            children: [
              _buildDropdownField(
                label: 'Relationship to respondent (Farmer/Manager/Caretaker)',
                value: widget.details.relationshipToRespondent,
                items: [
                  {'value': 'husband_wife', 'label': 'Husband/Wife'},
                  {'value': 'son_daughter', 'label': 'Son/Daughter'},
                  {'value': 'brother_sister', 'label': 'Brother/Sister'},
                  {
                    'value': 'son_in_law_daughter_in_law',
                    'label': 'Son-in-law/Daughter-in-law'
                  },
                  {
                    'value': 'grandson_granddaughter',
                    'label': 'Grandson/Granddaughter'
                  },
                  {'value': 'niece_nephew', 'label': 'Niece/Nephew'},
                  {'value': 'cousin', 'label': 'Cousin'},
                  {
                    'value': 'workers_family_member',
                    'label': "Worker's family member"
                  },
                  {'value': 'worker', 'label': 'Worker'},
                  {'value': 'father_mother', 'label': 'Father/Mother'},
                  {'value': 'other', 'label': 'Other (specify)'},
                ],
                onChanged: (value) {
                  setState(() {
                    widget.onDetailsUpdated(widget.details.copyWith(
                      relationshipToRespondent: value,
                      otherRelationship: value == 'other' ? '' : null,
                    ));
                  });
                },
              ),
              if (widget.details.relationshipToRespondent == 'other') ...[
                const SizedBox(height: _Spacing.md),
                _buildTextField(
                  label: 'If Other, please specify',
                  controller: _otherRelationshipController,
                  hintText: 'Enter relationship',
                ),
              ],
            ],
          ),
        ),

        // Birth Certificate
        _buildQuestionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Does ${widget.personName} have a birth certificate?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: _Spacing.sm),
              Wrap(
                spacing: 20,
                children: [
                  _buildRadioOption(
                    value: 'yes',
                    groupValue: widget.details.hasBirthCertificate,
                    label: 'Yes',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(widget.details
                            .copyWith(hasBirthCertificate: value));
                      });
                    },
                  ),
                  _buildRadioOption(
                    value: 'no',
                    groupValue: widget.details.hasBirthCertificate,
                    label: 'No',
                    onChanged: (value) {
                      setState(() {
                        widget.onDetailsUpdated(widget.details
                            .copyWith(hasBirthCertificate: value));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Occupation
        _buildQuestionCard(
          child: Column(
            children: [
              _buildDropdownField(
                label: 'Work/main occupation',
                value: widget.details.occupation,
                items: [
                  {'value': 'Farmer (cocoa)', 'label': 'Farmer (cocoa)'},
                  {'value': 'Farmer (coffee)', 'label': 'Farmer (coffee)'},
                  {'value': 'Farmer (other)', 'label': 'Farmer (other)'},
                  {'value': 'Merchant', 'label': 'Merchant'},
                  {'value': 'Student', 'label': 'Student'},
                  {
                    'value': 'Other (to specify)',
                    'label': 'Other (to specify)'
                  },
                  {'value': 'No activity', 'label': 'No activity'},
                ],
                onChanged: (value) {
                  setState(() {
                    widget.onDetailsUpdated(widget.details.copyWith(
                      occupation: value,
                      otherOccupation:
                          value == 'Other (to specify)' ? '' : null,
                    ));
                  });
                },
              ),
              if (widget.details.occupation == 'Other (to specify)') ...[
                const SizedBox(height: _Spacing.md),
                _buildTextField(
                  label: 'If other, please specify',
                  controller: _otherOccupationController,
                  hintText: 'Enter occupation',
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: _Spacing.md),
      ],
    );
  }
}