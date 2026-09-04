import 'dart:io';

import 'package:flutter/material.dart';

enum GradientDirection { diagonal, vertical, horizontal }

Color colorFromHex(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

String colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

class GradientSpec {
  final Color color1;
  final Color color2;
  final GradientDirection direction;

  const GradientSpec({
    required this.color1,
    required this.color2,
    this.direction = GradientDirection.diagonal,
  });

  LinearGradient toLinearGradient() {
    switch (direction) {
      case GradientDirection.vertical:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color1, color2],
        );
      case GradientDirection.horizontal:
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color1, color2],
        );
      case GradientDirection.diagonal:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        );
    }
  }

  Map<String, dynamic> toJson() => {
        'color1': colorToHex(color1),
        'color2': colorToHex(color2),
        'direction': direction.name,
      };

  factory GradientSpec.fromJson(Map<String, dynamic> json) => GradientSpec(
        color1: colorFromHex(json['color1'] as String),
        color2: colorFromHex(json['color2'] as String),
        direction: GradientDirection.values.firstWhere(
          (value) => value.name == json['direction'],
          orElse: () => GradientDirection.diagonal,
        ),
      );
}

enum WallpaperPresetId {
  defaultWp,
  blue,
  green,
  purple,
  dark,
  gradient,
  custom,
}

class ChatWallpaper {
  final WallpaperPresetId preset;
  final String? customImagePath;

  const ChatWallpaper({
    this.preset = WallpaperPresetId.defaultWp,
    this.customImagePath,
  });

  Decoration? resolveDecoration() {
    switch (preset) {
      case WallpaperPresetId.defaultWp:
        return null;
      case WallpaperPresetId.blue:
      case WallpaperPresetId.green:
      case WallpaperPresetId.purple:
      case WallpaperPresetId.gradient:
        return BoxDecoration(gradient: kWallpaperGradients[preset.name]);
      case WallpaperPresetId.dark:
        return const BoxDecoration(color: Color(0xFF1A1A1A));
      case WallpaperPresetId.custom:
        final path = customImagePath;
        if (path == null) return null;
        final file = File(path);
        if (!file.existsSync()) return null;
        return BoxDecoration(
          image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
        );
    }
  }
}

const kWallpaperGradients = <String, LinearGradient>{
  'blue': LinearGradient(
    colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  'green': LinearGradient(
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  'purple': LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  'gradient': LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
};

const kMyMessageSolidPresets = <String, Color>{
  'blue': Color(0xFF007AFF),
  'purple': Color(0xFFAF52DE),
  'orange': Color(0xFFFF9500),
};
const kMyMessageDefaultCustomSolid = Color(0xFF007E33);
const kMyMessageGradientPresets = <String, LinearGradient>{
  'gradient1': LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  'gradient2': LinearGradient(
    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
};

const kOtherMessageSolidPresets = <String, Color>{
  'dark-blue': Color(0xFF1F2937),
  'dark-green': Color(0xFF1F2D1F),
  'dark-purple': Color(0xFF2D1B38),
};
const kOtherMessageDefaultCustomSolid = Color(0xFF222222);
const kOtherMessageGradientPresets = <String, LinearGradient>{
  'gradient3': LinearGradient(
    colors: [Color(0xFF434343), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  'gradient4': LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
};

class MessageColorResolution {
  final Color? solidColor;
  final LinearGradient? gradient;

  const MessageColorResolution({this.solidColor, this.gradient});

  bool get isDefault => solidColor == null && gradient == null;
}

class MessageColorSetting {
  final String presetId;
  final Color? customSolid;
  final GradientSpec? customGradient;

  const MessageColorSetting({
    this.presetId = 'default',
    this.customSolid,
    this.customGradient,
  });

  MessageColorResolution resolve({
    required Map<String, Color> solidPresets,
    required Map<String, LinearGradient> gradientPresets,
    required Color defaultCustomSolid,
  }) {
    if (presetId == 'default') return const MessageColorResolution();
    if (presetId == 'custom') {
      return MessageColorResolution(
        solidColor: customSolid ?? defaultCustomSolid,
      );
    }
    if (presetId == 'custom-gradient') {
      final fallback = gradientPresets.values.first;
      return MessageColorResolution(
        gradient: (customGradient ??
                GradientSpec(
                  color1: fallback.colors.first,
                  color2: fallback.colors.last,
                ))
            .toLinearGradient(),
      );
    }
    if (solidPresets.containsKey(presetId)) {
      return MessageColorResolution(solidColor: solidPresets[presetId]);
    }
    if (gradientPresets.containsKey(presetId)) {
      return MessageColorResolution(gradient: gradientPresets[presetId]);
    }
    return const MessageColorResolution();
  }

  Map<String, dynamic> toJson() => {
        'presetId': presetId,
        if (customSolid != null) 'customSolid': colorToHex(customSolid!),
        if (customGradient != null) 'customGradient': customGradient!.toJson(),
      };

  factory MessageColorSetting.fromJson(Map<String, dynamic> json) =>
      MessageColorSetting(
        presetId: json['presetId'] as String? ?? 'default',
        customSolid: json['customSolid'] != null
            ? colorFromHex(json['customSolid'] as String)
            : null,
        customGradient: json['customGradient'] != null
            ? GradientSpec.fromJson(
                Map<String, dynamic>.from(json['customGradient'] as Map),
              )
            : null,
      );
}

enum NotificationStyle { standard, raven }
