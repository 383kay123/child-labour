import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/farmer_identification/farmer_identification.dart';
import 'consent_controller.dart';

class ConsentForm extends StatelessWidget {
  final int coverId;

  const ConsentForm({
    Key? key,
    required this.coverId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConsentController>(
      init: ConsentController(),
      builder: (controller) {
        return _ConsentFormContent(
          controller: controller,
          coverId: coverId,
        );
      },
    );
  }
}

class _ConsentFormContent extends StatefulWidget {
  final ConsentController controller;
  final int coverId;

  const _ConsentFormContent({
    required this.controller,
    required this.coverId,
  });

  @override
  State<_ConsentFormContent> createState() => _ConsentFormContentState();
}

class _ConsentFormContentState extends State<_ConsentFormContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Consent Form"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interview Information Section
            _buildInterviewInfoCard(widget.controller, theme),
            const SizedBox(height: 24),

            // Community Type - Using StatefulBuilder for real-time updates
            StatefulBuilder(
              builder: (context, setState) => _buildQuestionCard(
                title: 'Select the type of community',
                children: _buildRadioOptions(
                  options: ConsentController.communityTypes,
                  value: widget.controller.communityType.value,
                  onChanged: (value) {
                    widget.controller.updateCommunityType(value);
                    setState(() {}); // Force immediate rebuild
                  },
                ),
                error: widget.controller.fieldErrors['communityType'],
              ),
            ),

            // Show Other community field if "Other" is selected
            if (widget.controller.communityType.value == 'Other')
              StatefulBuilder(
                builder: (context, setState) => _buildTextFieldCard(
                  title: 'Please specify community',
                  controller: widget.controller.otherCommunityName,
                  hint: 'Enter community name',
                  error: widget.controller.fieldErrors['otherCommunityName'],
                  onChanged: (value) {
                    widget.controller.otherCommunityName.value = value;
                    setState(() {}); // Force immediate rebuild
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Residence Confirmation
            StatefulBuilder(
              builder: (context, setState) => _buildQuestionCard(
                title:
                'Does the farmer reside in the community stated on the cover?',
                children: _buildRadioOptions(
                  options: ConsentController.yesNoOptions,
                  value: widget.controller.residesInCommunity.value,
                  onChanged: (value) {
                    widget.controller.updateResidesInCommunity(value);
                    setState(() {}); // Force immediate rebuild
                  },
                ),
                error: widget.controller.fieldErrors['residesInCommunity'],
              ),
            ),

            // Show Other community field if "No" is selected
            if (widget.controller.residesInCommunity.value == 'No')
              StatefulBuilder(
                builder: (context, setState) => _buildTextFieldCard(
                  title: 'Please specify the community',
                  controller: widget.controller.otherCommunityName,
                  hint: 'Enter community name',
                  error: widget.controller.fieldErrors['otherCommunityName'],
                  onChanged: (value) {
                    widget.controller.otherCommunityName.value = value;
                    setState(() {}); // Force immediate rebuild
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Farmer Availability
            StatefulBuilder(
              builder: (context, setState) => _buildQuestionCard(
                title: 'Is the farmer available for the interview?',
                children: _buildRadioOptions(
                  options: ConsentController.yesNoOptions,
                  value: widget.controller.farmerAvailable.value,
                  onChanged: (value) {
                    widget.controller.updateFarmerAvailable(value);
                    setState(() {}); // Force immediate rebuild
                  },
                ),
                error: widget.controller.fieldErrors['farmerAvailable'],
              ),
            ),

            // Show additional fields if farmer not available
            if (widget.controller.farmerAvailable.value == 'No') ...[
              const SizedBox(height: 16),

              // Farmer Status
              StatefulBuilder(
                builder: (context, setState) => _buildQuestionCard(
                  title: 'If No, for what reason?',
                  children: _buildRadioOptions(
                    options: ConsentController.farmerStatusOptions,
                    value: widget.controller.farmerStatus.value,
                    onChanged: (value) {
                      widget.controller.updateFarmerStatus(value);
                      setState(() {}); // Force immediate rebuild
                    },
                  ),
                  error: widget.controller.fieldErrors['farmerStatus'],
                ),
              ),

              // Other Specification
              if (widget.controller.farmerStatus.value == 'Other')
                StatefulBuilder(
                  builder: (context, setState) => _buildTextFieldCard(
                    title: 'If other, please specify',
                    controller: widget.controller.otherSpecification,
                    hint: 'Enter specification',
                    error: widget.controller.fieldErrors['otherSpecification'],
                    onChanged: (value) {
                      widget.controller.otherSpecification.value = value;
                      setState(() {}); // Force immediate rebuild
                    },
                  ),
                ),

              // Available Person
              if (widget.controller.farmerStatus.value == 'Non-resident' ||
                  widget.controller.farmerStatus.value == 'Other') ...[
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => _buildQuestionCard(
                    title: 'Who is available for the interview?',
                    children: _buildRadioOptions(
                      options: ConsentController.availablePersonOptions,
                      value: widget.controller.availablePerson.value,
                      onChanged: (value) {
                        widget.controller.updateAvailablePerson(value);
                        setState(() {}); // Force immediate rebuild
                      },
                    ),
                    error: widget.controller.fieldErrors['availablePerson'],
                  ),
                ),
              ],
            ],

            const SizedBox(height: 24),

            // Consent Section with real-time updates
            StatefulBuilder(
              builder: (context, setState) => _buildConsentSection(
                widget.controller,
                theme,
                isDark,
                setState,
              ),
            ),

            const SizedBox(height: 32),

            // Continue Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: () async {
                  final saved =
                  await widget.controller.saveData(coverId: widget.coverId);
                  if (saved) {
                    // Navigate to the next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FarmerIdForm(
                            coverId: widget.coverId,
                          )),
                    );
                  } else if (widget.controller.fieldErrors.isNotEmpty) {
                    // Scroll to first error if there are any
                    Scrollable.ensureVisible(
                      context,
                      duration: const Duration(milliseconds: 300),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.controller.isLoading.value
                      ? 'Saving...'
                      : 'Continue',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              )),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewInfoCard(
      ConsentController controller, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interview Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Time:',
                        style: theme.textTheme.bodySmall,
                      ),
                      Obx(() => Text(
                        '${controller.interviewStartTime.value!.hour.toString().padLeft(2, '0')}:${controller.interviewStartTime.value!.minute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: controller.interviewStartTime.value != null
                              ? Colors.green
                              : Colors.black,
                        ),
                      ))
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: controller.recordInterviewTime,
                  icon: const Icon(Icons.access_time, size: 18),
                  label: const Text('Record Time'),
                  style: ElevatedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GPS Location:',
                        style: theme.textTheme.bodySmall,
                      ),
                      Obx(() => Text(
                        controller.locationStatus.value,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color:
                          controller.locationStatus.value == 'Captured'
                              ? Colors.green
                              : Colors.black,
                        ),
                      ))
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: controller.getLocation,
                  icon: const Icon(Icons.location_on, size: 18),
                  label: const Text('Get Location'),
                  style: ElevatedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            if (controller.fieldErrors.containsKey('location'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.fieldErrors['location']!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required String title,
    required List<Widget> children,
    String? error,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldCard({
    required String title,
    required RxString controller,
    required String hint,
    String? error,
    required ValueChanged<String> onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: error,
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRadioOptions({
    required List<String> options,
    required String value,
    required Function(String) onChanged,
  }) {
    return options.map((option) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        horizontalTitleGap: 8,
        leading: Radio<String>(
          value: option,
          groupValue: value,
          onChanged: (val) => onChanged(val!),
        ),
        title: Text(
          option,
          style: const TextStyle(fontSize: 14),
        ),
        onTap: () => onChanged(option),
      );
    }).toList();
  }

  Widget _buildConsentSection(
      ConsentController controller,
      ThemeData theme,
      bool isDark,
      StateSetter setState,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consent for Data Processing',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Consent Text
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
              child: SingleChildScrollView(
                child: const Text(
                  'By selecting "Yes, I confirm", I hereby give my free, explicit and unequivocal consent to the processing of my personal data...',
                  style: TextStyle(fontSize: 12, height: 1.6),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Consent Checkboxes
            Column(
              children: [
                // Accept Consent
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: controller.fieldErrors.containsKey('consent')
                        ? Border.all(color: theme.colorScheme.error, width: 1)
                        : null,
                    color: controller.fieldErrors.containsKey('consent')
                        ? theme.colorScheme.error.withOpacity(0.1)
                        : null,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Checkbox(
                        value: controller.consentGiven.value,
                        onChanged: (value) {
                          controller.toggleConsent();
                          setState(() {}); // Force immediate rebuild
                        },
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Yes, I accept the above conditions',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Decline Consent
                Row(
                  children: [
                    Checkbox(
                      value: controller.declinedConsent.value,
                      onChanged: (value) {
                        controller.toggleDeclinedConsent();
                        setState(() {}); // Force immediate rebuild
                      },
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'No, I refuse and end the survey',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                // Refusal Reason (if declined)
                if (controller.declinedConsent.value) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText:
                      'What is your reason for refusing to participate?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText: controller.fieldErrors['refusalReason'],
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      controller.refusalReason.value = value;
                      setState(() {});
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}