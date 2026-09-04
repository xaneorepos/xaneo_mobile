import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/chat/chat_model.dart';
import '../../screens/chat/chat_screen.dart';
import '../../services/chat/chat_local_repository.dart';
import '../../services/chat/group_channel_service.dart';
import '../../services/runtime_translations.dart';
import '../../styles/app_styles.dart';
import 'avatar_cropper.dart';
import 'base_custom_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Модальное окно создания группы
class CreateGroupModal extends BaseCustomModal {
  final GroupChannelService groupChannelService;
  final LocalChatRepository localChatRepo;

  const CreateGroupModal({
    super.key,
    required this.groupChannelService,
    required this.localChatRepo,
  });

  static Future<void> show({
    required BuildContext context,
    required GroupChannelService groupChannelService,
    required LocalChatRepository localChatRepo,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateGroupModal(
        groupChannelService: groupChannelService,
        localChatRepo: localChatRepo,
      ),
    );
  }

  @override
  State<CreateGroupModal> createState() => _CreateGroupModalState();
}

class _CreateGroupModalState extends BaseCustomModalState<CreateGroupModal> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPrivate = false;
  File? _avatarFile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  bool get fitContent => true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        final rawFile = File(result.files.single.path!);
        if (mounted) {
          final croppedFile = await AvatarCropper.show(context, rawFile);
          if (croppedFile != null && mounted) {
            setState(() {
              _avatarFile = croppedFile;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking avatar: $e');
    }
  }

  Future<void> _handleCreateGroup() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage =
            (AppLocalizations.of(context)?.vvediteNazvanieGruppy_0a69 ??
                'Fallback');
      });
      return;
    }

    if (!_isPrivate && username.isEmpty) {
      setState(() {
        _errorMessage = (AppLocalizations.of(context)
                ?.dlyaPublichnoyGruppyTrebuetsyaNikneym_15d0 ??
            'Fallback');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final description = _descriptionController.text.trim();
    final result = await widget.groupChannelService.createGroup(
      name: name,
      username: !_isPrivate ? username : null,
      description: description.isNotEmpty ? description : null,
      isPrivate: _isPrivate,
      avatarFile: _avatarFile,
    );

    if (!mounted) return;

    if (result != null &&
        (result['success'] == true ||
            result['id'] != null ||
            result['group_id'] != null)) {
      final groupIdRaw =
          result['id'] ?? result['group_id'] ?? result['chat_id'];
      final String chatId = groupIdRaw.toString().startsWith('group_')
          ? groupIdRaw.toString()
          : 'group_$groupIdRaw';

      final chat = ChatModel(
        id: chatId,
        name: name,
        avatar: result['avatar']?.toString(),
        avatarGradient: result['avatar_gradient']?.toString() ??
            result['gradient']?.toString(),
        isGroup: true,
        isPersonal: false,
        isChannel: false,
        isFavorites: false,
        lastMessage:
            (AppLocalizations.of(context)?.gruppaSozdana_6b3b ?? 'Fallback'),
        lastMessageTime: DateTime.now(),
        otherUser: {
          'members_count': 1,
          'online_count': 1,
          'description': description,
          'username': !_isPrivate ? username.replaceAll('@', '') : null,
          'avatar_gradient': result['avatar_gradient']?.toString() ??
              result['gradient']?.toString(),
        },
      );

      await widget.localChatRepo.saveChat(chat);

      if (!mounted) return;
      Navigator.of(context).pop();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(chat: chat),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result?['error']?.toString() ??
            result?['message']?.toString() ??
            (AppLocalizations.of(context)?.oshibkaPriSozdaniiGruppy_794e ??
                'Fallback');
      });
    }
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Аватарка и Заголовок
        Row(
          children: [
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: context.xaneoDivider,
                      shape: BoxShape.circle,
                      image: _avatarFile != null
                          ? DecorationImage(
                              image: FileImage(_avatarFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      border: Border.all(
                        color: context.xaneoOverlay(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: _avatarFile == null
                        ? Center(
                            child: FaIcon(
                              FontAwesomeIcons.users,
                              color: context.xaneoTextSecondary,
                              size: 22,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: context.xaneoTextPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.camera,
                          color: context.xaneoSurface,
                          size: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (AppLocalizations.of(context)?.sozdatGruppu_459f ??
                        'Fallback'),
                    style: TextStyle(
                      color: context.xaneoTextPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppStyles.fontFamily,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    (AppLocalizations.of(context)
                            ?.nazhmiteNaIkonkuChtobyVybrat_af03 ??
                        'Fallback'),
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12.5,
                      fontFamily: AppStyles.fontFamily,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Поле ввода названия
        TextField(
          controller: _nameController,
          style: TextStyle(color: context.xaneoTextPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: (AppLocalizations.of(context)?.nazvanieGruppy_9a39 ??
                'Fallback'),
            hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 15),
            filled: true,
            fillColor: context.xaneoOverlay(0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.xaneoTextMuted, width: 1),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Поле ввода описания
        TextField(
          controller: _descriptionController,
          maxLines: 2,
          style: TextStyle(color: context.xaneoTextPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: RuntimeTranslations.instance.resolve(
              'messenger.createGroup.descriptionPlaceholder',
              AppLocalizations.of(context)?.opisanieNeobyazatelno_7812 ??
                  'Fallback',
            ),
            hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 15),
            filled: true,
            fillColor: context.xaneoOverlay(0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.xaneoTextMuted, width: 1),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Переключатель приватности
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.xaneoOverlay(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.xaneoDivider),
          ),
          child: Row(
            children: [
              FaIcon(
                _isPrivate ? FontAwesomeIcons.lock : FontAwesomeIcons.globe,
                color: const Color(0xFFAAAAAA),
                size: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPrivate
                          ? (AppLocalizations.of(context)
                                  ?.privatnayaGruppa_d20e ??
                              'Fallback')
                          : (AppLocalizations.of(context)
                                  ?.publichnayaGruppa_50f8 ??
                              'Fallback'),
                      style: TextStyle(
                        color: context.xaneoTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppStyles.fontFamily,
                      ),
                    ),
                    Text(
                      _isPrivate
                          ? (AppLocalizations.of(context)
                                  ?.vhodTolkoPoPriglasheniyu_97a1 ??
                              'Fallback')
                          : (AppLocalizations.of(context)
                                  ?.lyuboyMozhetNaytiIVstupit_5e26 ??
                              'Fallback'),
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontFamily: AppStyles.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isPrivate,
                activeTrackColor: context.xaneoTextPrimary,
                onChanged: (val) {
                  setState(() {
                    _isPrivate = val;
                  });
                },
              ),
            ],
          ),
        ),

        // Если группа публичная — поле ввода username
        if (!_isPrivate) ...[
          SizedBox(height: 12),
          TextField(
            controller: _usernameController,
            style: TextStyle(color: context.xaneoTextPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: (AppLocalizations.of(context)
                      ?.publichnayaSsylkanikneymMyGroup_6640 ??
                  'Fallback'),
              hintStyle:
                  const TextStyle(color: Color(0xFF666666), fontSize: 14.5),
              prefixText: '@ ',
              prefixStyle: TextStyle(
                  color: context.xaneoTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              filled: true,
              fillColor: context.xaneoOverlay(0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: context.xaneoTextMuted, width: 1),
              ),
            ),
          ),
        ],

        if (_errorMessage != null) ...[
          const SizedBox(height: 14),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Color(0xFFFF5555),
              fontSize: 13,
              fontFamily: AppStyles.fontFamily,
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Кнопка создания
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleCreateGroup,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.xaneoTextPrimary,
              foregroundColor: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.xaneoSurface,
                    ),
                  )
                : Text(
                    (AppLocalizations.of(context)?.sozdatGruppu_459f ??
                        'Fallback'),
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
}
