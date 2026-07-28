import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../../models/chat/chat_model.dart';
import '../database/app_database.dart';

class LocalChatRepository {
  final AppDatabase _db;
  final String? userId;

  LocalChatRepository(this._db, {this.userId});

  /// Освобождает ресурсы базы данных
  Future<void> dispose() async {
    await _db.close();
  }

  /// Получение всех чатов в виде потока (Stream) для реактивного UI, уже преобразованных в ChatModel.
  Stream<List<ChatModel>> watchAllChats() {
    return (_db.select(_db.chats)
          ..where((c) => c.isArchived.equals(false))
          ..orderBy([(c) => OrderingTerm.desc(c.lastMessageTime)]))
        .watch()
        .map((rows) => rows
            .map(_mapChatToModel)
            .where((chat) {
              if (chat.isGroup || chat.isChannel) {
                return chat.otherUser?['is_member'] != false;
              }
              return true;
            })
            .toList());
  }

  /// Получение архивных чатов в виде потока (Stream)
  Stream<List<ChatModel>> watchArchivedChats() {
    return (_db.select(_db.chats)
          ..where((c) => c.isArchived.equals(true))
          ..orderBy([(c) => OrderingTerm.desc(c.lastMessageTime)]))
        .watch()
        .map((rows) => rows
            .map(_mapChatToModel)
            .where((chat) {
              if (chat.isGroup || chat.isChannel) {
                return chat.otherUser?['is_member'] != false;
              }
              return true;
            })
            .toList());
  }

  /// Обновление статуса архивации чата
  Future<void> updateArchiveStatus(String serverChatId, bool isArchived) async {
    final existing = await (_db.select(_db.chats)
          ..where((c) => c.serverChatId.equals(serverChatId)))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.chats)..where((c) => c.id.equals(existing.id)))
          .write(ChatsCompanion(
            isArchived: Value(isArchived),
            archivedAt: Value(isArchived ? DateTime.now() : null),
          ));
    }
  }

  /// Получение сообщений конкретного чата в виде потока
  Stream<List<Message>> watchMessagesForChat(int chatId) {
    return (_db.select(_db.messages)
          ..where((m) => m.chatId.equals(chatId))
          ..orderBy([
            (m) => OrderingTerm.desc(m.timestamp),
            (m) => OrderingTerm.desc(m.id),
          ]))
        .watch();
  }

  /// Получение списка сообщений для конкретного чата (будущее/Future)
  Future<List<Message>> getMessagesForChat(int chatId) {
    return (_db.select(_db.messages)
          ..where((m) => m.chatId.equals(chatId))
          ..orderBy([
            (m) => OrderingTerm.desc(m.timestamp),
            (m) => OrderingTerm.desc(m.id),
          ]))
        .get();
  }

  /// Получение сообщений конкретного чата по его строковому serverChatId с возможностью лимита
  Stream<List<Message>> watchMessagesForServerChat(String serverChatId, {int? limit}) {
    final query = _db.select(_db.messages).join([
      innerJoin(_db.chats, _db.chats.id.equalsExp(_db.messages.chatId))
    ])
      ..where(_db.chats.serverChatId.equals(serverChatId))
      ..orderBy([
        OrderingTerm.desc(_db.messages.timestamp),
        OrderingTerm.desc(_db.messages.id),
      ]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(_db.messages)).toList();
    });
  }

  /// Получение локального числового ID чата по его строковому serverChatId
  Future<int?> getLocalChatId(String serverChatId) async {
    final row = await (_db.select(_db.chats)
          ..where((c) => c.serverChatId.equals(serverChatId)))
        .getSingleOrNull();
    return row?.id;
  }

  Future<ChatModel?> getChatByServerId(String serverChatId) async {
    final row = await (_db.select(_db.chats)
          ..where((c) => c.serverChatId.equals(serverChatId)))
        .getSingleOrNull();

    if (row == null) return null;
    return _mapChatToModel(row);
  }

  Future<List<ChatModel>> getAllChats() async {
    final rows = await _db.select(_db.chats).get();
    return rows.map(_mapChatToModel).toList();
  }

  Future<int> deleteChatByServerId(String serverChatId) {
    return (_db.delete(_db.chats)
          ..where((c) => c.serverChatId.equals(serverChatId)))
        .go();
  }

  /// Удаление всех сообщений чата из локальной БД
  Future<int> deleteMessagesForChat(int chatId) {
    return (_db.delete(_db.messages)
          ..where((m) => m.chatId.equals(chatId)))
        .go();
  }

  /// Удаление одного сообщения по серверному ID (например, temp-сообщения
  /// оптимистичной отправки при сверке с эхом сервера)
  Future<int> deleteMessageByServerId(String serverMessageId) {
    return (_db.delete(_db.messages)
          ..where((m) => m.serverMessageId.equals(serverMessageId)))
        .go();
  }

  /// Обновление serverMessageId существующего (pending) сообщения в локальной БД без пересоздания
  Future<int> updateMessageServerId(String tempServerId, String newServerId) {
    return (_db.update(_db.messages)
          ..where((m) => m.serverMessageId.equals(tempServerId)))
        .write(MessagesCompanion(serverMessageId: Value(newServerId)));
  }

  /// Пакетное сохранение чатов из API в локальную БД
  Future<void> saveChatsBatch(List<ChatModel> chatModels) async {
    await _db.transaction(() async {
      for (final chatModel in chatModels) {
        await _upsertChat(chatModel);
      }
    });
  }

  /// Сохранение или обновление одного чата
  Future<int> saveChat(ChatModel chatModel) {
    return _upsertChat(chatModel);
  }

  /// Сохранение сообщения
  Future<int> saveMessage(MessagesCompanion message) {
    return _db.into(_db.messages).insert(
      message,
      onConflict: DoUpdate(
        (old) => message,
        target: [_db.messages.serverMessageId],
      ),
    );
  }

  /// Пакетное сохранение сообщений (полезно при загрузке истории)
  Future<void> saveMessagesBatch(List<MessagesCompanion> messages) async {
    if (messages.isEmpty) return;
    await _db.batch((batch) {
      for (final msg in messages) {
        batch.insert(
          _db.messages,
          msg,
          onConflict: DoUpdate(
            (old) => msg,
            target: [_db.messages.serverMessageId],
          ),
        );
      }
    });
  }

  /// Очистка невалидных cached fileUrl для предотвращения эксплуатации E2EE JSON в тексте
  Future<void> cleanupFakeFileMessages(int chatId) async {
    await (_db.update(_db.messages)
          ..where((tbl) => tbl.chatId.equals(chatId))
          ..where((tbl) => tbl.fileUrl.isNotNull())
          ..where((tbl) => tbl.fileUrl.equalsExp(tbl.textContent)))
        .write(const MessagesCompanion(fileUrl: Value(null)));
  }

  /// Получение количества сообщений в чате по его локальному числовому ID
  Future<int> getMessageCount(int chatId) async {
    final countExpr = _db.messages.id.count();
    final query = _db.selectOnly(_db.messages)
      ..addColumns([countExpr])
      ..where(_db.messages.chatId.equals(chatId));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Получение списка сообщений по их серверным ID (для оптимизации расшифровки)
  Future<List<Message>> getMessagesByServerIds(List<String> serverIds) {
    if (serverIds.isEmpty) return Future.value([]);
    return (_db.select(_db.messages)
          ..where((m) => m.serverMessageId.isIn(serverIds)))
        .get();
  }

  /// Получение порядкового номера (индекса) сообщения по его serverMessageId при сортировке по времени убывания
  Future<int?> getMessageIndexByServerId(String serverChatId, String serverMessageId) async {
    final chatId = await getLocalChatId(serverChatId);
    if (chatId == null) return null;

    final targetMsg = await getMessagesByServerIds([serverMessageId]);
    if (targetMsg.isEmpty) return null;
    final target = targetMsg.first;

    final query = _db.select(_db.messages)
      ..where((m) => m.chatId.equals(chatId))
      ..where((m) => m.timestamp.isBiggerOrEqualValue(target.timestamp));
    final list = await query.get();

    list.sort((a, b) {
      final cmp = b.timestamp.compareTo(a.timestamp);
      if (cmp != 0) return cmp;
      return b.id.compareTo(a.id);
    });

    final idx = list.indexWhere((m) => m.serverMessageId == serverMessageId);
    return idx == -1 ? null : idx;
  }

  /// Поиск сообщения в БД по его url или локальному пути
  Future<Message?> getMessageByFileUrlOrPath(String urlOrPath) async {
    String? fileId;
    if (urlOrPath.contains('/api/files/download/')) {
      final regExp = RegExp(r'/api/files/download/([^/]+)');
      final match = regExp.firstMatch(urlOrPath);
      if (match != null) {
        fileId = match.group(1);
      }
    }

    final query = _db.select(_db.messages)..where((m) => m.fileUrl.isNotNull());
    final allFileMsgs = await query.get();

    for (final msg in allFileMsgs) {
      if (msg.fileUrl == null) continue;
      try {
        final parsed = jsonDecode(msg.fileUrl!);
        if (parsed is Map) {
          if (fileId != null && parsed['file_id']?.toString() == fileId) {
            return msg;
          }
          if (parsed['file_id']?.toString() == urlOrPath) {
            return msg;
          }
          if (parsed['local_path']?.toString() == urlOrPath) {
            return msg;
          }
          if (parsed['file_url']?.toString() == urlOrPath) {
            return msg;
          }
        }
      } catch (_) {}
    }
    return null;
  }

  /// Получение сообщения по его messageId (UUID To-do/Poll)
  Future<Message?> getMessageByMessageId(String messageId) {
    return (_db.select(_db.messages)
          ..where((m) => m.messageId.equals(messageId)))
        .getSingleOrNull();
  }

  /// Обновление сообщения (например, статуса To-Do или голосов в опросе)
  Future<void> updateMessageCompanion(MessagesCompanion companion) async {
    if (companion.id.present) {
      final id = companion.id.value;
      await (_db.update(_db.messages)
            ..where((m) => m.id.equals(id)))
          .write(companion);
    } else if (companion.serverMessageId.present) {
      final serverId = companion.serverMessageId.value;
      await (_db.update(_db.messages)
            ..where((m) => m.serverMessageId.equals(serverId)))
          .write(companion);
    }
  }

  /// Отметить сообщения в локальной базе данных как прочитанные
  Future<void> markMessagesAsReadInDb(int chatId, {List<String>? serverMessageIds}) async {
    int updatedCount = 0;
    if (serverMessageIds != null && serverMessageIds.isNotEmpty) {
      updatedCount = await (_db.update(_db.messages)
            ..where((m) => m.chatId.equals(chatId))
            ..where((m) => m.serverMessageId.isIn(serverMessageIds)))
          .write(const MessagesCompanion(isRead: Value(true)));
    } else {
      updatedCount = await (_db.update(_db.messages)
            ..where((m) => m.chatId.equals(chatId)))
          .write(const MessagesCompanion(isRead: Value(true)));
    }
    debugPrint('[READ_STATUS_LOG] markMessagesAsReadInDb: chatId=$chatId, serverMessageIds=$serverMessageIds => updated $updatedCount rows to isRead=true');
  }

  ChatModel _mapChatToModel(Chat row) {
    Map<String, dynamic>? otherUser;
    if (row.otherUserJson != null && row.otherUserJson!.isNotEmpty) {
      try {
        otherUser = jsonDecode(row.otherUserJson!) as Map<String, dynamic>;
      } catch (_) {}
    }
    final rawCallsEnabled = otherUser?['group_calls_enabled'];
    bool groupCallsEnabled = rawCallsEnabled != null
        ? (rawCallsEnabled == true || rawCallsEnabled == 1 || rawCallsEnabled == 'true')
        : true;

    return ChatModel(
      id: row.serverChatId,
      name: row.name,
      avatar: row.avatar,
      avatarGradient: row.avatarGradient,
      lastMessage: row.lastMessage,
      lastMessageTime: row.lastMessageTime,
      unreadCount: row.unreadCount,
      isGroup: row.isGroup,
      isChannel: row.isChannel,
      isPersonal: row.isPersonal,
      isFavorites: row.isFavorites,
      otherUser: otherUser,
      isEncrypted: row.isEncrypted,
      isArchived: row.isArchived,
      archivedAt: row.archivedAt,
      lastMessageType: row.lastMessageType,
      groupCallsEnabled: groupCallsEnabled,
    );
  }

  ChatsCompanion _mapModelToCompanion(ChatModel model) {
    Map<String, dynamic> otherUserMap = Map<String, dynamic>.from(model.otherUser ?? {});
    otherUserMap['group_calls_enabled'] = model.groupCallsEnabled;
    final otherUserJson = jsonEncode(otherUserMap);

    return ChatsCompanion(
      serverChatId: Value(model.id),
      name: Value(model.name),
      avatar: Value(model.avatar),
      avatarGradient: Value(model.avatarGradient),
      lastMessage: Value(model.lastMessage),
      lastMessageTime: Value(model.lastMessageTime),
      unreadCount: Value(model.unreadCount),
      isGroup: Value(model.isGroup),
      isChannel: Value(model.isChannel),
      isPersonal: Value(model.isPersonal),
      isFavorites: Value(model.isFavorites),
      otherUserJson: Value(otherUserJson),
      isEncrypted: Value(model.isEncrypted),
      isArchived: Value(model.isArchived),
      archivedAt: Value(model.archivedAt),
      lastMessageType: Value(model.lastMessageType),
    );
  }

  Future<int> _upsertChat(ChatModel incoming) async {
    final existing = await (_db.select(_db.chats)
          ..where((c) => c.serverChatId.equals(incoming.id)))
        .getSingleOrNull();

    final merged = existing == null ? incoming : _mergeChat(_mapChatToModel(existing), incoming);

    if (existing == null) {
      return _db.into(_db.chats).insert(_mapModelToCompanion(merged));
    }

    return (_db.update(_db.chats)..where((c) => c.id.equals(existing.id)))
        .write(_mapModelToCompanion(merged));
  }

  ChatModel _mergeChat(ChatModel existing, ChatModel incoming) {
    final hasIncomingTime = incoming.lastMessageTime != null;
    final hasExistingTime = existing.lastMessageTime != null;

    bool incomingIsLatest;
    if (hasIncomingTime && hasExistingTime) {
      incomingIsLatest = !incoming.lastMessageTime!.isBefore(existing.lastMessageTime!);
    } else if (hasIncomingTime && !hasExistingTime) {
      incomingIsLatest = true;
    } else if (!hasIncomingTime && hasExistingTime) {
      incomingIsLatest = false;
    } else {
      // Если времени нет ни у кого, используем входящее значение как более актуальное.
      incomingIsLatest = true;
    }

    // Merge user_profiles from existing otherUser if incoming does not have them
    Map<String, dynamic>? mergedOtherUser;
    if (incoming.otherUser != null || existing.otherUser != null) {
      mergedOtherUser = Map<String, dynamic>.from(incoming.otherUser ?? {});
      final existingProfiles = existing.otherUser?['user_profiles'];
      if (existingProfiles != null && mergedOtherUser['user_profiles'] == null) {
        mergedOtherUser['user_profiles'] = existingProfiles;
      }
    }

    return ChatModel(
      id: incoming.id,
      name: incoming.name,
      avatar: incoming.avatar ?? existing.avatar,
      avatarGradient: incoming.avatarGradient ?? existing.avatarGradient,
      lastMessage: incomingIsLatest ? incoming.lastMessage : existing.lastMessage,
      lastMessageTime: incomingIsLatest ? incoming.lastMessageTime : existing.lastMessageTime,
      unreadCount: incoming.unreadCount,
      isGroup: incoming.isGroup,
      isChannel: incoming.isChannel,
      isPersonal: incoming.isPersonal,
      isFavorites: incoming.isFavorites,
      otherUser: mergedOtherUser,
      isEncrypted: incomingIsLatest ? incoming.isEncrypted : existing.isEncrypted,
      isArchived: incoming.isArchived,
      archivedAt: incoming.archivedAt ?? existing.archivedAt,
      lastMessageType: incomingIsLatest ? incoming.lastMessageType : existing.lastMessageType,
      groupCallsEnabled: incoming.groupCallsEnabled || existing.groupCallsEnabled,
    );
  }
}
