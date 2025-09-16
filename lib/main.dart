import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/about_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/ingredient_database_service.dart';
import 'navigation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the harmful ingredients database
  try {
    await IngredientDatabaseService.loadDatabase();
  } catch (e) {
    debugPrint('Failed to load ingredient database: $e');
  }
  
  runApp(const NutriScanApp());
}

class NutriScanApp extends StatelessWidget {
  const NutriScanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        nextScreen: MainNavigation(initialTab: 0),
      ),
    );
  }
}


