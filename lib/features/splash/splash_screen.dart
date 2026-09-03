import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../onboarding/onboarding_screen.dart';
import 'widgets/signal_lock_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _lockController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final AnimationController _sweepController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();
  late final Animation<double> _lockProgress = CurvedAnimation(
    parent: _lockController,
    curve: Curves.easeOutCubic,
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _lockController,
    curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _lockController.forward();
    _lockController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _sweepController.stop();
        Future.delayed(const Duration(milliseconds: 500), _proceed);
      }
    });
  }

  void _proceed() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const OnboardingScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lockController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_lockController, _sweepController]),
                builder: (context, _) => SignalLockLogo(
                  progress: _lockProgress.value,
                  sweepAngle: _sweepController.value * 6.28319,
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    Text(
                      'RECKON',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            letterSpacing: 6,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NEVER LOSES THE THREAD',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            letterSpacing: 3,
                            color: AppColors.gps,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
