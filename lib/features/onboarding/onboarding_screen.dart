import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';

class _OnboardPage {
  const _OnboardPage({required this.title, required this.body, required this.accent});
  final String title;
  final String body;
  final Color accent;
}

const _pages = [
  _OnboardPage(
    title: 'GPS drops.\nYour position shouldn’t.',
    body: 'Tunnels, parking structures, dense city streets — GPS fails constantly. '
        'Reckon keeps tracking anyway.',
    accent: AppColors.gps,
  ),
  _OnboardPage(
    title: 'Your phone already\nhas what it needs.',
    body: 'An on-device model reads the accelerometer and gyroscope you already carry, '
        'trained to reconstruct real motion — not just integrate noisy drift.',
    accent: AppColors.sensorOnly,
  ),
  _OnboardPage(
    title: 'No visible seam\nwhen GPS returns.',
    body: 'Reckon blends sensor-only estimates back onto GPS smoothly. '
        'You should never be able to tell which mode is active.',
    accent: AppColors.fusion,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index == _pages.length - 1) {
      _enter();
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
  }

  void _enter() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => FadeTransition(opacity: animation, child: const HomeScreen()),
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
    final page = _pages[_index];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _enter,
                    child: const Text('Skip'),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _OnboardPageView(page: _pages[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? page.accent : AppColors.hairline,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(backgroundColor: page.accent),
                        child: Text(_index == _pages.length - 1 ? 'Get started' : 'Next'),
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

class _OnboardPageView extends StatelessWidget {
  const _OnboardPageView({required this.page});
  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: page.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: page.accent.withValues(alpha: 0.5)),
            ),
            child: Icon(Icons.podcasts_rounded, color: page.accent),
          ),
          const SizedBox(height: 32),
          Text(page.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(page.body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
