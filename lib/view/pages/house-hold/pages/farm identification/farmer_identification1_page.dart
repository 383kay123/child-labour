import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmerIdentification1Page extends StatefulWidget {
  final Function(Map<String, dynamic>)? onComplete;
  final Map<String, dynamic>? initialData;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const FarmerIdentification1Page({
    Key? key,
    this.onComplete,
    this.initialData,
    this.onPrevious,
    this.onNext,
  }) : super(key: key);

  @override
  _FarmerIdentification1PageState createState() =>
      _FarmerIdentification1PageState();
}

class _FarmerIdentification1PageState extends State<FarmerIdentification1Page> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _hasGhanaCard;
  String? _selectedIdType; // Will store the selected ID type
  String? _idNumber;
  String? _idPictureConsent;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      final formData = {
        'farmer_gh_card_available': _hasGhanaCard == 'Yes' ? 'yes' : 'no',
        'farmer_nat_id_available': _hasGhanaCard == 'Yes'
            ? 'ghana_card'
            : _selectedIdType == 'voter_id'
                ? 'voter'
                : _selectedIdType == 'nhis_card'
                    ? 'nhis'
                    : _selectedIdType == 'passport'
                        ? 'passport'
                        : _selectedIdType == 'drivers_license'
                            ? 'driver'
                            : _selectedIdType == 'birth_certificate'
                                ? 'birth'
                                : 'other',
        'id_picture_consent': _idPictureConsent,
      };

      // Handle form submission
      widget.onComplete?.call({});

      // Navigate to next page if callback is provided
      if (widget.onNext != null) {
        widget.onNext!();
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ghana Card Question
                      Text(
                        'Do you have a Ghana Card?',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'Yes',
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                              value: 'Yes',
                              groupValue: _hasGhanaCard,
                              onChanged: (value) {
                                setState(() {
                                  _hasGhanaCard = value;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(
                                'No',
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                              value: 'No',
                              groupValue: _hasGhanaCard,
                              onChanged: (value) {
                                setState(() {
                                  _hasGhanaCard = value;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),

                      // Show alternative ID options if no Ghana Card
                      if (_hasGhanaCard == 'No') ...[
                        const SizedBox(height: 20),
                        Text(
                          'Which of the following ID cards do you have?',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Voter ID
                        RadioListTile<String>(
                          title: Text('Voter ID',
                              style: GoogleFonts.inter(fontSize: 14)),
                          value: 'voter_id',
                          groupValue: _selectedIdType,
                          onChanged: (value) {
                            setState(() => _selectedIdType = value);
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),

                        // Driver's License
                        RadioListTile<String>(
                          title: Text('Driver\'s License',
                              style: GoogleFonts.inter(fontSize: 14)),
                          value: 'drivers_license',
                          groupValue: _selectedIdType,
                          onChanged: (value) {
                            setState(() => _selectedIdType = value);
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),

                        // NHIS Card
                        RadioListTile<String>(
                          title: Text('NHIS Card',
                              style: GoogleFonts.inter(fontSize: 14)),
                          value: 'nhis_card',
                          groupValue: _selectedIdType,
                          onChanged: (value) {
                            setState(() => _selectedIdType = value);
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),

                        // Passport
                        RadioListTile<String>(
                          title: Text('Passport',
                              style: GoogleFonts.inter(fontSize: 14)),
                          value: 'passport',
                          groupValue: _selectedIdType,
                          onChanged: (value) {
                            setState(() => _selectedIdType = value);
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),

                        // SSNIT
                        RadioListTile<String>(
                          title: Text('SSNIT',
                              style: GoogleFonts.inter(fontSize: 14)),
                          value: 'ssnit',
                          groupValue: _selectedIdType,
                          onChanged: (value) {
                            setState(() => _selectedIdType = value);
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),

                        // Consent Question
                        if (_hasGhanaCard == 'Yes' ||
                            _selectedIdType == 'voter_id' ||
                            _selectedIdType == 'nhis_card' ||
                            _selectedIdType == 'birth_certificate' ||
                            _selectedIdType == 'passport' ||
                            _selectedIdType == 'drivers_license') ...[
                          const SizedBox(height: 24),
                          Text(
                            'Do you consent to us taking a picture of your national ID and taking ID number?',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Yes',
                                groupValue: _idPictureConsent,
                                onChanged: (value) {
                                  setState(() => _idPictureConsent = value);
                                },
                              ),
                              Text('Yes',
                                  style: GoogleFonts.inter(fontSize: 14)),
                              const SizedBox(width: 20),
                              Radio<String>(
                                value: 'No',
                                groupValue: _idPictureConsent,
                                onChanged: (value) {
                                  setState(() => _idPictureConsent = value);
                                },
                              ),
                              Text('No',
                                  style: GoogleFonts.inter(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Submit Button
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              widget.onNext != null
                                  ? 'Save & Continue'
                                  : 'Save',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Previous Button (if provided)
                        if (widget.onPrevious != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: widget.onPrevious,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Previous',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ]),
              ),
            ),
    );
  }
}
