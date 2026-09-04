import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/models/chat/chat_model.dart';
import 'package:xaneo/services/chat/chat_local_repository.dart';
import 'package:xaneo/services/database/app_database.dart';

void main() {
  group('database isolation', () {
    test('uses a different file for each server and user pair', () {
      final production = AppDatabase.databaseFileName(
        serverScope: 'https://xaneo.ru/api/v1',
        userId: '42',
      );
      final local = AppDatabase.databaseFileName(
        serverScope: 'http://192.168.1.113/api/v1',
        userId: '42',
      );
      final otherUser = AppDatabase.databaseFileName(
        serverScope: 'https://xaneo.ru/api/v1',
        userId: '7',
      );

      expect(production, isNot(local));
      expect(production, isNot(otherUser));
    });

    test('normalizes equivalent server URLs to the same scope', () {
      final first = AppDatabase.databaseFileName(
        serverScope: 'HTTPS://XANEO.RU:443/api/v1/',
        userId: '42',
      );
      final second = AppDatabase.databaseFileName(
        serverScope: 'https://xaneo.ru/api/v1',
        userId: '42',
      );

      expect(first, second);
    });
  });

  group('chat snapshot sync', () {
    late AppDatabase database;
    late LocalChatRepository repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = LocalChatRepository(database);
    });

    tearDown(() async {
      await repository.dispose();
    });

    test('updates authoritative rows and removes stale chats and messages',
        () async {
      await repository.syncChatsSnapshot([
        ChatModel(id: 'chat-a', name: 'Old name', unreadCount: 9),
        ChatModel(id: 'chat-b', name: 'Removed chat'),
      ]);

      final removedChatId = await repository.getLocalChatId('chat-b');
      expect(removedChatId, isNotNull);
      await repository.saveMessage(
        MessagesCompanion.insert(
          serverMessageId: 'message-b',
          chatId: removedChatId!,
          senderId: '7',
          textContent: 'stale',
          timestamp: DateTime.utc(2026),
        ),
      );

      await repository.syncChatsSnapshot([
        ChatModel(id: 'chat-a', name: 'Current name', unreadCount: 0),
      ]);

      final current = await repository.getChatByServerId('chat-a');
      expect(current?.name, 'Current name');
      expect(current?.unreadCount, 0);
      expect(await repository.getChatByServerId('chat-b'), isNull);
      expect(await repository.getMessagesByServerIds(['message-b']), isEmpty);
    });

    test('a valid empty snapshot clears the local chat list', () async {
      await repository.syncChatsSnapshot([
        ChatModel(id: 'chat-a', name: 'Chat'),
      ]);

      await repository.syncChatsSnapshot([]);

      expect(await repository.getAllChats(), isEmpty);
    });

    test('does not overwrite a newer websocket preview with an older snapshot',
        () async {
      await repository.saveChat(
        ChatModel(
          id: 'chat-a',
          name: 'Old metadata',
          lastMessage: 'new websocket message',
          lastMessageTime: DateTime.utc(2026, 8, 2, 12),
          unreadCount: 3,
        ),
      );

      await repository.syncChatsSnapshot([
        ChatModel(
          id: 'chat-a',
          name: 'Fresh server metadata',
          lastMessage: 'older snapshot message',
          lastMessageTime: DateTime.utc(2026, 8, 2, 11),
          unreadCount: 1,
        ),
      ]);

      final chat = await repository.getChatByServerId('chat-a');
      expect(chat?.name, 'Fresh server metadata');
      expect(chat?.lastMessage, 'new websocket message');
      expect(chat?.unreadCount, 3);
    });
  });

  group('cached message attachments', () {
    late AppDatabase database;
    late LocalChatRepository repository;
    late int chatId;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = LocalChatRepository(database);
      await repository.saveChat(ChatModel(id: 'chat-a', name: 'Chat'));
      chatId = (await repository.getLocalChatId('chat-a'))!;
    });

    tearDown(() async {
      await repository.dispose();
    });

    test('keeps a valid E2EE attachment when file JSON equals message text',
        () async {
      const fileJson =
          '{"type":"image","file_id":"file-1","file_name":"photo.jpg"}';
      await repository.saveMessage(
        MessagesCompanion.insert(
          serverMessageId: 'message-1',
          chatId: chatId,
          senderId: '7',
          textContent: fileJson,
          fileUrl: const Value(fileJson),
          messageType: const Value('image'),
          timestamp: DateTime.utc(2026),
        ),
      );

      await repository.cleanupFakeFileMessages(chatId);

      final message =
          (await repository.getMessagesByServerIds(['message-1'])).single;
      expect(message.fileUrl, fileJson);
    });

    test('removes an invalid attachment-shaped text payload', () async {
      const fakeJson = '{"type":"image"}';
      await repository.saveMessage(
        MessagesCompanion.insert(
          serverMessageId: 'message-2',
          chatId: chatId,
          senderId: '7',
          textContent: fakeJson,
          fileUrl: const Value(fakeJson),
          timestamp: DateTime.utc(2026),
        ),
      );

      await repository.cleanupFakeFileMessages(chatId);

      final message =
          (await repository.getMessagesByServerIds(['message-2'])).single;
      expect(message.fileUrl, isNull);
    });

    test('restores a valid attachment cleared by an older client', () async {
      const fileJson =
          '{"type":"image","file_id":"file-3","file_name":"old.jpg"}';
      await repository.saveMessage(
        MessagesCompanion.insert(
          serverMessageId: 'message-3',
          chatId: chatId,
          senderId: '7',
          textContent: fileJson,
          messageType: const Value('image'),
          timestamp: DateTime.utc(2026),
        ),
      );

      await repository.cleanupFakeFileMessages(chatId);

      final message =
          (await repository.getMessagesByServerIds(['message-3'])).single;
      expect(message.fileUrl, fileJson);
    });
  });

  group('optimistic message acknowledgement', () {
    late AppDatabase database;
    late LocalChatRepository repository;
    late int chatId;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = LocalChatRepository(database);
      await repository.saveChat(ChatModel(id: 'bot-chat', name: 'Bot'));
      chatId = (await repository.getLocalChatId('bot-chat'))!;
    });

    tearDown(() async {
      await repository.dispose();
    });

    test('replaces local time with server time to preserve reply order',
        () async {
      final localTime = DateTime.utc(2026, 9, 4, 12, 0, 5);
      final sentAt = DateTime.utc(2026, 9, 4, 12);
      final repliedAt = DateTime.utc(2026, 9, 4, 12, 0, 1);

      await repository.saveMessage(
        MessagesCompanion.insert(
          serverMessageId: 'temp-1',
          chatId: chatId,
          senderId: 'me',
          textContent: 'question',
          timestamp: localTime,
        ),
      );
      await repository.updateMessageServerId(
        'temp-1',
        'message-1',
        timestamp: sentAt,
      );
      await repository.saveMessage(
        MessagesCompanion.insert(
          serverMessageId: 'message-2',
          chatId: chatId,
          senderId: 'bot',
          textContent: 'answer',
          timestamp: repliedAt,
        ),
      );

      final messages = await repository.getMessagesForChat(chatId);
      expect(
        messages.map((message) => message.serverMessageId),
        ['message-2', 'message-1'],
      );
      expect(
        (await repository.getMessagesByServerIds(['message-1']))
            .single
            .timestamp
            .toUtc(),
        sentAt,
      );
    });
  });
}
