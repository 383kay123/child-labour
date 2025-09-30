import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/farm identification/adults_information_page.dart';

class AdultHouseholdPage extends StatefulWidget {
  const AdultHouseholdPage({super.key});

  @override
  State<AdultHouseholdPage> createState() => _AdultHouseholdPageState();
}

class _AdultHouseholdPageState extends State<AdultHouseholdPage> {
  bool isAdultsComplete = false;
  bool isChildrenComplete = false;
  bool isProducerManagerComplete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              context: context,
              title: 'Information on adults living in the household',
              isComplete: isAdultsComplete,
              onTap: () async {
                final result = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdultsInformationPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    isAdultsComplete = true;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '2. Children in the Household',
              isComplete: isChildrenComplete,
              onTap: () {
                // TODO: Navigate to Children form
              },
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              context: context,
              title: '3. Producer\'s/Manager\'s Household Information',
              isComplete: isProducerManagerComplete,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProducerManagerHouseholdPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    isProducerManagerComplete = true;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required bool isComplete,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: isComplete ? Colors.green : Colors.grey.shade200,
          width: isComplete ? 2 : 1,
        ),
      ),
      elevation: isComplete ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (isComplete)
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child:
                      Icon(Icons.check_circle, color: Colors.green, size: 24),
                ),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: isComplete ? FontWeight.w700 : FontWeight.w600,
                    color: isComplete
                        ? Colors.green[800]
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class ProducerManagerHouseholdPage extends StatefulWidget {
  const ProducerManagerHouseholdPage({super.key});

  @override
  State<ProducerManagerHouseholdPage> createState() =>
      _ProducerManagerHouseholdPageState();
}

class _ProducerManagerHouseholdPageState
    extends State<ProducerManagerHouseholdPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _gender;
  String? _relationship;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Save the data and return to previous screen
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Producer's/Manager's Information"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Age Field
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender Radio Buttons
              const Text('Gender', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Radio<String>(
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                  ),
                  const Text('Male'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                  ),
                  const Text('Female'),
                ],
              ),

              // Relationship Dropdown
              DropdownButtonFormField<String>(
                value: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship to Producer/Manager',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Self',
                    child: Text('Self (Producer/Manager)'),
                  ),
                  DropdownMenuItem(
                    value: 'Spouse',
                    child: Text('Spouse'),
                  ),
                  DropdownMenuItem(
                    value: 'Child',
                    child: Text('Child'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other Relative'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _relationship = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select relationship';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixText: '+233 ',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  } else if (value.length < 9) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Residential Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Save Information',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
