import 'package:flutter/material.dart';

class AdultsInformationPage extends StatefulWidget {
  const AdultsInformationPage({super.key});

  @override
  State<AdultsInformationPage> createState() => _AdultsInformationPageState();
}

class _AdultsInformationPageState extends State<AdultsInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adultsCountController = TextEditingController();
  int? _numberOfAdults;
  final List<TextEditingController> _nameControllers = [];
  bool _showNameFields = false;

  @override
  void dispose() {
    _adultsCountController.dispose();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateNameFields(int count) {
    // Dispose old controllers
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    
    // Create new controllers
    _nameControllers.clear();
    for (int i = 0; i < count; i++) {
      _nameControllers.add(TextEditingController());
    }
    
    setState(() {
      _numberOfAdults = count;
      _showNameFields = count > 0;
    });
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
              const Text(
                'Total number of adults in the household '
                '(producer/manager/owner not included)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _adultsCountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter number',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _numberOfAdults = int.tryParse(value);
                  });
                },
              ),
              if (_showNameFields) ...[
                const SizedBox(height: 24),
                const Text(
                  'Full name of household members',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'List all members of the producer\'s household. Do not include the manager/farmer. Include the manager\'s family only if they live in the producer\'s household.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ...List.generate(_nameControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: index < _nameControllers.length ? _nameControllers[index] : TextEditingController(),
                      decoration: InputDecoration(
                        labelText: 'Household Member ${index + 1}',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_numberOfAdults == null || _numberOfAdults == 0) {
                    Navigator.pop(context, {'count': 0, 'names': []});
                    return;
                  }
                  
                  final names = _nameControllers
                      .map((controller) => controller.text.trim())
                      .where((name) => name.isNotEmpty)
                      .toList();
                  
                  if (names.length != _numberOfAdults) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter names for all household members'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  Navigator.pop(context, {
                    'count': _numberOfAdults,
                    'names': names,
                  });
                }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
