import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/adult_info_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/visit_information_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/identification_of_owner_model.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/workers_in_farm_model.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';
import 'package:human_rights_monitor/controller/db/household_tables.dart';
import 'package:human_rights_monitor/controller/db/table_names.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/adults_information_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/adults_information_content.dart';
import 'package:sqflite/sqflite.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';

import 'package:human_rights_monitor/view/theme/app_theme.dart';

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class CombinedFarmIdentificationPage extends StatefulWidget {
  final int coverPageId; 
  final int initialPageIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;
  final ValueChanged<bool>? onCanProceedChanged;

  const CombinedFarmIdentificationPage({
    super.key,
    this.initialPageIndex = 0,
    required this.coverPageId, 
    required this.onPageChanged,
    this.onPrevious,
    this.onNext,
    this.onSubmit,
    this.onCanProceedChanged,
  });

  @override
  State<CombinedFarmIdentificationPage> createState() =>
      CombinedFarmIdentificationPageState(coverPageId: coverPageId);
}

class _IdentificationOfOwnerContent extends StatelessWidget {
  final IdentificationOfOwnerData data;
  final ValueChanged<IdentificationOfOwnerData> onDataChanged;
  final List<String> validationErrors;

  const _IdentificationOfOwnerContent({
    Key? key,
    required this.data,
    required this.onDataChanged,
    this.validationErrors = const [],
  }) : super(key: key);

  Widget _buildQuestionCard({required BuildContext context, required Widget child}) {
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
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required BuildContext context,
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
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: theme.primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Owner's Name
          _buildQuestionCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name of owner',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Verify this information with his identification document or any other document of identification. In capital letters',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkCard : Colors.grey[50],
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  initialValue: data.ownerName,
                  onChanged: (value) => onDataChanged(data.copyWith(ownerName: value)),
                ),
                const SizedBox(height: 16),
                Text(
                  'First Name of the owner?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),

                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Verify this information with his identification document or any other document of identification. In capital letters',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkCard : Colors.grey[50],
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  initialValue: data.ownerFirstName,
                  onChanged: (value) => onDataChanged(data.copyWith(ownerFirstName: value)),
                ),
              ],
            ),
          ),

         // Nationality
_buildQuestionCard(
  context: context,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'What is the nationality of the owner?',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: data.nationality,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: isDark ? AppTheme.darkCard : Colors.grey[50],
          hintText: 'Select Nationality',
        ),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
        dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
        items: const [
          DropdownMenuItem(value: 'Ghanaian', child: Text('Ghanaian')),
          DropdownMenuItem(value: 'Non-Ghanaian', child: Text('Non-Ghanaian')),
        ],
        onChanged: (value) => onDataChanged(data.copyWith(
          nationality: value,
          specificNationality: null, // Reset specific nationality when changing
          otherNationality: null,    // Reset other nationality when changing
        )),
      ),
      if (data.nationality == 'Non-Ghanaian') ...[
        const SizedBox(height: 16),
        Text(
          'If Non Ghanaian , specify country of origin',style: theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.w600,
    color: isDark ? Colors.white : Colors.black87,
  ),
          ),
          SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: data.specificNationality,
          decoration: InputDecoration(
            labelText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.grey[50],
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
          dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
          items: const [
            DropdownMenuItem(value: 'burkina_faso', child: Text('Burkina Faso')),
            DropdownMenuItem(value: 'mali', child: Text('Mali')),
            DropdownMenuItem(value: 'guinea', child: Text('Guinea')),
            DropdownMenuItem(value: 'ivory_coast', child: Text('Ivory Coast')),
            DropdownMenuItem(value: 'liberia', child: Text('Liberia')),
            DropdownMenuItem(value: 'togo', child: Text('Togo')),
            DropdownMenuItem(value: 'benin', child: Text('Benin')),
            DropdownMenuItem(value: 'other', child: Text('Other (to specify)')),
          ],
          onChanged: (value) => onDataChanged(data.copyWith(
            specificNationality: value,
            otherNationality: value == 'other' ? data.otherNationality : null,
          )),
        ),
        if (data.specificNationality == 'other')
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Specify Country',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: isDark ? AppTheme.darkCard : Colors.grey[50],
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
              initialValue: data.otherNationality,
              onChanged: (value) => onDataChanged(data.copyWith(otherNationality: value)),
            ),
          ),
      ],
    ],
  ),
),
            
          // Years with Owner
          _buildQuestionCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'For how many years has the respondent been working for the owner?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Number of Years',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkCard : Colors.grey[50],
                    suffixText: 'years',
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: data.yearsWithOwner,
                  onChanged: (value) => onDataChanged(data.copyWith(yearsWithOwner: value)),
                ),
              ],
            ),
          ),

          // Show validation errors if any
          if (validationErrors.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...validationErrors.map((error) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _VisitInformationContent extends StatefulWidget {
  final int currentPageIndex;
  final VisitInformationData data;
  final IdentificationOfOwnerData ownerData;
  final Function(VisitInformationData) onDataChanged;
  final WorkersInFarmData workersData;
  final AdultsInformationData adultsData;
  final List<String> validationErrors;
  final GlobalKey<FormState>? formKey;

  const _VisitInformationContent({
    Key? key,
    required this.currentPageIndex,
    required this.data,
    required this.ownerData,
    required this.onDataChanged,
    required this.workersData,
    required this.adultsData,
    required this.validationErrors,
    this.formKey,
  }) : super(key: key);

  @override
  State<_VisitInformationContent> createState() => _VisitInformationContentState();
}

class _VisitInformationContentState extends State<_VisitInformationContent> {
  late String? _respondentNameCorrect;
  late String? _respondentNationality;
  late String? _countryOfOrigin;
  late String? _isFarmOwner;
  late String? _farmOwnershipType;
  final TextEditingController _respondentNameController = TextEditingController();
  final TextEditingController _otherCountryController = TextEditingController();
  late final TextEditingController _respondentOtherNamesController;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _respondentOtherNamesController = TextEditingController();
    _initializeFromData();
  }

 void _initializeFromData() {
  _respondentNameCorrect = widget.data.respondentNameCorrect == true 
      ? 'Yes' 
      : (widget.data.respondentNameCorrect == false ? 'No' : null);
  _respondentNationality = widget.data.respondentNationality;
  _countryOfOrigin = widget.data.countryOfOrigin;
  _isFarmOwner = widget.data.isFarmOwner == true 
      ? 'Yes' 
      : (widget.data.isFarmOwner == false ? 'No' : null);
  _farmOwnershipType = widget.data.farmOwnershipType;
  _respondentNameController.text = widget.data.correctedRespondentName ?? '';
  _respondentOtherNamesController.text = widget.data.respondentOtherNames ?? '';
  _otherCountryController.text = widget.data.otherCountry ?? '';
}

  @override
  void dispose() {
    _respondentNameController.dispose();
    _otherCountryController.dispose();
    _respondentOtherNamesController.dispose();
    _pageController.dispose();
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
    );
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
          // Card 1: Name Confirmation Question
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Is the respondent's name correct?",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Wrap(
                  spacing: 20,
                  children: [
                    _buildRadioOption(
                      value: 'Yes',
                      groupValue: _respondentNameCorrect,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          _respondentNameCorrect = value;
                          if (value == 'Yes') {
                            _respondentNameController.clear();
                          }
                          _updateData();
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'No',
                      groupValue: _respondentNameCorrect,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          _respondentNameCorrect = value;
                          _updateData();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Card 2: Respondent's Name (only shown when 'No' is selected)
          if (_respondentNameCorrect == 'No') ...[
            _buildQuestionCard(
              child: TextField(
                controller: _respondentNameController,
                decoration: const InputDecoration(
                  labelText: 'If No, fill the exact surname of the producer?',
                  hintText: 'Verify this information with his identification document or any other document of identification. In capital letters',
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => _updateData(),
              ),
            ),
            const SizedBox(height: _Spacing.md),
            _buildQuestionCard(
              child: TextField(
                controller: _respondentOtherNamesController,
                decoration: const InputDecoration(
                  labelText: 'If No, fill the exact first and other names of the producer?',
                  hintText: 'Verify this information with his identification document or any other document of identification. In capital letters',
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => _updateData(),
              ),
            ),
          ],

          // Card 3: Nationality Question
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is the nationality of the respondent ?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Wrap(
                  spacing: 20,
                  children: [
                    _buildRadioOption(
                      value: 'Ghanaian',
                      groupValue: _respondentNationality,
                      label: 'Ghanaian',
                      onChanged: (value) {
                        setState(() {
                          _respondentNationality = value;
                          _countryOfOrigin = null;
                          _otherCountryController.clear();
                          _updateData();
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Non-Ghanaian',
                      groupValue: _respondentNationality,
                      label: 'Non-Ghanaian',
                      onChanged: (value) {
                        setState(() {
                          _respondentNationality = value;
                          _updateData();
                        });
                      },
                    ),
                  ],
                ),

                // Country of origin (only shown for non-Ghanaians)
                if (_respondentNationality == 'Non-Ghanaian') ...[
                  const SizedBox(height: _Spacing.md),
                  DropdownButtonFormField<String>(
                    value: _countryOfOrigin,
                    decoration: const InputDecoration(
                      labelText: 'If Non Ghanaian, specify country of origin',
                    ),
                    items: [
                      'Burkina Faso',
                      'Mali',
                      'Guinea',
                      'Ivory Coast',
                      'Liberia',
                      'Togo',
                      'Benin',
                      'Niger',
                      'Nigeria',
                      'Other'
                    ].map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _countryOfOrigin = newValue;
                          if (newValue != 'Other') {
                            _otherCountryController.clear();
                          }
                          _updateData();
                        });
                      }
                    },
                  ),

                  if (_countryOfOrigin == 'Other')
                    Padding(
                      padding: const EdgeInsets.only(top: _Spacing.md),
                      child: TextField(
                        controller: _otherCountryController,
                        decoration: const InputDecoration(
                          labelText:'If Other, specify country of origin',
                        ),
                        onChanged: (_) => _updateData(),
                      ),
                    ),
                ],
              ],
            ),
          ),

          // Card 4: Farm Ownership
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Is the respondent the owner of the farm?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Wrap(
                  spacing: 20,
                  children: [
                    _buildRadioOption(
                      value: 'Yes',
                      groupValue: _isFarmOwner,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          _isFarmOwner = value;
                          _updateData();
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'No',
                      groupValue: _isFarmOwner,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          _isFarmOwner = value;
                          _updateData();
                        });
                      },
                    ),
                  ],
                ),

                // Farm ownership type
                if (_isFarmOwner != null) ...[
                  const SizedBox(height: _Spacing.md),
                  DropdownButtonFormField<String>(
                    value: _farmOwnershipType,
                    decoration: const InputDecoration(
                      labelText: 'Which of these best describes you?',
                    ),
                    items: [
                      ' Complete Owner',
                      ' Sharecropper',
                      'Owner/Sharecropper',
                      'Caretaker/Manager of the Farm',
                    'Sharecropper',
                    ].map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _farmOwnershipType = value;
                        _updateData();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),

          // Show validation errors if any
          if (widget.validationErrors.isNotEmpty) ...[
            const SizedBox(height: _Spacing.md),
            ...widget.validationErrors.map((error) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            )),
          ],
        ],
      ),
    );
  }

 void _updateData() {
  widget.onDataChanged(
    VisitInformationData(
      respondentNameCorrect: _respondentNameCorrect == 'Yes' ? true : 
                          _respondentNameCorrect == 'No' ? false : null,
      respondentNationality: _respondentNationality,
      countryOfOrigin: _countryOfOrigin,
      isFarmOwner: _isFarmOwner == 'Yes' ? true : 
                  _isFarmOwner == 'No' ? false : null,
      farmOwnershipType: _farmOwnershipType,
      correctedRespondentName: _respondentNameController.text,
      respondentOtherNames: _respondentOtherNamesController.text,
      otherCountry: _otherCountryController.text,
    ),
  );
}
}

class _WorkersInFarmContent extends StatefulWidget {
  final WorkersInFarmData data;
  final ValueChanged<WorkersInFarmData> onDataChanged;
  final List<String> validationErrors;

  const _WorkersInFarmContent({
    Key? key,
    required this.data,
    required this.onDataChanged,
    this.validationErrors = const [],
  }) : super(key: key);

  @override
  State<_WorkersInFarmContent> createState() => _WorkersInFarmContentState();
}

class _WorkersInFarmContentState extends State<_WorkersInFarmContent> {
  final TextEditingController _otherAgreementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otherAgreementController.text = widget.data.otherAgreement;
  }

  @override
  void didUpdateWidget(_WorkersInFarmContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.otherAgreement != _otherAgreementController.text) {
      _otherAgreementController.text = widget.data.otherAgreement;
    }
  }

  void _updateData(WorkersInFarmData newData) {
    widget.onDataChanged(newData);
  }

  @override
  void dispose() {
    _otherAgreementController.dispose();
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

  Widget _buildCheckboxOption({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CheckboxListTile(
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String hintText = '',
    int maxLines = 1,
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementCard({
    required String statement,
    required String statementId,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _buildQuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statement,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: _Spacing.md),
          Row(
            children: [
              _buildAgreementButton(
                label: 'Agree',
                isSelected: widget.data.agreementResponses[statementId] == 'Agree',
                onPressed: () {
                  setState(() {
                    final newResponses = Map<String, String?>.from(widget.data.agreementResponses);
                    newResponses[statementId] = 'Agree';
                    _updateData(widget.data.copyWith(agreementResponses: newResponses));
                  });
                },
              ),
              const SizedBox(width: 16),
              _buildAgreementButton(
                label: 'Disagree',
                isSelected: widget.data.agreementResponses[statementId] == 'Disagree',
                onPressed: () {
                  setState(() {
                    final newResponses = Map<String, String?>.from(widget.data.agreementResponses);
                    newResponses[statementId] = 'Disagree';
                    _updateData(widget.data.copyWith(agreementResponses: newResponses));
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: _Spacing.md),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isSelected ? AppTheme.primaryColor : isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
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
          // First Card: Recruitment Question
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have you recruited at least one worker during the past year?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: '1',
                      groupValue: widget.data.hasRecruitedWorker,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(hasRecruitedWorker: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: '0',
                      groupValue: widget.data.hasRecruitedWorker,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(
                            hasRecruitedWorker: value,
                            permanentLabor: false,
                            casualLabor: false,
                          ));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Worker Recruitment Type Card (Conditional)
          if (widget.data.hasRecruitedWorker == '1') ...[
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Do you recruit workers for...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  _buildCheckboxOption(
                    value: widget.data.permanentLabor,
                    label: 'Permanent labor',
                    onChanged: (value) {
                      setState(() {
                        _updateData(widget.data.copyWith(permanentLabor: value ?? false));
                      });
                    },
                  ),
                  _buildCheckboxOption(
                    value: widget.data.casualLabor,
                    label: 'Casual labor',
                    onChanged: (value) {
                      setState(() {
                        _updateData(widget.data.copyWith(casualLabor: value ?? false));
                      });
                    },
                  ),
                ],
              ),
            ),
          ],

          // Second Card: Follow-up question when 'No' is selected in the first question
          if (widget.data.hasRecruitedWorker == '0')
            _buildQuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Have you ever recruited a worker before?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: _Spacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRadioOption(
                        value: 'Yes',
                        groupValue: widget.data.everRecruitedWorker,
                        label: 'Yes',
                        onChanged: (value) {
                          setState(() {
                            _updateData(widget.data.copyWith(everRecruitedWorker: value));
                          });
                        },
                      ),
                      _buildRadioOption(
                        value: 'No',
                        groupValue: widget.data.everRecruitedWorker,
                        label: 'No',
                        onChanged: (value) {
                          setState(() {
                            _updateData(widget.data.copyWith(everRecruitedWorker: value));
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Workers Recruitment Title
          Padding(
            padding: const EdgeInsets.only(top: _Spacing.lg, bottom: _Spacing.sm),
            child: Text(
              'Workers Recruitment',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
          ),

          // Worker Agreement Type Card
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What kind of agreement do you have with your workers?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: 'Verbal agreement without witness',
                      groupValue: widget.data.workerAgreementType,
                      label: 'Verbal agreement without witness',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(workerAgreementType: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Verbal agreement with witness',
                      groupValue: widget.data.workerAgreementType,
                      label: 'Verbal agreement with witness',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(workerAgreementType: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Written agreement without witness',
                      groupValue: widget.data.workerAgreementType,
                      label: 'Written agreement without witness',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(workerAgreementType: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Written contract with witness',
                      groupValue: widget.data.workerAgreementType,
                      label: 'Written contract with witness',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(workerAgreementType: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Other (specify)',
                      groupValue: widget.data.workerAgreementType,
                      label: 'Other (specify)',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(workerAgreementType: value));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Other Agreement Type Specification Card
          if (widget.data.workerAgreementType == 'Other (specify)')
            _buildQuestionCard(
              child: _buildTextField(
                label: 'If other,please specify',
                controller: _otherAgreementController,
                onChanged: (value) {
                  _updateData(widget.data.copyWith(otherAgreement: value));
                },
                hintText: 'Enter agreement type',
                maxLines: 2,
              ),
            ),

          // Task Clarification Card
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Were the tasks to be performed by the worker clarified with them during the recruitment?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: 'Yes',
                      groupValue: widget.data.tasksClarified,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(tasksClarified: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'No',
                      groupValue: widget.data.tasksClarified,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(tasksClarified: value));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Additional tasks question
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Does the worker perform tasks for you or your family members other than those agreed upon?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: 'Yes',
                      groupValue: widget.data.additionalTasks,
                      label: 'Yes',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(additionalTasks: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'No',
                      groupValue: widget.data.additionalTasks,
                      label: 'No',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(additionalTasks: value));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Refusal Action Card
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What do you do when a worker refuses to perform a task?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: 'I find a compromise',
                      groupValue: widget.data.refusalAction,
                      label: 'I find a compromise',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(refusalAction: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'I withdraw part of their salary',
                      groupValue: widget.data.refusalAction,
                      label: 'I withdraw part of their salary',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(refusalAction: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'I issue a warning',
                      groupValue: widget.data.refusalAction,
                      label: 'I issue a warning',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(refusalAction: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Other',
                      groupValue: widget.data.refusalAction,
                      label: 'Other',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(refusalAction: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Not applicable',
                      groupValue: widget.data.refusalAction,
                      label: 'Not applicable',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(refusalAction: value));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Additional card for 'Other' specification
          if (widget.data.refusalAction == 'Other')
            _buildQuestionCard(
              child: _buildTextField(
                label: 'If other,please specify',
                controller: _otherAgreementController,
                onChanged: (value) {
                  _updateData(widget.data.copyWith(otherAgreement: value));
                },
                hintText: 'Enter your response',
                maxLines: 3,
              ),
            ),

          // Salary payment frequency question
          _buildQuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do your workers receive their full salaries?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: _Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadioOption(
                      value: 'Always',
                      groupValue: widget.data.salaryPaymentFrequency,
                      label: 'Always',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(salaryPaymentFrequency: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Sometimes',
                      groupValue: widget.data.salaryPaymentFrequency,
                      label: 'Sometimes',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(salaryPaymentFrequency: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Rarely',
                      groupValue: widget.data.salaryPaymentFrequency,
                      label: 'Rarely',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(salaryPaymentFrequency: value));
                        });
                      },
                    ),
                    _buildRadioOption(
                      value: 'Never',
                      groupValue: widget.data.salaryPaymentFrequency,
                      label: 'Never',
                      onChanged: (value) {
                        setState(() {
                          _updateData(widget.data.copyWith(salaryPaymentFrequency: value));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Show agreement section if applicable
          if (widget.data.hasRecruitedWorker == '1' ||
              (widget.data.hasRecruitedWorker == '0' && widget.data.everRecruitedWorker == 'Yes')) ...[
            // Note for the respondent
            Padding(
              padding: const EdgeInsets.only(bottom: _Spacing.lg),
              child: Text(
                'For the following section, please read the statements to the respondent, and ask him/her if he/she agrees or disagrees.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),

            // Agreement Statements Section - Salary and Debt
            _buildAgreementCard(
              statement: 'It is acceptable to withhold a worker\'s salary without their consent.',
              statementId: 'salary_workers',
            ),
            _buildAgreementCard(
              statement: 'It is acceptable for a person who cannot pay their debts to work for the creditor to reimburse the debt.',
              statementId: 'recruit_1',
            ),

            // Agreement Statements Section - Recruitment
            _buildAgreementCard(
              statement: 'It is acceptable for an employer not to reveal the true nature of the work during the recruitment.',
              statementId: 'recruit_2',
            ),
            _buildAgreementCard(
              statement: 'A worker is obliged to work whenever he is called upon by his employer.',
              statementId: 'recruit_3',
            ),

            // Agreement Statements Section - Working Conditions
            _buildAgreementCard(
              statement: 'A worker is not entitled to move freely.',
              statementId: 'conditions_1',
            ),
            _buildAgreementCard(
              statement: 'A worker must be free to communicate with his or her family and friends.',
              statementId: 'conditions_2',
            ),
            _buildAgreementCard(
              statement: 'A worker is obliged to adapt to any living conditions imposed by the employer.',
              statementId: 'conditions_3',
            ),
            _buildAgreementCard(
              statement: 'It is acceptable for an employer and their family to interfere in a worker\'s private life.',
              statementId: 'conditions_4',
            ),
            _buildAgreementCard(
              statement: 'A worker should not have the freedom to leave work whenever they wish.',
              statementId: 'conditions_5',
            ),

            // Agreement Statements Section - Leaving Employment
            _buildAgreementCard(
              statement: 'A worker should be required to stay longer than expected while waiting for unpaid salary.',
              statementId: 'leaving_1',
            ),
            _buildAgreementCard(
              statement: 'A worker should not be able to leave their employer when they owe money to their employer.',
              statementId: 'leaving_2',
            ),
          ],

          // Show validation errors if any
          if (widget.validationErrors.isNotEmpty) ...[
            const SizedBox(height: _Spacing.lg),
            ...widget.validationErrors.map((error) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            )).toList(),
          ],

          const SizedBox(height: _Spacing.xxl),
        ],
      ),
    );
  }
}

// Missing AdultsInformationContent widget
// class AdultsInformationContent extends StatefulWidget {
//   final AdultsInformationData data;
//   final ValueChanged<AdultsInformationData> onDataChanged;
//   final List<String> validationErrors;
//   final GlobalKey<FormState>? formKey;

//   const AdultsInformationContent({
//     Key? key,
//     required this.data,
//     required this.onDataChanged,
//     this.validationErrors = const [],
//     this.formKey,
//   }) : super(key: key);

//   @override
//   State<AdultsInformationContent> createState() => _AdultsInformationContentState();
// }

// class _AdultsInformationContentState extends State<AdultsInformationContent> {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(_Spacing.lg),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Adults Information',
//             style: theme.textTheme.headlineSmall?.copyWith(
//               color: isDark ? Colors.white : Colors.black87,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: _Spacing.lg),
//           Text(
//             'This section collects information about adults in the household.',
//             style: theme.textTheme.bodyLarge?.copyWith(
//               color: isDark ? Colors.white70 : Colors.black54,
//             ),
//           ),
//           const SizedBox(height: _Spacing.xl),
          
//           // Number of adults input
//           Card(
//             elevation: 0,
//             margin: const EdgeInsets.only(bottom: _Spacing.lg),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               side: BorderSide(
//                 color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
//                 width: 1,
//               ),
//             ),
//             color: isDark ? AppTheme.darkCard : Colors.white,
//             child: Padding(
//               padding: const EdgeInsets.all(_Spacing.lg),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Number of adults in the household',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: _Spacing.md),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'Enter number of adults',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       filled: true,
//                       fillColor: isDark ? AppTheme.darkCard : Colors.grey[50],
//                     ),
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                     keyboardType: TextInputType.number,
//                     initialValue: widget.data.numberOfAdults?.toString(),
//                     onChanged: (value) {
//                       final numAdults = int.tryParse(value);
//                       widget.onDataChanged(
//                         widget.data.copyWith(numberOfAdults: numAdults)
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Show validation errors if any
//           if (widget.validationErrors.isNotEmpty) ...[
//             const SizedBox(height: _Spacing.md),
//             ...widget.validationErrors.map((error) => Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 error,
//                 style: const TextStyle(color: Colors.red, fontSize: 14),
//               ),
//             )),
//           ],
//         ],
//       ),
//     );
//   }
// }

// MAIN STATE CLASS - ONLY ONE DEFINITION
class CombinedFarmIdentificationPageState
    extends State<CombinedFarmIdentificationPage> {
  final int coverPageId; // coverPageId is required and cannot be null
  late PageController _pageController;
  
  // Form keys for each subpage
  final GlobalKey<FormState> visitInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> adultsFormKey = GlobalKey<FormState>();
  
  // Public getter for the page controller
  PageController get pageController => _pageController;
  late int _currentPageIndex;
  final int _totalPages = 4;

  // Individual models for each page
  VisitInformationData _visitInfoData = VisitInformationData();
  IdentificationOfOwnerData _ownerData = IdentificationOfOwnerData();
  WorkersInFarmData _workersData = WorkersInFarmData();
  AdultsInformationData _adultsData = AdultsInformationData();
  
  // Public getters for the private fields
  VisitInformationData get visitInfoData => _visitInfoData;
  IdentificationOfOwnerData get ownerData => _ownerData;
  WorkersInFarmData get workersData => _workersData;
  AdultsInformationData get adultsData => _adultsData;
  int get currentPageIndex => _currentPageIndex;
  
 /// Returns a CombinedFarmerIdentificationModel with all the form data from all pages
  CombinedFarmerIdentificationModel? getCombinedData() {
    try {
      debugPrint('🔍 [CombinedFarm] Creating combined data model');
      debugPrint('   - Visit Info: ${_visitInfoData != null}');
      debugPrint('   - Owner Info: ${_ownerData != null}');
      debugPrint('   - Workers Info: ${_workersData != null}');
      debugPrint('   - Adults Info: ${_adultsData != null}');
      
      return CombinedFarmerIdentificationModel(
        coverPageId: coverPageId,
        visitInformation: _visitInfoData,
        ownerInformation: _ownerData,
        workersInFarm: _workersData,
        adultsInformation: _adultsData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
        syncStatus: 0,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [CombinedFarm] Error creating combined model: $e');
      debugPrint('📜 Stack trace: $stackTrace');
      return null;
    }
  }

  // Validation state
  final Map<int, List<String>> _validationErrors = {};

  CombinedFarmIdentificationPageState({required this.coverPageId});

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPageIndex;
    _pageController = PageController(initialPage: _currentPageIndex);
    // Initialize validation errors for all pages
    for (int i = 0; i < _totalPages; i++) {
      _validationErrors[i] = [];
    }
    _notifyCanProceed();
  }

  @override
  void didUpdateWidget(CombinedFarmIdentificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPageIndex != widget.initialPageIndex) {
      _currentPageIndex = widget.initialPageIndex;
    }
  }

  bool get _isCurrentPageComplete {
    final errors = getCurrentPageErrors();
    return errors.isEmpty;
  }

  void _notifyCanProceed() {
    widget.onCanProceedChanged?.call(_isCurrentPageComplete);
  }

  Future<void> _saveCurrentPageData({required int coverPageId}) async {
    try {
      final db = await HouseholdDBHelper.instance.database;
      final now = DateTime.now().toIso8601String();
      
      debugPrint('💾 [CombinedFarm] Saving data for page $_currentPageIndex with coverPageId: $coverPageId');
      
      // Helper function to safely convert data to JSON string
      String safeJsonEncode(dynamic data) {
        if (data == null) return '{}';
        try {
          if (data is Map) {
            return jsonEncode(data);
          } else if (data.toMap != null) {
            return jsonEncode(data.toMap());
          }
          return '{}';
        } catch (e) {
          debugPrint('⚠️ Error encoding data: $e');
          return '{}';
        }
      }
      
      // Prepare all data sections
      final visitInfoJson = safeJsonEncode(_visitInfoData);
      final ownerInfoJson = safeJsonEncode(_ownerData);
      final workersInfoJson = safeJsonEncode(_workersData);
      final adultsInfoJson = safeJsonEncode(_adultsData);
      
      debugPrint('📊 [CombinedFarm] Data prepared:');
      debugPrint('   - Visit Info: ${visitInfoJson.length} chars');
      debugPrint('   - Owner Info: ${ownerInfoJson.length} chars');
      debugPrint('   - Workers Info: ${workersInfoJson.length} chars');
      debugPrint('   - Adults Info: ${adultsInfoJson.length} chars');
      
      // Create the complete data map
      final data = <String, dynamic>{
        'cover_page_id': coverPageId,
        'visit_information': visitInfoJson,
        'owner_information': ownerInfoJson,
        'workers_in_farm': workersInfoJson,
        'adults_information': adultsInfoJson,
        'created_at': now,
        'updated_at': now,
        'is_synced': 0,
        'sync_status': 0,
      };
      
      // First try to update existing record
      final updated = await db.update(
        TableNames.combinedFarmIdentificationTBL,
      data,
      where: 'cover_page_id = ?',
      whereArgs: [coverPageId],
    );
    
    // If no rows were updated, insert a new record
    if (updated == 0) {
      await db.insert(
        TableNames.combinedFarmIdentificationTBL,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('✅ Inserted new combined farm data with coverPageId: $coverPageId');
    } else {
      debugPrint('✅ Updated existing combined farm data with coverPageId: $coverPageId');
    }
    
  } catch (e, stackTrace) {
    debugPrint('❌ Error in _saveCurrentPageData: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}
  Future<void> _handlePageChanged(int index) async {
    // Save current page data before navigation
    await _saveCurrentPageData(coverPageId: coverPageId);
    
    // Validate current page before allowing navigation
    if (!_isCurrentPageComplete) {
      final errors = getCurrentPageErrors();
      if (errors.isNotEmpty) {
        setState(() {
          _validationErrors[_currentPageIndex] = errors;
        });
        _showValidationError(errors.first);
        // Prevent page change by resetting to current page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(_currentPageIndex);
          }
        });
        return;
      }
    }
    
    // If valid, proceed with navigation
    setState(() {
      _currentPageIndex = index;
      // Clear validation errors for the new page
      _validationErrors[index] = [];
    });
    
    widget.onPageChanged(index);
    _notifyCanProceed();
  }

  Future<void> _goToNextPage() async {
    // Validate current page first
    if (!validateCurrentPage()) {
      return;
    }
    
    try {
      // Save current page data before navigating with validation
      final saved = await saveData(validateAllPages: false);
      
      if (!saved) {
        debugPrint('❌ Failed to save data before navigation');
        return;
      }
      
      // If we have more sub-pages, go to the next one
      if (_currentPageIndex < _totalPages - 1) {
        final nextPageIndex = _currentPageIndex + 1;
        
        // Update the current page index
        if (mounted) {
          setState(() {
            _currentPageIndex = nextPageIndex;
            // Clear validation errors for the new page
            _validationErrors[nextPageIndex] = [];
          });
        }
        
        // Animate to the next page
        if (_pageController.hasClients) {
          await _pageController.animateToPage(
            nextPageIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        
        // Notify parent widget about the page change
        if (mounted) {
          widget.onPageChanged(nextPageIndex);
        }
      } 
      // Only call onNext if we're on the last sub-page and there's a next page to go to
      else if (widget.onNext != null && _currentPageIndex >= _totalPages - 1) {
        // This is the last page, call the onNext callback
        widget.onNext!();
      }
      
      if (mounted) {
        _notifyCanProceed();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _goToNextPage: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _showValidationError('Error saving data. Please try again.');
      }
    }
  }

  void _goToPreviousPage() async {
    // Clear validation errors when going back
    setState(() {
      _validationErrors[_currentPageIndex] = [];
    });
    
    if (_currentPageIndex > 0) {
      final previousPageIndex = _currentPageIndex - 1;
      
      // Save current page data before navigating
     await _saveCurrentPageData(coverPageId: coverPageId);
      // Update the current page index
      setState(() {
        _currentPageIndex = previousPageIndex;
        // Clear validation errors for the previous page
        _validationErrors[previousPageIndex] = [];
      });
      
      // Animate to the previous page
      await _pageController.animateToPage(
        previousPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Notify parent widget about the page change
      widget.onPageChanged(previousPageIndex);
    } else {
      // This is the first sub-page, notify parent to go to previous main page
      widget.onPrevious?.call();
    }
    
    _notifyCanProceed();
  }

  /// Saves the form data to the local database
  /// [validateAllPages] If true, validates all pages. If false, only validates the current page.
  /// Returns true if save was successful, false otherwise
  Future<bool> saveData({bool validateAllPages = false}) async {
    try {
      debugPrint('\n=== ATTEMPTING TO SAVE FORM DATA ===');
      
      // Validate coverPageId is not null
      if (coverPageId == null) {
        debugPrint('❌ Error: coverPageId is null when saving combined farmer data');
        _showValidationError('Error: Missing cover page reference. Please go back to the cover page and try again.');
        return false;
      }
      
      // First, save the current page data without validation
      await _saveCurrentPageData(coverPageId: coverPageId!);
      
      if (validateAllPages) {
        // Validate all pages if explicitly requested
        for (int i = 0; i < _totalPages; i++) {
          final errors = _validatePage(i) ? [] : (_validationErrors[i] ?? []);
          if (errors.isNotEmpty) {
            debugPrint('❌ Validation errors found on page $i: $errors');
            _showValidationError('Please complete all required fields');
            return false;
          }
        }
      } else {
        // Only validate the current page
        final errors = _validatePage(_currentPageIndex) ? [] : (_validationErrors[_currentPageIndex] ?? []);
        if (errors.isNotEmpty) {
          debugPrint('❌ Validation errors on current page: $errors');
          _showValidationError('Please complete all required fields on this page');
          return false;
        }
      }
      
      debugPrint('✅ All validations passed, saving data...');
      
      // Save all data again to ensure everything is up to date
      await _saveCurrentPageData(coverPageId: coverPageId!);
      
      debugPrint('✅ All form data saved successfully');
      return true;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving form data: $e');
      debugPrint('Stack trace: $stackTrace');
      _showValidationError('Error saving data. Please try again.');
      return false;
    }
  }

  /// Validates the page at the given index and returns true if valid
  bool _validatePage(int pageIndex) {
    List<String> errors;
    
    switch (pageIndex) {
      case 0:
        errors = _validateVisitInformation();
        break;
      case 1:
        errors = _validateOwnerIdentification();
        break;
      case 2:
        errors = _validateWorkersInFarm();
        break;
      case 3:
        errors = _validateAdultsInformation();
        break;
      default:
        errors = [];
    }
    
    // Store validation errors for UI display
    if (errors.isNotEmpty) {
      setState(() {
        _validationErrors[pageIndex] = errors;
      });
      return false;
    }
    return true;
  }

  /// Validates the current page and returns true if valid
  bool validateCurrentPage() {
    final errors = getCurrentPageErrors();
    
    // Store validation errors for UI display
    setState(() {
      _validationErrors[_currentPageIndex] = errors;
    });

    if (errors.isNotEmpty) {
      // Show first error message
      _showValidationError(errors.first);
      _notifyCanProceed();
      return false;
    }
    
    _notifyCanProceed();
    return true;
  }

  /// Gets validation errors for the current page
  List<String> getCurrentPageErrors() {
    switch (_currentPageIndex) {
      case 0:
        return _validateVisitInformation();
      case 1:
        return _validateOwnerIdentification();
      case 2:
        return _validateWorkersInFarm();
      case 3:
        return _validateAdultsInformation();
      default:
        return [];
    }
  }

  /// Validation for Visit Information Page - All fields are required
  List<String> _validateVisitInformation() {
    final errors = <String>[];
    final data = _visitInfoData;
    
    // Debug: Print all data being validated
    debugPrint('=== VALIDATION DEBUG ===');
    debugPrint('respondentNameCorrect: ${data.respondentNameCorrect}');
    debugPrint('isFarmOwner: ${data.isFarmOwner}');
    debugPrint('farmOwnershipType: ${data.farmOwnershipType}');
    debugPrint('respondentNationality: ${data.respondentNationality}');
    debugPrint('countryOfOrigin: ${data.countryOfOrigin}');
    debugPrint('otherCountry: ${data.otherCountry}');
    debugPrint('correctedRespondentName: ${data.correctedRespondentName}');
    debugPrint('respondentOtherNames: ${data.respondentOtherNames}');
    
    // Validate respondent name correctness - handle both boolean and string comparisons
    final isNameCorrect = data.respondentNameCorrect is bool 
        ? data.respondentNameCorrect as bool
        : data.respondentNameCorrect == 'Yes';
        
    if (data.respondentNameCorrect == null) {
      errors.add('Please specify if the respondent name is correct');
    } else if (!isNameCorrect && (data.correctedRespondentName?.trim().isEmpty ?? true)) {
      errors.add('Please provide the correct respondent name');
    }
    
    // Validate nationality
    if (data.respondentNationality == null || data.respondentNationality!.trim().isEmpty) {
      errors.add('Please specify the respondent\'s nationality');
    } 
    // If nationality is not Ghanaian, require country of origin
    else if (data.respondentNationality == 'Non-Ghanaian') {
      if (data.countryOfOrigin == null || data.countryOfOrigin!.isEmpty) {
        errors.add('Please specify the country of origin');
      } else if (data.countryOfOrigin == 'Other' && (data.otherCountry?.isEmpty ?? true)) {
        errors.add('Please specify the other country');
      }
    }
    
    // Validate farm ownership - handle both boolean and string values
    final isFarmOwner = data.isFarmOwner is bool 
        ? (data.isFarmOwner as bool) ? 'Yes' : 'No'
        : data.isFarmOwner;
        
    if (isFarmOwner == null) {
      errors.add('Please specify if the respondent is the farm owner');
    } 
    // If not the owner, require ownership type
    else if (isFarmOwner == 'No' && (data.farmOwnershipType == null || data.farmOwnershipType!.isEmpty)) {
      errors.add('Please specify the farm ownership type');
    }
    
    return errors;
  }

  /// Validation for Owner Identification Page - All fields are required
  List<String> _validateOwnerIdentification() {
    final errors = <String>[];
    final data = _ownerData;

    // Validate owner's name
    if (data.ownerName.isEmpty) {
      errors.add('Please enter the farm owner\'s name');
    }

    // Validate owner's first name
    if (data.ownerFirstName.isEmpty) {
      errors.add('Please enter the farm owner\'s first name');
    }

    // Validate nationality
    if (data.nationality == null) {
      errors.add('Please specify the farm owner\'s nationality');
    } else if (data.nationality == 'Non-Ghanaian') {
      if (data.specificNationality == null) {
        errors.add('Please specify the country of origin');
      } else if (data.specificNationality == 'other' && data.otherNationality.isEmpty) {
        errors.add('Please specify the other country');
      }
    }

    // Validate years with owner
    if (data.yearsWithOwner.isEmpty) {
      errors.add('Please specify how many years the respondent has been working for the owner');
    } else {
      final years = int.tryParse(data.yearsWithOwner);
      if (years == null || years < 0) {
        errors.add('Please enter a valid number of years');
      }
    }

    return errors;
  }

  /// Validation for Workers in Farm Page - FIXED
  List<String> _validateWorkersInFarm() {
    final errors = <String>[];
    final data = _workersData;

    // Validate recruitment question
    if (data.hasRecruitedWorker == null) {
      errors.add('Please specify if you have recruited workers in the past year');
      return errors;
    }

    if (data.hasRecruitedWorker == '1') {
      // Validate recruitment type
      if (!data.permanentLabor && !data.casualLabor) {
        errors.add('Please specify at least one type of labor recruitment');
      }

      // Validate worker agreement type
      if (data.workerAgreementType == null || data.workerAgreementType!.isEmpty) {
        errors.add('Please specify the type of agreement with workers');
      } else if (data.workerAgreementType == 'Other (specify)' && data.otherAgreement.isEmpty) {
        errors.add('Please specify the other agreement type');
      }

      // Validate task clarification
      if (data.tasksClarified == null) {
        errors.add('Please specify if tasks were clarified during recruitment');
      }

      // Validate additional tasks
      if (data.additionalTasks == null) {
        errors.add('Please specify if workers perform additional tasks');
      }

      // Validate refusal action
      if (data.refusalAction == null) {
        errors.add('Please specify the action taken when workers refuse tasks');
      } else if (data.refusalAction == 'Other' && data.otherAgreement.isEmpty) {
        errors.add('Please specify the other refusal action');
      }

      // Validate salary payment frequency
      if (data.salaryPaymentFrequency == null) {
        errors.add('Please specify how often workers receive full salaries');
      }

      // Validate agreement responses only if they have workers
      final requiredStatements = [
        'salary_workers', 'recruit_1', 'recruit_2', 'recruit_3',
        'conditions_1', 'conditions_2', 'conditions_3', 'conditions_4', 'conditions_5',
        'leaving_1', 'leaving_2'
      ];

      for (final statementId in requiredStatements) {
        if (data.agreementResponses[statementId] == null) {
          errors.add('Please respond to all agreement statements');
          break; // Only show one error for agreements
        }
      }
    } else if (data.hasRecruitedWorker == '0') {
      // Validate follow-up question
      if (data.everRecruitedWorker == null) {
        errors.add('Please specify if you have ever recruited workers before');
      } else if (data.everRecruitedWorker == 'Yes') {
        // Validate agreement responses for past recruitment
        final requiredStatements = [
          'salary_workers', 'recruit_1', 'recruit_2', 'recruit_3',
          'conditions_1', 'conditions_2', 'conditions_3', 'conditions_4', 'conditions_5',
          'leaving_1', 'leaving_2'
        ];

        for (final statementId in requiredStatements) {
          if (data.agreementResponses[statementId] == null) {
            errors.add('Please respond to all agreement statements');
            break;
          }
        }
      }
    }

    return errors;
  }

  /// Validation for Adults Information Page - All fields are required
  List<String> _validateAdultsInformation() {
    final errors = <String>[];
    final data = _adultsData;

    // Validate number of adults (0 is a valid input)
    if (data.numberOfAdults == null) {
      errors.add('Please specify the number of adults in the household');
      return errors;
    }

    final numAdults = data.numberOfAdults!;
    if (numAdults < 0) {
      errors.add('Number of adults cannot be negative');
      return errors;
    }

    // If no adults, no need to validate members
    if (numAdults == 0) {
      return errors;
    }

    // Validate that we have the correct number of members
    if (data.members.length != numAdults) {
      errors.add('Please provide information for all $numAdults household members');
      return errors;
    }

    // Validate each household member
    for (int i = 0; i < data.members.length; i++) {
      final member = data.members[i];
      final memberNumber = i + 1;
      final memberName = member.name.trim().isNotEmpty ? member.name : 'Member $memberNumber';
      final memberErrors = <String>[];

      // Validate member name
      if (member.name.trim().isEmpty) {
        memberErrors.add('Full name is required');
      } else if (member.name.trim().split(' ').length < 2) {
        memberErrors.add('Please enter both first and last name');
      }

      // Validate producer details
      final producerErrors = _validateProducerDetails(
        member.producerDetails, 
        memberNumber, 
        memberName,
      );
      memberErrors.addAll(producerErrors);

      // Add member-specific errors with member context
      if (memberErrors.isNotEmpty) {
        errors.add('Household Member $memberNumber ($memberName):');
        errors.addAll(memberErrors.map((e) => '  • $e'));
      }
    }

    return errors;
  }

  /// Validation for Producer Details
  List<String> _validateProducerDetails(ProducerDetailsModel details, int memberNumber, String memberName) {
    final errors = <String>[];

    // Validate gender
    if (details.gender == null) {
      errors.add('Gender is required');
    }

    // Validate nationality
    if (details.nationality == null) {
      errors.add('Nationality is required');
    } else if (details.nationality == 'non_ghanaian') {
      if (details.selectedCountry == null) {
        errors.add('Country of origin is required for non-Ghanaians');
      } else if (details.selectedCountry == 'Other' && 
                (details.otherCountry == null || details.otherCountry!.isEmpty)) {
        errors.add('Please specify the other country');
      }
    }

    // Always validate year of birth
    if (details.yearOfBirth == null) {
      errors.add('Year of birth is required');
    } else {
      final currentYear = DateTime.now().year;
      if (details.yearOfBirth! < 1900 || details.yearOfBirth! > currentYear) {
        errors.add('Please enter a valid year of birth (1900-$currentYear)');
      }
    }

    // Validate relationship to respondent
    if (details.relationshipToRespondent == null) {
      errors.add('Relationship to respondent is required');
    } else if (details.relationshipToRespondent == 'other' && 
              (details.otherRelationship == null || details.otherRelationship!.isEmpty)) {
      errors.add('Please specify the relationship');
    }

    // Validate birth certificate
    if (details.hasBirthCertificate == null) {
      errors.add('Birth certificate information is required');
    }

    // Validate occupation
    if (details.occupation == null) {
      errors.add('Occupation is required');
    } else if (details.occupation == 'other' && 
              (details.otherOccupation == null || details.otherOccupation!.isEmpty)) {
      errors.add('Please specify the other occupation');
    }

    return errors;
  }

  /// Shows a validation error message to the user
  void _showValidationError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Update your data change handlers to check completion
  void _updateVisitInfoData(VisitInformationData newData) {
    setState(() {
      _visitInfoData = newData;
      // Clear validation errors when data changes
      _validationErrors[0] = [];
    });
    _notifyCanProceed();
  }

  void _updateOwnerData(IdentificationOfOwnerData newData) {
    setState(() {
      _ownerData = newData;
      // Clear validation errors when data changes
      _validationErrors[1] = [];
    });
    _notifyCanProceed();
  }

  void _updateWorkersData(WorkersInFarmData newData) {
    setState(() {
      _workersData = newData;
      // Clear validation errors when data changes
      _validationErrors[2] = [];
    });
    _notifyCanProceed();
  }

  void _updateAdultsData(AdultsInformationData newData) {
    setState(() {
      _adultsData = newData;
      // Clear validation errors when data changes
      _validationErrors[3] = [];
    });
    _notifyCanProceed();
  }

  Future<void> _submitForm() async {
    try {
      // Save all current data without triggering navigation
      await saveData();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      // Don't call widget.onSubmit() here as it might trigger navigation
      // Just save the data and stay on the current page
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving form: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      body: Column(
        children: [
          // Progress indicator for sub-pages
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: _Spacing.lg, vertical: _Spacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _goToPreviousPage,
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    _getSubPageTitle(_currentPageIndex),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _goToNextPage,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Page 1: Visit Information
                _VisitInformationContent(
                  currentPageIndex: _currentPageIndex,
                  data: _visitInfoData,
                  ownerData: _ownerData,
                  onDataChanged: _updateVisitInfoData,
                  workersData: _workersData,
                  adultsData: _adultsData,
                  validationErrors: _currentPageIndex == 0 ? _validationErrors[0] ?? [] : const [],
                  formKey: visitInfoFormKey,
                ),

                // Page 2: Owner Identification
                _IdentificationOfOwnerContent(
                  data: _ownerData,
                  onDataChanged: _updateOwnerData,
                  validationErrors: _currentPageIndex == 1 ? _validationErrors[1] ?? [] : const [],
                ),

                // Page 3: Workers in Farm
                _WorkersInFarmContent(
                  data: _workersData,
                  onDataChanged: _updateWorkersData,
                  validationErrors: _currentPageIndex == 2 ? _validationErrors[2] ?? [] : const [],
                ),

                // Page 4: Adults Information
                AdultsInformationContent(
                  data: _adultsData,
                  onDataChanged: _updateAdultsData,
                  validationErrors: _currentPageIndex == 3 ? _validationErrors[3] ?? [] : const [],
                  formKey: adultsFormKey,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSubPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Visit Information';
      case 1:
        return 'Owner Identification';
      case 2:
        return 'Workers Information';
      case 3:
        return 'Household Adults';
      default:
        return 'Farm Details';
    }
  }

  // Helper method to clear all validations
  void _clearAllValidations() {
    setState(() {
      for (int i = 0; i < _totalPages; i++) {
        _validationErrors[i] = [];
      }
    });
    _notifyCanProceed();
  }

  /// Saves the current page's data without validation
  Future<void> saveCurrentPageData() async {
    try {
      // Get the current page data and save it
      switch (_currentPageIndex) {
        case 0: // Visit Information
          if (visitInfoFormKey.currentState != null) {
            visitInfoFormKey.currentState!.save();
            // Trigger parent to save this page's data
            if (widget.onPageChanged != null) {
              widget.onPageChanged!(_currentPageIndex);
            }
          }
          break;
          
        case 1: // Owner Identification
          // The _ownerData is already updated through _updateOwnerData
          if (widget.onPageChanged != null) {
            widget.onPageChanged!(_currentPageIndex);
          }
          break;
          
        case 2: // Workers in Farm
          // The _workersData is already updated through _updateWorkersData
          if (widget.onPageChanged != null) {
            widget.onPageChanged!(_currentPageIndex);
          }
          break;
          
        case 3: // Adults Information
          // The _adultsData is already updated through _updateAdultsData
          if (widget.onPageChanged != null) {
            widget.onPageChanged!(_currentPageIndex);
          }
          break;
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Page data saved successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      return Future.value();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving page data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return Future.error(e);
    }
  }
}