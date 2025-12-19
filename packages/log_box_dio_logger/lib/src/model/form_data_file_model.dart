import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'form_data_file_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class FormDataFileModel extends Equatable {
  const FormDataFileModel({
    this.fileName,
    required this.contentType,
    required this.length,
  });

  final String? fileName;
  final String contentType;
  final int length;

  @override
  List<Object?> get props => [fileName, contentType, length];

  Map<String, dynamic> toJson() => _$FormDataFileModelToJson(this);

  factory FormDataFileModel.fromJson(Map<String, dynamic> json) {
    return _$FormDataFileModelFromJson(json);
  }
}