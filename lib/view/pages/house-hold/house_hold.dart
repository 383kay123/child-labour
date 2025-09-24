import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HouseHold extends StatefulWidget {
  const HouseHold({super.key});

  @override
  State<HouseHold> createState() => _HouseHoldState();
}

class _HouseHoldState extends State<HouseHold> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedCommunityType; // To store the selected community type
  bool? _residesInCommunity; // To store if farmer resides in the community
  final TextEditingController _residenceExplanationController =
      TextEditingController();
  final int _totalPages = 3;
  final List<String> _pageTitles = ['Cover', 'Consent', 'Farm Identification'];
  final List<IconData> _pageIcons = [
    Icons.add,
    Icons.assignment,
    Icons.agriculture
  ];

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Survey'),
        content:
            const Text('Are you sure you want to submit the household survey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Survey submitted successfully!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _residenceExplanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Household Survey',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Step Indicators
                Row(
                  children: List.generate(_totalPages, (index) {
                    final isActive = index == _currentPage;
                    final isCompleted = index < _currentPage;

                    return Expanded(
                      child: Row(
                        children: [
                          // Step Circle
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? colorScheme.primary
                                  : isActive
                                      ? colorScheme.primary
                                      : colorScheme.surface,
                              border: isActive || isCompleted
                                  ? null
                                  : Border.all(
                                      color: Colors.grey.shade300, width: 2),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? Icon(Icons.check,
                                      color: colorScheme.onPrimary, size: 20)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: isActive
                                            ? colorScheme.onPrimary
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          // Connector Line (except for last item)
                          if (index < _totalPages - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      isCompleted
                                          ? colorScheme.primary
                                          : Colors.grey.shade300,
                                      index + 1 <= _currentPage
                                          ? colorScheme.primary
                                          : Colors.grey.shade300,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Current Page Title
                Text(
                  _pageTitles[_currentPage],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 8),

                // Progress Text
                Text(
                  'Step ${_currentPage + 1} of $_totalPages',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildCoverPage(),
                _buildConsentPage(),
                _buildFarmIdentificationPage(),
              ],
            ),
          ),
        ],
      ),

      // Navigation Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Previous Button
              if (_currentPage > 0)
                // Previous Button
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: colorScheme.primary),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios,
                              size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Previous',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),

              if (_currentPage > 0) const SizedBox(width: 12),

              // Next/Submit Button
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _currentPage < _totalPages - 1 ? _nextPage : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage < _totalPages - 1 ? 'Next' : 'Submit',
                        style: TextStyle(color: colorScheme.onPrimary),
                      ),
                      if (_currentPage < _totalPages - 1) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: colorScheme.onPrimary),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // List of towns with their codes
  final List<Map<String, String>> towns = [
    {'name': 'Select Society', 'code': ''},
    {'name': 'Nairobi Central', 'code': 'NBO-001'},
    {'name': 'Mombasa CBD', 'code': 'MBA-001'},
    {'name': 'Kisumu Town', 'code': 'KSM-001'},
    {'name': 'Nakuru CBD', 'code': 'NKR-001'},
    {'name': 'Eldoret Town', 'code': 'ELD-001'},
  ];

  // List of farmers with their codes
  final List<Map<String, String>> farmers = [
    {'name': 'Select Farmer', 'code': '', 'farmerName': ''},
    {'name': 'John Kamau', 'code': 'FARM-001', 'farmerName': 'John Kamau'},
    {'name': 'Mary Wanjiku', 'code': 'FARM-002', 'farmerName': 'Mary Wanjiku'},
    {'name': 'James Mwangi', 'code': 'FARM-003', 'farmerName': 'James Mwangi'},
    {'name': 'Grace Wambui', 'code': 'FARM-004', 'farmerName': 'Grace Wambui'},
    {
      'name': 'Peter Kariuki',
      'code': 'FARM-005',
      'farmerName': 'Peter Kariuki'
    },
  ];

  String? selectedTown;
  String? selectedFarmer;
  DateTime? interviewStartTime;
  Position? _currentPosition;
  String _address = '';

  // Reusable dropdown widget
  Widget _buildDropdown({
    required String label,
    required List<Map<String, String>> items,
    required String? value,
    required Function(String?) onChanged,
    bool isRequired = false,
    String Function(Map<String, String>)? displayText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label${isRequired ? ' *' : ''}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[50],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                hint: Text('Select $label'),
                onChanged: onChanged,
                items: items
                    .map<DropdownMenuItem<String>>((Map<String, String> item) {
                  final display = displayText != null
                      ? displayText(item)
                      : '${item['name']} (${item['code']})';
                  return DropdownMenuItem<String>(
                    value: item['code'],
                    child: Text(display),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildCoverPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown(
            label: 'Society',
            items: towns,
            value: selectedTown,
            onChanged: (String? newValue) {
              setState(() {
                selectedTown = newValue;
                // Clear farmer selection when society changes
                selectedFarmer = null;
              });
            },
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Farmer',
            items: farmers,
            value: selectedFarmer,
            onChanged: (String? newValue) {
              setState(() {
                selectedFarmer = newValue;
              });
            },
            isRequired: true,
            displayText: (item) => '${item['name']} (${item['code']})',
          ),
        ],
      ),
    );
  }

  Widget _buildConsentPage() {
    final theme = Theme.of(context);
    final isTimeRecorded = interviewStartTime != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Recording Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record the interview start/pick-up time',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: isTimeRecorded ? Colors.green.shade50 : theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            elevation: isTimeRecorded ? 1 : 0,
            child: InkWell(
              onTap: () {
                setState(() => interviewStartTime = DateTime.now());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Interview start time recorded!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isTimeRecorded
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isTimeRecorded
                            ? Colors.green.shade100
                            : theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isTimeRecorded
                            ? Icons.check_circle_outline_rounded
                            : Icons.timer_outlined,
                        size: 20,
                        color: isTimeRecorded
                            ? Colors.green.shade700
                            : theme.primaryColor,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTimeRecorded
                                ? _formatDateTime(interviewStartTime!)
                                : 'Tap to Record Start Time',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isTimeRecorded
                                  ? Colors.green.shade800
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (isTimeRecorded) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Started ${_formatTimeAgo(interviewStartTime!)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          // GPS Section - Only show after time is recorded
          if (isTimeRecorded) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Record GPS Location',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLocationCard(),

            // Residence Confirmation

            // Community Type Section
            const SizedBox(height: 24),
            _buildCommunityTypeSelector(),

            const SizedBox(height: 24),
            _buildResidenceConfirmation(),
          ],
        ],
      ),
    );
  }

  Widget _buildResidenceConfirmation() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Does the farmer reside in the community stated on the cover? *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              _buildResidenceRadio(
                value: true,
                label: 'Yes',
                groupValue: _residesInCommunity,
                onChanged: (value) {
                  setState(() {
                    _residesInCommunity = value;
                    _residenceExplanationController.clear();
                  });
                },
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildResidenceRadio(
                value: false,
                label: 'No',
                groupValue: _residesInCommunity,
                onChanged: (value) {
                  setState(() {
                    _residesInCommunity = value;
                  });
                },
              ),
            ],
          ),
        ),
        // Show text field only when "No" is selected
        if (_residesInCommunity == false) ...[
          const SizedBox(height: 16),
          Text(
            'Provide the name of the community the farmer resides in *',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _residenceExplanationController,
            decoration: InputDecoration(
              hintText: 'Enter residence location',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),
        ],
      ],
    );
  }

  Widget _buildResidenceRadio({
    required bool value,
    required String label,
    required bool? groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? Colors.black87 : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityTypeSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the type of community *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              _buildCommunityTypeRadio(
                value: 'Town',
                label: 'Town',
                groupValue: _selectedCommunityType,
                onChanged: (value) {
                  setState(() {
                    _selectedCommunityType = value;
                  });
                },
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildCommunityTypeRadio(
                value: 'Village',
                label: 'Village',
                groupValue: _selectedCommunityType,
                onChanged: (value) {
                  setState(() {
                    _selectedCommunityType = value;
                  });
                },
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              _buildCommunityTypeRadio(
                value: 'Camp',
                label: 'Camp',
                groupValue: _selectedCommunityType,
                onChanged: (value) {
                  setState(() {
                    _selectedCommunityType = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityTypeRadio({
    required String value,
    required String label,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? Colors.black87 : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Location Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_currentPosition != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationInfoRow('Latitude',
                        _currentPosition!.latitude.toStringAsFixed(6)),
                    const SizedBox(height: 8),
                    _buildLocationInfoRow('Longitude',
                        _currentPosition!.longitude.toStringAsFixed(6)),
                    const SizedBox(height: 8),
                    _buildLocationInfoRow('Accuracy',
                        '${_currentPosition!.accuracy.toStringAsFixed(2)} meters'),
                  ],
                ),
              )
            else
              Text(
                'No location data available. Tap the button below to get your current location.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Get Current Location'),
                onPressed: _getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location recorded: ${position.latitude}, ${position.longitude}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildFarmIdentificationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.agriculture,
            title: 'Farm Identification',
            subtitle: 'Basic farm details',
          ),
          const SizedBox(height: 24),
          _buildInputField('Farm Name', 'Enter farm name'),
          const SizedBox(height: 16),
          _buildInputField('Location', 'Enter farm location'),
          const SizedBox(height: 16),
          _buildInputField('Farm Size (acres)', 'Enter farm size'),
          const SizedBox(height: 16),
          _buildDropdownField(
              'Farm Type', ['Crop Farming', 'Livestock', 'Mixed', 'Other']),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  List<Widget> _buildConsentItems() {
    return [
      _buildConsentItem('I understand the purpose of this survey'),
      _buildConsentItem('I agree to participate voluntarily'),
      _buildConsentItem('I understand I can withdraw at any time'),
      _buildConsentItem('I agree to the use of data for research'),
    ];
  }

  Widget _buildConsentItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {},
        ),
      ],
    );
  }
}
