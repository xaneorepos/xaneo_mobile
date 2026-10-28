import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';

typedef ScheduleRequest = Future<Response<dynamic>> Function(
  String method,
  String path,
  dynamic data,
  Map<String, dynamic>? query,
);
typedef ScheduleSeal = Future<Map<String, dynamic>> Function(String text);
typedef ScheduleDecrypt = Future<String> Function(Map<String, dynamic> payload);

String scheduleRequestId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

class ScheduleException implements Exception {
  final String message;
  final int? status;
  const ScheduleException(this.message, [this.status]);
  @override
  String toString() => message;
}

class ScheduledAttachment {
  final String? id;
  final String name;
  final String type;
  final String mime;
  final String? url;
  final File? localFile;
  final bool unavailable;
  const ScheduledAttachment({
    this.id,
    required this.name,
    this.type = 'document',
    this.mime = '',
    this.url,
    this.localFile,
    this.unavailable = false,
  });
  factory ScheduledAttachment.fromJson(Map<String, dynamic> json) =>
      ScheduledAttachment(
        id: json['file_id']?.toString(),
        name:
            json['name']?.toString() ?? json['file_name']?.toString() ?? 'File',
        type: json['file_type']?.toString() ?? 'document',
        mime: json['mime_type']?.toString() ?? '',
        url: json['url']?.toString(),
        unavailable: json['unavailable'] == true,
      );
  factory ScheduledAttachment.local(File file) => ScheduledAttachment(
        name: file.path.replaceAll('\\', '/').split('/').last,
        localFile: file,
      );
  String get kind {
    final ext = name.split('.').last.toLowerCase();
    if (type == 'image' ||
        mime.startsWith('image/') ||
        [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
          'avif',
          'bmp',
          'heic',
        ].contains(ext)) {
      return 'image';
    }
    if (type == 'video' ||
        type == 'video_message' ||
        mime.startsWith('video/') ||
        ['mp4', 'webm', 'mov', 'mkv', 'avi', 'm4v'].contains(ext)) {
      return 'video';
    }
    if (type == 'audio' ||
        type == 'voice' ||
        mime.startsWith('audio/') ||
        ['mp3', 'm4a', 'wav', 'flac', 'ogg', 'aac', 'opus'].contains(ext)) {
      return 'audio';
    }
    return 'document';
  }
}

class ScheduledJob {
  final String id;
  final String chatId;
  final DateTime sendAt;
  final String status;
  final String error;
  final Map<String, dynamic> payload;
  final List<ScheduledAttachment> files;
  ScheduledJob.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        chatId = json['chat_id'].toString(),
        sendAt = DateTime.parse(json['send_at'].toString()).toLocal(),
        status = json['status'].toString(),
        error = json['last_error']?.toString() ?? '',
        payload = Map<String, dynamic>.from(json['payload'] as Map),
        files = (json['files'] as List? ?? [])
            .whereType<Map>()
            .map(
              (item) =>
                  ScheduledAttachment.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
  List<String> get fileIds => <String>{
        for (final item in payload['images'] as List? ?? [])
          if (item is Map && item['file_id'] != null)
            item['file_id'].toString(),
        if (payload['file_id'] != null) payload['file_id'].toString(),
      }.toList();
  List<ScheduledAttachment> get attachments => fileIds
      .map(
        (id) =>
            files.where((file) => file.id == id).firstOrNull ??
            ScheduledAttachment(id: id, name: 'File', unavailable: true),
      )
      .toList();
}

class ScheduledPage {
  final List<ScheduledJob> jobs;
  final bool hasMore;
  const ScheduledPage(this.jobs, this.hasMore);
}

class ScheduledMessagesApi {
  final ScheduleRequest request;
  final Uri origin;
  ScheduledMessagesApi({required this.request, required Uri baseUrl})
      : origin = baseUrl.replace(path: '/', query: '', fragment: '');
  String? mediaUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parsed = Uri.tryParse(raw);
    if (parsed == null) return null;
    final uri = origin.resolveUri(parsed);
    return ['http', 'https'].contains(uri.scheme) &&
            uri.userInfo.isEmpty &&
            uri.host == origin.host &&
            uri.port == origin.port &&
            uri.path.startsWith('/api/files/download/')
        ? uri.toString()
        : null;
  }

  Future<dynamic> _call(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await request(method, path, data, query);
      if ((response.statusCode ?? 500) >= 400) {
        throw ScheduleException(_detail(response.data), response.statusCode);
      }
      return response.data;
    } on DioException catch (error) {
      throw ScheduleException(
        _detail(error.response?.data ?? error.message),
        error.response?.statusCode,
      );
    }
  }

  String _detail(dynamic data) {
    if (data is Map) {
      return data['detail']?.toString() ?? data.values.map(_detail).join(' ');
    }
    if (data is List) return data.map(_detail).join(' ');
    return data?.toString() ?? 'Network error';
  }

  Future<ScheduledJob> create(Map<String, dynamic> body) async =>
      ScheduledJob.fromJson(
        Map<String, dynamic>.from(
          await _call('POST', '/scheduled-messages/', data: body),
        ),
      );
  Future<ScheduledPage> list(String chatId, {int offset = 0}) async {
    final data = await _call(
      'GET',
      '/scheduled-messages/',
      query: {'chat_id': chatId, 'limit': 50, 'offset': offset},
    );
    return ScheduledPage(
      (data['results'] as List)
          .map((row) => ScheduledJob.fromJson(Map<String, dynamic>.from(row)))
          .toList(),
      data['next'] != null,
    );
  }

  Future<void> cancel(ScheduledJob job) async {
    await _call(
      'DELETE',
      '/scheduled-messages/${Uri.encodeComponent(job.id)}/',
    );
  }

  Future<void> move(ScheduledJob job, DateTime date) async {
    await _call(
      'PATCH',
      '/scheduled-messages/${Uri.encodeComponent(job.id)}/',
      data: {'send_at': date.toUtc().toIso8601String()},
    );
  }

  Future<void> edit(
    ScheduledJob job,
    Map<String, dynamic> encrypted,
    List<ScheduledAttachment> files, {
    DateTime? sendAt,
  }) async {
    if (files.length > 10 || files.any((file) => file.id == null)) {
      throw const ScheduleException('Invalid attachments');
    }
    await _call(
      'PATCH',
      '/scheduled-messages/${Uri.encodeComponent(job.id)}/',
      data: {
        ...encrypted,
        'images': files.map((file) => {'file_id': file.id}).toList(),
        'expected_encrypted_text': job.payload['encrypted_text'],
        'expected_file_ids': job.fileIds,
        if (sendAt != null) 'send_at': sendAt.toUtc().toIso8601String(),
      },
    );
  }

  Future<ScheduledAttachment> upload(File file, String chatId) async {
    final local = ScheduledAttachment.local(file);
    final data = await _call(
      'POST',
      '/files/upload/',
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: local.name),
        'chat_id': chatId,
        'file_type': local.kind,
      }),
    );
    if (data is! Map || data['file_id'] == null) {
      throw ScheduleException(_detail(data));
    }
    return ScheduledAttachment(
      id: data['file_id'].toString(),
      name: local.name,
      type: data['file_type']?.toString() ?? local.kind,
      mime: data['mime_type']?.toString() ?? '',
      localFile: file,
      url: data['file_url']?.toString(),
    );
  }
}

/// Fixed request ID, ciphertext and time survive ambiguous failures. Never
/// create a second job just because the first response was lost.
class ScheduledSubmission {
  final ScheduledMessagesApi api;
  final Future<Map<String, dynamic>> Function() prepare;
  final String requestId = scheduleRequestId();
  Map<String, dynamic>? _payload;
  String? _sendAt;
  bool get timeLocked => _sendAt != null;
  ScheduledSubmission({required this.api, required this.prepare});
  Future<ScheduledJob> send(DateTime date) async {
    if (_sendAt == null &&
        (!date.isAfter(DateTime.now()) ||
            date.isAfter(DateTime.now().add(const Duration(days: 365))))) {
      throw const ScheduleException('Choose a future time within one year');
    }
    if (_payload == null) {
      final prepared = await prepare();
      const fields = {
        'chat_id',
        'encrypted_text',
        'signature',
        'epoch_id',
        'images',
        'file_id',
        'reply_to_id',
        'is_channel_comment',
      };
      _payload = Map<String, dynamic>.from(
        jsonDecode(
          jsonEncode(
            Map<String, dynamic>.fromEntries(
              prepared.entries.where((entry) => fields.contains(entry.key)),
            ),
          ),
        ),
      );
    }
    _sendAt ??= date.toUtc().toIso8601String();
    try {
      return await api.create({
        ..._payload!,
        'send_at': _sendAt,
        'client_request_id': requestId,
      });
    } on ScheduleException catch (error) {
      if (error.status != null &&
          error.status! >= 400 &&
          error.status! < 500 &&
          error.status != 409) {
        _sendAt = null;
        _payload = null;
      }
      rethrow;
    }
  }
}
