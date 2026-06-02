// lib/widgets/onboarding_tour.dart
//
// First-launch overlay that introduces the four big features
// (keypad, history, function pickers, analysis hub) as a paged
// stack of cards. Skippable from any page; the user's choice is
// persisted on AppState so the tour only runs once.

import 'package:flutter/material.dart';

import '../engine/app_state.dart';
import '../localization/app_localizations.dart';

class OnboardingTour extends StatefulWidget {
  const OnboardingTour({super.key});

  /// Show the tour as a full-screen modal dialog. Marks
  /// [AppState.onboardingDismissed] = true on close so the caller
  /// doesn't have to remember.
  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const OnboardingTour(),
    );
    AppState().setOnboardingDismissed(true);
  }

  @override
  State<OnboardingTour> createState() => _OnboardingTourState();
}

class _OnboardingTourState extends State<OnboardingTour> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final pages = <_TourCard>[
      _TourCard(
        icon: Icons.calculate,
        title: t.onboardingKeypadTitle,
        body: t.onboardingKeypadBody,
      ),
      _TourCard(
        icon: Icons.description,
        title: t.onboardingNotepadTitle,
        body: t.onboardingNotepadBody,
      ),
      _TourCard(
        icon: Icons.history,
        title: t.onboardingHistoryTitle,
        body: t.onboardingHistoryBody,
      ),
      _TourCard(
        icon: Icons.functions,
        title: t.onboardingFunctionsTitle,
        body: t.onboardingFunctionsBody,
      ),
      _TourCard(
        icon: Icons.donut_large,
        title: t.onboardingAnalysisTitle,
        body: t.onboardingAnalysisBody,
      ),
    ];

    final isLast = _page == pages.length - 1;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [for (final p in pages) p],
              ),
            ),
            // Page-dots indicator.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < pages.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: i == _page ? 10 : 6,
                        height: i == _page ? 10 : 6,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? scheme.primary
                              : scheme.onSurface.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.onboardingSkip),
                  ),
                  const Spacer(),
                  Text(t.onboardingPage(_page + 1, pages.length),
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      )),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      if (isLast) {
                        Navigator.of(context).pop();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Text(isLast ? t.onboardingDone : t.onboardingNext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _TourCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 56, color: scheme.primary),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.4,
                  color: scheme.onSurface.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }
}
