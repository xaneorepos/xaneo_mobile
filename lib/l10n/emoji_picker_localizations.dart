import 'package:flutter/widgets.dart';

import '../services/runtime_translations.dart';

/// Copy for the emoji picker. Custom language packs use the same canonical keys.
class EmojiPickerLocalizations {
  EmojiPickerLocalizations._(this._languageCode);

  final String _languageCode;

  static EmojiPickerLocalizations of(BuildContext context) =>
      EmojiPickerLocalizations._(Localizations.localeOf(context).languageCode);

  static const _languages = <String>[
    'ru',
    'en',
    'fr',
    'es',
    'zh',
    'ja',
    'ko',
    'ar',
  ];
  static const _strings = <String, List<String>>{
    "messenger.emoji.title": [
      "Эмодзи",
      "Emoji",
      "Émojis",
      "Emojis",
      "表情符号",
      "絵文字",
      "이모지",
      "الرموز التعبيرية",
    ],
    "messenger.emoji.closePanel": [
      "Закрыть панель эмодзи",
      "Close emoji picker",
      "Fermer le sélecteur d’émojis",
      "Cerrar el selector de emojis",
      "关闭表情符号面板",
      "絵文字パネルを閉じる",
      "이모지 선택기 닫기",
      "إغلاق لوحة الرموز التعبيرية",
    ],
    "messenger.emoji.close": [
      "Закрыть",
      "Close",
      "Fermer",
      "Cerrar",
      "关闭",
      "閉じる",
      "닫기",
      "إغلاق",
    ],
    "messenger.emoji.searchPlaceholder": [
      "Поиск эмодзи...",
      "Search emoji...",
      "Rechercher un émoji...",
      "Buscar emojis...",
      "搜索表情符号...",
      "絵文字を検索...",
      "이모지 검색...",
      "البحث عن رمز تعبيري...",
    ],
    "messenger.emoji.recentEmpty": [
      "Недавние эмодзи появятся здесь",
      "Recently used emoji will appear here",
      "Les émojis récents apparaîtront ici",
      "Los emojis recientes aparecerán aquí",
      "最近使用的表情符号会显示在这里",
      "最近使用した絵文字がここに表示されます",
      "최근 사용한 이모지가 여기에 표시됩니다",
      "ستظهر الرموز التعبيرية المستخدمة مؤخرًا هنا",
    ],
    "messenger.emoji.notFound": [
      "Ничего не найдено",
      "Nothing found",
      "Aucun résultat",
      "No se encontraron resultados",
      "未找到结果",
      "見つかりませんでした",
      "검색 결과가 없습니다",
      "لم يتم العثور على نتائج",
    ],
    "messenger.emoji.category.recent": [
      "Недавние",
      "Recent",
      "Récents",
      "Recientes",
      "最近使用",
      "最近使ったもの",
      "최근 사용",
      "الأخيرة",
    ],
    "messenger.emoji.category.smileys": [
      "Смайлы",
      "Smileys",
      "Smileys",
      "Caritas",
      "笑脸",
      "スマイリー",
      "스마일",
      "الوجوه التعبيرية",
    ],
    "messenger.emoji.category.people": [
      "Люди",
      "People",
      "Personnes",
      "Personas",
      "人物",
      "人物",
      "사람",
      "الأشخاص",
    ],
    "messenger.emoji.category.animals": [
      "Животные",
      "Animals",
      "Animaux",
      "Animales",
      "动物",
      "動物",
      "동물",
      "الحيوانات",
    ],
    "messenger.emoji.category.food": [
      "Еда",
      "Food",
      "Nourriture",
      "Comida",
      "食物",
      "食べ物",
      "음식",
      "الطعام",
    ],
    "messenger.emoji.category.activities": [
      "Активности",
      "Activities",
      "Activités",
      "Actividades",
      "活动",
      "アクティビティ",
      "활동",
      "الأنشطة",
    ],
    "messenger.emoji.category.travel": [
      "Путешествия",
      "Travel",
      "Voyages",
      "Viajes",
      "旅行",
      "旅行",
      "여행",
      "السفر",
    ],
    "messenger.emoji.category.objects": [
      "Объекты",
      "Objects",
      "Objets",
      "Objetos",
      "物品",
      "物",
      "사물",
      "الأشياء",
    ],
    "messenger.emoji.category.symbols": [
      "Символы",
      "Symbols",
      "Symboles",
      "Símbolos",
      "符号",
      "記号",
      "기호",
      "الرموز",
    ],
    "messenger.emoji.category.flags": [
      "Флаги",
      "Flags",
      "Drapeaux",
      "Banderas",
      "旗帜",
      "旗",
      "깃발",
      "الأعلام",
    ],
  };

  String text(String key) {
    final values = _strings[key];
    if (values == null) return key;
    final runtime = RuntimeTranslations.instance;
    final language = runtime.hasActiveCustomPack
        ? runtime.fallbackLocale
        : _languageCode;
    final index = _languages.indexOf(language);
    final fallback = values[index < 0 ? 1 : index];
    return runtime.containsKey(key)
        ? runtime.get(key, fallback: fallback)
        : fallback;
  }
}
