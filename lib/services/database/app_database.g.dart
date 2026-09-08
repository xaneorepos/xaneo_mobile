// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChatsTable extends Chats with TableInfo<$ChatsTable, Chat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverChatIdMeta =
      const VerificationMeta('serverChatId');
  @override
  late final GeneratedColumn<String> serverChatId = GeneratedColumn<String>(
      'server_chat_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarGradientMeta =
      const VerificationMeta('avatarGradient');
  @override
  late final GeneratedColumn<String> avatarGradient = GeneratedColumn<String>(
      'avatar_gradient', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
      'last_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageTimeMeta =
      const VerificationMeta('lastMessageTime');
  @override
  late final GeneratedColumn<DateTime> lastMessageTime =
      GeneratedColumn<DateTime>('last_message_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isGroupMeta =
      const VerificationMeta('isGroup');
  @override
  late final GeneratedColumn<bool> isGroup = GeneratedColumn<bool>(
      'is_group', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_group" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isChannelMeta =
      const VerificationMeta('isChannel');
  @override
  late final GeneratedColumn<bool> isChannel = GeneratedColumn<bool>(
      'is_channel', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_channel" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPersonalMeta =
      const VerificationMeta('isPersonal');
  @override
  late final GeneratedColumn<bool> isPersonal = GeneratedColumn<bool>(
      'is_personal', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_personal" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isFavoritesMeta =
      const VerificationMeta('isFavorites');
  @override
  late final GeneratedColumn<bool> isFavorites = GeneratedColumn<bool>(
      'is_favorites', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_favorites" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _otherUserJsonMeta =
      const VerificationMeta('otherUserJson');
  @override
  late final GeneratedColumn<String> otherUserJson = GeneratedColumn<String>(
      'other_user_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isEncryptedMeta =
      const VerificationMeta('isEncrypted');
  @override
  late final GeneratedColumn<bool> isEncrypted = GeneratedColumn<bool>(
      'is_encrypted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_encrypted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageTypeMeta =
      const VerificationMeta('lastMessageType');
  @override
  late final GeneratedColumn<String> lastMessageType = GeneratedColumn<String>(
      'last_message_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverChatId,
        name,
        avatar,
        avatarGradient,
        lastMessage,
        lastMessageTime,
        unreadCount,
        isGroup,
        isChannel,
        isPersonal,
        isFavorites,
        otherUserJson,
        isEncrypted,
        isArchived,
        archivedAt,
        lastMessageType
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(Insertable<Chat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_chat_id')) {
      context.handle(
          _serverChatIdMeta,
          serverChatId.isAcceptableOrUnknown(
              data['server_chat_id']!, _serverChatIdMeta));
    } else if (isInserting) {
      context.missing(_serverChatIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta,
          avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('avatar_gradient')) {
      context.handle(
          _avatarGradientMeta,
          avatarGradient.isAcceptableOrUnknown(
              data['avatar_gradient']!, _avatarGradientMeta));
    }
    if (data.containsKey('last_message')) {
      context.handle(
          _lastMessageMeta,
          lastMessage.isAcceptableOrUnknown(
              data['last_message']!, _lastMessageMeta));
    }
    if (data.containsKey('last_message_time')) {
      context.handle(
          _lastMessageTimeMeta,
          lastMessageTime.isAcceptableOrUnknown(
              data['last_message_time']!, _lastMessageTimeMeta));
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    if (data.containsKey('is_group')) {
      context.handle(_isGroupMeta,
          isGroup.isAcceptableOrUnknown(data['is_group']!, _isGroupMeta));
    }
    if (data.containsKey('is_channel')) {
      context.handle(_isChannelMeta,
          isChannel.isAcceptableOrUnknown(data['is_channel']!, _isChannelMeta));
    }
    if (data.containsKey('is_personal')) {
      context.handle(
          _isPersonalMeta,
          isPersonal.isAcceptableOrUnknown(
              data['is_personal']!, _isPersonalMeta));
    }
    if (data.containsKey('is_favorites')) {
      context.handle(
          _isFavoritesMeta,
          isFavorites.isAcceptableOrUnknown(
              data['is_favorites']!, _isFavoritesMeta));
    }
    if (data.containsKey('other_user_json')) {
      context.handle(
          _otherUserJsonMeta,
          otherUserJson.isAcceptableOrUnknown(
              data['other_user_json']!, _otherUserJsonMeta));
    }
    if (data.containsKey('is_encrypted')) {
      context.handle(
          _isEncryptedMeta,
          isEncrypted.isAcceptableOrUnknown(
              data['is_encrypted']!, _isEncryptedMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    if (data.containsKey('last_message_type')) {
      context.handle(
          _lastMessageTypeMeta,
          lastMessageType.isAcceptableOrUnknown(
              data['last_message_type']!, _lastMessageTypeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chat(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverChatId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_chat_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      avatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar']),
      avatarGradient: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_gradient']),
      lastMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_message']),
      lastMessageTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_message_time']),
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
      isGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_group'])!,
      isChannel: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_channel'])!,
      isPersonal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_personal'])!,
      isFavorites: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorites'])!,
      otherUserJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}other_user_json']),
      isEncrypted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_encrypted'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
      lastMessageType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_message_type']),
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class Chat extends DataClass implements Insertable<Chat> {
  final int id;
  final String serverChatId;
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
  final String? otherUserJson;
  final bool isEncrypted;
  final bool isArchived;
  final DateTime? archivedAt;
  final String? lastMessageType;
  const Chat(
      {required this.id,
      required this.serverChatId,
      required this.name,
      this.avatar,
      this.avatarGradient,
      this.lastMessage,
      this.lastMessageTime,
      required this.unreadCount,
      required this.isGroup,
      required this.isChannel,
      required this.isPersonal,
      required this.isFavorites,
      this.otherUserJson,
      required this.isEncrypted,
      required this.isArchived,
      this.archivedAt,
      this.lastMessageType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_chat_id'] = Variable<String>(serverChatId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    if (!nullToAbsent || avatarGradient != null) {
      map['avatar_gradient'] = Variable<String>(avatarGradient);
    }
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
    }
    if (!nullToAbsent || lastMessageTime != null) {
      map['last_message_time'] = Variable<DateTime>(lastMessageTime);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['is_group'] = Variable<bool>(isGroup);
    map['is_channel'] = Variable<bool>(isChannel);
    map['is_personal'] = Variable<bool>(isPersonal);
    map['is_favorites'] = Variable<bool>(isFavorites);
    if (!nullToAbsent || otherUserJson != null) {
      map['other_user_json'] = Variable<String>(otherUserJson);
    }
    map['is_encrypted'] = Variable<bool>(isEncrypted);
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || lastMessageType != null) {
      map['last_message_type'] = Variable<String>(lastMessageType);
    }
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      id: Value(id),
      serverChatId: Value(serverChatId),
      name: Value(name),
      avatar:
          avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      avatarGradient: avatarGradient == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarGradient),
      lastMessage: lastMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessage),
      lastMessageTime: lastMessageTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageTime),
      unreadCount: Value(unreadCount),
      isGroup: Value(isGroup),
      isChannel: Value(isChannel),
      isPersonal: Value(isPersonal),
      isFavorites: Value(isFavorites),
      otherUserJson: otherUserJson == null && nullToAbsent
          ? const Value.absent()
          : Value(otherUserJson),
      isEncrypted: Value(isEncrypted),
      isArchived: Value(isArchived),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      lastMessageType: lastMessageType == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageType),
    );
  }

  factory Chat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chat(
      id: serializer.fromJson<int>(json['id']),
      serverChatId: serializer.fromJson<String>(json['serverChatId']),
      name: serializer.fromJson<String>(json['name']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      avatarGradient: serializer.fromJson<String?>(json['avatarGradient']),
      lastMessage: serializer.fromJson<String?>(json['lastMessage']),
      lastMessageTime: serializer.fromJson<DateTime?>(json['lastMessageTime']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      isGroup: serializer.fromJson<bool>(json['isGroup']),
      isChannel: serializer.fromJson<bool>(json['isChannel']),
      isPersonal: serializer.fromJson<bool>(json['isPersonal']),
      isFavorites: serializer.fromJson<bool>(json['isFavorites']),
      otherUserJson: serializer.fromJson<String?>(json['otherUserJson']),
      isEncrypted: serializer.fromJson<bool>(json['isEncrypted']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      lastMessageType: serializer.fromJson<String?>(json['lastMessageType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverChatId': serializer.toJson<String>(serverChatId),
      'name': serializer.toJson<String>(name),
      'avatar': serializer.toJson<String?>(avatar),
      'avatarGradient': serializer.toJson<String?>(avatarGradient),
      'lastMessage': serializer.toJson<String?>(lastMessage),
      'lastMessageTime': serializer.toJson<DateTime?>(lastMessageTime),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'isGroup': serializer.toJson<bool>(isGroup),
      'isChannel': serializer.toJson<bool>(isChannel),
      'isPersonal': serializer.toJson<bool>(isPersonal),
      'isFavorites': serializer.toJson<bool>(isFavorites),
      'otherUserJson': serializer.toJson<String?>(otherUserJson),
      'isEncrypted': serializer.toJson<bool>(isEncrypted),
      'isArchived': serializer.toJson<bool>(isArchived),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'lastMessageType': serializer.toJson<String?>(lastMessageType),
    };
  }

  Chat copyWith(
          {int? id,
          String? serverChatId,
          String? name,
          Value<String?> avatar = const Value.absent(),
          Value<String?> avatarGradient = const Value.absent(),
          Value<String?> lastMessage = const Value.absent(),
          Value<DateTime?> lastMessageTime = const Value.absent(),
          int? unreadCount,
          bool? isGroup,
          bool? isChannel,
          bool? isPersonal,
          bool? isFavorites,
          Value<String?> otherUserJson = const Value.absent(),
          bool? isEncrypted,
          bool? isArchived,
          Value<DateTime?> archivedAt = const Value.absent(),
          Value<String?> lastMessageType = const Value.absent()}) =>
      Chat(
        id: id ?? this.id,
        serverChatId: serverChatId ?? this.serverChatId,
        name: name ?? this.name,
        avatar: avatar.present ? avatar.value : this.avatar,
        avatarGradient:
            avatarGradient.present ? avatarGradient.value : this.avatarGradient,
        lastMessage: lastMessage.present ? lastMessage.value : this.lastMessage,
        lastMessageTime: lastMessageTime.present
            ? lastMessageTime.value
            : this.lastMessageTime,
        unreadCount: unreadCount ?? this.unreadCount,
        isGroup: isGroup ?? this.isGroup,
        isChannel: isChannel ?? this.isChannel,
        isPersonal: isPersonal ?? this.isPersonal,
        isFavorites: isFavorites ?? this.isFavorites,
        otherUserJson:
            otherUserJson.present ? otherUserJson.value : this.otherUserJson,
        isEncrypted: isEncrypted ?? this.isEncrypted,
        isArchived: isArchived ?? this.isArchived,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
        lastMessageType: lastMessageType.present
            ? lastMessageType.value
            : this.lastMessageType,
      );
  Chat copyWithCompanion(ChatsCompanion data) {
    return Chat(
      id: data.id.present ? data.id.value : this.id,
      serverChatId: data.serverChatId.present
          ? data.serverChatId.value
          : this.serverChatId,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      avatarGradient: data.avatarGradient.present
          ? data.avatarGradient.value
          : this.avatarGradient,
      lastMessage:
          data.lastMessage.present ? data.lastMessage.value : this.lastMessage,
      lastMessageTime: data.lastMessageTime.present
          ? data.lastMessageTime.value
          : this.lastMessageTime,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      isGroup: data.isGroup.present ? data.isGroup.value : this.isGroup,
      isChannel: data.isChannel.present ? data.isChannel.value : this.isChannel,
      isPersonal:
          data.isPersonal.present ? data.isPersonal.value : this.isPersonal,
      isFavorites:
          data.isFavorites.present ? data.isFavorites.value : this.isFavorites,
      otherUserJson: data.otherUserJson.present
          ? data.otherUserJson.value
          : this.otherUserJson,
      isEncrypted:
          data.isEncrypted.present ? data.isEncrypted.value : this.isEncrypted,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      lastMessageType: data.lastMessageType.present
          ? data.lastMessageType.value
          : this.lastMessageType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chat(')
          ..write('id: $id, ')
          ..write('serverChatId: $serverChatId, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('avatarGradient: $avatarGradient, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('isGroup: $isGroup, ')
          ..write('isChannel: $isChannel, ')
          ..write('isPersonal: $isPersonal, ')
          ..write('isFavorites: $isFavorites, ')
          ..write('otherUserJson: $otherUserJson, ')
          ..write('isEncrypted: $isEncrypted, ')
          ..write('isArchived: $isArchived, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('lastMessageType: $lastMessageType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverChatId,
      name,
      avatar,
      avatarGradient,
      lastMessage,
      lastMessageTime,
      unreadCount,
      isGroup,
      isChannel,
      isPersonal,
      isFavorites,
      otherUserJson,
      isEncrypted,
      isArchived,
      archivedAt,
      lastMessageType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chat &&
          other.id == this.id &&
          other.serverChatId == this.serverChatId &&
          other.name == this.name &&
          other.avatar == this.avatar &&
          other.avatarGradient == this.avatarGradient &&
          other.lastMessage == this.lastMessage &&
          other.lastMessageTime == this.lastMessageTime &&
          other.unreadCount == this.unreadCount &&
          other.isGroup == this.isGroup &&
          other.isChannel == this.isChannel &&
          other.isPersonal == this.isPersonal &&
          other.isFavorites == this.isFavorites &&
          other.otherUserJson == this.otherUserJson &&
          other.isEncrypted == this.isEncrypted &&
          other.isArchived == this.isArchived &&
          other.archivedAt == this.archivedAt &&
          other.lastMessageType == this.lastMessageType);
}

class ChatsCompanion extends UpdateCompanion<Chat> {
  final Value<int> id;
  final Value<String> serverChatId;
  final Value<String> name;
  final Value<String?> avatar;
  final Value<String?> avatarGradient;
  final Value<String?> lastMessage;
  final Value<DateTime?> lastMessageTime;
  final Value<int> unreadCount;
  final Value<bool> isGroup;
  final Value<bool> isChannel;
  final Value<bool> isPersonal;
  final Value<bool> isFavorites;
  final Value<String?> otherUserJson;
  final Value<bool> isEncrypted;
  final Value<bool> isArchived;
  final Value<DateTime?> archivedAt;
  final Value<String?> lastMessageType;
  const ChatsCompanion({
    this.id = const Value.absent(),
    this.serverChatId = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    this.avatarGradient = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.isChannel = const Value.absent(),
    this.isPersonal = const Value.absent(),
    this.isFavorites = const Value.absent(),
    this.otherUserJson = const Value.absent(),
    this.isEncrypted = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.lastMessageType = const Value.absent(),
  });
  ChatsCompanion.insert({
    this.id = const Value.absent(),
    required String serverChatId,
    required String name,
    this.avatar = const Value.absent(),
    this.avatarGradient = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastMessageTime = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.isChannel = const Value.absent(),
    this.isPersonal = const Value.absent(),
    this.isFavorites = const Value.absent(),
    this.otherUserJson = const Value.absent(),
    this.isEncrypted = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.lastMessageType = const Value.absent(),
  })  : serverChatId = Value(serverChatId),
        name = Value(name);
  static Insertable<Chat> custom({
    Expression<int>? id,
    Expression<String>? serverChatId,
    Expression<String>? name,
    Expression<String>? avatar,
    Expression<String>? avatarGradient,
    Expression<String>? lastMessage,
    Expression<DateTime>? lastMessageTime,
    Expression<int>? unreadCount,
    Expression<bool>? isGroup,
    Expression<bool>? isChannel,
    Expression<bool>? isPersonal,
    Expression<bool>? isFavorites,
    Expression<String>? otherUserJson,
    Expression<bool>? isEncrypted,
    Expression<bool>? isArchived,
    Expression<DateTime>? archivedAt,
    Expression<String>? lastMessageType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverChatId != null) 'server_chat_id': serverChatId,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (avatarGradient != null) 'avatar_gradient': avatarGradient,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastMessageTime != null) 'last_message_time': lastMessageTime,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (isGroup != null) 'is_group': isGroup,
      if (isChannel != null) 'is_channel': isChannel,
      if (isPersonal != null) 'is_personal': isPersonal,
      if (isFavorites != null) 'is_favorites': isFavorites,
      if (otherUserJson != null) 'other_user_json': otherUserJson,
      if (isEncrypted != null) 'is_encrypted': isEncrypted,
      if (isArchived != null) 'is_archived': isArchived,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (lastMessageType != null) 'last_message_type': lastMessageType,
    });
  }

  ChatsCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverChatId,
      Value<String>? name,
      Value<String?>? avatar,
      Value<String?>? avatarGradient,
      Value<String?>? lastMessage,
      Value<DateTime?>? lastMessageTime,
      Value<int>? unreadCount,
      Value<bool>? isGroup,
      Value<bool>? isChannel,
      Value<bool>? isPersonal,
      Value<bool>? isFavorites,
      Value<String?>? otherUserJson,
      Value<bool>? isEncrypted,
      Value<bool>? isArchived,
      Value<DateTime?>? archivedAt,
      Value<String?>? lastMessageType}) {
    return ChatsCompanion(
      id: id ?? this.id,
      serverChatId: serverChatId ?? this.serverChatId,
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
      otherUserJson: otherUserJson ?? this.otherUserJson,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      lastMessageType: lastMessageType ?? this.lastMessageType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverChatId.present) {
      map['server_chat_id'] = Variable<String>(serverChatId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (avatarGradient.present) {
      map['avatar_gradient'] = Variable<String>(avatarGradient.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (lastMessageTime.present) {
      map['last_message_time'] = Variable<DateTime>(lastMessageTime.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (isGroup.present) {
      map['is_group'] = Variable<bool>(isGroup.value);
    }
    if (isChannel.present) {
      map['is_channel'] = Variable<bool>(isChannel.value);
    }
    if (isPersonal.present) {
      map['is_personal'] = Variable<bool>(isPersonal.value);
    }
    if (isFavorites.present) {
      map['is_favorites'] = Variable<bool>(isFavorites.value);
    }
    if (otherUserJson.present) {
      map['other_user_json'] = Variable<String>(otherUserJson.value);
    }
    if (isEncrypted.present) {
      map['is_encrypted'] = Variable<bool>(isEncrypted.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (lastMessageType.present) {
      map['last_message_type'] = Variable<String>(lastMessageType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatsCompanion(')
          ..write('id: $id, ')
          ..write('serverChatId: $serverChatId, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('avatarGradient: $avatarGradient, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastMessageTime: $lastMessageTime, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('isGroup: $isGroup, ')
          ..write('isChannel: $isChannel, ')
          ..write('isPersonal: $isPersonal, ')
          ..write('isFavorites: $isFavorites, ')
          ..write('otherUserJson: $otherUserJson, ')
          ..write('isEncrypted: $isEncrypted, ')
          ..write('isArchived: $isArchived, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('lastMessageType: $lastMessageType')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverMessageIdMeta =
      const VerificationMeta('serverMessageId');
  @override
  late final GeneratedColumn<String> serverMessageId = GeneratedColumn<String>(
      'server_message_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
      'chat_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chats (id)'));
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textContentMeta =
      const VerificationMeta('textContent');
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
      'text_content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileUrlMeta =
      const VerificationMeta('fileUrl');
  @override
  late final GeneratedColumn<String> fileUrl = GeneratedColumn<String>(
      'file_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _messageTypeMeta =
      const VerificationMeta('messageType');
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
      'message_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completionStatusMeta =
      const VerificationMeta('completionStatus');
  @override
  late final GeneratedColumn<String> completionStatus = GeneratedColumn<String>(
      'completion_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _votesByOptionMeta =
      const VerificationMeta('votesByOption');
  @override
  late final GeneratedColumn<String> votesByOption = GeneratedColumn<String>(
      'votes_by_option', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userVotesMeta =
      const VerificationMeta('userVotes');
  @override
  late final GeneratedColumn<String> userVotes = GeneratedColumn<String>(
      'user_votes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _replyToIdMeta =
      const VerificationMeta('replyToId');
  @override
  late final GeneratedColumn<String> replyToId = GeneratedColumn<String>(
      'reply_to_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _replyTextMeta =
      const VerificationMeta('replyText');
  @override
  late final GeneratedColumn<String> replyText = GeneratedColumn<String>(
      'reply_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _replyAuthorNameMeta =
      const VerificationMeta('replyAuthorName');
  @override
  late final GeneratedColumn<String> replyAuthorName = GeneratedColumn<String>(
      'reply_author_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _replyMarkupMeta =
      const VerificationMeta('replyMarkup');
  @override
  late final GeneratedColumn<String> replyMarkup = GeneratedColumn<String>(
      'reply_markup', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _messageDataMeta =
      const VerificationMeta('messageData');
  @override
  late final GeneratedColumn<String> messageData = GeneratedColumn<String>(
      'message_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverMessageId,
        chatId,
        senderId,
        textContent,
        fileUrl,
        isRead,
        timestamp,
        messageType,
        messageId,
        completionStatus,
        votesByOption,
        userVotes,
        replyToId,
        replyText,
        replyAuthorName,
        replyMarkup,
        messageData
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_message_id')) {
      context.handle(
          _serverMessageIdMeta,
          serverMessageId.isAcceptableOrUnknown(
              data['server_message_id']!, _serverMessageIdMeta));
    } else if (isInserting) {
      context.missing(_serverMessageIdMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(_chatIdMeta,
          chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta));
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
          _textContentMeta,
          textContent.isAcceptableOrUnknown(
              data['text_content']!, _textContentMeta));
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('file_url')) {
      context.handle(_fileUrlMeta,
          fileUrl.isAcceptableOrUnknown(data['file_url']!, _fileUrlMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
          _messageTypeMeta,
          messageType.isAcceptableOrUnknown(
              data['message_type']!, _messageTypeMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    }
    if (data.containsKey('completion_status')) {
      context.handle(
          _completionStatusMeta,
          completionStatus.isAcceptableOrUnknown(
              data['completion_status']!, _completionStatusMeta));
    }
    if (data.containsKey('votes_by_option')) {
      context.handle(
          _votesByOptionMeta,
          votesByOption.isAcceptableOrUnknown(
              data['votes_by_option']!, _votesByOptionMeta));
    }
    if (data.containsKey('user_votes')) {
      context.handle(_userVotesMeta,
          userVotes.isAcceptableOrUnknown(data['user_votes']!, _userVotesMeta));
    }
    if (data.containsKey('reply_to_id')) {
      context.handle(
          _replyToIdMeta,
          replyToId.isAcceptableOrUnknown(
              data['reply_to_id']!, _replyToIdMeta));
    }
    if (data.containsKey('reply_text')) {
      context.handle(_replyTextMeta,
          replyText.isAcceptableOrUnknown(data['reply_text']!, _replyTextMeta));
    }
    if (data.containsKey('reply_author_name')) {
      context.handle(
          _replyAuthorNameMeta,
          replyAuthorName.isAcceptableOrUnknown(
              data['reply_author_name']!, _replyAuthorNameMeta));
    }
    if (data.containsKey('reply_markup')) {
      context.handle(
          _replyMarkupMeta,
          replyMarkup.isAcceptableOrUnknown(
              data['reply_markup']!, _replyMarkupMeta));
    }
    if (data.containsKey('message_data')) {
      context.handle(
          _messageDataMeta,
          messageData.isAcceptableOrUnknown(
              data['message_data']!, _messageDataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}server_message_id'])!,
      chatId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chat_id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      textContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_content'])!,
      fileUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_url']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      messageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_type']),
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id']),
      completionStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}completion_status']),
      votesByOption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}votes_by_option']),
      userVotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_votes']),
      replyToId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_to_id']),
      replyText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_text']),
      replyAuthorName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reply_author_name']),
      replyMarkup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_markup']),
      messageData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_data']),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final String serverMessageId;
  final int chatId;
  final String senderId;
  final String textContent;
  final String? fileUrl;
  final bool isRead;
  final DateTime timestamp;
  final String? messageType;
  final String? messageId;
  final String? completionStatus;
  final String? votesByOption;
  final String? userVotes;
  final String? replyToId;
  final String? replyText;
  final String? replyAuthorName;
  final String? replyMarkup;
  final String? messageData;
  const Message(
      {required this.id,
      required this.serverMessageId,
      required this.chatId,
      required this.senderId,
      required this.textContent,
      this.fileUrl,
      required this.isRead,
      required this.timestamp,
      this.messageType,
      this.messageId,
      this.completionStatus,
      this.votesByOption,
      this.userVotes,
      this.replyToId,
      this.replyText,
      this.replyAuthorName,
      this.replyMarkup,
      this.messageData});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_message_id'] = Variable<String>(serverMessageId);
    map['chat_id'] = Variable<int>(chatId);
    map['sender_id'] = Variable<String>(senderId);
    map['text_content'] = Variable<String>(textContent);
    if (!nullToAbsent || fileUrl != null) {
      map['file_url'] = Variable<String>(fileUrl);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || messageType != null) {
      map['message_type'] = Variable<String>(messageType);
    }
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<String>(messageId);
    }
    if (!nullToAbsent || completionStatus != null) {
      map['completion_status'] = Variable<String>(completionStatus);
    }
    if (!nullToAbsent || votesByOption != null) {
      map['votes_by_option'] = Variable<String>(votesByOption);
    }
    if (!nullToAbsent || userVotes != null) {
      map['user_votes'] = Variable<String>(userVotes);
    }
    if (!nullToAbsent || replyToId != null) {
      map['reply_to_id'] = Variable<String>(replyToId);
    }
    if (!nullToAbsent || replyText != null) {
      map['reply_text'] = Variable<String>(replyText);
    }
    if (!nullToAbsent || replyAuthorName != null) {
      map['reply_author_name'] = Variable<String>(replyAuthorName);
    }
    if (!nullToAbsent || replyMarkup != null) {
      map['reply_markup'] = Variable<String>(replyMarkup);
    }
    if (!nullToAbsent || messageData != null) {
      map['message_data'] = Variable<String>(messageData);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      serverMessageId: Value(serverMessageId),
      chatId: Value(chatId),
      senderId: Value(senderId),
      textContent: Value(textContent),
      fileUrl: fileUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fileUrl),
      isRead: Value(isRead),
      timestamp: Value(timestamp),
      messageType: messageType == null && nullToAbsent
          ? const Value.absent()
          : Value(messageType),
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      completionStatus: completionStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(completionStatus),
      votesByOption: votesByOption == null && nullToAbsent
          ? const Value.absent()
          : Value(votesByOption),
      userVotes: userVotes == null && nullToAbsent
          ? const Value.absent()
          : Value(userVotes),
      replyToId: replyToId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToId),
      replyText: replyText == null && nullToAbsent
          ? const Value.absent()
          : Value(replyText),
      replyAuthorName: replyAuthorName == null && nullToAbsent
          ? const Value.absent()
          : Value(replyAuthorName),
      replyMarkup: replyMarkup == null && nullToAbsent
          ? const Value.absent()
          : Value(replyMarkup),
      messageData: messageData == null && nullToAbsent
          ? const Value.absent()
          : Value(messageData),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      serverMessageId: serializer.fromJson<String>(json['serverMessageId']),
      chatId: serializer.fromJson<int>(json['chatId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      textContent: serializer.fromJson<String>(json['textContent']),
      fileUrl: serializer.fromJson<String?>(json['fileUrl']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      messageType: serializer.fromJson<String?>(json['messageType']),
      messageId: serializer.fromJson<String?>(json['messageId']),
      completionStatus: serializer.fromJson<String?>(json['completionStatus']),
      votesByOption: serializer.fromJson<String?>(json['votesByOption']),
      userVotes: serializer.fromJson<String?>(json['userVotes']),
      replyToId: serializer.fromJson<String?>(json['replyToId']),
      replyText: serializer.fromJson<String?>(json['replyText']),
      replyAuthorName: serializer.fromJson<String?>(json['replyAuthorName']),
      replyMarkup: serializer.fromJson<String?>(json['replyMarkup']),
      messageData: serializer.fromJson<String?>(json['messageData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverMessageId': serializer.toJson<String>(serverMessageId),
      'chatId': serializer.toJson<int>(chatId),
      'senderId': serializer.toJson<String>(senderId),
      'textContent': serializer.toJson<String>(textContent),
      'fileUrl': serializer.toJson<String?>(fileUrl),
      'isRead': serializer.toJson<bool>(isRead),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'messageType': serializer.toJson<String?>(messageType),
      'messageId': serializer.toJson<String?>(messageId),
      'completionStatus': serializer.toJson<String?>(completionStatus),
      'votesByOption': serializer.toJson<String?>(votesByOption),
      'userVotes': serializer.toJson<String?>(userVotes),
      'replyToId': serializer.toJson<String?>(replyToId),
      'replyText': serializer.toJson<String?>(replyText),
      'replyAuthorName': serializer.toJson<String?>(replyAuthorName),
      'replyMarkup': serializer.toJson<String?>(replyMarkup),
      'messageData': serializer.toJson<String?>(messageData),
    };
  }

  Message copyWith(
          {int? id,
          String? serverMessageId,
          int? chatId,
          String? senderId,
          String? textContent,
          Value<String?> fileUrl = const Value.absent(),
          bool? isRead,
          DateTime? timestamp,
          Value<String?> messageType = const Value.absent(),
          Value<String?> messageId = const Value.absent(),
          Value<String?> completionStatus = const Value.absent(),
          Value<String?> votesByOption = const Value.absent(),
          Value<String?> userVotes = const Value.absent(),
          Value<String?> replyToId = const Value.absent(),
          Value<String?> replyText = const Value.absent(),
          Value<String?> replyAuthorName = const Value.absent(),
          Value<String?> replyMarkup = const Value.absent(),
          Value<String?> messageData = const Value.absent()}) =>
      Message(
        id: id ?? this.id,
        serverMessageId: serverMessageId ?? this.serverMessageId,
        chatId: chatId ?? this.chatId,
        senderId: senderId ?? this.senderId,
        textContent: textContent ?? this.textContent,
        fileUrl: fileUrl.present ? fileUrl.value : this.fileUrl,
        isRead: isRead ?? this.isRead,
        timestamp: timestamp ?? this.timestamp,
        messageType: messageType.present ? messageType.value : this.messageType,
        messageId: messageId.present ? messageId.value : this.messageId,
        completionStatus: completionStatus.present
            ? completionStatus.value
            : this.completionStatus,
        votesByOption:
            votesByOption.present ? votesByOption.value : this.votesByOption,
        userVotes: userVotes.present ? userVotes.value : this.userVotes,
        replyToId: replyToId.present ? replyToId.value : this.replyToId,
        replyText: replyText.present ? replyText.value : this.replyText,
        replyAuthorName: replyAuthorName.present
            ? replyAuthorName.value
            : this.replyAuthorName,
        replyMarkup: replyMarkup.present ? replyMarkup.value : this.replyMarkup,
        messageData: messageData.present ? messageData.value : this.messageData,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      serverMessageId: data.serverMessageId.present
          ? data.serverMessageId.value
          : this.serverMessageId,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      textContent:
          data.textContent.present ? data.textContent.value : this.textContent,
      fileUrl: data.fileUrl.present ? data.fileUrl.value : this.fileUrl,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      messageType:
          data.messageType.present ? data.messageType.value : this.messageType,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      completionStatus: data.completionStatus.present
          ? data.completionStatus.value
          : this.completionStatus,
      votesByOption: data.votesByOption.present
          ? data.votesByOption.value
          : this.votesByOption,
      userVotes: data.userVotes.present ? data.userVotes.value : this.userVotes,
      replyToId: data.replyToId.present ? data.replyToId.value : this.replyToId,
      replyText: data.replyText.present ? data.replyText.value : this.replyText,
      replyAuthorName: data.replyAuthorName.present
          ? data.replyAuthorName.value
          : this.replyAuthorName,
      replyMarkup:
          data.replyMarkup.present ? data.replyMarkup.value : this.replyMarkup,
      messageData:
          data.messageData.present ? data.messageData.value : this.messageData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('serverMessageId: $serverMessageId, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('textContent: $textContent, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('isRead: $isRead, ')
          ..write('timestamp: $timestamp, ')
          ..write('messageType: $messageType, ')
          ..write('messageId: $messageId, ')
          ..write('completionStatus: $completionStatus, ')
          ..write('votesByOption: $votesByOption, ')
          ..write('userVotes: $userVotes, ')
          ..write('replyToId: $replyToId, ')
          ..write('replyText: $replyText, ')
          ..write('replyAuthorName: $replyAuthorName, ')
          ..write('replyMarkup: $replyMarkup, ')
          ..write('messageData: $messageData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverMessageId,
      chatId,
      senderId,
      textContent,
      fileUrl,
      isRead,
      timestamp,
      messageType,
      messageId,
      completionStatus,
      votesByOption,
      userVotes,
      replyToId,
      replyText,
      replyAuthorName,
      replyMarkup,
      messageData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.serverMessageId == this.serverMessageId &&
          other.chatId == this.chatId &&
          other.senderId == this.senderId &&
          other.textContent == this.textContent &&
          other.fileUrl == this.fileUrl &&
          other.isRead == this.isRead &&
          other.timestamp == this.timestamp &&
          other.messageType == this.messageType &&
          other.messageId == this.messageId &&
          other.completionStatus == this.completionStatus &&
          other.votesByOption == this.votesByOption &&
          other.userVotes == this.userVotes &&
          other.replyToId == this.replyToId &&
          other.replyText == this.replyText &&
          other.replyAuthorName == this.replyAuthorName &&
          other.replyMarkup == this.replyMarkup &&
          other.messageData == this.messageData);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<String> serverMessageId;
  final Value<int> chatId;
  final Value<String> senderId;
  final Value<String> textContent;
  final Value<String?> fileUrl;
  final Value<bool> isRead;
  final Value<DateTime> timestamp;
  final Value<String?> messageType;
  final Value<String?> messageId;
  final Value<String?> completionStatus;
  final Value<String?> votesByOption;
  final Value<String?> userVotes;
  final Value<String?> replyToId;
  final Value<String?> replyText;
  final Value<String?> replyAuthorName;
  final Value<String?> replyMarkup;
  final Value<String?> messageData;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.serverMessageId = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.textContent = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.isRead = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.messageType = const Value.absent(),
    this.messageId = const Value.absent(),
    this.completionStatus = const Value.absent(),
    this.votesByOption = const Value.absent(),
    this.userVotes = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.replyText = const Value.absent(),
    this.replyAuthorName = const Value.absent(),
    this.replyMarkup = const Value.absent(),
    this.messageData = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required String serverMessageId,
    required int chatId,
    required String senderId,
    required String textContent,
    this.fileUrl = const Value.absent(),
    this.isRead = const Value.absent(),
    required DateTime timestamp,
    this.messageType = const Value.absent(),
    this.messageId = const Value.absent(),
    this.completionStatus = const Value.absent(),
    this.votesByOption = const Value.absent(),
    this.userVotes = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.replyText = const Value.absent(),
    this.replyAuthorName = const Value.absent(),
    this.replyMarkup = const Value.absent(),
    this.messageData = const Value.absent(),
  })  : serverMessageId = Value(serverMessageId),
        chatId = Value(chatId),
        senderId = Value(senderId),
        textContent = Value(textContent),
        timestamp = Value(timestamp);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<String>? serverMessageId,
    Expression<int>? chatId,
    Expression<String>? senderId,
    Expression<String>? textContent,
    Expression<String>? fileUrl,
    Expression<bool>? isRead,
    Expression<DateTime>? timestamp,
    Expression<String>? messageType,
    Expression<String>? messageId,
    Expression<String>? completionStatus,
    Expression<String>? votesByOption,
    Expression<String>? userVotes,
    Expression<String>? replyToId,
    Expression<String>? replyText,
    Expression<String>? replyAuthorName,
    Expression<String>? replyMarkup,
    Expression<String>? messageData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverMessageId != null) 'server_message_id': serverMessageId,
      if (chatId != null) 'chat_id': chatId,
      if (senderId != null) 'sender_id': senderId,
      if (textContent != null) 'text_content': textContent,
      if (fileUrl != null) 'file_url': fileUrl,
      if (isRead != null) 'is_read': isRead,
      if (timestamp != null) 'timestamp': timestamp,
      if (messageType != null) 'message_type': messageType,
      if (messageId != null) 'message_id': messageId,
      if (completionStatus != null) 'completion_status': completionStatus,
      if (votesByOption != null) 'votes_by_option': votesByOption,
      if (userVotes != null) 'user_votes': userVotes,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (replyText != null) 'reply_text': replyText,
      if (replyAuthorName != null) 'reply_author_name': replyAuthorName,
      if (replyMarkup != null) 'reply_markup': replyMarkup,
      if (messageData != null) 'message_data': messageData,
    });
  }

  MessagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverMessageId,
      Value<int>? chatId,
      Value<String>? senderId,
      Value<String>? textContent,
      Value<String?>? fileUrl,
      Value<bool>? isRead,
      Value<DateTime>? timestamp,
      Value<String?>? messageType,
      Value<String?>? messageId,
      Value<String?>? completionStatus,
      Value<String?>? votesByOption,
      Value<String?>? userVotes,
      Value<String?>? replyToId,
      Value<String?>? replyText,
      Value<String?>? replyAuthorName,
      Value<String?>? replyMarkup,
      Value<String?>? messageData}) {
    return MessagesCompanion(
      id: id ?? this.id,
      serverMessageId: serverMessageId ?? this.serverMessageId,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      textContent: textContent ?? this.textContent,
      fileUrl: fileUrl ?? this.fileUrl,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      messageId: messageId ?? this.messageId,
      completionStatus: completionStatus ?? this.completionStatus,
      votesByOption: votesByOption ?? this.votesByOption,
      userVotes: userVotes ?? this.userVotes,
      replyToId: replyToId ?? this.replyToId,
      replyText: replyText ?? this.replyText,
      replyAuthorName: replyAuthorName ?? this.replyAuthorName,
      replyMarkup: replyMarkup ?? this.replyMarkup,
      messageData: messageData ?? this.messageData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverMessageId.present) {
      map['server_message_id'] = Variable<String>(serverMessageId.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (fileUrl.present) {
      map['file_url'] = Variable<String>(fileUrl.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (completionStatus.present) {
      map['completion_status'] = Variable<String>(completionStatus.value);
    }
    if (votesByOption.present) {
      map['votes_by_option'] = Variable<String>(votesByOption.value);
    }
    if (userVotes.present) {
      map['user_votes'] = Variable<String>(userVotes.value);
    }
    if (replyToId.present) {
      map['reply_to_id'] = Variable<String>(replyToId.value);
    }
    if (replyText.present) {
      map['reply_text'] = Variable<String>(replyText.value);
    }
    if (replyAuthorName.present) {
      map['reply_author_name'] = Variable<String>(replyAuthorName.value);
    }
    if (replyMarkup.present) {
      map['reply_markup'] = Variable<String>(replyMarkup.value);
    }
    if (messageData.present) {
      map['message_data'] = Variable<String>(messageData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('serverMessageId: $serverMessageId, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('textContent: $textContent, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('isRead: $isRead, ')
          ..write('timestamp: $timestamp, ')
          ..write('messageType: $messageType, ')
          ..write('messageId: $messageId, ')
          ..write('completionStatus: $completionStatus, ')
          ..write('votesByOption: $votesByOption, ')
          ..write('userVotes: $userVotes, ')
          ..write('replyToId: $replyToId, ')
          ..write('replyText: $replyText, ')
          ..write('replyAuthorName: $replyAuthorName, ')
          ..write('replyMarkup: $replyMarkup, ')
          ..write('messageData: $messageData')
          ..write(')'))
        .toString();
  }
}

class $AudioTracksTable extends AudioTracks
    with TableInfo<$AudioTracksTable, AudioTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceUrlMeta =
      const VerificationMeta('sourceUrl');
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
      'source_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
      'artist', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
      'album', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _artworkUriMeta =
      const VerificationMeta('artworkUri');
  @override
  late final GeneratedColumn<String> artworkUri = GeneratedColumn<String>(
      'artwork_uri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioDataMeta =
      const VerificationMeta('audioData');
  @override
  late final GeneratedColumn<Uint8List> audioData = GeneratedColumn<Uint8List>(
      'audio_data', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _compressionMeta =
      const VerificationMeta('compression');
  @override
  late final GeneratedColumn<String> compression = GeneratedColumn<String>(
      'compression', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalBytesMeta =
      const VerificationMeta('originalBytes');
  @override
  late final GeneratedColumn<int> originalBytes = GeneratedColumn<int>(
      'original_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _storedBytesMeta =
      const VerificationMeta('storedBytes');
  @override
  late final GeneratedColumn<int> storedBytes = GeneratedColumn<int>(
      'stored_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastAccessedAtMeta =
      const VerificationMeta('lastAccessedAt');
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>('last_accessed_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        sourceUrl,
        title,
        artist,
        album,
        mimeType,
        durationMs,
        artworkUri,
        audioData,
        compression,
        originalBytes,
        storedBytes,
        lastAccessedAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_tracks';
  @override
  VerificationContext validateIntegrity(Insertable<AudioTrack> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_url')) {
      context.handle(_sourceUrlMeta,
          sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta));
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('artist')) {
      context.handle(_artistMeta,
          artist.isAcceptableOrUnknown(data['artist']!, _artistMeta));
    }
    if (data.containsKey('album')) {
      context.handle(
          _albumMeta, album.isAcceptableOrUnknown(data['album']!, _albumMeta));
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('artwork_uri')) {
      context.handle(
          _artworkUriMeta,
          artworkUri.isAcceptableOrUnknown(
              data['artwork_uri']!, _artworkUriMeta));
    }
    if (data.containsKey('audio_data')) {
      context.handle(_audioDataMeta,
          audioData.isAcceptableOrUnknown(data['audio_data']!, _audioDataMeta));
    }
    if (data.containsKey('compression')) {
      context.handle(
          _compressionMeta,
          compression.isAcceptableOrUnknown(
              data['compression']!, _compressionMeta));
    }
    if (data.containsKey('original_bytes')) {
      context.handle(
          _originalBytesMeta,
          originalBytes.isAcceptableOrUnknown(
              data['original_bytes']!, _originalBytesMeta));
    }
    if (data.containsKey('stored_bytes')) {
      context.handle(
          _storedBytesMeta,
          storedBytes.isAcceptableOrUnknown(
              data['stored_bytes']!, _storedBytesMeta));
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
          _lastAccessedAtMeta,
          lastAccessedAt.isAcceptableOrUnknown(
              data['last_accessed_at']!, _lastAccessedAtMeta));
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceUrl};
  @override
  AudioTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioTrack(
      sourceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_url'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist'])!,
      album: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms']),
      artworkUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artwork_uri']),
      audioData: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}audio_data']),
      compression: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}compression']),
      originalBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}original_bytes'])!,
      storedBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stored_bytes'])!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_accessed_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AudioTracksTable createAlias(String alias) {
    return $AudioTracksTable(attachedDatabase, alias);
  }
}

class AudioTrack extends DataClass implements Insertable<AudioTrack> {
  final String sourceUrl;
  final String title;
  final String artist;
  final String album;
  final String? mimeType;
  final int? durationMs;
  final String? artworkUri;
  final Uint8List? audioData;
  final String? compression;
  final int originalBytes;
  final int storedBytes;
  final DateTime lastAccessedAt;
  final DateTime updatedAt;
  const AudioTrack(
      {required this.sourceUrl,
      required this.title,
      required this.artist,
      required this.album,
      this.mimeType,
      this.durationMs,
      this.artworkUri,
      this.audioData,
      this.compression,
      required this.originalBytes,
      required this.storedBytes,
      required this.lastAccessedAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_url'] = Variable<String>(sourceUrl);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || artworkUri != null) {
      map['artwork_uri'] = Variable<String>(artworkUri);
    }
    if (!nullToAbsent || audioData != null) {
      map['audio_data'] = Variable<Uint8List>(audioData);
    }
    if (!nullToAbsent || compression != null) {
      map['compression'] = Variable<String>(compression);
    }
    map['original_bytes'] = Variable<int>(originalBytes);
    map['stored_bytes'] = Variable<int>(storedBytes);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AudioTracksCompanion toCompanion(bool nullToAbsent) {
    return AudioTracksCompanion(
      sourceUrl: Value(sourceUrl),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      artworkUri: artworkUri == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUri),
      audioData: audioData == null && nullToAbsent
          ? const Value.absent()
          : Value(audioData),
      compression: compression == null && nullToAbsent
          ? const Value.absent()
          : Value(compression),
      originalBytes: Value(originalBytes),
      storedBytes: Value(storedBytes),
      lastAccessedAt: Value(lastAccessedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AudioTrack.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioTrack(
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      artworkUri: serializer.fromJson<String?>(json['artworkUri']),
      audioData: serializer.fromJson<Uint8List?>(json['audioData']),
      compression: serializer.fromJson<String?>(json['compression']),
      originalBytes: serializer.fromJson<int>(json['originalBytes']),
      storedBytes: serializer.fromJson<int>(json['storedBytes']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'mimeType': serializer.toJson<String?>(mimeType),
      'durationMs': serializer.toJson<int?>(durationMs),
      'artworkUri': serializer.toJson<String?>(artworkUri),
      'audioData': serializer.toJson<Uint8List?>(audioData),
      'compression': serializer.toJson<String?>(compression),
      'originalBytes': serializer.toJson<int>(originalBytes),
      'storedBytes': serializer.toJson<int>(storedBytes),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AudioTrack copyWith(
          {String? sourceUrl,
          String? title,
          String? artist,
          String? album,
          Value<String?> mimeType = const Value.absent(),
          Value<int?> durationMs = const Value.absent(),
          Value<String?> artworkUri = const Value.absent(),
          Value<Uint8List?> audioData = const Value.absent(),
          Value<String?> compression = const Value.absent(),
          int? originalBytes,
          int? storedBytes,
          DateTime? lastAccessedAt,
          DateTime? updatedAt}) =>
      AudioTrack(
        sourceUrl: sourceUrl ?? this.sourceUrl,
        title: title ?? this.title,
        artist: artist ?? this.artist,
        album: album ?? this.album,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        durationMs: durationMs.present ? durationMs.value : this.durationMs,
        artworkUri: artworkUri.present ? artworkUri.value : this.artworkUri,
        audioData: audioData.present ? audioData.value : this.audioData,
        compression: compression.present ? compression.value : this.compression,
        originalBytes: originalBytes ?? this.originalBytes,
        storedBytes: storedBytes ?? this.storedBytes,
        lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AudioTrack copyWithCompanion(AudioTracksCompanion data) {
    return AudioTrack(
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      artworkUri:
          data.artworkUri.present ? data.artworkUri.value : this.artworkUri,
      audioData: data.audioData.present ? data.audioData.value : this.audioData,
      compression:
          data.compression.present ? data.compression.value : this.compression,
      originalBytes: data.originalBytes.present
          ? data.originalBytes.value
          : this.originalBytes,
      storedBytes:
          data.storedBytes.present ? data.storedBytes.value : this.storedBytes,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioTrack(')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('mimeType: $mimeType, ')
          ..write('durationMs: $durationMs, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('audioData: $audioData, ')
          ..write('compression: $compression, ')
          ..write('originalBytes: $originalBytes, ')
          ..write('storedBytes: $storedBytes, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      sourceUrl,
      title,
      artist,
      album,
      mimeType,
      durationMs,
      artworkUri,
      $driftBlobEquality.hash(audioData),
      compression,
      originalBytes,
      storedBytes,
      lastAccessedAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioTrack &&
          other.sourceUrl == this.sourceUrl &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.mimeType == this.mimeType &&
          other.durationMs == this.durationMs &&
          other.artworkUri == this.artworkUri &&
          $driftBlobEquality.equals(other.audioData, this.audioData) &&
          other.compression == this.compression &&
          other.originalBytes == this.originalBytes &&
          other.storedBytes == this.storedBytes &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.updatedAt == this.updatedAt);
}

class AudioTracksCompanion extends UpdateCompanion<AudioTrack> {
  final Value<String> sourceUrl;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<String?> mimeType;
  final Value<int?> durationMs;
  final Value<String?> artworkUri;
  final Value<Uint8List?> audioData;
  final Value<String?> compression;
  final Value<int> originalBytes;
  final Value<int> storedBytes;
  final Value<DateTime> lastAccessedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AudioTracksCompanion({
    this.sourceUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.audioData = const Value.absent(),
    this.compression = const Value.absent(),
    this.originalBytes = const Value.absent(),
    this.storedBytes = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioTracksCompanion.insert({
    required String sourceUrl,
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.artworkUri = const Value.absent(),
    this.audioData = const Value.absent(),
    this.compression = const Value.absent(),
    this.originalBytes = const Value.absent(),
    this.storedBytes = const Value.absent(),
    required DateTime lastAccessedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : sourceUrl = Value(sourceUrl),
        lastAccessedAt = Value(lastAccessedAt),
        updatedAt = Value(updatedAt);
  static Insertable<AudioTrack> custom({
    Expression<String>? sourceUrl,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? mimeType,
    Expression<int>? durationMs,
    Expression<String>? artworkUri,
    Expression<Uint8List>? audioData,
    Expression<String>? compression,
    Expression<int>? originalBytes,
    Expression<int>? storedBytes,
    Expression<DateTime>? lastAccessedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (mimeType != null) 'mime_type': mimeType,
      if (durationMs != null) 'duration_ms': durationMs,
      if (artworkUri != null) 'artwork_uri': artworkUri,
      if (audioData != null) 'audio_data': audioData,
      if (compression != null) 'compression': compression,
      if (originalBytes != null) 'original_bytes': originalBytes,
      if (storedBytes != null) 'stored_bytes': storedBytes,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioTracksCompanion copyWith(
      {Value<String>? sourceUrl,
      Value<String>? title,
      Value<String>? artist,
      Value<String>? album,
      Value<String?>? mimeType,
      Value<int?>? durationMs,
      Value<String?>? artworkUri,
      Value<Uint8List?>? audioData,
      Value<String?>? compression,
      Value<int>? originalBytes,
      Value<int>? storedBytes,
      Value<DateTime>? lastAccessedAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AudioTracksCompanion(
      sourceUrl: sourceUrl ?? this.sourceUrl,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      mimeType: mimeType ?? this.mimeType,
      durationMs: durationMs ?? this.durationMs,
      artworkUri: artworkUri ?? this.artworkUri,
      audioData: audioData ?? this.audioData,
      compression: compression ?? this.compression,
      originalBytes: originalBytes ?? this.originalBytes,
      storedBytes: storedBytes ?? this.storedBytes,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (artworkUri.present) {
      map['artwork_uri'] = Variable<String>(artworkUri.value);
    }
    if (audioData.present) {
      map['audio_data'] = Variable<Uint8List>(audioData.value);
    }
    if (compression.present) {
      map['compression'] = Variable<String>(compression.value);
    }
    if (originalBytes.present) {
      map['original_bytes'] = Variable<int>(originalBytes.value);
    }
    if (storedBytes.present) {
      map['stored_bytes'] = Variable<int>(storedBytes.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioTracksCompanion(')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('mimeType: $mimeType, ')
          ..write('durationMs: $durationMs, ')
          ..write('artworkUri: $artworkUri, ')
          ..write('audioData: $audioData, ')
          ..write('compression: $compression, ')
          ..write('originalBytes: $originalBytes, ')
          ..write('storedBytes: $storedBytes, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $AudioTracksTable audioTracks = $AudioTracksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [chats, messages, audioTracks];
}

typedef $$ChatsTableCreateCompanionBuilder = ChatsCompanion Function({
  Value<int> id,
  required String serverChatId,
  required String name,
  Value<String?> avatar,
  Value<String?> avatarGradient,
  Value<String?> lastMessage,
  Value<DateTime?> lastMessageTime,
  Value<int> unreadCount,
  Value<bool> isGroup,
  Value<bool> isChannel,
  Value<bool> isPersonal,
  Value<bool> isFavorites,
  Value<String?> otherUserJson,
  Value<bool> isEncrypted,
  Value<bool> isArchived,
  Value<DateTime?> archivedAt,
  Value<String?> lastMessageType,
});
typedef $$ChatsTableUpdateCompanionBuilder = ChatsCompanion Function({
  Value<int> id,
  Value<String> serverChatId,
  Value<String> name,
  Value<String?> avatar,
  Value<String?> avatarGradient,
  Value<String?> lastMessage,
  Value<DateTime?> lastMessageTime,
  Value<int> unreadCount,
  Value<bool> isGroup,
  Value<bool> isChannel,
  Value<bool> isPersonal,
  Value<bool> isFavorites,
  Value<String?> otherUserJson,
  Value<bool> isEncrypted,
  Value<bool> isArchived,
  Value<DateTime?> archivedAt,
  Value<String?> lastMessageType,
});

final class $$ChatsTableReferences
    extends BaseReferences<_$AppDatabase, $ChatsTable, Chat> {
  $$ChatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.messages,
          aliasName: 'chats__id__messages__chat_id');

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager($_db, $_db.messages)
        .filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ChatsTableFilterComposer extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverChatId => $composableBuilder(
      column: $table.serverChatId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarGradient => $composableBuilder(
      column: $table.avatarGradient,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMessageTime => $composableBuilder(
      column: $table.lastMessageTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGroup => $composableBuilder(
      column: $table.isGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isChannel => $composableBuilder(
      column: $table.isChannel, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPersonal => $composableBuilder(
      column: $table.isPersonal, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorites => $composableBuilder(
      column: $table.isFavorites, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get otherUserJson => $composableBuilder(
      column: $table.otherUserJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEncrypted => $composableBuilder(
      column: $table.isEncrypted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMessageType => $composableBuilder(
      column: $table.lastMessageType,
      builder: (column) => ColumnFilters(column));

  Expression<bool> messagesRefs(
      Expression<bool> Function($$MessagesTableFilterComposer f) f) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.messages,
        getReferencedColumn: (t) => t.chatId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessagesTableFilterComposer(
              $db: $db,
              $table: $db.messages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverChatId => $composableBuilder(
      column: $table.serverChatId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarGradient => $composableBuilder(
      column: $table.avatarGradient,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMessageTime => $composableBuilder(
      column: $table.lastMessageTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGroup => $composableBuilder(
      column: $table.isGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isChannel => $composableBuilder(
      column: $table.isChannel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPersonal => $composableBuilder(
      column: $table.isPersonal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorites => $composableBuilder(
      column: $table.isFavorites, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get otherUserJson => $composableBuilder(
      column: $table.otherUserJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEncrypted => $composableBuilder(
      column: $table.isEncrypted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMessageType => $composableBuilder(
      column: $table.lastMessageType,
      builder: (column) => ColumnOrderings(column));
}

class $$ChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverChatId => $composableBuilder(
      column: $table.serverChatId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get avatarGradient => $composableBuilder(
      column: $table.avatarGradient, builder: (column) => column);

  GeneratedColumn<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageTime => $composableBuilder(
      column: $table.lastMessageTime, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => column);

  GeneratedColumn<bool> get isGroup =>
      $composableBuilder(column: $table.isGroup, builder: (column) => column);

  GeneratedColumn<bool> get isChannel =>
      $composableBuilder(column: $table.isChannel, builder: (column) => column);

  GeneratedColumn<bool> get isPersonal => $composableBuilder(
      column: $table.isPersonal, builder: (column) => column);

  GeneratedColumn<bool> get isFavorites => $composableBuilder(
      column: $table.isFavorites, builder: (column) => column);

  GeneratedColumn<String> get otherUserJson => $composableBuilder(
      column: $table.otherUserJson, builder: (column) => column);

  GeneratedColumn<bool> get isEncrypted => $composableBuilder(
      column: $table.isEncrypted, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);

  GeneratedColumn<String> get lastMessageType => $composableBuilder(
      column: $table.lastMessageType, builder: (column) => column);

  Expression<T> messagesRefs<T extends Object>(
      Expression<T> Function($$MessagesTableAnnotationComposer a) f) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.messages,
        getReferencedColumn: (t) => t.chatId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessagesTableAnnotationComposer(
              $db: $db,
              $table: $db.messages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatsTable,
    Chat,
    $$ChatsTableFilterComposer,
    $$ChatsTableOrderingComposer,
    $$ChatsTableAnnotationComposer,
    $$ChatsTableCreateCompanionBuilder,
    $$ChatsTableUpdateCompanionBuilder,
    (Chat, $$ChatsTableReferences),
    Chat,
    PrefetchHooks Function({bool messagesRefs})> {
  $$ChatsTableTableManager(_$AppDatabase db, $ChatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverChatId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> avatar = const Value.absent(),
            Value<String?> avatarGradient = const Value.absent(),
            Value<String?> lastMessage = const Value.absent(),
            Value<DateTime?> lastMessageTime = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<bool> isGroup = const Value.absent(),
            Value<bool> isChannel = const Value.absent(),
            Value<bool> isPersonal = const Value.absent(),
            Value<bool> isFavorites = const Value.absent(),
            Value<String?> otherUserJson = const Value.absent(),
            Value<bool> isEncrypted = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<String?> lastMessageType = const Value.absent(),
          }) =>
              ChatsCompanion(
            id: id,
            serverChatId: serverChatId,
            name: name,
            avatar: avatar,
            avatarGradient: avatarGradient,
            lastMessage: lastMessage,
            lastMessageTime: lastMessageTime,
            unreadCount: unreadCount,
            isGroup: isGroup,
            isChannel: isChannel,
            isPersonal: isPersonal,
            isFavorites: isFavorites,
            otherUserJson: otherUserJson,
            isEncrypted: isEncrypted,
            isArchived: isArchived,
            archivedAt: archivedAt,
            lastMessageType: lastMessageType,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverChatId,
            required String name,
            Value<String?> avatar = const Value.absent(),
            Value<String?> avatarGradient = const Value.absent(),
            Value<String?> lastMessage = const Value.absent(),
            Value<DateTime?> lastMessageTime = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<bool> isGroup = const Value.absent(),
            Value<bool> isChannel = const Value.absent(),
            Value<bool> isPersonal = const Value.absent(),
            Value<bool> isFavorites = const Value.absent(),
            Value<String?> otherUserJson = const Value.absent(),
            Value<bool> isEncrypted = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<String?> lastMessageType = const Value.absent(),
          }) =>
              ChatsCompanion.insert(
            id: id,
            serverChatId: serverChatId,
            name: name,
            avatar: avatar,
            avatarGradient: avatarGradient,
            lastMessage: lastMessage,
            lastMessageTime: lastMessageTime,
            unreadCount: unreadCount,
            isGroup: isGroup,
            isChannel: isChannel,
            isPersonal: isPersonal,
            isFavorites: isFavorites,
            otherUserJson: otherUserJson,
            isEncrypted: isEncrypted,
            isArchived: isArchived,
            archivedAt: archivedAt,
            lastMessageType: lastMessageType,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ChatsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({messagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messagesRefs) db.messages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedData<Chat, $ChatsTable, Message>(
                        currentTable: table,
                        referencedTable:
                            $$ChatsTableReferences._messagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChatsTableReferences(db, table, p0).messagesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.chatId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ChatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatsTable,
    Chat,
    $$ChatsTableFilterComposer,
    $$ChatsTableOrderingComposer,
    $$ChatsTableAnnotationComposer,
    $$ChatsTableCreateCompanionBuilder,
    $$ChatsTableUpdateCompanionBuilder,
    (Chat, $$ChatsTableReferences),
    Chat,
    PrefetchHooks Function({bool messagesRefs})>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  required String serverMessageId,
  required int chatId,
  required String senderId,
  required String textContent,
  Value<String?> fileUrl,
  Value<bool> isRead,
  required DateTime timestamp,
  Value<String?> messageType,
  Value<String?> messageId,
  Value<String?> completionStatus,
  Value<String?> votesByOption,
  Value<String?> userVotes,
  Value<String?> replyToId,
  Value<String?> replyText,
  Value<String?> replyAuthorName,
  Value<String?> replyMarkup,
  Value<String?> messageData,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  Value<String> serverMessageId,
  Value<int> chatId,
  Value<String> senderId,
  Value<String> textContent,
  Value<String?> fileUrl,
  Value<bool> isRead,
  Value<DateTime> timestamp,
  Value<String?> messageType,
  Value<String?> messageId,
  Value<String?> completionStatus,
  Value<String?> votesByOption,
  Value<String?> userVotes,
  Value<String?> replyToId,
  Value<String?> replyText,
  Value<String?> replyAuthorName,
  Value<String?> replyMarkup,
  Value<String?> messageData,
});

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatsTable _chatIdTable(_$AppDatabase db) =>
      db.chats.createAlias('messages__chat_id__chats__id');

  $$ChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$ChatsTableTableManager($_db, $_db.chats)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverMessageId => $composableBuilder(
      column: $table.serverMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileUrl => $composableBuilder(
      column: $table.fileUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completionStatus => $composableBuilder(
      column: $table.completionStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get votesByOption => $composableBuilder(
      column: $table.votesByOption, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userVotes => $composableBuilder(
      column: $table.userVotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyToId => $composableBuilder(
      column: $table.replyToId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyText => $composableBuilder(
      column: $table.replyText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyAuthorName => $composableBuilder(
      column: $table.replyAuthorName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyMarkup => $composableBuilder(
      column: $table.replyMarkup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageData => $composableBuilder(
      column: $table.messageData, builder: (column) => ColumnFilters(column));

  $$ChatsTableFilterComposer get chatId {
    final $$ChatsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chatId,
        referencedTable: $db.chats,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChatsTableFilterComposer(
              $db: $db,
              $table: $db.chats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverMessageId => $composableBuilder(
      column: $table.serverMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileUrl => $composableBuilder(
      column: $table.fileUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completionStatus => $composableBuilder(
      column: $table.completionStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get votesByOption => $composableBuilder(
      column: $table.votesByOption,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userVotes => $composableBuilder(
      column: $table.userVotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyToId => $composableBuilder(
      column: $table.replyToId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyText => $composableBuilder(
      column: $table.replyText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyAuthorName => $composableBuilder(
      column: $table.replyAuthorName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyMarkup => $composableBuilder(
      column: $table.replyMarkup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageData => $composableBuilder(
      column: $table.messageData, builder: (column) => ColumnOrderings(column));

  $$ChatsTableOrderingComposer get chatId {
    final $$ChatsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chatId,
        referencedTable: $db.chats,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChatsTableOrderingComposer(
              $db: $db,
              $table: $db.chats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverMessageId => $composableBuilder(
      column: $table.serverMessageId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => column);

  GeneratedColumn<String> get fileUrl =>
      $composableBuilder(column: $table.fileUrl, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get completionStatus => $composableBuilder(
      column: $table.completionStatus, builder: (column) => column);

  GeneratedColumn<String> get votesByOption => $composableBuilder(
      column: $table.votesByOption, builder: (column) => column);

  GeneratedColumn<String> get userVotes =>
      $composableBuilder(column: $table.userVotes, builder: (column) => column);

  GeneratedColumn<String> get replyToId =>
      $composableBuilder(column: $table.replyToId, builder: (column) => column);

  GeneratedColumn<String> get replyText =>
      $composableBuilder(column: $table.replyText, builder: (column) => column);

  GeneratedColumn<String> get replyAuthorName => $composableBuilder(
      column: $table.replyAuthorName, builder: (column) => column);

  GeneratedColumn<String> get replyMarkup => $composableBuilder(
      column: $table.replyMarkup, builder: (column) => column);

  GeneratedColumn<String> get messageData => $composableBuilder(
      column: $table.messageData, builder: (column) => column);

  $$ChatsTableAnnotationComposer get chatId {
    final $$ChatsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chatId,
        referencedTable: $db.chats,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChatsTableAnnotationComposer(
              $db: $db,
              $table: $db.chats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, $$MessagesTableReferences),
    Message,
    PrefetchHooks Function({bool chatId})> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverMessageId = const Value.absent(),
            Value<int> chatId = const Value.absent(),
            Value<String> senderId = const Value.absent(),
            Value<String> textContent = const Value.absent(),
            Value<String?> fileUrl = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> messageType = const Value.absent(),
            Value<String?> messageId = const Value.absent(),
            Value<String?> completionStatus = const Value.absent(),
            Value<String?> votesByOption = const Value.absent(),
            Value<String?> userVotes = const Value.absent(),
            Value<String?> replyToId = const Value.absent(),
            Value<String?> replyText = const Value.absent(),
            Value<String?> replyAuthorName = const Value.absent(),
            Value<String?> replyMarkup = const Value.absent(),
            Value<String?> messageData = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            serverMessageId: serverMessageId,
            chatId: chatId,
            senderId: senderId,
            textContent: textContent,
            fileUrl: fileUrl,
            isRead: isRead,
            timestamp: timestamp,
            messageType: messageType,
            messageId: messageId,
            completionStatus: completionStatus,
            votesByOption: votesByOption,
            userVotes: userVotes,
            replyToId: replyToId,
            replyText: replyText,
            replyAuthorName: replyAuthorName,
            replyMarkup: replyMarkup,
            messageData: messageData,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverMessageId,
            required int chatId,
            required String senderId,
            required String textContent,
            Value<String?> fileUrl = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            required DateTime timestamp,
            Value<String?> messageType = const Value.absent(),
            Value<String?> messageId = const Value.absent(),
            Value<String?> completionStatus = const Value.absent(),
            Value<String?> votesByOption = const Value.absent(),
            Value<String?> userVotes = const Value.absent(),
            Value<String?> replyToId = const Value.absent(),
            Value<String?> replyText = const Value.absent(),
            Value<String?> replyAuthorName = const Value.absent(),
            Value<String?> replyMarkup = const Value.absent(),
            Value<String?> messageData = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            serverMessageId: serverMessageId,
            chatId: chatId,
            senderId: senderId,
            textContent: textContent,
            fileUrl: fileUrl,
            isRead: isRead,
            timestamp: timestamp,
            messageType: messageType,
            messageId: messageId,
            completionStatus: completionStatus,
            votesByOption: votesByOption,
            userVotes: userVotes,
            replyToId: replyToId,
            replyText: replyText,
            replyAuthorName: replyAuthorName,
            replyMarkup: replyMarkup,
            messageData: messageData,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MessagesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({chatId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (chatId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chatId,
                    referencedTable: $$MessagesTableReferences._chatIdTable(db),
                    referencedColumn:
                        $$MessagesTableReferences._chatIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, $$MessagesTableReferences),
    Message,
    PrefetchHooks Function({bool chatId})>;
typedef $$AudioTracksTableCreateCompanionBuilder = AudioTracksCompanion
    Function({
  required String sourceUrl,
  Value<String> title,
  Value<String> artist,
  Value<String> album,
  Value<String?> mimeType,
  Value<int?> durationMs,
  Value<String?> artworkUri,
  Value<Uint8List?> audioData,
  Value<String?> compression,
  Value<int> originalBytes,
  Value<int> storedBytes,
  required DateTime lastAccessedAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AudioTracksTableUpdateCompanionBuilder = AudioTracksCompanion
    Function({
  Value<String> sourceUrl,
  Value<String> title,
  Value<String> artist,
  Value<String> album,
  Value<String?> mimeType,
  Value<int?> durationMs,
  Value<String?> artworkUri,
  Value<Uint8List?> audioData,
  Value<String?> compression,
  Value<int> originalBytes,
  Value<int> storedBytes,
  Value<DateTime> lastAccessedAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AudioTracksTableFilterComposer
    extends Composer<_$AppDatabase, $AudioTracksTable> {
  $$AudioTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artist => $composableBuilder(
      column: $table.artist, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get album => $composableBuilder(
      column: $table.album, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artworkUri => $composableBuilder(
      column: $table.artworkUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get audioData => $composableBuilder(
      column: $table.audioData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get compression => $composableBuilder(
      column: $table.compression, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get originalBytes => $composableBuilder(
      column: $table.originalBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get storedBytes => $composableBuilder(
      column: $table.storedBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AudioTracksTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioTracksTable> {
  $$AudioTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artist => $composableBuilder(
      column: $table.artist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get album => $composableBuilder(
      column: $table.album, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artworkUri => $composableBuilder(
      column: $table.artworkUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get audioData => $composableBuilder(
      column: $table.audioData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get compression => $composableBuilder(
      column: $table.compression, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get originalBytes => $composableBuilder(
      column: $table.originalBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get storedBytes => $composableBuilder(
      column: $table.storedBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AudioTracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioTracksTable> {
  $$AudioTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get artworkUri => $composableBuilder(
      column: $table.artworkUri, builder: (column) => column);

  GeneratedColumn<Uint8List> get audioData =>
      $composableBuilder(column: $table.audioData, builder: (column) => column);

  GeneratedColumn<String> get compression => $composableBuilder(
      column: $table.compression, builder: (column) => column);

  GeneratedColumn<int> get originalBytes => $composableBuilder(
      column: $table.originalBytes, builder: (column) => column);

  GeneratedColumn<int> get storedBytes => $composableBuilder(
      column: $table.storedBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
      column: $table.lastAccessedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AudioTracksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AudioTracksTable,
    AudioTrack,
    $$AudioTracksTableFilterComposer,
    $$AudioTracksTableOrderingComposer,
    $$AudioTracksTableAnnotationComposer,
    $$AudioTracksTableCreateCompanionBuilder,
    $$AudioTracksTableUpdateCompanionBuilder,
    (AudioTrack, BaseReferences<_$AppDatabase, $AudioTracksTable, AudioTrack>),
    AudioTrack,
    PrefetchHooks Function()> {
  $$AudioTracksTableTableManager(_$AppDatabase db, $AudioTracksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> sourceUrl = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> artist = const Value.absent(),
            Value<String> album = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<String?> artworkUri = const Value.absent(),
            Value<Uint8List?> audioData = const Value.absent(),
            Value<String?> compression = const Value.absent(),
            Value<int> originalBytes = const Value.absent(),
            Value<int> storedBytes = const Value.absent(),
            Value<DateTime> lastAccessedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AudioTracksCompanion(
            sourceUrl: sourceUrl,
            title: title,
            artist: artist,
            album: album,
            mimeType: mimeType,
            durationMs: durationMs,
            artworkUri: artworkUri,
            audioData: audioData,
            compression: compression,
            originalBytes: originalBytes,
            storedBytes: storedBytes,
            lastAccessedAt: lastAccessedAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String sourceUrl,
            Value<String> title = const Value.absent(),
            Value<String> artist = const Value.absent(),
            Value<String> album = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<String?> artworkUri = const Value.absent(),
            Value<Uint8List?> audioData = const Value.absent(),
            Value<String?> compression = const Value.absent(),
            Value<int> originalBytes = const Value.absent(),
            Value<int> storedBytes = const Value.absent(),
            required DateTime lastAccessedAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AudioTracksCompanion.insert(
            sourceUrl: sourceUrl,
            title: title,
            artist: artist,
            album: album,
            mimeType: mimeType,
            durationMs: durationMs,
            artworkUri: artworkUri,
            audioData: audioData,
            compression: compression,
            originalBytes: originalBytes,
            storedBytes: storedBytes,
            lastAccessedAt: lastAccessedAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AudioTracksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AudioTracksTable,
    AudioTrack,
    $$AudioTracksTableFilterComposer,
    $$AudioTracksTableOrderingComposer,
    $$AudioTracksTableAnnotationComposer,
    $$AudioTracksTableCreateCompanionBuilder,
    $$AudioTracksTableUpdateCompanionBuilder,
    (AudioTrack, BaseReferences<_$AppDatabase, $AudioTracksTable, AudioTrack>),
    AudioTrack,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatsTableTableManager get chats =>
      $$ChatsTableTableManager(_db, _db.chats);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$AudioTracksTableTableManager get audioTracks =>
      $$AudioTracksTableTableManager(_db, _db.audioTracks);
}
