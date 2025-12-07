import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/models/dropdown_item_model.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/consent/consent_page.dart';
import 'cover_page_controller.dart';

class CoverPageForm extends StatelessWidget {
  // final VoidCallback onContinue;

  const CoverPageForm({
    Key? key,
    // required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoverPageController>(
      init: CoverPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Cover Form"),
          ),
          body: Column(
            children: [
              // Header
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              //   decoration: BoxDecoration(
              //     color: Theme.of(context).primaryColor,
              //     borderRadius: const BorderRadius.only(
              //       bottomLeft: Radius.circular(20),
              //       bottomRight: Radius.circular(20),
              //     ),
              //   ),
              //   child: SafeArea(
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           children: [
              //             IconButton(
              //               onPressed: () => Get.back(),
              //               icon: const Icon(Icons.arrow_back,
              //                   color: Colors.white),
              //             ),
              //             const SizedBox(width: 12),
              //             Text(
              //               'Cover Page',
              //               style: GoogleFonts.inter(
              //                 fontSize: 20,
              //                 fontWeight: FontWeight.w600,
              //                 color: Colors.white,
              //               ),
              //             ),
              //           ],
              //         ),
              //         const SizedBox(height: 8),
              //         Text(
              //           'Select society and farmer to begin survey',
              //           style: GoogleFonts.inter(
              //             fontSize: 14,
              //             color: Colors.white.withOpacity(0.9),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Society Selection
                      _buildSectionCard(
                        title: 'Select Society',
                        icon: Icons.apartment_rounded,
                        child: _buildSocietyDropdown(controller),
                      ),

                      const SizedBox(height: 20),

                      // Farmer Selection
                      _buildSectionCard(
                        title: 'Select Farmer',
                        icon: Icons.person_outline_rounded,
                        child: _buildFarmerDropdown(controller),
                      ),

                      const SizedBox(height: 40),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate and save before continuing
                            final saved = await controller.saveData();
                            if (saved) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return  ConsentForm(
                                  coverId: controller.coverPageId.value,
                                );
                              }));
                              // onContinue();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Obx(() => Text(
                                controller.isLoadingTowns.value ||
                                        controller.isLoadingFarmers.value
                                    ? 'Loading...'
                                    : 'Continue',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                        ),
                      ),
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(Get.context!).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSocietyDropdown(CoverPageController controller) {
    return Obx(() {
      if (controller.isLoadingTowns.value) {
        return _buildLoadingState();
      }

      if (controller.towns.isEmpty) {
        return _buildEmptyState(
          icon: Icons.location_city_outlined,
          message: 'No societies available',
          submessage: 'Please check your connection',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomDropdown(
            value: controller.selectedTownCode.value,
            items: controller.towns,
            hint: 'Select your society',
            onChanged: (DropdownItem? item) =>
                item != null ? controller.selectTown(item.code) : null,
            error: controller.townError.value,
          ),
          if (controller.townError.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.townError.value,
                style: TextStyle(
                  color: Theme.of(Get.context!).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildFarmerDropdown(CoverPageController controller) {
    return Obx(() {
      if (controller.isLoadingFarmers.value) {
        return _buildLoadingState();
      }

      if (controller.farmers.isEmpty) {
        return _buildEmptyState(
          icon: Icons.people_outline,
          message: 'No farmers available',
          submessage: 'Please check your connection',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomDropdown(
            value: controller.selectedFarmerCode.value,
            items: controller.farmers,
            hint: 'Select a farmer',
            onChanged: (DropdownItem? item) =>
                item != null ? controller.selectFarmer(item.code) : null,
            error: controller.farmerError.value,
          ),
          if (controller.farmerError.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.farmerError.value,
                style: TextStyle(
                  color: Theme.of(Get.context!).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildCustomDropdown({
    required String value,
    required List<DropdownItem> items,
    required String hint,
    required ValueChanged<DropdownItem?>? onChanged,
    String? error,
  }) {
    final theme = Theme.of(Get.context!);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: error != null ? theme.colorScheme.error : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DropdownItem>(
          value: items.any((item) => item.code == value)
              ? items.firstWhere((item) => item.code == value)
              : null,
          items: items
              .map((item) => DropdownMenuItem<DropdownItem>(
                    value: item,
                    child: Text(item.name),
                  ))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_drop_down_rounded,
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              hint,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Container(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading...',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String submessage,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              color: Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            submessage,
            style: GoogleFonts.inter(
              color: Colors.grey.shade600,
              fontSize: 14,
              // textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
