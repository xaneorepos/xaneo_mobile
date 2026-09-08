import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/widgets/common/blur_hash_placeholder.dart';

void main() {
  test('decodes a valid blurhash into RGBA pixels', () {
    final pixels = decodeBlurHash(
      r'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
      width: 24,
      height: 16,
    );

    expect(pixels.length, 24 * 16 * 4);
    for (var index = 3; index < pixels.length; index += 4) {
      expect(pixels[index], 255);
    }
  });

  test('rejects malformed blurhashes', () {
    expect(
      () => decodeBlurHash('invalid', width: 8, height: 8),
      throwsFormatException,
    );
  });
}
