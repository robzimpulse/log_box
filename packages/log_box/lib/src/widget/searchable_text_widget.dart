import 'package:flutter/material.dart';

/// A widget for displaying text with highlighted search terms.
class HighlightedTextWidget extends StatelessWidget {
  /// Original text to display.
  final String text;

  /// Term to highlight.
  final String? searchTerm;

  /// Style for non-highlighted text.
  final TextStyle? style;

  /// Style for highlighted text.
  final Color highlightedColor;

  /// Creates a text widget with highlighted search terms.
  ///
  /// The [text] parameter is the original text to be displayed.
  ///
  /// The [searchTerm] parameter is the term to search for and highlight.
  ///
  /// The [style] parameter defines the style for non-highlighted text.
  ///
  /// The [highlightedColor] parameter defines the color for highlighted text.
  const HighlightedTextWidget({
    super.key,
    required this.text,
    this.searchTerm,
    this.style,
    this.highlightedColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    final terms = searchTerm;
    if (terms == null) return SelectionArea(child: Text(text, style: style));
    return SelectableText.rich(
      TextSpan(text: '', children: _buildSpan(context, terms)),
    );
  }

  List<InlineSpan> _buildSpan(BuildContext context, String term) {
    final List<InlineSpan> widgets = [];
    final String lowerCaseText = text.toLowerCase();
    final String lowerCaseSearchTerm = term.toLowerCase();
    final List<String> parts =
        lowerCaseSearchTerm.isEmpty
            ? [lowerCaseText]
            : lowerCaseText.split(lowerCaseSearchTerm);

    int startIndex = 0;

    for (String part in parts) {
      if (lowerCaseText.indexOf(part, startIndex) != -1) {
        widgets.add(
          TextSpan(
            text: text.substring(startIndex, startIndex + part.length),
            style: style,
          ),
        );
        startIndex += part.length;
      }

      if (startIndex < text.length) {
        widgets.add(
          TextSpan(
            text: text.substring(
              startIndex,
              startIndex + lowerCaseSearchTerm.length,
            ),
            style: style?.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: highlightedColor,
            ),
          ),
        );
        startIndex += lowerCaseSearchTerm.length;
      }
    }

    return widgets;
  }
}
