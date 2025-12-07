import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/combined_farmer_id/combined_farmer_identification.dart';
import 'package:path/path.dart';
import 'farmer_id_controller.dart';

class FarmerIdForm extends StatelessWidget {
  // final VoidCallback onContinue;
  final int coverId;

  const FarmerIdForm({
    Key? key,
    required this.coverId,
    // required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FarmerIdController>(
      init: FarmerIdController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Farmer Identification Form"),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Column(
            children: [
              // Header
              // _buildHeader(context),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Ghana Card Section
                      _buildGhanaCardSection(controller),

                      const SizedBox(height: 16),

                      // Alternative ID Section (if no Ghana Card)
                      if (!controller.hasGhanaCard.value)
                        _buildAlternativeIdSection(controller),

                      const SizedBox(height: 16),

                      // Consent Section
                      if (controller.hasGhanaCard.value ||
                          (!controller.hasGhanaCard.value &&
                              controller.selectedIdType.value.isNotEmpty))
                        _buildConsentSection(controller),

                      const SizedBox(height: 16),

                      // ID Number Field
                      _buildIdNumberSection(controller),

                      const SizedBox(height: 16),

                      // ID Picture Section (if consent given)
                      if (controller.idPictureConsent.value == '1')
                        _buildIdPictureSection(controller),

                      const SizedBox(height: 16),

                      // Contact Number
                      _buildContactNumberSection(controller),

                      const SizedBox(height: 16),

                      // Children Count
                      _buildChildrenCountSection(controller),

                      const SizedBox(height: 16),

                      // Children Details (if count > 0)
                      if (controller.childrenCount.value > 0)
                        Obx(
                          () => controller.childrenCount.value > 0
                              ? _buildChildrenDetailsSection(controller)
                              : Container(),
                        ),

                      const SizedBox(height: 32),

                      // Continue Button
                      _buildContinueButton(controller, context),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  'Farmer Identification',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 56, bottom: 8),
              child: Text(
                'Provide farmer identification details',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGhanaCardSection(FarmerIdController controller) {
    return _buildQuestionCard(
      title: 'Does the farmer have a Ghana Card?',
      error: controller.fieldErrors['ghanaCard'],
      child: Column(
        children: [
          _buildRadioOption(
            value: true,
            groupValue: controller.hasGhanaCard.value,
            label: 'Yes',
            onChanged: (value) {
              controller.hasGhanaCard.value = true;
              controller.selectedIdType.value = '';
              controller.fieldErrors.remove('ghanaCard');
              controller.update();
            },
          ),
          _buildRadioOption(
            value: false,
            groupValue: controller.hasGhanaCard.value,
            label: 'No',
            onChanged: (value) {
              controller.hasGhanaCard.value = false;
              controller.ghanaCardNumber.value = '';
              controller.fieldErrors.remove('ghanaCard');
              controller.update();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeIdSection(FarmerIdController controller) {
    return _buildQuestionCard(
      title: 'Which other national ID card is available?',
      error: controller.fieldErrors['idType'],
      child: Column(
        children: FarmerIdController.idTypes.map((idType) {
          return _buildRadioOption(
            value: idType['value'],
            groupValue: controller.selectedIdType.value,
            label: idType['label']!,
            onChanged: (value) {
              controller.selectedIdType.value = value!;
              controller.fieldErrors.remove('idType');
              controller.update();
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConsentSection(FarmerIdController controller) {
    final idTypeName = controller.hasGhanaCard.value
        ? 'Ghana Card'
        : FarmerIdController.idTypes.firstWhere(
            (type) => type['value'] == controller.selectedIdType.value,
            orElse: () => {'label': 'ID'},
          )['label']!;

    return Column(
      children: [
        _buildQuestionCard(
          title:
              'Do you consent to us taking a picture of your $idTypeName and recording the ID number?',
          error: controller.fieldErrors['consent'],
          child: Column(
            children: [
              _buildRadioOption(
                value: '1',
                groupValue: controller.idPictureConsent.value,
                label: 'Yes',
                onChanged: (value) {
                  controller.idPictureConsent.value = '1';
                  controller.noConsentReason.value = '';
                  controller.fieldErrors.remove('consent');
                  controller.update();
                },
              ),
              _buildRadioOption(
                value: '0',
                groupValue: controller.idPictureConsent.value,
                label: 'No',
                onChanged: (value) {
                  controller.idPictureConsent.value = '0';
                  controller.fieldErrors.remove('consent');
                  controller.update();
                },
              ),
            ],
          ),
        ),

        // No consent reason field
        if (controller.idPictureConsent.value == '0')
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildQuestionCard(
              title: 'Please specify reason',
              error: controller.fieldErrors['noConsentReason'],
              child: _buildTextField(
                label: 'Reason for not consenting',
                value: controller.noConsentReason.value,
                onChanged: (value) {
                  controller.noConsentReason.value = value;
                  controller.fieldErrors.remove('noConsentReason');
                },
                maxLines: 3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIdNumberSection(FarmerIdController controller) {
    if (controller.idPictureConsent.value != '1') {
      return const SizedBox.shrink();
    }

    final isGhanaCard = controller.hasGhanaCard.value;
    final label = isGhanaCard
        ? 'Ghana Card Number (GHA-XXXXXXXXX-X)'
        : '${_getIdTypeLabel(controller.selectedIdType.value)} Number';

    final hint = isGhanaCard
        ? 'Enter Ghana Card number (e.g., GHA-123456789-0)'
        : 'Enter ${_getIdTypeLabel(controller.selectedIdType.value)} number';

    final errorKey = isGhanaCard ? 'ghanaCardNumber' : 'alternativeIdNumber';
    final error = controller.fieldErrors[errorKey];

    return _buildQuestionCard(
      title: label,
      error: error,
      child: _buildTextField(
        label: label,
        value: isGhanaCard
            ? controller.ghanaCardNumber.value
            : controller.alternativeIdNumber.value,
        onChanged: (value) {
          if (isGhanaCard) {
            controller.ghanaCardNumber.value = value;
          } else {
            controller.alternativeIdNumber.value = value;
          }
          controller.fieldErrors.remove(errorKey);
        },
        hintText: hint,
        textCapitalization: TextCapitalization.characters,
      ),
    );
  }

  Widget _buildIdPictureSection(FarmerIdController controller) {
    final idTypeLabel = controller.hasGhanaCard.value
        ? 'Ghana Card'
        : _getIdTypeLabel(controller.selectedIdType.value);

    return _buildQuestionCard(
      title: '$idTypeLabel Picture',
      error: controller.fieldErrors['idImage'],
      child: Column(
        children: [
          // Image Preview
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: controller.idImagePath.value == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No image captured',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(controller.idImagePath.value!),
                      fit: BoxFit.cover,
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // Capture Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.captureIdPicture,
              icon: const Icon(Icons.camera_alt, size: 20),
              label: Text(
                controller.idImagePath.value == null
                    ? 'Take Picture of ID'
                    : 'Retake Picture',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactNumberSection(FarmerIdController controller) {
    return _buildQuestionCard(
      title: 'Contact Number',
      error: controller.fieldErrors['contactNumber'],
      child: _buildTextField(
        label: 'Contact Number',
        value: controller.contactNumber.value,
        onChanged: (value) {
          controller.contactNumber.value = value;
          controller.fieldErrors.remove('contactNumber');
        },
        hintText: 'Enter 10-digit phone number (e.g., 0241234567)',
        keyboardType: TextInputType.phone,
        maxLength: 10,
      ),
    );
  }

  Widget _buildChildrenCountSection(FarmerIdController controller) {
    return _buildQuestionCard(
      title: 'Number of Children (Aged 5-17)',
      error: controller.fieldErrors['childrenCount'],
      child: _buildTextField(
        label: 'Number of Children',
        value: controller.childrenCount.value.toString(),
        onChanged: (value) {
          final count = int.tryParse(value) ?? 0;
          controller.updateChildrenCount(count);
          controller.fieldErrors.remove('childrenCount');
        },
        hintText: 'Enter number of children',
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildChildrenDetailsSection(FarmerIdController controller) {
    return _buildQuestionCard(
      title: 'Farmer\'s Children (Aged 5-17)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Children: ${controller.childrenCount.value}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(controller.childrenCount.value, (index) {
            final child = controller.children[index];
            final childNumber = index + 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Child $childNumber',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // First Name
                  _buildTextField(
                    label: 'First Name',
                    value: child.firstName,
                    onChanged: (value) {
                      controller.updateChild(index, value, child.surname);
                    },
                    hintText: 'Enter first name',
                    textCapitalization: TextCapitalization.words,
                    error: controller.fieldErrors['child_${index}_firstName'],
                  ),

                  const SizedBox(height: 12),

                  // Surname
                  _buildTextField(
                    label: 'Surname',
                    value: child.surname,
                    onChanged: (value) {
                      controller.updateChild(index, child.firstName, value);
                    },
                    hintText: 'Enter surname',
                    textCapitalization: TextCapitalization.words,
                    error: controller.fieldErrors['child_${index}_surname'],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContinueButton(
      FarmerIdController controller, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Validate children names
          // for (int i = 0; i < controller.childrenCount.value; i++) {
          //   final child = controller.children[i];
          //   final firstNameError =
          //       controller.validateName(child.firstName, 'first name');
          //   final surnameError =
          //       controller.validateName(child.surname, 'surname');
          //
          //   if (firstNameError != null) {
          //     controller.fieldErrors['child_${i}_firstName'] = firstNameError;
          //   }
          //   if (surnameError != null) {
          //     controller.fieldErrors['child_${i}_surname'] = surnameError;
          //   }
          // }

          // Update UI
          // controller.update();

          // // Proceed if no errors
          // if (controller.fieldErrors.isEmpty) {
          //   // Show loading state
          //   controller.isLoading.value = true;

          try {
            // Save the data
            final saved = await controller.saveData(coverId: coverId);

            if (saved) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CombinedFarmForm(
                  coverPageId: coverId,
                );
              }));
              Get.snackbar(
                'Success',
                'Farmer information saved successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            }
          } catch (e) {
            // Show error message if save fails
            Get.snackbar(
              'Error',
              'Failed to save farmer information',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } finally {
            // if (context.mounted) {
            controller.isLoading.value = false;
            // }
          }
          // } else {
          //   // Show validation errors
          //   Get.snackbar(
          //     'Validation Error',
          //     'Please check all required fields',
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
              controller.isLoading.value ? 'Saving...' : 'Continue',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  // ==================== UI Helper Methods ====================

  Widget _buildQuestionCard({
    required String title,
    required Widget child,
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
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
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
                    color: Theme.of(Get.context!).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption<T>({
    required T value,
    required T groupValue,
    required String label,
    required Function(T?) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      horizontalTitleGap: 8,
      leading: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Colors.green.shade600,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(fontSize: 14),
      ),
      onTap: () => onChanged(value),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: error,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _getIdTypeLabel(String value) {
    return FarmerIdController.idTypes.firstWhere(
      (type) => type['value'] == value,
      orElse: () => {'label': 'ID'},
    )['label']!;
  }
}
