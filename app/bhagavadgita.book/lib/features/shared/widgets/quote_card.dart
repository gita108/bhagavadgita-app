import 'package:flutter/material.dart';

import '../../../ui/theme/app_colors.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    this.author,
  });

  final String quote;
  final String? author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gray5,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray1),
          ),
          if (author != null && author!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- $author',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.gray2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

