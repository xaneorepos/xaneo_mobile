import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/message_color_presets.dart';

class AppearanceProvider extends ChangeNotifier {
  static const double minFontSize = 12;
  static const double maxFontSize = 24;
  static const double defaultFontSize = 14.5;
  static const int _maxWallpaperBytes = 5 * 1024 * 1024;
  static const int _maxWallpaperDimension = 1920;

  static const _fontSizeKey = 'appearance_chat_font_size';
  static const _wallpaperPresetKey = 'appearance_wallpaper_preset';
  static const _wallpaperPathKey = 'appearance_wallpaper_custom_path';
  static const _myColorKey = 'appearance_my_message_color';
  static const _otherColorKey = 'appearance_other_message_color';
  static const _notificationStyleKey = 'appearance_notification_style';
  static const _darkModeKey = 'mobile_dark_mode';
  static const _animationsKey = 'mobile_animations';

  double _chatFontSize = defaultFontSize;
  ChatWallpaper _wallpaper = const ChatWallpaper();
  MessageColorSetting _myMessageColor = const MessageColorSetting();
  MessageColorSetting _otherMessageColor = const MessageColorSetting();
  NotificationStyle _notificationStyle = NotificationStyle.standard;
  bool _isDarkMode = true;
  bool _animationsEnabled = true;
  bool _loaded = false;

  AppearanceProvider() {
    _load();
  }

  double get chatFontSize => _chatFontSize;
  ChatWallpaper get wallpaper => _wallpaper;
  MessageColorSetting get myMessageColor => _myMessageColor;
  MessageColorSetting get otherMessageColor => _otherMessageColor;
  NotificationStyle get notificationStyle => _notificationStyle;
  bool get isDarkMode => _isDarkMode;
  bool get animationsEnabled => _animationsEnabled;
  bool get isLoaded => _loaded;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _chatFontSize = prefs.getDouble(_fontSizeKey) ?? defaultFontSize;

    final presetName = prefs.getString(_wallpaperPresetKey);
    final preset = WallpaperPresetId.values.firstWhere(
      (value) => value.name == presetName,
      orElse: () => WallpaperPresetId.defaultWp,
    );
    _wallpaper = ChatWallpaper(
      preset: preset,
      customImagePath: prefs.getString(_wallpaperPathKey),
    );
    _myMessageColor = _decodeColor(prefs.getString(_myColorKey));
    _otherMessageColor = _decodeColor(prefs.getString(_otherColorKey));
    _notificationStyle = NotificationStyle.values.firstWhere(
      (value) => value.name == prefs.getString(_notificationStyleKey),
      orElse: () => NotificationStyle.standard,
    );
    _isDarkMode = prefs.getBool(_darkModeKey) ?? true;
    _animationsEnabled = prefs.getBool(_animationsKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  MessageColorSetting _decodeColor(String? raw) {
    if (raw == null) return const MessageColorSetting();
    try {
      return MessageColorSetting.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return const MessageColorSetting();
    }
  }

  Future<void> setChatFontSize(double value) async {
    _chatFontSize = value.clamp(minFontSize, maxFontSize);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _chatFontSize);
  }

  Future<void> setWallpaperPreset(WallpaperPresetId preset) async {
    _wallpaper = ChatWallpaper(
      preset: preset,
      customImagePath: _wallpaper.customImagePath,
    );
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wallpaperPresetKey, preset.name);
  }

  Future<void> setCustomWallpaperFromPickedFile(String pickedPath) async {
    final bytes = await File(pickedPath).readAsBytes();
    if (bytes.length > _maxWallpaperBytes) {
      throw StateError('wallpaper_too_large');
    }
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw StateError('wallpaper_decode_failed');

    final resized = decoded.width > _maxWallpaperDimension ||
            decoded.height > _maxWallpaperDimension
        ? img.copyResize(
            decoded,
            width:
                decoded.width >= decoded.height ? _maxWallpaperDimension : null,
            height:
                decoded.height > decoded.width ? _maxWallpaperDimension : null,
          )
        : decoded;
    final encoded = img.encodeJpg(resized, quality: 80);
    final supportDir = await getApplicationSupportDirectory();
    final wallpaperDir = Directory(p.join(supportDir.path, 'wallpapers'));
    await wallpaperDir.create(recursive: true);
    await _deleteCustomWallpaper();
    final destination = p.join(wallpaperDir.path, 'chat_wallpaper.jpg');
    await File(destination).writeAsBytes(encoded);

    _wallpaper = ChatWallpaper(
      preset: WallpaperPresetId.custom,
      customImagePath: destination,
    );
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wallpaperPresetKey, WallpaperPresetId.custom.name);
    await prefs.setString(_wallpaperPathKey, destination);
  }

  Future<void> removeCustomWallpaper() async {
    await _deleteCustomWallpaper();
    _wallpaper = const ChatWallpaper();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _wallpaperPresetKey, WallpaperPresetId.defaultWp.name);
    await prefs.remove(_wallpaperPathKey);
  }

  Future<void> _deleteCustomWallpaper() async {
    final path = _wallpaper.customImagePath;
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<void> setMyMessageColor(MessageColorSetting value) async {
    _myMessageColor = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_myColorKey, jsonEncode(value.toJson()));
  }

  Future<void> setOtherMessageColor(MessageColorSetting value) async {
    _otherMessageColor = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_otherColorKey, jsonEncode(value.toJson()));
  }

  Future<void> setNotificationStyle(NotificationStyle value) async {
    _notificationStyle = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationStyleKey, value.name);
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setAnimationsEnabled(bool value) async {
    if (_animationsEnabled == value) return;
    _animationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animationsKey, value);
  }
}
