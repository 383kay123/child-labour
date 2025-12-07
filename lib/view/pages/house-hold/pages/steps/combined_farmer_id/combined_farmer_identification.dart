import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/models/combinefarmer.dart/adult_info_model.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/children_household/children_household_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/combined_farmer_id/combined_farmer_id_controller.dart';

// Reuse the same spacing constants
class _Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Combined Form Widget
class CombinedFarmForm extends StatelessWidget {
  final int coverPageId;

  const CombinedFarmForm({
    Key? key,
    required this.coverPageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CombinedFarmController>(
      init: CombinedFarmController()..coverPageId.value = coverPageId,
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: _buildAppBar(context, controller),
          body: Column(
            children: [
              // Content area with PageView
              Expanded(
                child: Obx(() {
                  // Access the reactive variable to trigger updates
                  final currentPage = controller.currentPageIndex.value;
                  return PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      controller.currentPageIndex.value = index;
                    },
                    children: [
                    // Page 1: Visit Information
                    _VisitInformationContent(controller: controller),

                    // Page 2: Owner Identification
                    _OwnerIdentificationContent(controller: controller),

                    // Page 3: Workers in Farm
                    _WorkersInFarmContent(controller: controller),

                    // Page 4: Adults Information
                    _AdultsInformationContent(controller: controller),
                  ],
                );
                }),
              ),

              // Navigation buttons
              _buildNavigationButtons(context, controller),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CombinedFarmController controller) {
    final pageTitles = ['Visit Information', 'Owner Identification', 'Workers Information', 'Household Adults'];

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          if (controller.currentPageIndex.value > 0) {
            controller.previousPage();
          } else {
            Get.back();
          }
        },
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Obx(() => Text(
        pageTitles[controller.currentPageIndex.value],
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      )),
      actions: [
        Obx(() => controller.currentPageIndex.value < 3
            ? IconButton(
          onPressed: () {
            if (controller.validateCurrentPage()) {
              controller.nextPage();
            }
          },
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
        )
            : const SizedBox.shrink()),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Obx(() => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: controller.currentPageIndex.value == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: controller.currentPageIndex.value == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              );
            }),
          ),
        )),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, CombinedFarmController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous button
            Expanded(
              child: Obx(() => OutlinedButton(
                onPressed: controller.currentPageIndex.value > 0
                    ? () => controller.previousPage()
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: controller.currentPageIndex.value > 0
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: const Text('Back'),
              )),
            ),
            const SizedBox(width: 16),

            // Next/Continue button
            Expanded(
              child: Obx(() => ElevatedButton(
                onPressed: () {
                  if (controller.currentPageIndex.value < 3) {
                    if (controller.validateCurrentPage()) {
                      controller.nextPage();
                    }
                  } else {
                    // On last page, validate and save
                    // if (controller.validateCurrentPage()) {
                      controller.saveAllData().then((success) {
                        if (success) {
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return ChildrenHouseholdForm(
                              coverPageId: controller.coverPageId.value,
                            );
                          }));
                        }
                      });
                    // }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  controller.currentPageIndex.value < 3 ? 'Next' : 'Continue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== INDIVIDUAL PAGE CONTENT WIDGETS ====================

// Visit Information Page
class _VisitInformationContent extends StatelessWidget {
  final CombinedFarmController controller;

  const _VisitInformationContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
        children: [
          // Respondent Name Correct
          _buildQuestionCard(
            title: "Is the respondent's name correct?",
            child: Column(
              children: [
                _buildRadioOption(
                  label: 'Yes',
                  value: true,
                  groupValue: controller.respondentNameCorrect.value,
                  onChanged: (value) {
                    controller.respondentNameCorrect.value = true;
                    controller.fieldErrors.remove('correctedName');
                    controller.update();
                  },
                ),
                _buildRadioOption(
                  label: 'No',
                  value: false,
                  groupValue: controller.respondentNameCorrect.value,
                  onChanged: (value) {
                    controller.respondentNameCorrect.value = false;
                    controller.update();
                  },
                ),
              ],
            ),
          ),

          // Corrected Name (if No)
          if (!controller.respondentNameCorrect.value) ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'Correct Respondent Name',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Surname',
                      hintText: 'Enter correct surname',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      controller.correctedRespondentName.value = value;
                      controller.fieldErrors.remove('correctedName');
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'First and Other Names',
                      hintText: 'Enter correct first and other names',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      controller.respondentOtherNames.value = value;
                    },
                  ),
                ],
              ),
            ),
          ],

          // Nationality
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'What is the nationality of the respondent?',
            child: Column(
              children: [
                _buildRadioOption(
                  label: 'Ghanaian',
                  value: 'Ghanaian',
                  groupValue: controller.respondentNationality.value,
                  onChanged: (value) {
                    controller.respondentNationality.value = value!;
                    controller.countryOfOrigin.value = '';
                    controller.otherCountry.value = '';
                    controller.fieldErrors.remove('nationality');
                    controller.fieldErrors.remove('countryOrigin');
                    controller.update();
                  },
                ),
                _buildRadioOption(
                  label: 'Non-Ghanaian',
                  value: 'Non-Ghanaian',
                  groupValue: controller.respondentNationality.value,
                  onChanged: (value) {
                    controller.respondentNationality.value = value!;
                    controller.update();
                  },
                ),
              ],
            ),
          ),

          // Country of Origin (if Non-Ghanaian)
          if (controller.respondentNationality.value == 'Non-Ghanaian') ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'Specify country of origin',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: controller.countryOfOrigin.value.isNotEmpty
                        ? controller.countryOfOrigin.value
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Select Country',
                      border: OutlineInputBorder(),
                    ),
                    items: CombinedFarmController.countryOptions
                        .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    ))
                        .toList(),
                    onChanged: (value) {
                      controller.countryOfOrigin.value = value ?? '';
                      if (value != 'Other') {
                        controller.otherCountry.value = '';
                      }
                      controller.fieldErrors.remove('countryOrigin');
                      controller.update();
                    },
                  ),

                  if (controller.countryOfOrigin.value == 'Other')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Specify Country',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          controller.otherCountry.value = value;
                          controller.fieldErrors.remove('otherCountry');
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Farm Ownership
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Is the respondent the owner of the farm?',
            child: Column(
              children: [
                _buildRadioOption(
                  label: 'Yes',
                  value: true,
                  groupValue: controller.isFarmOwner.value,
                  onChanged: (value) {
                    controller.isFarmOwner.value = true;
                    controller.farmOwnershipType.value = '';
                    controller.fieldErrors.remove('farmOwnership');
                    controller.update();
                  },
                ),
                _buildRadioOption(
                  label: 'No',
                  value: false,
                  groupValue: controller.isFarmOwner.value,
                  onChanged: (value) {
                    controller.isFarmOwner.value = false;
                    controller.update();
                  },
                ),
              ],
            ),
          ),

          // Farm Ownership Type (if No)
          if (!controller.isFarmOwner.value) ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'Which of these best describes you?',
              child: DropdownButtonFormField<String>(
                value: controller.farmOwnershipType.value.isNotEmpty
                    ? controller.farmOwnershipType.value
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Select Ownership Type',
                  border: OutlineInputBorder(),
                ),
                items: CombinedFarmController.farmOwnershipOptions
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  controller.farmOwnershipType.value = value ?? '';
                  controller.fieldErrors.remove('farmOwnership');
                  controller.update();
                },
              ),
            ),
          ],

          // Show validation errors
          if (controller.pageErrors[0]?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            ...controller.pageErrors[0]!.map((error) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      )),
    );
  }
}

// Owner Identification Page
class _OwnerIdentificationContent extends StatelessWidget {
  final CombinedFarmController controller;

  const _OwnerIdentificationContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
        children: [
          // Owner Name
          _buildQuestionCard(
            title: 'Name of owner',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Surname',
                    hintText: 'Verify with identification document. In capital letters',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    controller.ownerName.value = value;
                    controller.fieldErrors.remove('ownerName');
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter first name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    controller.ownerFirstName.value = value;
                    controller.fieldErrors.remove('ownerFirstName');
                  },
                ),
              ],
            ),
          ),

          // Nationality
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'What is the nationality of the owner?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRadioOption(
                  label: 'Ghanaian',
                  value: 'Ghanaian',
                  groupValue: controller.ownerNationality.value,
                  onChanged: (value) {
                    controller.ownerNationality.value = value!;
                    controller.specificNationality.value = '';
                    controller.otherNationality.value = '';
                    controller.fieldErrors.remove('nationality');
                    controller.update();
                  },
                ),
                _buildRadioOption(
                  label: 'Non-Ghanaian',
                  value: 'Non-Ghanaian',
                  groupValue: controller.ownerNationality.value,
                  onChanged: (value) {
                    controller.ownerNationality.value = value!;
                    controller.update();
                  },
                ),

                // Country of origin for Non-Ghanaians
                if (controller.ownerNationality.value == 'Non-Ghanaian') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: controller.specificNationality.value.isNotEmpty
                        ? controller.specificNationality.value
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Specify country of origin',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'burkina_faso', child: Text('Burkina Faso')),
                      DropdownMenuItem(value: 'mali', child: Text('Mali')),
                      DropdownMenuItem(value: 'guinea', child: Text('Guinea')),
                      DropdownMenuItem(value: 'ivory_coast', child: Text('Ivory Coast')),
                      DropdownMenuItem(value: 'liberia', child: Text('Liberia')),
                      DropdownMenuItem(value: 'togo', child: Text('Togo')),
                      DropdownMenuItem(value: 'benin', child: Text('Benin')),
                      DropdownMenuItem(value: 'other', child: Text('Other (to specify)')),
                    ],
                    onChanged: (value) {
                      controller.specificNationality.value = value ?? '';
                      if (value != 'other') {
                        controller.otherNationality.value = '';
                      }
                      controller.fieldErrors.remove('specificNationality');
                      controller.update();
                    },
                  ),

                  if (controller.specificNationality.value == 'other')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Specify Country',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          controller.otherNationality.value = value;
                          controller.fieldErrors.remove('otherNationality');
                        },
                      ),
                    ),
                ],
              ],
            ),
          ),

          // Years with Owner
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'For how many years has the respondent been working for the owner?',
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Number of Years',
                suffixText: 'years',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                controller.yearsWithOwner.value = value;
                controller.fieldErrors.remove('yearsWithOwner');
              },
            ),
          ),

          // Show validation errors
          if (controller.pageErrors[1]?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            ...controller.pageErrors[1]!.map((error) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      )),
    );
  }
}

// Workers in Farm Page
class _WorkersInFarmContent extends StatefulWidget {
  final CombinedFarmController controller;

  const _WorkersInFarmContent({required this.controller});

  @override
  State<_WorkersInFarmContent> createState() => _WorkersInFarmContentState();
}

class _WorkersInFarmContentState extends State<_WorkersInFarmContent> {
  final TextEditingController _otherAgreementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otherAgreementController.text = widget.controller.otherAgreement.value;
    _otherAgreementController.addListener(() {
      widget.controller.otherAgreement.value = _otherAgreementController.text;
    });
  }

  @override
  void dispose() {
    _otherAgreementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
        children: [
          // Recruitment Question
          _buildQuestionCard(
            title: 'Have you recruited at least one worker during the past year?',
            child: Column(
              children: [
                _buildRadioOption(
                  label: 'Yes',
                  value: '1',
                  groupValue: controller.hasRecruitedWorker.value,
                  onChanged: (value) {
                    controller.hasRecruitedWorker.value = value!;
                    if (value == '0') {
                      controller.permanentLabor.value = false;
                      controller.casualLabor.value = false;
                    }
                    controller.update();
                  },
                ),
                _buildRadioOption(
                  label: 'No',
                  value: '0',
                  groupValue: controller.hasRecruitedWorker.value,
                  onChanged: (value) {
                    controller.hasRecruitedWorker.value = value!;
                    controller.update();
                  },
                ),
              ],
            ),
          ),

          // Labor Types (if Yes)
          if (controller.hasRecruitedWorker.value == '1') ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'Do you recruit workers for...',
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Permanent labor'),
                    value: controller.permanentLabor.value,
                    onChanged: (value) {
                      controller.permanentLabor.value = value ?? false;
                      controller.update();
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Casual labor'),
                    value: controller.casualLabor.value,
                    onChanged: (value) {
                      controller.casualLabor.value = value ?? false;
                      controller.update();
                    },
                  ),
                ],
              ),
            ),
          ],

          // Past Recruitment (if No)
          if (controller.hasRecruitedWorker.value == '0') ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'Have you ever recruited a worker before?',
              child: Column(
                children: [
                  _buildRadioOption(
                    label: 'Yes',
                    value: 'Yes',
                    groupValue: controller.everRecruitedWorker.value,
                    onChanged: (value) {
                      controller.everRecruitedWorker.value = value!;
                      controller.update();
                    },
                  ),
                  _buildRadioOption(
                    label: 'No',
                    value: 'No',
                    groupValue: controller.everRecruitedWorker.value,
                    onChanged: (value) {
                      controller.everRecruitedWorker.value = value!;
                      controller.update();
                    },
                  ),
                ],
              ),
            ),
          ],

          // Worker Agreement Type
          if (controller.hasRecruitedWorker.value == '1' ||
              (controller.hasRecruitedWorker.value == '0' && controller.everRecruitedWorker.value == 'Yes')) ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'What kind of agreement do you have with your workers?',
              child: Column(
                children: CombinedFarmController.workerAgreementOptions
                    .map((option) => _buildRadioOption(
                  label: option,
                  value: option,
                  groupValue: controller.workerAgreementType.value,
                  onChanged: (value) {
                    controller.workerAgreementType.value = value!;
                    controller.update();
                  },
                ))
                    .toList(),
              ),
            ),
          ],

          // Other Agreement Specification
          if (controller.workerAgreementType.value == 'Other (specify)') ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'If other, please specify',
              child: TextFormField(
                controller: _otherAgreementController,
                decoration: const InputDecoration(
                  labelText: 'Specify agreement type',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ),
          ],

          // Task Clarification
          if (controller.hasRecruitedWorker.value == '1') ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'Were the tasks to be performed by the worker clarified with them during the recruitment?',
              child: Column(
                children: [
                  _buildRadioOption(
                    label: 'Yes',
                    value: 'Yes',
                    groupValue: controller.tasksClarified.value,
                    onChanged: (value) {
                      controller.tasksClarified.value = value!;
                      controller.update();
                    },
                  ),
                  _buildRadioOption(
                    label: 'No',
                    value: 'No',
                    groupValue: controller.tasksClarified.value,
                    onChanged: (value) {
                      controller.tasksClarified.value = value!;
                      controller.update();
                    },
                  ),
                ],
              ),
            ),
          ],

          // Additional Tasks
          if (controller.hasRecruitedWorker.value == '1') ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'Does the worker perform tasks for you or your family members other than those agreed upon?',
              child: Column(
                children: [
                  _buildRadioOption(
                    label: 'Yes',
                    value: 'Yes',
                    groupValue: controller.additionalTasks.value,
                    onChanged: (value) {
                      controller.additionalTasks.value = value!;
                      controller.update();
                    },
                  ),
                  _buildRadioOption(
                    label: 'No',
                    value: 'No',
                    groupValue: controller.additionalTasks.value,
                    onChanged: (value) {
                      controller.additionalTasks.value = value!;
                      controller.update();
                    },
                  ),
                ],
              ),
            ),
          ],

          // Refusal Action
          if (controller.hasRecruitedWorker.value == '1') ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'What do you do when a worker refuses to perform a task?',
              child: Column(
                children: CombinedFarmController.refusalActionOptions
                    .map((option) => _buildRadioOption(
                  label: option,
                  value: option,
                  groupValue: controller.refusalAction.value,
                  onChanged: (value) {
                    controller.refusalAction.value = value!;
                    controller.update();
                  },
                ))
                    .toList(),
              ),
            ),
          ],

          // Salary Payment Frequency
          if (controller.hasRecruitedWorker.value == '1') ...[
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'Do your workers receive their full salaries?',
              child: Column(
                children: CombinedFarmController.salaryPaymentOptions
                    .map((option) => _buildRadioOption(
                  label: option,
                  value: option,
                  groupValue: controller.salaryPaymentFrequency.value,
                  onChanged: (value) {
                    controller.salaryPaymentFrequency.value = value!;
                    controller.update();
                  },
                ))
                    .toList(),
              ),
            ),
          ],

          // Agreement Statements
          if (controller.hasRecruitedWorker.value == '1' ||
              (controller.hasRecruitedWorker.value == '0' && controller.everRecruitedWorker.value == 'Yes')) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For the following section, please read the statements to the respondent, and ask him/her if he/she agrees or disagrees.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Agreement Statements
            ..._buildAgreementStatements(controller),
          ],

          // Show validation errors
          if (controller.pageErrors[2]?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            ...controller.pageErrors[2]!.map((error) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      )),
    );
  }

  List<Widget> _buildAgreementStatements(CombinedFarmController controller) {
    final statements = [
      ['salary_workers', 'It is acceptable to withhold a worker\'s salary without their consent.'],
      ['recruit_1', 'It is acceptable for a person who cannot pay their debts to work for the creditor to reimburse the debt.'],
      ['recruit_2', 'It is acceptable for an employer not to reveal the true nature of the work during the recruitment.'],
      ['recruit_3', 'A worker is obliged to work whenever he is called upon by his employer.'],
      ['conditions_1', 'A worker is not entitled to move freely.'],
      ['conditions_2', 'A worker must be free to communicate with his or her family and friends.'],
      ['conditions_3', 'A worker is obliged to adapt to any living conditions imposed by the employer.'],
      ['conditions_4', 'It is acceptable for an employer and their family to interfere in a worker\'s private life.'],
      ['conditions_5', 'A worker should not have the freedom to leave work whenever they wish.'],
      ['leaving_1', 'A worker should be required to stay longer than expected while waiting for unpaid salary.'],
      ['leaving_2', 'A worker should not be able to leave their employer when they owe money to their employer.'],
    ];

    return statements.map((statement) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _buildAgreementCard(
          statement: statement[1],
          statementId: statement[0],
          controller: controller,
        ),
      );
    }).toList();
  }

  Widget _buildAgreementCard({
    required String statement,
    required String statementId,
    required CombinedFarmController controller,
  }) {
    return Obx(() {
      final currentResponse = controller.agreementResponses[statementId];

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
                statement,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.updateAgreementResponse(statementId, 'Agree');
                        controller.update();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: currentResponse == 'Agree'
                            ? Colors.green.withOpacity(0.1)
                            : null,
                        side: BorderSide(
                          color: currentResponse == 'Agree'
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: currentResponse == 'Agree' ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        'Agree',
                        style: TextStyle(
                          color: currentResponse == 'Agree'
                              ? Colors.green
                              : Colors.grey.shade700,
                          fontWeight: currentResponse == 'Agree'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.updateAgreementResponse(statementId, 'Disagree');
                        controller.update();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: currentResponse == 'Disagree'
                            ? Colors.red.withOpacity(0.1)
                            : null,
                        side: BorderSide(
                          color: currentResponse == 'Disagree'
                              ? Colors.red
                              : Colors.grey.shade300,
                          width: currentResponse == 'Disagree' ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        'Disagree',
                        style: TextStyle(
                          color: currentResponse == 'Disagree'
                              ? Colors.red
                              : Colors.grey.shade700,
                          fontWeight: currentResponse == 'Disagree'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

// Adults Information Page
class _AdultsInformationContent extends StatelessWidget {
  final CombinedFarmController controller;

  const _AdultsInformationContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
        children: [
          // Number of Adults
          _buildQuestionCard(
            title: 'Number of adults in the household (Aged 18+)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How many adults (aged 18+) live in the household?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Number of adults',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final count = int.tryParse(value) ?? 0;
                    controller.updateNumberOfAdults(count);
                  },
                ),
              ],
            ),
          ),

          // Adult Members
          if (controller.numberOfAdults.value > 0) ...[
            const SizedBox(height: 24),
            Text(
              'Please provide information for each household member',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(controller.numberOfAdults.value, (index) {
              final member = controller.members[index];
              final memberNumber = index + 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMemberCard(
                  member: member,
                  memberNumber: memberNumber,
                  onMemberUpdated: (updatedMember) {
                    controller.updateMember(index, updatedMember);
                  },
                  context: context,
                ),
              );
            }),
          ],

          // Show validation errors
          if (controller.pageErrors[3]?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            ...controller.pageErrors[3]!.map((error) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      )),
    );
  }

  Widget _buildMemberCard({
    required HouseholdMember member,
    required int memberNumber,
    required Function(HouseholdMember) onMemberUpdated,
    required BuildContext context,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Household Member $memberNumber',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'First and Last Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                final updatedMember = member.copyWith(name: value);
                onMemberUpdated(updatedMember);
              },
            ),

            const SizedBox(height: 16),

            // Gender
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRadioOption(
                        label: 'Male',
                        value: 'male',
                        groupValue: member.producerDetails.gender,
                        onChanged: (value) {
                          final updatedDetails = member.producerDetails.copyWith(gender: value);
                          final updatedMember = member.copyWith(producerDetails: updatedDetails);
                          onMemberUpdated(updatedMember);
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildRadioOption(
                        label: 'Female',
                        value: 'female',
                        groupValue: member.producerDetails.gender,
                        onChanged: (value) {
                          final updatedDetails = member.producerDetails.copyWith(gender: value);
                          final updatedMember = member.copyWith(producerDetails: updatedDetails);
                          onMemberUpdated(updatedMember);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nationality
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nationality',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRadioOption(
                        label: 'Ghanaian',
                        value: 'ghanaian',
                        groupValue: member.producerDetails.nationality,
                        onChanged: (value) {
                          final updatedDetails = member.producerDetails.copyWith(
                            nationality: value,
                            selectedCountry: null,
                            otherCountry: null,
                          );
                          final updatedMember = member.copyWith(producerDetails: updatedDetails);
                          onMemberUpdated(updatedMember);
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildRadioOption(
                        label: 'Non-Ghanaian',
                        value: 'non_ghanaian',
                        groupValue: member.producerDetails.nationality,
                        onChanged: (value) {
                          final updatedDetails = member.producerDetails.copyWith(nationality: value);
                          final updatedMember = member.copyWith(producerDetails: updatedDetails);
                          onMemberUpdated(updatedMember);
                        },
                      ),
                    ),
                  ],
                ),

                // Country of origin for Non-Ghanaians
                if (member.producerDetails.nationality == 'non_ghanaian') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: member.producerDetails.selectedCountry,
                    decoration: const InputDecoration(
                      labelText: 'Country of Origin',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: CombinedFarmController.countryOptions
                        .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    ))
                        .toList(),
                    onChanged: (value) {
                      final updatedDetails = member.producerDetails.copyWith(
                        selectedCountry: value,
                        otherCountry: value == 'Other'
                            ? member.producerDetails.otherCountry
                            : null,
                      );
                      final updatedMember = member.copyWith(producerDetails: updatedDetails);
                      onMemberUpdated(updatedMember);
                    },
                  ),

                  if (member.producerDetails.selectedCountry == 'Other')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Specify Country',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final updatedDetails = member.producerDetails.copyWith(otherCountry: value);
                          final updatedMember = member.copyWith(producerDetails: updatedDetails);
                          onMemberUpdated(updatedMember);
                        },
                      ),
                    ),
                ],
              ],
            ),

            // Year of Birth
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Year of Birth',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final year = int.tryParse(value);
                final updatedDetails = member.producerDetails.copyWith(yearOfBirth: year);
                final updatedMember = member.copyWith(producerDetails: updatedDetails);
                onMemberUpdated(updatedMember);
              },
            ),

            // Relationship to Respondent
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relationship to Respondent',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: member.producerDetails.relationshipToRespondent,
                  decoration: const InputDecoration(
                    labelText: 'Select Relationship',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'spouse', child: Text('Spouse')),
                    DropdownMenuItem(value: 'child', child: Text('Child')),
                    DropdownMenuItem(value: 'parent', child: Text('Parent')),
                    DropdownMenuItem(value: 'sibling', child: Text('Sibling')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    final updatedDetails = member.producerDetails.copyWith(
                      relationshipToRespondent: value,
                      otherRelationship: value == 'other'
                          ? member.producerDetails.otherRelationship
                          : null,
                    );
                    final updatedMember = member.copyWith(producerDetails: updatedDetails);
                    onMemberUpdated(updatedMember);
                  },
                ),

                if (member.producerDetails.relationshipToRespondent == 'other')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Specify Relationship',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final updatedDetails = member.producerDetails.copyWith(otherRelationship: value);
                        final updatedMember = member.copyWith(producerDetails: updatedDetails);
                        onMemberUpdated(updatedMember);
                      },
                    ),
                  ),
              ],
            ),

            // Birth Certificate
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Does this person have a birth certificate?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRadioOption<String>(
                        label: 'Yes',
                        value: 'true',
                        groupValue: member.producerDetails.hasBirthCertificate,
                        onChanged: (value) {
                          final updatedDetails = member.producerDetails.copyWith(hasBirthCertificate: value);
                          final updatedMember = member.copyWith(producerDetails: updatedDetails);
                          onMemberUpdated(updatedMember);
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildRadioOption<String>(
                        label: 'No',
                        value: 'false',
                        groupValue: member.producerDetails.hasBirthCertificate,
                        onChanged: (value) {
                          final updatedDetails = member.producerDetails.copyWith(hasBirthCertificate: value);
                          final updatedMember = member.copyWith(producerDetails: updatedDetails);
                          onMemberUpdated(updatedMember);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Occupation
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Occupation',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: member.producerDetails.occupation,
                  decoration: const InputDecoration(
                    labelText: 'Select Occupation',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                    DropdownMenuItem(value: 'trader', child: Text('Trader')),
                    DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    final updatedDetails = member.producerDetails.copyWith(
                      occupation: value,
                      otherOccupation: value == 'other'
                          ? member.producerDetails.otherOccupation
                          : null,
                    );
                    final updatedMember = member.copyWith(producerDetails: updatedDetails);
                    onMemberUpdated(updatedMember);
                  },
                ),

                if (member.producerDetails.occupation == 'other')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Specify Occupation',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final updatedDetails = member.producerDetails.copyWith(otherOccupation: value);
                        final updatedMember = member.copyWith(producerDetails: updatedDetails);
                        onMemberUpdated(updatedMember);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== REUSABLE UI COMPONENTS ====================

Widget _buildQuestionCard({
  required String title,
  required Widget child,
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
          child,
        ],
      ),
    ),
  );
}

Widget _buildRadioOption<T>({
  required String label,
  required T value,
  required T? groupValue,
  required Function(T?) onChanged,
}) {
  return InkWell(
    onTap: () => onChanged(value),
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Radio<T>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: Colors.green.shade600,
          ),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    ),
  );
}