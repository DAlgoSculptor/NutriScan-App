import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

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
  late AnimationController _particlesController;
  late AnimationController _glowController;
  
  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _particlesAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _backgroundColorAnimation;

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
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Individual controllers with safe bounds
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2500),
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

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Safe animations with clamped values
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOutQuart)
    );

    _backgroundColorAnimation = ColorTween(
      begin: AppTheme.primaryGreen,
      end: Colors.teal.shade600,
    ).animate(_backgroundController);

    // Simplified logo scale animation to avoid TweenSequence issues
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut)
    );

    _logoRotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut)
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn)
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.bounceOut));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutBack));

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn)
    );

    _particlesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particlesController, curve: Curves.easeInOut)
    );

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut)
    );
  }

  void _startAnimationSequence() async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Start background animation immediately
    _backgroundController.forward();
    _particlesController.repeat();
    _glowController.repeat(reverse: true);

    // Staggered animations
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _showSecondaryText = true);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _showLoadingDots = true);

    await Future.delayed(const Duration(milliseconds: 2000));
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
    _particlesController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundController,
        _logoController,
        _textController,
        _particlesController,
        _glowController,
      ]),
      builder: (context, child) {
        return AnimatedSplashScreen(
          splash: _buildSplashContent(),
          backgroundColor: Colors.black,
          nextScreen: widget.nextScreen,
          splashIconSize: MediaQuery.of(context).size.height * 0.9,
          duration: 4000,
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
          _buildFloatingParticles(screenSize),
          _buildMainContent(screenSize),
          _buildTopGradientOverlay(),
          _buildBottomGradientOverlay(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size screenSize) {
    return AnimatedBuilder(
      animation: _backgroundColorAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0 + (_backgroundAnimation.value * 0.5),
              colors: [
                (_backgroundColorAnimation.value ?? AppTheme.primaryGreen).withOpacity(0.9),
                AppTheme.primaryGreen.withOpacity(0.7),
                Colors.teal.shade400.withOpacity(0.8),
                Colors.black,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: CustomPaint(
            size: screenSize,
            painter: NeuralNetworkPainter(_backgroundAnimation.value),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles(Size screenSize) {
    return Positioned.fill(
      child: CustomPaint(
        size: screenSize,
        painter: AdvancedParticlesPainter(
          _particlesAnimation.value,
          _glowAnimation.value,
        ),
      ),
    );
  }

  Widget _buildMainContent(Size screenSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHolographicLogo(screenSize),
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

  Widget _buildHolographicLogo(Size screenSize) {
    return SlideTransition(
      position: _logoSlideAnimation,
      child: FadeTransition(
        opacity: _logoOpacityAnimation,
        child: Transform.scale(
          scale: _logoScaleAnimation.value * _glowAnimation.value.clamp(0.8, 1.2),
          child: Transform.rotate(
            angle: _logoRotationAnimation.value * math.pi,
            child: Container(
              width: screenSize.width * 0.5,
              height: screenSize.width * 0.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Multiple glow layers
                  ...List.generate(3, (index) => _buildGlowLayer(index, screenSize)),
                  // Main logo container
                  _buildMainLogoContainer(screenSize),
                  // Holographic overlay
                  _buildHolographicOverlay(screenSize),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowLayer(int index, Size screenSize) {
    final size = 160.0 + (index * 15);
    final opacity = (0.15 - index * 0.03) * _glowAnimation.value.clamp(0.0, 1.0);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(opacity),
            blurRadius: 20.0 + (index * 8),
            spreadRadius: 5.0 + (index * 3),
          ),
        ],
      ),
    );
  }

  Widget _buildMainLogoContainer(Size screenSize) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Colors.white,
            Color(0xFFF8F8F8),
            Color(0xFFE8E8E8),
          ],
        ),
        border: Border.all(
          color: Colors.cyan.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 3,
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
                return Icon(
                  Icons.eco_rounded,
                  size: 80,
                  color: AppTheme.primaryGreen,
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
                    color: Colors.green.withOpacity(0.3),
                    size: 100,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolographicOverlay(Size screenSize) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyan.withOpacity(0.1 * _backgroundAnimation.value),
            Colors.transparent,
            Colors.blue.withOpacity(0.05 * _backgroundAnimation.value),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFF80E8FF),
                  Colors.white,
                ],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: const Text(
                'NutriScan',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.5,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 3),
                      blurRadius: 10,
                      color: Colors.cyan,
                    ),
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 6,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              height: 2,
              width: 180 * _textFadeAnimation.value,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.cyan,
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle() {
    return AnimatedOpacity(
      opacity: _showSecondaryText ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.cyan.withOpacity(0.05),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.cyan.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Scan. Analyze. Eat Smart.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'AI-Powered Nutrition Intelligence',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.8),
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
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                strokeWidth: 3,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: _particlesController,
          builder: (context, child) {
            String dots = '.' * ((_particlesController.value * 3).floor() + 1);
            return Text(
              'Initializing AI systems$dots',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                fontWeight: FontWeight.w400,
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
      height: 80,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
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
      height: 120,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// Simplified particle system painter
class AdvancedParticlesPainter extends CustomPainter {
  final double animationValue;
  final double glowValue;

  AdvancedParticlesPainter(this.animationValue, this.glowValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.0 + random.nextDouble() * 2.0;
      final opacity = (0.2 + random.nextDouble() * 0.3) * animationValue;
      
      final paint = Paint()
        ..color = [Colors.cyan, Colors.white, Colors.blue.shade200][i % 3]
            .withOpacity(opacity * glowValue.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Simplified neural network background painter
class NeuralNetworkPainter extends CustomPainter {
  final double animationValue;

  NeuralNetworkPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.08 * animationValue)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final random = math.Random(123);
    final points = <Offset>[];
    
    // Generate connection points
    for (int i = 0; i < 20; i++) {
      points.add(Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ));
    }

    // Draw connections
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final distance = (points[i] - points[j]).distance;
        if (distance < 150) {
          final opacity = (1 - distance / 150) * animationValue * 0.2;
          paint.color = Colors.cyan.withOpacity(opacity.clamp(0.0, 1.0));
          canvas.drawLine(points[i], points[j], paint);
        }
      }
    }

    // Draw nodes
    for (final point in points) {
      final nodePaint = Paint()
        ..color = Colors.cyan.withOpacity(0.3 * animationValue)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 1.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}