import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';

class PlaygroundScreen extends StatelessWidget {
  const PlaygroundScreen({
    super.key,
    required this.box,
    required this.dio,
    required this.cache,
  });

  final LogBox box;
  final Dio dio;
  final BaseCacheManager cache;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Playground Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: CachedNetworkImage(
                cacheManager: cache,
                imageUrl: 'https://picsum.photos/200/300',
                errorWidget: (context, url, error) {
                  return const Center(child: Icon(Icons.error));
                },
                progressIndicatorBuilder: (context, url, progress) {
                  return Center(
                    child: CircularProgressIndicator(value: progress.progress),
                  );
                },
              ),
            ),

            TextButton(
              onPressed: () => box.log('testing message'),
              child: Text('Send Log'),
            ),
            TextButton(
              onPressed: () => _onTapTrace(context),
              child: Text('Send Trace Log'),
            ),
            TextButton(
              onPressed: () async {
                final response = await dio.get(
                  options: Options(responseType: ResponseType.bytes),
                  'https://picsum.photos/200/300',
                );
                if (!context.mounted) return;
                final snackbar = SnackBar(content: Text(response.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              },
              child: Text('Send Get Request'),
            ),
            TextButton(
              onPressed: () => context.push('/webview'),
              child: Text('Open Webview Screen'),
            ),
            TextButton(
              onPressed: () {
                box.webview(
                  context: context,
                  uri: Uri.parse(
                    'https://www.scrapingcourse.com/cloudflare-challenge',
                  ),
                  onTapSnapshot: (url, html) async {
                    final snackbar = SnackBar(content: Text(url.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);

                    final manager = CookieManager.instance();
                    final cookies = await manager.getAllCookies();

                    for (final cookie in cookies) {
                      print(cookie);
                    }
                  },
                );
              },
              child: Text('Open Logbox Webview'),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapTrace(BuildContext context) async {
    return box.tracer('_onTapTrace', (tracer) async {
      await Future.delayed(Duration(milliseconds: 100));
      tracer(LogEntryModel(message: 'trace 1'));
      await Future.delayed(Duration(milliseconds: 100));
      tracer(LogEntryModel(message: 'trace 2'));
      await Future.delayed(Duration(milliseconds: 100));
      tracer(LogEntryModel(message: 'trace 3'));
      await Future.delayed(Duration(milliseconds: 100));
      tracer(LogEntryModel(message: 'done'));
    });
  }
}
