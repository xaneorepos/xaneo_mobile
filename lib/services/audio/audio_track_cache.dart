import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';

class AudioTrackMetadata {
  const AudioTrackMetadata({
    required this.sourceUrl,
    required this.title,
    required this.artist,
    this.album = '',
    this.mimeType,
    this.duration,
    this.artworkUri,
  });

  final String sourceUrl;
  final String title;
  final String artist;
  final String album;
  final String? mimeType;
  final Duration? duration;
  final Uri? artworkUri;
}

/// User-scoped, encrypted SQLite cache for tracks and their metadata.
/// Audio is kept bit-perfect: zlib is used only when it actually saves space.
class AudioTrackCache {
  AudioTrackCache(this._db);

  static const int maxStoredBytes = 256 * 1024 * 1024;
  final AppDatabase _db;

  Object get databaseIdentity => _db;

  Stream<Set<String>> watchCachedSourceUrls() {
    final query = _db.selectOnly(_db.audioTracks)
      ..addColumns([_db.audioTracks.sourceUrl])
      ..where(_db.audioTracks.audioData.isNotNull());
    return query.watch().map(
          (rows) => rows
              .map((row) => row.read(_db.audioTracks.sourceUrl))
              .whereType<String>()
              .toSet(),
        );
  }

  Future<void> saveMetadata(AudioTrackMetadata metadata) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      final updated = await (_db.update(_db.audioTracks)
            ..where((track) => track.sourceUrl.equals(metadata.sourceUrl)))
          .write(AudioTracksCompanion(
        title: Value(metadata.title),
        artist: Value(metadata.artist),
        album: Value(metadata.album),
        mimeType: Value(metadata.mimeType),
        durationMs: Value(metadata.duration?.inMilliseconds),
        artworkUri: Value(metadata.artworkUri?.toString()),
        lastAccessedAt: Value(now),
        updatedAt: Value(now),
      ));
      if (updated == 0) {
        await _db.into(_db.audioTracks).insert(
              AudioTracksCompanion.insert(
                sourceUrl: metadata.sourceUrl,
                title: Value(metadata.title),
                artist: Value(metadata.artist),
                album: Value(metadata.album),
                mimeType: Value(metadata.mimeType),
                durationMs: Value(metadata.duration?.inMilliseconds),
                artworkUri: Value(metadata.artworkUri?.toString()),
                lastAccessedAt: now,
                updatedAt: now,
              ),
            );
      }
    });
  }

  Future<bool> hasAudio(String sourceUrl) async {
    final row = await (_db.selectOnly(_db.audioTracks)
          ..addColumns([_db.audioTracks.audioData])
          ..where(_db.audioTracks.sourceUrl.equals(sourceUrl)))
        .getSingleOrNull();
    return row?.read(_db.audioTracks.audioData)?.isNotEmpty ?? false;
  }

  Future<void> storeFile(
    AudioTrackMetadata metadata,
    File source,
  ) async {
    final bytes = await source.readAsBytes();
    if (bytes.isEmpty) return;
    final compressed = Uint8List.fromList(zlib.encode(bytes));
    final shouldCompress = compressed.length < bytes.length;
    final stored = shouldCompress ? compressed : bytes;
    final now = DateTime.now();
    await _db.into(_db.audioTracks).insertOnConflictUpdate(
          AudioTracksCompanion.insert(
            sourceUrl: metadata.sourceUrl,
            title: Value(metadata.title),
            artist: Value(metadata.artist),
            album: Value(metadata.album),
            mimeType: Value(metadata.mimeType),
            durationMs: Value(metadata.duration?.inMilliseconds),
            artworkUri: Value(metadata.artworkUri?.toString()),
            audioData: Value(stored),
            compression: Value(shouldCompress ? 'zlib' : null),
            originalBytes: Value(bytes.length),
            storedBytes: Value(stored.length),
            lastAccessedAt: now,
            updatedAt: now,
          ),
        );
    await _evictOldTracks();
  }

  Future<File?> restoreFile(
    String sourceUrl,
    Directory targetDirectory, {
    required String extension,
  }) async {
    final row = await (_db.select(_db.audioTracks)
          ..where((track) => track.sourceUrl.equals(sourceUrl)))
        .getSingleOrNull();
    final stored = row?.audioData;
    if (row == null || stored == null || stored.isEmpty) return null;

    final bytes = row.compression == 'zlib'
        ? Uint8List.fromList(zlib.decode(stored))
        : stored;
    await targetDirectory.create(recursive: true);
    final safeName = sourceUrl.hashCode.toUnsigned(32).toRadixString(16);
    final file = File(p.join(targetDirectory.path, '$safeName$extension'));
    await file.writeAsBytes(bytes, flush: true);
    await (_db.update(_db.audioTracks)
          ..where((track) => track.sourceUrl.equals(sourceUrl)))
        .write(AudioTracksCompanion(lastAccessedAt: Value(DateTime.now())));
    return file;
  }

  Future<void> _evictOldTracks() async {
    final rows = await (_db.select(_db.audioTracks)
          ..where((track) => track.audioData.isNotNull())
          ..orderBy([(track) => OrderingTerm.asc(track.lastAccessedAt)]))
        .get();
    var total = rows.fold<int>(0, (sum, row) => sum + row.storedBytes);
    for (final row in rows) {
      if (total <= maxStoredBytes) break;
      total -= row.storedBytes;
      await (_db.update(_db.audioTracks)
            ..where((track) => track.sourceUrl.equals(row.sourceUrl)))
          .write(const AudioTracksCompanion(
        audioData: Value(null),
        compression: Value(null),
        originalBytes: Value(0),
        storedBytes: Value(0),
      ));
    }
  }
}
