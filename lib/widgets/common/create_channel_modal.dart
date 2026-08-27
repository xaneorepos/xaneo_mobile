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

/// Модальное окно создания канала
class CreateChannelModal extends BaseCustomModal {
  final GroupChannelService groupChannelService;
  final LocalChatRepository localChatRepo;

  const CreateChannelModal({
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
      builder: (ctx) => CreateChannelModal(
        groupChannelService: groupChannelService,
        localChatRepo: localChatRepo,
      ),
    );
  }

  @override
  State<CreateChannelModal> createState() => _CreateChannelModalState();
}

class _CreateChannelModalState
    extends BaseCustomModalState<CreateChannelModal> {
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

  Future<void> _handleCreateChannel() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage =
            (AppLocalizations.of(context)?.vvediteNazvanieKanala_5536 ??
                'Fallback');
      });
      return;
    }

    if (!_isPrivate && username.isEmpty) {
      setState(() {
        _errorMessage = (AppLocalizations.of(context)
                ?.dlyaPublichnogoKanalaTrebuetsyaSsylkanikneym_5f06 ??
            'Fallback');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final description = _descriptionController.text.trim();
    final result = await widget.groupChannelService.createChannel(
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
            result['channel_id'] != null)) {
      final channelIdRaw =
          result['id'] ?? result['channel_id'] ?? result['chat_id'];
      final String chatId = channelIdRaw.toString().startsWith('channel_')
          ? channelIdRaw.toString()
          : 'channel_$channelIdRaw';

      final chat = ChatModel(
        id: chatId,
        name: name,
        avatar: result['avatar']?.toString(),
        avatarGradient: result['avatar_gradient']?.toString() ??
            result['gradient']?.toString(),
        isChannel: true,
        isGroup: false,
        isPersonal: false,
        isFavorites: false,
        lastMessage:
            (AppLocalizations.of(context)?.kanalSozdan_1522 ?? 'Fallback'),
        lastMessageTime: DateTime.now(),
        otherUser: {
          'subscribers_count': 1,
          'username': !_isPrivate ? username.replaceAll('@', '') : null,
          'description': description,
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
            (AppLocalizations.of(context)?.oshibkaPriSozdaniiKanala_7d4b ??
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
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                      image: _avatarFile != null
                          ? DecorationImage(
                              image: FileImage(_avatarFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: _avatarFile == null
                        ? Center(
                            child: FaIcon(
                              FontAwesomeIcons.bullhorn,
                              color: Colors.white70,
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.camera,
                          color: Colors.black,
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
                    (AppLocalizations.of(context)?.sozdatKanal_9022 ??
                        'Fallback'),
                    style: TextStyle(
                      color: Colors.white,
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
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: (AppLocalizations.of(context)?.nazvanieKanala_c548 ??
                'Fallback'),
            hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 15),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Поле ввода описания
        TextField(
          controller: _descriptionController,
          maxLines: 2,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: RuntimeTranslations.instance.resolve(
              'messenger.createChannel.descriptionPlaceholder',
              AppLocalizations.of(context)?.opisanieNeobyazatelno_7812 ??
                  'Fallback',
            ),
            hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 15),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Переключатель приватности
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
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
                                  ?.privatnyyKanal_3139 ??
                              'Fallback')
                          : (AppLocalizations.of(context)
                                  ?.publichnyyKanal_0f7c ??
                              'Fallback'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppStyles.fontFamily,
                      ),
                    ),
                    Text(
                      _isPrivate
                          ? (AppLocalizations.of(context)
                                  ?.podpiskaTolkoPoPriglasheniyu_99c3 ??
                              'Fallback')
                          : (AppLocalizations.of(context)
                                  ?.lyuboyMozhetNaytiIPodpisatsya_8579 ??
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
                activeTrackColor: Colors.white,
                onChanged: (val) {
                  setState(() {
                    _isPrivate = val;
                  });
                },
              ),
            ],
          ),
        ),

        // Если канал публичный — поле ввода юзернейма
        if (!_isPrivate) ...[
          SizedBox(height: 12),
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: (AppLocalizations.of(context)
                      ?.ssylkanikneymKanalaMychannel_79f6 ??
                  'Fallback'),
              hintStyle:
                  const TextStyle(color: Color(0xFF666666), fontSize: 14.5),
              prefixText: '@ ',
              prefixStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
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
            onPressed: _isLoading ? null : _handleCreateChannel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    (AppLocalizations.of(context)?.sozdatKanal_9022 ??
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
