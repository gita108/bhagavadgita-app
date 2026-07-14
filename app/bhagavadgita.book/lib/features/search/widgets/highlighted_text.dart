import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    required this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final String query;
  final TextStyle style;
  final TextStyle highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final spans = <TextSpan>[];
    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.toLowerCase();

    var start = 0;
    while (true) {
      final index = lowercaseText.indexOf(lowercaseQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle,
      ));

      start = index + query.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
