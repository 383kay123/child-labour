import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../theme/app_theme.dart';
import '../../producer_details_page.dart';

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
  final List<Map<String, String>> _nationalityOptions = [
    {'value': 'Burkina Faso', 'display': 'Burkina Faso'},
    {'value': 'Mali', 'display': 'Mali'},
    {'value': 'Guinea', 'display': 'Guinea'},
    {'value': 'Togo', 'display': 'Togo'},
    {'value': 'Cote d\'Ivoire', 'display': 'Cote d\'Ivoire'},
    {'value': 'Niger', 'display': 'Niger'},
    {'value': 'Nigeria', 'display': 'Nigeria'},
    {'value': 'Benin', 'display': 'Benin'},
    {'value': 'Other', 'display': 'Other'},
  ];
  String? _selectedNationality;
  final TextEditingController _otherNationalityController =
      TextEditingController();
  int? _numberOfAdults;
  String? _isGhanaCitizen;
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _ghanaCardIdControllers = [];
  final List<bool?> _hasGhanaCard = [];
  final TextEditingController _nationalityController = TextEditingController();

  bool _isNameValid(String name) {
    return name.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _adultsCountController.addListener(_onCountChanged);
    _nationalityController.text = _selectedNationality ?? '';
    _loadSavedData();
  }

  // Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isGhanaCitizen = prefs.getString('isGhanaCitizen');
      });
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    }
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isGhanaCitizen != null) {
        await prefs.setString('isGhanaCitizen', _isGhanaCitizen!);
      }
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
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
      });
      return;
    }

    // Dispose old controllers
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _ghanaCardIdControllers) {
      controller.dispose();
    }

    // Create new controllers
    _nameControllers.clear();
    _ghanaCardIdControllers.clear();
    _hasGhanaCard.clear();

    for (int i = 0; i < count; i++) {
      _nameControllers.add(TextEditingController());
      _ghanaCardIdControllers.add(TextEditingController());
      _hasGhanaCard.add(null);
    }

    setState(() {
      _numberOfAdults = count;
    });
  }

  @override
  void dispose() {
    _adultsCountController.removeListener(_onCountChanged);
    _adultsCountController.dispose();
    _otherNationalityController.dispose();
    _nationalityController.dispose();

    for (var controller in _nameControllers) {
      controller.dispose();
    }

    for (var controller in _ghanaCardIdControllers) {
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
              horizontal: _Spacing.lg,
              vertical: _Spacing.md,
            ),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
          validator: validator,
        ),
      ],
    );
  }

  bool get _isFormComplete {
    if (_numberOfAdults == null || _numberOfAdults == 0) return false;
    if (_isGhanaCitizen == null) return false;
    if (_isGhanaCitizen == 'No' && _selectedNationality == null) return false;
    if (_isGhanaCitizen == 'No' &&
        _selectedNationality == 'Other' &&
        _otherNationalityController.text.isEmpty) return false;

    // Check all names are filled
    for (int i = 0; i < _nameControllers.length; i++) {
      if (_nameControllers[i].text.trim().isEmpty) return false;
    }

    return true;
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate() && _isFormComplete) {
      final count = _numberOfAdults ?? 0;

      if (count == 0) {
        Navigator.pop(context, {'count': 0, 'names': []});
        return;
      }

      // Validate that all name fields are filled
      bool allNamesFilled = true;
      final names = <String>[];

      for (int i = 0; i < _nameControllers.length; i++) {
        final name = _nameControllers[i].text.trim();
        if (name.isEmpty) {
          allNamesFilled = false;
          break;
        }
        names.add(name);
      }

      if (!allNamesFilled || names.length != count) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter names for all household members'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      // Prepare list of adult details including Ghana Card information
      final List<Map<String, dynamic>> adultDetails = [];
      for (int i = 0; i < _nameControllers.length; i++) {
        adultDetails.add({
          'name': _nameControllers[i].text.trim(),
          'hasGhanaCard': _hasGhanaCard[i] == true,
          'ghanaCardId': _hasGhanaCard[i] == true
              ? _ghanaCardIdControllers[i].text.trim()
              : null,
        });
      }

      // Navigate to next page or return data
      // Navigator.push(...);
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

                    // // Citizenship question
                    // if (_numberOfAdults != null && _numberOfAdults! > 0)
                    //   _buildQuestionCard(
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           'Are all household members Ghanaian citizens?',
                    //           style: theme.textTheme.titleMedium?.copyWith(
                    //             color: isDark
                    //                 ? AppTheme.darkTextSecondary
                    //                 : AppTheme.textPrimary,
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //         const SizedBox(height: _Spacing.md),
                    //         Wrap(
                    //           spacing: 20,
                    //           children: [
                    //             _buildRadioOption(
                    //               value: 'Yes',
                    //               groupValue: _isGhanaCitizen,
                    //               label: 'Yes',
                    //               onChanged: (value) {
                    //                 setState(() {
                    //                   _isGhanaCitizen = value;
                    //                   if (value == 'Yes') {
                    //                     _nationalityController.clear();
                    //                   }
                    //                   _saveData(); // Save the selection
                    //                 });
                    //               },
                    //             ),
                    //             _buildRadioOption(
                    //               value: 'No',
                    //               groupValue: _isGhanaCitizen,
                    //               label: 'No',
                    //               onChanged: (value) {
                    //                 setState(() {
                    //                   _isGhanaCitizen = value;
                    //                 });
                    //               },
                    //             ),
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //
                    // // Nationality for non-Ghanaian
                    // if (_isGhanaCitizen == 'No')
                    //   Column(
                    //     children: [
                    //       _buildQuestionCard(
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               'Nationality',
                    //               style: Theme.of(context)
                    //                   .textTheme
                    //                   .titleMedium
                    //                   ?.copyWith(
                    //                     color: Theme.of(context).brightness ==
                    //                             Brightness.dark
                    //                         ? AppTheme.darkTextSecondary
                    //                         : AppTheme.textPrimary,
                    //                     fontWeight: FontWeight.w500,
                    //                   ),
                    //             ),
                    //             const SizedBox(height: _Spacing.md),
                    //             DropdownButtonFormField<String>(
                    //               value: _selectedNationality,
                    //               decoration: InputDecoration(
                    //                 border: OutlineInputBorder(
                    //                   borderRadius: BorderRadius.circular(8.0),
                    //                   borderSide: BorderSide(
                    //                     color: Theme.of(context).brightness ==
                    //                             Brightness.dark
                    //                         ? AppTheme.darkCard
                    //                         : Colors.grey.shade300,
                    //                   ),
                    //                 ),
                    //                 filled: true,
                    //                 fillColor: Theme.of(context).brightness ==
                    //                         Brightness.dark
                    //                     ? AppTheme.darkCard
                    //                     : Colors.white,
                    //                 contentPadding: const EdgeInsets.symmetric(
                    //                   horizontal: _Spacing.lg,
                    //                   vertical: _Spacing.md,
                    //                 ),
                    //               ),
                    //               hint: const Text('Select nationality'),
                    //               items: _nationalityOptions.map((option) {
                    //                 return DropdownMenuItem<String>(
                    //                   value: option['value'],
                    //                   child: Text(option['display']!),
                    //                 );
                    //               }).toList(),
                    //               onChanged: (value) {
                    //                 setState(() {
                    //                   _selectedNationality = value;
                    //                 });
                    //               },
                    //               validator: (value) {
                    //                 if (_isGhanaCitizen == 'No' &&
                    //                     value == null) {
                    //                   return 'Please select a nationality';
                    //                 }
                    //                 return null;
                    //               },
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       if (_selectedNationality == 'Other')
                    //         _buildQuestionCard(
                    //           child: _buildTextField(
                    //             label: 'Specify other nationality',
                    //             controller: _otherNationalityController,
                    //             hintText: 'Enter nationality',
                    //           ),
                    //         ),
                    //     ],
                    //   ),

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

                    // Individual household member cards
                    if (_numberOfAdults != null && _numberOfAdults! > 0)
                      ...List.generate(_numberOfAdults!, (index) {
                        return Column(
                          children: [
                            _buildQuestionCard(
                              child: _buildTextField(
                                label:
                                    'Full Name of Household Member ${index + 1}',
                                controller: _nameControllers[index],
                                hintText: 'Enter first and last name',
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

                            // Producer details card
                            Opacity(
                              opacity:
                                  _isNameValid(_nameControllers[index].text)
                                      ? 1.0
                                      : 0.5,
                              child: GestureDetector(
                                onTap: () {
                                  if (_isNameValid(
                                      _nameControllers[index].text)) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProducerDetailsPage(
                                          personName:
                                              _nameControllers[index].text,
                                          onSave: (details) {
                                            // Handle saving the details
                                            print(
                                                'Saved details for ${_nameControllers[index].text}: $details');
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(
                                      bottom: _Spacing.lg),
                                  color:
                                      _isNameValid(_nameControllers[index].text)
                                          ? AppTheme.primaryColor
                                              .withOpacity(0.1)
                                          : Colors.grey.shade200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    side: BorderSide(
                                      color: _isNameValid(
                                              _nameControllers[index].text)
                                          ? AppTheme.primaryColor
                                              .withOpacity(0.3)
                                          : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(_Spacing.lg),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                                  ? AppTheme.primaryColor
                                                  : Colors.grey.shade600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: _isNameValid(
                                                  _nameControllers[index].text)
                                              ? AppTheme.primaryColor
                                              : Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),
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
        ],
      ),
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
                onPressed: _isFormComplete
                    ? () {
                        try {
                          _saveAndContinue();
                          // Navigate to next page if needed
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => NextPage(),
                          //   ),
                          // );
                        } catch (e) {
                          debugPrint('Navigation error: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Could not proceed. Please try again.'),
                                backgroundColor: Colors.red.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        }
                      }
                    : null,
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
                    Icon(
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
