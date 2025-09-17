import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownCheckboxField extends StatefulWidget {
  final String question;
  final List<String> options;
  final String? cautionText;
  final Function(Map<String, bool>) onChanged;
  final bool singleSelect;

  const DropdownCheckboxField({
    super.key,
    required this.question,
    required this.options,
    this.cautionText,
    required this.onChanged,
    this.singleSelect = false,
  });

  @override
  _DropdownCheckboxFieldState createState() => _DropdownCheckboxFieldState();
}

class _DropdownCheckboxFieldState extends State<DropdownCheckboxField> {
  Map<String, bool> selectedOptions = {};

  @override
  void initState() {
    super.initState();
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
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        if (widget.cautionText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.cautionText!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.red,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: widget.options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedOptions[option] == true
                          ? const Color(0xFF00754B)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: selectedOptions[option] == true
                        ? const Color(0xFFE8F5F0)
                        : Colors.white,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        if (widget.singleSelect) {
                          selectedOptions.forEach((key, _) {
                            selectedOptions[key] = false;
                          });
                          selectedOptions[option] = !selectedOptions[option]!;
                        } else {
                          selectedOptions[option] = !selectedOptions[option]!;
                        }
                        widget
                            .onChanged(Map<String, bool>.from(selectedOptions));
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: selectedOptions[option] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                if (widget.singleSelect) {
                                  selectedOptions.forEach((key, _) {
                                    selectedOptions[key] = false;
                                  });
                                }
                                selectedOptions[option] = value ?? false;
                                widget.onChanged(
                                    Map<String, bool>.from(selectedOptions));
                              });
                            },
                            activeColor: const Color(0xFF00754B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              option,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: selectedOptions[option] == true
                                    ? const Color(0xFF00754B)
                                    : Colors.black87,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
