import 'dart:convert';

String _firstText(Iterable<dynamic> values) {
  for (final value in values) {
    if (value is Iterable) {
      final nested = _firstText(value);
      if (nested.isNotEmpty) return nested;
      continue;
    }
    if (value == null || value is Map) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return '';
}

String _withoutAudioExtension(String value) => value.replaceFirst(
      RegExp(r'\.(mp3|m4a|aac|flac|wav|ogg|opus|wma)$', caseSensitive: false),
      '',
    );

Map<String, dynamic> _allAudioMetadata(Map<String, dynamic> payload) {
  final result = <String, dynamic>{};

  void extract(Map<dynamic, dynamic> map) {
    map.forEach((k, v) {
      final keyStr = k.toString().toLowerCase();
      result[keyStr] = v;
      if (v is Map) {
        extract(v);
      } else if (v is String && v.trim().startsWith('{')) {
        try {
          final decoded = jsonDecode(v);
          if (decoded is Map) extract(decoded);
        } catch (_) {}
      }
    });
  }

  extract(payload);
  return result;
}

String audioTrackTitle(Map<String, dynamic> payload, String fileName) {
  final metadata = _allAudioMetadata(payload);
  final title = _firstText([
    metadata['track_title'],
    metadata['audio_title'],
    metadata['title'],
  ]);
  if (title.isNotEmpty) return title;

  final clean = _withoutAudioExtension(fileName).trim();
  return clean.isNotEmpty ? clean : fileName;
}

String audioTrackArtist(Map<String, dynamic> payload, String fileName) {
  final metadata = _allAudioMetadata(payload);
  final artist = _firstText([
    metadata['artist'],
    metadata['performer'],
    metadata['track_artist'],
    metadata['audio_artist'],
    metadata['album_artist'],
  ]);
  return artist;
}

int audioTrackDuration(Map<String, dynamic> payload) {
  final metadata = _allAudioMetadata(payload);
  final raw = metadata['duration'] ??
      metadata['audio_duration'] ??
      metadata['length'] ??
      metadata['track_duration'] ??
      payload['duration'] ??
      payload['audio_duration'] ??
      payload['length'] ??
      payload['audio_metadata']?['duration'] ??
      payload['metadata']?['duration'];
  if (raw is num) {
    if (raw > 10000) {
      return (raw / 1000).round();
    }
    return raw.toInt();
  }
  if (raw is String) {
    final parsed = double.tryParse(raw);
    if (parsed != null) {
      if (parsed > 10000) return (parsed / 1000).round();
      return parsed.toInt();
    }
  }
  return 0;
}

String? audioTrackCoverUri(Map<String, dynamic> payload) {
  final metadata = _allAudioMetadata(payload);
  final cover = _firstText([
    metadata['cover_url'],
    metadata['cover'],
    metadata['artwork_url'],
    metadata['artwork'],
    metadata['image_url'],
    metadata['image'],
    metadata['album_art'],
    payload['cover_url'],
    payload['artwork_url'],
  ]);
  if (cover.isNotEmpty) return cover;
  return null;
}
