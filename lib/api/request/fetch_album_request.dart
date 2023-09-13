import 'package:lc_http_demo/http/base_api.dart';

class FetchAlbumRequest extends BaseApi {
  final String title;

  FetchAlbumRequest(this.title);

  @override
  String get path => 'albums/$title';

  @override
  RequestMethod get method => RequestMethod.get;
}
