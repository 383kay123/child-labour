import 'package:flutter/material.dart';


import '../../../../../controller/models/childrenhouseholdmodel.dart';
import '../../../../theme/app_theme.dart';
import '../../child_details_page.dart';

/// A collection of reusable spacing constants for consistent UI layout.
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class ChildrenHouseholdPage extends StatefulWidget {
  final Map<String, dynamic> producerDetails;
  final Function(int)? onComplete;
  final TextEditingController? children5To17Controller;
  final ChildrenHouseholdModel? initialData;

  const ChildrenHouseholdPage({
    Key? key,
    required this.producerDetails,
    this.onComplete,
    this.children5To17Controller,
    this.initialData,
  }) : super(key: key);

  @override
  _ChildrenHouseholdPageState createState() => _ChildrenHouseholdPageState();
}

class _ChildrenHouseholdPageState extends State<ChildrenHouseholdPage> {
  final _formKey = GlobalKey<FormState>();
  late ChildrenHouseholdModel _householdData;
  late final TextEditingController _numberOfChildrenController;
  late final TextEditingController _children5To17Controller;
  bool _isOwnController = false;
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Initialize with provided data or create empty
    _householdData = widget.initialData ?? ChildrenHouseholdModel.empty();

    // Initialize controllers
    _numberOfChildrenController = TextEditingController(
        text: _householdData.numberOfChildren > 0
            ? _householdData.numberOfChildren.toString()
            : '');

    _children5To17Controller = widget.children5To17Controller ??
        TextEditingController(
            text: _householdData.children5To17 > 0
                ? _householdData.children5To17.toString()
                : '');

    _isOwnController = widget.children5To17Controller == null;
  }

  @override
  void dispose() {
    // Only dispose if we created the controller ourselves
    if (_isOwnController) {
      _children5To17Controller.dispose();
    }
    _numberOfChildrenController.dispose();
    super.dispose();
  }

// In the parent widget that shows ChildrenHouseholdPage
void _onChildDetailsComplete(int children5To17) {
  setState(() {
    // Update your state with the returned data
    _householdData = _householdData.copyWith(children5To17: children5To17);
  });
}

// Add this method to ensure the state is updated when the widget is updated
@override
void didUpdateWidget(ChildrenHouseholdPage oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.initialData != oldWidget.initialData) {
    setState(() {
      _householdData = widget.initialData ?? ChildrenHouseholdModel.empty();
      // Update controllers with new data
      _numberOfChildrenController.text = _householdData.numberOfChildren > 0
          ? _householdData.numberOfChildren.toString()
          : '';
      if (_isOwnController) {
        _children5To17Controller.text = _householdData.children5To17 > 0
            ? _householdData.children5To17.toString()
            : '';
      }
    });
  }
}
  void _updateHouseholdData(ChildrenHouseholdModel newData) {
    setState(() {
      _householdData = newData;
    });
  }

  Future<void> _navigateToChildDetails(
      BuildContext context, int totalChildren) async {
    int currentChild = _householdData.childrenDetails.length + 1;

    while (currentChild <= totalChildren) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChildDetailsPage(
            childNumber: currentChild,
            totalChildren: totalChildren,
            childrenDetails: _householdData.childrenDetails,
          ),
        ),
      );

      if (result == null || result['childData'] == null) {
        // User cancelled the operation or there was an error
        return;
      }

      // Update or add the child data to our list
      setState(() {
        final existingIndex = _householdData.childrenDetails.indexWhere(
            (child) =>
                child['childNumber'] == result['childData']['childNumber']);

        final updatedChildren =
            List<Map<String, dynamic>>.from(_householdData.childrenDetails);

        if (existingIndex >= 0) {
          // Update existing child data
          updatedChildren[existingIndex] = result['childData'];
        } else {
          // Add new child data
          updatedChildren.add(result['childData']);
        }

        _householdData =
            _householdData.copyWith(childrenDetails: updatedChildren);
      });

      // Check if we should navigate to next child
      if (result['navigateToNextChild'] == true &&
          result['nextChildNumber'] != null) {
        currentChild = result['nextChildNumber'];
      } else {
        // Return to children household page
        break;
      }
    }

    // All children processed, return to parent
    if (mounted) {
      // Call onComplete callback if provided
      widget.onComplete?.call(_householdData.children5To17);
    }
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
    ValueChanged<String>? onChanged,
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
          onChanged: (value) {
            if (onChanged != null) {
              onChanged(value);
            }
            setState(() {}); // Trigger a rebuild to update the UI
          },
        ),
      ],
    );
  }

  void _submitForm() {
    // Validate form using model's validation
    if (!_householdData.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
        ),
      );
      return;
    }

    if (_householdData.hasChildrenInHousehold == 'Yes') {
      // Validate number of children
      if (_householdData.numberOfChildren <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please enter a valid number of children (greater than 0)'),
          ),
        );
        return;
      }

      // Validate children 5-17
      if (_householdData.children5To17 < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid number of children aged 5-17'),
          ),
        );
        return;
      }

      if (_householdData.children5To17 > _householdData.numberOfChildren) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Number of children aged 5-17 cannot be greater than total number of children',
            ),
          ),
        );
        return;
      }

      // If there are children 5-17, navigate to child details
      if (_householdData.children5To17 > 0) {
        _navigateToChildDetails(context, _householdData.children5To17);
        return;
      }
    }

    // All validations passed, return the data
    if (mounted) {
      // Call onComplete callback if provided
      widget.onComplete?.call(_householdData.children5To17);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question about children in household
                    _buildQuestionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Are there children living in the respondent\'s household?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: _Spacing.md),
                          Wrap(
                            spacing: 20,
                            children: [
                              _buildRadioOption(
                                value: 'Yes',
                                groupValue:
                                    _householdData.hasChildrenInHousehold,
                                label: 'Yes',
                                onChanged: (value) {
                                  setState(() {
                                    _householdData = _householdData.copyWith(
                                      hasChildrenInHousehold: value,
                                      numberOfChildren: 0,
                                      children5To17: 0,
                                      childrenDetails: [],
                                    );
                                    _numberOfChildrenController.clear();
                                    _children5To17Controller.clear();
                                    // Update the main controller
                                    widget.children5To17Controller?.clear();
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'No',
                                groupValue:
                                    _householdData.hasChildrenInHousehold,
                                label: 'No',
                                onChanged: (value) {
                                  setState(() {
                                    _householdData = _householdData.copyWith(
                                      hasChildrenInHousehold: value,
                                      numberOfChildren: 0,
                                      children5To17: 0,
                                      childrenDetails: [],
                                    );
                                    _numberOfChildrenController.clear();
                                    _children5To17Controller.clear();
                                    // Update the main controller
                                    widget.children5To17Controller?.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Number of children field (conditional)
                    if (_householdData.hasChildrenInHousehold == 'Yes')
                      _buildQuestionCard(
                        child: _buildTextField(
                          label: 'How many children are in the household?',
                          controller: _numberOfChildrenController,
                          hintText: 'Enter number of children',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final count = int.tryParse(value) ?? 0;
                            setState(() {
                              _householdData = _householdData.copyWith(
                                numberOfChildren: count,
                                children5To17: 0,
                                childrenDetails: [],
                              );
                              _children5To17Controller.clear();
                              // Update the main controller when this field changes
                              widget.children5To17Controller?.clear();
                            });
                          },
                        ),
                      ),

                    // Children aged 5-17 field (conditional)
                    if (_householdData.hasChildrenInHousehold == 'Yes' &&
                        _householdData.numberOfChildren > 0)
                      _buildQuestionCard(
                        child: _buildTextField(
                          label:
                              'Out of ${_householdData.numberOfChildren} children, how many are between 5-17 years old?',
                          controller: _children5To17Controller,
                          hintText: 'Enter number of children (5-17 years)',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final count = int.tryParse(value) ?? 0;
                            setState(() {
                              _householdData =
                                  _householdData.copyWith(children5To17: count);
                              // Update the main controller in real-time
                              widget.children5To17Controller?.text = value;
                            });
                          },
                        ),
                      ),

                    // Progress indicator when collecting child details
                    if (_householdData.children5To17 > 0)
                      _buildQuestionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Child Details Progress',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: _Spacing.md),
                            LinearProgressIndicator(
                              value: _householdData.childrenDetails.length /
                                  _householdData.children5To17,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: _Spacing.sm),
                            Text(
                              '${_householdData.childrenDetails.length} of ${_householdData.children5To17} children details collected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                            if (_householdData.childrenDetails.isNotEmpty) ...[
                              const SizedBox(height: _Spacing.md),
                              Wrap(
                                spacing: 8,
                                children:
                                    _householdData.childrenDetails.map((child) {
                                  return Chip(
                                    label:
                                        Text('Child ${child['childNumber']}'),
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),

                    const SizedBox(height: _Spacing.lg),
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
