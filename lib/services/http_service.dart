import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grid_view_demo/services/http_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
part 'http_service.g.dart';

enum Resource {
  galleryList1,
  galleryDetailList1,
  gallerySyncDetailList1,
  gallerySearchList1
}

enum HttpMethod { get, post, patch, delete }

enum MobileOS {
  ios,
  and,
  win,
  etc,
}

enum Arrange {
  a,
  b,
  c,
}

@riverpod
class HttpService extends _$HttpService {
  final Duration _timeout = const Duration(milliseconds: 5000);
  late final Dio _dio;
  late final String _serviceKey;
  late final MobileOS _mobileOS;
  @override
  Dio build() {
    _dio = Dio();
    _serviceKey = dotenv.get('DECODING_KEY');
    _mobileOS = _getPlatform();
    return _dio;
  }

  String get baseUrl => dotenv.get('END_POINT');

  MobileOS _getPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return MobileOS.and;
      case TargetPlatform.iOS:
        return MobileOS.ios;
      case TargetPlatform.windows:
        return MobileOS.win;
      default:
        return MobileOS.etc;
    }
  }

  Future<HttpResponse> sendRequest({
    String url = '',
    required HttpMethod httpMethod,
    required Resource resource,
    Arrange arrange = Arrange.a,
    int? numOfRows,
    int? pageNo,
  }) async {
    Response? response;

    try {
      final endPoint =
          url != '' ? "$url/${resource.name}" : "$baseUrl/${resource.name}";
      response = await _dio.request(endPoint,
          queryParameters: {
            'numOfRows': numOfRows,
            'pageNo': pageNo,
            'MobileOS': _mobileOS.name.toUpperCase(),
            'MobileApp': 'AppTest',
            'arrange': arrange.name.toUpperCase(),
            '_type': 'json',
            'serviceKey': _serviceKey
          },
          options: Options(
            method: httpMethod.name.toUpperCase(),
            sendTimeout: _timeout,
            receiveTimeout: _timeout,
            responseType: ResponseType.json,
          ));
    } on DioException catch (e) {
      throw HttpException(e.message ?? 'dio Exception occur');
    }
    HttpResponse apiResponse = (response.data == null || response.data == "")
        ? HttpResponse()
        : HttpResponse(
            resultCode: response.data['response']['header']['resultMsg'],
            resultMsg: response.data['response']['header']['resultCode'],
            items: response.data['response']['body']['items']['item'],
            numOfRows: response.data['response']['body']['numOfRows'],
            pageNo: response.data['response']['body']['pageNo'],
            totalCount: response.data['response']['body']['totalCount'],
          );
    return apiResponse;
  }
}
