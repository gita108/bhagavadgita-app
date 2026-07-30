import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../ui/theme/app_colors.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/app_text.dart';

/// "Quote of the Day" card shown atop the Contents chapter list. Tapping the
/// body opens the Quote detail screen; the share icon shares directly.
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    this.author,
    this.onTap,
    this.onShare,
  });

  final String quote;
  final String? author;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.space2),
      color: AppColors.gray5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l10n.contentsQuoteTitle,
                      textAlign: TextAlign.center,
                      style: AppText.quoteTitle(),
                    ),
                    const SizedBox(height: 5),
                    Image.asset(
                      'assets/icons/divider.png',
                      height: 12,
                      color: AppColors.red1,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      quote,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body().copyWith(color: AppColors.gray1),
                    ),
                  ],
                ),
                if (onShare != null)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      onPressed: onShare,
                      icon: Image.asset(
                        'assets/icons/ic_share.png',
                        width: 20,
                        height: 20,
                        color: AppColors.gray2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
