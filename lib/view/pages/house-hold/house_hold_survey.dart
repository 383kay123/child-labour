// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
//
// import '../../models/household_survey.dart';
// import 'house_hold_survey_provider.dart';
//
// class HouseHoldSurveyScreen extends StatefulWidget {
//   final String? surveyId;
//   final bool isNewSurvey;
//
//   const HouseHoldSurveyScreen({
//     super.key,
//     this.surveyId,
//     this.isNewSurvey = true,
//   });
//
//   @override
//   _HouseHoldSurveyScreenState createState() => _HouseHoldSurveyScreenState();
// }
//
// class _HouseHoldSurveyScreenState extends State<HouseHoldSurveyScreen> {
//   late final HouseHoldSurveyProvider _provider;
//   final ImagePicker _picker = ImagePicker();
//   int _currentPage = 0;
//   int _totalPages = 1; // Will be updated with actual page count
//
//   @override
//   void initState() {
//     super.initState();
//     _provider = context.read<HouseHoldSurveyProvider>();
//     _initializeSurvey();
//   }
//
//   Future<void> _initializeSurvey() async {
//     await _provider.initializeSurvey(
//       surveyId: widget.surveyId,
//       isNewSurvey: widget.isNewSurvey,
//     );
//
//     // Initialize total pages based on the number of questions or sections
//     // You might need to adjust this based on how your survey is structured
//     setState(() {
//       _totalPages = _provider.surveyQuestions.length; // or another way to calculate total pages
//     });
//   }
//
//   Widget _buildQuestion(SurveyQuestion question, HouseHoldSurveyProvider provider) {
//     final currentValue = provider.getCurrentResponse(question.id);
//
//     switch (question.type) {
//       case 'yes_no':
//         return _buildYesNoQuestion(question, currentValue, provider);
//       case 'multiple_choice':
//         return _buildMultipleChoiceQuestion(question, currentValue, provider);
//       case 'checkbox':
//         return _buildCheckboxQuestion(question, currentValue, provider);
//       case 'text':
//       case 'numeric':
//       case 'date':
//         return _buildTextQuestion(question, currentValue, provider);
//       case 'picture':
//         return _buildPictureQuestion(question, currentValue, provider);
//       case 'gps':
//         return _buildGpsQuestion(question, currentValue, provider);
//       case 'instruction':
//         return _buildInstruction(question);
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   Widget _buildYesNoQuestion(
//       SurveyQuestion question, dynamic currentValue, HouseHoldSurveyProvider provider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(question.question,
//             style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             _buildChoiceChip('Yes', currentValue == 'Yes', (selected) {
//               provider.saveResponse(question.id, 'Yes');
//             }),
//             const SizedBox(width: 16),
//             _buildChoiceChip('No', currentValue == 'No', (selected) {
//               provider.saveResponse(question.id, 'No');
//             }),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildChoiceChip(
//       String label, bool selected, ValueChanged<bool> onSelected) {
//     return ChoiceChip(
//       label: Text(label),
//       selected: selected,
//       onSelected: onSelected,
//       selectedColor: const Color(0xFF006A4E).withOpacity(0.2),
//       labelStyle: GoogleFonts.poppins(
//         color: selected ? const Color(0xFF006A4E) : Colors.black87,
//       ),
//     );
//   }
//
//   Widget _buildMultipleChoiceQuestion(
//       SurveyQuestion question, dynamic currentValue, HouseHoldSurveyProvider provider) {
//     if (question.options == null) return const SizedBox.shrink();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(question.question,
//             style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 16),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: question.options!.map((option) {
//             return _buildChoiceChip(option, currentValue == option, (selected) {
//               provider.saveResponse(question.id, option);
//             });
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCheckboxQuestion(
//       SurveyQuestion question, dynamic currentValue, HouseHoldSurveyProvider provider) {
//     if (question.options == null) return const SizedBox.shrink();
//
//     final selectedOptions =
//     currentValue is List ? List<String>.from(currentValue) : [];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(question.question,
//             style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 16),
//         ...question.options!.map((option) {
//           return CheckboxListTile(
//             title: Text(option),
//             value: selectedOptions.contains(option),
//             onChanged: (bool? selected) {
//               List<String> updated = List.from(selectedOptions);
//               if (selected == true) {
//                 updated.add(option);
//               } else {
//                 updated.remove(option);
//               }
//               provider.saveResponse(question.id, updated);
//             },
//             controlAffinity: ListTileControlAffinity.leading,
//           );
//         }).toList(),
//       ],
//     );
//   }
//
//   Widget _buildTextQuestion(
//       SurveyQuestion question, dynamic currentValue, HouseHoldSurveyProvider provider) {
//     final controller =
//     TextEditingController(text: currentValue?.toString() ?? '');
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(question.question,
//             style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 16),
//         TextField(
//           controller: controller,
//           keyboardType:
//           question.type == 'numeric' ? TextInputType.number : TextInputType.text,
//           decoration: InputDecoration(
//             hintText: question.hint,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           onChanged: (value) {
//             provider.saveResponse(question.id, value);
//           },
//         ),
//       ],
//     );
//   }
//
//   Future<String?> _pickAndSaveImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//       if (image == null) return null;
//
//       final appDir = await getApplicationDocumentsDirectory();
//       final imagesDir = Directory('${appDir.path}/survey_images');
//       if (!await imagesDir.exists()) {
//         await imagesDir.create(recursive: true);
//       }
//
//       final fileName =
//           '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
//       final newPath = '${imagesDir.path}/$fileName';
//
//       await File(image.path).copy(newPath);
//       return newPath;
//     } catch (e) {
//       debugPrint('Error picking/saving image: $e');
//       return null;
//     }
//   }
//
//   Widget _buildPictureQuestion(
//       SurveyQuestion question, dynamic currentValue, HouseHoldSurveyProvider provider) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(question.question,
//             style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 16),
//         if (currentValue != null && currentValue is String && currentValue.isNotEmpty)
//           Container(
//             margin: const EdgeInsets.only(bottom: 16),
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.file(
//                     File(currentValue),
//                     width: double.infinity,
//                     height: 200,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: CircleAvatar(
//                     backgroundColor: Colors.black54,
//                     radius: 18,
//                     child: IconButton(
//                       icon: const Icon(Icons.close, size: 18, color: Colors.white),
//                       onPressed: () => provider.saveResponse(question.id, null),
//                       padding: EdgeInsets.zero,
//                       visualDensity: VisualDensity.compact,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         else
//           ElevatedButton.icon(
//             onPressed: () async {
//               final imagePath = await _pickAndSaveImage();
//               if (imagePath != null) {
//                 provider.saveResponse(question.id, imagePath);
//               }
//             },
//             icon: const Icon(Icons.camera_alt),
//             label: const Text('Take Photo'),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildGpsQuestion(
//       SurveyQuestion question, dynamic currentValue, HouseHoldSurveyProvider provider) {
//     // Placeholder implementation
//     return Text("GPS question: ${question.question}");
//   }
//
//   Widget _buildInstruction(SurveyQuestion question) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16.0),
//       child: Text(
//         question.question,
//         style: GoogleFonts.poppins(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: const Color(0xFF006A4E),
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
//
//   final int _questionsPerPage = 20;
//
//   List<SurveyQuestion> _getCurrentPageQuestions(List<SurveyQuestion> allQuestions) {
//     final startIndex = _currentPage * _questionsPerPage;
//     final endIndex = (startIndex + _questionsPerPage).clamp(0, allQuestions.length);
//     return allQuestions.sublist(startIndex, endIndex);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HouseHoldSurveyProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const Scaffold(body: Center(child: CircularProgressIndicator()));
//         }
//
//         final questions = provider.questions;
//         final totalPages = (questions.length / _questionsPerPage).ceil();
//         if (questions.isEmpty) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Household Survey')),
//             body: const Center(child: Text('No questions found.')),
//           );
//         }
//
//         final currentPageQuestions = _getCurrentPageQuestions(questions);
//         final isLastPage = _currentPage >= totalPages - 1;
//
//         return Scaffold(
//           appBar: AppBar(
//             title: Text(
//               'Household Survey (Page ${_currentPage + 1}/$totalPages)',
//               style: GoogleFonts.poppins(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 16,
//               ),
//             ),
//             backgroundColor: const Color(0xFF006A4E),
//             elevation: 0,
//           ),
//           body: SafeArea(
//             child: Column(
//               children: [
//                 LinearProgressIndicator(
//                   value: _totalPages > 0
//                       ? (_currentPage + 1) / _totalPages
//                       : 0,
//                   backgroundColor: Colors.grey[200],
//                   valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006A4E)),
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ...currentPageQuestions.map((question) => Padding(
//                           padding: const EdgeInsets.only(bottom: 24.0),
//                           child: _buildQuestion(question, provider),
//                         )).toList(),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         spreadRadius: 1,
//                         blurRadius: 5,
//                         offset: const Offset(0, -2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       if (_currentPage > 0)
//                         ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               _currentPage--;
//                             });
//                             // Scroll to top when changing pages
//                             Future.delayed(Duration.zero, () {
//                               Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300));
//                             });
//                           },
//                           style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
//                           child: Text('Previous Page',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.black87,
//                                 fontWeight: FontWeight.w500,
//                               )),
//                         )
//                       else
//                         const SizedBox(width: 100),
//                       ElevatedButton(
//                         onPressed: () {
//                           if (!isLastPage) {
//                             setState(() {
//                               _currentPage++;
//                             });
//                             // Scroll to top when changing pages
//                             Future.delayed(Duration.zero, () {
//                               Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300));
//                             });
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Survey completed!')),
//                             );
//                             // You can add navigation or other actions here
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF006A4E),
//                         ),
//                         child: Text(
//                           isLastPage ? 'Finish Survey' : 'Next Page',
//                           style: GoogleFonts.poppins(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
