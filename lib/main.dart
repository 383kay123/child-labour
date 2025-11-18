import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/view/screen_wrapper/screen_wrapper.dart';
import 'package:human_rights_monitor/view/splash/splash_screen.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    debugPrint('Caught error: ${details.exception}');
  };

  // Only clear data in debug mode for development
  if (kDebugMode) {
    try {
      await HouseholdDBHelper.instance.clearAllSurveyData();
    } catch (e) {
      debugPrint('Error clearing database on startup: $e');
    }
  }

  runApp(const HumanRightsMonitor());
}

class HumanRightsMonitor extends StatelessWidget {
  const HumanRightsMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Human Rights Monitoring',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFF1B5E20),
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF1B5E20),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
