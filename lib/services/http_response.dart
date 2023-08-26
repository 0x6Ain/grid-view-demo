import 'package:freezed_annotation/freezed_annotation.dart';

part 'http_response.g.dart';
part 'http_response.freezed.dart';

@freezed
class HttpResponse with _$HttpResponse {
  factory HttpResponse({
    String? resultCode,
    String? resultMsg,
    dynamic items,
    int? numOfRows,
    int? pageNo,
    int? totalCount,
  }) = _HttpResponse;

  factory HttpResponse.fromJson(Map<String, dynamic> json) =>
      _$HttpResponseFromJson(json);
}
