import 'package:flutter/material.dart';

import '../../../ui/theme/app_text.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = AppText.label();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(text.toUpperCase(), style: style),
    );
  }
}

