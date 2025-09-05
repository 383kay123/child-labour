import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TimePickerField extends StatefulWidget {
  final String question;

  const TimePickerField({super.key, required this.question});

  @override
  State<TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  DateTime? recordedDateTime;

  void _recordNow() {
    setState(() {
      recordedDateTime = DateTime.now();
    });
  }

  void _clear() {
    setState(() {
      recordedDateTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayText = recordedDateTime != null
        ? DateFormat('dd/MM/yyyy hh:mm a').format(recordedDateTime!)
        : 'Tap to record date & time';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: recordedDateTime == null
              ? _recordNow
              : null, // only allow tap to record when empty
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: recordedDateTime == null
                          ? const Color(0xFF00754B)
                          : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (recordedDateTime != null)
                  GestureDetector(
                    onTap: _clear,
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
