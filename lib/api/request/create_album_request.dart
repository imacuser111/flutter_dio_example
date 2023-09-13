import 'package:lc_http_demo/http/base_api.dart';

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
