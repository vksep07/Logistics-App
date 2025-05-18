import 'package:flutter/material.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/theme/spacing.dart';
import 'package:logistics_demo/features/auth/screens/login_screen.dart';
import 'package:logistics_demo/features/dashboard/screens/main_screen.dart';
import 'package:logistics_demo/services/auth_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:logistics_demo/constants/image_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkLoginStatus();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final isLoggedIn = await _authService.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                isLoggedIn ? const DashboardScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive sizes
          final isWeb = constraints.maxWidth > 600;
          final logoSize =
              isWeb ? Spacing.space200 : constraints.maxWidth * 0.5;
          final fontSize = isWeb ? Spacing.space32 : Spacing.space24;

          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo with constrained size
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SizedBox(
                            width: logoSize,
                            height: logoSize,
                            child: Image.asset(
                              ImageConstants.logoPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isWeb ? Spacing.space48 : Spacing.space24),
                  // Animated App Name with responsive font size
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          FadeAnimatedText(
                            AppLocalizations.of(context)!.appSlogan,
                            duration: const Duration(seconds: 2),
                            fadeOutBegin: 0.9,
                            fadeInEnd: 0.1,
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    ),
                  ),
                  SizedBox(height: isWeb ? Spacing.space64 : Spacing.space48),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
