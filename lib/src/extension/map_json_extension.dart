import 'dart:convert';

extension MapJsonExtension on Map<String, dynamic> {
  String? get json {
    try {
      return jsonEncode(this);
    } catch (e) {
      return null;
    }
  }
}