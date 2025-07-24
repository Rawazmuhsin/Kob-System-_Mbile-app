import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'routes/app_routes.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const KOBApp());

class KOBApp extends StatelessWidget {
  const KOBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto',
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: lightTextTheme,
      ),
      darkTheme: ThemeData(
        fontFamily: '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto',
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: darkTextTheme,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.splash,
    );
  }
}
