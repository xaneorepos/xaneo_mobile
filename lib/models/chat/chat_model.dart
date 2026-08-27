import 'dart:convert';

/// Восстанавливает тип preview, когда WebSocket/API присылает файл
/// без message_type, но с file_id/images/MIME-метаданными.
String? inferChatMessageType(
  Map<String, dynamic> payload, {
  String? fallback,
}) {
  String? normalize(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? normalizeFileType(dynamic value) {
    final type = normalize(value);
    if (type == null) return null;
    if (type == 'voice' || type == 'voice_message') return 'voice';
    if (type == 'video_message') return 'video_message';
    if (type == 'video' || type.startsWith('video/')) return 'video';
    if (type == 'image' || type == 'photo' || type.startsWith('image/')) {
      return 'image';
    }
    if (type == 'audio' || type == 'music' || type.startsWith('audio/')) {
      return 'audio';
    }
    if (type == 'document' || type == 'attachment') return 'file';
    return type;
  }

  var result = normalize(payload['message_type']) ??
      normalize(payload['last_message_type']) ??
      normalize(fallback);
  result = normalizeFileType(result);
  if (result != null && result != 'file') return result;

  final images = payload['images'];
  if (images is List && images.isNotEmpty) {
    if (images.length > 1) return 'collage';
    final first = images.first;
    if (first is Map) {
      result = normalizeFileType(
        first['file_type'] ?? first['type'] ?? first['mime_type'],
      );
      if (result != null) return result;
    }
    return 'image';
  }

  final files = payload['files'];
  if (files is List && files.isNotEmpty) {
    final first = files.first;
    if (first is Map) {
      result = normalizeFileType(
        first['file_type'] ?? first['type'] ?? first['mime_type'],
      );
      if (result != null) return result;
    }
    return 'file';
  }

  if (payload['image'] != null) return 'image';
  if (payload['file_id'] != null ||
      payload['attached_file_id'] != null ||
      payload['file_url'] != null) {
    return normalizeFileType(
          payload['file_type'] ?? payload['mime_type'],
        ) ??
        'file';
  }

  return result;
}

/// Модель чата
class ChatModel {
  final String id;
  final String name;
  final String? avatar;
  final String? avatarGradient;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isGroup;
  final bool isChannel;
  final bool isPersonal;
  final bool isFavorites;
  final Map<String, dynamic>? otherUser;
  final bool isEncrypted;
  final bool isArchived;
  final DateTime? archivedAt;
  final String? lastMessageType;
  final bool groupCallsEnabled;
  final Map<String, dynamic> raw;

  bool get isPinned => raw['is_pinned'] == true;
  bool get isMuted => raw['is_muted'] == true;

  ChatModel({
    required this.id,
    required this.name,
    this.avatar,
    this.avatarGradient,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isGroup = false,
    this.isChannel = false,
    this.isPersonal = false,
    this.isFavorites = false,
    this.otherUser,
    this.isEncrypted = false,
    this.isArchived = false,
    this.archivedAt,
    this.lastMessageType,
    this.groupCallsEnabled = true,
    this.raw = const {},
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // Обрабатываем разные форматы ответа API
    final chatId = json['chat_id']?.toString() ?? json['id']?.toString() ?? '';
    final chatType = json['chat_type']?.toString() ?? '';
    final displayName =
        json['chat_display_name'] ?? json['name'] ?? json['title'] ?? 'Unknown';

    // Для личных чатов используем other_user
    String chatName = displayName;
    String? avatarUrl;
    String? avatarGrad;
    if (json['other_user'] != null && json['other_user'] is Map) {
      final otherUser = json['other_user'] as Map<String, dynamic>;
      chatName = otherUser['first_name']?.toString() ??
          otherUser['username']?.toString() ??
          displayName;
      // Безопасная проверка типа для avatar_url
      if (otherUser['avatar_url'] is String) {
        avatarUrl = otherUser['avatar_url'] as String;
      }
      // Градиент аватара
      if (otherUser['avatar_gradient'] is String) {
        avatarGrad = otherUser['avatar_gradient'] as String;
      }
    }

    // Безопасная проверка для avatar
    String? avatar;
    if (avatarUrl != null) {
      avatar = avatarUrl;
    } else if (json['avatar_url'] is String) {
      avatar = json['avatar_url'] as String;
    } else if (json['avatar'] is String) {
      avatar = json['avatar'] as String;
    } else if (json['image'] is String) {
      avatar = json['image'] as String;
    }

    // Градиент аватара для групп/каналов (из корня JSON)
    if (avatarGrad == null && json['avatar_gradient'] is String) {
      avatarGrad = json['avatar_gradient'] as String;
    }

    final isPersonal = chatType == 'personal';
    final isGroup = chatType == 'group';
    final isChannel = chatType == 'channel';

    // Определяем, является ли чат Избранным
    final isFavorites = chatId == 'favorites' ||
        chatId.startsWith('favorites_user_') ||
        displayName == 'Избранное' ||
        json['is_bookmark'] == true ||
        json['is_favorites'] == true;

    // Для Избранного устанавливаем фиолетовый градиент если не передан
    if (isFavorites && avatarGrad == null) {
      avatarGrad = '8B5CF6,6366F1';
    }

    // Получаем зашифрованный текст сообщения
    String? encryptedText;
    if (json['last_message'] is Map) {
      encryptedText = json['last_message']['encrypted_text']?.toString();
    } else if (json['lastMessage'] is Map) {
      encryptedText = json['lastMessage']['encrypted_text']?.toString();
    }

    // Получаем тип сообщения
    String? messageType;
    if (json['last_message'] is Map) {
      messageType = json['last_message']['message_type']?.toString();
    } else if (json['lastMessage'] is Map) {
      messageType = json['lastMessage']['message_type']?.toString();
    }

    messageType ??= json['last_message_type']?.toString() ??
        json['message_type']?.toString();

    final lastMsgMap = json['last_message'] is Map
        ? json['last_message'] as Map<String, dynamic>
        : json['lastMessage'] is Map
            ? json['lastMessage'] as Map<String, dynamic>
            : null;
    if (lastMsgMap != null) {
      messageType = inferChatMessageType(lastMsgMap, fallback: messageType);
      final filesList = lastMsgMap['files'] as List<dynamic>? ?? [];
      final hasServerFile = filesList.isNotEmpty ||
          (lastMsgMap['attached_file_id'] != null &&
              lastMsgMap['attached_file_id'].toString().isNotEmpty) ||
          (lastMsgMap['file_id'] != null &&
              lastMsgMap['file_id'].toString().isNotEmpty) ||
          (lastMsgMap['file_url'] != null &&
              lastMsgMap['file_url'].toString().isNotEmpty) ||
          (lastMsgMap['image'] != null &&
              lastMsgMap['image'].toString().isNotEmpty) ||
          (lastMsgMap['images'] is List &&
              (lastMsgMap['images'] as List).isNotEmpty);

      if (hasServerFile) {
        if (messageType != 'todo_list' && messageType != 'poll') {
          String detectedType = 'file';
          if (filesList.isNotEmpty) {
            final firstFile = filesList[0];
            if (firstFile is Map) {
              final fType = (firstFile['file_type'] ??
                          firstFile['type'] ??
                          firstFile['mime_type'])
                      ?.toString()
                      .toLowerCase() ??
                  '';
              if (fType == 'voice' || fType == 'voice_message') {
                detectedType = 'voice';
              } else if (fType == 'video' || fType == 'video_message') {
                detectedType = 'video_message';
              } else if (fType == 'image' || fType.startsWith('image/')) {
                detectedType = 'image';
              }
            }
          }
          messageType = detectedType;
        }
      }
    }

    String? lastMsg;
    bool isEncrypted = false;

    if (encryptedText != null && encryptedText.isNotEmpty) {
      // Это зашифрованное сообщение XSEC-2
      lastMsg = encryptedText;
      isEncrypted = true;
    } else {
      // Пробуем получить plaintext
      final rawLastMsg = json['last_message'] ??
          json['lastMessage'] ??
          json['latest_message'] ??
          json['last_message_content'] ??
          json['message_preview'] ??
          json['preview'] ??
          json['message'];

      if (rawLastMsg is String) {
        lastMsg = rawLastMsg;
      } else if (rawLastMsg is Map) {
        final textCandidate = rawLastMsg['text'] ??
            rawLastMsg['message'] ??
            rawLastMsg['content'] ??
            rawLastMsg['body'] ??
            rawLastMsg['encrypted_text'];
        if (textCandidate is String && textCandidate.isNotEmpty) {
          lastMsg = textCandidate;
          isEncrypted = _isEncryptedMessage(textCandidate);
        } else {
          lastMsg = jsonEncode(rawLastMsg);
        }
      } else if (rawLastMsg != null) {
        lastMsg = rawLastMsg.toString();
      }
    }

    // Дополнительная проверка на шифрование
    if (!isEncrypted && lastMsg != null) {
      isEncrypted = _isEncryptedMessage(lastMsg);
    }

    // Извлекаем время последнего сообщения из разных возможных полей.
    // Важно: не останавливаемся на первом поле, если оно не распарсилось.
    DateTime? lastMsgTime;

    final candidates = <dynamic>[
      json['last_message_time'],
      if (json['last_message'] is Map)
        (json['last_message'] as Map<String, dynamic>)['timestamp'] ??
            (json['last_message'] as Map<String, dynamic>)['created_at'] ??
            (json['last_message'] as Map<String, dynamic>)['time'] ??
            (json['last_message'] as Map<String, dynamic>)['sent_at'],
      json['last_message_timestamp'],
      json['last_activity'],
    ];

    for (final candidate in candidates) {
      final parsed = _parseApiDateTime(candidate);
      if (parsed != null) {
        lastMsgTime = parsed;
        break;
      }
    }

    final Map<String, dynamic> otherUserMap = json['other_user'] is Map
        ? Map<String, dynamic>.from(json['other_user'] as Map)
        : <String, dynamic>{};

    int? _parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    final rawMem = _parseInt(json['members_count']) ??
        _parseInt(json['membersCount']) ??
        _parseInt(json['member_count']) ??
        _parseInt(otherUserMap['members_count']);
    if (rawMem != null) {
      otherUserMap['members_count'] = rawMem;
    }

    final rawOnline = _parseInt(json['online_count']) ??
        _parseInt(json['onlineCount']) ??
        _parseInt(json['online_members_count']) ??
        _parseInt(otherUserMap['online_count']);
    if (rawOnline != null) {
      otherUserMap['online_count'] = rawOnline;
    }

    final rawSub = _parseInt(json['subscribers_count']) ??
        _parseInt(json['subscribersCount']) ??
        _parseInt(json['subscriber_count']) ??
        _parseInt(json['members_count']) ??
        _parseInt(otherUserMap['subscribers_count']);
    if (rawSub != null) {
      otherUserMap['subscribers_count'] = rawSub;
    }

    final isArchived = json['is_archived'] == true;
    final archivedAt = _parseApiDateTime(json['archived_at']);
    final rawCallsEnabled = json['group_calls_enabled'] ??
        (json['other_user'] is Map
            ? json['other_user']['group_calls_enabled']
            : null);
    final groupCallsEnabled = rawCallsEnabled != null
        ? (rawCallsEnabled == true ||
            rawCallsEnabled == 1 ||
            rawCallsEnabled == 'true')
        : true;

    return ChatModel(
      id: chatId,
      name: chatName,
      avatar: avatar,
      avatarGradient: avatarGrad,
      lastMessage: lastMsg,
      lastMessageTime: lastMsgTime,
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
      isGroup: isGroup,
      isChannel: isChannel,
      isPersonal: isPersonal,
      isFavorites: isFavorites,
      isEncrypted: isEncrypted,
      isArchived: isArchived,
      archivedAt: archivedAt,
      lastMessageType: messageType,
      otherUser: otherUserMap.isNotEmpty ? otherUserMap : null,
      groupCallsEnabled: groupCallsEnabled,
      raw: json,
    );
  }

  ChatModel copyWith({
    String? id,
    String? name,
    String? avatar,
    String? avatarGradient,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isGroup,
    bool? isChannel,
    bool? isPersonal,
    bool? isFavorites,
    bool? isEncrypted,
    bool? isArchived,
    DateTime? archivedAt,
    String? lastMessageType,
    Map<String, dynamic>? otherUser,
    bool? groupCallsEnabled,
    Map<String, dynamic>? raw,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      avatarGradient: avatarGradient ?? this.avatarGradient,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      isChannel: isChannel ?? this.isChannel,
      isPersonal: isPersonal ?? this.isPersonal,
      isFavorites: isFavorites ?? this.isFavorites,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      otherUser: otherUser ?? this.otherUser,
      groupCallsEnabled: groupCallsEnabled ?? this.groupCallsEnabled,
      raw: raw ?? this.raw,
    );
  }

  /// Получить инициалы для аватара
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.isNotEmpty) return name[0].toUpperCase();
    return '?';
  }

  /// Форматировать время последнего сообщения
  String get formattedTime {
    if (lastMessageTime == null) return '';

    try {
      final now = DateTime.now();
      final diff = now.difference(lastMessageTime!);

      if (diff.inMinutes < 1) {
        return 'сейчас';
      } else if (diff.inHours < 1) {
        return '${diff.inMinutes}м';
      } else if (diff.inDays < 1) {
        return '${diff.inHours}ч';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}д';
      } else {
        return '${lastMessageTime!.day}.${lastMessageTime!.month}';
      }
    } catch (e) {
      final h = lastMessageTime!.hour.toString().padLeft(2, '0');
      final m = lastMessageTime!.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
  }

  /// Проверить, является ли сообщение зашифрованным
  bool get isEncryptedMessage {
    if (lastMessage == null || lastMessage!.isEmpty) return false;
    return _isEncryptedMessage(lastMessage!);
  }

  /// Проверить, является ли строка зашифрованным сообщением XSEC-2
  /// Формат: base64(12 bytes IV/nonce + ciphertext)
  static bool _isEncryptedMessage(String text) {
    if (text.isEmpty) return false;

    try {
      final trimmed = text.trim();

      // JSON не является зашифрованным сообщением
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        return false;
      }

      // Пробуем декодировать как base64
      var normalized = trimmed
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .replaceAll('-', '+')
          .replaceAll('_', '/');

      final pad = normalized.length % 4;
      if (pad == 2) {
        normalized += '==';
      } else if (pad == 3) {
        normalized += '=';
      }

      final decoded = base64Decode(normalized);

      // Минимальная длина: 12 байт nonce + 16 байт tag (AES-GCM)
      if (decoded.length < 28) return false;

      // Проверяем что это не читаемый текст
      try {
        utf8.decode(decoded);
        return false; // Если получилось декодировать как UTF-8 - это plaintext
      } catch (_) {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  static bool _looksLikeStructuredPayload(String text) {
    final trimmed = text.trim();

    // Проверяем на явные признаки зашифрованного payload
    final hasNonce = RegExp(r'nonce\s*[:=]').hasMatch(trimmed);
    final hasCipher =
        RegExp(r'ciphertext\s*[:=]|encrypted_data\s*[:=]').hasMatch(trimmed);

    if (hasNonce && hasCipher) {
      return true;
    }

    // Если это JSON объект, проверяем что это НЕ обычное сообщение
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final parsed = jsonDecode(trimmed);
        if (parsed is Map) {
          // Если есть поля обычного сообщения (id, creator_id, message_type),
          // это НЕ зашифрованный payload
          if (parsed.containsKey('id') ||
              parsed.containsKey('creator_id') ||
              parsed.containsKey('message_type') ||
              parsed.containsKey('created_at')) {
            return false;
          }
          // Если есть поля зашифрованного сообщения
          if (parsed.containsKey('nonce') ||
              parsed.containsKey('ciphertext') ||
              parsed.containsKey('encrypted_data')) {
            return true;
          }
        }
      } catch (_) {
        // Если не удалось распарсить, считаем что это может быть зашифрованное
        return true;
      }
    }

    return false;
  }

  /// Получить отображаемое сообщение
  /// Для зашифрованных сообщений показываем плейсхолдер
  /// Для пустых групп/каналов показываем "Группа создана"/"Канал создан"
  String get displayMessage {
    if (lastMessage == null || lastMessage!.isEmpty) {
      if (isGroup) return 'Группа создана';
      if (isChannel) return 'Канал создан';
      return '';
    }

    final trimmed = lastMessage!.trim();

    // Проверяем если lastMessage - это JSON объект сообщения
    // И тип сообщения от сервера — один из известных медиа/структурированных типов
    final isStructuredType = lastMessageType == 'voice' ||
        lastMessageType == 'voice_message' ||
        lastMessageType == 'video' ||
        lastMessageType == 'video_message' ||
        lastMessageType == 'todo_list' ||
        lastMessageType == 'poll' ||
        lastMessageType == 'file';

    if (isStructuredType && trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final parsed = jsonDecode(trimmed);
        if (parsed is Map) {
          // Сначала проверяем message_type в корне объекта (для poll/todo)
          final messageType = parsed['message_type']?.toString();

          if (messageType == 'poll') {
            return '📊 Опрос';
          } else if (messageType == 'todo_list') {
            return '✅ Список задач';
          }

          // Затем проверяем type для файлов/голосовых
          final fileType = parsed['type']?.toString();

          if (fileType == 'voice' || fileType == 'voice_message') {
            return '🎙 Голосовое сообщение';
          } else if (fileType == 'video' || fileType == 'video_message') {
            return '📹 Видеосообщение';
          } else if (fileType == 'todo_list') {
            return '✅ Список задач';
          } else if (fileType == 'poll') {
            return '📊 Опрос';
          }

          final mime = (parsed['mime_type'] ?? '').toString().toLowerCase();
          final fileName = (parsed['file_name'] ?? '').toString().toLowerCase();

          final isImage = mime.startsWith('image/') ||
              fileName.endsWith('.jpg') ||
              fileName.endsWith('.jpeg') ||
              fileName.endsWith('.png') ||
              fileName.endsWith('.gif') ||
              fileName.endsWith('.webp') ||
              fileName.endsWith('.bmp') ||
              fileName.endsWith('.svg');

          final isVideo = mime.startsWith('video/') ||
              fileName.endsWith('.mp4') ||
              fileName.endsWith('.avi') ||
              fileName.endsWith('.mov') ||
              fileName.endsWith('.wmv') ||
              fileName.endsWith('.flv') ||
              fileName.endsWith('.webm') ||
              fileName.endsWith('.mkv') ||
              fileName.endsWith('.loc_3gp') ||
              fileName.endsWith('.ogv') ||
              fileName.endsWith('.m4v');

          if (fileType == 'file') {
            if (isImage) {
              return '🖼 Фотография';
            } else if (isVideo) {
              return '📹 Видеозапись';
            } else {
              final originalName = parsed['file_name'] ?? 'Файл';
              return '📁 $originalName';
            }
          }
        }
      } catch (_) {
        // Игнорируем ошибку парсинга
      }
    }

    // Сначала проверяем тип сообщения из API (если был передан отдельно)
    if (lastMessageType != null) {
      switch (lastMessageType) {
        case 'todo_list':
          return '✅ Список задач';
        case 'poll':
          return '📊 Опрос';
        case 'voice':
        case 'voice_message':
          return '🎙 Голосовое сообщение';
        case 'video':
        case 'video_message':
          return '📹 Видеосообщение';
      }
    }

    // Если сообщение зашифровано (base64 payload), проверяем тип
    if (isEncryptedMessage || _looksLikeStructuredPayload(lastMessage!)) {
      // Если известен тип сообщения, показываем его
      if (lastMessageType != null) {
        switch (lastMessageType) {
          case 'todo_list':
            return '🔒 Список задач';
          case 'poll':
            return '🔒 Опрос';
          case 'voice':
          case 'voice_message':
            return '🔒 Голосовое сообщение';
          case 'video':
          case 'video_message':
            return '🔒 Видеосообщение';
          default:
            return 'Зашифрованное сообщение';
        }
      }
      return 'Зашифрованное сообщение';
    }

    return lastMessage!;
  }

  static DateTime? _parseApiDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value.isUtc ? value.toLocal() : value;
    }

    if (value is int) {
      // Поддержка unix timestamp в секундах и миллисекундах.
      final isMilliseconds = value > 100000000000;
      final dateTime = isMilliseconds
          ? DateTime.fromMillisecondsSinceEpoch(value, isUtc: true)
          : DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
      return dateTime.toLocal();
    }

    if (value is double) {
      return _parseApiDateTime(value.toInt());
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;

      final parsedStringDate = DateTime.tryParse(trimmed);
      if (parsedStringDate != null) {
        return parsedStringDate.isUtc
            ? parsedStringDate.toLocal()
            : parsedStringDate;
      }

      final numericValue = int.tryParse(trimmed);
      if (numericValue != null) {
        return _parseApiDateTime(numericValue);
      }
    }

    return null;
  }
}
