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
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final TextEditingController? children5To17Controller;
  final ChildrenHouseholdModel? initialData;
  final GlobalKey<FormState>? formKey;

  const ChildrenHouseholdPage({
    Key? key,
    required this.producerDetails,
    required this.onNext,
    required this.onPrevious,
    this.children5To17Controller,
    this.initialData,
    this.formKey,
  }) : super(key: key);

  // Add this method to get the state from the context
  static ChildrenHouseholdPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<ChildrenHouseholdPageState>();
  }

  @override
  ChildrenHouseholdPageState createState() => ChildrenHouseholdPageState();
}

class ChildrenHouseholdPageState extends State<ChildrenHouseholdPage> with AutomaticKeepAliveClientMixin {
  bool _isSaving = false;
  late final GlobalKey<FormState> _formKey;
  late ChildrenHouseholdModel _householdData;
  late final TextEditingController _numberOfChildrenController;
  late final TextEditingController _children5To17Controller;
  bool _isOwnController = false;
  
  @override
  bool get wantKeepAlive => true;

  // Public method to get the household data
  ChildrenHouseholdModel getHouseholdData() => _householdData;
  
  // Public getter for the form key
  GlobalKey<FormState> get formKey => _formKey;
  
  // Public method to validate the form
  bool validateForm() {
    if (_formKey.currentState == null) return false;
    return _formKey.currentState!.validate();
  }

  @override
  void initState() {
    super.initState();
    // Always create a new form key to prevent duplicates
    _formKey = GlobalKey<FormState>();
    _initFromWidget();
  }

  @override
  void didUpdateWidget(ChildrenHouseholdPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-initialize if the initialData changes
    if (widget.initialData != oldWidget.initialData) {
      _initFromWidget();
    }
    
    // Update the controller if it was changed from outside
    if (widget.children5To17Controller != oldWidget.children5To17Controller) {
      _children5To17Controller = widget.children5To17Controller ?? TextEditingController();
      _isOwnController = widget.children5To17Controller == null;
    }
  }

  void _initFromWidget() {
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

  // Callback when child details are completed
  void _onChildDetailsComplete(int children5To17) {
    if (mounted) {
      setState(() {
        // Update your state with the returned data
        _householdData = _householdData.copyWith(children5To17: children5To17);
      });
      
      // Update the controller if needed
      if (_isOwnController && _householdData.children5To17 > 0) {
        _children5To17Controller.text = _householdData.children5To17.toString();
      }
      
      // After collecting child details, proceed to next page
      widget.onNext();
    }
  }

  void _updateHouseholdData(ChildrenHouseholdModel newData) {
    setState(() {
      _householdData = newData;
    });
  }

  Future<void> _navigateToChildDetails(
      BuildContext context, int totalChildren) async {
    if (!mounted) return; // Check if widget is still mounted

    try {
      // Start with the first child that doesn't have details yet
      int currentChild = _householdData.childrenDetails.length + 1;
      
      // If all children have details, start from the first one
      if (currentChild > totalChildren && totalChildren > 0) {
        currentChild = 1;
      }

      while (currentChild <= totalChildren) {
        if (!mounted) return; // Check before async operation

        // Find if we already have details for this child
        final existingChildIndex = _householdData.childrenDetails.indexWhere(
          (child) => child['childNumber'] == currentChild
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
              onComplete: (data) => _onChildDetailsComplete(data),
            ),
          ),
        );

        if (!mounted) return; // Check after async operation

        // If user cancels or there's an error, return to the list
        if (result == null || result['childData'] == null) {
          return;
        }

        // Update or add the child data to our list
        if (mounted) {
          setState(() {
            final updatedChildren = List<Map<String, dynamic>>.from(_householdData.childrenDetails);
            final newChildData = Map<String, dynamic>.from(result['childData']);
            
            // Ensure the child number is set correctly
            newChildData['childNumber'] = currentChild;

            if (existingChildIndex >= 0) {
              // Update existing child data
              updatedChildren[existingChildIndex] = newChildData;
            } else {
              // Add new child data
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
      // Call onNext to proceed to the next page
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

    // All validations passed, proceed to next page
    if (mounted) {
      widget.onNext();
    }
  }

  // Save the current form data without navigation
  Future<void> saveFormData() async {
    // Update the household data with current form values
    _householdData = _householdData.copyWith(
      hasChildrenInHousehold: _householdData.hasChildrenInHousehold,
      numberOfChildren: int.tryParse(_numberOfChildrenController.text) ?? 0,
      children5To17: int.tryParse(_children5To17Controller.text) ?? 0,
      // Preserve existing children details
      childrenDetails: _householdData.childrenDetails,
    );

    // Update the parent's controller if it exists
    if (widget.children5To17Controller != null) {
      widget.children5To17Controller!.text = _children5To17Controller.text;
    }
  }

  // Public method to submit the form (save only, no navigation)
  Future<bool> submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      try {
        saveFormData();
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Children in Household'),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Theme.of(context).primaryColor,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   actions: [
      //     // Save button
      //     _isSaving
      //         ? const Padding(
      //             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      //             child: Center(
      //               child: SizedBox(
      //                 width: 20,
      //                 height: 20,
      //                 child: CircularProgressIndicator(
      //                   strokeWidth: 2,
      //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      //                 ),
      //               ),
      //             ),
      //           )
      //         : IconButton(
      //             icon: const Icon(Icons.save, color: Colors.white),
      //             tooltip: 'Save',
      //             onPressed: submitForm,
      //           ),
      //   ],
      // ),
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
                        child: Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: _buildTextField(
                            label:
                                'Out of ${_householdData.numberOfChildren} children, how many are between 5-17 years old?',
                            controller: _children5To17Controller,
                            hintText: 'Enter number of children (5-17 years)',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the number of children';
                              }
                              final count = int.tryParse(value);
                              if (count == null) {
                                return 'Please enter a valid number';
                              }
                              if (count < 0) {
                                return 'Number cannot be negative';
                              }
                              if (count > _householdData.numberOfChildren) {
                                return 'Cannot exceed total number of children (${_householdData.numberOfChildren})';
                              }
                              if (count > 19) {
                                return 'Maximum allowed is 19';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                final count = int.tryParse(value) ?? 0;
                                if (count >= 0 && count <= _householdData.numberOfChildren && count <= 19) {
                                  setState(() {
                                    _householdData = _householdData.copyWith(children5To17: count);
                                    // Update the main controller in real-time
                                    widget.children5To17Controller?.text = value;
                                  });
                                }
                              } else {
                                setState(() {
                                  _householdData = _householdData.copyWith(children5To17: 0);
                                  widget.children5To17Controller?.clear();
                                });
                              }
                            },
                          ),
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
