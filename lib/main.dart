import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:human_rights_monitor/view/splash/splash_screen.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    debugPrint('Caught error: ${details.exception}');
  };

  // REMOVED: Automatic database clearing on startup
  // This was causing all your data to be deleted every time the app restarts
  
  // Optional: Only for specific debugging scenarios
  // Uncomment and use manually when needed for testing
  /*
  if (kDebugMode && false) { // Set to true only when you want to clear data
    try {
      debugPrint('🔄 Manually clearing database for testing...');
      await HouseholdDBHelper.instance.clearAllSurveyData();
    } catch (e) {
      debugPrint('Error clearing database: $e');
    }
  }
  */

  runApp(const HumanRightsMonitor());
}

class HumanRightsMonitor extends StatelessWidget {
  const HumanRightsMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Human Rights Monitoring',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      defaultTransition: Transition.fadeIn,
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