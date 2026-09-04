import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';

/// Сервис для работы с группами, каналами и инвайтами
class GroupChannelService {
  final ApiClient _apiClient;

  GroupChannelService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Создать новую группу (POST /api/groups/create/)
  Future<Map<String, dynamic>?> createGroup({
    required String name,
    String? username,
    String? description,
    bool isPrivate = false,
    File? avatarFile,
  }) async {
    try {
      final String privacy = isPrivate ? 'private' : 'public';
      final Map<String, dynamic> mapData = {
        'name': name,
        'privacy': privacy,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (!isPrivate && username != null && username.isNotEmpty)
          'username': username.replaceAll('@', '').trim(),
      };

      dynamic dataToSend;
      if (avatarFile != null) {
        dataToSend = FormData.fromMap({
          ...mapData,
          'avatar': await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split(Platform.pathSeparator).last,
          ),
        });
      } else {
        dataToSend = mapData;
      }

      final response = await _apiClient.post(
        '/groups/create/',
        data: dataToSend,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data as Map);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating group: $e');
      return null;
    }
  }

  /// Создать новый канал (POST /api/channels/create/)
  Future<Map<String, dynamic>?> createChannel({
    required String name,
    String? username,
    String? description,
    bool isPrivate = false,
    File? avatarFile,
  }) async {
    try {
      final String privacy = isPrivate ? 'private' : 'public';
      final Map<String, dynamic> mapData = {
        'name': name,
        'privacy': privacy,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (!isPrivate && username != null && username.isNotEmpty)
          'username': username.replaceAll('@', '').trim(),
      };

      dynamic dataToSend;
      if (avatarFile != null) {
        dataToSend = FormData.fromMap({
          ...mapData,
          'avatar': await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split(Platform.pathSeparator).last,
          ),
        });
      } else {
        dataToSend = mapData;
      }

      final response = await _apiClient.post(
        '/channels/create/',
        data: dataToSend,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data as Map);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating channel: $e');
      return null;
    }
  }

  /// Вступить в группу (POST /api/groups/{id}/join/)
  Future<bool> joinGroup(int groupId, {String? inviteCode}) async {
    try {
      final response = await _apiClient.post(
        '/groups/$groupId/join/',
        data: {
          if (inviteCode != null) 'invite': inviteCode,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map) {
          final map = response.data as Map;
          return map['success'] == true || map['status'] == 'joined';
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error joining group $groupId: $e');
      return false;
    }
  }

  /// Покинуть группу (POST /api/groups/{id}/leave/)
  Future<bool> leaveGroup(int groupId) async {
    try {
      final response = await _apiClient.post('/groups/$groupId/leave/');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error leaving group $groupId: $e');
      return false;
    }
  }

  /// Подписаться или отписаться от канала (POST /api/channels/subscribe/)
  Future<bool> toggleChannelSubscription(int channelId,
      {required bool subscribe}) async {
    try {
      final response = await _apiClient.post(
        '/channels/subscribe/',
        data: {
          'channel_id': channelId,
          'action': subscribe ? 'subscribe' : 'unsubscribe',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map) {
          final map = response.data as Map;
          return map['success'] == true ||
              map['status'] == 'subscribed' ||
              map['status'] == 'unsubscribed';
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling channel subscription $channelId: $e');
      return false;
    }
  }

  /// Получить информацию об инвайте/публичном объекте (GET /api/invite/{identifier}/)
  Future<Map<String, dynamic>?> getInviteData(String identifier) async {
    try {
      final cleanIdentifier = identifier.replaceAll('@', '').trim();
      final response = await _apiClient.get('/invite/$cleanIdentifier/');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data as Map);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting invite data for $identifier: $e');
      return null;
    }
  }

  /// Обновить или удалить аватар группы (POST /api/groups/{id}/avatar/)
  Future<Map<String, dynamic>?> updateGroupAvatar({
    required int groupId,
    File? avatarFile,
    bool removeAvatar = false,
  }) async {
    try {
      dynamic dataToSend;
      if (removeAvatar) {
        dataToSend = {'remove_avatar': true};
      } else if (avatarFile != null) {
        dataToSend = FormData.fromMap({
          'avatar': await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split(Platform.pathSeparator).last,
          ),
        });
      } else {
        return null;
      }

      final response = await _apiClient.post(
        '/groups/$groupId/avatar/',
        data: dataToSend,
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating group avatar for $groupId: $e');
      return null;
    }
  }

  /// Обновить или удалить аватар канала (POST /api/channels/{id}/avatar/)
  Future<Map<String, dynamic>?> updateChannelAvatar({
    required int channelId,
    File? avatarFile,
    bool removeAvatar = false,
  }) async {
    try {
      dynamic dataToSend;
      if (removeAvatar) {
        dataToSend = {'remove_avatar': true};
      } else if (avatarFile != null) {
        dataToSend = FormData.fromMap({
          'avatar': await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split(Platform.pathSeparator).last,
          ),
        });
      } else {
        return null;
      }

      final response = await _apiClient.post(
        '/channels/$channelId/avatar/',
        data: dataToSend,
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating channel avatar for $channelId: $e');
      return null;
    }
  }
}
