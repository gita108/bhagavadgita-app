import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../ui/widgets/om_logo.dart';
import '../../ui/widgets/page_dots.dart';
import '../contents/contents_screen.dart';

class _Page {
  const _Page(this.asset, this.title, this.body);
  final String asset;
  final String title;
  final String body;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = <_Page>[
    _Page(
      'assets/icons/icn_guide_1.png',
      'Welcome to the Bhagavad Gita',
      'Ancient wisdom for modern life. 700 verses of spiritual guidance, '
          'in Sanskrit with translations.',
    ),
    _Page(
      'assets/icons/icn_guide_2.png',
      'Easy Reading',
      'Browse 18 chapters with 700+ verses. Swipe between slokas, bookmark '
          'favorites, and add personal notes.',
    ),
    _Page(
      'assets/icons/icn_guide_3.png',
      'Listen & Learn',
      'Play Sanskrit pronunciation and translation audio. Customize display '
          'settings to focus on what matters to you.',
    ),
  ];

  void _toContents() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const ContentsScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    final isFirst = _index == 0;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OmLogo(size: 80, dark: i == 0),
                          const SizedBox(height: 28),
                          Image.asset(p.asset,
                              width: 96, height: 96, fit: BoxFit.contain),
                          const SizedBox(height: 28),
                          Text(p.title,
                              textAlign: TextAlign.center,
                              style: AppText.guideTitle()),
                          const SizedBox(height: 14),
                          Text(p.body,
                              textAlign: TextAlign.center,
                              style: AppText.guideText()),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: isFirst
                              ? _toContents
                              : () => _controller.previousPage(
                                    duration:
                                        const Duration(milliseconds: 280),
                                    curve: Curves.easeOut,
                                  ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.white,
                          ),
                          child: Text(isFirst ? 'Skip' : '‹ Back'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.red1,
                          ),
                          onPressed: isLast
                              ? _toContents
                              : () => _controller.nextPage(
                                    duration:
                                        const Duration(milliseconds: 280),
                                    curve: Curves.easeOut,
                                  ),
                          child: Text(isLast ? 'Done' : 'Next ›'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    PageDots(count: _pages.length, index: _index),
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
