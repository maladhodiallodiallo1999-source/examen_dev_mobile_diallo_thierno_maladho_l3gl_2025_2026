import 'dart:async';
import 'package:flutter/material.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/core/constants/app_strings.dart';
import 'package:SunuTask/screens/auth/login_screen.dart';
import 'package:SunuTask/screens/onboarding/onboarding_screen.dart';
import 'package:SunuTask/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _showLogo = false;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showLogo = true);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showText = true);
    });
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 3), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // ← MODIFIÉ : on va vers LoginScreen si onboarding fait,
    // sinon vers OnboardingScreen
    final bool onboardingComplete = StorageService.instance.isOnboardingComplete;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => onboardingComplete
            ? const LoginScreen()
            : const SimpleOnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildLogo(),
          const SizedBox(height: 24),
          _buildAppName(),
          const SizedBox(height: 8),
          _buildAppSlogan(),
          const SizedBox(height: 48),
          _buildLoadingIndicator(),
        ]),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedOpacity(
      opacity: _showLogo ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      child: AnimatedScale(
        scale: _showLogo ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: Container(
          width: 124, height: 124,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(180), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Icon(Icons.task_alt, size: 65, color: AppColors.white.withAlpha(200)),
        ),
      ),
    );
  }

  Widget _buildAppName() => AnimatedOpacity(
    opacity: _showText ? 1 : 0,
    duration: const Duration(milliseconds: 500),
    child: const Text(AppStrings.appName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 1.2)),
  );

  Widget _buildAppSlogan() => AnimatedOpacity(
    opacity: _showText ? 1 : 0,
    duration: const Duration(milliseconds: 500),
    child: const Text(AppStrings.appSlogan, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
  );

  Widget _buildLoadingIndicator() => AnimatedOpacity(
    opacity: _showText ? 1 : 0,
    duration: const Duration(milliseconds: 500),
    child: const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 8.0, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
  );
}
