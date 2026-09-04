import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../config/app_config.dart';
import '../utils/local_proxy.dart';

/// Persistent avatar cache shared by every AvatarWidget in the application.
class AvatarCacheService {
  AvatarCacheService._()
      : _cache = CacheManager(
          Config(
            'xaneo_avatar_cache_v1',
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 500,
          ),
        );

  static final AvatarCacheService instance = AvatarCacheService._();

  final CacheManager _cache;
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static String cacheKeyFor(String sourceUrl) {
    final uri = Uri.tryParse(sourceUrl);
    if (uri == null || !uri.hasScheme) return sourceUrl;
    final query = Map<String, String>.from(uri.queryParameters)
      ..remove('token');
    return uri
        .replace(queryParameters: query.isEmpty ? null : query)
        .toString();
  }

  Future<File> fileFor(String sourceUrl) {
    final formatted = AppConfig.formatImageUrl(sourceUrl) ?? sourceUrl;
    return _cache.getSingleFile(
      _authenticatedImageUrl(formatted),
      key: cacheKeyFor(formatted),
    );
  }

  /// Removes both disk and decoded-image entries. This is needed when the
  /// backend keeps the same avatar URL after replacing its contents.
  Future<void> invalidate(String? sourceUrl) async {
    if (sourceUrl == null || sourceUrl.trim().isEmpty) return;
    final formatted = AppConfig.formatImageUrl(sourceUrl) ?? sourceUrl;
    final key = cacheKeyFor(formatted);
    final cached = await _cache.getFileFromCache(key);
    if (cached != null) {
      await FileImage(cached.file).evict();
    }
    await _cache.removeFile(key);
    revision.value++;
  }

  String _authenticatedImageUrl(String url) {
    try {
      final target = Uri.parse(url);
      final api = Uri.parse(AppConfig.apiBaseUrl);
      if (target.host == api.host) return LocalProxy.getProxyUrl(url);
    } catch (_) {}
    return url;
  }
}
