import 'package:flutter/material.dart';

import '../../data/remote/dto/quote_dto.dart';
import '../../l10n/l10n.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text.dart';
import '../shared/services/share_service.dart';

/// Full-screen quote detail, reached by tapping the Quote-of-the-Day card
/// body on Contents. Receives the already-fetched [quote] directly — no
/// re-fetch, matching legacy's Intent-extra / navigation-argument pattern.
class QuoteScreen extends StatelessWidget {
  const QuoteScreen({super.key, required this.quote});

  final QuoteDto quote;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = quote.text ?? '';
    final author = quote.author ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contentsQuoteTitle, style: AppText.navTitle()),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/ic_share.png',
              width: 22,
              height: 22,
              color: AppColors.white,
            ),
            onPressed: () {
              ShareService().shareQuote(text: text, author: author);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: AppText.body()),
            const SizedBox(height: AppSpacing.space4),
            Text(
              author,
              style: AppText.bodyItalic().copyWith(
                fontSize: 14,
                color: AppColors.gray2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
