import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../services/language_pack_validator.dart';
import '../services/local_language_pack_repository.dart';
import '../services/runtime_translations.dart';

/// Провайдер для управления локализацией мобильного приложения Xaneo (официальные и пользовательские языки)
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  final LocalLanguagePackRepository _packRepo = LocalLanguagePackRepository();
  List<InstalledLanguagePack> _installedPacks = [];
  InstalledLanguagePack? _activeCustomPack;

  LocaleProvider() {
    _init();
  }

  Locale? get locale => _locale;
  List<InstalledLanguagePack> get installedCustomPacks =>
      List.unmodifiable(_installedPacks);
  InstalledLanguagePack? get activeCustomPack => _activeCustomPack;
  bool get hasActiveCustomPack => _activeCustomPack != null;

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
    if (_activeCustomPack != null) {
      return _activeCustomPack!.name;
    }
    final code = _locale?.languageCode ?? 'ru';
    final found = availableLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => availableLanguages[0],
    );
    return found['name']!;
  }

  Future<void> _init() async {
    await _loadInstalledPacks();
    final activeId = await _packRepo.getActivePackId();
    if (activeId != null) {
      await activateCustomPack(activeId, notify: false);
    } else {
      await _loadLocale();
    }
    notifyListeners();
  }

  Future<void> _loadInstalledPacks() async {
    _installedPacks = await _packRepo.getInstalledPacks();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(AppConfig.localeKey);
    if (langCode != null) {
      _locale = Locale(langCode);
    } else {
      _locale = const Locale('ru');
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
    _activeCustomPack = null;
    _packRepo.setActivePackId(null);
    RuntimeTranslations.instance.setActivePack(null);

    _locale = locale;
    _saveLocale(locale.languageCode);
    notifyListeners();
  }

  void clearLocale() {
    _activeCustomPack = null;
    _packRepo.setActivePackId(null);
    RuntimeTranslations.instance.setActivePack(null);

    _locale = const Locale('ru');
    _saveLocale('ru');
    notifyListeners();
  }

  /// Activate an installed custom language pack by ID
  Future<bool> activateCustomPack(String packId, {bool notify = true}) async {
    final packContent = await _packRepo.loadPackContent(packId);
    if (packContent == null) {
      // If file missing or corrupted, revert to fallback
      await _packRepo.setActivePackId(null);
      _activeCustomPack = null;
      RuntimeTranslations.instance.setActivePack(null);
      await _loadLocale();
      if (notify) notifyListeners();
      return false;
    }

    final packMeta = _installedPacks.where((p) => p.id == packId).firstOrNull;
    _activeCustomPack = packMeta;
    await _packRepo.setActivePackId(packId);

    // Build the canonical fallback index before activating the pack. Without
    // this, resolveByText only worked immediately after importing a pack and
    // silently stopped working after a cold app restart.
    await RuntimeTranslations.instance.getManifest();
    RuntimeTranslations.instance.setActivePack(packContent);

    // Set Flutter framework locale to fallback_locale for Material widgets
    final fallback = packContent['fallback_locale'] as String? ?? 'ru';
    _locale = Locale(fallback);

    if (notify) notifyListeners();
    return true;
  }

  /// Validate a raw JSON string against the manifest
  Future<ValidationResult> validatePackJson(String jsonString) async {
    final manifest = await RuntimeTranslations.instance.getManifest();
    return LanguagePackValidator.validate(jsonString, manifest);
  }

  /// Install a validated pack and activate it
  Future<InstalledLanguagePack> installAndActivatePack(
      Map<String, dynamic> normalizedPack) async {
    final installed = await _packRepo.installPack(normalizedPack);
    await _loadInstalledPacks();
    await activateCustomPack(installed.id);
    return installed;
  }

  /// Delete an installed custom pack
  Future<void> deleteCustomPack(String packId) async {
    final wasActive = _activeCustomPack?.id == packId;
    await _packRepo.deletePack(packId);
    await _loadInstalledPacks();

    if (wasActive) {
      _activeCustomPack = null;
      RuntimeTranslations.instance.setActivePack(null);
      await _loadLocale();
    }
    notifyListeners();
  }
}
