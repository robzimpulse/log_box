import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'searchable_text_widget.dart';

import '../extension/copyable_text_extension.dart';
import '../extension/json_helper_extension.dart';

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

  Widget _header(BuildContext context) {
    final value = this.value;

    return Row(
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
        if (value != null && image == null)
          IconButton(
            icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
            onPressed: () => value.copyToClipboard(context: context),
          )
        else
          SizedBox.shrink(),
      ],
    );
  }

  Widget _content(BuildContext context) {
    final value = this.value;
    final image = this.image;

    if (image != null) {
      return Image.memory(image, fit: BoxFit.contain);
    }

    if (value != null) {
      return HighlightedTextWidget(
        text: value.isJson ? value.prettify : value,
        style: Theme.of(context).textTheme.labelSmall,
        searchTerm: searchTerm,
      );
    }

    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShrink = [
      value == null || value?.isEmpty == true,
      image == null || image?.isEmpty == true,
    ].every((e) => e);

    if (shouldShrink) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _content(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
