import 'package:flutter/material.dart';

class AdultsInformationPage extends StatefulWidget {
  const AdultsInformationPage({super.key});

  @override
  State<AdultsInformationPage> createState() => _AdultsInformationPageState();
}

class _AdultsInformationPageState extends State<AdultsInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adultsCountController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  int? _numberOfAdults;
  String? _isGhanaCitizen;
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _ghanaCardIdControllers = [];
  final List<bool?> _hasGhanaCard = [];

  @override
  void initState() {
    super.initState();
    _adultsCountController.addListener(_onCountChanged);
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
    _nationalityController.dispose();

    for (var controller in _nameControllers) {
      controller.dispose();
    }

    for (var controller in _ghanaCardIdControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _saveAndReturn() {
    if (_formKey.currentState!.validate()) {
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
          const SnackBar(
            content: Text('Please enter names for all household members'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate Ghana citizenship is selected
      if (_isGhanaCitizen == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select citizenship status'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate nationality is provided if not Ghanaian
      if (_isGhanaCitizen == 'No' &&
          _nationalityController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please specify nationality'),
            backgroundColor: Colors.red,
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

      Navigator.pop(context, {
        'count': count,
        'names': names,
        'adultDetails': adultDetails,
        'isGhanaCitizen': _isGhanaCitizen == 'Yes',
        'nationality':
            _isGhanaCitizen == 'No' ? _nationalityController.text.trim() : null,
      });
    }
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Information on Adults in Household'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number of adults input
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total number of adults in the household '
                        '(producer/manager/owner not included)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _adultsCountController,
                        decoration: const InputDecoration(
                          labelText: 'Number of adults',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
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
                    ],
                  ),
                ),
              ),

              // Household members section header
              if (_numberOfAdults != null && _numberOfAdults! > 0) ...[
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full name of household members',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'List all members of the producer\'s household. Do not include the manager/farmer. Include the manager\'s family only if they live in the producer\'s household. Write the first and last names of household members.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Individual household member cards
              if (_numberOfAdults != null && _numberOfAdults! > 0)
                ...List.generate(_numberOfAdults!, (index) {
                  final personName = _nameControllers[index].text.isNotEmpty
                      ? _nameControllers[index].text
                      : 'Household Member ${index + 1}';

                  return Column(
                    children: [
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Household Member ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: index < _nameControllers.length
                                    ? _nameControllers[index]
                                    : TextEditingController(),
                                decoration: const InputDecoration(
                                  labelText: 'Full Name (First and Last Name)',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
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
                            ],
                          ),
                        ),
                      ),

                      // PRODUCER'S/MANAGER'S HOUSEHOLD INFORMATION Card
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRODUCER\'S/MANAGER\'S HOUSEHOLD INFORMATION - $personName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Ghana Card Question
                              Text(
                                'Does $personName have a Ghana Card?',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Radio<bool?>(
                                    value: true,
                                    groupValue: _hasGhanaCard[index],
                                    onChanged: (value) {
                                      setState(() {
                                        _hasGhanaCard[index] = value;
                                      });
                                    },
                                  ),
                                  const Text('Yes'),
                                  const SizedBox(width: 20),
                                  Radio<bool?>(
                                    value: false,
                                    groupValue: _hasGhanaCard[index],
                                    onChanged: (value) {
                                      setState(() {
                                        _hasGhanaCard[index] = value;
                                        _ghanaCardIdControllers[index].clear();
                                      });
                                    },
                                  ),
                                  const Text('No'),
                                ],
                              ),

                              // Ghana Card ID Number (if Yes is selected)
                              if (_hasGhanaCard[index] == true) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller:
                                      index < _ghanaCardIdControllers.length
                                          ? _ghanaCardIdControllers[index]
                                          : TextEditingController(),
                                  decoration: const InputDecoration(
                                    labelText: 'Ghana Card ID Number',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (_hasGhanaCard[index] == true &&
                                        (value == null || value.isEmpty)) {
                                      return 'Please enter Ghana Card ID number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
