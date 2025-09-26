import 'package:flutter/material.dart';

/// A widget for displaying text with highlighted search terms.
class SearchableTextWidget extends StatelessWidget {
  /// Original text to display.
  final String text;

  /// Term to highlight.
  final String searchTerm;

  /// Style for non-highlighted text.
  final TextStyle? style;

  /// Style for highlighted text.
  final TextStyle? highlightedStyle;

  /// Decoration for highlighted area (optional).
  /// Default is a yellow container
  ///
  /// ```dart
  /// BoxDecoration(color: Colors.yellow)
  /// ```

  final BoxDecoration? highlightedDecoration;

  /// Creates a text widget with highlighted search terms.
  ///
  /// The [text] parameter is the original text to be displayed.
  ///
  /// The [searchTerm] parameter is the term to search for and highlight.
  ///
  /// The [style] parameter defines the style for non-highlighted text.
  ///
  /// The [highlightedTextStyle] parameter defines the style for highlighted text.
  ///
  /// The [highlighterDecoration] parameter defines decoration for the highlighted area.
  const SearchableTextWidget(
    this.text, {
    super.key,
    required this.searchTerm,
    this.style,
    this.highlightedStyle,
    this.highlightedDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(children: _highlightOccurrences);
  }

  BoxDecoration get _defaultHighlightDecoration {
    return BoxDecoration(color: Colors.yellow);
  }

  List<Widget> get _highlightOccurrences {
    final List<Widget> widgets = [];
    final String lowerCaseText = text.toLowerCase();
    final String lowerCaseSearchTerm = searchTerm.toLowerCase();
    final List<String> parts =
        lowerCaseSearchTerm.isEmpty
            ? [lowerCaseText]
            : lowerCaseText.split(lowerCaseSearchTerm);

    int startIndex = 0;

    for (String part in parts) {
      if (lowerCaseText.indexOf(part, startIndex) != -1) {
        widgets.add(
          Text(
            text.substring(startIndex, startIndex + part.length),
            style: style,
          ),
        );
        startIndex += part.length;
      }

      if (startIndex < text.length) {
        widgets.add(
          Container(
            decoration: highlightedDecoration ?? _defaultHighlightDecoration,
            child: Text(
              text.substring(
                startIndex,
                startIndex + lowerCaseSearchTerm.length,
              ),
              style: highlightedStyle ?? style,
            ),
          ),
        );
        startIndex += lowerCaseSearchTerm.length;
      }
    }

    return widgets;
  }
}
