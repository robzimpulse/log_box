extension StringFormatExtension on String {
  String interpolate(List<Object?>? params) {
    if (params == null || params.isEmpty) return this;
    String result = this;
    for (final param in params) {
      result = result.replaceFirst(
        '?',
        (param is String) ? '"$param"' : '$param',
      );
    }
    return result;
  }
}
