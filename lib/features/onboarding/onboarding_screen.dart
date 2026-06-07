import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../providers/settings_providers.dart';

/// Onboarding introduction walkthrough carousel.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlideData> _slides = [
    const _OnboardingSlideData(
      title: 'Plan with Precision',
      description: 'Manage your daily tasks, set priorities, and keep track of tags in a gorgeous local-first database.',
      icon: Icons.check_circle_outline,
      gradient: [Color(0xFF6366F1), Color(0xFF4F46E5)], // Indigo
    ),
    const _OnboardingSlideData(
      title: 'Own Your Schedule',
      description: 'Schedule timeline entries and customize precise notification reminders so you never miss a standup or routine jog.',
      icon: Icons.calendar_today_outlined,
      gradient: [Color(0xFFEC4899), Color(0xFFDB2777)], // Pink
    ),
    const _OnboardingSlideData(
      title: 'Understand Spending',
      description: 'Log daily expenses, visualize category pie charts, scan receipts, and analyze month-over-month trends offline.',
      icon: Icons.payments_outlined,
      gradient: [Color(0xFF10B981), Color(0xFF059669)], // Emerald
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _slides[_currentPage].gradient[0].withValues(alpha: 0.12),
                    colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSizes.xl),
                    // Skip button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
                          context.go('/home');
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (page) => setState(() => _currentPage = page),
                        itemBuilder: (context, index) {
                          final slide = _slides[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Glassmorphic / Gradient Icon container
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: slide.gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: slide.gradient[1].withValues(alpha: 0.4),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  slide.icon,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ).animate(key: ValueKey('icon_$index')).scale(
                                    duration: 400.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                              const SizedBox(height: AppSizes.xl),
                              Text(
                                slide.title,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                textAlign: TextAlign.center,
                              ).animate(key: ValueKey('title_$index')).fadeIn(delay: 100.ms).slideY(
                                    begin: 0.2,
                                    end: 0,
                                    duration: 300.ms,
                                  ),
                              const SizedBox(height: AppSizes.md),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                                child: Text(
                                  slide.description,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        height: 1.5,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ).animate(key: ValueKey('desc_$index')).fadeIn(delay: 200.ms).slideY(
                                    begin: 0.2,
                                    end: 0,
                                    duration: 300.ms,
                                  ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Indicator and Next Button Row
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.xl),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Indicators
                          Row(
                            children: List.generate(_slides.length, (index) {
                              final active = index == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: active
                                      ? _slides[_currentPage].gradient[1]
                                      : colorScheme.outlineVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          // Next / Complete Button
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _slides[_currentPage].gradient[1],
                              minimumSize: const Size(130, 50),
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: _onNext,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
}
