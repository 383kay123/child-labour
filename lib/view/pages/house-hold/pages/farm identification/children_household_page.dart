import 'package:flutter/material.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart';

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
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final TextEditingController? children5To17Controller;
  final ChildrenHouseholdModel? initialData;
  final GlobalKey<FormState> formKey; // REQUIRED: Parent owns the key
  final void Function(ChildrenHouseholdModel)? onDataChanged;

  const ChildrenHouseholdPage({
    Key? key,
    required this.formKey,
    required this.producerDetails,
    required this.onNext,
    required this.onPrevious,
    this.children5To17Controller,
    this.initialData,
    this.onDataChanged,
  }) : super(key: key);

  @override
  ChildrenHouseholdPageState createState() => ChildrenHouseholdPageState();
}

class ChildrenHouseholdPageState extends State<ChildrenHouseholdPage>
    with AutomaticKeepAliveClientMixin {
  bool _isSaving = false;
  late ChildrenHouseholdModel _householdData;
  late final TextEditingController _numberOfChildrenController;
  late TextEditingController _children5To17Controller;
  bool _isOwnController = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateKeepAlive();
  }

  // Public method to get the household data
  ChildrenHouseholdModel getHouseholdData() => _householdData;

  // Public getter for the form key (from parent)
  GlobalKey<FormState> get formKey => widget.formKey;

  // Public method to validate the form
  bool validateForm() {
    return widget.formKey.currentState?.validate() ?? false;
  }

  @override
  void initState() {
    super.initState();
    _numberOfChildrenController = TextEditingController();
    _children5To17Controller = widget.children5To17Controller ?? TextEditingController();
    _isOwnController = widget.children5To17Controller == null;
    _initFromWidget();
  }

  @override
  void didUpdateWidget(ChildrenHouseholdPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if reference changed
    if (widget.children5To17Controller != oldWidget.children5To17Controller) {
      if (_isOwnController) {
        _children5To17Controller.dispose();
      }

      _children5To17Controller = widget.children5To17Controller ?? TextEditingController();
      _isOwnController = widget.children5To17Controller == null;

      if (_isOwnController && _householdData.children5To17 > 0) {
        _children5To17Controller.text = _householdData.children5To17.toString();
      }
    }

    // Re-init if initial data changed
    if (widget.initialData != oldWidget.initialData) {
      _initFromWidget();
    }
  }

  void _initFromWidget() {
    _householdData = widget.initialData ?? ChildrenHouseholdModel();

    _numberOfChildrenController.text = _householdData.numberOfChildren > 0
        ? _householdData.numberOfChildren.toString()
        : '';

    if (_isOwnController) {
      _children5To17Controller.text = _householdData.children5To17 > 0
          ? _householdData.children5To17.toString()
          : '';
    }
  }

  @override
  void dispose() {
    if (_isOwnController) {
      _children5To17Controller.dispose();
    }
    _numberOfChildrenController.dispose();
    super.dispose();
  }

  // Callback when child details are completed
  void _onChildDetailsComplete(int children5To17) {
    if (mounted) {
      setState(() {
        _householdData = _householdData.copyWith(children5To17: children5To17);
      });

      if (_isOwnController && _householdData.children5To17 > 0) {
        _children5To17Controller.text = _householdData.children5To17.toString();
      }

      widget.onNext();
    }
  }

  void _updateHouseholdData(ChildrenHouseholdModel newData) {
    if (mounted) {
      setState(() {
        _householdData = newData;
      });
      widget.onDataChanged?.call(newData);
    }
  }

  Future<void> _navigateToChildDetails(
      BuildContext context, int totalChildren) async {
    if (!mounted) return;

    try {
      int currentChild = _householdData.childrenDetails.length + 1;
      if (currentChild > totalChildren && totalChildren > 0) {
        currentChild = 1;
      }

      while (currentChild <= totalChildren) {
        if (!mounted) return;

        final existingChildIndex = _householdData.childrenDetails.indexWhere(
          (child) => child['childNumber'] == currentChild,
        );

        final existingChildData = existingChildIndex >= 0
            ? _householdData.childrenDetails[existingChildIndex]
            : null;

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildDetailsPage(
              childNumber: currentChild,
              totalChildren: totalChildren,
              childrenDetails: _householdData.childrenDetails,
              onComplete: (data) {
                // Extract the children5To17 from the data map
                final children5To17 = data != null && data['children5To17'] != null 
                    ? int.tryParse(data['children5To17'].toString()) ?? 0 
                    : 0;
                _onChildDetailsComplete(children5To17);
              },
            ),
          ),
        );

        if (!mounted) return;

        if (result == null || result['childData'] == null) {
          return;
        }

        if (mounted) {
          setState(() {
            final updatedChildren = List<Map<String, dynamic>>.from(_householdData.childrenDetails);
            final newChildData = Map<String, dynamic>.from(result['childData']);
            newChildData['childNumber'] = currentChild;

            if (existingChildIndex >= 0) {
              updatedChildren[existingChildIndex] = newChildData;
            } else {
              updatedChildren.add(newChildData);
            }

            _updateHouseholdData(
              _householdData.copyWith(childrenDetails: updatedChildren),
            );
          });
        }

        currentChild++;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }

    if (mounted) {
      setState(() {});
      widget.onNext();
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
    String? Function(String?)? validator,
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
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
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
          onChanged: (value) {
            onChanged?.call(value);
            setState(() {}); // Trigger UI update
          },
        ),
      ],
    );
  }

  void _submitForm() {
    if (!_householdData.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields correctly')),
      );
      return;
    }

    if (_householdData.hasChildrenInHousehold == 'Yes') {
      if (_householdData.numberOfChildren <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid number of children (greater than 0)')),
        );
        return;
      }

      if (_householdData.children5To17 < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid number of children aged 5-17')),
        );
        return;
      }

      if (_householdData.children5To17 > _householdData.numberOfChildren) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Number of children aged 5-17 cannot exceed total children')),
        );
        return;
      }

      if (_householdData.children5To17 > 0) {
        _navigateToChildDetails(context, _householdData.children5To17);
        return;
      }
    }

    if (mounted) {
      widget.onNext();
    }
  }

  Future<void> saveFormData() async {
    _householdData = _householdData.copyWith(
      hasChildrenInHousehold: _householdData.hasChildrenInHousehold,
      numberOfChildren: int.tryParse(_numberOfChildrenController.text) ?? 0,
      children5To17: int.tryParse(_children5To17Controller.text) ?? 0,
      childrenDetails: _householdData.childrenDetails,
    );

    if (widget.children5To17Controller != null) {
      widget.children5To17Controller!.text = _children5To17Controller.text;
    }
  }

  Future<bool> submitForm() async {
    if (widget.formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      try {
        await saveFormData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Progress saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required fields correctly'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // DO NOT call super.build(context) here — mixin handles it
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Form(
        key: widget.formKey, // Use parent-provided key
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question: Are there children?
                    _buildQuestionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Are there children living in the respondent\'s household?',
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
                                groupValue: _householdData.hasChildrenInHousehold,
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
                                    widget.children5To17Controller?.clear();
                                  });
                                },
                              ),
                              _buildRadioOption(
                                value: 'No',
                                groupValue: _householdData.hasChildrenInHousehold,
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
                                    widget.children5To17Controller?.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Number of children
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
                              widget.children5To17Controller?.clear();
                            });
                          },
                        ),
                      ),

                    // Children 5-17
                    if (_householdData.hasChildrenInHousehold == 'Yes' &&
                        _householdData.numberOfChildren > 0)
                      _buildQuestionCard(
                        child: Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: _buildTextField(
                            label:
                                'Out of ${_householdData.numberOfChildren} children, how many are between 5-17 years old?',
                            controller: _children5To17Controller,
                            hintText: 'Enter number of children (5-17 years)',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final n = int.tryParse(v);
                              if (n == null) return 'Invalid number';
                              if (n < 0) return 'Cannot be negative';
                              if (n > _householdData.numberOfChildren)
                                return 'Cannot exceed total children';
                              if (n > 19) return 'Max 19 allowed';
                              return null;
                            },
                            onChanged: (value) {
                              final count = int.tryParse(value) ?? 0;
                              if (count >= 0 &&
                                  count <= _householdData.numberOfChildren &&
                                  count <= 19) {
                                setState(() {
                                  _householdData =
                                      _householdData.copyWith(children5To17: count);
                                  widget.children5To17Controller?.text = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),

                    // Progress indicator
                    if (_householdData.children5To17 > 0)
                      _buildQuestionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Child Details Progress',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: _Spacing.md),
                            LinearProgressIndicator(
                              value: _householdData.childrenDetails.length /
                                  _householdData.children5To17,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                            ),
                            const SizedBox(height: _Spacing.sm),
                            Text(
                              '${_householdData.childrenDetails.length} of ${_householdData.children5To17} children details collected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                              ),
                            ),
                            if (_householdData.childrenDetails.isNotEmpty) ...[
                              const SizedBox(height: _Spacing.md),
                              Wrap(
                                spacing: 8,
                                children: _householdData.childrenDetails.map((child) {
                                  return Chip(
                                    label: Text('Child ${child['childNumber']}'),
                                    backgroundColor: theme.primaryColor.withOpacity(0.1),
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