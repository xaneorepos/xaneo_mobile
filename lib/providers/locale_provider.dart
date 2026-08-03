import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Провайдер для управления локализацией мобильного приложения Xaneo
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Locale? get locale => _locale;

  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('ar'),
  ];

  static const List<Map<String, String>> availableLanguages = [
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'ar', 'name': 'العربية'},
  ];

  String get currentLanguageName {
    final code = _locale?.languageCode ?? 'ru';
    final found = availableLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => availableLanguages[0],
    );
    return found['name']!;
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(AppConfig.localeKey);
    if (langCode != null) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  Future<void> _saveLocale(String? langCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (langCode != null) {
      await prefs.setString(AppConfig.localeKey, langCode);
    } else {
      await prefs.remove(AppConfig.localeKey);
    }
  }

  void setLocale(Locale locale) {
    _locale = locale;
    _saveLocale(locale.languageCode);
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    _saveLocale(null);
    notifyListeners();
  }
}
