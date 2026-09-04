import 'dart:io';

import 'package:flutter/material.dart';

/// Displays track artwork from either a local file or a remote URL.
///
/// [fallback] stays visible while a remote image loads and when artwork is
/// unavailable or invalid.
class TrackArtwork extends StatelessWidget {
  const TrackArtwork({
    super.key,
    required this.uri,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  final Uri? uri;
  final Widget fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final source = uri;
    if (source == null) return fallback;

    if (source.scheme == 'file' || source.scheme.isEmpty) {
      final path = source.scheme == 'file' ? source.toFilePath() : source.path;
      if (path.isEmpty) return fallback;
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    if (source.scheme == 'http' || source.scheme == 'https') {
      return Image.network(
        source.toString(),
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
            wasSynchronouslyLoaded || frame != null ? child : fallback,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return fallback;
  }
}
