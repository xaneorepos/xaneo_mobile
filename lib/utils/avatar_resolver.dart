/// Whether [avatar] is a generated SVG fallback returned by the backend.
bool isGeneratedAvatar(String avatar) {
  final normalized = avatar.trim().toLowerCase();
  if (normalized.startsWith('data:image/svg+xml')) return true;
  if (normalized.contains('/svg_avatars/')) return true;
  return normalized.split('?').first.endsWith('.svg');
}

/// Chooses an uploaded image before a generated avatar fallback.
///
/// API and WebSocket payloads may contain both `avatar` and `avatar_url`, and
/// either field can contain a generated SVG. A simple `??` then incorrectly
/// hides a real PNG/JPEG/WebP that is present in another field.
String? preferredAvatar(Iterable<Object?> candidates) {
  String? generatedFallback;

  for (final candidate in candidates) {
    final value = candidate?.toString().trim();
    if (value == null || value.isEmpty || value == 'null') continue;

    if (!isGeneratedAvatar(value)) return value;
    generatedFallback ??= value;
  }

  return generatedFallback;
}
