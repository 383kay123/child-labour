import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionField extends StatelessWidget {
  final String question;
  final String? cautionText;
  final Function(String)? onChanged;
  final TextInputType keyboardType;

  const QuestionField({
    super.key,
    required this.question,
    this.cautionText,
    this.onChanged,
    this.keyboardType = TextInputType.text,
  });

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
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
