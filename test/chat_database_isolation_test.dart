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
}
