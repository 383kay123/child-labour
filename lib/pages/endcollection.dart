import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/fields/gpsfield.dart';
import 'package:surveyflow/fields/image_picker.dart';
import 'package:surveyflow/fields/datepickerfield.dart';
import 'package:surveyflow/pages/Consent.dart';
import 'package:surveyflow/pages/cover.dart';
import 'package:surveyflow/pages/farmerident.dart';
import 'package:surveyflow/pages/remediation.dart';
import 'package:surveyflow/pages/sensitization.dart';
import 'package:surveyflow/pages/success.dart';

class Endcollection extends StatelessWidget {
  const Endcollection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'END OF COLLECTION',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF006A4E),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync,
                color: Colors.white), // Change the icon here
            onPressed: () {
              // Add functionality here
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Fill out the survey',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Picture of the respondent'),
                  SizedBox(height: 10),
                  PictureField(),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Signature Producer'),
                  SizedBox(height: 10),
                  PictureField(),
                  const SizedBox(height: 10),
                  GPSField(question: 'Provide end GPS of survey'),
                  const SizedBox(height: 16),
                  DatePickerField(question: 'Provide end time of survey'),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF00754B)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'REVIEW GHA - CLMRS Household profiling - 24-25',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          _buildDrawerItem(context, 'COVER', const Questionnaire()),
          _buildDrawerItem(context, 'CONSENT AND LOCATION', const Consent()),
          _buildDrawerItem(context, 'FARMER IDENTIFICATION', Farmerident()),
          _buildDrawerItem(context, 'REMEDIATION', const Remediation()),
          _buildDrawerItem(context, 'SENSITIZATION', const Sensitization()),
          _buildDrawerItem(context, 'END OF COLLECTION', const Endcollection()),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, Widget page) {
    return ListTile(
      title:
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Sensitization()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00754B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text('PREV',
                style: GoogleFonts.inter(fontWeight: FontWeight.w400)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LoadingToSuccessScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00754B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text('SUBMIT',
                style: GoogleFonts.inter(fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}
