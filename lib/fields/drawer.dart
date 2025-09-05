import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyflow/pages/Consent.dart';
import 'package:surveyflow/pages/cover.dart';
import 'package:surveyflow/pages/endcollection.dart';
import 'package:surveyflow/pages/farmerident.dart';
import 'package:surveyflow/pages/remediation.dart';
import 'package:surveyflow/pages/sensitization.dart';

class CustomDrawer extends StatelessWidget {
  final String currentPage;

  const CustomDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    TextStyle drawerTextStyle(String page) {
      return GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: currentPage == page ? Color(0xFF00754B) : Colors.black,
      );
    }

    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: DrawerHeader(
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
          ),
          ListTile(
            title: Text('COVER', style: drawerTextStyle('COVER')),
            tileColor: currentPage == 'COVER' ? Colors.grey[300] : null,
            onTap: () {
              if (currentPage != 'COVER') {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Questionnaire()));
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            title:
                Text('CONSENT AND LOCATION', style: drawerTextStyle('CONSENT')),
            tileColor:
                currentPage == 'CONSENT AND LOCATION' ? Colors.grey[300] : null,
            onTap: () {
              if (currentPage != 'CONSENT') {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Consent(
                              survey: {},
                            )));
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            title:
                Text('FARMER IDENTIFICATION', style: drawerTextStyle('IDENT')),
            tileColor: currentPage == 'FARMER IDENTIFICATION'
                ? Colors.grey[300]
                : null,
            onTap: () {
              if (currentPage != 'IDENT') {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Farmerident()));
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            title: Text('REMEDIATION', style: drawerTextStyle('REMEDIATION')),
            tileColor: currentPage == 'REMEDIATION' ? Colors.grey[300] : null,
            onTap: () {
              if (currentPage != 'REMEDIATION') {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Remediation()));
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            title:
                Text('SENSITIZATION', style: drawerTextStyle('SENSITIZATION')),
            tileColor: currentPage == 'SENSITIZATION' ? Colors.grey[300] : null,
            onTap: () {
              if (currentPage != 'SENSITIZATION') {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Sensitization()));
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            title: Text('END OF COLLECTION', style: drawerTextStyle('END')),
            tileColor:
                currentPage == 'END OF COLLECTION' ? Colors.grey[300] : null,
            onTap: () {
              if (currentPage != 'END') {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Endcollection()));
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
