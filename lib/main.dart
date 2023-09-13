import 'package:flutter/material.dart';
import 'package:lc_http_demo/service/http_service.dart';
import 'package:lc_http_demo/view_model/album_provider.dart';
import 'package:provider/provider.dart';

import 'api/api_response.dart';
import 'api/podo/album_response.dart';

void main() {
  HttpService service = HttpService.instance;
  service.initDio();
  runApp(const MyApp());
}

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('myApp build');
    return ChangeNotifierProvider<AlbumProvider>(
      create: (context) => AlbumProvider(),
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}

/// The home screen
class HomeScreen extends StatelessWidget {
  final _controller = TextEditingController();

  /// Constructs a [HomeScreen]
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen build');

    final viewModel = Provider.of<AlbumProvider>(context, listen: false);

    // 等待畫面初始化完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchAlbumData('1');
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Enter Title'),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                viewModel.createAlbumData(_controller.text);
                // httpService
                //     .send(CreateAlbumRequest(_controller.text))
                //     .then((value) => viewModel.setupData(value.album));
              },
              child: const Text('send createAlbumRequest'),
            ),
            Consumer<AlbumProvider>(
              builder: (context, value, child) {
                
                debugPrint(value.response.status.toString()); // print
                
                switch (value.response.status) {
                  case Status.error:
                    return const FlutterLogo();
                  case Status.completed:
                    Album data = value.response.data;
                    return Text(data.title);
                  default:
                    return const CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
