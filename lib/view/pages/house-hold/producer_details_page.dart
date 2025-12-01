// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../../theme/app_theme.dart';
// import 'pages/farm identification/children_household_page.dart';
//
// /// A collection of reusable spacing constants for consistent UI layout.
// class _Spacing {
//   static const double xs = 4.0;
//   static const double sm = 8.0;
//   static const double md = 16.0;
//   static const double lg = 24.0;
//   static const double xl = 32.0;
// }
//
// class ProducerDetailsPage extends StatefulWidget {
//   final String personName;
//   final Function(Map<String, dynamic>) onSave;
//   final VoidCallback? onPrevious;
//   final VoidCallback? onNext;
//
//   const ProducerDetailsPage({
//     super.key,
//     required this.personName,
//     required this.onSave,
//     this.onPrevious,
//     this.onNext,
//   });
//
//   @override
//   State<ProducerDetailsPage> createState() => _ProducerDetailsPageState();
// }
//
// class _ProducerDetailsPageState extends State<ProducerDetailsPage> {
//   final _formKey = GlobalKey<FormState>();
//   String? _gender;
//   String? _nationality;
//   final TextEditingController _yearOfBirthController = TextEditingController();
//   DateTime? _selectedDate;
//   String? _selectedCountry;
//   final TextEditingController _otherCountryController = TextEditingController();
//
//   final List<String> countries = [
//     'Burkina Faso',
//     'Mali',
//     'Guinea',
//     'Liberia',
//     'Togo',
//     'Benin',
//     'Niger',
//     'Nigeria',
//     'Other (specify)'
//   ];
//   final TextEditingController _ghanaCardIdController = TextEditingController();
//   final TextEditingController _otherIdController = TextEditingController();
//   final TextEditingController _noConsentReasonController =
//       TextEditingController();
//   String? _hasGhanaCard;
//   String? _selectedIdType;
//   bool? _consentToTakePhoto;
//   File? _idPhoto;
//   String? _relationshipToRespondent;
//   String? _hasBirthCertificate;
//   String? _selectedOccupation;
//   final TextEditingController _otherOccupationController =
//       TextEditingController();
//   final List<String> _occupationOptions = [
//     'Farmer (cocoa)',
//     'Farmer (coffee)',
//     'Farmer (other)',
//     'Merchant',
//     'Student',
//     'Other (to specify)',
//     'No activity'
//   ];
//   final TextEditingController _otherRelationshipController =
//       TextEditingController();
//
//   final List<Map<String, String>> relationshipOptions = [
//     {'value': 'husband_wife', 'label': 'Husband/Wife'},
//     {'value': 'son_daughter', 'label': 'Son/Daughter'},
//     {'value': 'brother_sister', 'label': 'Brother/Sister'},
//     {
//       'value': 'son_in_law_daughter_in_law',
//       'label': 'Son-in-law/Daughter-in-law'
//     },
//     {'value': 'grandson_granddaughter', 'label': 'Grandson/Granddaughter'},
//     {'value': 'niece_nephew', 'label': 'Niece/Nephew'},
//     {'value': 'cousin', 'label': 'Cousin'},
//     {'value': 'workers_family_member', 'label': "Worker's family member"},
//     {'value': 'worker', 'label': 'Worker'},
//     {'value': 'father_mother', 'label': 'Father/Mother'},
//     {'value': 'other', 'label': 'Other (specify)'},
//   ];
//
//   final List<Map<String, String>> idTypes = [
//     {'value': 'voter_id', 'label': 'Voter ID'},
//     {'value': 'nhis', 'label': 'NHIS Card'},
//     {'value': 'birth_cert', 'label': 'Birth Certificate'},
//     {'value': 'passport', 'label': 'Passport'},
//     {'value': 'drivers_license', 'label': 'Driver\'s License'},
//     {'value': 'none', 'label': 'None'},
//   ];
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       initialDatePickerMode: DatePickerMode.year,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Theme.of(context).colorScheme.onSurface,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//         _yearOfBirthController.text = picked.year.toString();
//       });
//     }
//   }
//
//   Future<void> _takePhoto() async {
//     try {
//       final picker = ImagePicker();
//       final XFile? photo = await picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 80,
//         maxWidth: 800,
//       );
//
//       if (photo != null) {
//         setState(() {
//           _idPhoto = File(photo.path);
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Failed to capture image'),
//             backgroundColor: Colors.red.shade600,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _yearOfBirthController.dispose();
//     _otherCountryController.dispose();
//     _ghanaCardIdController.dispose();
//     _otherIdController.dispose();
//     _noConsentReasonController.dispose();
//     _otherRelationshipController.dispose();
//     _otherOccupationController.dispose();
//     super.dispose();
//   }
//
//   Widget _buildQuestionCard({required Widget child}) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Card(
//       elevation: 0,
//       margin: const EdgeInsets.only(bottom: _Spacing.lg),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//         side: BorderSide(
//           color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
//           width: 1,
//         ),
//       ),
//       color: isDark ? AppTheme.darkCard : Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(_Spacing.lg),
//         child: child,
//       ),
//     );
//   }
//
//   Widget _buildRadioOption({
//     required String value,
//     required String? groupValue,
//     required String label,
//     required ValueChanged<String?> onChanged,
//   }) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return RadioListTile<String>(
//       title: Text(
//         label,
//         style: theme.textTheme.bodyLarge?.copyWith(
//           color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
//         ),
//       ),
//       value: value,
//       groupValue: groupValue,
//       onChanged: onChanged,
//       activeColor: AppTheme.primaryColor,
//       contentPadding: EdgeInsets.zero,
//       dense: true,
//       controlAffinity: ListTileControlAffinity.leading,
//       tileColor: isDark ? AppTheme.darkCard : Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     String hintText = '',
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//     int maxLines = 1,
//   }) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: theme.textTheme.titleMedium?.copyWith(
//             color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: _Spacing.md),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           decoration: InputDecoration(
//             hintText: hintText,
//             hintStyle: theme.textTheme.bodyMedium?.copyWith(
//               color:
//                   isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(
//                 color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(
//                 color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(
//                 color: theme.primaryColor,
//                 width: 1.5,
//               ),
//             ),
//             filled: true,
//             fillColor: isDark ? AppTheme.darkCard : Colors.white,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: _Spacing.lg,
//               vertical: _Spacing.md,
//             ),
//           ),
//           style: theme.textTheme.bodyLarge?.copyWith(
//             color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
//           ),
//           validator: validator,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDropdownField({
//     required String label,
//     required String? value,
//     required List<Map<String, String>> items,
//     required ValueChanged<String?> onChanged,
//     String? Function(String?)? validator,
//   }) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: theme.textTheme.titleMedium?.copyWith(
//             color: isDark ? AppTheme.darkTextSecondary : AppTheme.textPrimary,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: _Spacing.sm),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8.0),
//             border: Border.all(
//               color: isDark ? AppTheme.darkCard : Colors.grey.shade300,
//             ),
//             color: isDark ? AppTheme.darkCard : Colors.white,
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: _Spacing.md),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: value,
//               isExpanded: true,
//               icon: Icon(Icons.arrow_drop_down, color: theme.primaryColor),
//               iconSize: 24,
//               elevation: 16,
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
//               ),
//               onChanged: onChanged,
//               dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
//               items: items
//                   .map<DropdownMenuItem<String>>((Map<String, String> item) {
//                 return DropdownMenuItem<String>(
//                   value: item['value'],
//                   child: Text(
//                     item['label']!,
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       color: isDark
//                           ? AppTheme.darkTextPrimary
//                           : AppTheme.textPrimary,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   bool get _isFormComplete {
//     return _hasGhanaCard != null &&
//         (_hasGhanaCard == 'No' || _consentToTakePhoto != null) &&
//         _relationshipToRespondent != null &&
//         _gender != null &&
//         _nationality != null &&
//         _hasBirthCertificate != null &&
//         _selectedOccupation != null;
//   }
//
//   void _submitForm() {
//     if (_formKey.currentState?.validate() ?? false) {
//       // Parse year of birth safely
//       int? yearOfBirth;
//       if (_yearOfBirthController.text.trim().isNotEmpty) {
//         yearOfBirth = int.tryParse(_yearOfBirthController.text.trim());
//       }
//
//       // Determine occupation value
//       String? occupation;
//       if (_selectedOccupation == 'Other (to specify)' &&
//           _otherOccupationController.text.isNotEmpty) {
//         occupation = _otherOccupationController.text;
//       } else {
//         occupation = _selectedOccupation;
//       }
//
//       final details = {
//         'name': widget.personName,
//         'hasGhanaCard': _hasGhanaCard == 'Yes',
//         'ghanaCardId':
//             _hasGhanaCard == 'Yes' ? _ghanaCardIdController.text : null,
//         'otherIdType': _hasGhanaCard == 'No' ? _selectedIdType : null,
//         'otherIdNumber': _hasGhanaCard == 'No' ? _otherIdController.text : null,
//         'consentToTakePhoto': _consentToTakePhoto,
//         'noConsentReason': _consentToTakePhoto == false
//             ? _noConsentReasonController.text
//             : null,
//         'idPhotoPath': _idPhoto?.path,
//         'relationshipToRespondent': _relationshipToRespondent,
//         'otherRelationship': _relationshipToRespondent == 'other'
//             ? _otherRelationshipController.text
//             : null,
//         'gender': _gender,
//         'nationality': _nationality,
//         'yearOfBirth': yearOfBirth,
//         'countryOfOrigin': _nationality == 'non_ghanaian'
//             ? (_selectedCountry == 'Other (specify)'
//                 ? _otherCountryController.text
//                 : _selectedCountry)
//             : null,
//         'hasBirthCertificate': _hasBirthCertificate,
//         'occupation': occupation,
//       };
//
//       // Call onSave first
//       widget.onSave(details);
//
//       // Then navigate
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChildrenHouseholdPage(
//             producerDetails: details,
//           ),
//         ),
//       );
//     }
//   }
//
//   void _goBack() {
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor:
//           isDark ? AppTheme.darkBackground : AppTheme.backgroundColor,
//       appBar: AppBar(
//         title: Text(
//           'PRODUCER\'S / MANAGER\'S INFORMATION - ${widget.personName.toUpperCase()}',
//           style: theme.textTheme.titleLarge?.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: AppTheme.primaryColor,
//         automaticallyImplyLeading: false,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(_Spacing.lg),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Ghana Card Question
//                     _buildQuestionCard(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Does ${widget.personName} have a Ghana card?',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               color: isDark
//                                   ? AppTheme.darkTextSecondary
//                                   : AppTheme.textPrimary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: _Spacing.md),
//                           Wrap(
//                             spacing: 20,
//                             children: [
//                               _buildRadioOption(
//                                 value: 'Yes',
//                                 groupValue: _hasGhanaCard,
//                                 label: 'Yes',
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _hasGhanaCard = value;
//                                     _selectedIdType = null;
//                                     _otherIdController.clear();
//                                   });
//                                 },
//                               ),
//                               _buildRadioOption(
//                                 value: 'No',
//                                 groupValue: _hasGhanaCard,
//                                 label: 'No',
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _hasGhanaCard = value;
//                                     if (_hasGhanaCard == 'No') {
//                                       _ghanaCardIdController.clear();
//                                     }
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Other ID Card (shown when 'No' is selected)
//                     if (_hasGhanaCard == 'No')
//                       _buildQuestionCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildDropdownField(
//                               label:
//                                   'Which other national id card is available',
//                               value: _selectedIdType,
//                               items: idTypes,
//                               onChanged: (value) {
//                                 setState(() {
//                                   _selectedIdType = value;
//                                 });
//                               },
//                               validator: (value) {
//                                 if (_hasGhanaCard == 'No' &&
//                                     (value == null || value.isEmpty)) {
//                                   return 'Please select an ID type';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     // Show consent question if has Ghana card or any other national ID (not 'none')
//                     if ((_hasGhanaCard == 'Yes' && _selectedIdType != 'none') ||
//                         (_hasGhanaCard == 'No' &&
//                             _selectedIdType != null &&
//                             _selectedIdType != 'none'))
//                       _buildQuestionCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Do you consent to us taking a picture of your identification document?',
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 color: isDark
//                                     ? AppTheme.darkTextSecondary
//                                     : AppTheme.textPrimary,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: _Spacing.md),
//                             Wrap(
//                               spacing: 20,
//                               children: [
//                                 _buildRadioOption(
//                                   value: 'Yes',
//                                   groupValue: _consentToTakePhoto == null
//                                       ? null
//                                       : (_consentToTakePhoto! ? 'Yes' : 'No'),
//                                   label: 'Yes',
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _consentToTakePhoto = value == 'Yes';
//                                     });
//                                   },
//                                 ),
//                                 _buildRadioOption(
//                                   value: 'No',
//                                   groupValue: _consentToTakePhoto == null
//                                       ? null
//                                       : (_consentToTakePhoto! ? 'Yes' : 'No'),
//                                   label: 'No',
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _consentToTakePhoto = value == 'Yes';
//                                     });
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     // ID Photo Section (shown when consent is given and has a valid ID type)
//                     if (_consentToTakePhoto == true &&
//                         ((_hasGhanaCard == 'Yes' &&
//                                 _selectedIdType != 'none') ||
//                             (_hasGhanaCard == 'No' &&
//                                 _selectedIdType != null &&
//                                 _selectedIdType != 'none')))
//                       _buildQuestionCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'ID Photo',
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 color: isDark
//                                     ? AppTheme.darkTextSecondary
//                                     : AppTheme.textPrimary,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: _Spacing.md),
//                             GestureDetector(
//                               onTap: _takePhoto,
//                               child: Container(
//                                 height: 200,
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color: isDark
//                                         ? AppTheme.darkCard
//                                         : Colors.grey.shade300,
//                                   ),
//                                   borderRadius: BorderRadius.circular(8),
//                                   color: isDark
//                                       ? AppTheme.darkCard
//                                       : Colors.grey[100],
//                                 ),
//                                 child: _idPhoto == null
//                                     ? Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(Icons.camera_alt,
//                                               size: 40,
//                                               color: isDark
//                                                   ? Colors.white70
//                                                   : Colors.grey[500]),
//                                           const SizedBox(height: 8),
//                                           Text(
//                                             'Tap to take photo of ID',
//                                             style: theme.textTheme.bodyMedium
//                                                 ?.copyWith(
//                                               color: isDark
//                                                   ? Colors.white70
//                                                   : Colors.grey[600],
//                                             ),
//                                           ),
//                                         ],
//                                       )
//                                     : ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: Image.file(
//                                           _idPhoto!,
//                                           fit: BoxFit.cover,
//                                           width: double.infinity,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     // No Consent Reason (shown when consent is not given)
//                     if (_consentToTakePhoto == false)
//                       _buildQuestionCard(
//                         child: _buildTextField(
//                           label: 'Reason for not providing photo',
//                           controller: _noConsentReasonController,
//                           hintText: 'Please specify reason',
//                           maxLines: 3,
//                         ),
//                       ),
//
//                     // Relationship to Respondent
//                     _buildQuestionCard(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: _Spacing.md),
//                           _buildDropdownField(
//                             label:
//                                 'Relationship of ${widget.personName} to the '
//                                 'respondent (Farmer/Manager/Cartaker)',
//                             value: _relationshipToRespondent,
//                             items: relationshipOptions,
//                             onChanged: (value) {
//                               setState(() {
//                                 _relationshipToRespondent = value;
//                               });
//                             },
//                           ),
//                           if (_relationshipToRespondent == 'worker' ||
//                               _relationshipToRespondent ==
//                                   'workers_family_member')
//                             Padding(
//                               padding: const EdgeInsets.only(top: _Spacing.sm),
//                               child: Text(
//                                 '***Make sure to interview the Worker or Family of the Worker should any of these 2 be selected above.***',
//                                 style: TextStyle(
//                                   color: Colors.orange[800],
//                                   fontStyle: FontStyle.italic,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           if (_relationshipToRespondent == 'other') ...[
//                             const SizedBox(height: _Spacing.md),
//                             _buildTextField(
//                               label: 'If Other, please specify',
//                               controller: _otherRelationshipController,
//                               hintText: 'Enter relationship',
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//
//                     // Gender Selection
//                     _buildQuestionCard(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Gender of ${widget.personName}',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               color: isDark
//                                   ? AppTheme.darkTextSecondary
//                                   : AppTheme.textPrimary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: _Spacing.md),
//                           Wrap(
//                             spacing: 20,
//                             children: [
//                               _buildRadioOption(
//                                 value: 'male',
//                                 groupValue: _gender,
//                                 label: 'Male',
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _gender = value;
//                                   });
//                                 },
//                               ),
//                               _buildRadioOption(
//                                 value: 'female',
//                                 groupValue: _gender,
//                                 label: 'Female',
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _gender = value;
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Nationality
//                     _buildQuestionCard(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Nationality of ${widget.personName}',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               color: isDark
//                                   ? AppTheme.darkTextSecondary
//                                   : AppTheme.textPrimary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: _Spacing.md),
//                           Wrap(
//                             spacing: 20,
//                             children: [
//                               _buildRadioOption(
//                                 value: 'ghanaian',
//                                 groupValue: _nationality,
//                                 label: 'Ghanaian',
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _nationality = value;
//                                     if (_nationality == 'ghanaian') {
//                                       _selectedCountry = null;
//                                       _otherCountryController.clear();
//                                     }
//                                   });
//                                 },
//                               ),
//                               _buildRadioOption(
//                                 value: 'non_ghanaian',
//                                 groupValue: _nationality,
//                                 label: 'Non-Ghanaian',
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _nationality = value;
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Country of Origin (Conditional)
//                     if (_nationality == 'non_ghanaian')
//                       _buildQuestionCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildDropdownField(
//                               label: 'If Non Ghanaian, specify country of '
//                                   'origin',
//                               value: _selectedCountry,
//                               items: countries
//                                   .map((country) =>
//                                       {'value': country, 'label': country})
//                                   .toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   _selectedCountry = value;
//                                 });
//                               },
//                             ),
//                             if (_selectedCountry == 'Other (specify)') ...[
//                               const SizedBox(height: _Spacing.md),
//                               _buildTextField(
//                                 label: 'If other please specify',
//                                 controller: _otherCountryController,
//                                 hintText: 'Enter country name',
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//
//                     // Year of Birth
//                     _buildQuestionCard(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Year of Birth of ${widget.personName}',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium
//                                 ?.copyWith(
//                                   color: Theme.of(context).brightness ==
//                                           Brightness.dark
//                                       ? AppTheme.darkTextSecondary
//                                       : AppTheme.textPrimary,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                           ),
//                           const SizedBox(height: 8),
//                           InkWell(
//                             onTap: () => _selectDate(context),
//                             child: InputDecorator(
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 12,
//                                 ),
//                                 suffixIcon:
//                                     const Icon(Icons.calendar_today, size: 20),
//                               ),
//                               child: Text(
//                                 _selectedDate != null
//                                     ? '${_selectedDate!.year}'
//                                     : 'Select year of birth',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyMedium
//                                     ?.copyWith(
//                                       color: _selectedDate != null
//                                           ? null
//                                           : Theme.of(context).hintColor,
//                                     ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Birth Certificate Question
//                     _buildQuestionCard(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Does ${widget.personName} have a birth certificate?',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               color: isDark
//                                   ? AppTheme.darkTextSecondary
//                                   : AppTheme.textPrimary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: _Spacing.md),
//                           Wrap(
//                             spacing: 20,
//                             children: [
//                               _buildRadioOption(
//                                 value: 'yes',
//                                 groupValue: _hasBirthCertificate,
//                                 label: 'Yes',
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _hasBirthCertificate = value;
//                                   });
//                                 },
//                               ),
//                               _buildRadioOption(
//                                 value: 'no',
//                                 groupValue: _hasBirthCertificate,
//                                 label: 'No',
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _hasBirthCertificate = value;
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Occupation
//                     _buildQuestionCard(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: _Spacing.md),
//                           _buildDropdownField(
//                             label:
//                                 'Work/main occupation of ${widget.personName}',
//                             value: _selectedOccupation,
//                             items: _occupationOptions
//                                 .map((occupation) =>
//                                     {'value': occupation, 'label': occupation})
//                                 .toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 _selectedOccupation = value;
//                               });
//                             },
//                           ),
//                           if (_selectedOccupation == 'Other (to specify)') ...[
//                             const SizedBox(height: _Spacing.md),
//                             _buildTextField(
//                               label: 'If other,please specify',
//                               controller: _otherOccupationController,
//                               hintText: 'Enter occupation',
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 80), // Space for bottom button
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(_Spacing.lg),
//         decoration: BoxDecoration(
//           color: Theme.of(context).scaffoldBackgroundColor,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 // Previous Button
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _goBack,
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       side: BorderSide(color: Colors.green.shade600, width: 2),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.arrow_back_ios,
//                             size: 18, color: Colors.green.shade600),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Previous',
//                           style: TextStyle(
//                             color: Colors.green.shade600,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 // Next Button
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _isFormComplete ? _submitForm : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _isFormComplete
//                           ? Colors.green.shade600
//                           : Colors.grey[400],
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 2,
//                       shadowColor: Colors.green.shade600.withOpacity(0.3),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Next',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         const Icon(Icons.arrow_forward_ios,
//                             size: 18, color: Colors.white),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
