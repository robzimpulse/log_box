import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'form_data_field_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class FormDataFieldModel extends Equatable {
  const FormDataFieldModel({required this.name, required this.value});

  final String name;
  final String value;

  @override
  List<Object?> get props => [name, value];

  Map<String, dynamic> toJson() => _$FormDataFieldModelToJson(this);

  factory FormDataFieldModel.fromJson(Map<String, dynamic> json) {
    return _$FormDataFieldModelFromJson(json);
  }
}