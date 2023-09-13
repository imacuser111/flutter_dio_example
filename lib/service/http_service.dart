import 'package:dio/dio.dart';

class HttpService {
  HttpService._privateConstructor();

  static final HttpService instance = HttpService._privateConstructor();

  final _baseUrl = "https://jsonplaceholder.typicode.com/";

  final Dio dio = Dio();

  Map<String, dynamic>? serviceHeader() {
    Map<String, dynamic> header = <String, dynamic>{};
    // header["token"] = "";
    return header;
  }

  Map<String, dynamic>? serviceQuery() {
    return null;
  }

  Map<String, dynamic>? serviceBody() {
    return null;
  }

  void initDio() {
    //請求標頭也可以在這裡設置
    dio.options.headers = {
      "Access-Control-Allow-Origin": "*",
    };
    dio.options.baseUrl = _baseUrl;

    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 8);
    // dio.options.contentType = "application/json";
    //這裡可以添加其他插件
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Map<String, dynamic> responseFactory(Map<String, dynamic> dataMap) {
    return dataMap;
  }

  String createMessage(List<dynamic> errorVar, String message) {
    String string = message;
    for (var error in errorVar) {
      string = string.replaceFirst("%s", error);
    }
    return string;
  }

  String errorFactory(DioException error) {
    //請求處理錯誤
    String? errorMessage = error.message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = "網路連線超時，請檢查網路設定";
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = "伺服器異常，請稍後重試！";
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = "網路連線超時，請檢查網路設定";
        break;
      case DioExceptionType.badResponse:
        errorMessage = "伺服器異常，請稍後重試！";
        break;
      case DioExceptionType.cancel:
        errorMessage = "請求已被取消，請重新請求";
        break;
      default:
        errorMessage = "網路異常，請稍後重試！";
        break;
    }
    return errorMessage;
  }
}
