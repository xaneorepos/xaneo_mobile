import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import 'avatar_widget.dart';
import 'base_custom_modal.dart';

/// Модалка информации о чате (собеседник, группа, канал, бот, избранное).
class ChatInfoModal extends BaseCustomModal {
  final ChatModel chat;

  const ChatInfoModal({
    super.key,
    required this.chat,
  });

  /// Вспомогательный статический метод для показа модалки
  static Future<String?> show(BuildContext context, ChatModel chat) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (context) => ChatInfoModal(chat: chat),
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

  @override
  void initState() {
    super.initState();
    // Запускаем загрузку данных и расшифровку ТОЛЬКО после завершения 300мс анимации вылета модалки,
    // чтобы не блокировать UI-поток во время анимации скольжения.
    Future.delayed(const Duration(milliseconds: 320), () {
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

      if (id != null) {
        _subscribeToMessages(repo, id);
        _syncHistoryFromServer(id);
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

  /// Подписка на сообщения чата создаётся ровно один раз.
  /// Раньше watchMessagesForChat() вызывался прямо в build(), из-за чего на
  /// каждый кадр пересоздавался drift-стрим (новый запрос к БД + мигание
  /// ConnectionState.waiting).
  void _subscribeToMessages(LocalChatRepository repo, int localId) {
    _messagesSub?.cancel();
    _messagesSub = repo.watchMessagesForChat(localId).listen((messages) {
      final buckets = _computeSharedItems(messages);
      if (!mounted) return;
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
  _SharedItemsBuckets _computeSharedItems(List<Message> messages) {
    final List<SharedFileItem> mediaList = [];
    final List<SharedFileItem> filesList = [];
    final List<SharedFileItem> voiceList = [];
    final List<SharedFileItem> musicList = [];
    final List<SharedLinkItem> linksList = [];

    for (final message in messages) {
      // Извлекаем файлы
      final files = _extractFileItems(message);
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
        } else if (file.mimeType.startsWith('image/') || file.mimeType.startsWith('video/')) {
          mediaList.add(file);
        } else if (file.mimeType.startsWith('audio/') || _isMusicExtension(file.fileName)) {
          musicList.add(file);
        } else {
          filesList.add(file);
        }
      }

      // Извлекаем ссылки
      final links = _extractLinks(message);
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

        final existingMessages = await localChatRepo.getMessagesByServerIds(msgIds);
        final existingMap = {for (final m in existingMessages) m.serverMessageId: m};

        for (final item in results) {
          final msgId = item['id']?.toString() ?? '';
          if (msgId.isEmpty) continue;
          
          final senderId = item['author_username']?.toString() ?? 'unknown';
          final encryptedText = item['encrypted_text']?.toString() ?? '';
          final timestamp = _parseDateTime(item['created_at']) ?? DateTime.now();

          String? decrypted;
          if (existingMap.containsKey(msgId)) {
            final existingMsg = existingMap[msgId]!;
            final existingText = existingMsg.textContent;
            if (cryptoService.isEncryptedMessage(existingText) && encryptedText.isNotEmpty) {
              decrypted = await cryptoService.decryptChatMessage(encryptedText, widget.chat.id);
              await Future.delayed(Duration.zero);
            } else {
              decrypted = existingText;
            }
          } else if (encryptedText.isNotEmpty) {
            decrypted = await cryptoService.decryptChatMessage(encryptedText, widget.chat.id);
            await Future.delayed(Duration.zero);
          }

          final fileInfoJson = _parseFileInfo(Map<String, dynamic>.from(item), decrypted);
          final messageType = item['message_type']?.toString();
          final messageId = item['message_id']?.toString();
          final completionStatusVal = item['completion_status'] != null ? jsonEncode(item['completion_status']) : null;
          final votesByOptionVal = item['votes_by_option'] != null ? jsonEncode(item['votes_by_option']) : null;

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
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
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
            padding: isCircle ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: isCircle ? Center(child: child) : child,
          ),
        ),
      ),
    );
  }

  void _openMediaViewer(BuildContext context, String url, bool isVideo, {SharedFileItem? item}) {
    String senderName = widget.chat.name;
    String dateStr = '';
    if (item != null) {
      final timeStr = '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';
      final months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
      dateStr = '${item.timestamp.day} ${months[item.timestamp.month - 1]} в $timeStr';
      
      final currentUser = context.read<AuthProvider>().user;
      final isMe = currentUser != null && (item.senderId == currentUser.username || item.senderId == currentUser.id.toString() || item.senderId == 'me');
      final myName = (currentUser?.firstName != null && currentUser!.firstName!.isNotEmpty)
          ? currentUser.firstName!
          : 'Вы';
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
        senderName = item.senderId.isNotEmpty ? item.senderId : widget.chat.name;
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
                    ? FullScreenVideoPlayer(videoUrl: url, jwtToken: _accessToken)
                    : InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Hero(
                          tag: url,
                          child: Image.network(
                            url,
                            headers: _accessToken != null ? {'Authorization': 'Bearer $_accessToken'} : null,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('FULLSCREEN IMAGE LOAD ERROR: $error');
                              debugPrint('FULLSCREEN IMAGE URL: $url');
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, color: Colors.white54, size: 64),
                                    SizedBox(height: 16),
                                    Text('Не удалось загрузить изображение', style: TextStyle(color: Colors.white54)),
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
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 16,
                      right: 16,
                      child: _buildDroplet(
                        isCircle: true,
                        onTap: () {
                          if (item != null) {
                            _downloadFile(context, url, item.fileName);
                          }
                        },
                        child: const Icon(Icons.more_vert, color: Colors.white, size: 22),
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
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateStr,
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
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

  Future<void> _downloadFile(BuildContext context, String url, String fileName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Скачивание $fileName...'), duration: const Duration(seconds: 1)),
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
          SnackBar(content: Text('Файл сохранен: $savePath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка скачивания: $e')),
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
    if ((item['message_type'] == 'call' || item['type'] == 'call') && item['message_data'] != null) {
      return jsonEncode(item['message_data']);
    }
    final hasServerFile = (item['attached_file_id'] != null && item['attached_file_id'].toString().isNotEmpty) ||
                          (item['file_id'] != null && item['file_id'].toString().isNotEmpty) ||
                          (item['file_url'] != null && item['file_url'].toString().isNotEmpty);
    if (hasServerFile && decrypted != null && decrypted.trim().startsWith('{')) {
      try {
        final parsed = jsonDecode(decrypted);
        if (parsed is Map && (parsed['type'] == 'file' || parsed['type'] == 'voice' || parsed['type'] == 'video_message') && parsed['file_id'] != null && parsed['file_id'].toString().isNotEmpty) {
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
            final fName = img['name']?.toString() ?? img['file_name']?.toString() ?? 'file';
            final fSize = img['size'] as int? ?? img['file_size'] as int? ?? 0;
            final fType = img['mime_type']?.toString() ?? img['file_type']?.toString() ?? 'image/jpeg';
            String fUrl = img['url']?.toString() ?? img['file_url']?.toString() ?? '';
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

    final fileId = item['attached_file_id']?.toString() ?? item['file_id']?.toString();
    if (fileId != null && fileId.isNotEmpty) {
      final fileName = item['attached_file_name']?.toString() ?? item['file_name']?.toString() ?? 'file';
      final fileSize = item['attached_file_size'] as int? ?? item['file_size'] as int? ?? 0;
      final fileType = item['attached_file_type']?.toString() ?? item['mime_type']?.toString() ?? 'application/octet-stream';
      String fileUrlSuffix = item['attached_file_url']?.toString() ?? item['file_url']?.toString() ?? '';
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
    final String? username = chat.isFavorites ? null : otherUser?['username']?.toString();
    final String? phone = chat.isFavorites ? null : otherUser?['phone']?.toString();
    
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
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_localChatId == null) {
      return _buildStaticLayout(context, scrollController, username, phone, bio, primaryGlowColor);
    }

    // Ждём первую порцию данных из подписки (см. _subscribeToMessages).
    if (!_sharedItemsReady) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final tabs = [
      {'title': 'Медиа', 'count': _mediaList.length.toString(), 'icon': Icons.image_rounded},
      {'title': 'Файлы', 'count': _filesList.length.toString(), 'icon': Icons.description_rounded},
      {'title': 'Голос', 'count': _voiceList.length.toString(), 'icon': Icons.mic_rounded},
      {'title': 'Музыка', 'count': _musicList.length.toString(), 'icon': Icons.music_note_rounded},
      {'title': 'Ссылки', 'count': _linksList.length.toString(), 'icon': Icons.link_rounded},
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
      {'title': 'Медиа', 'count': '0', 'icon': Icons.image_rounded},
      {'title': 'Файлы', 'count': '0', 'icon': Icons.description_rounded},
      {'title': 'Голос', 'count': '0', 'icon': Icons.mic_rounded},
      {'title': 'Музыка', 'count': '0', 'icon': Icons.music_note_rounded},
      {'title': 'Ссылки', 'count': '0', 'icon': Icons.link_rounded},
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
        _buildEmptyPlaceholder(
          Icons.cloud_off_rounded,
          'Нет данных',
          'История сообщений пуста или чат еще не сохранен локально',
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, Color primaryGlowColor) {
    final chat = widget.chat;
    return Column(
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
                  username: chat.name,
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
                chat.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: _buildStatusWidget(),
          ),
        ],
      );
  }

  Widget _buildSharedMediaTabsHeader(List<Map<String, dynamic>> tabsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Общие материалы',
            style: TextStyle(
              color: Colors.white70,
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
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
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
                      color: isSelected ? Colors.white.withOpacity(0.06) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tab['title'].toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tab['count'].toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.white.withOpacity(0.3),
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
    switch (index) {
      case 0:
        return _buildMediaGrid(mediaList);
      case 1:
        return _buildFilesList(filesList);
      case 2:
        return _buildVoiceAndVideoList(voiceList);
      case 3:
        return _buildMusicList(musicList);
      case 4:
        return _buildLinksList(linksList);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMediaGrid(List<SharedFileItem> items) {
    if (items.isEmpty) {
      return _buildEmptyPlaceholder(
        Icons.image_rounded,
        'Нет медиафайлов',
        'Здесь будут отображаться общие фото и видео',
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
              color: Colors.white.withOpacity(0.04),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    fileUrl,
                    headers: _accessToken != null ? {'Authorization': 'Bearer $_accessToken'} : null,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          isVideo ? Icons.videocam_rounded : Icons.image_rounded,
                          color: Colors.white24,
                          size: 28,
                        ),
                      );
                    },
                  ),
                  if (isVideo)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white,
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
        'Нет файлов',
        'Здесь будут отображаться отправленные файлы',
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
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.insert_drive_file_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
            title: Text(
              item.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '$sizeStr • $dateStr',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.white70),
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
        'Нет голосовых сообщений',
        'Здесь будут отображаться голосовые и видеосообщения',
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
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
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
                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                else
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: isVideoMessage ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                      size: 36,
                    ),
                    onPressed: () {
                      final provider = context.read<PlaybackProvider>();
                      provider.play(
                        fileUrl,
                        isVideoMessage ? 'Видеосообщение' : 'Голосовое сообщение',
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
                          isVideoMessage ? 'Видеосообщение' : 'Голосовое сообщение',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$sizeStr • $dateStr',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
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
                      color: Colors.white.withOpacity(0.3),
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
        'Нет ссылок',
        'Здесь будут отображаться общие ссылки',
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
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
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
              style: const TextStyle(
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
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            onTap: () {
              Clipboard.setData(ClipboardData(text: item.url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ссылка скопирована в буфер'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: const Color(0xFF1E1E22),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        'Нет музыки',
        'Здесь будут отображаться отправленные треки',
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
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: isLoading
                ? Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(8),
                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '$sizeStr • $dateStr',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
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
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.02),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.18),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
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
    final hostUrl = '${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}';
    final prefix = fileUrlSuffix.startsWith('/') ? '' : '/';
    final token = _accessToken;
    
    return '$hostUrl$prefix$fileUrlSuffix${token != null ? "?token=$token" : ""}';
  }

  List<SharedFileItem> _extractFileItems(Message message) {
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
              mimeType: map['mime_type']?.toString() ?? 'application/octet-stream',
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
            mimeType: parsed['mime_type']?.toString() ?? 'application/octet-stream',
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

  final urlRegex = RegExp(
    r'(https?:\/\/[^\s]+)',
    caseSensitive: false,
  );

  List<SharedLinkItem> _extractLinks(Message message) {
    if (message.textContent.isEmpty) return [];
    if (message.textContent.trim().startsWith('{')) return [];
    
    final matches = urlRegex.allMatches(message.textContent);
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

  bool _isMusicExtension(String filename) {
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
    Color textColor = Colors.white70;
    IconData? icon;

    if (chat.isFavorites) {
      // Статус для "Избранного" не отображается
    } else if (_isDeleted()) {
      text = 'удалённый аккаунт';
      textColor = Colors.white38;
    } else if (chat.isPersonal) {
      if (_isBot()) {
        text = 'бот';
        textColor = const Color(0xFF60A5FA); // Blue
        icon = Icons.android_rounded;
      } else {
        text = _formatUserStatus(chat.otherUser);
        if (text == 'в сети') {
          textColor = const Color(0xFF4ADE80); // Green
        }
      }
    } else if (chat.isGroup) {
      final rawMem = chat.otherUser?['members_count'];
      final membersCount = rawMem is int ? rawMem : (rawMem is num ? rawMem.toInt() : int.tryParse(rawMem?.toString() ?? '') ?? 0);
      final rawOnline = chat.otherUser?['online_count'];
      final onlineCount = rawOnline is int ? rawOnline : (rawOnline is num ? rawOnline.toInt() : int.tryParse(rawOnline?.toString() ?? '') ?? 0);
      text = _pluralizeParticipants(membersCount);
      if (onlineCount > 0) {
        text += ', $onlineCount в сети';
      }
      textColor = Colors.white54;
      icon = Icons.people_alt_rounded;
    } else if (chat.isChannel) {
      final rawSub = chat.otherUser?['subscribers_count'];
      final subscribersCount = rawSub is int ? rawSub : (rawSub is num ? rawSub.toInt() : int.tryParse(rawSub?.toString() ?? '') ?? 0);
      text = _formatSubscribers(subscribersCount);
      textColor = Colors.white54;
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
            const SizedBox(width: 6),
          ] else if (text == 'в сети') ...[
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
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.03),
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
              label: widget.chat.isGroup || widget.chat.isChannel ? 'Описание' : 'О себе',
            ),
            if (hasPhone || hasUsername) _buildDivider(),
          ],
          if (hasPhone) ...[
            _buildInfoTile(
              icon: Icons.phone_outlined,
              value: phone,
              label: 'Мобильный',
            ),
            if (hasUsername) _buildDivider(),
          ],
          if (hasUsername) ...[
            _buildInfoTile(
              icon: Icons.alternate_email_rounded,
              value: username.startsWith('@') ? username : '@$username',
              label: 'Имя пользователя',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.04),
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
              content: Text('"$value" скопировано в буфер'),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF1E1E22),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white70, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
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
                  color: Colors.white.withOpacity(0.2),
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
    if (otherUser == null) return 'был(-а) недавно';
    
    final isOnlineVal = otherUser['is_online'] ?? otherUser['online'];
    if (isOnlineVal == true || isOnlineVal?.toString().toLowerCase() == 'true') {
      return 'в сети';
    }
    
    final lastSeenVal = otherUser['last_seen'] ?? otherUser['last_login'] ?? otherUser['last_activity'];
    if (lastSeenVal == null) return 'был(-а) недавно';
    
    DateTime? lastSeen;
    if (lastSeenVal is String) {
      lastSeen = DateTime.tryParse(lastSeenVal);
    } else if (lastSeenVal is int) {
      lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenVal);
    } else if (lastSeenVal is DateTime) {
      lastSeen = lastSeenVal;
    }
    
    if (lastSeen == null) return 'был(-а) недавно';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 5) {
      return 'в сети';
    }
    
    if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      String minStr;
      if (mins % 10 == 1 && mins % 100 != 11) {
        minStr = 'минуту';
      } else if ([2, 3, 4].contains(mins % 10) && ![12, 13, 14].contains(mins % 100)) {
        minStr = 'минуты';
      } else {
        minStr = 'минут';
      }
      return 'был(-а) в сети $mins $minStr назад';
    }
    
    final today = DateTime(now.year, now.month, now.day);
    final lastSeenDay = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);
    
    final hour = lastSeen.hour.toString().padLeft(2, '0');
    final minute = lastSeen.minute.toString().padLeft(2, '0');
    
    if (lastSeenDay == today) {
      return 'был(-а) в сети сегодня в $hour:$minute';
    }
    
    final yesterday = today.subtract(const Duration(days: 1));
    if (lastSeenDay == yesterday) {
      return 'был(-а) в сети вчера в $hour:$minute';
    }
    
    final day = lastSeen.day.toString().padLeft(2, '0');
    final month = lastSeen.month.toString().padLeft(2, '0');
    return 'был(-а) в сети $day.$month.${lastSeen.year} в $hour:$minute';
  }

  String _pluralizeParticipants(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return '$count участник';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return '$count участника';
    } else {
      return '$count участников';
    }
  }

  String _formatSubscribers(int count) {
    String countStr;
    if (count >= 1000000000) {
      countStr = '${(count / 1000000000.0).toStringAsFixed(1).replaceAll('.0', '')}B';
    } else if (count >= 1000000) {
      countStr = '${(count / 1000000.0).toStringAsFixed(1).replaceAll('.0', '')}M';
    } else if (count >= 1000) {
      countStr = '${(count / 1000.0).toStringAsFixed(1).replaceAll('.0', '')}K';
    } else {
      countStr = count.toString();
    }

    if (count % 10 == 1 && count % 100 != 11) {
      return '$countStr подписчик';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return '$countStr подписчика';
    } else {
      return '$countStr подписчиков';
    }
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
