import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownField extends StatefulWidget {
  final String question;
  final List<String> options;
  final Function(String?)? onChanged;
  final String? defaultValue;
  final String hintText;

  const DropdownField({
    super.key,
    required this.question,
    required this.options,
    this.onChanged,
    this.defaultValue,
    this.hintText = "Select an option",
  });

  @override
  _DropdownFieldState createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    // Set the default value when the widget is initialized
    selectedOption = widget.defaultValue;
  }

  @override
  void didUpdateWidget(DropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected option if defaultValue changes
    if (widget.defaultValue != oldWidget.defaultValue) {
      setState(() {
        selectedOption = widget.defaultValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedOption,
              isExpanded: true,
              hint: Text(
                widget.hintText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              items: widget.options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
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