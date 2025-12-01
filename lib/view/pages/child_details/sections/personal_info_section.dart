import 'package:flutter/material.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';
import 'package:human_rights_monitor/view/pages/child_details/widgets/custom_widgets/modern_checkbox.dart';
import 'base_section.dart';

class PersonalInfoSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController childNumberController;
  final TextEditingController birthYearController;
  final bool canBeSurveyedNow;
  final bool? isFarmerChild;
  final ValueChanged<String?>? onGenderChanged;
  final String? gender;
  final ValueChanged<bool?>? onBirthCertificateChanged;
  final bool? hasBirthCertificate;
  

  const PersonalInfoSection({
    Key? key,
    required this.nameController,
    required this.surnameController,
    required this.childNumberController,
    required this.birthYearController,
    required this.canBeSurveyedNow,
    this.onBirthCertificateChanged,
    this.isFarmerChild,
    this.onGenderChanged,
    this.gender,
    this.hasBirthCertificate,
  }) : super(key: key);

  @override
  _PersonalInfoSectionState createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  // Form controllers and state variables
  final List<String> _countries = [
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda', 'Argentina', 'Armenia', 
    'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 
    'Belize', 'Benin', 'Bhutan', 'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria', 
    'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cambodia', 'Cameroon', 'Canada', 'Central African Republic', 'Chad', 
    'Chile', 'China', 'Colombia', 'Comoros', 'Congo', 'Costa Rica', 'Croatia', 'Cuba', 'Cyprus', 'Czech Republic', 
    "Côte d'Ivoire", 'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 'Ecuador', 'Egypt', 'El Salvador', 
    'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia', 'Fiji', 'Finland', 'France', 'Gabon', 'Gambia', 
    'Georgia', 'Germany', 'Ghana', 'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana', 'Haiti', 
    'Honduras', 'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy', 'Jamaica', 
    'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 
    'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Madagascar', 'Malawi', 'Malaysia', 
    'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania', 'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 
    'Monaco', 'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar', 'Namibia', 'Nauru', 'Nepal', 
    'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Korea', 'North Macedonia', 'Norway', 'Oman', 
    'Pakistan', 'Palau', 'Palestine', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland', 
    'Portugal', 'Qatar', 'Romania', 'Russia', 'Rwanda', 'Saint Kitts and Nevis', 'Saint Lucia', 
    'Saint Vincent and the Grenadines', 'Samoa', 'San Marino', 'Sao Tome and Principe', 'Saudi Arabia', 'Senegal', 
    'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 
    'South Africa', 'South Korea', 'South Sudan', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname', 'Sweden', 'Switzerland', 
    'Syria', 'Tajikistan', 'Tanzania', 'Thailand', 'Timor-Leste', 'Togo', 'Tonga', 'Trinidad and Tobago', 'Tunisia', 
    'Turkey', 'Turkmenistan', 'Tuvalu', 'Uganda', 'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States', 
    'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe'
  ];

  Map<String, bool> _notLivingWithFamilyReasons = {
  'Parents are deceased': false,
  'Abandoned by parents': false,
  'Ran away from home': false,
  'Sent to work': false,
  'Other (specify)': false,
};
  bool? _hasBirthCertificate;
  bool? _bornInCommunity;
  String? _birthCountry;
  DateTime? _selectedDate;
  final TextEditingController _noBirthCertificateReasonController = TextEditingController();
  String? _relationshipToHead; 
  final TextEditingController _otherRelationshipController = TextEditingController();
  final TextEditingController _otherNotLivingWithFamilyController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    _hasBirthCertificate = widget.hasBirthCertificate;
    _bornInCommunity = true; // Default value, adjust as needed
  }

  @override
  void dispose() {
    _otherNotLivingWithFamilyController.dispose();
    _noBirthCertificateReasonController.dispose();
    _otherRelationshipController.dispose();
    super.dispose();
  }

  Widget _buildQuestionCard({required BuildContext context, required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }


  Widget _buildRadioOption({
    required BuildContext context,
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
    );
  }

  Widget _buildModernRadioGroup<T>({
    required BuildContext context,
    required String question,
    required T? groupValue,
    required ValueChanged<T>? onChanged,
    required List<Map<String, dynamic>> options,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: options.map((option) {
            final value = option['value'] as T;
            final label = option['title'] as String;

            return RadioListTile<T>(
              title: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                ),
              ),
              value: value,
              groupValue: groupValue,
              onChanged: onChanged != null 
                  ? (T? newValue) {
                      if (newValue != null) {
                        onChanged(newValue);
                      }
                    }
                  : null,
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModernCheckboxGroup({
    required String question,
    required Map<String, bool> values,
    required Function(String, bool?) onChanged,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
         style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
        ),
        const SizedBox(height: 8),
        ...values.entries.map((entry) {
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              entry.key,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppTheme.darkTextPrimary 
                    : AppTheme.textPrimary,
              ),
            ),
            value: entry.value,
            onChanged: (bool? value) => onChanged(entry.key, value),
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildModernTextField({
    required BuildContext context,
    required String label,
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? hintText,
    bool readOnly = false,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2010),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      initialDatePickerMode: DatePickerMode.year,
      builder: (BuildContext context, Widget? child) {
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
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      widget.birthYearController.text = picked.year.toString();
    }
  }

  Widget _buildModernDropdown<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>>? items,
    String? hint,
    String? Function(T?)? validator,
    void Function(T?)? onChanged,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
          items: items,
          validator: validator,
          onChanged: onChanged,
          isExpanded: true,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          dropdownColor: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseSection(
      title: 'Personal Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== PERSONAL INFORMATION SECTION ==========
          // Show child's name fields if not a farmer's child or status is unknown
          if (widget.isFarmerChild != true) ...[
            _buildModernTextField(
              context: context,
              label: 'Child\'s First Name:',
              controller: widget.nameController,
              hintText: 'Enter child\'s first name',
              onTap: () {},
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the child\'s first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildModernTextField(
              context: context,
              label: 'Child\'s Surname:',
controller: widget.surnameController,
              hintText: 'Enter child\'s surname',
              onTap: () {},
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the child\'s surname';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
           
            const SizedBox(height: 16
            ),
             // Child's Gender
                _buildModernRadioGroup<String>(
                  context: context,
                  question: 'Gender of the child',
                  groupValue: widget.gender,
                  onChanged: widget.onGenderChanged, 
                  options: [
                    {'value': 'Male', 'title': 'Male'},
                    {'value': 'Female', 'title': 'Female'},
                  ],
                ),
                const SizedBox(height: 20),
                 // Year of Birth with Date Picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Year of Birth:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[700]! 
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null 
                              ? _selectedDate!.year.toString()
                              : 'Select year of birth',
                          style: TextStyle(
                            color: _selectedDate != null 
                                ? (Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white 
                                    : Colors.black87)
                                : Colors.grey[500],
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedDate == null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Please select year of birth',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
                
          ],
           const SizedBox(height: 20),
          
          // Birth Certificate Status
          _buildModernRadioGroup<bool>(
            context: context,
            question: 'Does the child have a birth certificate?',
            groupValue: _hasBirthCertificate,
            onChanged: (value) {
              setState(() {
                _hasBirthCertificate = value;
              });
              widget.onBirthCertificateChanged?.call(value);
            },
            options: const [
              {'value': true, 'title': 'Yes'},
              {'value': false, 'title': 'No'},
            ],
          ),
          
         
          // Show reason field if no birth certificate
                if (_hasBirthCertificate == false) ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    context: context,
                    label: 'If no, please specify why',
                    onTap: () {},
                    controller: _noBirthCertificateReasonController,
                    hintText: 'Enter reason for not having a birth certificate',
                    validator: (value) {
                      if (_hasBirthCertificate == false &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please specify why the child does not have a birth certificate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                  // Born in community
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  context: context,
                  question: 'Is the child born in this community?',
                  groupValue: _bornInCommunity == null
                      ? null
                      : _bornInCommunity!
                          ? 'same_community'
                          : _birthCountry == 'same_district'
                              ? 'same_district'
                              : _birthCountry == 'same_region'
                                  ? 'same_region'
                                  : _birthCountry == 'other_ghana_region'
                                      ? 'other_ghana_region'
                                      : 'other_country',
                  onChanged: (value) {
                    setState(() {
                      _bornInCommunity = value == 'same_community';
                      if (value == 'same_community') {
                        _birthCountry = null;
                      } else if (value == 'same_district') {
                        _birthCountry = 'same_district';
                      } else if (value == 'same_region') {
                        _birthCountry = 'same_region';
                      } else if (value == 'other_ghana_region') {
                        _birthCountry = 'other_ghana_region';
                      } else if (value == 'other_country') {
                        _birthCountry = 'other_country';
                      }
                    });
                  },
                  options: [
                    {'value': 'same_community', 'title': 'Yes'},
                    {
                      'value': 'same_district',
                      'title':
                          'No, he was born in this district but different community within the district'
                    },
                    {
                      'value': 'same_region',
                      'title':
                          'No, he was born in this region but different district within the region'
                    },
                    {
                      'value': 'other_ghana_region',
                      'title': 'No, he was born in another region of Ghana'
                    },
                    {
                      'value': 'other_country',
                      'title': 'No, he was born in another country'
                    },
                  ],
                ),

                // Country of birth (shown only if born in another country)
                if (_birthCountry == 'other_country') ...[
                  const SizedBox(height: 16),
                  _buildModernDropdown<String>(
                    context: context,
                    label: 'In which country was the child born?',
                    value:
                        _birthCountry == 'other_country' ? null : _birthCountry,
                    items: _countries
                        .where((c) => c != 'Ghana')
                        .map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _birthCountry = newValue;
                      });
                    },
                    hint: 'Select country',
                    validator: (value) {
                      if (_birthCountry == 'other_country' &&
                          (value == null || value.isEmpty)) {
                        return 'Please select the country of birth';
                      }
                      return null;
                    },
                  ),
                ],
                  const SizedBox(height: 16),
                  // Relationship to head of household
                 _buildModernDropdown<String>(
                  context: context,
                  label:
                      'Relationship of the child to the head of the household',
                  value: _relationshipToHead,
                  items: [
                    'Son/daughter',
                    'Brother/Sister',
                    'Son-in-law/Daughter-in-law',
                    'Grandson/Granddaughter',
                    'Niece/nephew',
                    'Cousin',
                    'Child of the worker',
                    'Child of the farm owner',
                    'Other (please specify)'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _relationshipToHead = newValue;
                    });
                  },
                  hint: 'Select relationship',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a relationship';
                    }
                    return null;
                  },
                ),
      
                if (_relationshipToHead == 'Other (please specify)') ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    context: context,
                    label: 'If other please specify',
                    controller: _otherRelationshipController,
                    validator: (value) {
                      if (_relationshipToHead == 'Other (please specify)' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please specify the relationship';
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(height: 20,),
               
               
                
              
            
               
                 // Show family living situation question if child is not a direct family member
                if (_relationshipToHead == 'Child of the worker' ||
                    _relationshipToHead == 'Child of the farm owner' ||
                    _relationshipToHead == 'Other (please specify)') ...[
                  const SizedBox(height: 16),
                  Text(
                    'Why does the child [${widget.childNumberController.text}] not live with his/her family?',
                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._notLivingWithFamilyReasons.entries.map((entry) {
                    return ModernCheckbox(
                      value: entry.value,
                      onChanged: (bool? selected) {
                        setState(() {
                          _notLivingWithFamilyReasons[entry.key] =
                              selected ?? false;
                        });
                      },
                      title: entry.key,
                    );
                  }).toList(),
                  if (_notLivingWithFamilyReasons['Other (specify)'] ==
                      true) ...[
                    const SizedBox(height: 8),
                    _buildModernTextField(
                      context: context,
                      label: 'Other reason',
                      controller: _otherNotLivingWithFamilyController,
                      validator: (value) {
                        if (_notLivingWithFamilyReasons['Other (specify)'] ==
                                true &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Please specify the reason';
                        }
                        return null;
                      },
                    ),
                  ], // Show family living situation question if child is not a direct family member
                    
                SizedBox(height: 20,),
                
                
        ] 
        ] 
      )
    );
  }

  
  Widget _buildInfoCard(String text) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  // Widget _buildRadioOption({
  //   required BuildContext context,
  //   required String value,
  //   required String? groupValue,
  //   required String label,
  //   required ValueChanged<String?> onChanged,
  // }) {
  //   final theme = Theme.of(context);
  //   final isDark = theme.brightness == Brightness.dark;

  //   return RadioListTile<String>(
  //     title: Text(
  //       label,
  //       style: theme.textTheme.bodyLarge?.copyWith(
  //         color: isDark ? Colors.white70 : Colors.black87,
  //       ),
  //     ),
  //     value: value,
  //     groupValue: groupValue,
  //     onChanged: onChanged,
  //     activeColor: theme.primaryColor,
  //   );
  // }

  // Widget _buildModernRadioGroup<T>({
  //   required BuildContext context,
  //   required String question,
  //   required T? groupValue,
  //   required ValueChanged<T>? onChanged,
  //   required List<Map<String, dynamic>> options,
  // }) {
  //   final theme = Theme.of(context);
  //   final isDark = theme.brightness == Brightness.dark;

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         question,
  //         style: theme.textTheme.titleMedium?.copyWith(
  //           color: isDark ? Colors.white70 : Colors.black87,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       ...options.map((option) {
  //         final value = option['value'] as T;
  //         final label = option['title'] as String;

  //         return RadioListTile<T>(
  //           title: Text(
  //             label,
  //             style: theme.textTheme.bodyLarge?.copyWith(
  //               color: isDark ? Colors.white70 : Colors.black87,
  //             ),
  //           ),
  //           value: value,
  //           groupValue: groupValue,
  //           onChanged: onChanged != null ? (T? val) => onChanged(val as T) : null,
  //           activeColor: theme.primaryColor,
  //           contentPadding: EdgeInsets.zero,
  //           dense: true,
  //         );
  //       }).toList(),
  //     ],
  //   );
  // }

}