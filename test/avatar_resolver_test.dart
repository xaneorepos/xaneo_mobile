import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/utils/avatar_resolver.dart';

void main() {
  group('preferredAvatar', () {
    test('prefers an uploaded PNG over an earlier generated SVG', () {
      expect(
        preferredAvatar([
          'https://cdn.xaneo.ru/svg_avatars/generated.svg',
          '/media/avatars/user.png',
        ]),
        '/media/avatars/user.png',
      );
    });

    test('keeps generated avatar when no uploaded image exists', () {
      const generated = 'data:image/svg+xml;base64,PHN2Zz4=';
      expect(preferredAvatar([null, '', generated]), generated);
    });

    test('ignores empty and textual null values', () {
      expect(preferredAvatar([null, '', 'null']), isNull);
    });
  });
}
