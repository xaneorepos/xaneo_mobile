import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/chat/chat_model.dart';
import '../../screens/chat/chat_screen.dart' show FullScreenVideoPlayer;
import '../../services/database/app_database.dart';
import '../../services/chat/chat_local_repository.dart';
import '../../services/auth/token_storage.dart';
import '../../config/app_config.dart';
import '../../services/crypto/crypto_service.dart';
import '../../services/api/api_client.dart';
import '../../services/chat/chat_service.dart';
import '../../providers/playback_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/chat_name_localizer.dart';
import 'avatar_widget.dart';
import 'base_custom_modal.dart';
import 'package:xaneo/l10n/app_localizations.dart';
import '../../l10n/community_settings_localizations.dart';
import '../../services/runtime_translations.dart';
import '../../styles/app_styles.dart';

/// Модалка информации о чате (собеседник, группа, канал, бот, избранное).
class ChatInfoModal extends BaseCustomModal {
  final ChatModel chat;
  final Future<void> Function()? onOpenSettings;

  const ChatInfoModal({
    super.key,
    required this.chat,
    this.onOpenSettings,
  });

  /// Вспомогательный статический метод для показа модалки
  static Future<String?> show(
    BuildContext context,
    ChatModel chat, {
    Future<void> Function()? onOpenSettings,
  }) {
    return BaseCustomModal.show<String>(
      context: context,
      child: ChatInfoModal(chat: chat, onOpenSettings: onOpenSettings),
      // Сам контент уже использует DraggableScrollableSheet.
      // Второй drag от ModalBottomSheet создавал конкурирующие gesture arena.
      enableDrag: false,
    );
  }

  @override
  State<ChatInfoModal> createState() => _ChatInfoModalState();
}

class _ChatInfoModalState extends BaseCustomModalState<ChatInfoModal> {
  @override
  double get initialExtent => 0.75;
  @override
  double get maxExtent => 0.95;

  int _selectedTabIndex = 0;
  int? _localChatId;
  bool _loadingChatId = true;
  bool _canEditCommunity = false;
  String? _accessToken;

  // Разложенные по категориям вложения. Считаются ОДИН раз на каждое обновление
  // данных в подписке ниже, а не в build(): buildContent() вызывается из
  // DraggableScrollableSheet.builder на каждом кадре перетаскивания, и разбор
  // всех сообщений чата там приводил к микрофризам.
  StreamSubscription<List<Message>>? _messagesSub;
  bool _sharedItemsReady = false;
  List<SharedFileItem> _mediaList = const [];
  List<SharedFileItem> _filesList = const [];
  List<SharedFileItem> _voiceList = const [];
  List<SharedFileItem> _musicList = const [];
  List<SharedLinkItem> _linksList = const [];
  int _sharedItemsGeneration = 0;
  final List<int> _visibleItemsByTab = [18, 30, 30, 30, 30];

  @override
  void initState() {
    super.initState();
    // Первый кадр и короткая анимация должны завершиться до чтения БД.
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final repo = context.read<LocalChatRepository>();
      final id = await repo.getLocalChatId(widget.chat.id);
      final token = await TokenStorage().getAccessToken();
      if (mounted) {
        setState(() {
          _localChatId = id;
          _accessToken = token;
          _loadingChatId = false;
        });
      }

      _loadCommunityPermissions();

      if (id != null) {
        _subscribeToMessages(repo, id);
        // Не запускаем дешифровку 300 сообщений в тот же кадр,
        // когда первый раз строится локальный контент.
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _syncHistoryFromServer(id);
        });
      }
    } catch (e) {
      debugPrint('Error loading chat info data: $e');
      if (mounted) {
        setState(() {
          _loadingChatId = false;
        });
      }
    }
  }

  Future<void> _loadCommunityPermissions() async {
    if (!widget.chat.isGroup && !widget.chat.isChannel) return;
    final apiClient = context.read<ApiClient>();
    final resource = widget.chat.isGroup ? 'groups' : 'channels';
    final communityId =
        widget.chat.id.replaceFirst('group_', '').replaceFirst('channel_', '');
    try {
      final response = await apiClient.get('/$resource/$communityId/');
      final data = response.data;
      if (!mounted || data is! Map) return;
      setState(() {
        _canEditCommunity = data['is_creator'] == true ||
            data['is_owner'] == true ||
            data['is_admin'] == true;
      });
    } catch (_) {}
  }

  /// Подписка на сообщения чата создаётся ровно один раз.
  /// Раньше watchMessagesForChat() вызывался прямо в build(), из-за чего на
  /// каждый кадр пересоздавался drift-стрим (новый запрос к БД + мигание
  /// ConnectionState.waiting).
  void _subscribeToMessages(LocalChatRepository repo, int localId) {
    _messagesSub?.cancel();
    _messagesSub = repo.watchMessagesForChat(localId).listen((messages) async {
      final generation = ++_sharedItemsGeneration;
      // JSON/ссылки во всей истории разбираем в фоновом isolate.
      final buckets = await compute(_computeSharedItemsInBackground, messages);
      if (!mounted || generation != _sharedItemsGeneration) return;
      setState(() {
        _mediaList = buckets.media;
        _filesList = buckets.files;
        _voiceList = buckets.voice;
        _musicList = buckets.music;
        _linksList = buckets.links;
        _sharedItemsReady = true;
      });
    }, onError: (Object e) {
      debugPrint('Error watching messages for chat info: $e');
      if (mounted) {
        setState(() => _sharedItemsReady = true);
      }
    });
  }

  /// Разбирает сообщения на категории вложений. Чистая функция — вызывается
  /// только при изменении данных, не при перерисовке.
  static _SharedItemsBuckets _computeSharedItemsInBackground(
      List<Message> messages) {
    final List<SharedFileItem> mediaList = [];
    final List<SharedFileItem> filesList = [];
    final List<SharedFileItem> voiceList = [];
    final List<SharedFileItem> musicList = [];
    final List<SharedLinkItem> linksList = [];

    for (final message in messages) {
      // Извлекаем файлы
      final files = _extractFileItemsInBackground(message);
      for (final file in files) {
        final isVoiceMsg = file.messageType == 'voice' ||
            file.messageType == 'video_message' ||
            file.fileName.startsWith('voice_') ||
            file.fileName.endsWith('.wav') ||
            file.fileName.endsWith('.ogg') ||
            file.fileName.endsWith('.amr') ||
            file.mimeType == 'audio/wav' ||
            file.mimeType == 'audio/ogg';

        if (isVoiceMsg) {
          voiceList.add(file);
        } else if (file.mimeType.startsWith('image/') ||
            file.mimeType.startsWith('video/')) {
          mediaList.add(file);
        } else if (file.mimeType.startsWith('audio/') ||
            _isMusicExtensionInBackground(file.fileName)) {
          musicList.add(file);
        } else {
          filesList.add(file);
        }
      }

      // Извлекаем ссылки
      final links = _extractLinksInBackground(message);
      linksList.addAll(links);
    }

    return _SharedItemsBuckets(
      media: mediaList,
      files: filesList,
      voice: voiceList,
      music: musicList,
      links: linksList,
    );
  }

  Future<void> _syncHistoryFromServer(int localId) async {
    try {
      final cryptoService = context.read<CryptoService>();
      final apiClient = context.read<ApiClient>();
      final chatService = ChatService(apiClient: apiClient);
      final localChatRepo = context.read<LocalChatRepository>();

      // Загружаем до 300 сообщений с сервера для извлечения всех вложений
      final response = await chatService.getEncryptedMessages(
        widget.chat.id,
        limit: 300,
        offset: 0,
      );

      if (response != null && mounted) {
        final results = response['results'] as List<dynamic>? ?? [];
        if (results.isEmpty) return;

        final List<MessagesCompanion> companions = [];
        final msgIds = results
            .map((item) => item['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

        final existingMessages =
            await localChatRepo.getMessagesByServerIds(msgIds);
        final existingMap = {
          for (final m in existingMessages) m.serverMessageId: m
        };

        for (final item in results) {
          final msgId = item['id']?.toString() ?? '';
          if (msgId.isEmpty) continue;

          final senderId = item['author_username']?.toString() ?? 'unknown';
          final encryptedText = item['encrypted_text']?.toString() ?? '';
          final timestamp =
              _parseDateTime(item['created_at']) ?? DateTime.now();

          String? decrypted;
          if (existingMap.containsKey(msgId)) {
            final existingMsg = existingMap[msgId]!;
            final existingText = existingMsg.textContent;
            if (cryptoService.isEncryptedMessage(existingText) &&
                encryptedText.isNotEmpty) {
              decrypted = await cryptoService.decryptChatMessage(
                  encryptedText, widget.chat.id);
              await Future.delayed(Duration.zero);
            } else {
              decrypted = existingText;
            }
          } else if (encryptedText.isNotEmpty) {
            decrypted = await cryptoService.decryptChatMessage(
                encryptedText, widget.chat.id);
            await Future.delayed(Duration.zero);
          }

          final fileInfoJson =
              _parseFileInfo(Map<String, dynamic>.from(item), decrypted);
          final messageType = item['message_type']?.toString();
          final messageId = item['message_id']?.toString();
          final completionStatusVal = item['completion_status'] != null
              ? jsonEncode(item['completion_status'])
              : null;
          final votesByOptionVal = item['votes_by_option'] != null
              ? jsonEncode(item['votes_by_option'])
              : null;

          companions.add(
            MessagesCompanion(
              serverMessageId: Value(msgId),
              chatId: Value(localId),
              senderId: Value(senderId),
              textContent: Value(decrypted ?? encryptedText),
              timestamp: Value(timestamp),
              fileUrl: Value(fileInfoJson),
              messageType: Value(messageType),
              messageId: Value(messageId),
              completionStatus: Value(completionStatusVal),
              votesByOption: Value(votesByOptionVal),
            ),
          );
        }

        if (companions.isNotEmpty) {
          await localChatRepo.saveMessagesBatch(companions);
        }
      }
    } catch (e) {
      debugPrint('Error syncing history from server: $e');
    }
  }

  Widget _buildDroplet({
    required Widget child,
    VoidCallback? onTap,
    bool isCircle = true,
  }) {
    final borderRadius = isCircle ? null : BorderRadius.circular(20);
    return Container(
      width: isCircle ? 40 : null,
      height: isCircle ? 40 : null,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
        color: context.xaneoOverlay(0.08),
        border: Border.all(
          color: context.xaneoOverlay(0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: isCircle ? const CircleBorder() : null,
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: isCircle
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: isCircle ? Center(child: child) : child,
          ),
        ),
      ),
    );
  }

  Future<void> _showMediaActions(
    BuildContext context, {
    required String url,
    required String fileName,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sheetContext.xaneoSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sheetContext.xaneoDivider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.download_rounded,
                  color: sheetContext.xaneoTextSecondary,
                ),
                title: Text(
                  l10n.downloadVersion,
                  style: TextStyle(color: sheetContext.xaneoTextPrimary),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _downloadFile(context, url, fileName);
                },
              ),
              Divider(height: 1, color: sheetContext.xaneoDivider),
              ListTile(
                leading: Icon(
                  Icons.link_rounded,
                  color: sheetContext.xaneoTextSecondary,
                ),
                title: Text(
                  l10n.copy,
                  style: TextStyle(color: sheetContext.xaneoTextPrimary),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: url));
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMediaViewer(BuildContext context, String url, bool isVideo,
      {SharedFileItem? item}) {
    String senderName = widget.chat.name;
    String dateStr = '';
    if (item != null) {
      final timeStr =
          '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';
      final months = [
        (AppLocalizations.of(context)?.yanvarya_d861 ?? 'Fallback'),
        (AppLocalizations.of(context)?.fevralya_fcf9 ?? 'Fallback'),
        (AppLocalizations.of(context)?.marta_bb77 ?? 'Fallback'),
        (AppLocalizations.of(context)?.aprelya_2b5a ?? 'Fallback'),
        (AppLocalizations.of(context)?.maya_4dbb ?? 'Fallback'),
        (AppLocalizations.of(context)?.iyunya_adcb ?? 'Fallback'),
        (AppLocalizations.of(context)?.iyulya_3236 ?? 'Fallback'),
        (AppLocalizations.of(context)?.avgusta_e3aa ?? 'Fallback'),
        (AppLocalizations.of(context)?.sentyabrya_a146 ?? 'Fallback'),
        (AppLocalizations.of(context)?.oktyabrya_7abd ?? 'Fallback'),
        (AppLocalizations.of(context)?.noyabrya_6e78 ?? 'Fallback'),
        (AppLocalizations.of(context)?.dekabrya_29cc ?? 'Fallback')
      ];
      dateStr =
          '${item.timestamp.day} ${months[item.timestamp.month - 1]} • $timeStr';

      final currentUser = context.read<AuthProvider>().user;
      final isMe = currentUser != null &&
          (item.senderId == currentUser.username ||
              item.senderId == currentUser.id.toString() ||
              item.senderId == 'me');
      final myName =
          (currentUser?.firstName != null && currentUser!.firstName!.isNotEmpty)
              ? currentUser.firstName!
              : (AppLocalizations.of(context)?.vy_0101 ?? 'Fallback');
      final otherFirstName = widget.chat.otherUser?['first_name']?.toString() ??
          widget.chat.otherUser?['firstName']?.toString() ??
          widget.chat.otherUser?['name']?.toString();
      final otherName = (otherFirstName != null && otherFirstName.isNotEmpty)
          ? otherFirstName
          : widget.chat.name;

      if (isMe || widget.chat.isFavorites) {
        senderName = myName;
      } else if (widget.chat.isPersonal) {
        senderName = otherName;
      } else {
        senderName =
            item.senderId.isNotEmpty ? item.senderId : widget.chat.name;
      }
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: isVideo
                    ? FullScreenVideoPlayer(
                        videoUrl: url, jwtToken: _accessToken)
                    : InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Hero(
                          tag: url,
                          child: Image.network(
                            url,
                            headers: _accessToken != null
                                ? {'Authorization': 'Bearer $_accessToken'}
                                : null,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                  'FULLSCREEN IMAGE LOAD ERROR: ${error.runtimeType}');
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image,
                                        color: Colors.white54, size: 64),
                                    SizedBox(height: 16),
                                    Text(
                                        (AppLocalizations.of(context)
                                                ?.neUdalosZagruzitIzobrazhenie_3fa0 ??
                                            'Fallback'),
                                        style:
                                            TextStyle(color: Colors.white54)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ),
              FadeTransition(
                opacity: animation,
                child: Stack(
                  children: [
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 16,
                      left: 16,
                      child: _buildDroplet(
                        isCircle: true,
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 22),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 16,
                      right: 16,
                      child: _buildDroplet(
                        isCircle: true,
                        onTap: item == null
                            ? null
                            : () => _showMediaActions(
                                  context,
                                  url: url,
                                  fileName: item.fileName,
                                ),
                        child: const Icon(Icons.more_vert,
                            color: Colors.white, size: 22),
                      ),
                    ),
                    if (item != null && dateStr.isNotEmpty)
                      Positioned(
                        bottom: MediaQuery.paddingOf(context).bottom + 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _buildDroplet(
                            isCircle: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  senderName,
                                  style: TextStyle(
                                      color: context.xaneoTextPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadFile(
      BuildContext context, String url, String fileName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context)?.zagruzkaFayla_f817 ?? 'Downloading file'} $fileName'),
            duration: const Duration(seconds: 1)),
      );

      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download/Xaneo');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } else {
        dir = await getDownloadsDirectory();
        if (dir != null) {
          dir = Directory('${dir.path}/Xaneo');
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
        } else {
          dir = await getApplicationDocumentsDirectory();
        }
      }

      final savePath = '${dir!.path}/$fileName';
      final dio = Dio();
      if (_accessToken != null) {
        dio.options.headers['Authorization'] = 'Bearer $_accessToken';
      }
      await dio.download(url, savePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.faylZagruzhenIPrikreplen_dc24 ?? 'File saved'}: $savePath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.oshibkaSkachivaniyaFayla_34ac ?? 'Download error'}: $e')),
        );
      }
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  String? _parseFileInfo(Map<String, dynamic> item, String? decrypted) {
    if ((item['message_type'] == 'call' || item['type'] == 'call') &&
        item['message_data'] != null) {
      return jsonEncode(item['message_data']);
    }
    final hasServerFile = (item['attached_file_id'] != null &&
            item['attached_file_id'].toString().isNotEmpty) ||
        (item['file_id'] != null && item['file_id'].toString().isNotEmpty) ||
        (item['file_url'] != null && item['file_url'].toString().isNotEmpty);
    if (hasServerFile &&
        decrypted != null &&
        decrypted.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(decrypted);
        if (parsed is Map &&
            (parsed['type'] == 'file' ||
                parsed['type'] == 'voice' ||
                parsed['type'] == 'video_message') &&
            parsed['file_id'] != null &&
            parsed['file_id'].toString().isNotEmpty) {
          return decrypted;
        }
      } catch (_) {}
    }

    final imagesList = item['images'];
    if (imagesList is List && imagesList.isNotEmpty) {
      final List<Map<String, dynamic>> files = [];
      for (final img in imagesList) {
        if (img is Map) {
          final fId = img['file_id']?.toString();
          if (fId != null && fId.isNotEmpty) {
            final fName = img['name']?.toString() ??
                img['file_name']?.toString() ??
                'file';
            final fSize = img['size'] as int? ?? img['file_size'] as int? ?? 0;
            final fType = img['mime_type']?.toString() ??
                img['file_type']?.toString() ??
                'image/jpeg';
            String fUrl =
                img['url']?.toString() ?? img['file_url']?.toString() ?? '';
            if (fUrl.isEmpty) {
              fUrl = '/api/files/download/$fId/';
            }
            files.add({
              'file_id': fId,
              'file_name': fName,
              'file_size': fSize,
              'mime_type': fType,
              'file_url': fUrl,
              'blur_hash': img['blur_hash']?.toString(),
            });
          }
        }
      }
      if (files.isNotEmpty) {
        return jsonEncode({
          'type': 'collage',
          'files': files,
        });
      }
    }

    final fileId =
        item['attached_file_id']?.toString() ?? item['file_id']?.toString();
    if (fileId != null && fileId.isNotEmpty) {
      final fileName = item['attached_file_name']?.toString() ??
          item['file_name']?.toString() ??
          'file';
      final fileSize =
          item['attached_file_size'] as int? ?? item['file_size'] as int? ?? 0;
      final fileType = item['attached_file_type']?.toString() ??
          item['mime_type']?.toString() ??
          'application/octet-stream';
      String fileUrlSuffix = item['attached_file_url']?.toString() ??
          item['file_url']?.toString() ??
          '';
      if (fileUrlSuffix.isEmpty) {
        fileUrlSuffix = '/api/files/download/$fileId/';
      }
      return jsonEncode({
        'file_id': fileId,
        'file_name': fileName,
        'file_size': fileSize,
        'mime_type': fileType,
        'file_url': fileUrlSuffix,
      });
    }

    return null;
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    final chat = widget.chat;
    final otherUser = chat.otherUser;

    // Свойства пользователя/чата
    final String? username =
        chat.isFavorites ? null : otherUser?['username']?.toString();
    final String? phone =
        chat.isFavorites ? null : otherUser?['phone']?.toString();

    // Получение описания
    String? bio;
    if (chat.isFavorites) {
      bio = null;
    } else {
      bio = otherUser?['bio']?.toString() ??
          otherUser?['description']?.toString() ??
          otherUser?['about']?.toString();
    }

    // Парсим цвета градиента для эффекта свечения
    final colors = _parseGradientColors(chat.avatarGradient);
    final primaryGlowColor = colors.first;

    if (_loadingChatId) {
      return Center(
        child: CircularProgressIndicator(color: context.xaneoTextPrimary),
      );
    }

    if (_localChatId == null) {
      return _buildStaticLayout(
          context, scrollController, username, phone, bio, primaryGlowColor);
    }

    // Ждём первую порцию данных из подписки (см. _subscribeToMessages).
    if (!_sharedItemsReady) {
      return Center(
          child: CircularProgressIndicator(color: context.xaneoTextPrimary));
    }

    final tabs = [
      {
        'title': (AppLocalizations.of(context)?.media_c247 ?? 'Fallback'),
        'count': _mediaList.length.toString(),
        'icon': Icons.image_rounded
      },
      {
        'title': (AppLocalizations.of(context)?.fayly_200c ?? 'Fallback'),
        'count': _filesList.length.toString(),
        'icon': Icons.description_rounded
      },
      {
        'title': (AppLocalizations.of(context)?.golos_2d89 ?? 'Fallback'),
        'count': _voiceList.length.toString(),
        'icon': Icons.mic_rounded
      },
      {
        'title': (AppLocalizations.of(context)?.muzyka_0660 ?? 'Fallback'),
        'count': _musicList.length.toString(),
        'icon': Icons.music_note_rounded
      },
      {
        'title': (AppLocalizations.of(context)?.ssylki_9f58 ?? 'Fallback'),
        'count': _linksList.length.toString(),
        'icon': Icons.link_rounded
      },
    ];

    return ListView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 10),
        _buildProfileHeader(context, primaryGlowColor),
        const SizedBox(height: 24),
        _buildDetailsSection(username, phone, bio),
        const SizedBox(height: 24),
        _buildSharedMediaTabsHeader(tabs),
        const SizedBox(height: 16),
        _buildTabContentWithData(
          _selectedTabIndex,
          _mediaList,
          _filesList,
          _voiceList,
          _musicList,
          _linksList,
        ),
      ],
    );
  }

  Widget _buildStaticLayout(
    BuildContext context,
    ScrollController scrollController,
    String? username,
    String? phone,
    String? bio,
    Color primaryGlowColor,
  ) {
    final tabs = [
      {
        'title': (AppLocalizations.of(context)?.media_c247 ?? 'Fallback'),
        'count': '0',
        'icon': Icons.image_rounded
      },
      {
        'title': (AppLocalizations.of(context)?.fayly_200c ?? 'Fallback'),
        'count': '0',
        'icon': Icons.description_rounded
      },
      {
        'title': (AppLocalizations.of(context)?.golos_2d89 ?? 'Fallback'),
        'count': '0',
        'icon': Icons.mic_rounded
      },
      {
        'title': (AppLocalizations.of(context)?.muzyka_0660 ?? 'Fallback'),
        'count': '0',
        'icon': Icons.music_note_rounded
      },
      {
        'title': (AppLocalizations.of(context)?.ssylki_9f58 ?? 'Fallback'),
        'count': '0',
        'icon': Icons.link_rounded
      },
    ];

    return ListView(
      controller: scrollController,
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 10),
        _buildProfileHeader(context, primaryGlowColor),
        const SizedBox(height: 24),
        _buildDetailsSection(username, phone, bio),
        const SizedBox(height: 24),
        _buildSharedMediaTabsHeader(tabs),
        const SizedBox(height: 16),
        _buildEmptyPlaceholder(
          Icons.cloud_off_rounded,
          (AppLocalizations.of(context)?.netDannyh_dee9 ?? 'Fallback'),
          (AppLocalizations.of(context)?.istoriyaSoobscheniyPustaIliChat_2d07 ??
              'Fallback'),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, Color primaryGlowColor) {
    final chat = widget.chat;
    final settingsLabel = CommunitySettingsLocalizations.of(context).text(
      chat.isGroup
          ? 'messenger.editChat.settingsGroup'
          : 'messenger.editChat.settingsChannel',
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Hero(
                tag: 'chat_avatar_${chat.id}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryGlowColor.withOpacity(0.24),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: AvatarWidget(
                    avatar: chat.avatar,
                    avatarGradient: chat.avatarGradient,
                    hasAvatar: chat.avatar != null && chat.avatar!.isNotEmpty,
                    username: localizedChatName(context, chat),
                    size: 96,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Hero(
              tag: 'chat_name_${chat.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  localizedChatName(context, chat),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: context.xaneoTextPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(child: _buildStatusWidget()),
          ],
        ),
        if (_canEditCommunity && widget.onOpenSettings != null)
          PositionedDirectional(
            top: 0,
            end: 0,
            child: SizedBox(
              width: 40,
              height: 40,
              child: PopupMenuButton<String>(
                tooltip: settingsLabel,
                position: PopupMenuPosition.under,
                padding: EdgeInsets.zero,
                color: context.xaneoSurface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: context.xaneoDivider),
                ),
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: context.xaneoTextSecondary,
                ),
                onSelected: (_) {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onOpenSettings?.call();
                  });
                },
                itemBuilder: (_) => [
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 15,
                          color: context.xaneoTextSecondary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          settingsLabel,
                          style: TextStyle(
                            color: context.xaneoTextPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSharedMediaTabsHeader(List<Map<String, dynamic>> tabsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            (AppLocalizations.of(context)?.obschieMaterialy_11e4 ?? 'Fallback'),
            style: TextStyle(
              color: context.xaneoTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.xaneoOverlay(0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.xaneoOverlay(0.04),
              width: 1,
            ),
          ),
          child: Row(
            children: List.generate(tabsList.length, (index) {
              final tab = tabsList[index];
              final isSelected = _selectedTabIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.xaneoOverlay(0.06)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tab['title'].toString(),
                          style: TextStyle(
                            color: isSelected
                                ? context.xaneoTextPrimary
                                : context.xaneoTextMuted,
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.xaneoOverlay(0.12)
                                : context.xaneoOverlay(0.04),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tab['count'].toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? context.xaneoTextSecondary
                                  : context.xaneoTextMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContentWithData(
    int index,
    List<SharedFileItem> mediaList,
    List<SharedFileItem> filesList,
    List<SharedFileItem> voiceList,
    List<SharedFileItem> musicList,
    List<SharedLinkItem> linksList,
  ) {
    final visibleCount = _visibleItemsByTab[index];
    switch (index) {
      case 0:
        return _buildPaginatedTab(
          _buildMediaGrid(mediaList.take(visibleCount).toList()),
          shown: visibleCount,
          total: mediaList.length,
          tabIndex: index,
        );
      case 1:
        return _buildPaginatedTab(
          _buildFilesList(filesList.take(visibleCount).toList()),
          shown: visibleCount,
          total: filesList.length,
          tabIndex: index,
        );
      case 2:
        return _buildPaginatedTab(
          _buildVoiceAndVideoList(voiceList.take(visibleCount).toList()),
          shown: visibleCount,
          total: voiceList.length,
          tabIndex: index,
        );
      case 3:
        return _buildPaginatedTab(
          _buildMusicList(musicList.take(visibleCount).toList()),
          shown: visibleCount,
          total: musicList.length,
          tabIndex: index,
        );
      case 4:
        return _buildPaginatedTab(
          _buildLinksList(linksList.take(visibleCount).toList()),
          shown: visibleCount,
          total: linksList.length,
          tabIndex: index,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPaginatedTab(
    Widget content, {
    required int shown,
    required int total,
    required int tabIndex,
  }) {
    if (shown >= total) return content;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {
              setState(() => _visibleItemsByTab[tabIndex] += 30);
            },
            icon: const Icon(Icons.expand_more_rounded),
            label: Text(
              '${RuntimeTranslations.instance.resolveByText("Показать ещё")} (${total - shown})',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGrid(List<SharedFileItem> items) {
    if (items.isEmpty) {
      return _buildEmptyPlaceholder(
        Icons.image_rounded,
        (AppLocalizations.of(context)?.netMediafaylov_08d2 ?? 'Fallback'),
        (AppLocalizations.of(context)?.zdesBudutOtobrazhatsyaObschieFoto_9bc7 ??
            'Fallback'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isVideo = item.mimeType.startsWith('video/');
        final fileUrl = _getAbsoluteUrl(item.fileUrl);

        return GestureDetector(
          onTap: () => _openMediaViewer(context, fileUrl, isVideo, item: item),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: context.xaneoOverlay(0.04),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isVideo)
                    Center(
                      child: Icon(
                        Icons.videocam_rounded,
                        color: context.xaneoDivider,
                        size: 28,
                      ),
                    )
                  else
                    Image.network(
                      fileUrl,
                      headers: _accessToken != null
                          ? {'Authorization': 'Bearer $_accessToken'}
                          : null,
                      fit: BoxFit.cover,
                      cacheWidth: 320,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_rounded,
                            color: context.xaneoDivider,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  if (isVideo)
                    Container(
                      color: Colors.black26,
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: context.xaneoTextPrimary,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilesList(List<SharedFileItem> items) {
    if (items.isEmpty) {
      return _buildEmptyPlaceholder(
        Icons.description_rounded,
        (AppLocalizations.of(context)?.netFaylov_e95e ?? 'Fallback'),
        (AppLocalizations.of(context)
                ?.zdesBudutOtobrazhatsyaOtpravlennyeFayly_f62c ??
            'Fallback'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final sizeStr = _formatBytes(item.fileSize);
        final dateStr = _formatDate(item.timestamp);
        final fileUrl = _getAbsoluteUrl(item.fileUrl);

        return Container(
          decoration: BoxDecoration(
            color: context.xaneoOverlay(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.xaneoOverlay(0.04),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.xaneoOverlay(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.insert_drive_file_rounded,
                color: context.xaneoTextSecondary,
                size: 20,
              ),
            ),
            title: Text(
              item.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.xaneoTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '$sizeStr • $dateStr',
              style: TextStyle(
                color: context.xaneoTextMuted,
                fontSize: 11,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.download_rounded,
                  color: context.xaneoTextSecondary),
              onPressed: () {
                _downloadFile(context, fileUrl, item.fileName);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceAndVideoList(List<SharedFileItem> items) {
    if (items.isEmpty) {
      return _buildEmptyPlaceholder(
        Icons.mic_rounded,
        (AppLocalizations.of(context)?.netGolosovyhSoobscheniy_2427 ??
            'Fallback'),
        (AppLocalizations.of(context)?.zdesBudutOtobrazhatsyaGolosovyeI_0a73 ??
            'Fallback'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final isVideoMessage = item.messageType == 'video_message';
        final dateStr = _formatDate(item.timestamp);
        final fileUrl = _getAbsoluteUrl(item.fileUrl);
        final sizeStr = _formatBytes(item.fileSize);

        final playbackProvider = context.watch<PlaybackProvider>();
        final isCurrent = playbackProvider.currentAudioUrl == fileUrl;
        final isPlaying = isCurrent && playbackProvider.isPlaying;
        final isLoading = isCurrent && playbackProvider.isLoading;

        return Container(
          decoration: BoxDecoration(
            color: context.xaneoOverlay(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.xaneoOverlay(0.04),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Кнопка воспроизведения — своя зона нажатия
                if (isLoading)
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: context.xaneoTextPrimary),
                  )
                else
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: isVideoMessage
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6366F1),
                      size: 36,
                    ),
                    onPressed: () {
                      final provider = context.read<PlaybackProvider>();
                      provider.play(
                        fileUrl,
                        isVideoMessage
                            ? (AppLocalizations.of(context)
                                    ?.videosoobschenie_2951 ??
                                'Fallback')
                            : (AppLocalizations.of(context)
                                    ?.golosovoeSoobschenie_33d5 ??
                                'Fallback'),
                        dateStr,
                        mimeType: item.mimeType,
                      );
                    },
                  ),
                const SizedBox(width: 10),
                // Текстовая часть — нажатие ведёт к сообщению в чате
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).pop(item.serverMessageId);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isVideoMessage
                              ? (AppLocalizations.of(context)
                                      ?.videosoobschenie_2951 ??
                                  'Fallback')
                              : (AppLocalizations.of(context)
                                      ?.golosovoeSoobschenie_33d5 ??
                                  'Fallback'),
                          style: TextStyle(
                            color: context.xaneoTextPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$sizeStr • $dateStr',
                          style: TextStyle(
                            color: context.xaneoTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Иконка перехода к сообщению
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).pop(item.serverMessageId);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: context.xaneoOverlay(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLinksList(List<SharedLinkItem> items) {
    if (items.isEmpty) {
      return _buildEmptyPlaceholder(
        Icons.link_rounded,
        (AppLocalizations.of(context)?.netSsylok_b0ec ?? 'Fallback'),
        (AppLocalizations.of(context)
                ?.zdesBudutOtobrazhatsyaObschieSsylki_6b61 ??
            'Fallback'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final dateStr = _formatDate(item.timestamp);

        return Container(
          decoration: BoxDecoration(
            color: context.xaneoOverlay(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.xaneoOverlay(0.04),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.xaneoOverlay(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.link_rounded,
                color: Color(0xFF60A5FA),
                size: 20,
              ),
            ),
            title: Text(
              item.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF60A5FA),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.text.trim() != item.url.trim()) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.xaneoTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: context.xaneoTextMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            onTap: () {
              Clipboard.setData(ClipboardData(text: item.url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text((AppLocalizations.of(context)
                          ?.ssylkaSkopirovanaVBufer_c16e ??
                      'Fallback')),
                  duration: const Duration(seconds: 1),
                  backgroundColor: const Color(0xFF1E1E22),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMusicList(List<SharedFileItem> items) {
    if (items.isEmpty) {
      return _buildEmptyPlaceholder(
        Icons.music_note_rounded,
        (AppLocalizations.of(context)?.netMuzyki_1ca3 ?? 'Fallback'),
        (AppLocalizations.of(context)
                ?.zdesBudutOtobrazhatsyaOtpravlennyeTreki_ea23 ??
            'Fallback'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final sizeStr = _formatBytes(item.fileSize);
        final dateStr = _formatDate(item.timestamp);
        final fileUrl = _getAbsoluteUrl(item.fileUrl);

        final playbackProvider = context.watch<PlaybackProvider>();
        final isCurrent = playbackProvider.currentAudioUrl == fileUrl;
        final isPlaying = isCurrent && playbackProvider.isPlaying;
        final isLoading = isCurrent && playbackProvider.isLoading;

        return Container(
          decoration: BoxDecoration(
            color: context.xaneoOverlay(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.xaneoOverlay(0.04),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: isLoading
                ? Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: context.xaneoTextPrimary),
                  )
                : IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 36,
                    ),
                    onPressed: () {
                      final provider = context.read<PlaybackProvider>();
                      provider.play(
                        fileUrl,
                        item.fileName,
                        sizeStr,
                        mimeType: item.mimeType,
                      );
                    },
                  ),
            title: Text(
              item.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.xaneoTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '$sizeStr • $dateStr',
              style: TextStyle(
                color: context.xaneoTextMuted,
                fontSize: 11,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyPlaceholder(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.xaneoOverlay(0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.xaneoOverlay(0.02),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.xaneoOverlay(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: context.xaneoOverlay(0.18),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: context.xaneoTextSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.xaneoOverlay(0.35),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getAbsoluteUrl(String fileUrlSuffix) {
    if (fileUrlSuffix.isEmpty) return '';
    if (fileUrlSuffix.startsWith('http')) {
      final token = _accessToken;
      return '$fileUrlSuffix${token != null ? (fileUrlSuffix.contains('?') ? "&token=$token" : "?token=$token") : ""}';
    }

    final uri = Uri.parse(AppConfig.apiBaseUrl);
    final hostUrl =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}';
    final prefix = fileUrlSuffix.startsWith('/') ? '' : '/';
    final token = _accessToken;

    return '$hostUrl$prefix$fileUrlSuffix${token != null ? "?token=$token" : ""}';
  }

  static List<SharedFileItem> _extractFileItemsInBackground(Message message) {
    if (message.fileUrl == null || message.fileUrl!.isEmpty) return [];
    try {
      final parsed = jsonDecode(message.fileUrl!);
      if (parsed is! Map) return [];

      if (parsed['type'] == 'collage') {
        final filesList = parsed['files'];
        if (filesList is List) {
          return filesList.map((item) {
            final map = Map<String, dynamic>.from(item);
            final fId = map['file_id']?.toString() ?? '';
            String fUrl = map['file_url']?.toString() ?? '';
            if (fUrl.isEmpty && fId.isNotEmpty) {
              fUrl = '/api/files/download/$fId/';
            }
            return SharedFileItem(
              fileId: fId,
              fileName: map['file_name']?.toString() ?? 'file',
              fileSize: map['file_size'] as int? ?? 0,
              mimeType:
                  map['mime_type']?.toString() ?? 'application/octet-stream',
              fileUrl: fUrl,
              timestamp: message.timestamp,
              senderId: message.senderId,
              messageType: map['type']?.toString() ?? message.messageType,
              serverMessageId: message.serverMessageId,
            );
          }).toList();
        }
      } else {
        final fId = parsed['file_id']?.toString() ?? '';
        String fUrl = parsed['file_url']?.toString() ?? '';
        if (fUrl.isEmpty && fId.isNotEmpty) {
          fUrl = '/api/files/download/$fId/';
        }
        return [
          SharedFileItem(
            fileId: fId,
            fileName: parsed['file_name']?.toString() ?? 'file',
            fileSize: parsed['file_size'] as int? ?? 0,
            mimeType:
                parsed['mime_type']?.toString() ?? 'application/octet-stream',
            fileUrl: fUrl,
            timestamp: message.timestamp,
            senderId: message.senderId,
            messageType: parsed['type']?.toString() ?? message.messageType,
            serverMessageId: message.serverMessageId,
          )
        ];
      }
    } catch (_) {}
    return [];
  }

  static final RegExp _urlRegex = RegExp(
    r'(https?:\/\/[^\s]+)',
    caseSensitive: false,
  );

  static List<SharedLinkItem> _extractLinksInBackground(Message message) {
    if (message.textContent.isEmpty) return [];
    if (message.textContent.trim().startsWith('{')) return [];

    final matches = _urlRegex.allMatches(message.textContent);
    if (matches.isEmpty) return [];

    return matches.map((match) {
      return SharedLinkItem(
        url: match.group(0)!,
        text: message.textContent,
        timestamp: message.timestamp,
        senderId: message.senderId,
      );
    }).toList();
  }

  static bool _isMusicExtensionInBackground(String filename) {
    final lower = filename.toLowerCase();
    return lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.flac') ||
        lower.endsWith('.aac') ||
        lower.endsWith('.wma') ||
        lower.endsWith('.ogg');
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return '${d.toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  /// Парсит градиент из строки (поддерживает "Hex1,Hex2")
  List<Color> _parseGradientColors(String? gradient) {
    if (gradient == null || gradient.isEmpty) {
      return [const Color(0xFF10B981), const Color(0xFF14B8A6)];
    }
    try {
      final parts = gradient.split(RegExp(r'[,|]'));
      return parts.map((part) {
        var colorStr = part.trim();
        if (colorStr.startsWith('#')) {
          colorStr = colorStr.substring(1);
        }
        return Color(int.parse('FF$colorStr', radix: 16));
      }).toList();
    } catch (_) {
      return [const Color(0xFF10B981), const Color(0xFF14B8A6)];
    }
  }

  /// Возвращает статус (в сети, был в сети, участников, бот, избранное)
  Widget _buildStatusWidget() {
    final chat = widget.chat;
    String text = '';
    Color textColor = context.xaneoTextSecondary;
    IconData? icon;

    if (chat.isFavorites) {
      // Статус для "Избранного" не отображается
    } else if (_isDeleted()) {
      text =
          (AppLocalizations.of(context)?.udalennyyAkkaunt_ce47 ?? 'Fallback');
      textColor = context.xaneoTextMuted;
    } else if (chat.isPersonal) {
      if (_isBot()) {
        text = (AppLocalizations.of(context)?.bot_2712 ?? 'Fallback');
        textColor = const Color(0xFF60A5FA); // Blue
        icon = Icons.android_rounded;
      } else {
        text = _formatUserStatus(chat.otherUser);
        if (text == (AppLocalizations.of(context)?.vSeti_d902 ?? 'Fallback')) {
          textColor = const Color(0xFF4ADE80); // Green
        }
      }
    } else if (chat.isGroup) {
      final rawMem = chat.otherUser?['members_count'];
      final membersCount = rawMem is int
          ? rawMem
          : (rawMem is num
              ? rawMem.toInt()
              : int.tryParse(rawMem?.toString() ?? '') ?? 0);
      final rawOnline = chat.otherUser?['online_count'];
      final onlineCount = rawOnline is int
          ? rawOnline
          : (rawOnline is num
              ? rawOnline.toInt()
              : int.tryParse(rawOnline?.toString() ?? '') ?? 0);
      text = _pluralizeParticipants(membersCount);
      if (onlineCount > 0) {
        text +=
            ' • $onlineCount ${AppLocalizations.of(context)?.online ?? 'online'}';
      }
      textColor = context.xaneoTextMuted;
      icon = Icons.people_alt_rounded;
    } else if (chat.isChannel) {
      final rawSub = chat.otherUser?['subscribers_count'];
      final subscribersCount = rawSub is int
          ? rawSub
          : (rawSub is num
              ? rawSub.toInt()
              : int.tryParse(rawSub?.toString() ?? '') ?? 0);
      text = _formatSubscribers(subscribersCount);
      textColor = context.xaneoTextMuted;
      icon = Icons.campaign_rounded;
    }

    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            SizedBox(width: 6),
          ] else if (text ==
              (AppLocalizations.of(context)?.vSeti_d902 ?? 'Fallback')) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: textColor.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Раздел подробностей (телефон, о себе, юзернейм)
  Widget _buildDetailsSection(String? username, String? phone, String? bio) {
    final hasBio = bio != null && bio.isNotEmpty;
    final hasPhone = phone != null && phone.isNotEmpty;
    final hasUsername = username != null && username.isNotEmpty;

    if (!hasBio && !hasPhone && !hasUsername) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: context.xaneoOverlay(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.xaneoOverlay(0.03),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (hasBio) ...[
            _buildInfoTile(
              icon: Icons.info_outline_rounded,
              value: bio,
              label: widget.chat.isGroup || widget.chat.isChannel
                  ? (AppLocalizations.of(context)?.opisanie_38ca ?? 'Fallback')
                  : (AppLocalizations.of(context)?.oSebe_0b3b ?? 'Fallback'),
            ),
            if (hasPhone || hasUsername) _buildDivider(),
          ],
          if (hasPhone) ...[
            _buildInfoTile(
              icon: Icons.phone_outlined,
              value: phone,
              label:
                  (AppLocalizations.of(context)?.mobilnyy_5ac7 ?? 'Fallback'),
            ),
            if (hasUsername) _buildDivider(),
          ],
          if (hasUsername) ...[
            _buildInfoTile(
              icon: Icons.alternate_email_rounded,
              value: username.startsWith('@') ? username : '@$username',
              label: (AppLocalizations.of(context)?.imyaPolzovatelya_6fd4 ??
                  'Fallback'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: context.xaneoOverlay(0.04),
      height: 1,
      indent: 52,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)?.copied ?? 'Copied'}: "$value"'),
              duration: const Duration(seconds: 1),
              backgroundColor: context.xaneoSurfaceElevated,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.xaneoOverlay(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: context.xaneoTextSecondary, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: context.xaneoTextPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        color: context.xaneoTextMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.copy_rounded,
                  color: context.xaneoOverlay(0.2),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isBot() {
    final otherUser = widget.chat.otherUser;
    if (otherUser == null) return false;
    final isBotVal = otherUser['is_bot'];
    if (isBotVal is bool) return isBotVal;
    if (isBotVal is String) return isBotVal.toLowerCase() == 'true';
    final username = otherUser['username']?.toString() ?? '';
    return username.toLowerCase().endsWith('bot');
  }

  bool _isDeleted() {
    final otherUser = widget.chat.otherUser;
    if (otherUser == null) return false;
    final isDeletedVal = otherUser['is_deleted'];
    if (isDeletedVal is bool) return isDeletedVal;
    if (isDeletedVal is String) return isDeletedVal.toLowerCase() == 'true';
    return false;
  }

  String _formatUserStatus(Map<String, dynamic>? otherUser) {
    if (otherUser == null)
      return (AppLocalizations.of(context)?.bylANedavno_168d ?? 'Fallback');

    final isOnlineVal = otherUser['is_online'] ?? otherUser['online'];
    if (isOnlineVal == true ||
        isOnlineVal?.toString().toLowerCase() == 'true') {
      return (AppLocalizations.of(context)?.vSeti_d902 ?? 'Fallback');
    }

    final lastSeenVal = otherUser['last_seen'] ??
        otherUser['last_login'] ??
        otherUser['last_activity'];
    if (lastSeenVal == null)
      return (AppLocalizations.of(context)?.bylANedavno_168d ?? 'Fallback');

    DateTime? lastSeen;
    if (lastSeenVal is String) {
      lastSeen = DateTime.tryParse(lastSeenVal);
    } else if (lastSeenVal is int) {
      lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenVal);
    } else if (lastSeenVal is DateTime) {
      lastSeen = lastSeenVal;
    }

    if (lastSeen == null)
      return (AppLocalizations.of(context)?.bylANedavno_168d ?? 'Fallback');

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 5) {
      return (AppLocalizations.of(context)?.vSeti_d902 ?? 'Fallback');
    }

    if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)?.lastSeenRecently ??
          'last seen recently';
    }

    final today = DateTime(now.year, now.month, now.day);
    final lastSeenDay = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);

    final hour = lastSeen.hour.toString().padLeft(2, '0');
    final minute = lastSeen.minute.toString().padLeft(2, '0');

    if (lastSeenDay == today) {
      return '${AppLocalizations.of(context)?.today ?? 'Today'} • $hour:$minute';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (lastSeenDay == yesterday) {
      return '${AppLocalizations.of(context)?.yesterday ?? 'Yesterday'} • $hour:$minute';
    }

    final day = lastSeen.day.toString().padLeft(2, '0');
    final month = lastSeen.month.toString().padLeft(2, '0');
    return '$day.$month.${lastSeen.year} • $hour:$minute';
  }

  String _pluralizeParticipants(int count) {
    return AppLocalizations.of(context)?.membersCount(count) ??
        '$count members';
  }

  String _formatSubscribers(int count) {
    return AppLocalizations.of(context)?.subscribersCount(count) ??
        '$count subscribers';
  }
}

/// Результат разбора сообщений чата по категориям вложений.
class _SharedItemsBuckets {
  final List<SharedFileItem> media;
  final List<SharedFileItem> files;
  final List<SharedFileItem> voice;
  final List<SharedFileItem> music;
  final List<SharedLinkItem> links;

  const _SharedItemsBuckets({
    required this.media,
    required this.files,
    required this.voice,
    required this.music,
    required this.links,
  });
}

class SharedFileItem {
  final String fileId;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String fileUrl;
  final DateTime timestamp;
  final String senderId;
  final String? messageType;
  final String? serverMessageId;

  SharedFileItem({
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.fileUrl,
    required this.timestamp,
    required this.senderId,
    this.messageType,
    this.serverMessageId,
  });
}

class SharedLinkItem {
  final String url;
  final String text;
  final DateTime timestamp;
  final String senderId;

  SharedLinkItem({
    required this.url,
    required this.text,
    required this.timestamp,
    required this.senderId,
  });
}
