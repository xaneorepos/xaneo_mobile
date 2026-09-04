import 'dart:convert';

/// Represents a single validation error or warning
class ValidationIssue {
  final String code;
  final String message;
  final String? key;

  const ValidationIssue({
    required this.code,
    required this.message,
    this.key,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        if (key != null) 'key': key,
      };

  @override
  String toString() =>
      key != null ? '[$code] ($key) $message' : '[$code] $message';
}

/// Result of language pack validation
class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> errors;
  final List<ValidationIssue> warnings;
  final Map<String, dynamic>? normalizedPack;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    this.normalizedPack,
  });
}

/// Strict validator for Custom Language Packs in Flutter
class LanguagePackValidator {
  static const Set<String> allowedFallbackLocales = {
    'ru',
    'en',
    'fr',
    'es',
    'zh',
    'ja',
    'ko',
    'ar'
  };

  static const int maxPackSizeBytes = 2 * 1024 * 1024; // 2 MiB
  static const int maxStringLength = 4096;
  static const int maxMetadataLength = 80;
  static const int maxLocaleLength = 35;

  static final RegExp controlCharsRegex =
      RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]');
  static final RegExp bidiCharsRegex = RegExp(r'[\u202A-\u202E\u2066-\u2069]');
  static final RegExp localeTagRegex =
      RegExp(r'^[a-zA-Z0-9]+([-_][a-zA-Z0-9]+)*$');
  static final RegExp placeholderRegex = RegExp(r'\{([a-zA-Z0-9_]+)\}');

  /// Parse JSON strictly detecting duplicate keys
  static Map<String, dynamic> parseStrictJson(String jsonString) {
    if (utf8.encode(jsonString).length > maxPackSizeBytes) {
      throw FormatException('Pack size exceeds maximum limit of 2 MiB');
    }

    // Duplicate key detector
    final seenKeys = <String>{};
    final keyRegex = RegExp(r'"((?:\\.|[^"\\])*)"\s*:');
    bool inStrings = false;

    for (final match in keyRegex.allMatches(jsonString)) {
      final rawKey = match.group(1);
      if (rawKey == 'strings') {
        inStrings = true;
        continue;
      }
      if (inStrings && rawKey != null) {
        if (seenKeys.contains(rawKey)) {
          throw FormatException('Duplicate key detected in JSON: "$rawKey"');
        }
        seenKeys.add(rawKey);
      }
    }

    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Root of language pack must be a JSON object');
    }
    return decoded;
  }

  /// Main validation method
  static ValidationResult validate(
    dynamic rawInput,
    Map<String, dynamic> manifest,
  ) {
    final errors = <ValidationIssue>[];
    final warnings = <ValidationIssue>[];
    Map<String, dynamic>? parsed;

    final dynamic manifestKeysRaw = manifest['keys'];
    if (manifestKeysRaw is! Map<String, dynamic>) {
      return const ValidationResult(
        isValid: false,
        errors: [
          ValidationIssue(
            code: 'INVALID_MANIFEST',
            message: 'Canonical manifest is missing or invalid',
          ),
        ],
        warnings: [],
        normalizedPack: null,
      );
    }
    final manifestKeys = manifestKeysRaw;

    // 1. Strict parsing
    try {
      if (rawInput is String) {
        parsed = parseStrictJson(rawInput);
      } else if (rawInput is Map<String, dynamic>) {
        parsed = rawInput;
      } else {
        return const ValidationResult(
          isValid: false,
          errors: [
            ValidationIssue(
              code: 'INVALID_INPUT',
              message: 'Input must be a JSON string or map',
            ),
          ],
          warnings: [],
          normalizedPack: null,
        );
      }
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: [
          ValidationIssue(
            code: 'JSON_PARSE_ERROR',
            message: e.toString(),
          ),
        ],
        warnings: [],
        normalizedPack: null,
      );
    }

    // 2. Schema version
    if (parsed['schema_version'] != 1) {
      errors.add(const ValidationIssue(
        code: 'INVALID_SCHEMA_VERSION',
        message: 'schema_version must be exactly 1',
      ));
    }

    // 3. Locale
    final dynamic locale = parsed['locale'];
    if (locale is! String ||
        locale.isEmpty ||
        locale.length > maxLocaleLength ||
        !localeTagRegex.hasMatch(locale)) {
      errors.add(const ValidationIssue(
        code: 'INVALID_LOCALE',
        message: 'locale must be a valid BCP-47 tag up to 35 chars',
      ));
    }

    // 4. Name & Native Name
    for (final field in ['name', 'native_name']) {
      final dynamic val = parsed[field];
      if (val is! String || val.trim().isEmpty) {
        errors.add(ValidationIssue(
          code: 'MISSING_${field.toUpperCase()}',
          message: '$field is required and must be a non-empty string',
        ));
      } else if (val.length > maxMetadataLength) {
        errors.add(ValidationIssue(
          code: 'OVERSIZED_${field.toUpperCase()}',
          message: '$field must not exceed $maxMetadataLength characters',
        ));
      } else if (controlCharsRegex.hasMatch(val)) {
        errors.add(ValidationIssue(
          code: 'CONTROL_CHARS_IN_${field.toUpperCase()}',
          message: '$field contains illegal control characters',
        ));
      } else if (bidiCharsRegex.hasMatch(val)) {
        errors.add(ValidationIssue(
          code: 'BIDI_CHARS_IN_${field.toUpperCase()}',
          message: '$field contains illegal bidi characters',
        ));
      }
    }

    // 5. Direction
    final dynamic direction = parsed['direction'];
    if (direction != 'ltr' && direction != 'rtl') {
      errors.add(const ValidationIssue(
        code: 'INVALID_DIRECTION',
        message: 'direction must be either "ltr" or "rtl"',
      ));
    }

    // 6. Fallback locale
    final dynamic fallbackLocale = parsed['fallback_locale'];
    if (fallbackLocale is! String ||
        !allowedFallbackLocales.contains(fallbackLocale)) {
      errors.add(ValidationIssue(
        code: 'INVALID_FALLBACK_LOCALE',
        message:
            'fallback_locale must be one of: ${allowedFallbackLocales.join(', ')}',
      ));
    }

    // 7. Strings map
    final dynamic stringsRaw = parsed['strings'];
    if (stringsRaw is! Map<String, dynamic>) {
      errors.add(const ValidationIssue(
        code: 'INVALID_STRINGS_MAP',
        message: 'strings must be a flat key-value map',
      ));
    } else {
      final normalizedStrings = <String, String>{};

      for (final entry in stringsRaw.entries) {
        final key = entry.key;
        final dynamic value = entry.value;

        if (!manifestKeys.containsKey(key)) {
          warnings.add(ValidationIssue(
            code: 'UNKNOWN_KEY',
            key: key,
            message: 'Key "$key" is not in manifest and will be ignored',
          ));
          continue;
        }

        if (value is! String) {
          errors.add(ValidationIssue(
            code: 'NON_STRING_VALUE',
            key: key,
            message: 'Value for key "$key" must be a string',
          ));
          continue;
        }

        if (value.length > maxStringLength) {
          errors.add(ValidationIssue(
            code: 'OVERSIZED_STRING',
            key: key,
            message:
                'String for key "$key" exceeds $maxStringLength characters',
          ));
          continue;
        }

        if (controlCharsRegex.hasMatch(value)) {
          errors.add(ValidationIssue(
            code: 'CONTROL_CHARACTERS',
            key: key,
            message:
                'String for key "$key" contains illegal control characters',
          ));
          continue;
        }

        final dynamic keyDef = manifestKeys[key];
        if (keyDef is Map<String, dynamic> &&
            keyDef['security_critical'] == true) {
          warnings.add(ValidationIssue(
            code: 'SECURITY_CRITICAL_OVERRIDE_IGNORED',
            key: key,
            message: 'Key "$key" is security-critical and cannot be overridden',
          ));
          continue;
        }

        // Placeholders check
        if (keyDef is Map<String, dynamic> && keyDef['placeholders'] is List) {
          final expectedList = (keyDef['placeholders'] as List).cast<String>();
          final foundList = <String>[];

          final openCount = '{'.allMatches(value).length;
          final closeCount = '}'.allMatches(value).length;
          if (openCount != closeCount) {
            errors.add(ValidationIssue(
              code: 'INVALID_PLACEHOLDER',
              key: key,
              message:
                  'Unbalanced braces (malformed placeholder/ICU syntax) in key "$key"',
            ));
            continue;
          }

          for (final m in placeholderRegex.allMatches(value)) {
            final ph = m.group(1);
            if (ph != null) foundList.add(ph);
          }

          bool phError = false;
          for (final ph in foundList) {
            if (!expectedList.contains(ph)) {
              errors.add(ValidationIssue(
                code: 'INVALID_PLACEHOLDER',
                key: key,
                message: 'Unexpected placeholder "{$ph}" for key "$key"',
              ));
              phError = true;
              break;
            }
          }
          if (phError) continue;

          for (final ph in expectedList) {
            if (!foundList.contains(ph)) {
              errors.add(ValidationIssue(
                code: 'INVALID_PLACEHOLDER',
                key: key,
                message: 'Missing required placeholder "{$ph}" for key "$key"',
              ));
              phError = true;
              break;
            }
          }
          if (phError) continue;
        }

        normalizedStrings[key] = value;
      }

      if (errors.isEmpty) {
        return ValidationResult(
          isValid: true,
          errors: const [],
          warnings: warnings,
          normalizedPack: {
            'schema_version': 1,
            'locale': locale,
            'name': parsed['name'],
            'native_name': parsed['native_name'],
            'direction': direction,
            'fallback_locale': fallbackLocale,
            'strings': normalizedStrings,
          },
        );
      }
    }

    return ValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
      normalizedPack: null,
    );
  }
}
