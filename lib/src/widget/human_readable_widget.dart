import 'package:flutter/material.dart';
import 'package:log_box/src/common/extension.dart';

class HumanReadableWidget extends StatelessWidget {
  const HumanReadableWidget({super.key, required this.name, this.value});

  final String name;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    if (value == null) return const SizedBox();
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
                name ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
              onPressed: () => value.copyToClipboard(context: context),
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
              child: SelectionArea(
                child: Text(
                  value.isJson ? value.prettify : value,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
