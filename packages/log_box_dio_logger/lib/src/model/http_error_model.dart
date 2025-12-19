import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'http_error_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class HttpErrorModel extends Equatable {
  final String? error;
  final String? stackTrace;

  const HttpErrorModel({this.error, this.stackTrace});

  @override
  List<Object?> get props => [error, stackTrace];

  Map<String, dynamic> toJson() => _$HttpErrorModelToJson(this);

  factory HttpErrorModel.fromJson(Map<String, dynamic> json) {
    return _$HttpErrorModelFromJson(json);
  }
}