import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/view/pages/house-hold/house_hold_survey_provider.dart';
import 'package:human_rights_monitor/view/screen_wrapper/screen_wrapper.dart';
import 'package:human_rights_monitor/view/splash/splash_screen.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HumanRightsMonitor());
}

class HumanRightsMonitor extends StatelessWidget {
  const HumanRightsMonitor({super.key});

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
          statusBarColor: Color(0xFF1B5E20).withOpacity(0.9),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF1B5E20).withOpacity(0.8),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: MaterialApp(
          title: 'Human Rights Monitoring',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
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
