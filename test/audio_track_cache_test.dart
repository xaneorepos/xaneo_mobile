import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/services/audio/audio_track_cache.dart';
import 'package:xaneo/services/database/app_database.dart';

void main() {
  late AppDatabase database;
  late AudioTrackCache cache;
  late Directory tempDirectory;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    cache = AudioTrackCache(database);
    tempDirectory = await Directory.systemTemp.createTemp('xaneo_audio_test_');
  });

  tearDown(() async {
    await database.close();
    await tempDirectory.delete(recursive: true);
  });

  test('stores metadata and restores bit-perfect compressed audio', () async {
    const sourceUrl = 'https://xaneo.test/files/track.mp3';
    final artworkUri = Uri.parse('https://xaneo.test/covers/track.jpg');
    final metadata = AudioTrackMetadata(
      sourceUrl: sourceUrl,
      title: 'Track title',
      artist: 'Artist',
      album: 'Album',
      mimeType: 'audio/mpeg',
      duration: const Duration(seconds: 42),
      artworkUri: artworkUri,
    );
    final original = List<int>.generate(8192, (index) => index % 16);
    final source = File('${tempDirectory.path}/source.mp3');
    await source.writeAsBytes(original);

    await cache.saveMetadata(metadata);
    await cache.storeFile(metadata, source);

    final row = await (database.select(database.audioTracks)
          ..where((track) => track.sourceUrl.equals(sourceUrl)))
        .getSingle();
    expect(row.title, 'Track title');
    expect(row.artist, 'Artist');
    expect(row.album, 'Album');
    expect(row.durationMs, 42000);
    expect(row.compression, 'zlib');
    expect(row.storedBytes, lessThan(row.originalBytes));

    await source.delete();
    final restored = await cache.restoreFile(
      sourceUrl,
      tempDirectory,
      extension: '.mp3',
    );
    expect(restored, isNotNull);
    expect(await restored!.readAsBytes(), original);
  });

  test('updating metadata keeps the stored audio payload', () async {
    const sourceUrl = 'https://xaneo.test/files/track.ogg';
    const originalMetadata = AudioTrackMetadata(
      sourceUrl: sourceUrl,
      title: 'Old title',
      artist: 'Artist',
    );
    final source = File('${tempDirectory.path}/source.ogg');
    await source.writeAsBytes(List<int>.filled(1024, 7));
    await cache.storeFile(originalMetadata, source);

    await cache.saveMetadata(const AudioTrackMetadata(
      sourceUrl: sourceUrl,
      title: 'New title',
      artist: 'Artist',
    ));

    final row = await (database.select(database.audioTracks)
          ..where((track) => track.sourceUrl.equals(sourceUrl)))
        .getSingle();
    expect(row.title, 'New title');
    expect(row.audioData, isNotEmpty);
  });

  test('reports persisted tracks to a newly attached cache facade', () async {
    const sourceUrl = 'https://xaneo.test/files/persisted.mp3';
    const metadata = AudioTrackMetadata(
      sourceUrl: sourceUrl,
      title: 'Persisted track',
      artist: 'Artist',
    );
    final source = File('${tempDirectory.path}/persisted.mp3');
    await source.writeAsBytes(List<int>.generate(2048, (index) => index % 31));
    await cache.storeFile(metadata, source);

    final reattachedCache = AudioTrackCache(database);
    final cachedUrls = await reattachedCache.watchCachedSourceUrls().first;

    expect(cachedUrls, contains(sourceUrl));
  });
}
