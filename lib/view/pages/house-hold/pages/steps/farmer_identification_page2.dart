import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';

class FarmerIdentificationPage extends StatefulWidget {
  const FarmerIdentificationPage({super.key});

  @override
  State<FarmerIdentificationPage> createState() => _FarmerIdentificationPageState();
}

class _FarmerIdentificationPageState extends State<FarmerIdentificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  
  // Visit Information Section
  String? _respondentNameCorrect;
  String? _respondentNationality;
  String? _countryOfOrigin;
  String? _isFarmOwner;
  final TextEditingController _respondentNameController = TextEditingController();
  final TextEditingController _otherCountryController = TextEditingController();
  
  // Owner Identification Section
  final TextEditingController _ownerNameController = TextEditingController();
  String? _ownerGender;
  String? _ownerMaritalStatus;
  String? _ownerEducationLevel;
  
  // Workers in Farm Section
  bool _hasWorkers = false;
  final TextEditingController _numberOfWorkersController = TextEditingController();
  final TextEditingController _workersUnder18Controller = TextEditingController();
  
  // Adult Household Section
  final TextEditingController _adultNameController = TextEditingController();
  String? _adultGender;
  String? _adultRelationship;
  String? _adultEducationLevel;

  // Country list
  final List<Map<String, String>> _countries = [
    {'value': 'Burkina Faso', 'display': 'Burkina Faso'},
    {'value': 'Mali', 'display': 'Mali'},
    {'value': 'Guinea', 'display': 'Guinea'},
    {'value': 'Ivory Coast', 'display': 'Ivory Coast'},
    {'value': 'Liberia', 'display': 'Liberia'},
    {'value': 'other', 'display': 'Other (specify)'},
  ];

  // Gender options
  final List<Map<String, String>> _genderOptions = [
    {'value': 'male', 'display': 'Male'},
    {'value': 'female', 'display': 'Female'},
    {'value': 'other', 'display': 'Other'},
  ];

  // Marital status options
  final List<Map<String, String>> _maritalStatusOptions = [
    {'value': 'single', 'display': 'Single'},
    {'value': 'married', 'display': 'Married'},
    {'value': 'divorced', 'display': 'Divorced'},
    {'value': 'widowed', 'display': 'Widowed'},
  ];

  // Education level options
  final List<Map<String, String>> _educationLevels = [
    {'value': 'none', 'display': 'No formal education'},
    {'value': 'primary', 'display': 'Primary'},
    {'value': 'secondary', 'display': 'Secondary'},
    {'value': 'tertiary', 'display': 'Tertiary'},
  ];

  @override
  void dispose() {
    _respondentNameController.dispose();
    _otherCountryController.dispose();
    _ownerNameController.dispose();
    _numberOfWorkersController.dispose();
    _workersUnder18Controller.dispose();
    _adultNameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) { // 4 pages (0-3)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save form data
      print('Form submitted successfully');
      // Navigate to next screen or show success message
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Identification'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Page indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index 
                          ? AppTheme.primaryColor 
                          : Colors.grey,
                    ),
                  );
                }),
              ),
            ),
            
            // Main form content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Page 1: Visit Information
                  _buildVisitInformationSection(theme, isDark),
                  
                  // Page 2: Owner Identification
                  _buildOwnerIdentificationSection(theme, isDark),
                  
                  // Page 3: Workers in Farm
                  _buildWorkersSection(theme, isDark),
                  
                  // Page 4: Adult Household
                  _buildAdultHouseholdSection(theme, isDark),
                ],
              ),
            ),
            
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppTheme.primaryColor),
                        ),
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage < 3 ? _nextPage : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentPage < 3 ? 'Continue' : 'Submit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the Visit Information section
  Widget _buildVisitInformationSection(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1. Information on the visit',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Respondent name field
          TextFormField(
            controller: _respondentNameController,
            decoration: InputDecoration(
              labelText: 'Respondent Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter respondent name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Is respondent name correct?
          Text(
            'Is the respondent name correct?',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          Row(
            children: [
              Radio<String>(
                value: 'yes',
                groupValue: _respondentNameCorrect,
                onChanged: (value) {
                  setState(() {
                    _respondentNameCorrect = value;
                  });
                },
              ),
              const Text('Yes'),
              const SizedBox(width: 20),
              Radio<String>(
                value: 'no',
                groupValue: _respondentNameCorrect,
                onChanged: (value) {
                  setState(() {
                    _respondentNameCorrect = value;
                  });
                },
              ),
              const Text('No'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Nationality
          Text(
            'Nationality',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          ..._countries.map((country) {
            return RadioListTile<String>(
              title: Text(country['display']!),
              value: country['value']!,
              groupValue: _respondentNationality,
              onChanged: (value) {
                setState(() {
                  _respondentNationality = value;
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
          
          if (_respondentNationality == 'other')
            TextFormField(
              controller: _otherCountryController,
              decoration: const InputDecoration(
                labelText: 'Please specify country',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_respondentNationality == 'other' && (value == null || value.isEmpty)) {
                  return 'Please specify country';
                }
                return null;
              },
            ),
          
          const SizedBox(height: 16),
          
          // Is farm owner?
          Text(
            'Is the respondent the farm owner?',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          Row(
            children: [
              Radio<String>(
                value: 'yes',
                groupValue: _isFarmOwner,
                onChanged: (value) {
                  setState(() {
                    _isFarmOwner = value;
                  });
                },
              ),
              const Text('Yes'),
              const SizedBox(width: 20),
              Radio<String>(
                value: 'no',
                groupValue: _isFarmOwner,
                onChanged: (value) {
                  setState(() {
                    _isFarmOwner = value;
                  });
                },
              ),
              const Text('No'),
            ],
          ),
        ],
      ),
    );
  }

  // Build the Owner Identification section
  Widget _buildOwnerIdentificationSection(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2. Identification of the Owner',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Owner name field
          TextFormField(
            controller: _ownerNameController,
            decoration: InputDecoration(
              labelText: 'Owner Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter owner name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Owner gender
          Text(
            'Gender',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          ..._genderOptions.map((gender) {
            return RadioListTile<String>(
              title: Text(gender['display']!),
              value: gender['value']!,
              groupValue: _ownerGender,
              onChanged: (value) {
                setState(() {
                  _ownerGender = value;
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          // Marital status
          Text(
            'Marital Status',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          ..._maritalStatusOptions.map((status) {
            return RadioListTile<String>(
              title: Text(status['display']!),
              value: status['value']!,
              groupValue: _ownerMaritalStatus,
              onChanged: (value) {
                setState(() {
                  _ownerMaritalStatus = value;
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          // Education level
          Text(
            'Education Level',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          ..._educationLevels.map((level) {
            return RadioListTile<String>(
              title: Text(level['display']!),
              value: level['value']!,
              groupValue: _ownerEducationLevel,
              onChanged: (value) {
                setState(() {
                  _ownerEducationLevel = value;
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
        ],
      ),
    );
  }

  // Build the Workers in Farm section
  Widget _buildWorkersSection(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3. Workers in the farm',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Does the farm have workers?
          Text(
            'Does the farm have any workers?',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _hasWorkers,
                onChanged: (value) {
                  setState(() {
                    _hasWorkers = value ?? false;
                  });
                },
              ),
              const Text('Yes'),
              const SizedBox(width: 20),
              Radio<bool>(
                value: false,
                groupValue: _hasWorkers,
                onChanged: (value) {
                  setState(() {
                    _hasWorkers = value ?? false;
                    _numberOfWorkersController.clear();
                    _workersUnder18Controller.clear();
                  });
                },
              ),
              const Text('No'),
            ],
          ),
          
          if (_hasWorkers) ...[
            const SizedBox(height: 16),
            
            // Number of workers
            TextFormField(
              controller: _numberOfWorkersController,
              decoration: InputDecoration(
                labelText: 'Number of workers',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_hasWorkers && (value == null || value.isEmpty)) {
                  return 'Please enter number of workers';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Workers under 18
            TextFormField(
              controller: _workersUnder18Controller,
              decoration: InputDecoration(
                labelText: 'Number of workers under 18 years old',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_hasWorkers) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of workers under 18';
                  }
                  final totalWorkers = int.tryParse(_numberOfWorkersController.text) ?? 0;
                  final under18 = int.tryParse(value) ?? 0;
                  if (under18 > totalWorkers) {
                    return 'Cannot exceed total number of workers';
                  }
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  // Build the Adult Household section
  Widget _buildAdultHouseholdSection(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '4. Adult of the respondent\'s household',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Adult name field
          TextFormField(
            controller: _adultNameController,
            decoration: InputDecoration(
              labelText: 'Adult Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter adult name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Adult gender
          Text(
            'Gender',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          ..._genderOptions.map((gender) {
            return RadioListTile<String>(
              title: Text(gender['display']!),
              value: gender['value']!,
              groupValue: _adultGender,
              onChanged: (value) {
                setState(() {
                  _adultGender = value;
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          // Relationship to respondent
          Text(
            'Relationship to Respondent',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _adultRelationship,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            hint: const Text('Select relationship'),
            items: const [
              DropdownMenuItem(value: 'spouse', child: Text('Spouse')),
              DropdownMenuItem(value: 'child', child: Text('Child')),
              DropdownMenuItem(value: 'parent', child: Text('Parent')),
              DropdownMenuItem(value: 'sibling', child: Text('Sibling')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                _adultRelationship = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select relationship';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Education level
          Text(
            'Education Level',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          ..._educationLevels.map((level) {
            return RadioListTile<String>(
              title: Text(level['display']!),
              value: level['value']!,
              groupValue: _adultEducationLevel,
              onChanged: (value) {
                setState(() {
                  _adultEducationLevel = value;
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
        ],
      ),
    );
  }
}
