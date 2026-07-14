import 'package:flutter/material.dart';
import 'package:bhagavadgita_book/features/shared/services/share_service.dart';

class ShareButton extends StatelessWidget {
  final ShareService _shareService = ShareService();
  final int? chapter;
  final int? verse;

  ShareButton({super.key, this.chapter, this.verse});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        if (chapter != null && verse != null) {
          _shareService.shareVerse(chapter: chapter!, verse: verse!);
        } else if (chapter != null) {
          _shareService.shareChapter(chapter: chapter!);
        }
      },
    );
  }
}
