import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/utils/audio_metadata.dart';

void main() {
  test('reads title and artist from nested audio metadata', () {
    final payload = <String, dynamic>{
      'metadata': {
        'common': {
          'title': 'Night Drive',
          'artist': ['Xaneo'],
        },
      },
    };

    expect(audioTrackTitle(payload, 'track.mp3'), 'Night Drive');
    expect(audioTrackArtist(payload, 'track.mp3'), 'Xaneo');
  });

  test('extracts duration from payload metadata', () {
    final payload = <String, dynamic>{
      'duration': 185,
    };
    expect(audioTrackDuration(payload), 185);

    final nestedPayload = <String, dynamic>{
      'metadata': {
        'audio_metadata': {
          'duration': '210.5',
        },
      },
    };
    expect(audioTrackDuration(nestedPayload), 210);
  });

  test('falls back to clean file name for title and empty artist without metadata', () {
    const payload = <String, dynamic>{};

    expect(audioTrackTitle(payload, 'Xaneo — Night Drive.mp3'), 'Xaneo — Night Drive');
    expect(audioTrackArtist(payload, 'Xaneo — Night Drive.mp3'), '');
    expect(audioTrackDuration(payload), 0);
  });
}
