import 'package:flutter/material.dart';

import '../../child_details_page.dart';

class ChildrenHouseholdPage extends StatefulWidget {
  final Map<String, dynamic> producerDetails;

  const ChildrenHouseholdPage({
    Key? key,
    required this.producerDetails,
  }) : super(key: key);

  @override
  _ChildrenHouseholdPageState createState() => _ChildrenHouseholdPageState();
}

class _ChildrenHouseholdPageState extends State<ChildrenHouseholdPage> {
  String? _hasChildrenInHousehold;
  final TextEditingController _numberOfChildrenController =
      TextEditingController();
  final TextEditingController _children5To17Controller =
      TextEditingController();
  final List<Map<String, dynamic>> _childrenDetails = [];

  Future<void> _navigateToChildDetails(
      BuildContext context, int totalChildren) async {
    for (int i = 1; i <= totalChildren; i++) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChildDetailsPage(
            childNumber: i,
            totalChildren: totalChildren,
          ),
        ),
      );

      if (result == null) {
        // User cancelled the operation
        return;
      }

      setState(() {
        _childrenDetails.add(result);
      });

      // If this is the last child, save and go back
      if (i == totalChildren) {
        final childrenData = {
          'hasChildrenInHousehold': _hasChildrenInHousehold,
          'numberOfChildren': _numberOfChildrenController.text.isNotEmpty
              ? int.tryParse(_numberOfChildrenController.text) ?? 0
              : 0,
          'children5To17': totalChildren,
          'childrenDetails': _childrenDetails,
        };

        if (mounted) {
          Navigator.pop(context, childrenData);
        }
      }
    }
  }

  void _submitForm() {
    if (_hasChildrenInHousehold == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option')),
      );
      return;
    }

    if (_hasChildrenInHousehold == 'Yes') {
      if (_numberOfChildrenController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the number of children')),
        );
        return;
      }

      final numberOfChildren =
          int.tryParse(_numberOfChildrenController.text) ?? 0;
      if (numberOfChildren < 1 || numberOfChildren > 19) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Number of children must be between 1 and 19')),
        );
        return;
      }

      // Validate 5-17 years field
      if (_children5To17Controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Please enter the number of children aged 5-17 years')),
        );
        return;
      }

      final children5To17 = int.tryParse(_children5To17Controller.text) ?? 0;

      if (children5To17 < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Number of children (5-17) cannot be negative')),
        );
        return;
      }

      if (children5To17 > numberOfChildren) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Number of children (5-17) cannot be more than total children')),
        );
        return;
      }

      // If there are children 5-17, navigate to child details
      if (children5To17 > 0) {
        _navigateToChildDetails(context, children5To17);
        return;
      }
    }

    // If no children 5-17 or 'No' was selected, return the data
    final childrenData = {
      'hasChildrenInHousehold': _hasChildrenInHousehold,
      'numberOfChildren': _hasChildrenInHousehold == 'Yes'
          ? int.tryParse(_numberOfChildrenController.text) ?? 0
          : 0,
      'children5To17': _hasChildrenInHousehold == 'Yes'
          ? int.tryParse(_children5To17Controller.text) ?? 0
          : 0,
      'childrenDetails': _childrenDetails,
    };

    // Return to previous screen with the collected data
    if (mounted) {
      Navigator.pop(context, childrenData);
    }
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Children in Household'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Question about children in household
              Text(
                'Are there children living in the respondent\'s household?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              _buildRadioOption(
                value: 'Yes',
                groupValue: _hasChildrenInHousehold,
                label: 'Yes',
                onChanged: (value) {
                  setState(() {
                    _hasChildrenInHousehold = value;
                  });
                },
              ),
              _buildRadioOption(
                value: 'No',
                groupValue: _hasChildrenInHousehold,
                label: 'No',
                onChanged: (value) {
                  setState(() {
                    _hasChildrenInHousehold = value;
                    _numberOfChildrenController.clear();
                    _children5To17Controller.clear();
                    _childrenDetails.clear();
                  });
                },
              ),

              if (_hasChildrenInHousehold == 'Yes') ...[
                const SizedBox(height: 16),
                Text(
                  'How many children are in the household?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _numberOfChildrenController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter number of children',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Clear the 5-17 field when total children changes
                      if (_children5To17Controller.text.isNotEmpty) {
                        _children5To17Controller.clear();
                        _childrenDetails.clear();
                      }
                    });
                  },
                ),

                // Children aged 5-17 field
                if (_numberOfChildrenController.text.isNotEmpty &&
                    int.tryParse(_numberOfChildrenController.text) != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Out of ${_numberOfChildrenController.text} children, how many are between 5-17 years old?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _children5To17Controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Enter number of children (5-17 years)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      // Clear children details when 5-17 count changes
                      if (_childrenDetails.isNotEmpty) {
                        setState(() {
                          _childrenDetails.clear();
                        });
                      }
                    },
                  ),
                ],
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('NEXT'),
                ),
              ),
            ],
          ),
        ));
  }
}
