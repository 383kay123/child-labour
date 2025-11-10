import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/controller/db/household_db_helper.dart';

import 'package:human_rights_monitor/view/screen_wrapper/screen_wrapper.dart';
import 'package:human_rights_monitor/view/splash/splash_screen.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'package:human_rights_monitor/controller/db/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear all persisted data on app start to prevent selections from persisting across restarts
  try {
    await HouseholdDBHelper.instance.clearAllSurveyData();
  } catch (e) {
    debugPrint('Error clearing database on startup: $e');
  }

  runApp(const HumanRightsMonitor());
}

class HumanRightsMonitor extends StatelessWidget {
  const HumanRightsMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
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
          // '/home': (context) => const ScreenWrapper(),
        },
      ),
    );
  }
}
