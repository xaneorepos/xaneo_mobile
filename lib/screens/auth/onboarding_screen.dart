import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../styles/app_styles.dart';
import 'login_screen.dart';
import 'package:xaneo/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;

  late final List<Map<String, String>> _steps = [
    {
      'title': (AppLocalizations.of(context)?.dobroPozhalovatVXaneo_66d0 ??
          'Fallback'),
      'description': (AppLocalizations.of(context)?.xaneoTeperIVMobilnom_e918 ??
          'Fallback'),
      'image': 'assets/images/medved.png',
      'button':
          (AppLocalizations.of(context)?.mneUzheInteresno_5365 ?? 'Fallback'),
    },
    {
      'title': (AppLocalizations.of(context)?.vseVashiDannyePodZaschitoy_b7d9 ??
          'Fallback'),
      'description': (AppLocalizations.of(context)
              ?.vseSoobscheniyaZaschischenySkvoznymShifrovaniem_443e ??
          'Fallback'),
      'image': 'assets/images/medvedprivate.png',
      'button': (AppLocalizations.of(context)?.prodolzhit_e9c3 ?? 'Fallback'),
    },
    {
      'title': (AppLocalizations.of(context)?.lokalnyeDataTsentry_f089 ??
          'Fallback'),
      'description':
          (AppLocalizations.of(context)?.vashiDannyeNikogdaNePokidayut_f871 ??
              'Fallback'),
      'image': 'assets/images/medved_database.png',
      'button': (AppLocalizations.of(context)?.zavershit_b0e3 ?? 'Fallback'),
    },
  ];

  void _nextStep() async {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: AppStyles.animationMedium,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            children: [
              // Progress indicator
              Row(
                children: List.generate(_steps.length, (index) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : AppStyles.animationFast,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: _currentStep >= index
                            ? context.xaneoTextPrimary
                            : context.xaneoDivider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(flex: 1),

              // Animated Content
              Expanded(
                flex: 6,
                child: AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AppStyles.animationMedium,
                  child: Column(
                    key: ValueKey<int>(_currentStep),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        step['image']!,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 48),
                      Text(
                        step['title']!,
                        style: AppStyles.titleLarge.copyWith(
                          color: context.xaneoTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step['description']!,
                        style: AppStyles.bodyMuted.copyWith(
                          color: context.xaneoTextMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.xaneoTextPrimary,
                    foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    step['button']!,
                    style: AppStyles.buttonText.copyWith(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
