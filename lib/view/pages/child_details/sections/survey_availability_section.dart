import 'package:flutter/material.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';
import 'base_section.dart';

class SurveyAvailabilitySection extends StatefulWidget {
  final bool? isFarmerChild;
  final ValueChanged<bool?> onFarmerChildChanged;
  final TextEditingController childNumberController;
  final ValueChanged<bool?>? onSurveyAvailabilityChanged;

  const SurveyAvailabilitySection({
    Key? key,
    required this.isFarmerChild,
    required this.onFarmerChildChanged,
    required this.childNumberController,
    this.onSurveyAvailabilityChanged,
  }) : super(key: key);

  @override
  _SurveyAvailabilitySectionState createState() => _SurveyAvailabilitySectionState();
  
  static _SurveyAvailabilitySectionState? of(BuildContext context) {
    return context.findAncestorStateOfType<_SurveyAvailabilitySectionState>();
  }
}

class _SurveyAvailabilitySectionState extends State<SurveyAvailabilitySection> {
  bool? get canBeSurveyedNow => _canBeSurveyedNow;
  final TextEditingController _childNumberController = TextEditingController();
  final TextEditingController _otherRespondentTypeController = TextEditingController();
  String? _respondentType;
  final Map<String, bool> _surveyNotPossibleReasons = {
    'The child is at school': false,
    'The child has gone to work on the cocoa farm': false,
    'Child is busy doing housework': false,
    'Child works outside the household': false,
    'The child is too young': false,
    'The child is sick': false,
    'The child has travelled': false,
    'The child has gone out to play': false,
    'Other': false,
  };
  final TextEditingController _otherReasonController = TextEditingController();
  bool? _canBeSurveyedNow;

  @override
  void initState() {
    super.initState();
    // Initialize with default value and notify parent
    _updateCanBeSurveyedNow(true);
  }

  void _updateCanBeSurveyedNow(bool? value) {
    if (_canBeSurveyedNow != value) {
      setState(() {
        _canBeSurveyedNow = value;
        
        // Reset all form fields when survey availability changes
        if (value == true) {
          // Clear all checkboxes
          for (var key in _surveyNotPossibleReasons.keys.toList()) {
            _surveyNotPossibleReasons[key] = false;
          }
          _otherReasonController.clear();
          _respondentType = null;
          _otherRespondentTypeController.clear();
        } else if (value == false) {
          // Keep the fields as they are when switching to "No"
        }
      });
      // Notify parent widget if callback is provided
      widget.onSurveyAvailabilityChanged?.call(value);
    }
  }

  @override
  void dispose() {
    _childNumberController.dispose();
    _otherReasonController.dispose();
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

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
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
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).brightness == Brightness.dark 
        ? AppTheme.darkTextPrimary 
        : AppTheme.textPrimary,
  ),
        ),
        const SizedBox(height: 8),
        ...values.entries.map((entry) {
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              entry.key,
             
   style:theme.textTheme.bodyLarge?.copyWith(
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
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
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

  @override
  Widget build(BuildContext context) {
    return BaseSection(
      title: 'Survey Availability',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          

          // Farmer's Children Question - Now in a card
          _buildQuestionCard(
            context: context,
            child: _buildModernRadioGroup<bool>(
              context: context,
              question: 'Is the child among the list of children declared in the cover to be the farmer\'s children?',
              groupValue: widget.isFarmerChild,
              onChanged: widget.onFarmerChildChanged,
              options: const [
                {'value': true, 'title': 'Yes'},
                {'value': false, 'title': 'No'},
              ],
            ),
          ),

          // Info Card
          _buildQuestionCard(
            context: context,
            child: _buildInfoCard('FARMER CHILDREN LIST'),
          ),

          // Child Number Input - Only show if child is among farmer's children
          if (widget.isFarmerChild == true) ...[
            _buildQuestionCard(
              context: context,
              child: _buildModernTextField(
                label: 'Enter the number attached to the child name in the cover so we can identify the child in question:',
                controller: _childNumberController,
                keyboardType: TextInputType.number,
                hintText: 'Enter child number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the child number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 18),
            _buildModernRadioGroup<bool>(
                context: context,
                question: 'Can the child be surveyed now?',
                groupValue: _canBeSurveyedNow,
                onChanged: (value) {
                  void _updateCanBeSurveyedNow(bool? value) {
                    if (_canBeSurveyedNow != value) {
                      setState(() {
                        _canBeSurveyedNow = value;
                      });
                      widget.onSurveyAvailabilityChanged?.call(value);
                    }
                  }
                  _updateCanBeSurveyedNow(value);
                },
                options: [
                  {'value': true, 'title': 'Yes'},
                  {'value': false, 'title': 'No'},
                ],
              ),

              // Show reasons if survey is not possible
              if (_canBeSurveyedNow == false) ...[
                const SizedBox(height: 24),
                _buildModernCheckboxGroup(
                  question: 'If not, what are the reasons?',
                  values: _surveyNotPossibleReasons,
                  onChanged: (String reason, bool? value) {
                    setState(() {
                      _surveyNotPossibleReasons[reason] = value ?? false;
                      // Clear other reason text when unchecking "Other"
                      if (reason == 'Other' && (value == false || value == null)) {
                        _otherReasonController.clear();
                      }
                    });
                  },
                ),
                // Show text field for other reason if "Other" is checked
                if (_surveyNotPossibleReasons['Other'] == true) ...[
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: 'Please specify other reason',
                    controller: _otherReasonController,
                    hintText: 'Enter the reason...',
                  ),
                ],
              ],
SizedBox(height: 20,),
               // Respondent information
               if(_canBeSurveyedNow == false) ...[
                const SizedBox(height: 24),
                _buildModernRadioGroup<String>(
                  context: context,
                  question:
                      'Who is answering for the child since he/she is not available?',
                  groupValue: _respondentType,
                  onChanged: (value) {
                    setState(() {
                      _respondentType = value;
                    });
                  },
                  options: [
                    {
                      'value': 'the_parents_or_legal_guardians',
                      'title': 'The parents or legal guardians'
                    },
                    {
                      'value': 'another_family_member',
                      'title': 'Another family member of the child'
                    },
                    {
                      'value': 'child_siblings',
                      'title': 'One of the child\'s siblings'
                    },
                    {'value': 'other', 'title': 'Other'},
                  ],
                ),

                if (_respondentType != null) ...[
                  const SizedBox(height: 16),
                  if (_respondentType == 'other') ...[
                    _buildModernTextField(
                      label: 'Please specify',
                      controller: _otherRespondentTypeController,
                      validator: (value) {
                        if (_respondentType == 'other' &&
                            (value == null || value.isEmpty)) {
                          return 'Please specify who is answering for the child';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ],
            ],
        ]
          ),
        );
    
  
  }
}
  
  