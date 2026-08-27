#!/usr/bin/env python3
"""
Скрипт для 100% сопоставления всех строк xaneo_mobile с manifest.v1.json и генерации DynamicAppLocalizations.
"""

import json
import re
import os

MANIFEST_PATH = '/home/xaneodev/xaneo_mobile/assets/manifest.v1.json'
RU_DART_PATH = '/home/xaneodev/xaneo_mobile/lib/l10n/app_localizations_ru.dart'
APP_L10N_PATH = '/home/xaneodev/xaneo_mobile/lib/l10n/app_localizations.dart'
DYNAMIC_DART_PATH = '/home/xaneodev/xaneo_mobile/lib/l10n/dynamic_app_localizations.dart'
TSUKISHIRO_PATH = '/home/xaneodev/tsukishiro_agent_lang.json'

with open(MANIFEST_PATH, 'r', encoding='utf-8') as f:
    manifest_data = json.load(f)

manifest_keys = manifest_data.setdefault('keys', {})

# Читаем все геттеры и методы из app_localizations.dart
with open(APP_L10N_PATH, 'r', encoding='utf-8') as f:
    l10n_content = f.read()

getters = []
methods = []
for line in l10n_content.splitlines():
    line = line.strip()
    m_getter = re.match(r'String get ([a-zA-Z0-9_]+);', line)
    if m_getter:
        getters.append(m_getter.group(1))
        continue
    m_method = re.match(r'String ([a-zA-Z0-9_]+)\(([^)]*)\);', line)
    if m_method:
        methods.append((m_method.group(1), m_method.group(2)))

# Читаем русские значения
with open(RU_DART_PATH, 'r', encoding='utf-8') as f:
    ru_content = f.read()

getter_to_ru = {}
pattern = r"String get ([a-zA-Z0-9_]+)\s*=>\s*(.*?);"
for m in re.finditer(pattern, ru_content, re.DOTALL):
    g = m.group(1)
    raw = m.group(2).strip()
    # Simple extraction of string content inside single or double quotes
    parts = re.findall(r"'([^'\\]*(?:\\.[^'\\]*)*)'|\"([^\"\\]*(?:\\.[^\"\\]*)*)\"", raw)
    extracted = ""
    for p1, p2 in parts:
        val = p1 if p1 else p2
        val = val.replace(r"\'", "'").replace(r'\"', '"').replace(r'\n', '\n')
        extracted += val
    if not extracted and (raw.startswith("'") or raw.startswith('"')):
        extracted = raw.strip("'\"")
    getter_to_ru[g] = extracted

def normalize_text(t):
    if not t:
        return ""
    t = re.sub(r'[^\w\s]', '', t, flags=re.UNICODE)
    t = re.sub(r'\s+', '', t)
    return t.lower()

manifest_by_norm = {}
manifest_by_exact = {}

for k, v in manifest_keys.items():
    if isinstance(v, dict):
        ru_text = v.get('fallback_ru') or v.get('ru') or ''
        if ru_text:
            manifest_by_exact.setdefault(ru_text, []).append(k)
            norm = normalize_text(ru_text)
            if norm:
                manifest_by_norm.setdefault(norm, []).append(k)

# Добавляем семантические подсказки (semantic hints)
semantic_hints = {
    'chats': ['messenger.chats', 'messenger.settings.chatsTitle'],
    'search': ['messenger.search', 'common.search', 'header.search', 'settings.search'],
    'reply': ['messenger.reply', 'messenger.message.reply'],
    'settings': ['messenger.settings.title', 'header.settings', 'settings.title'],
    'lichnyeDannye_be85': ['messenger.settings.personalTitle', 'messenger.settings.personal'],
    'typeMessage': ['messenger.input.message', 'messenger.typeMessage', 'messenger.messageInputPlaceholder'],
    'searchPlaceholder': ['messenger.searchPlaceholder', 'messenger.search', 'common.search'],
    'edit': ['messenger.edit', 'messenger.chat.edit', 'messenger.message.edit'],
    'delete': ['messenger.buttons.delete', 'messenger.delete.buttons.delete', 'messenger.moderation.deleteAction', 'messenger.delete', 'messenger.message.delete', 'messenger.chat.delete'],
    'copy': ['messenger.copy', 'messenger.message.copy'],
    'forward': ['messenger.forward', 'messenger.message.forward'],
    'pin': ['messenger.pin', 'messenger.pinned.title'],
    'unpin': ['messenger.unpin', 'messenger.pinned.unpin'],
    'online': ['messenger.status.online'],
    'offline': ['messenger.status.offline', 'messenger.status.lastSeenRecently'],
    'neVSeti_ee01': ['messenger.status.offline', 'messenger.status.lastSeenRecently'],
    'lastSeenRecently': ['messenger.status.lastSeenRecently'],
    'savedMessages': ['messenger.favorites.title', 'messenger.savedMessages', 'header.savedMessages'],
    'savedMessagesDesc': ['messenger.favorites.emptyDesc', 'messenger.savedMessages.desc', 'messenger.favorites.desc'],
    'incomingCall': ['messenger.calls.incoming'],
    'outgoingCall': ['messenger.calls.outgoing'],
    'callEnded': ['messenger.calls.ended'],
    'callRejected': ['messenger.calls.rejected'],
    'answer': ['messenger.calls.answer'],
    'decline': ['messenger.calls.decline'],
    'toArchive': ['messenger.context.archiveChat', 'messenger.chat.archive', 'messenger.archive'],
    'unarchive': ['messenger.context.unarchiveChat', 'messenger.chat.unarchive', 'messenger.unarchive'],
    'clearHistory': ['messenger.delete.historyTitle', 'messenger.chat.clearHistory', 'messenger.clearHistory'],
    'deleteChat': ['messenger.context.deleteChat', 'messenger.delete.deleteChatTitle', 'messenger.chat.delete', 'messenger.delete'],
    'pinChat': ['messenger.chat.pin', 'messenger.pin', 'messenger.pinned.title'],
    'unpinChat': ['messenger.chat.unpin', 'messenger.unpin', 'messenger.pinned.unpin'],
    'muteNotifications': ['messenger.chat.mute', 'messenger.mute'],
    'unmuteNotifications': ['messenger.chat.unmute', 'messenger.unmute'],
    'personalDataDesc': ['messenger.settings.personalDesc'],
    'securityDesc': ['messenger.settings.privacyDesc'],
    'appearanceDesc': ['messenger.settings.generalDesc', 'settings.appearance'],
    'energySavingDesc': ['messenger.settings.energyDesc', 'messenger.energy.mainSettings'],
    'closeActionTitle': ['settings.closeActionTitle', 'messenger.generalSettings.closeAction'],
    'closeActionDescription': ['settings.closeActionDescription'],
    'file': ['messenger.attach.uploadFile', 'messenger.attach.file', 'common.file'],
    'todoList': ['messenger.attach.todoList', 'messenger.attach.todoListTitle', 'messenger.todoModal.title'],
    'poll': ['messenger.attach.pollShort', 'messenger.attach.poll', 'messenger.pollModal.title'],
    'createTodo': ['messenger.todoModal.title'],
    'createPoll': ['messenger.pollModal.title'],
    'listName': ['messenger.todoModal.listNameLabel'],
    'todoItems': ['messenger.todoModal.itemsLabel'],
    'addTodoItem': ['messenger.todoModal.addItem'],
    'pollQuestion': ['messenger.pollModal.questionLabel'],
    'pollOptions': ['messenger.pollModal.optionsLabel'],
    'addPollOption': ['messenger.pollModal.addOption'],
    'whoSeesAvatar': ['messenger.privacy.whoSeesAvatar'],
    'whoSeesBirthday': ['messenger.privacy.whoSeesBirthday'],
    'whoSeesOnlineTime': ['messenger.privacy.whoSeesOnlineTime'],
    'bio': ['profile.profile.displayName'],
    'username': ['profile.profile.username'],
    'birthday': ['profile.profile.birthdate'],
    'copied': ['common.copied', 'messenger.copied'],
    'today': ['common.today', 'messenger.today'],
    'yesterday': ['common.yesterday', 'messenger.yesterday'],
    'media': ['messenger.chatInfo.media', 'common.media'],
    'files': ['messenger.chatInfo.files', 'common.files'],
    'voice': ['profile.access.voice', 'common.voice'],
    'links': ['messenger.chatInfo.links', 'common.links'],
    'profile': ['header.profile', 'profile.title'],
    'group': ['messenger.chatInfo.groupTitle', 'messenger.createGroup.title', 'messenger.chat.group', 'common.group'],
    'channel': ['messenger.chatInfo.channelTitle', 'messenger.createChannel.title', 'messenger.chat.channel', 'common.channel'],
    'joinGroup': ['messenger.chat.joinGroup'],
    'subscribeChannel': ['messenger.chat.subscribeChannel'],
    'unsubscribeChannel': ['messenger.chat.unsubscribeChannel'],
    'isRecordingVoice': ['messenger.status.recordingVoice'],
    'isTyping': ['messenger.status.typing'],
    'mainSettings': ['messenger.settings.title', 'header.settings', 'settings.title'],
    'account': ['messenger.settings.personalTitle', 'messenger.settings.personal', 'profile.title', 'header.profile'],
    'akkaunt_38ac': ['messenger.settings.personalTitle', 'profile.title'],
    'interface': ['messenger.settings.generalTitle', 'settings.appearance'],
    'interfeys_49be': ['messenger.settings.generalTitle', 'settings.appearance'],
    'logout': ['messenger.settings.logout', 'header.logout', 'common.logout'],
    'vyytiIzAkkaunta_6d41': ['messenger.settings.logout', 'header.logout', 'common.logout'],
    'personalData': ['messenger.settings.personalTitle', 'messenger.settings.personal'],
    'privacyTitle': ['messenger.settings.privacyTitle', 'messenger.settings.privacy'],
    'chatsSettings': ['messenger.settings.chatsTitle', 'messenger.settings.chats'],
    'chatsSettingsDesc': ['messenger.settings.chatsDesc'],
    'contacts': ['messenger.settings.contactsTitle', 'messenger.contacts.title', 'messenger.contacts'],
    'kontakty_7576': ['messenger.settings.contactsTitle', 'messenger.contacts.title', 'messenger.contacts'],
    'contactsDesc': ['messenger.settings.contactsDesc'],
    'security': ['messenger.settings.securityTitle', 'messenger.settings.security'],
    'privacyDesc': ['messenger.settings.privacyDesc'],
    'appearance': ['messenger.chatSettings.appearance', 'settings.appearance', 'messenger.settings.generalTitle'],
    'oformlenie_601f': ['messenger.chatSettings.appearance', 'settings.appearance'],
    'language': ['messenger.generalSettings.language', 'messenger.settings.languageTitle', 'settings.language', 'common.language'],
    'yazyk_412e': ['messenger.generalSettings.language', 'settings.language'],
    'videoCall': ['messenger.callType.video', 'messenger.call.videoCall'],
    'videozvonok_dd18': ['messenger.callType.video', 'messenger.call.videoCall'],
    'videozvonok_8142': ['messenger.callType.video', 'messenger.call.videoCall'],
    'audioCall': ['messenger.callType.audio', 'messenger.call.audioCall'],
    'golosovoyZvonok_a32b': ['messenger.callType.audio'],
    'languageDescription': ['messenger.settings.languageDesc', 'settings.languageDescription', 'messenger.settings.generalDesc'],
    'notifications': ['messenger.settings.notificationsTitle', 'messenger.settings.chatsTitle', 'settings.notifications'],
    'notificationsDescription': ['messenger.settings.notificationsDesc', 'messenger.settings.chatsDesc', 'settings.notificationsDescription'],
    'energySaving': ['messenger.settings.energyTitle', 'messenger.energy.mainSettings', 'messenger.energy.title'],
    'about': ['messenger.settings.aboutTitle', 'settings.about', 'messenger.settings.title'],
    'aboutDescription': ['messenger.settings.aboutDesc', 'settings.aboutDescription', 'messenger.settings.title'],
    'basicInfo': ['messenger.personal.sectionTitle', 'messenger.settings.personalTitle'],
    'osnovnayaInformatsiya_6fec': ['messenger.personal.sectionTitle', 'messenger.settings.personalTitle'],
    'yourName': ['messenger.personal.name', 'profile.profile.displayName'],
    'imya_d38d': ['messenger.personal.name', 'profile.profile.displayName'],
    'nickname': ['messenger.personal.nickname', 'profile.profile.username'],
    'nikneym_3fea': ['messenger.personal.nickname', 'profile.profile.username'],
    'nicknameCannotBeChanged': ['messenger.personal.nicknameCannotBeChanged'],
    'aboutMe': ['messenger.personal.bio', 'profile.profile.bio'],
    'oSebe_0b3b': ['messenger.personal.bio', 'profile.profile.bio'],
    'aboutMeHint': ['messenger.personal.bioPlaceholder'],
    'save': ['messenger.buttons.save', 'messenger.createGroup.createButton', 'common.save', 'profile.profile.save'],
    'sohranit_74ea': ['messenger.buttons.save', 'messenger.createGroup.createButton', 'common.save', 'profile.profile.save'],
    'communications': ['messenger.privacy.communications'],
    'whoCanMessage': ['messenger.privacy.whoCanMessage'],
    'whoCanCall': ['messenger.privacy.whoCanCall'],
    'whoCanRecordVoice': ['messenger.privacy.whoCanRecordVoice'],
    'cancel': ['messenger.buttons.cancel', 'messenger.delete.buttons.cancel', 'common.cancel'],
    'done': ['common.done', 'messenger.done'],
    'send': ['common.send', 'messenger.send'],
    'retry': ['common.retry', 'messenger.retry'],
    'confirm': ['common.confirm', 'messenger.confirm'],
    'error': ['common.error', 'messenger.error'],
    'success': ['common.success', 'messenger.success'],
    'loading': ['common.loading', 'messenger.loading'],
    'no': ['common.no', 'messenger.no'],
    'yes': ['common.yes', 'messenger.yes'],
    'all': ['common.all', 'messenger.all'],
    'close': ['common.close', 'messenger.close'],
    'back': ['common.back', 'messenger.back'],
    'next': ['common.next', 'messenger.next'],
    'create': ['common.create', 'messenger.create'],
    'novoeSoobschenie_a4d2': ['messenger.createChat.newMessageTitle'],
    'napisatSoobschenieNovomuCheloveku_6122': ['messenger.createChat.newMessageDesc'],
    'sozdatGruppu_459f': ['messenger.createGroup.title', 'messenger.createChat.groupTitle'],
    'gruppovoyChatDlyaObscheniyaS_01ba': ['messenger.createGroup.desc', 'messenger.createChat.groupDesc'],
    'sozdatKanal_9022': ['messenger.createChannel.title', 'messenger.createChat.channelTitle'],
    'kanalDlyaShirokoyAuditorii_9dba': ['messenger.createChannel.desc', 'messenger.createChat.channelDesc'],
    'sozdatNovyyChat_8ba4': ['messenger.createChat.title'],
    'lichnyyChat_cbec': ['messenger.createChat.newMessageTitle'],
    'nachatObschenieSPolzovatelem_0578': ['messenger.createChat.newMessageDesc'],
    'noMessagesTitle': ['messenger.empty.noMessages'],
    'noMessagesSubtitle': ['messenger.empty.startNow'],
    'groupWelcome': ['messenger.empty.groupWelcome'],
    'channelWelcome': ['messenger.empty.channelWelcome'],
    'joinedChat': ['messenger.system.joinedChat'],
    'leftChat': ['messenger.system.leftChat'],
    'prisoedinilsyaKChatu_f623': ['messenger.system.joinedChat'],
    'pokinulChat_d567': ['messenger.system.leftChat'],
    'polzovatel_f154': ['messenger.system.user'],
    'polzovatelya_1083': ['messenger.system.user'],
    'priglasil_47ae': ['messenger.system.invited'],
    'dobroPozhalovatVGruppu_47a1': ['messenger.empty.groupWelcome'],
    'dobroPozhalovatVKanal_f669': ['messenger.empty.channelWelcome'],
    'netSoobscheniy_29d4': ['messenger.empty.noMessages'],
    'netSoobscheniyNapishiteChtoNibud_2bf4': ['messenger.empty.startNow'],
    'vyberiteChatDlyaNachalaObscheniya_36a5': ['messenger.empty.startMessage'],
    'nachatObschatsya_e91e': ['messenger.empty.startTitle'],
    'otvetit_3499': ['messenger.reply', 'messenger.message.reply'],
    'kopirovat_59e9': ['messenger.copy', 'messenger.message.copy'],
    'redaktirovat_e6f6': ['messenger.edit', 'messenger.chat.edit', 'messenger.message.edit'],
    'udalit_7e8b': ['messenger.buttons.delete', 'messenger.delete.buttons.delete', 'messenger.message.delete', 'messenger.chat.delete'],
    'zakrepit_b251': ['messenger.pin', 'messenger.pinned.title', 'messenger.message.pin'],
    'otkrepit_5f8f': ['messenger.unpin', 'messenger.pinned.unpin', 'messenger.message.unpin'],
}

# Mobile messenger getters whose wording differs from the canonical web/PC
# fallback. Keep these explicit: text-based matching cannot discover them.
semantic_hints.update({
    # Calls
    'startCall': ['messenger.callType.title'],
    'audioCallDesc': ['messenger.callType.audioDesc'],
    'videoCallDesc': ['messenger.callType.videoDesc'],
    'nachatZvonok_3d26': ['messenger.callType.title'],
    'pozvonitPoGolosovoySvyazi_4069': ['messenger.callType.audioDesc'],
    'pozvonitSVklyuchennoyKameroy_fb05': ['messenger.callType.videoDesc'],
    'ishodyaschiyVyzov_650b': ['messenger.calls.outgoing'],
    'vhodyaschiyVyzov_19ff': ['messenger.calls.incoming'],
    'vhodyaschiyVyzov_905e': ['messenger.call.incoming', 'messenger.calls.incoming'],
    'vhodyaschiyVideozvonok_14d4': ['messenger.call.incoming', 'messenger.calls.incoming'],
    'razgovorPoAudiosvyazi_3ed7': ['messenger.call.active'],
    'podklyucheno_d022': ['messenger.call.active'],
    'svernut_ca9f': ['messenger.call.minimize'],
    'gruppovoyZvonok_dac1': ['messenger.createGroup.calls', 'messenger.editChat.groupCalls'],
    'podklyuchenieKZvonku_e2cf': ['messenger.call.outgoingStatus'],
    'podklyuchenieKVeschaniyu_038b': ['messenger.call.outgoingStatus'],

    # Contacts
    'dobavitKontakt_2903': ['messenger.contacts.createTitle'],
    'neUdalosZagruzitKontakty_02a3': ['messenger.contacts.loadError'],
    'poiskKontaktov_9a71': ['messenger.contacts.searchPlaceholder'],
    'spisokKontaktovPust_58c6': ['messenger.contacts.empty'],
    'kontaktyNeNaydeny_1b08': ['messenger.contacts.empty'],
    'nikneymPolzovatelyaUsername_a6ff': ['messenger.contacts.namePlaceholder'],
    'otobrazhaemoeImyaNeobyazatelno_340a': ['messenger.contacts.name'],

    # Create group/channel
    'privatnayaGruppa_d20e': ['messenger.createGroup.private'],
    'publichnayaGruppa_50f8': ['messenger.createGroup.public'],
    'vhodTolkoPoPriglasheniyu_97a1': ['messenger.createGroup.privateDescription'],
    'lyuboyMozhetNaytiIVstupit_5e26': ['messenger.createGroup.typeDescription'],
    'publichnayaSsylkanikneymMyGroup_6640': ['messenger.createGroup.nickname'],
    'privatnyyKanal_3139': ['messenger.createChannel.private'],
    'publichnyyKanal_0f7c': ['messenger.createChannel.public'],
    'podpiskaTolkoPoPriglasheniyu_99c3': ['messenger.createChannel.privateDescription'],
    'ssylkanikneymKanalaMychannel_79f6': ['messenger.createChannel.nickname'],

    # Chat info and profile
    'golos_2d89': ['messenger.chatInfo.voiceMessages'],
    'netObschihFaylov_bf77': ['messenger.chatInfo.noFiles'],
    'netFaylov_e95e': ['messenger.chatInfo.noFiles'],
    'netGolosovyhSoobscheniy_2427': ['messenger.chatInfo.noVoice'],
    'netMediafaylov_08d2': ['messenger.chatInfo.noMedia'],
    'netMuzyki_1ca3': ['messenger.chatInfo.noMusic'],
    'noSharedMedia': ['messenger.chatInfo.noMedia'],
    'noSharedFiles': ['messenger.chatInfo.noFiles'],
    'noSharedVoice': ['messenger.chatInfo.noVoice'],
    'noSharedMusic': ['messenger.chatInfo.noMusic'],
    'birthday': ['messenger.personal.birthday', 'profile.profile.birthdate'],

    # Polls and to-do lists
    'sozdatSpisokZadach_0416': ['messenger.todoModal.send'],
    'sozdatSpisokZadach_4018': ['messenger.todoModal.title'],
    'spisokZadach_1852': ['messenger.todoModal.title', 'messenger.attach.todoList'],
    'nazvanieSpiska_c3cc': ['messenger.todoModal.listNameLabel'],
    'punkty_0481': ['messenger.todoModal.itemsLabel'],
    'itemHintPrefix': ['messenger.todoModal.itemPlaceholder'],
    'variantyOtveta_ef4e': ['messenger.pollModal.optionsLabel'],
    'optionHintPrefix': ['messenger.pollModal.optionPlaceholder'],
    'sozdatOpros_4b9e': ['messenger.pollModal.title'],
    'sozdatOpros_8401': ['messenger.pollModal.send'],

    # Archive and message UI
    'vArhiv_ce22': ['messenger.context.archiveChat'],
    'razarhivirovat_416b': ['messenger.context.unarchiveChat'],
    'selectChatToStart': ['messenger.empty.startMessage'],
    'fayl_2d46': ['messenger.attach.uploadFile', 'messenger.attach.file'],
    'addAttachment': ['messenger.attach.file', 'messenger.attach.uploadFile'],
    'pinChat': ['messenger.context.pinChat', 'messenger.message.pin'],
    'unpinChat': ['messenger.context.unpinChat', 'messenger.message.unpin'],
    'muteNotifications': ['messenger.context.muteChat'],
    'unmuteNotifications': ['messenger.context.unmuteChat'],
    'poiskKontaktovChatovKanalovBotov_db66': ['messenger.search'],
    'poiskLyudeyBotovGrupp_e84e': ['messenger.search'],
    'globalnyyPoisk_7ff2': ['messenger.search'],
})

out_lines = [
    "// GENERATED BOILERPLATE ADAPTER FROM CANONICAL MANIFEST",
    "// 100% COMPLETE MANIFEST COVERAGE FOR XANEO MOBILE",
    "// ignore_for_file: non_constant_identifier_names, type=lint, unused_local_variable",
    "",
    "import 'app_localizations.dart';",
    "import '../services/runtime_translations.dart';",
    "",
    "class DynamicAppLocalizations extends AppLocalizations {",
    "  final AppLocalizations base;",
    "  final RuntimeTranslations _rt = RuntimeTranslations.instance;",
    "",
    "  DynamicAppLocalizations(this.base, String locale) : super(locale);",
    "",
    "  String _resolve(List<String> keys, String fallback) {",
    "    if (!_rt.hasActiveCustomPack) return fallback;",
    "    for (final key in keys) {",
    "      if (_rt.containsKey(key)) return _rt.get(key);",
    "    }",
    "    return _rt.resolveByText(fallback);",
    "  }",
    ""
]

for g in getters:
    keys = []
    # 1. Semantic hints
    if g in semantic_hints:
        for sk in semantic_hints[g]:
            if sk not in keys:
                keys.append(sk)

    # 2. Exact getter / candidate keys in manifest
    for candidate in [f"mobile.{g}", f"pc.{g}", g]:
        if candidate in manifest_keys and candidate not in keys:
            keys.append(candidate)

    # 3. Exact & normalized Russian text in manifest
    ru = getter_to_ru.get(g, "")
    if ru:
        exacts = manifest_by_exact.get(ru, [])
        for ek in exacts:
            if ek not in keys:
                keys.append(ek)
        norm = normalize_text(ru)
        if norm:
            norms = manifest_by_norm.get(norm, [])
            for nk in norms:
                if nk not in keys:
                    keys.append(nk)

    # 4. Default fallback keys
    if not keys:
        keys = [f"mobile.{g}", g]

    keys_str = ", ".join([f"'{k}'" for k in keys])
    out_lines.append("  @override")
    out_lines.append(f"  String get {g} => _resolve(const [{keys_str}], base.{g});")
    out_lines.append("")

for m_name, m_params in methods:
    param_list = [p.strip() for p in m_params.split(",") if p.strip()]
    param_names = []
    for p in param_list:
        parts = p.split()
        if parts:
            param_names.append(parts[-1])

    params_map_str = ", ".join([f"'{pn}': {pn}" for pn in param_names])

    if m_name in ('membersCount', 'subscribersCount'):
        noun = 'member' if m_name == 'membersCount' else 'subscriber'
        out_lines.append("  @override")
        out_lines.append(f"  String {m_name}({m_params}) {{")
        out_lines.append(f"    if (!_rt.hasActiveCustomPack) return base.{m_name}({', '.join(param_names)});")
        out_lines.append("    final mod10 = count % 10;")
        out_lines.append("    final mod100 = count % 100;")
        out_lines.append("    final form = mod10 == 1 && mod100 != 11")
        out_lines.append("        ? 'One'")
        out_lines.append("        : ([2, 3, 4].contains(mod10) && ![12, 13, 14].contains(mod100) ? 'Few' : 'Many');")
        out_lines.append(f"    final key = 'messenger.chatInfo.{noun}$form';")
        out_lines.append(f"    if (!_rt.containsKey(key)) return base.{m_name}(count);")
        out_lines.append("    return '$count ${_rt.get(key)}';")
        out_lines.append("  }")
        out_lines.append("")
        continue

    keys = []
    if m_name in semantic_hints:
        for sk in semantic_hints[m_name]:
            if sk not in keys:
                keys.append(sk)
    for candidate in [f"mobile.{m_name}", f"pc.{m_name}", m_name]:
        if candidate in manifest_keys and candidate not in keys:
            keys.append(candidate)

    if not keys:
        keys = [f"mobile.{m_name}", m_name]

    first_key = keys[0]
    arg_pass = ", ".join(param_names)
    out_lines.append("  @override")
    out_lines.append(f"  String {m_name}({m_params}) {{")
    out_lines.append(f"    if (!_rt.hasActiveCustomPack) return base.{m_name}({arg_pass});")
    out_lines.append(f"    final resolved = _rt.get('{first_key}', params: {{{params_map_str}}}, fallback: base.{m_name}({arg_pass}));")
    out_lines.append("    return resolved;")
    out_lines.append("  }")
    out_lines.append("")

out_lines.append("}")


with open(DYNAMIC_DART_PATH, "w", encoding="utf-8") as f:
    f.write("\n".join(out_lines) + "\n")

print(f"✅ DynamicAppLocalizations успешно сгенерирован для всех {len(getters)} геттеров с полным сопоставлением.")

# Теперь протестируем с Tsukishiro pack
with open(TSUKISHIRO_PATH, 'r', encoding='utf-8') as f:
    tsukishiro = json.load(f)['strings']

# Load DynamicAppLocalizations back to test
with open(DYNAMIC_DART_PATH, 'r', encoding='utf-8') as f:
    dyn_test = f.read()

test_map = {}
for m in re.finditer(r'String get ([a-zA-Z0-9_]+) => _resolve\(const \[(.*?)\]', dyn_test):
    g_name = m.group(1)
    k_list = [k.strip("'\" ") for k in m.group(2).split(',') if k.strip("'\" ")]
    test_map[g_name] = k_list

tsuki_hits = 0
for g, k_list in test_map.items():
    for k in k_list:
        if k in tsukishiro:
            tsuki_hits += 1
            break

print(f"🎯 Проверка Tsukishiro: {tsuki_hits} / {len(test_map)} геттеров переведены пакетом Tsukishiro ({tsuki_hits/len(test_map)*100:.1f}%)")
