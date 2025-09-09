import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../theme/constants.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _masterController;
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _scannerController;
  late AnimationController _molecularController;
  late AnimationController _ingredientController;
  late AnimationController _healthController;
  
  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _scannerAnimation;
  late Animation<double> _molecularAnimation;
  late Animation<double> _ingredientAnimation;
  late Animation<double> _healthPulseAnimation;

  // State variables
  bool _showSecondaryText = false;
  bool _showLoadingDots = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Master controller for overall timing
    _masterController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    // Individual controllers with safe bounds
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _scannerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _molecularController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _ingredientController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _healthController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Safe animations with clamped values
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut)
    );

    // Logo scale animation with bounce effect
    _logoScaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_logoController);

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn)
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutBack));

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn)
    );

    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut)
    );

    _molecularAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _molecularController, curve: Curves.easeInOut)
    );

    _ingredientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ingredientController, curve: Curves.easeInOut)
    );
    
    _healthPulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _healthController, curve: Curves.easeInOut)
    );
  }

  void _startAnimationSequence() async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Start background animation immediately
    _backgroundController.forward();
    _healthController.repeat(reverse: true);

    // Staggered animations representing the scanning process
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _scannerController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _molecularController.forward();

    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) _ingredientController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) _textController.forward();

    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) setState(() => _showSecondaryText = true);

    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) setState(() => _showLoadingDots = true);

    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      HapticFeedback.mediumImpact();
      _masterController.forward();
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _backgroundController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _scannerController.dispose();
    _molecularController.dispose();
    _ingredientController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundController,
        _logoController,
        _textController,
        _scannerController,
        _molecularController,
        _ingredientController,
        _healthController,
      ]),
      builder: (context, child) {
        return AnimatedSplashScreen(
          splash: _buildSplashContent(),
          backgroundColor: Colors.black,
          nextScreen: widget.nextScreen,
          splashIconSize: MediaQuery.of(context).size.height * 0.9,
          duration: 5000,
          splashTransition: SplashTransition.fadeTransition,
          pageTransitionType: PageTransitionType.fade,
          animationDuration: const Duration(milliseconds: 1000),
        );
      },
    );
  }

  Widget _buildSplashContent() {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          _buildAnimatedBackground(screenSize),
          _buildScanningVisualization(screenSize),
          _buildMolecularStructure(screenSize),
          _buildIngredientDetection(screenSize),
          _buildMainContent(screenSize),
          _buildTopGradientOverlay(),
          _buildBottomGradientOverlay(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size screenSize) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryGreen.withOpacity(0.95 * _backgroundAnimation.value),
                AppTheme.lightGreen.withOpacity(0.85 * _backgroundAnimation.value),
                AppTheme.accentGreen.withOpacity(0.75 * _backgroundAnimation.value),
                Colors.black,
              ],
              stops: const [0.0, 0.4, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanningVisualization(Size screenSize) {
    return AnimatedBuilder(
      animation: _scannerAnimation,
      builder: (context, child) {
        return Positioned(
          top: screenSize.height * 0.15,
          left: screenSize.width * 0.1,
          right: screenSize.width * 0.1,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.lightGreen.withOpacity(0.8 * _scannerAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
            transform: Matrix4.translationValues(
              0.0,
              screenSize.height * 0.3 * _scannerAnimation.value,
              0.0,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMolecularStructure(Size screenSize) {
    return AnimatedBuilder(
      animation: _molecularAnimation,
      builder: (context, child) {
        return Positioned(
          top: screenSize.height * 0.2,
          left: screenSize.width * 0.5 - 60,
          child: Opacity(
            opacity: _molecularAnimation.value,
            child: CustomPaint(
              size: const Size(120, 120),
              painter: MolecularStructurePainter(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientDetection(Size screenSize) {
    return AnimatedBuilder(
      animation: _ingredientController,
      builder: (context, child) {
        return Positioned(
          top: screenSize.height * 0.35,
          left: screenSize.width * 0.5 - 100,
          right: screenSize.width * 0.5 - 100,
          child: Opacity(
            opacity: _ingredientController.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIngredientIcon(Icons.warning_amber_rounded, AppTheme.highRisk, "Tartrazine"),
                _buildIngredientIcon(Icons.info_outline, AppTheme.moderateRisk, "MSG"),
                _buildIngredientIcon(Icons.check_circle_outline, AppTheme.safeColor, "Vitamin C"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientIcon(IconData icon, Color color, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(Size screenSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAppLogo(screenSize),
          SizedBox(height: screenSize.height * 0.08),
          _buildAnimatedTitle(),
          SizedBox(height: screenSize.height * 0.03),
          _buildAnimatedSubtitle(),
          SizedBox(height: screenSize.height * 0.1),
          if (_showLoadingDots) _buildAdvancedLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildAppLogo(Size screenSize) {
    return SlideTransition(
      position: _logoSlideAnimation,
      child: FadeTransition(
        opacity: _logoOpacityAnimation,
        child: Transform.scale(
          scale: _logoScaleAnimation.value * _healthPulseAnimation.value,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: AppTheme.lightGreen.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // App icon
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 160,
                    height: 160,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 160,
                        height: 160,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  // Lottie animation overlay
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/splash_animation.json',
                      fit: BoxFit.cover,
                      repeat: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.scatter_plot_rounded,
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          size: 100,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFF80E8FF),
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2.5,
              shadows: [
                Shadow(
                  offset: Offset(0, 3),
                  blurRadius: 15,
                  color: Colors.lightGreen,
                ),
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 8,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle() {
    return AnimatedOpacity(
      opacity: _showSecondaryText ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppTheme.lightGreen.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: const Text(
              AppConstants.appTagline,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            AppConstants.appDescription,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 0.8,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedLoadingIndicator() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.lightGreen),
                strokeWidth: 4,
                backgroundColor: Colors.white.withOpacity(0.15),
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _ingredientController,
          builder: (context, child) {
            String dots = '.' * ((_ingredientController.value * 3).floor() + 1);
            return Text(
              'Analyzing ingredients$dots',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopGradientOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 100,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 150,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// Molecular structure painter representing food analysis
class MolecularStructurePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.7);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw central atom
    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4CAF50);

    canvas.drawCircle(center, 8, centerPaint);

    // Draw connected atoms
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      // Draw bond line
      canvas.drawLine(center, Offset(x, y), paint);
      
      // Draw atom
      final atomPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = i % 2 == 0 ? const Color(0xFF81C784) : const Color(0xFF8BC34A);
      
      canvas.drawCircle(Offset(x, y), 6, atomPaint);
    }

    // Draw rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(0.5);

    canvas.drawCircle(center, radius * 0.6, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}