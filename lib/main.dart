import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyflow/view/pages/house-hold/house_hold_survey_provider.dart';
import 'package:surveyflow/view/screen_wrapper/screen_wrapper.dart';
import 'package:surveyflow/view/splash/splash_screen.dart';
import 'package:surveyflow/view/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Surveyflow());
}

class Surveyflow extends StatelessWidget {
  const Surveyflow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => SurveyProvider()),
        ChangeNotifierProvider(create: (_) => HouseHoldSurveyProvider()),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor:  Color(0xFF1B5E20).withOpacity(0.9),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF1B5E20).withOpacity(0.8),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: MaterialApp(
          title: 'Human Rights Monitoring',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme.copyWith(
            textTheme: GoogleFonts.comicNeueTextTheme(Theme.of(context).textTheme),
            primaryTextTheme:
                GoogleFonts.comicNeueTextTheme(Theme.of(context).primaryTextTheme),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => const ScreenWrapper(),
          },
        ),
      ),
    );
  }
}
