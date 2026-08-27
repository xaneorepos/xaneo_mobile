#!/usr/bin/env python3
"""
Скрипт для 100% сопоставления всех строк xaneo_pc с manifest.v1.json и умной генерации DynamicAppLocalizations.
"""

import json
import re
import os

MANIFEST_PATH = '/home/xaneodev/xaneomain/localization/schema/manifest.v1.json'
PC_MANIFEST_PATH = '/home/xaneodev/xaneo_mobile/assets/manifest.v1.json'
RU_DART_PATH = '/home/xaneodev/xaneo_mobile/lib/l10n/app_localizations_ru.dart'
APP_L10N_PATH = '/home/xaneodev/xaneo_mobile/lib/l10n/app_localizations.dart'
DYNAMIC_DART_PATH = '/home/xaneodev/xaneo_mobile/lib/l10n/dynamic_app_localizations.dart'

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
for m in re.finditer(r'String get ([a-zA-Z0-9_]+) => (.*?);', ru_content):
    getter_name = m.group(1)
    raw_val = m.group(2).strip()
    if (raw_val.startswith("'") and raw_val.endswith("'")) or (raw_val.startswith('"') and raw_val.endswith('"')):
        val = raw_val[1:-1].encode().decode('unicode-escape')
    else:
        val = raw_val.strip("'\"")
    getter_to_ru[getter_name] = val

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
    'securityDesc': ['messenger.settings.securityDesc'],
    'logout': ['messenger.delete.buttons.leave', 'auth.logout', 'common.logout'],
    'vyytiIzAkkaunta_6d41': ['messenger.delete.buttons.leave', 'auth.logout', 'common.logout'],
    'appearance': ['messenger.settings.generalTitle', 'settings.appearance'],
    'appearanceDesc': ['messenger.settings.generalDesc'],
    'language': ['messenger.settings.generalTitle', 'messenger.generalSettings.language', 'messenger.settings.languageTitle', 'settings.language', 'common.language'],
    'languageDescription': ['messenger.settings.generalDesc', 'messenger.settings.languageDesc', 'settings.languageDescription'],
    'notifications': ['messenger.settings.chatsTitle', 'messenger.settings.notificationsTitle', 'settings.notifications'],
    'notificationsDescription': ['messenger.settings.chatsDesc', 'messenger.settings.notificationsDesc', 'settings.notificationsDescription'],
    'energySaving': ['messenger.settings.energyTitle', 'messenger.energy.mainSettings', 'messenger.energy.title'],
    'about': ['messenger.settings.aboutTitle', 'messenger.settings.title', 'settings.about'],
    'aboutDescription': ['messenger.settings.aboutDesc', 'messenger.settings.title', 'settings.aboutDescription'],
    'vashiSohranennyeKontakty_a641': ['messenger.settings.contactsDesc', 'messenger.contacts.empty'],
    'sessiiParolAutentifikatsiya_73f5': ['messenger.settings.securityDesc'],
    'temaShriftMasshtab_d8c9': ['messenger.settings.generalDesc'],
    'yazykInterfeysaKlienta_2ad3': ['messenger.settings.generalDesc', 'messenger.settings.languageDesc'],
    'zvukiBannery_1b60': ['messenger.settings.chatsDesc', 'messenger.settings.notificationsDesc'],
    'animatsiiIProizvoditelnost_fba8': ['messenger.settings.energyDesc'],
    'versiyaProverkaObnovleniySsylki_6efc': ['messenger.settings.aboutDesc', 'messenger.settings.title'],
    'basicInfo': ['messenger.personal.sectionTitle', 'messenger.settings.personalTitle'],
    'osnovnayaInformatsiya_6fec': ['messenger.personal.sectionTitle', 'messenger.settings.personalTitle'],
    'yourName': ['messenger.personal.name', 'profile.profile.displayName'],
    'imya_d38d': ['messenger.personal.name', 'profile.profile.displayName'],
    'registerStep0Subtitle': ['messenger.personal.namePlaceholder'],
    'vvediteVasheImya_751e': ['messenger.personal.namePlaceholder'],
    'nickname': ['messenger.personal.nickname', 'profile.profile.username'],
    'nikneym_3fea': ['messenger.personal.nickname', 'profile.profile.username'],
    'nicknameCannotBeChanged': ['messenger.personal.nicknameCannotBeChanged'],
    'nikneymNelzyaIzmenitVPrilozhenii_75d0': ['messenger.personal.nicknameCannotBeChanged'],
    'aboutMe': ['messenger.personal.bio', 'profile.profile.bio'],
    'oSebe_0b3b': ['messenger.personal.bio', 'profile.profile.bio'],
    'aboutMeHint': ['messenger.personal.bioPlaceholder'],
    'rasskazhiteOSebe_1c37': ['messenger.personal.bioPlaceholder'],
    'save': ['messenger.buttons.save', 'messenger.createGroup.createButton', 'common.save', 'profile.profile.save'],
    'sohranit_74ea': ['messenger.buttons.save', 'messenger.createGroup.createButton', 'common.save', 'profile.profile.save'],
    'saving': ['common.saving'],
    'sohranenie_c15f': ['common.saving'],
    'communications': ['messenger.privacy.communications'],
    'kommunikatsii_1242': ['messenger.privacy.communications'],
    'whoCanMessage': ['messenger.privacy.whoCanMessage'],
    'ktoMozhetPisatSoobscheniya_4645': ['messenger.privacy.whoCanMessage'],
    'whoCanCall': ['messenger.privacy.whoCanCall'],
    'ktoMozhetZvonit_c427': ['messenger.privacy.whoCanCall'],
    'whoCanRecordVoice': ['messenger.privacy.whoCanRecordVoice'],
    'ktoMozhetZapisyvatGolosovye_c69a': ['messenger.privacy.whoCanRecordVoice'],
    'whoCanSendFiles': ['messenger.privacy.whoCanSendFiles'],
    'ktoMozhetOtpravlyatFayly_2e40': ['messenger.privacy.whoCanSendFiles'],
    'whoCanInvite': ['messenger.privacy.whoCanInvite'],
    'ktoMozhetPriglashatVGruppy_cdc0': ['messenger.privacy.whoCanInvite'],
    'profileVisibility': ['messenger.privacy.profileVisibility'],
    'vidimostProfilya_34bf': ['messenger.privacy.profileVisibility'],
    'whoSeesNickname': ['messenger.privacy.whoSeesNickname'],
    'ktoViditMoyNikneym_54b8': ['messenger.privacy.whoSeesNickname'],
    'whoSeesAvatar': ['messenger.privacy.whoSeesAvatar'],
    'whoSeesBirthday': ['messenger.privacy.whoSeesBirthday'],
    'whoSeesOnlineTime': ['messenger.privacy.whoSeesOnlineTime'],
    'everyone': ['messenger.privacy.all', 'common.all'],
    'vse_984b': ['messenger.privacy.all', 'common.all'],
    'contactsOnly': ['messenger.privacy.contactsOnly'],
    'tolkoKontakty_a559': ['messenger.privacy.contactsOnly'],
    'nobody': ['messenger.privacy.nobody'],
    'nikto_ba19': ['messenger.privacy.nobody'],
    'messages': ['messenger.energy.chatAnimations', 'messenger.chats'],
    'messageAnimations': ['messenger.energy.messageAnimationsTitle'],
    'messageAnimationsDesc': ['messenger.energy.messageAnimationsDesc'],
    'archivedChats': ['messenger.context.archiveChat', 'messenger.archivedChats', 'messenger.context.archive'],
    'archiveManagement': ['messenger.archiveManagement'],
    'clearHistory': ['messenger.context.clearHistory', 'messenger.delete.clearHistoryTitle'],
    'clearHistoryDesc': ['messenger.delete.clearHistoryWarning', 'messenger.delete.clearHistoryMessage'],
    'addContact': ['messenger.contacts.createTitle', 'common.add'],
    'dobavitKontakt_4278': ['messenger.contacts.createTitle', 'common.add'],
    'dobavit_5eba': ['messenger.contacts.createTitle', 'common.add'],
    'noContactsYet': ['messenger.contacts.empty'],
    'theme': ['messenger.chatSettings.appearance', 'common.theme'],
    'darkTheme': ['messenger.chatSettings.appearance', 'common.darkTheme'],
    'darkThemeDesc': ['messenger.chatSettings.appearance'],
    'fontSizeText': ['messenger.chatSettings.textSize'],
    'closeActionTitle': ['settings.closeActionTitle', 'messenger.generalSettings.closeAction', 'messenger.settings.generalTitle'],
    'closeActionDescription': ['settings.closeActionDescription', 'messenger.settings.generalDesc'],
    'closeActionMinimizeToTray': ['messenger.call.minimize', 'settings.closeActionMinimizeToTray'],
    'closeActionMinimizeToTraySubtitle': ['settings.closeActionMinimizeToTraySubtitle'],
    'closeActionMinimizeToTaskbar': ['settings.closeActionMinimizeToTaskbar'],
    'closeActionMinimizeToTaskbarSubtitle': ['settings.closeActionMinimizeToTaskbarSubtitle'],
    'closeActionExitApp': ['messenger.delete.buttons.leave', 'settings.closeActionExitApp'],
    'closeActionExitAppSubtitle': ['settings.closeActionExitAppSubtitle'],
    'energySavingMode': ['messenger.energy.lowPowerTitle'],
    'energySavingModeDesc': ['messenger.energy.lowPowerDesc'],
    'autoSleep': ['messenger.energy.autoSleepTitle'],
    'autoSleepDesc': ['messenger.energy.autoSleepDesc'],
    'animations': ['messenger.energy.chatAnimations'],
    'reducedMotion': ['messenger.energy.reducedAnimationsTitle'],
    'reducedMotionDesc': ['messenger.energy.reducedAnimationsDesc'],
    'appInfo': ['messenger.settings.generalTitle', 'messenger.settings.aboutTitle', 'messenger.settings.about'],
    'checkUpdates': ['messenger.settings.greeting', 'header.checkForUpdates', 'common.checkUpdates'],
    'checkingUpdates': ['header.checkingForUpdates'],
    'youHaveLatestVersion': ['header.latestVersion'],
    'newVersionAvailableTitle': ['header.newVersionAvailable'],
    'ishodyaschiyZvonok_8381': ['messenger.calls.outgoing'],
    'vhodyaschiyZvonok_5ce9': ['messenger.calls.incoming'],
    'otklonennyyZvonok_d499': ['messenger.calls.rejected'],
    'propuschennyyZvonok_e98d': ['messenger.calls.missed'],
    'razgovorNeSostoyalsya_67fb': ['messenger.calls.unanswered'],
    'vyOtkloniliVyzov_8d1d': ['messenger.calls.declined'],
    'vyPropustiliVyzov_f17a': ['messenger.calls.missedByYou'],
    'startCall': ['messenger.callType.title', 'messenger.calls.start', 'messenger.calls.audio', 'messenger.calls.startCall'],
    'audioCall': ['messenger.callType.audio', 'messenger.calls.audio', 'messenger.calls.audioCall'],
    'videoCall': ['messenger.callType.video', 'messenger.calls.video', 'messenger.calls.videoCall'],
    'audioCallDesc': ['messenger.callType.audioDesc', 'messenger.callType.audio', 'messenger.createGroup.callsDescription'],
    'videoCallDesc': ['messenger.callType.videoDesc', 'messenger.callType.video'],
    'vhodyaschiyVyzov_905e': ['messenger.call.incoming', 'messenger.calls.incoming'],
    'otklonit_8b0d': ['messenger.call.decline', 'messenger.call.drop', 'messenger.calls.decline', 'messenger.delete.buttons.cancel'],
    'otvetit_e568': ['messenger.call.accept', 'messenger.call.answer', 'messenger.calls.answer', 'messenger.message.reply'],
    'videozvonok_dd18': ['messenger.callType.video', 'messenger.call.videoCall', 'messenger.calls.video'],
    'videozvonok_8142': ['messenger.callType.video', 'messenger.call.videoCall', 'messenger.calls.video'],
    'golosovoyZvonok_5410': ['messenger.callType.audio', 'messenger.calls.audio'],
    'golosovoyZvonok_b615': ['messenger.callType.audio', 'messenger.calls.audio'],
    'pozvonitPoGolosovoySvyazi_4069': ['messenger.callType.audioDesc', 'messenger.callType.audio'],
    'pozvonitSVklyuchennoyKameroy_fb05': ['messenger.callType.videoDesc', 'messenger.callType.video'],
    'nachatZvonok_3d26': ['messenger.callType.title', 'messenger.calls.start', 'messenger.calls.startCall'],
    'svernut_ca9f': ['messenger.call.minimize', 'common.minimize'],
    'gruppovoyZvonok_dac1': ['messenger.createGroup.calls', 'messenger.editChat.groupCalls', 'common.groupCall'],
    'podklyuchenieKZvonku_e2cf': ['messenger.call.waiting', 'messenger.call.outgoingStatus'],
    'podklyuchenieKVeschaniyu_038b': ['messenger.call.waiting', 'messenger.call.outgoingStatus'],
    'sobesednik_7025': ['messenger.call.contact', 'messenger.chatInfo.user', 'common.peer'],
    'vy_0101': ['messenger.chatInfo.you', 'common.you'],
    'neizvestnyy_be89': ['messenger.system.unknownUser', 'common.unknown'],
    'whoCanCall': ['messenger.privacy.whoCanCall'],
    'ktoMozhetZvonit_c427': ['messenger.privacy.whoCanCall'],
    'addAttachment': ['messenger.attach.file', 'messenger.attach.uploadFile'],
}

getter_to_keys = {}
for g in getters:
    candidates = []
    if g in semantic_hints:
        candidates.extend(semantic_hints[g])
    
    ru_val = getter_to_ru.get(g, '')
    if ru_val:
        if ru_val in manifest_by_exact:
            candidates.extend(manifest_by_exact[ru_val])
        norm = normalize_text(ru_val)
        if norm in manifest_by_norm:
            candidates.extend(manifest_by_norm[norm])
    
    candidates.append(g)
    candidates.append(f"pc.{g}")
    
    seen = set()
    uniq = []
    for c in candidates:
        if c not in seen:
            seen.add(c)
            uniq.append(c)
    getter_to_keys[g] = uniq

# Генерируем DynamicAppLocalizations
out = [
    "// GENERATED BOILERPLATE ADAPTER FROM CANONICAL MANIFEST",
    "// 100% COMPLETE MANIFEST COVERAGE FOR XANEO MOBILE",
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
    "      final val = _rt.get(key);",
    "      if (val != key) return val;",
    "    }",
    "    return _rt.resolveByText(fallback);",
    "  }",
    "",
]

for g in getters:
    keys = getter_to_keys[g]
    keys_repr = ", ".join(f"'{k}'" for k in keys)
    out.append("  @override")
    out.append(f"  String get {g} => _resolve(const [{keys_repr}], base.{g});")
    out.append("")

for name, params in methods:
    param_names = []
    param_pairs = []
    for p in params.split(','):
        p = p.strip()
        if p:
            parts = p.split()
            p_name = parts[-1]
            param_names.append(p_name)
            param_pairs.append(f"'{p_name}': {p_name}")
    
    params_dict = "{" + ", ".join(param_pairs) + "}"
    call_args = ", ".join(param_names)
    
    out.append("  @override")
    out.append(f"  String {name}({params}) {{")
    out.append(f"    if (!_rt.hasActiveCustomPack) return base.{name}({call_args});")
    out.append(f"    final res = _rt.get('{name}', params: {params_dict});")
    out.append(f"    if (res != '{name}') return res;")
    out.append(f"    return base.{name}({call_args});")
    out.append("  }")
    out.append("")

out.append("}")
out.append("")

with open(DYNAMIC_DART_PATH, 'w', encoding='utf-8') as f:
    f.write("\n".join(out))

print(f"DynamicAppLocalizations успешно сгенерирован для всех {len(getters)} геттеров с умным разрешением.")
