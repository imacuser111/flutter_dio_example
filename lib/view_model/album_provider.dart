import 'package:flutter/cupertino.dart';

import '../api//request/create_album_request.dart';
import '../api/api_response.dart';
import '../api/podo/album_response.dart';
import '../api/request/fetch_album_request.dart';
import '../http/base_api.dart';

class AlbumProvider with ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.initial('Empty data');

  ApiResponse get response {
    return _apiResponse;
  }

  fetchAlbumData(String title) {
    BaseApi apiRequest = FetchAlbumRequest(title);
    _send(apiRequest);
  }

  createAlbumData(String title) {
    BaseApi apiRequest = CreateAlbumRequest(title);
    _send(apiRequest);
  }

  _send(BaseApi apiRequest) async {
    _apiResponse = ApiResponse.loading('Create album data');
    notifyListeners();

    apiRequest.request(successCallBack: (data) {
      final album = Album.fromJson(data);
      _apiResponse = ApiResponse.completed(album);
      notifyListeners();
    }, errorCallBack: (e) {
      _apiResponse = ApiResponse.error(e.toString());
      notifyListeners();
    });
  }
}
