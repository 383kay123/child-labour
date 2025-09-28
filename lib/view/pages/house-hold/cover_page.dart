import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoverPage extends StatelessWidget {
  final String? selectedTown;
  final String? selectedFarmer;
  final List<Map<String, String>> towns;
  final List<Map<String, String>> farmers;
  final ValueChanged<String?> onTownChanged;
  final ValueChanged<String?> onFarmerChanged;
  final VoidCallback onNext;

  const CoverPage({
    Key? key,
    required this.selectedTown,
    required this.selectedFarmer,
    required this.towns,
    required this.farmers,
    required this.onTownChanged,
    required this.onFarmerChanged,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(0.02),
            primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Society Selection
                  _buildSection(
                    context: context,
                    title: 'Select Society',
                    icon: Icons.apartment_rounded,
                    child: _buildDropdown(
                      context: context,
                      value: selectedTown,
                      items: towns,
                      onChanged: onTownChanged,
                      hint: 'Select your society',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Farmer Selection
                  _buildSection(
                    context: context,
                    title: 'Select Farmer',
                    icon: Icons.person_outline_rounded,
                    child: _buildDropdown(
                      context: context,
                      value: selectedFarmer,
                      items: farmers,
                      onChanged: onFarmerChanged,
                      hint: 'Select a farmer',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Next Button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 25,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: _buildNextButton(
              context,
              onNext: onNext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon with animated background
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.9),
                primaryColor.withBlue(primaryColor.blue + 30).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.assessment_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        // Title with gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              primaryColor,
              primaryColor.withBlue(primaryColor.blue + 50),
            ],
          ).createShader(bounds),
          child: Text(
            'Farm Survey',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.8,
              color: Colors.white, // This is required for the shader to work
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Subtitle with improved typography
        Text(
          'Select the society and farmer to begin your survey',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
            height: 1.5,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
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
              // Icon with gradient background
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: primaryColor,
                ),
              ),

              const SizedBox(width: 12),

              // Section Title with subtle animation
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Child widget with animated entry
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    final validItems = items.where((item) => item['code'] != null).toList();
    final selectedValue =
        validItems.any((item) => item['code'] == value) ? value : null;
    final theme = Theme.of(context);
    final isSelected = selectedValue != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.3)
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                onChanged: onChanged,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.hintColor.withOpacity(0.7),
                  size: 24,
                ),
                hint: Text(
                  hint,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0x8064758B),
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                items: validItems
                    .map<DropdownMenuItem<String>>((Map<String, String> item) {
                  return DropdownMenuItem<String>(
                    value: item['code']!,
                    child: Text(
                      item['name'] ?? 'Unnamed',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
                menuMaxHeight: 300,
                selectedItemBuilder: (BuildContext context) {
                  return validItems.map<Widget>((Map<String, String> item) {
                    return Text(
                      item['name'] ?? 'Unnamed',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context, {
    required VoidCallback onNext,
    bool isEnabled = true,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withBlue(primaryColor.blue + 50),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? onNext : null,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue to Consent and Location',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        key: ValueKey<bool>(isEnabled),
                        size: 20,
                        color: isEnabled
                            ? Colors.white
                            : const Color(0x8064758B).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
