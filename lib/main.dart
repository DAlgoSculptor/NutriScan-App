import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/about_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/ingredient_database_service.dart';

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
  const NutriScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(nextScreen: MainNavigationScreen()),
      routes: {
        '/home': (context) => const MainNavigationScreen(),
        '/scan': (context) => const ScanScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  // Add a static reference to the state
  static _MainNavigationScreenState? _instance;

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();

  // Public method to change tabs from anywhere in the app
  static void changeTab(int index) {
    _instance?.onTabTapped(index);
  }
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScanScreen(),
    const AboutScreen(),
    // Removed ContactScreen from the list
  ];

  @override
  void initState() {
    super.initState();
    // Set the instance when the state is initialized
    MainNavigationScreen._instance = this;
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Clear the instance when the state is disposed
    MainNavigationScreen._instance = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // Disable scrolling between pages by setting physics to NeverScrollableScrollPhysics
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none, // Allow drawing outside bounds
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Regular navigation items (Home, About)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Home button (left)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTabTapped(0),
                        child: Container(
                          color: Colors.transparent,
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _currentIndex == 0 ? Icons.home_rounded : Icons.home_rounded,
                                color: _currentIndex == 0 
                                    ? AppTheme.primaryGreen 
                                    : AppTheme.mediumGray,
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Home',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _currentIndex == 0 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                  color: _currentIndex == 0 
                                      ? AppTheme.primaryGreen 
                                      : AppTheme.mediumGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Spacer for center position
                    const Expanded(child: SizedBox()),
                    
                    // About button (right)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTabTapped(2),
                        child: Container(
                          color: Colors.transparent,
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _currentIndex == 2 
                                    ? Icons.info_rounded 
                                    : Icons.info_outline_rounded,
                                color: _currentIndex == 2 
                                    ? AppTheme.primaryGreen 
                                    : AppTheme.mediumGray,
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'About',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _currentIndex == 2 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                  color: _currentIndex == 2 
                                      ? AppTheme.primaryGreen 
                                      : AppTheme.mediumGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Floating Scan button (without animations)
          Positioned(
            top: -25, // Lifted higher for floating effect
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTabTapped(1),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Public method to change tabs
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}