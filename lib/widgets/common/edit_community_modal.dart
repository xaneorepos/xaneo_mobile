import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../l10n/community_settings_localizations.dart';
import '../../models/chat/chat_model.dart';
import '../../services/chat/chat_local_repository.dart';
import '../../services/chat/group_channel_service.dart';
import '../../styles/app_styles.dart';
import 'avatar_cropper.dart';
import 'base_custom_modal.dart';
import 'create_channel_modal.dart';
import 'create_group_modal.dart';
import '../emoji_picker_panel.dart';

/// Редактирование канала наследует публичный контракт модалки его создания.
class EditChannelModal extends CreateChannelModal {
  final ChatModel chat;
  final Map<String, dynamic> initialData;

  const EditChannelModal({
    super.key,
    required super.groupChannelService,
    required super.localChatRepo,
    required this.chat,
    required this.initialData,
  });

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required GroupChannelService groupChannelService,
    required LocalChatRepository localChatRepo,
    required ChatModel chat,
  }) async {
    final data = await groupChannelService.getCommunityDetails(
      chatId: chat.id,
      isGroup: false,
    );
    if (!context.mounted || data == null) return null;
    return BaseCustomModal.show<Map<String, dynamic>>(
      context: context,
      child: EditChannelModal(
        groupChannelService: groupChannelService,
        localChatRepo: localChatRepo,
        chat: chat,
        initialData: data,
      ),
    );
  }

  @override
  State<EditChannelModal> createState() => _EditChannelModalState();
}

class _EditChannelModalState extends BaseCustomModalState<EditChannelModal> {
  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController controller) {
    return _CommunitySettingsForm(
      chat: widget.chat,
      initialData: widget.initialData,
      service: widget.groupChannelService,
      localRepo: widget.localChatRepo,
      scrollController: controller,
      isGroup: false,
    );
  }
}

/// Редактирование группы наследует публичный контракт модалки её создания.
class EditGroupModal extends CreateGroupModal {
  final ChatModel chat;
  final Map<String, dynamic> initialData;

  const EditGroupModal({
    super.key,
    required super.groupChannelService,
    required super.localChatRepo,
    required this.chat,
    required this.initialData,
  });

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required GroupChannelService groupChannelService,
    required LocalChatRepository localChatRepo,
    required ChatModel chat,
  }) async {
    final data = await groupChannelService.getCommunityDetails(
      chatId: chat.id,
      isGroup: true,
    );
    if (!context.mounted || data == null) return null;
    return BaseCustomModal.show<Map<String, dynamic>>(
      context: context,
      child: EditGroupModal(
        groupChannelService: groupChannelService,
        localChatRepo: localChatRepo,
        chat: chat,
        initialData: data,
      ),
    );
  }

  @override
  State<EditGroupModal> createState() => _EditGroupModalState();
}

class _EditGroupModalState extends BaseCustomModalState<EditGroupModal> {
  @override
  bool get fitContent => true;

  @override
  Widget buildContent(BuildContext context, ScrollController controller) {
    return _CommunitySettingsForm(
      chat: widget.chat,
      initialData: widget.initialData,
      service: widget.groupChannelService,
      localRepo: widget.localChatRepo,
      scrollController: controller,
      isGroup: true,
    );
  }
}

class _CommunitySettingsForm extends StatefulWidget {
  final ChatModel chat;
  final Map<String, dynamic> initialData;
  final GroupChannelService service;
  final LocalChatRepository localRepo;
  final ScrollController scrollController;
  final bool isGroup;

  const _CommunitySettingsForm({
    required this.chat,
    required this.initialData,
    required this.service,
    required this.localRepo,
    required this.scrollController,
    required this.isGroup,
  });

  @override
  State<_CommunitySettingsForm> createState() => _CommunitySettingsFormState();
}

class _CommunitySettingsFormState extends State<_CommunitySettingsForm> {
  static const _permissionKeys = [
    'change-info',
    'manage-admins',
    'manage-permissions',
    'delete-messages',
    'ban-members',
    'post-messages',
  ];

  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _description;
  late bool _isPrivate;
  late bool _groupCallsEnabled;
  late Map<String, bool> _permissions;
  late bool _reactionsEnabled;
  late Set<String> _allowedReactions;
  late bool _slowModeEnabled;
  late int _slowModeSeconds;
  late bool _adminsException;
  late bool _verifiedException;
  String? _discussionGroupId;
  List<ChatModel> _groups = const [];
  File? _avatarFile;
  bool _saving = false;
  String? _error;

  CommunitySettingsLocalizations get l10n =>
      CommunitySettingsLocalizations.of(context);

  Map<String, dynamic> get data => widget.initialData;
  bool get _isCreator => data['is_creator'] == true || data['is_owner'] == true;
  bool get _canManage =>
      _isCreator || _permissions['manage-permissions'] == true;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
        text: data['name']?.toString() ?? widget.chat.name);
    _username = TextEditingController(text: data['username']?.toString() ?? '');
    _description =
        TextEditingController(text: data['description']?.toString() ?? '');
    _isPrivate = data['privacy'] == 'private';
    _groupCallsEnabled = data['group_calls_enabled'] == true;
    final rawPermissions = data['admin_permissions'] is Map
        ? Map<String, dynamic>.from(data['admin_permissions'] as Map)
        : <String, dynamic>{};
    _permissions = {
      for (final key in _permissionKeys) key: rawPermissions[key] != false
    };
    final advanced = data['advanced_settings'] is Map
        ? Map<String, dynamic>.from(data['advanced_settings'] as Map)
        : <String, dynamic>{};
    _reactionsEnabled = advanced['reactions_enabled'] != false;
    _allowedReactions = Set<String>.from(
      (advanced['allowed_reactions'] is List
              ? advanced['allowed_reactions'] as List
              : const ['👍', '❤️', '😂', '😮'])
          .map((e) => e.toString()),
    );
    final slow = advanced['slow_mode'] is Map
        ? Map<String, dynamic>.from(advanced['slow_mode'] as Map)
        : <String, dynamic>{};
    _slowModeEnabled = slow['enabled'] == true;
    _slowModeSeconds =
        int.tryParse(slow['duration_seconds']?.toString() ?? '') ?? 60;
    final exceptions = slow['exceptions'] is Map
        ? Map<String, dynamic>.from(slow['exceptions'] as Map)
        : <String, dynamic>{};
    _adminsException = exceptions['admins'] != false;
    _verifiedException = exceptions['verified'] == true;
    _discussionGroupId = data['discussion_group_id']?.toString();
    if (!widget.isGroup) _loadGroups();
  }

  Future<void> _loadGroups() async {
    final chats = await widget.localRepo.getAllChats();
    if (mounted)
      setState(() => _groups = chats.where((c) => c.isGroup).toList());
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await FilePicker.pickFiles(type: FileType.image);
    if (picked == null || picked.files.single.path == null || !mounted) return;
    final cropped =
        await AvatarCropper.show(context, File(picked.files.single.path!));
    if (cropped != null && mounted) setState(() => _avatarFile = cropped);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final username = _username.text.trim().replaceAll('@', '');
    if (name.isEmpty || (!_isPrivate && username.isEmpty)) {
      setState(() => _error = name.isEmpty
          ? l10n.text('messenger.editChat.nameRequired')
          : l10n.text('messenger.editChat.publicNicknameRequired'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final advanced = widget.isGroup
        ? {
            'admin_permissions': _permissions,
            'slow_mode': {
              'enabled': _slowModeEnabled,
              'duration_seconds': _slowModeSeconds,
              'exceptions': {
                'admins': _adminsException,
                'verified': _verifiedException,
                'custom_list': const <dynamic>[],
              },
            },
          }
        : {
            'reactions_enabled': _reactionsEnabled,
            'allowed_reactions': _allowedReactions.toList(),
          };
    final payload = <String, dynamic>{
      'name': name,
      'description': _description.text.trim(),
      'privacy': _isPrivate ? 'private' : 'public',
      if (!_isPrivate) 'username': username,
      if (_isCreator) 'admin_permissions': jsonEncode(_permissions),
      if (_canManage) 'advanced_settings': jsonEncode(advanced),
      if (widget.isGroup) 'group_calls_enabled': _groupCallsEnabled,
      if (!widget.isGroup) 'discussion_group_id': _discussionGroupId ?? '',
    };
    final result = await widget.service.updateCommunity(
      chatId: widget.chat.id,
      isGroup: widget.isGroup,
      data: payload,
      avatarFile: _avatarFile,
    );
    if (!mounted) return;
    if (result == null) {
      setState(() {
        _saving = false;
        _error = l10n.text('messenger.editChat.saveFailed');
      });
      return;
    }
    final other = Map<String, dynamic>.from(widget.chat.otherUser ?? {});
    other.addAll({
      'username': result['username'],
      'description': result['description'],
      'group_calls_enabled': result['group_calls_enabled'],
      'discussion_group_id': result['discussion_group_id'],
      'discussion_group_name': result['discussion_group_name'],
      'advanced_settings': result['advanced_settings'],
      'admin_permissions': result['admin_permissions'],
    });
    await widget.localRepo.saveChat(widget.chat.copyWith(
      name: result['name']?.toString() ?? name,
      avatar: result['avatar_url']?.toString() ?? widget.chat.avatar,
      avatarGradient:
          result['avatar_gradient']?.toString() ?? widget.chat.avatarGradient,
      otherUser: other,
      groupCallsEnabled: result['group_calls_enabled'] == true,
    ));
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        _identityHeader(),
        const SizedBox(height: 20),
        _field(l10n.text('messenger.editChat.name'), _name, maxLength: 100),
        _field(
          l10n.text('messenger.editChat.description'),
          _description,
          maxLength: 500,
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        _settingsSwitchCard(
          title: l10n.text(
            _isPrivate
                ? 'messenger.editChat.private'
                : 'messenger.editChat.public',
          ),
          subtitle: _isPrivate
              ? l10n.text('messenger.editChat.inviteOnly')
              : (widget.isGroup
                  ? l10n.text('messenger.editChat.publicJoin')
                  : l10n.text('messenger.editChat.publicSubscribe')),
          value: _isPrivate,
          icon: _isPrivate ? FontAwesomeIcons.lock : FontAwesomeIcons.globe,
          onChanged: (v) => setState(() => _isPrivate = v),
        ),
        if (!_isPrivate)
          _field(
            l10n.text('messenger.editChat.nickname'),
            _username,
            prefix: '@',
            maxLength: 50,
          ),
        if (_isPrivate && (data['invite_link']?.toString().isNotEmpty ?? false))
          _readOnlyValue(l10n.text('messenger.editChat.inviteLink'),
              'xaneo.ru/${data['invite_link']}'),
        if (widget.isGroup) ...[
          _sectionTitle(l10n.text('messenger.editChat.groupCalls')),
          _settingsSwitchCard(
              title: l10n.text('messenger.editChat.groupCalls'),
              subtitle: l10n.text('messenger.editChat.groupCallsDesc'),
              icon: FontAwesomeIcons.phone,
              value: _groupCallsEnabled,
              onChanged: (v) => setState(() => _groupCallsEnabled = v)),
        ] else ...[
          _sectionTitle(l10n.text('messenger.editChat.discussionGroup')),
          DropdownButtonFormField<String>(
            initialValue: _groups.any((g) =>
                    g.id.replaceFirst('group_', '') == _discussionGroupId)
                ? _discussionGroupId
                : null,
            decoration:
                _inputDecoration(l10n.text('messenger.editChat.notLinked')),
            items: [
              DropdownMenuItem(
                  value: null,
                  child: Text(l10n.text('messenger.editChat.notLinked'))),
              ..._groups.map((g) => DropdownMenuItem(
                  value: g.id.replaceFirst('group_', ''), child: Text(g.name)))
            ],
            onChanged: (v) => setState(() => _discussionGroupId = v),
          ),
        ],
        if (_canManage || _isCreator) _adminPermissions(),
        if (!widget.isGroup && _canManage) _reactionSettings(),
        if (widget.isGroup && _canManage) _slowModeSettings(),
        if (_error != null) _errorBanner(_error!),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.xaneoTextPrimary,
              foregroundColor: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _saving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.xaneoSurface,
                    ),
                  )
                : Text(
                    l10n.text('common.save'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppStyles.fontFamily,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _identityHeader() {
    final avatar = data['avatar_url']?.toString();
    return Row(children: [
      GestureDetector(
        onTap: _pickAvatar,
        child: Stack(children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.xaneoDivider,
              shape: BoxShape.circle,
              border: Border.all(color: context.xaneoOverlay(.15), width: 1.5),
              image: _avatarFile != null
                  ? DecorationImage(
                      image: FileImage(_avatarFile!), fit: BoxFit.cover)
                  : avatar != null && avatar.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(avatar), fit: BoxFit.cover)
                      : null,
            ),
            child: _avatarFile == null && (avatar == null || avatar.isEmpty)
                ? Center(
                    child: FaIcon(
                        widget.isGroup
                            ? FontAwesomeIcons.users
                            : FontAwesomeIcons.bullhorn,
                        color: context.xaneoTextSecondary,
                        size: 22))
                : null,
          ),
          Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                    color: context.xaneoTextPrimary, shape: BoxShape.circle),
                child: Center(
                    child: FaIcon(FontAwesomeIcons.camera,
                        size: 11, color: context.xaneoSurface)),
              )),
        ]),
      ),
      const SizedBox(width: 16),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            l10n.text(widget.isGroup
                ? 'messenger.editChat.editGroupTitle'
                : 'messenger.editChat.editChannelTitle'),
            style: TextStyle(
                color: context.xaneoTextPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w600,
                fontFamily: AppStyles.fontFamily,
                letterSpacing: -.4)),
        const SizedBox(height: 2),
        Text(l10n.text('messenger.editChat.avatarHint'),
            style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 12.5,
                fontFamily: AppStyles.fontFamily,
                letterSpacing: -.2)),
      ])),
    ]);
  }

  Widget _field(String label, TextEditingController controller,
      {int? maxLength, int maxLines = 1, String? prefix}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          onChanged: (_) => setState(() {}),
          style: TextStyle(
              color: context.xaneoTextPrimary,
              fontSize: maxLines > 1 ? 15 : 16),
          decoration: _inputDecoration(label)
              .copyWith(prefixText: prefix, counterText: '')),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 15),
      filled: true,
      fillColor: context.xaneoOverlay(.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.xaneoTextMuted)));
  Widget _sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.w700, color: context.xaneoTextPrimary)));
  Widget _switchTile(
          {required String title,
          required String subtitle,
          required bool value,
          required FaIconData icon,
          required ValueChanged<bool> onChanged}) =>
      _settingsSwitchCard(
          title: title,
          subtitle: subtitle,
          value: value,
          icon: icon,
          onChanged: onChanged);
  Widget _settingsSwitchCard(
          {required String title,
          required String subtitle,
          required bool value,
          required FaIconData icon,
          required ValueChanged<bool> onChanged}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: context.xaneoOverlay(.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.xaneoDivider)),
        child: Row(children: [
          FaIcon(icon, color: const Color(0xFFAAAAAA), size: 16),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        color: context.xaneoTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppStyles.fontFamily)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontFamily: AppStyles.fontFamily)),
              ])),
          Switch.adaptive(
              value: value,
              activeTrackColor: context.xaneoTextPrimary,
              onChanged: onChanged),
        ]),
      );
  Widget _readOnlyValue(String label, String value) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: SelectableText(value));
  Widget _errorBanner(String value) => Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(10)),
      child: Text(value, style: const TextStyle(color: Colors.redAccent)));

  Widget _adminPermissions() {
    const labels = {
      'change-info': 'messenger.admin.changeInfo',
      'manage-admins': 'messenger.admin.manageAdmins',
      'manage-permissions': 'messenger.admin.managePermissions',
      'delete-messages': 'messenger.admin.deleteMessages',
      'ban-members': 'messenger.admin.banMembers',
      'post-messages': 'messenger.admin.postMessages',
    };
    final keys =
        _permissionKeys.where((k) => !widget.isGroup || k != 'post-messages');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(l10n.text('messenger.admin.permissions')),
      ...keys.map((key) => CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.text(labels[key]!)),
          value: _permissions[key] ?? true,
          onChanged: _isCreator
              ? (v) => setState(() => _permissions[key] = v ?? false)
              : null)),
    ]);
  }

  Widget _reactionSettings() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle(l10n.text('messenger.reactions.title')),
        _switchTile(
            title: l10n.text(_reactionsEnabled
                ? 'messenger.common.enabledPlural'
                : 'messenger.common.disabledPlural'),
            subtitle: l10n.text('messenger.reactions.choose'),
            icon: FontAwesomeIcons.faceSmile,
            value: _reactionsEnabled,
            onChanged: (v) => setState(() => _reactionsEnabled = v)),
        if (_reactionsEnabled) ...[
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allowedReactions
                  .map((emoji) => InputChip(
                      label: Text(emoji, style: const TextStyle(fontSize: 20)),
                      onDeleted: () =>
                          setState(() => _allowedReactions.remove(emoji))))
                  .toList()),
          const SizedBox(height: 10),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(l10n.text('messenger.reactions.chooseAvailable')),
            children: [
              SizedBox(
                height: 330,
                child: EmojiPickerPanel(
                  isDark: context.isDarkTheme,
                  onEmojiSelected: (emoji) => setState(() {
                    if (_allowedReactions.contains(emoji)) {
                      _allowedReactions.remove(emoji);
                    } else {
                      _allowedReactions.add(emoji);
                    }
                  }),
                ),
              ),
            ],
          ),
        ],
      ]);

  Widget _slowModeSettings() {
    const presets = [5, 10, 30, 60, 300, 900, 3600];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(l10n.text('messenger.slowMode.title')),
      _switchTile(
          title: l10n.text(_slowModeEnabled
              ? 'messenger.common.enabled'
              : 'messenger.common.disabled'),
          subtitle: l10n.text('messenger.slowMode.interval'),
          icon: FontAwesomeIcons.clock,
          value: _slowModeEnabled,
          onChanged: (v) => setState(() => _slowModeEnabled = v)),
      if (_slowModeEnabled) ...[
        Wrap(
            spacing: 7,
            runSpacing: 7,
            children: presets
                .map((e) => ChoiceChip(
                    label: Text(l10n.duration(e)),
                    selected: _slowModeSeconds == e,
                    onSelected: (_) => setState(() => _slowModeSeconds = e)))
                .toList()),
        CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.text('messenger.slowMode.admins')),
            value: _adminsException,
            onChanged: (v) => setState(() => _adminsException = v ?? false)),
        CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.text('messenger.slowMode.verified')),
            value: _verifiedException,
            onChanged: (v) => setState(() => _verifiedException = v ?? false)),
      ],
    ]);
  }
}
