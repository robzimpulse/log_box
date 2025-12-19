import 'package:json_annotation/json_annotation.dart';

enum NavigationAction {
  @JsonValue('push')
  push,
  @JsonValue('pop')
  pop,
  @JsonValue('remove')
  remove,
  @JsonValue('replace')
  replace }
