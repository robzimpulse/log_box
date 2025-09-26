import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../src/extension/extension.dart';
import 'searchable_text_widget.dart';

class HumanReadableWidget extends StatelessWidget {
  const HumanReadableWidget({
    super.key,
    required this.name,
    this.value,
    this.image,
    this.searchTerm,
  });

  final String name;
  final String? value;
  final Uint8List? image;
  final String? searchTerm;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Builder(
              builder: (context) {
                final value = this.value;

                if (value != null && image == null) {
                  return IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                    onPressed: () => value.copyToClipboard(context: context),
                  );
                }

                return SizedBox();
              },
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Builder(
                builder: (context) {
                  final image = this.image;
                  if (image != null) {
                    return Image.memory(image);
                  }

                  final value = this.value;

                  if (value != null) {
                    return SelectionArea(
                      child: HighlightedTextWidget(
                        text: value.isJson ? value.prettify : value,
                        style: Theme.of(context).textTheme.labelSmall,
                        searchTerm: searchTerm,
                      ),
                    );
                  }

                  return SizedBox();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
