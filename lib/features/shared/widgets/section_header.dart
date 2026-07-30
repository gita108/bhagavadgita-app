import 'package:flutter/material.dart';

import '../../../ui/theme/app_text.dart';

/// Small uppercase label. [settingsStyle] switches to the larger
/// gray2/14sp style used for Settings' section headers ("DISPLAY", "AUDIO",
/// ...) — resolved (2026-07-30) over Android's red1 version, see
/// vdd-bhagavadgita-app-uiux specs; the default (smaller, `AppText.label()`)
/// style remains for the Reader's use.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.settingsStyle = false});

  final String text;
  final bool settingsStyle;

  @override
  Widget build(BuildContext context) {
    final style = settingsStyle
        ? AppText.settingsSectionHeader()
        : AppText.label();
    final padding = settingsStyle
        ? const EdgeInsets.fromLTRB(16, 18, 16, 8)
        : const EdgeInsets.only(top: 10, bottom: 6);
    return Padding(
      padding: padding,
      child: Text(text.toUpperCase(), style: style),
    );
  }
}
