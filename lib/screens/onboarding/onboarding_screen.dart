import 'package:flutter/material.dart';
import 'package:SunuTask/core/constants/app_colors.dart';
import 'package:SunuTask/core/constants/app_strings.dart';
import 'package:SunuTask/screens/auth/login_screen.dart';
import 'package:SunuTask/services/storage_service.dart';

class SimpleOnboardingScreen extends StatefulWidget {
  const SimpleOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<SimpleOnboardingScreen> createState() => _SimpleOnboardingScreenState();
}

class _SimpleOnboardingScreenState extends State<SimpleOnboardingScreen> {
  late PageController pageController;
  int pageIndex = 0;

  final List<List<String>> onboardingPages = [
    [AppStrings.onboardingTitle1, AppStrings.onboardingDesc1],
    [AppStrings.onboardingTitle2, AppStrings.onboardingDesc2],
    [AppStrings.onboardingTitle3, AppStrings.onboardingDesc3],
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// ← MODIFIÉ : marque l'onboarding et va au LoginScreen
  Future<void> _onGetStarted() async {
    await StorageService.instance.setOnboardingComplete();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Expanded(
          child: PageView(
            controller: pageController,
            onPageChanged: (index) => setState(() => pageIndex = index),
            children: onboardingPages.map((page) => buildPage(title: page[0], description: page[1])).toList(),
          ),
        ),

        // Indicateurs de page
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(onboardingPages.length, (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: pageIndex == i ? 16 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: pageIndex == i ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(20),
            ),
          )),
        ),
        const SizedBox(height: 24),

        // Bouton Suivant / Commencer
        Padding(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton(
            onPressed: () {
              if (pageIndex < onboardingPages.length - 1) {
                pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
              } else {
                _onGetStarted(); // ← va au LoginScreen
              }
            },
            child: Text(pageIndex == onboardingPages.length - 1 ? AppStrings.getStarted : AppStrings.next),
          ),
        ),
      ]),
    );
  }

  Widget buildPage({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 14),
          Text(description, style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}
