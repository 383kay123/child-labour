import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyflow/home/home.dart';
import 'package:surveyflow/pages/house-hold/house_hold_survey_provider.dart';
// import 'package:surveyflow/pages/survey_form_page.dart';
import 'package:surveyflow/providers/survey_provider.dart';
import 'package:surveyflow/screens/splash_screen.dart';
import 'package:surveyflow/screens/survey_home_screen.dart';
import 'package:surveyflow/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Surveyflow());
}

class Surveyflow extends StatelessWidget {
  const Surveyflow({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SurveyProvider()),
        ChangeNotifierProvider(create: (_) => HouseHoldSurveyProvider()),
      ],
      child: MaterialApp(
        title: 'ChildSafe',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          primaryTextTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).primaryTextTheme),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const Homepage(),
        },
      ),
    );
  }
}
