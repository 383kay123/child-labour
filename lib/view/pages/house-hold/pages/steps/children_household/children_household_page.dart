import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/children_household/child_details_page.dart';
import 'children_household_controller.dart';

class ChildrenHouseholdForm extends StatelessWidget {
  // final VoidCallback onContinue;

  final int coverPageId;

  const ChildrenHouseholdForm({
    Key? key,
    required this.coverPageId,
    // required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChildrenHouseholdController>(
      init: ChildrenHouseholdController(),
      builder: (controller) {
        return _ChildrenHouseholdContent(
          controller: controller,
          coverPageId: coverPageId,
          // onContinue: onContinue,
        );
      },
    );
  }
}

class _ChildrenHouseholdContent extends StatelessWidget {
  final ChildrenHouseholdController controller;
  // final VoidCallback onContinue;
  final int coverPageId;

  const _ChildrenHouseholdContent({
    required this.controller,
    required this.coverPageId,
    // required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Children in Household',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Information about children living in the household',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question: Are there children in the household?
                  _buildQuestionCard(
                    title:
                        'Are there children living in the respondent\'s household?',
                    child: Obx(() => Column(
                          children: [
                            _buildRadioOption(
                              label: 'Yes',
                              value: 'Yes',
                              groupValue:
                                  controller.hasChildrenInHousehold.value,
                              onChanged: (value) =>
                                  controller.updateHasChildren('Yes'),
                            ),
                            _buildRadioOption(
                              label: 'No',
                              value: 'No',
                              groupValue:
                                  controller.hasChildrenInHousehold.value,
                              onChanged: (value) =>
                                  controller.updateHasChildren('No'),
                            ),
                          ],
                        )),
                    error: controller.fieldErrors['hasChildren'],
                  ),

                  // Number of children (if Yes)
                  // if () ...[
                  //
                  // ],

                  Obx(() => controller.hasChildrenInHousehold.value == 'Yes'
                      ? Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildQuestionCard(
                              title: 'How many children are in the household?',
                              child: _buildNumberInput(
                                label: 'Number of children',
                                value: controller.numberOfChildren.value
                                    .toString(),
                                onChanged: (value) {
                                  final count = int.tryParse(value) ?? 0;
                                  controller.updateNumberOfChildren(count);
                                },
                                maxValue: 50,
                              ),
                              error: controller.fieldErrors['numberOfChildren'],
                            ),
                          ],
                        )
                      : Container()),

                  // Children 5-17 years (if Yes and has children)
                  // if  ...[
                  //
                  // ],

                  Obx(() => (controller.hasChildrenInHousehold.value == 'Yes' &&
                          controller.numberOfChildren.value > 0)
                      ? Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildQuestionCard(
                              title:
                                  'How many children are between 5-17 years old?',
                              child: _buildNumberInput(
                                label: 'Children aged 5-17',
                                value:
                                    controller.children5To17.value.toString(),
                                onChanged: (value) {
                                  final count = int.tryParse(value) ?? 0;
                                  controller.updateChildren5To17(count);
                                },
                                maxValue: controller.numberOfChildren.value,
                                maxAllowed: 19,
                                showHint: true,
                                hintText:
                                    'Out of ${controller.numberOfChildren.value} total children',
                              ),
                              error: controller.fieldErrors['children5To17'],
                            ),
                          ],
                        )
                      : Container()),

                  // Progress Indicator (if collecting child details)
                  if (controller.shouldCollectChildDetails) ...[
                    const SizedBox(height: 16),
                    _buildProgressCard(controller),
                  ],

                  Obx(() => (controller.hasChildrenInHousehold.value == 'Yes' &&
                          controller.numberOfChildren.value > 0)
                      ? Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildProgressCard(controller),
                          ],
                        )
                      : Container()),

                  // Child Details Collection (if needed)
                  // if  ...[
                  //   const SizedBox(height: 16),
                  //   _buildChildDetailsList(controller),
                  // ],

                  Obx(() => (controller.shouldCollectChildDetails &&
                          controller.childrenDetails.isNotEmpty)
                      ? Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildChildDetailsList(controller),
                          ],
                        )
                      : Container()),

                  // Continue Button
                  const SizedBox(height: 32),
                  _buildContinueButton(controller, coverPageId, context),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required String title,
    required Widget child,
    String? error,
  }) {
    final theme = Theme.of(Get.context!);

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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            child,
            if (error != null && error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error,
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

  Widget _buildRadioOption({
    required String label,
    required String value,
    required String groupValue,
    required Function(String) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      horizontalTitleGap: 8,
      leading: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: (val) => onChanged(val!),
        activeColor: Theme.of(Get.context!).primaryColor,
      ),
      title: Text(label),
      onTap: () => onChanged(value),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxValue = 50,
    int maxAllowed = 50,
    bool showHint = false,
    String hintText = '',
  }) {
    final theme = Theme.of(Get.context!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHint && hintText.isNotEmpty) ...[
          Text(
            hintText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          initialValue: value != '0' ? value : '',
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixText: 'children',
          ),
          keyboardType: TextInputType.number,
          onChanged: (newValue) {
            if (newValue.isEmpty) {
              onChanged('0');
              return;
            }

            final number = int.tryParse(newValue);
            if (number != null && number >= 0) {
              if (number <= maxAllowed) {
                onChanged(newValue);
              } else {
                // Show error but don't block input
                Get.snackbar(
                  'Validation',
                  'Maximum allowed is $maxAllowed',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildProgressCard(ChildrenHouseholdController controller) {
    final progress = controller.childrenDetails.length /
        (controller.children5To17.value > 0
            ? controller.children5To17.value
            : 1);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Child Details Progress',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${controller.childrenDetails.length}/${controller.children5To17.value}',
                  style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(Get.context!).primaryColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(Get.context!).primaryColor,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              progress >= 1.0
                  ? 'All child details collected ✅'
                  : 'Collecting details for children aged 5-17',
              style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildDetailsList(ChildrenHouseholdController controller) {
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
              'Child Details Collected',
              style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            if (controller.childrenDetails.isEmpty)
              Text(
                'No child details collected yet',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    controller.childrenDetails.asMap().entries.map((entry) {
                  final index = entry.key;
                  final child = entry.value;
                  final childNumber = child['childNumber'] ?? index + 1;

                  return Chip(
                    label: Text('Child $childNumber'),
                    backgroundColor:
                        Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                    deleteIcon: const Icon(Icons.edit, size: 16),
                    onDeleted: () {
                      // Navigate to edit child details
                      _navigateToChildDetails(index, child);
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(
      ChildrenHouseholdController controller, coverId, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final bool done = controller.saveHouseHoldChild(coverPageId: coverId);

          if(done){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChildDetailsPage(
                  // childNumber: controller.numberOfChildren.value,
                  totalChildren: controller.numberOfChildren.value,
                  // isLastChild: isLastChild,
                  // householdId: householdId,
                  coverPageId: coverPageId,
                  // childrenDetails: childrenDetails,
                  // onComplete: onComplete,
                ),
              ),
            );
          }
          // // Validate form
          // final errors = {
          //   'hasChildren': controller.validateHasChildren(),
          //   'numberOfChildren': controller.validateNumberOfChildren(),
          //   'children5To17': controller.validateChildren5To17(),
          // };
          //
          // // Clear previous errors
          // controller.fieldErrors.clear();
          //
          // // Add new errors
          // errors.forEach((key, value) {
          //   if (value != null) {
          //     controller.fieldErrors[key] = value;
          //   }
          // });
          //
          // // Update UI
          // controller.update();
          //
          // if (controller.fieldErrors.isEmpty) {
          //   // Check if we need to collect child details
          //   if (controller.shouldCollectChildDetails) {
          //     // Navigate to child details collection
          //     _startChildDetailsCollection(controller);
          //   } else {
          //     // Proceed with continue
          //     // onContinue();
          //   }
          // } else {
          //   // Show first error
          //   final firstError = controller.fieldErrors.values.first;
          //   Get.snackbar(
          //     'Validation Error',
          //     firstError,
          //     backgroundColor: Colors.orange,
          //     colorText: Colors.white,
          //   );
          // }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Obx(() => Text(
              controller.isLoading.value ? 'Processing...' : 'Continue',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )),
      ),
    );
  }

  void _startChildDetailsCollection(ChildrenHouseholdController controller) {
    // This would navigate to a child details collection screen
    // For now, just show a message
    Get.snackbar(
      'Child Details Required',
      'Please collect details for ${controller.children5To17.value} children',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );

    // In a real implementation, you would navigate to:
    // Get.to(() => ChildDetailsCollectionScreen(
    //   totalChildren: controller.children5To17.value,
    //   onComplete: (details) {
    //     controller.childrenDetails.value = details;
    //     controller.update();
    //   },
    // ));

    // For now, simulate completion and continue
    // Future.delayed(const Duration(seconds: 2), () {
    //   onContinue();
    // });
  }

  void _navigateToChildDetails(int index, Map<String, dynamic> childData) {
    // Navigate to edit child details
    Get.snackbar(
      'Edit Child Details',
      'Edit functionality would open here',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
