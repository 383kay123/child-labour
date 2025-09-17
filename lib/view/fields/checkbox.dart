import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckboxField extends StatefulWidget {
  final String question;
  final List<String> options;

  const CheckboxField({
    super.key,
    required this.question,
    required this.options,
  });

  @override
  _CheckboxFieldState createState() => _CheckboxFieldState();
}

class _CheckboxFieldState extends State<CheckboxField> {
  Map<String, bool> selectedOptions = {}; // Tracks selected checkboxes

  @override
  void initState() {
    super.initState();
    // Initialize all options as unchecked
    for (var option in widget.options) {
      selectedOptions[option] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(
                  bottom: 6.0), // Space between checkboxes
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: selectedOptions[option],
                    onChanged: (bool? value) {
                      setState(() {
                        selectedOptions[option] = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF00754B), // App's primary color
                  ),
                  Expanded(
                    // Ensures text wraps properly
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
