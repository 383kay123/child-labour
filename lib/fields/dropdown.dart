import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownField extends StatefulWidget {
  final String question;
  final List<String> options;
  final Function(String?)? onChanged;

  const DropdownField(
      {super.key, required this.question, required this.options, this.onChanged});

  @override
  _DropdownFieldState createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400), // Border color
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedOption,
              isExpanded: true, // Makes dropdown take full width
              hint: Text(
                "Select an option",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),
              items: widget.options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option, style: GoogleFonts.poppins(fontSize: 12)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue;
                });
                widget.onChanged?.call(newValue);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
