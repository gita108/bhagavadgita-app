import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/audio/audio_download_controller.dart';
import '../../app/audio/audio_track.dart';
import '../../app/bootstrap/bootstrap_coordinator.dart';
import '../../app/quote/quote_of_day_controller.dart';
import '../../l10n/l10n.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text.dart';
import '../../ui/widgets/om_logo.dart';
import '../../data/local/app_database.dart';
import '../contents/contents_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/app_onboarding_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<BootstrapResult> _future;
  double _progress = 0.0;
  bool _showDownloadDialog = false;
  bool _downloadDialogDismissed = false;

  @override
  void initState() {
    super.initState();
    _future = _bootstrap();
  }

  Future<BootstrapResult> _bootstrap() async {
    _progress = 0.0;
    final result = await BootstrapCoordinator(db: widget.db).run(
      onProgress: (fraction) {
        if (mounted) setState(() => _progress = fraction);
      },
    );
    if (result.hasSnapshot) {
      unawaited(quoteOfDayController.refreshIfStale());
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<BootstrapResult>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _SplashScaffold(
            title: l10n.splashAppName,
            subtitle: '',
            showProgress: true,
            progress: _progress,
          );
        }
        if (snap.hasError) {
          return _SplashScaffold(
            title: l10n.splashAppName,
            subtitle: l10n.splashConnectionError,
            showProgress: false,
            retryLabel: l10n.retry,
            onTap: () => setState(() => _future = _bootstrap()),
          );
        }

        final result = snap.requireData;
        if (!result.hasSnapshot) {
          return _SplashScaffold(
            title: l10n.splashAppName,
            subtitle: l10n.splashConnectionError,
            showProgress: false,
          );
        }

        // Show download dialog on first successful bootstrap
        if (!_downloadDialogDismissed && !_showDownloadDialog) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showDownloadDialog = true);
          });
        }

        if (_showDownloadDialog) {
          return _SplashScaffold(
            title: l10n.splashAppName,
            subtitle: '',
            showProgress: false,
            dialog: _AudioDownloadDialog(
              prompt: l10n.splashAudioDownloadPrompt,
              yesLabel: l10n.confirmYes,
              noLabel: l10n.confirmNo,
              onYes: () {
                setState(() {
                  _showDownloadDialog = false;
                  _downloadDialogDismissed = true;
                });
                unawaited(
                  audioDownloadController.downloadAllChapters(
                    AudioTrack.translation,
                  ),
                );
                unawaited(
                  audioDownloadController.downloadAllChapters(
                    AudioTrack.sanskrit,
                  ),
                );
              },
              onNo: () {
                setState(() {
                  _showDownloadDialog = false;
                  _downloadDialogDismissed = true;
                });
              },
            ),
          );
        }

        return ListenableBuilder(
          listenable: appOnboardingController,
          builder: (context, _) {
            if (!appOnboardingController.value) {
              return OnboardingScreen(db: widget.db);
            }
            return ContentsScreen(db: widget.db);
          },
        );
      },
    );
  }
}

class _SplashScaffold extends StatelessWidget {
  const _SplashScaffold({
    required this.title,
    required this.subtitle,
    required this.showProgress,
    this.progress = 0.0,
    this.retryLabel,
    this.onTap,
    this.dialog,
  });

  final String title;
  final String subtitle;
  final bool showProgress;
  final double progress;
  final String? retryLabel;
  final VoidCallback? onTap;
  final Widget? dialog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const OmLogo(size: 96),
                const SizedBox(height: 30),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppText.splashTitle(),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppText.body().copyWith(
                      color: AppColors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
                if (retryLabel != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    retryLabel!,
                    style: AppText.body().copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
                if (showProgress) ...[
                  const SizedBox(height: 41),
                  SizedBox(
                    width: 240,
                    child: Column(
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppText.body().copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: AppColors.red2,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (dialog != null) ...[const SizedBox(height: 32), dialog!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioDownloadDialog extends StatelessWidget {
  const _AudioDownloadDialog({
    required this.prompt,
    required this.yesLabel,
    required this.noLabel,
    required this.onYes,
    required this.onNo,
  });

  final String prompt;
  final String yesLabel;
  final String noLabel;
  final VoidCallback onYes;
  final VoidCallback onNo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppEffects.shadowCard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: AppText.body().copyWith(color: AppColors.gray1),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onNo,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gray1,
                  side: const BorderSide(color: AppColors.gray3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(noLabel),
              ),
              const SizedBox(width: 16),
              FilledButton(onPressed: onYes, child: Text(yesLabel)),
            ],
          ),
        ],
      ),
    );
  }
}
