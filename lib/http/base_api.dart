import 'dart:convert';
import 'package:lc_http_demo/service/http_service.dart';

import 'package:dio/dio.dart';

enum RequestMethod { get, post, put, delete, patch, copy }

abstract class BaseApi {
  RequestMethod get method;

  String get path;

  Map<String, String>? get header {
    switch (method) {
      case RequestMethod.post:
        return <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        };
      default:
        return null;
    }
  }

  Map<String, dynamic>? get query => null;

  Map<String, dynamic>? get body => null;

  void request({
    required Function successCallBack,
    required Function errorCallBack,
  }) async {
    HttpService service = HttpService.instance;
    Dio dio = service.dio;

    Response? response;

    Map<String, String>? h = header;
    Map<String, dynamic>? q = query;
    Map<String, dynamic>? b = body;

    Map<String, dynamic>? queryParams = {};
    var globalQueryParams = service.serviceQuery();
    if (globalQueryParams != null) {
      queryParams.addAll(globalQueryParams);
    }
    if (q != null) {
      queryParams.addAll(q);
    }

    Map<String, dynamic>? headerParams = {};
    var globalHeaderParams = service.serviceHeader();
    if (globalHeaderParams != null) {
      headerParams.addAll(globalHeaderParams);
    }
    if (h != null) {
      headerParams.addAll(h);
    }

    Map<String, dynamic>? bodyParams = {};
    var globalBodyParams = service.serviceBody();
    if (globalBodyParams != null) {
      bodyParams.addAll(globalBodyParams);
    }
    if (b != null) {
      bodyParams.addAll(b);
    }

    String url = path;

    Options options = Options(headers: headerParams);

    try {
      switch (method) {
        case RequestMethod.get:
          response = await dio.get(url,
              queryParameters: queryParams, options: options);
          break;
        case RequestMethod.post:
          response = await dio.post(url, data: bodyParams, options: options);
          break;
        default:
          break;
      }
    } on DioException catch (error) {
      errorCallBack(service.errorFactory(error));
    }
    if (response != null && response.data != null) {
      String dataStr = json.encode(response.data);
      Map<String, dynamic> dataMap = json.decode(dataStr);
      dataMap = service.responseFactory(dataMap);
      successCallBack(dataMap);
    }
  }
}
