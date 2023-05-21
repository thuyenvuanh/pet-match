import 'package:intl/intl.dart';

class ApiError {
  String? httpStatus;
  DateTime? timestamp;
  String? message;
  String? debugMessage;
  List<ApiErrorDetails>? details;

  ApiError({
    this.httpStatus,
    this.timestamp,
    this.message,
    this.debugMessage,
    this.details,
  });

  ApiError.fromJson(Map<String, dynamic> json) {
    httpStatus = json['httpStatus'];
    timestamp = DateFormat('dd/MM/yyyy hh:mm:ss').parse(json['timestamp']);
    message = json['message'];
    debugMessage = json['debugMessage'];
    if (json['details'] != null) {
      details = List.castFrom(json['details'])
          .map((e) => ApiErrorDetails.fromJson(e))
          .toList();
    }
  }
}

class ApiErrorDetails {
  String? object;
  String? field;
  String? value;
  String? message;

  ApiErrorDetails({this.object, this.field, this.value, this.message});

  ApiErrorDetails.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    field = json['field'];
    value = json['value'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    return {
      'object': object,
      'field': field,
      'value': value,
      'message': message,
    };
  }
}
