import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/auth/token_storage.dart';

class LocalProxy {
  static HttpServer? _server;

  static Future<void> start() async {
    if (_server != null) return;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server!.listen((HttpRequest request) async {
        final targetUrl = request.uri.queryParameters['url'];
        final jwtToken = request.uri.queryParameters['token'];

        if (targetUrl == null) {
          request.response.statusCode = 400;
          await request.response.close();
          return;
        }

        try {
          final client = HttpClient();
          // Explicitly ignore SSL certificate validation for local development
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          
          Uri targetUri = Uri.parse(targetUrl!);
          
          // Get fresh token from storage and inject it into the request URL
          final freshToken = await TokenStorage().getAccessToken();
          if (freshToken != null && freshToken.isNotEmpty) {
             final newParams = Map<String, String>.from(targetUri.queryParameters);
             newParams['token'] = freshToken;
             targetUri = targetUri.replace(queryParameters: newParams);
          }

          final clientRequest = await client.getUrl(targetUri);

          // Propagate headers (especially Range for video)
          request.headers.forEach((name, values) {
            if (name.toLowerCase() == 'host') return;
            clientRequest.headers.set(name, values.join(','));
          });

          if (freshToken != null && freshToken.isNotEmpty) {
            clientRequest.headers.set('Authorization', 'Bearer $freshToken');
          }

          final clientResponse = await clientRequest.close();

          request.response.statusCode = clientResponse.statusCode;
          clientResponse.headers.forEach((name, values) {
            request.response.headers.set(name, values.join(','));
          });

          await clientResponse.pipe(request.response);
        } catch (e, stack) {
          debugPrint('LocalProxy handler error for url $targetUrl: $e\n$stack');
          request.response.statusCode = 500;
          await request.response.close();
        }
      });
    } catch (e) {
      print('Proxy start error: $e');
    }
  }

  static String getProxyUrl(String targetUrl, {String? jwtToken, String? ext}) {
    if (_server == null) return targetUrl;
    
    String path = '/media';
    if (ext != null) {
      path = '/media$ext';
    } else {
      final lower = targetUrl.toLowerCase();
      if (lower.contains('.m4a')) path = '/audio.m4a';
      else if (lower.contains('.mp3')) path = '/audio.mp3';
      else if (lower.contains('.mp4')) path = '/video.mp4';
      else if (lower.contains('.m3u8')) path = '/video.m3u8';
    }

    final uri = Uri(
      scheme: 'http',
      host: _server!.address.address,
      port: _server!.port,
      path: path,
      queryParameters: {
        'url': targetUrl,
        if (jwtToken != null) 'token': jwtToken,
      },
    );
    return uri.toString();
  }
}
