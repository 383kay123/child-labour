import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/models/adult_info_model.dart';
import 'package:human_rights_monitor/controller/models/visit_information_model.dart';
import 'package:human_rights_monitor/controller/models/identification_of_owner_model.dart';
import 'adults_information_content.dart';
import 'package:human_rights_monitor/controller/models/workers_in_farm_model.dart';

import 'package:human_rights_monitor/view/theme/app_theme.dart';
import '../farm identification/adults_information_page.dart';

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
  final int initialPageIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;

  // Add this to check if we can go to next sub-page
  final ValueChanged<bool>? onCanProceedChanged;

  const CombinedFarmIdentificationPage({
    super.key,
    this.initialPageIndex = 0,
    required this.onPageChanged,
    this.onPrevious,
    this.onNext,
    this.onSubmit,
    this.onCanProceedChanged,
  });

  @override
  State<CombinedFarmIdentificationPage> createState() =>
      CombinedFarmIdentificationPageState();
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

  const _VisitInformationContent({
    Key? key,
    required this.currentPageIndex,
    required this.data,
    required this.ownerData,
    required this.onDataChanged,
    required this.workersData,
    required this.adultsData,
    required this.validationErrors,
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
    _respondentNameCorrect = widget.data.respondentNameCorrect;
    _respondentNationality = widget.data.respondentNationality;
    _countryOfOrigin = widget.data.countryOfOrigin;
    _isFarmOwner = widget.data.isFarmOwner;
    _farmOwnershipType = widget.data.farmOwnershipType;
    _respondentNameController.text = widget.data.correctedRespondentName;
    _respondentOtherNamesController.text = widget.data.respondentOtherNames;
    _otherCountryController.text = widget.data.otherCountry;
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

  // Add this method to CombinedFarmIdentificationPageState class
void animateToPage(int page, {Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.easeInOut}) {
  if (_pageController.hasClients) {
    _pageController.animateToPage(
      page,
      duration: duration,
      curve: curve,
    );
  }
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
                      labelText: 'If Non Ghanaian , specify country of origin',
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
                    onChanged: (value) {
                      setState(() {
                        _countryOfOrigin = value;
                        _updateData();
                      });
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
        respondentNameCorrect: _respondentNameCorrect,
        respondentNationality: _respondentNationality,
        countryOfOrigin: _countryOfOrigin,
        isFarmOwner: _isFarmOwner,
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

class CombinedFarmIdentificationPageState
    extends State<CombinedFarmIdentificationPage> {
  late PageController _pageController;
  // Public getter for the page controller
  PageController get pageController => _pageController;
  late int _currentPageIndex;
  final int _totalPages = 4;

  // Individual models for each page
  VisitInformationData _visitInfoData = VisitInformationData.empty();
  IdentificationOfOwnerData _ownerData = IdentificationOfOwnerData.empty();
  WorkersInFarmData _workersData = WorkersInFarmData.empty();
  AdultsInformationData _adultsData = AdultsInformationData.empty();

  // Validation state
  final Map<int, List<String>> _validationErrors = {};

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

  void _handlePageChanged(int index) {
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

  void _goToNextPage() {
    // Validate current page first
    if (!validateCurrentPage()) {
      return;
    }
    
    // If we get here, validation passed - proceed to next page
    if (_currentPageIndex < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (widget.onNext != null) {
      widget.onNext!();
    }
    _notifyCanProceed();
  }

  void _goToPreviousPage() {
    // Clear validation errors when going back
    setState(() {
      _validationErrors[_currentPageIndex] = [];
    });
    
    if (_currentPageIndex > 0) {
      final previousPageIndex = _currentPageIndex - 1;
      _pageController.animateToPage(
        previousPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // This is the first sub-page, notify parent to go to previous main page
      widget.onPrevious?.call();
    }
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

  /// Validation for Visit Information Page - FIXED
  List<String> _validateVisitInformation() {
    final errors = <String>[];
    final data = _visitInfoData;
    
    // Debug: Log current visit info data
    debugPrint('=== Visit Information Validation ===');
    debugPrint('Respondent Name Correct: ${data.respondentNameCorrect}');
    debugPrint('Corrected Name: ${data.correctedRespondentName}');
    debugPrint('Nationality: ${data.respondentNationality}');
    debugPrint('Country of Origin: ${data.countryOfOrigin}');
    debugPrint('Other Country: ${data.otherCountry}');
    debugPrint('Is Farm Owner: ${data.isFarmOwner}');
    debugPrint('Farm Ownership Type: ${data.farmOwnershipType}');
    debugPrint('===================================');

    // Validate respondent name correctness
    if (data.respondentNameCorrect == null) {
      errors.add('Please specify if the respondent name is correct');
    } else if (data.respondentNameCorrect == 'No') {
      if (data.correctedRespondentName.isEmpty) {
        errors.add('Please provide the correct respondent name');
      }
    }

    // Validate nationality
    if (data.respondentNationality == null) {
      errors.add('Please specify the respondent\'s nationality');
    } else if (data.respondentNationality == 'Non-Ghanaian') {
      if (data.countryOfOrigin == null) {
        errors.add('Please specify the country of origin');
      } else if (data.countryOfOrigin == 'Other' && data.otherCountry.isEmpty) {
        errors.add('Please specify the other country of origin');
      }
    }

    // Validate farm ownership
    if (data.isFarmOwner == null) {
      errors.add('Please specify if the respondent is the farm owner');
    } else if (data.farmOwnershipType == null) {
      errors.add('Please specify the farm ownership type');
    }

    return errors;
  }

  /// Validation for Owner Identification Page - FIXED
  List<String> _validateOwnerIdentification() {
    final errors = <String>[];
    final data = _ownerData;

    // Validate owner name
    if (data.ownerName.isEmpty) {
      errors.add('Please enter the name of the owner');
    }

    // Validate owner first name
    if (data.ownerFirstName.isEmpty) {
      errors.add('Please enter the first name of the owner');
    }

    // Validate nationality
    if (data.nationality == null) {
      errors.add('Please specify the owner\'s nationality');
    } else if (data.nationality == 'national') {
      if (data.specificNationality == null) {
        errors.add('Please specify the specific nationality');
      } else if (data.specificNationality == 'other' && data.otherNationality.isEmpty) {
        errors.add('Please specify the other nationality');
      }
    }

    // Validate years with owner
    if (data.yearsWithOwner.isEmpty) {
      errors.add('Please specify how many years with current owner');
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

  /// Validation for Adults Information Page - FIXED
  List<String> _validateAdultsInformation() {
    final errors = <String>[];
    final data = _adultsData;

    // Validate number of adults
    if (data.numberOfAdults == null) {
      errors.add('Please specify the number of adults in the household');
      return errors;
    }

    if (data.numberOfAdults! < 1) {
      errors.add('There must be at least 1 adult in the household');
      return errors;
    }

    // Validate that we have the correct number of members
    if (data.members.length != data.numberOfAdults) {
      errors.add('Please provide information for all ${data.numberOfAdults} household members');
      return errors;
    }

    // Validate each household member
    for (int i = 0; i < data.members.length; i++) {
      final member = data.members[i];
      final memberNumber = i + 1;

      // Validate member name
      if (member.name.trim().isEmpty) {
        errors.add('Please enter the full name for household member $memberNumber');
      }

      // Validate basic member details
      final producerErrors = _validateProducerDetails(member.producerDetails, memberNumber, member.name);
      errors.addAll(producerErrors);
    }

    return errors;
  }

  /// Validation for Producer Details
  List<String> _validateProducerDetails(ProducerDetailsModel details, int memberNumber, String memberName) {
    final errors = <String>[];

    // Validate gender
    if (details.gender == null) {
      errors.add('Please specify gender for $memberName (Household Member $memberNumber)');
    }

    // Validate nationality
    if (details.nationality == null) {
      errors.add('Please specify nationality for $memberName (Household Member $memberNumber)');
    } else if (details.nationality == 'non_ghanaian') {
      if (details.selectedCountry == null) {
        errors.add('Please specify country of origin for $memberName (Household Member $memberNumber)');
      } else if (details.selectedCountry == 'Other' && (details.selectedCountry?.isEmpty ?? true)) {
        errors.add('Please specify the other country for $memberName (Household Member $memberNumber)');
      }
    } else {
      final currentYear = DateTime.now().year;
      if (details.yearOfBirth! < 1900 || details.yearOfBirth! > currentYear) {
        errors.add('Please enter a valid year of birth for $memberName (Household Member $memberNumber)');
      }
    }

    return errors;
  }

  void _showValidationError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
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

  void _submitForm() {
    // Validate all pages before submission
    bool allPagesValid = true;
    List<String> allErrors = [];

    for (int i = 0; i < _totalPages; i++) {
      _currentPageIndex = i;
      final errors = getCurrentPageErrors();
      if (errors.isNotEmpty) {
        allPagesValid = false;
        allErrors.addAll(errors);
        _showValidationError(errors.first);
        break;
      }
    }

    if (!allPagesValid) {
      return;
    }

    final allData = {
      'visitInformation': _visitInfoData.toMap(),
      'ownerIdentification': _ownerData.toMap(),
      'workersInFarm': _workersData.toMap(),
      'adultsInformation': _adultsData.toMap(),
    };

    print('Submitting all data: $allData');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Submit Survey',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
        content: Text(
            'Are you sure you want to submit the farm identification survey?',
            style: GoogleFonts.inter(color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Survey submitted successfully!',
                      style: GoogleFonts.inter()),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
              widget.onSubmit?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                Text('Submit', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
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
                Text(
                  'Step ${_currentPageIndex + 1} of $_totalPages',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
                Text(
                  _getSubPageTitle(_currentPageIndex),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _handlePageChanged,
              children: [
                // Page 1: Visit Information
                _VisitInformationContent(
                  currentPageIndex: _currentPageIndex,
                  data: _visitInfoData,
                  ownerData: _ownerData,
                  onDataChanged: _updateVisitInfoData,
                  workersData: _workersData,
                  adultsData: _adultsData,
                  validationErrors: _validationErrors[0] ?? [],
                ),

                // Page 2: Identification of Owner
                _IdentificationOfOwnerContent(
                  data: _ownerData,
                  onDataChanged: _updateOwnerData,
                  validationErrors: _validationErrors[1] ?? [],
                ),

                // Page 3: Workers in Farm
                _WorkersInFarmContent(
                  data: _workersData,
                  onDataChanged: _updateWorkersData,
                  validationErrors: _validationErrors[2] ?? [],
                ),

                // Page 4: Adults Information
                AdultsInformationContent(
                  data: _adultsData,
                  onDataChanged: _updateAdultsData,
                  validationErrors: _validationErrors[3] ?? [],
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
}