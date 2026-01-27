// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigationEntryModel _$NavigationEntryModelFromJson(
  Map<String, dynamic> json,
) => NavigationEntryModel(
  id: json['id'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  action: $enumDecode(_$NavigationActionEnumMap, json['action']),
  route: json['route'] as String?,
  previousRoute: json['previous_route'] as String?,
  argument: json['argument'] as String?,
  previousArgument: json['previous_argument'] as String?,
);

Map<String, dynamic> _$NavigationEntryModelToJson(
  NavigationEntryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'action': _$NavigationActionEnumMap[instance.action]!,
  'route': instance.route,
  'argument': instance.argument,
  'previous_route': instance.previousRoute,
  'previous_argument': instance.previousArgument,
};

const _$NavigationActionEnumMap = {
  NavigationAction.push: 'push',
  NavigationAction.pop: 'pop',
  NavigationAction.remove: 'remove',
  NavigationAction.replace: 'replace',
};
