---
title: 'Flutter Dio 封裝'
tags: Flutter
disqus: hackmd
---

<font size="6">Flutter Dio 封裝</font>

## 背景

我們知道dio是一個非常強大的Dart Http請求庫，支持非常多的功能，如果我們單單只是在外層包裹一層業務相關的封裝，如果業務場景稍微複雜一點，這一層封裝就顯得臃腫和冗餘了，當然我們的網絡層本身也是為業務層服務，業務層有了需求，網絡層自然得有響應了，只是響應的方式應該遵循低耦合、可用性、可維護性、可擴展性等原則。

## 設計

我在做iOS原生開發的時候深受Casa大神網絡層設計的影響，這裡將服務層( service)和接口層( api)劃分開，這樣做的好處有：

在面對不同服務時可單獨配置相關的http強求配置，通常我們的應用在開發的過程中都不會只和一個服務交互，所以在這種場景下是非常有必要的。
服務層和接口層職責拆分，讓他們做自己該做的事情。

![](https://hackmd.io/_uploads/BkFud30An.png)

## 實現

### 服務層

服務層的職責包括：baseUrl的配置、服務公共請求頭的配置、服務公共請求參數的配置、請求結果的加工、請求錯誤的統一處理等，除此之外還有驗證、輸出token等log。這裡只提供一種封裝思路具體的實現可以根據業務場景自行實現。首先我們會創建一個抽象的基類，這裡命名為Service，因為每一次請求都應該有一個全新的dio實例，Service只需要記錄一個配置信息


```dart=
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
```

### api層

Api層的職責包括設置path、請求參數的組裝、請求method配置等功能了。

```dart=
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
```

## 使用

### 註冊

在網絡請求前需要完成服務的註冊

```dart=
void main() {
  HttpService service = HttpService.instance;
  service.initDio();
  runApp(const MyApp());
}
```

### Api的實現

Api的實現也是繼承於BaseApi，然後實現相關的父類方法重寫即可：

```dart=
// get
class FetchAlbumRequest extends BaseApi {
  final String title;

  FetchAlbumRequest(this.title);

  @override
  String get path => 'albums/$title';

  @override
  RequestMethod get method => RequestMethod.get;
}

// post
class CreateAlbumRequest extends BaseApi {
  final String title;

  CreateAlbumRequest(this.title);

  @override
  String get path => 'albums';

  @override
  RequestMethod get method => RequestMethod.post;

  @override
  Map<String, dynamic>? get body => <String, String>{
        'title': title,
      };
}
```

### Api的調用

```dart=
BaseApi apiRequest = FetchAlbumRequest(title);

apiRequest.request(successCallBack: (data) {
      final album = Album.fromJson(data);
      _apiResponse = ApiResponse.completed(album);
      notifyListeners();
    }, errorCallBack: (e) {
      _apiResponse = ApiResponse.error(e.toString());
      notifyListeners();
    });
```

## Demo

https://github.com/imacuser111/flutter_dio_example

## 參考

https://juejin.cn/post/7101238139254997006
