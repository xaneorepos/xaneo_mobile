import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/services/language_pack_validator.dart';

void main() {
  late Map<String, dynamic> manifest;
  const corpusDirPath = '/home/xaneodev/xaneomain/localization/test_corpus';
  const manifestPath = '/home/xaneodev/xaneomain/localization/schema/manifest.v1.json';

  setUpAll(() {
    final manifestFile = File(manifestPath);
    expect(manifestFile.existsSync(), isTrue);
    manifest = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
  });

  group('LanguagePackValidator Test Corpus (Mobile)', () {
    final expectedResults = <String, Map<String, dynamic>>{
      'valid-minimal.json': {'valid': true},
      'valid-rtl.json': {'valid': true},
      'missing-keys.json': {'valid': true},
      'unknown-key.json': {'valid': true, 'hasWarning': 'UNKNOWN_KEY'},
      'wrong-placeholder.json': {'valid': false, 'error': 'INVALID_PLACEHOLDER'},
      'missing-placeholder.json': {'valid': false, 'error': 'INVALID_PLACEHOLDER'},
      'malformed-icu.json': {'valid': false, 'error': 'INVALID_PLACEHOLDER'},
      'duplicate-key.json': {'valid': false, 'error': 'JSON_PARSE_ERROR'},
      'oversized-string.json': {'valid': false, 'error': 'OVERSIZED_STRING'},
      'oversized-pack.json': {'valid': false, 'error': 'JSON_PARSE_ERROR'},
      'control-chars.json': {'valid': false},
      'bad-locale.json': {'valid': false, 'error': 'INVALID_LOCALE'},
      'bad-direction.json': {'valid': false, 'error': 'INVALID_DIRECTION'},
      'bad-fallback-locale.json': {'valid': false, 'error': 'INVALID_FALLBACK_LOCALE'},
      'custom-pack-as-fallback.json': {'valid': false, 'error': 'INVALID_FALLBACK_LOCALE'},
      'explicit-russian-fallback.json': {'valid': true},
      'explicit-chinese-fallback.json': {'valid': true},
      'html-as-text.json': {'valid': true},
    };

    for (final entry in expectedResults.entries) {
      final filename = entry.key;
      final expected = entry.value;

      test('validates $filename correctly', () {
        final file = File('$corpusDirPath/$filename');
        expect(file.existsSync(), isTrue);

        final raw = file.readAsStringSync();
        final result = LanguagePackValidator.validate(raw, manifest);

        expect(result.isValid, equals(expected['valid']),
            reason: 'isValid mismatch for $filename (errors: ${result.errors})');

        if (expected.containsKey('error')) {
          expect(result.errors.any((e) => e.code == expected['error']), isTrue,
              reason: 'Expected error ${expected['error']} in ${result.errors}');
        }

        if (expected.containsKey('hasWarning')) {
          expect(result.warnings.any((w) => w.code == expected['hasWarning']), isTrue,
              reason: 'Expected warning ${expected['hasWarning']} in ${result.warnings}');
        }
      });
    }
  });
}
