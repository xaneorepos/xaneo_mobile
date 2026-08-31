import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/app_config.dart';
import '../../models/chat/chat_model.dart';
import '../api/api_client.dart';

/// Сервис для работы с чатами
class ChatService {
  final ApiClient _apiClient;

  ChatService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Получить список чатов пользователя (включая архивные)
  Future<List<ChatModel>> getChats() async {
    try {
      final response = await _apiClient.get(AppConfig.chatsList);

      if (response.statusCode == 200 && response.data != null) {
        // API возвращает {chats: [...], archived_chats: [...]} или [...]
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data as List;
        } else if (response.data is Map) {
          final mapData = response.data as Map<String, dynamic>;
          final activeChats = mapData['chats'] as List? ?? [];
          final archivedChats = mapData['archived_chats'] as List? ?? [];
          data = [...activeChats, ...archivedChats];
        }

        return data
            .map((json) => ChatModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw StateError(
        'Failed to fetch chats: HTTP ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Error fetching chats: $e');
      rethrow;
    }
  }

  /// Архивировать или разархивировать чат на сервере
  Future<bool> archiveChat(String chatId, bool isArchived) async {
    try {
      final response = await _apiClient.post(
        '/chats/archive/',
        data: {
          'chat_id': chatId,
          'is_archived': isArchived,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          return data['success'] == true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error archiving chat $chatId: $e');
      return false;
    }
  }

  /// Нажатие на inline-кнопку бота под сообщением (callback_data-кнопка).
  /// Эндпоинт живёт под /api/bots/, а не /api/{apiVersion}/, поэтому бьём
  /// напрямую в serverOrigin, а не через baseUrl клиента.
  /// Возвращает null при успехе, иначе текст ошибки для показа пользователю.
  Future<String?> activateBotCallback(int messageId, String buttonId) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.serverOrigin}/api/bots/callbacks/activate/',
        data: {'message_id': messageId, 'button_id': buttonId},
      );
      if (response.statusCode == 200) return null;
      return 'Не удалось выполнить действие';
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['detail'] is String) {
        return data['detail'] as String;
      }
      return 'Не удалось выполнить действие: ${e.message}';
    } catch (e) {
      debugPrint('Error activating bot callback: $e');
      return 'Не удалось выполнить действие: $e';
    }
  }

  /// Список зарегистрированных команд бота для меню рядом с полем ввода.
  Future<List<Map<String, String>>> getBotCommands(String username) async {
    try {
      final encodedUsername = Uri.encodeComponent(username);
      final response = await _apiClient.get(
        '${AppConfig.serverOrigin}/api/bots/$encodedUsername/commands/',
      );
      final data = response.data;
      if (response.statusCode != 200 || data is! Map) return const [];
      final result = data['result'];
      if (result is! List) return const [];
      return result.whereType<Map>().map((item) {
        return {
          'command': item['command']?.toString() ?? '',
          'description': item['description']?.toString() ?? '',
        };
      }).where((item) => item['command']!.isNotEmpty).toList();
    } catch (e) {
      debugPrint('Error loading bot commands for $username: $e');
      return const [];
    }
  }

  Future<bool> pinChat(String chatId, bool isPinned) {
    return _updateChatSetting(
      endpoint: '/chats/pin/',
      chatId: chatId,
      field: 'is_pinned',
      value: isPinned,
    );
  }

  Future<bool> muteChat(String chatId, bool isMuted) {
    return _updateChatSetting(
      endpoint: '/chats/mute/',
      chatId: chatId,
      field: 'is_muted',
      value: isMuted,
    );
  }

  Future<bool> _updateChatSetting({
    required String endpoint,
    required String chatId,
    required String field,
    required bool value,
  }) async {
    try {
      final response = await _apiClient.post(
        endpoint,
        data: {'chat_id': chatId, field: value},
      );
      return response.statusCode == 200 &&
          response.data is Map &&
          response.data['success'] == true;
    } catch (e) {
      debugPrint('Error updating $field for chat $chatId: $e');
      return false;
    }
  }

  Future<bool> clearChatHistory(String chatId, String chatType) async {
    try {
      final response = await _apiClient.post(
        '/../clear-chat-history/',
        data: {'chat_id': chatId, 'chat_type': chatType},
      );
      return response.statusCode == 200 &&
          response.data is Map &&
          response.data['success'] == true;
    } catch (e) {
      debugPrint('Error clearing history for chat $chatId: $e');
      return false;
    }
  }

  Future<bool> deleteChat(String chatId) async {
    try {
      final response = await _apiClient.post(
        '/../delete-chat/',
        data: {'chat_id': chatId},
      );
      return response.statusCode == 200 &&
          response.data is Map &&
          response.data['success'] == true;
    } catch (e) {
      debugPrint('Error deleting chat $chatId: $e');
      return false;
    }
  }

  /// Получить список зашифрованных сообщений для конкретного чата с пагинацией (limit/offset)
  Future<Map<String, dynamic>?> getEncryptedMessages(
    String chatId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/encrypted-messages/',
        queryParameters: {
          'chat_id': chatId,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map) {
          return response.data as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching encrypted messages for chat $chatId: $e');
      return null;
    }
  }

  /// Отметить сообщения в чате как прочитанные
  Future<bool> markMessagesAsRead(String chatId) async {
    try {
      final response = await _apiClient.post(
        '/mark-messages-as-read/$chatId/',
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking messages as read for chat $chatId: $e');
      return false;
    }
  }

  /// Глобальный поиск людей, ботов, групп и каналов
  Future<Map<String, dynamic>?> globalSearch(String query) async {
    try {
      final response = await _apiClient.get(
        '/user/search/',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map) {
          return response.data as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error performing global search for query $query: $e');
      return null;
    }
  }
}
