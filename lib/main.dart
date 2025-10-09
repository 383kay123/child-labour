import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_rights_monitor/view/pages/house-hold/house_hold_survey_provider.dart';
import 'package:human_rights_monitor/view/screen_wrapper/screen_wrapper.dart';
import 'package:human_rights_monitor/view/splash/splash_screen.dart';
import 'package:human_rights_monitor/view/theme/app_theme.dart';
import 'package:provider/provider.dart';
//

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations if needed
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const Surveyflow());
}

class Surveyflow extends StatelessWidget {
  const Surveyflow({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HouseHoldSurveyProvider()),
      ],
      child: MaterialApp(
        title: 'Human Rights Monitoring',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/home': (context) => const ScreenWrapper(),
        },
        onGenerateRoute: (settings) {
          // Handle unknown routes by going to splash
          return MaterialPageRoute(
            builder: (context) => const SplashScreen(),
          );
        },
        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
