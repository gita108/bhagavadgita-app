import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../ui/widgets/page_dots.dart';
import '../../data/local/app_database.dart';
import '../contents/contents_screen.dart';
import 'app_onboarding_controller.dart';

class _Page {
  const _Page({required this.asset, this.title, this.body, this.checklist});

  final String asset;
  final String? title;
  final String? body;
  final List<String>? checklist;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _toContents() {
    appOnboardingController.markShown();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ContentsScreen(db: widget.db)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // 3 pages, matching legacy exactly: page 1 & 2 are icon + uppercase bold
    // title + body paragraph; page 3 drops the title in favor of a 5-row
    // checklist (icon + text per row).
    final pages = <_Page>[
      _Page(
        asset: 'assets/icons/icn_guide_1.png',
        title: l10n.guideTitle1,
        body: l10n.guideText1,
      ),
      _Page(
        asset: 'assets/icons/icn_guide_2.png',
        title: l10n.guideTitle2,
        body: l10n.guideText2,
      ),
      _Page(
        asset: 'assets/icons/icn_guide_3.png',
        checklist: [
          l10n.guideChecklist1,
          l10n.guideChecklist2,
          l10n.guideChecklist3,
          l10n.guideChecklist4,
          l10n.guideChecklist5,
        ],
      ),
    ];
    final isFirst = _index == 0;
    final isLast = _index == pages.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _OnboardingPage(page: pages[i]),
              ),
              // "Skip" — always visible, top-right; the only way to finish
              // onboarding once on the last page, since "Next" is hidden
              // there (matches legacy: no separate "Done" button).
              Positioned(
                top: 0,
                right: 0,
                child: TextButton(
                  onPressed: _toContents,
                  style: TextButton.styleFrom(foregroundColor: AppColors.white),
                  child: Text(l10n.guideSkip),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PageDots(count: pages.length, index: _index),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!isFirst)
                          TextButton(
                            onPressed: () => _controller.previousPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOut,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.white,
                            ),
                            child: Text(l10n.guideBack),
                          )
                        else
                          const SizedBox.shrink(),
                        if (!isLast)
                          TextButton(
                            onPressed: () => _controller.nextPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOut,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.white,
                            ),
                            child: Text(l10n.guideNext),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
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

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});

  final _Page page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            page.asset,
            width: 120,
            height: 120,
            color: AppColors.white,
          ),
          const SizedBox(height: 15),
          if (page.title != null) ...[
            Text(
              page.title!.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppText.guideTitle(),
            ),
            const SizedBox(height: 15),
            Text(
              page.body!,
              textAlign: TextAlign.center,
              style: AppText.guideText(),
            ),
          ],
          if (page.checklist != null)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in page.checklist!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Image.asset(
                              'assets/icons/icn_check.png',
                              width: 16,
                              height: 16,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(item, style: AppText.guideText()),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
