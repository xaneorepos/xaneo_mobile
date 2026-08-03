import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../../models/database/chats_table.dart';
import '../../models/database/messages_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Chats, Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.e);

  /// Конструктор для тестов в памяти
  AppDatabase.forTesting(super.e);

  /// Создает экземпляр БД для конкретной пары сервер + пользователь.
  ///
  /// Один и тот же числовой userId может существовать на prod, staging и
  /// локальном сервере, поэтому userId сам по себе не является безопасным
  /// namespace для локального кеша.
  static AppDatabase createForUser({
    required Directory dbFolder,
    required String dbKey,
    required String serverScope,
    String? userId,
  }) {
    final dbName = databaseFileName(
      serverScope: serverScope,
      userId: userId,
    );
    final file = File(p.join(dbFolder.path, dbName));

    return AppDatabase._(NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // Устанавливаем ключ для SQLCipher при открытии БД
        db.execute("PRAGMA key = '$dbKey';");
        // Не допускаем появления сообщений без существующего чата.
        db.execute('PRAGMA foreign_keys = ON;');
        // Включаем WAL-режим для параллельного чтения и записи
        db.execute("PRAGMA journal_mode = WAL;");
      },
    ));
  }

  /// Стабильное имя файла без утечки URL сервера в файловую систему.
  static String databaseFileName({
    required String serverScope,
    String? userId,
  }) {
    final normalizedServer = normalizeServerScope(serverScope);
    final encodedServer =
        base64Url.encode(utf8.encode(normalizedServer)).replaceAll('=', '');
    final normalizedUser = (userId == null || userId.trim().isEmpty)
        ? 'anonymous'
        : userId.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return 'app_db_${encodedServer}_user_$normalizedUser.sqlite';
  }

  static String normalizeServerScope(String serverScope) {
    final raw = serverScope.trim();
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
      return raw.toLowerCase().replaceAll(RegExp(r'/+$'), '');
    }

    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final port = uri.hasPort
        ? uri.port
        : switch (scheme) {
            'http' => 80,
            'https' => 443,
            _ => 0,
          };
    final path = uri.path.replaceAll(RegExp(r'/+$'), '');
    return '$scheme://$host:$port$path';
  }

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(chats, chats.isArchived);
            await m.addColumn(chats, chats.archivedAt);
          }
          if (from < 3) {
            await m.addColumn(messages, messages.messageType);
            await m.addColumn(messages, messages.messageId);
            await m.addColumn(messages, messages.completionStatus);
            await m.addColumn(messages, messages.votesByOption);
            await m.addColumn(messages, messages.userVotes);
          }
          if (from < 4) {
            await m.addColumn(chats, chats.lastMessageType);
          }
          if (from < 5) {
            await m.addColumn(messages, messages.replyToId);
            await m.addColumn(messages, messages.replyText);
            await m.addColumn(messages, messages.replyAuthorName);
          }
        },
        beforeOpen: (details) async {
          // Создаем композитный индекс для оптимизации сортировки и выборки сообщений в чате
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_messages_chat_timestamp ON messages (chat_id, timestamp DESC);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_chats_last_message_time ON chats (last_message_time DESC);',
          );
        },
      );
}
