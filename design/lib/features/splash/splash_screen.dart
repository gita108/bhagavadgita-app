import 'package:flutter/material.dart';

import '../../data/mock_content.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../../ui/widgets/om_logo.dart';
import '../onboarding/onboarding_screen.dart';

/// Splash screen — red gradient bg, centered Om logo + wordmark, loading
/// indicator with percentage. Mocked progress for layout work.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showDownloadDialog = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _showDownloadDialog = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const OnboardingScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_controller.value * 100).round();
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(decoration: const BoxDecoration(
              gradient: AppColors.splashGradient)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const SplashWordmark(),
                  const Spacer(),
                  if (!_showDownloadDialog) ...[
                    Text('Loading data…',
                        style: AppText.body()
                            .copyWith(color: AppColors.white)),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: _controller.value,
                          minHeight: 6,
                          backgroundColor:
                              AppColors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('$pct%',
                        style: AppText.caption()
                            .copyWith(color: AppColors.white)),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          if (_showDownloadDialog)
            Center(child: _DownloadDialog(onResult: (_) => _continue())),
        ],
      ),
    );
  }
}

class _DownloadDialog extends StatelessWidget {
  const _DownloadDialog({required this.onResult});
  final ValueChanged<bool> onResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black20,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Download audio files?',
              style: AppText.heading(),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            'Sanskrit and translation audio (~150 MB). You can also '
            'download them later from Settings.',
            style: AppText.body().copyWith(color: AppColors.gray2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onResult(false),
                  child: const Text('No'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => onResult(true),
                  child: const Text('Yes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Sanity check that mock content compiles.
final _bootSanity = MockContent.chapters.length;
