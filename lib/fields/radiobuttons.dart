import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RadioButtonField extends StatelessWidget {
  final String question;
  final List<String> options;
  final String? value;
  final Function(String?)? onChanged; // updated to accept null
  final String? cautionText;

  const RadioButtonField({
    Key? key,
    required this.question,
    required this.options,
    this.value,
    this.onChanged,
    this.cautionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        if (cautionText != null) ...[
          const SizedBox(height: 8),
          Text(
            cautionText!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.red,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 5.0,
          children: options.map((option) {
            final isSelected = value == option;
            return Container(
              width: MediaQuery.of(context).size.width / 1,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00754B)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? const Color(0xFFE8F5F0) : Colors.white,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged?.call(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 1.0),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue: value,
                        onChanged: (newValue) => onChanged?.call(newValue),
                        activeColor: const Color(0xFF00754B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          option,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isSelected
                                ? const Color(0xFF00754B)
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected)
                        IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 18,
                            color: Color(0xFF00754B),
                          ),
                          onPressed: () =>
                              onChanged?.call(null), // Clear selection
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
