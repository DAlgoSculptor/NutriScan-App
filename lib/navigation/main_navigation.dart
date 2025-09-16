import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/about_screen.dart';
import '../theme/app_theme.dart';

/// A simple navigation service that provides tab navigation
/// functionality for the app
class MainNavigationScreen {
  final PageController _pageController;
  int _currentIndex;

  MainNavigationScreen(this._pageController, this._currentIndex);

  /// Gets the current instance of [MainNavigationScreen]
  static MainNavigationScreen of(BuildContext context) {
    final navigator = context.findAncestorStateOfType<_MainNavigationScreenState>();
    if (navigator == null) {
      throw FlutterError('MainNavigationScreen.of() called with a context that does not contain a MainNavigationScreen widget.');
    }
    return navigator._mainNavigationScreen;
  }

  /// Changes to the specified tab index
  void changeTab(int index) {
    _currentIndex = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

/// A stateful widget that provides the main navigation for the app
class MainNavigation extends StatefulWidget {
  final int initialTab;

  const MainNavigation({
    super.key,
    this.initialTab = 0,
  });

  static _MainNavigationScreenState of(BuildContext context) {
    final _MainNavigationScreenState? navigator = context.findAncestorStateOfType<_MainNavigationScreenState>();
    if (navigator == null) {
      throw FlutterError('MainNavigation.of() called with a context that does not contain a MainNavigation widget.');
    }
    return navigator;
  }

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigation> {
  late PageController _pageController;
  late int _currentIndex;
  late MainNavigationScreen _mainNavigationScreen;
  final List<Widget> _screens = [
    const HomeScreen(),
    const ScanScreen(),
    const AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pageController = PageController(initialPage: _currentIndex);
    _mainNavigationScreen = MainNavigationScreen(_pageController, _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // Disable scrolling between pages
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return Stack(
      clipBehavior: Clip.none, // Allow drawing outside bounds
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Home button (left)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _mainNavigationScreen.changeTab(0),
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
                                fontWeight: FontWeight.w600,
                                color: AppTheme.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Spacer for center position - made it responsive
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width > 400 ? 80 : 40,
                    ),
                  ),
                  
                  // About button (right)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _mainNavigationScreen.changeTab(2),
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
                                fontWeight: FontWeight.w600,
                                color: AppTheme.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        
        // Floating Scan button (without animations)
        Positioned(
          top: -25, // Lifted higher for floating effect
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => _mainNavigationScreen.changeTab(1),
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
    );
  }
}