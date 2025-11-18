import 'dart:io';

import 'package:flutter/material.dart';
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

class AdultsInformationPage extends StatefulWidget {
  const AdultsInformationPage({super.key});

  @override
  State<AdultsInformationPage> createState() => _AdultsInformationPageState();
}

class _AdultsInformationPageState extends State<AdultsInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adultsCountController = TextEditingController();
  int? _numberOfAdults;

  // Lists to store data for each household member
  final List<TextEditingController> _nameControllers = [];
  final List<bool> _isNameValidList = [];
  final List<bool> _showProducerDetailsList =
      []; // Track which members have expanded details

  // Producer details for each household member
  final List<ProducerDetails> _producerDetailsList = [];

  @override
  void initState() {
    super.initState();
    _adultsCountController.addListener(_onCountChanged);
  }

  void _onCountChanged() {
    final value = _adultsCountController.text;
    final count = int.tryParse(value);
    if (count != _numberOfAdults) {
      _updateNameFields(count);
    }
  }

  void _updateNameFields(int? count) {
    if (count == null) {
      setState(() {
        _numberOfAdults = null;
        _isNameValidList.clear();
        _showProducerDetailsList.clear();
        _producerDetailsList.clear();
      });
      return;
    }

    // Dispose old controllers and clear lists
    for (var controller in _nameControllers) {
      controller.dispose();
    }

    _nameControllers.clear();
    _isNameValidList.clear();
    _showProducerDetailsList.clear();
    _producerDetailsList.clear();

    // Initialize all lists with the correct count
    for (int i = 0; i < count; i++) {
      _nameControllers.add(TextEditingController()
        ..addListener(() {
          _updateNameValidity(i, _nameControllers[i].text);
        }));
      _isNameValidList.add(false);
      _showProducerDetailsList.add(false);
      _producerDetailsList.add(ProducerDetails());
    }

    setState(() {
      _numberOfAdults = count;
    });
  }

  void _updateNameValidity(int index, String value) {
    final isValid = _isNameValid(value);
    if (index < _isNameValidList.length && _isNameValidList[index] != isValid) {
      setState(() {
        _isNameValidList[index] = isValid;
      });
    }
  }

  bool _isNameValid(String name) {
    return name.trim().isNotEmpty && name.trim().split(' ').length >= 2;
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

  void _updateProducerDetails(int index, ProducerDetails details) {
    if (index < _producerDetailsList.length) {
      setState(() {
        _producerDetailsList[index] = details;
      });
    }
  }

  @override
  void dispose() {
    _adultsCountController.removeListener(_onCountChanged);
    _adultsCountController.dispose();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool? isValid,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.xs),
        TextFormField(
          controller: controller,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
            ),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: (isValid == true)
                    ? Colors.green.shade400
                    : (isDark ? AppTheme.darkCard : Colors.grey.shade300),
                width: (isValid == true) ? 2.0 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: (isValid == true)
                    ? Colors.green.shade600
                    : (isDark ? AppTheme.primaryColor : AppTheme.primaryColor),
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _Spacing.lg,
              vertical: _Spacing.md,
            ),
            suffixIcon: (isValid == true)
                ? Icon(Icons.check_circle, color: Colors.green.shade600)
                : null,
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  bool get _isFormComplete {
    // If no adults, form is complete
    if (_numberOfAdults == null || _numberOfAdults == 0) return true;
    
    // Check if all names are valid (if provided)
    for (int i = 0; i < _nameControllers.length; i++) {
      if (_nameControllers[i].text.trim().isNotEmpty && 
          !_isNameValid(_nameControllers[i].text)) {
        return false;
      }
    }
    return true;
  }

  bool _isProducerDetailsComplete(ProducerDetails details) {
    // All fields are optional, but if provided, they should be valid
    return true;
  }

  bool _isGhanaCardComplete(ProducerDetails details) {
    // All fields are optional
    return true;
  }

  bool _isConsentComplete(ProducerDetails details) {
    // All fields are optional
    return true;
  }

  void _saveAndContinue() {
    // Always allow saving, but validate what's there
    if (_formKey.currentState!.validate()) {
      // Prepare data for submission
      final householdData = {
        'numberOfAdults': _numberOfAdults,
        'members': List.generate(_numberOfAdults!, (index) {
          return {
            'name': _nameControllers[index].text.trim(),
            'producerDetails': _producerDetailsList[index].toMap(),
          };
        }),
      };

      print('Household Data: $householdData');

      // Navigate to ChildrenHouseholdPage with the collected data
      // This navigation should be handled by the parent widget's page controller
      // The parent widget should manage the page navigation
      if (mounted) {
        // Instead of pushing a new route, we should call the parent's onNext
        // This assumes the parent widget is managing the page controller
        // and will handle the navigation to the next page
        // If this is not the case, you'll need to pass the onNext callback from the parent
        Navigator.of(context).pop(householdData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Information on Adults in Household',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_Spacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Number of adults input
                    _buildQuestionCard(
                      child: _buildTextField(
                        label: 'Total number of adults in the household'
                            '(Producer/manager/owner not included). '
                            'Include the manager\'s family only if they live in the producer\'s household. *',
                        controller: _adultsCountController,
                        hintText: 'Enter number of adults',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number';
                          }
                          final number = int.tryParse(value);
                          if (number == null) {
                            return 'Please enter a valid number';
                          }
                          if (number < 0) {
                            return 'Number cannot be negative';
                          }
                          if (number > 50) {
                            return 'Please enter a reasonable number';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Household members section header
                    if (_numberOfAdults != null && _numberOfAdults! > 0) ...[
                      _buildQuestionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full name of household members',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: _Spacing.sm),
                            Text(
                              'List all members of the producer\'s household. Do not include the manager/farmer. Include the manager\'s family only if they live in the producer\'s household. Write the first and last names of household members.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Individual household member cards with integrated producer details
                    if (_numberOfAdults != null && _numberOfAdults! > 0)
                      ...List.generate(_numberOfAdults!, (index) {
                        // Add safety checks to prevent index errors
                        if (index >= _nameControllers.length ||
                            index >= _isNameValidList.length ||
                            index >= _showProducerDetailsList.length ||
                            index >= _producerDetailsList.length) {
                          return const SizedBox
                              .shrink(); // Return empty widget if index is invalid
                        }

                        return Column(
                          children: [
                            _buildQuestionCard(
                              child: _buildTextField(
                                label:
                                    'Full Name of Household Member ${index + 1}',
                                controller: _nameControllers[index],
                                hintText: 'Enter first and last name',
                                isValid: _isNameValidList[index],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the household member\'s full name';
                                  }
                                  final nameParts = value.trim().split(' ');
                                  if (nameParts.length < 2) {
                                    return 'Please enter both first and last name';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Please enter a valid name';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            // Producer details section - now integrated
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: Card(
                                margin:
                                    const EdgeInsets.only(bottom: _Spacing.lg),
                                color:
                                    _isNameValid(_nameControllers[index].text)
                                        ? (isDark
                                            ? Colors.green.shade900
                                                .withOpacity(0.3)
                                            : Colors.green.shade50)
                                        : (isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: BorderSide(
                                    color: _isNameValid(
                                            _nameControllers[index].text)
                                        ? Colors.green.shade300
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Header - clickable to expand/collapse
                                    // In the build method, replace the ListTile in the producer details section:
                                    ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'PRODUCER DETAILS - ${_nameControllers[index].text.isNotEmpty ? _nameControllers[index].text.toUpperCase() : 'ENTER FULL NAME'}',
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: _isNameValid(
                                                        _nameControllers[index]
                                                            .text)
                                                    ? Colors.green.shade800
                                                    : Colors.grey.shade600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          // Add completion indicator
                                          if (_isNameValid(
                                              _nameControllers[index].text))
                                            Icon(
                                              _isProducerDetailsComplete(
                                                      _producerDetailsList[
                                                          index])
                                                  ? Icons.check_circle
                                                  : Icons.error,
                                              color: _isProducerDetailsComplete(
                                                      _producerDetailsList[
                                                          index])
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
                                        color: _isNameValid(
                                                _nameControllers[index].text)
                                            ? Colors.green.shade800
                                            : Colors.grey.shade600,
                                      ),
                                      onTap: () =>
                                          _toggleProducerDetails(index),
                                    ),

                                    // Producer details form (expanded content)
                                    if (_showProducerDetailsList[index] &&
                                        _isNameValid(
                                            _nameControllers[index].text))
                                      Padding(
                                        padding:
                                            const EdgeInsets.all(_Spacing.lg),
                                        child: ProducerDetailsForm(
                                          personName:
                                              _nameControllers[index].text,
                                          details: _producerDetailsList[index],
                                          onDetailsUpdated: (details) =>
                                              _updateProducerDetails(
                                                  index, details),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    const SizedBox(height: 80), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
          // Add this widget here (moved from outside the Expanded)
          if (_numberOfAdults != null &&
              _numberOfAdults! > 0 &&
              !_isFormComplete)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: _Spacing.lg, vertical: _Spacing.sm),
              child: Text(
                'Please complete all producer details for all household members to continue',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade700,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),

      // Add this widget before the bottom navigation bar in the build method:

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(_Spacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Previous Button
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.green.shade600, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: _Spacing.md),
            // Next Button
            Expanded(
              child: ElevatedButton(
                onPressed: _isFormComplete ? _saveAndContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormComplete
                      ? Colors.green.shade600
                      : Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: Colors.green.shade600.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Producer Details Data Class
class ProducerDetails {
  String? gender;
  String? nationality;
  int? yearOfBirth;
  String? selectedCountry;
  String? ghanaCardId;
  String? otherIdType;
  String? otherIdNumber;
  bool? consentToTakePhoto;
  String? noConsentReason;
  File? idPhoto;
  String? relationshipToRespondent;
  String? otherRelationship;
  String? hasBirthCertificate;
  String? occupation;
  String? otherOccupation;

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'nationality': nationality,
      'yearOfBirth': yearOfBirth,
      'selectedCountry': selectedCountry,
      'ghanaCardId': ghanaCardId,
      'otherIdType': otherIdType,
      'otherIdNumber': otherIdNumber,
      'consentToTakePhoto': consentToTakePhoto,
      'noConsentReason': noConsentReason,
      'idPhotoPath': idPhoto?.path,
      'relationshipToRespondent': relationshipToRespondent,
      'otherRelationship': otherRelationship,
      'hasBirthCertificate': hasBirthCertificate,
      'occupation': occupation,
      'otherOccupation': otherOccupation,
    };
  }
}

// Producer Details Form Widget
class ProducerDetailsForm extends StatefulWidget {
  final String personName;
  final ProducerDetails details;
  final Function(ProducerDetails) onDetailsUpdated;

  const ProducerDetailsForm({
    super.key,
    required this.personName,
    required this.details,
    required this.onDetailsUpdated,
  });

  @override
  State<ProducerDetailsForm> createState() => _ProducerDetailsFormState();
}

class _ProducerDetailsFormState extends State<ProducerDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  String? _gender;
  String? _nationality;
  final TextEditingController _yearOfBirthController = TextEditingController();
  DateTime? _selectedDate;
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
  String? _hasGhanaCard;
  String? _selectedIdType;
  bool? _consentToTakePhoto;
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

  @override
  void initState() {
    super.initState();
    // Initialize form with existing details if any
    _initializeForm();
  }

  void _initializeForm() {
    // Initialize all form fields with widget.details values
    _gender = widget.details.gender;
    _nationality = widget.details.nationality;
    if (widget.details.yearOfBirth != null) {
      _yearOfBirthController.text = widget.details.yearOfBirth.toString();
      _selectedDate = DateTime(widget.details.yearOfBirth!);
    }
    _selectedCountry = widget.details.selectedCountry;
    _ghanaCardIdController.text = widget.details.ghanaCardId ?? '';
    _otherIdController.text = widget.details.otherIdNumber ?? '';
    _noConsentReasonController.text = widget.details.noConsentReason ?? '';
    _otherOccupationController.text = widget.details.otherOccupation ?? '';
    _otherRelationshipController.text = widget.details.otherRelationship ?? '';

    // Initialize Ghana Card state
    if (widget.details.ghanaCardId != null && widget.details.ghanaCardId!.isNotEmpty) {
      _hasGhanaCard = 'Yes';
    } else if (widget.details.otherIdType != null) {
      _hasGhanaCard = 'No';
    } else {
      _hasGhanaCard = null; // Start with no selection
    }
    
    _selectedIdType = widget.details.otherIdType;
    _consentToTakePhoto = widget.details.consentToTakePhoto;
    _idPhoto = widget.details.idPhoto;
    _relationshipToRespondent = widget.details.relationshipToRespondent;
    _hasBirthCertificate = widget.details.hasBirthCertificate;
    _selectedOccupation = widget.details.occupation;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _yearOfBirthController.text = picked.year.toString();
        _updateParentDetails();
      });
    }
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

  void _updateParentDetails() {
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

    final details = ProducerDetails()
      ..gender = _gender
      ..nationality = _nationality
      ..yearOfBirth = yearOfBirth
      ..selectedCountry = _selectedCountry == 'Other (specify)'
          ? _otherCountryController.text
          : _selectedCountry
      ..ghanaCardId =
          _hasGhanaCard == 'Yes' ? _ghanaCardIdController.text : null
      ..otherIdType = _hasGhanaCard == 'No' ? _selectedIdType : null
      ..otherIdNumber = _hasGhanaCard == 'No' ? _otherIdController.text : null
      ..consentToTakePhoto = _consentToTakePhoto
      ..noConsentReason =
          _consentToTakePhoto == false ? _noConsentReasonController.text : null
      ..idPhoto = _idPhoto
      ..relationshipToRespondent = _relationshipToRespondent
      ..otherRelationship = _relationshipToRespondent == 'other'
          ? _otherRelationshipController.text
          : null
      ..hasBirthCertificate = _hasBirthCertificate
      ..occupation = occupation
      ..otherOccupation = _selectedOccupation == 'Other (to specify)'
          ? _otherOccupationController.text
          : null;

    widget.onDetailsUpdated(details);
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
      color: isDark ? AppTheme.darkCard : Colors.white,
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

    return RadioListTile<String>(
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
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
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    VoidCallback? onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (value) {
            onChanged?.call();
            _updateParentDetails();
          },
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
              horizontal: _Spacing.md,
              vertical: _Spacing.sm,
            ),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
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
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _Spacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
            ),
            color: isDark ? AppTheme.darkCard : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: _Spacing.md),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select an option',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark 
                      ? Colors.grey.shade400 
                      : Colors.grey.shade600,
                ),
              ),
              icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
              iconSize: 20,
              elevation: 16,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
              onChanged: (newValue) {
                // Only update if the value has actually changed
                if (newValue != value) {
                  onChanged(newValue);
                  // Update parent details when selection changes
                  _updateParentDetails();
                }
              },
              dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((Map<String, String> item) {
                  return Text(
                    item['label']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                }).toList();
              },
              items: items.map<DropdownMenuItem<String>>((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(
                    item['label']!,
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
    return Form(
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
                  'Does ${widget.personName} have a Ghana card?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: _Spacing.sm),
                Row(
                  children: [
                    _buildRadioOption(
                      value: 'Yes',
                      groupValue: _hasGhanaCard,
                      label: 'Yes',
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _hasGhanaCard = value;
                          _selectedIdType = null;
                          _otherIdController.clear();
                          _ghanaCardIdController.clear();
                          _updateParentDetails();
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildRadioOption(
                      value: 'No',
                      groupValue: _hasGhanaCard,
                      label: 'No',
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _hasGhanaCard = value;
                          _ghanaCardIdController.clear();
                          _updateParentDetails();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ghana Card ID (shown when 'Yes' is selected)
          if (_hasGhanaCard == 'Yes')
            _buildQuestionCard(
              child: _buildTextField(
                label: 'Ghana Card ID',
                controller: _ghanaCardIdController,
                hintText: 'Enter Ghana Card ID',
              ),
            ),

          // Other ID Card (shown when 'No' is selected)
          if (_hasGhanaCard == 'No')
            _buildQuestionCard(
              child: Column(
                children: [
                  _buildDropdownField(
                    label: 'Which other national id card is available',
                    value: _selectedIdType,
                    items: idTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedIdType = value;
                        _otherIdController.clear(); // Clear the ID field when changing type
                        _updateParentDetails();
                      });
                    },
                  ),
                  if (_selectedIdType != null && _selectedIdType != 'none') ...[
                    const SizedBox(height: _Spacing.md),
                    _buildTextField(
                      label: 'ID Number',
                      controller: _otherIdController,
                      hintText: 'Enter ID number',
                    ),
                  ],
                ],
              ),
            ),

          // Show consent question if has Ghana card or any other national ID (not 'none')
          if ((_hasGhanaCard == 'Yes' && _selectedIdType != 'none') ||
              (_hasGhanaCard == 'No' &&
                  _selectedIdType != null &&
                  _selectedIdType != 'none'))
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
                        groupValue: _consentToTakePhoto == null
                            ? null
                            : (_consentToTakePhoto! ? 'Yes' : 'No'),
                        label: 'Yes',
                        onChanged: (value) {
                          setState(() {
                            _consentToTakePhoto = value == 'Yes';
                            _updateParentDetails();
                          });
                        },
                      ),
                      _buildRadioOption(
                        value: 'No',
                        groupValue: _consentToTakePhoto == null
                            ? null
                            : (_consentToTakePhoto! ? 'Yes' : 'No'),
                        label: 'No',
                        onChanged: (value) {
                          setState(() {
                            _consentToTakePhoto = value == 'Yes';
                            _updateParentDetails();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // ID Photo Section (shown when consent is given and has a valid ID type)
          if (_consentToTakePhoto == true &&
              ((_hasGhanaCard == 'Yes' && _selectedIdType != 'none') ||
                  (_hasGhanaCard == 'No' &&
                      _selectedIdType != null &&
                      _selectedIdType != 'none')))
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
                              ? AppTheme.darkCard
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkCard
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

          // No Consent Reason (shown when consent is not given)
          if (_consentToTakePhoto == false)
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
                  label:
                      'Relationship to respondent (Farmer/Manager/Caretaker)',
                  value: _relationshipToRespondent,
                  items: relationshipOptions,
                  onChanged: (value) {
                    if (value != _relationshipToRespondent) {
                      setState(() {
                        _relationshipToRespondent = value;
                        _otherRelationshipController.clear(); // Clear other field when changing relationship
                      });
                      _updateParentDetails(); // Ensure parent is updated with new value
                    }
                  },
                ),
                if (_relationshipToRespondent == 'other') ...[
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

          // Gender Selection
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
                      groupValue: _gender,
                      label: 'Male',
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'female',
                      groupValue: _gender,
                      label: 'Female',
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
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
                      groupValue: _nationality,
                      label: 'Ghanaian',
                      onChanged: (value) {
                        setState(() {
                          _nationality = value;
                          if (_nationality == 'ghanaian') {
                            _selectedCountry = null;
                            _otherCountryController.clear();
                          }
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'non_ghanaian',
                      groupValue: _nationality,
                      label: 'Non-Ghanaian',
                      onChanged: (value) {
                        setState(() {
                          _nationality = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Country of Origin (Conditional)
          if (_nationality == 'non_ghanaian')
            _buildQuestionCard(
              child: Column(
                children: [
                  _buildDropdownField(
                    label: 'If Non Ghanaian, specify country of origin',
                    value: _selectedCountry,
                    items: countries
                        .map((country) => {'value': country, 'label': country})
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                      });
                    },
                  ),
                  if (_selectedCountry == 'Other (specify)') ...[
                    const SizedBox(height: _Spacing.md),
                    _buildTextField(
                      label: 'If other please specify',
                      controller: _otherCountryController,
                      hintText: 'Enter country name',
                    ),
                  ],
                ],
              ),
            ),

          // Year of Birth
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Year of Birth',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: _Spacing.sm),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.year}'
                          : 'Select year of birth',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _selectedDate != null
                                ? null
                                : Theme.of(context).hintColor,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Birth Certificate Question
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
                      groupValue: _hasBirthCertificate,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          _hasBirthCertificate = value;
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'no',
                      groupValue: _hasBirthCertificate,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          _hasBirthCertificate = value;
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
                  value: _selectedOccupation,
                  items: _occupationOptions
                      .map((occupation) =>
                          {'value': occupation, 'label': occupation})
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedOccupation = value;
                    });
                  },
                ),
                if (_selectedOccupation == 'Other (to specify)') ...[
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
        ],
      ),
    );
  }
}