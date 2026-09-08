// This is a generated file - do not edit.
//
// Generated from xaneo/v1/chat_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class MarkAsReadRequest extends $pb.GeneratedMessage {
  factory MarkAsReadRequest({
    $core.String? chatId,
    $core.String? userId,
    $core.Iterable<$core.String>? messageIds,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (userId != null) result.userId = userId;
    if (messageIds != null) result.messageIds.addAll(messageIds);
    return result;
  }

  MarkAsReadRequest._();

  factory MarkAsReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAsReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAsReadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chatId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..pPS(3, _omitFieldNames ? '' : 'messageIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadRequest copyWith(void Function(MarkAsReadRequest) updates) =>
      super.copyWith((message) => updates(message as MarkAsReadRequest))
          as MarkAsReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAsReadRequest create() => MarkAsReadRequest._();
  @$core.override
  MarkAsReadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAsReadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAsReadRequest>(create);
  static MarkAsReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chatId => $_getSZ(0);
  @$pb.TagNumber(1)
  set chatId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get messageIds => $_getList<$core.String>(2);
}

class MarkAsReadResponse extends $pb.GeneratedMessage {
  factory MarkAsReadResponse({
    $core.bool? success,
    $core.int? markedCount,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (markedCount != null) result.markedCount = markedCount;
    return result;
  }

  MarkAsReadResponse._();

  factory MarkAsReadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAsReadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAsReadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'markedCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAsReadResponse copyWith(void Function(MarkAsReadResponse) updates) =>
      super.copyWith((message) => updates(message as MarkAsReadResponse))
          as MarkAsReadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAsReadResponse create() => MarkAsReadResponse._();
  @$core.override
  MarkAsReadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAsReadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAsReadResponse>(create);
  static MarkAsReadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get markedCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set markedCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarkedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarkedCount() => clearField(2);
}

class Empty extends $pb.GeneratedMessage {
  factory Empty() => create();

  Empty._();

  factory Empty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Empty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  @$core.override
  Empty createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

class HistoryRequest extends $pb.GeneratedMessage {
  factory HistoryRequest({
    $core.String? chatId,
    $core.int? limit,
    $core.String? beforeMessageId,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (limit != null) result.limit = limit;
    if (beforeMessageId != null) result.beforeMessageId = beforeMessageId;
    return result;
  }

  HistoryRequest._();

  factory HistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chatId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'beforeMessageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HistoryRequest copyWith(void Function(HistoryRequest) updates) =>
      super.copyWith((message) => updates(message as HistoryRequest))
          as HistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HistoryRequest create() => HistoryRequest._();
  @$core.override
  HistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HistoryRequest>(create);
  static HistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chatId => $_getSZ(0);
  @$pb.TagNumber(1)
  set chatId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get beforeMessageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set beforeMessageId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBeforeMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBeforeMessageId() => clearField(3);
}

class MessageItem extends $pb.GeneratedMessage {
  factory MessageItem({
    $core.String? id,
    $core.String? chatId,
    $core.String? senderId,
    $core.String? senderUsername,
    $core.String? senderAvatarUrl,
    $core.List<$core.int>? encryptedContent,
    $core.String? plainContent,
    $fixnum.Int64? timestamp,
    $core.bool? isEdited,
    $core.String? replyToId,
    $core.String? signature,
    $fixnum.Int64? epochId,
    $fixnum.Int64? msgCounter,
    $core.String? messageType,
    $core.String? encryptionVersion,
    $core.String? messageDataJson,
    $core.String? imagesJson,
    $core.String? attachedFileId,
    $core.String? attachedFileJson,
    $core.String? cryptoChatId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (chatId != null) result.chatId = chatId;
    if (senderId != null) result.senderId = senderId;
    if (senderUsername != null) result.senderUsername = senderUsername;
    if (senderAvatarUrl != null) result.senderAvatarUrl = senderAvatarUrl;
    if (encryptedContent != null) result.encryptedContent = encryptedContent;
    if (plainContent != null) result.plainContent = plainContent;
    if (timestamp != null) result.timestamp = timestamp;
    if (isEdited != null) result.isEdited = isEdited;
    if (replyToId != null) result.replyToId = replyToId;
    if (signature != null) result.signature = signature;
    if (epochId != null) result.epochId = epochId;
    if (msgCounter != null) result.msgCounter = msgCounter;
    if (messageType != null) result.messageType = messageType;
    if (encryptionVersion != null) result.encryptionVersion = encryptionVersion;
    if (messageDataJson != null) result.messageDataJson = messageDataJson;
    if (imagesJson != null) result.imagesJson = imagesJson;
    if (attachedFileId != null) result.attachedFileId = attachedFileId;
    if (attachedFileJson != null) result.attachedFileJson = attachedFileJson;
    if (cryptoChatId != null) result.cryptoChatId = cryptoChatId;
    return result;
  }

  MessageItem._();

  factory MessageItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'chatId')
    ..aOS(3, _omitFieldNames ? '' : 'senderId')
    ..aOS(4, _omitFieldNames ? '' : 'senderUsername')
    ..aOS(5, _omitFieldNames ? '' : 'senderAvatarUrl')
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'encryptedContent', $pb.PbFieldType.OY)
    ..aOS(7, _omitFieldNames ? '' : 'plainContent')
    ..aInt64(8, _omitFieldNames ? '' : 'timestamp')
    ..aOB(9, _omitFieldNames ? '' : 'isEdited')
    ..aOS(10, _omitFieldNames ? '' : 'replyToId')
    ..aOS(11, _omitFieldNames ? '' : 'signature')
    ..aInt64(12, _omitFieldNames ? '' : 'epochId')
    ..aInt64(13, _omitFieldNames ? '' : 'msgCounter')
    ..aOS(14, _omitFieldNames ? '' : 'messageType')
    ..aOS(15, _omitFieldNames ? '' : 'encryptionVersion')
    ..aOS(16, _omitFieldNames ? '' : 'messageDataJson')
    ..aOS(17, _omitFieldNames ? '' : 'imagesJson')
    ..aOS(18, _omitFieldNames ? '' : 'attachedFileId')
    ..aOS(19, _omitFieldNames ? '' : 'attachedFileJson')
    ..aOS(20, _omitFieldNames ? '' : 'cryptoChatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageItem copyWith(void Function(MessageItem) updates) =>
      super.copyWith((message) => updates(message as MessageItem))
          as MessageItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageItem create() => MessageItem._();
  @$core.override
  MessageItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageItem>(create);
  static MessageItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get chatId => $_getSZ(1);
  @$pb.TagNumber(2)
  set chatId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChatId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChatId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get senderId => $_getSZ(2);
  @$pb.TagNumber(3)
  set senderId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSenderId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSenderId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get senderUsername => $_getSZ(3);
  @$pb.TagNumber(4)
  set senderUsername($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSenderUsername() => $_has(3);
  @$pb.TagNumber(4)
  void clearSenderUsername() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get senderAvatarUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set senderAvatarUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSenderAvatarUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearSenderAvatarUrl() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get encryptedContent => $_getN(5);
  @$pb.TagNumber(6)
  set encryptedContent($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEncryptedContent() => $_has(5);
  @$pb.TagNumber(6)
  void clearEncryptedContent() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get plainContent => $_getSZ(6);
  @$pb.TagNumber(7)
  set plainContent($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPlainContent() => $_has(6);
  @$pb.TagNumber(7)
  void clearPlainContent() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get timestamp => $_getI64(7);
  @$pb.TagNumber(8)
  set timestamp($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTimestamp() => $_has(7);
  @$pb.TagNumber(8)
  void clearTimestamp() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isEdited => $_getBF(8);
  @$pb.TagNumber(9)
  set isEdited($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsEdited() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsEdited() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get replyToId => $_getSZ(9);
  @$pb.TagNumber(10)
  set replyToId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasReplyToId() => $_has(9);
  @$pb.TagNumber(10)
  void clearReplyToId() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get signature => $_getSZ(10);
  @$pb.TagNumber(11)
  set signature($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSignature() => $_has(10);
  @$pb.TagNumber(11)
  void clearSignature() => clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get epochId => $_getI64(11);
  @$pb.TagNumber(12)
  set epochId($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasEpochId() => $_has(11);
  @$pb.TagNumber(12)
  void clearEpochId() => clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get msgCounter => $_getI64(12);
  @$pb.TagNumber(13)
  set msgCounter($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasMsgCounter() => $_has(12);
  @$pb.TagNumber(13)
  void clearMsgCounter() => clearField(13);

  @$pb.TagNumber(14)
  $core.String get messageType => $_getSZ(13);
  @$pb.TagNumber(14)
  set messageType($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasMessageType() => $_has(13);
  @$pb.TagNumber(14)
  void clearMessageType() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get encryptionVersion => $_getSZ(14);
  @$pb.TagNumber(15)
  set encryptionVersion($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasEncryptionVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearEncryptionVersion() => clearField(15);

  @$pb.TagNumber(16)
  $core.String get messageDataJson => $_getSZ(15);
  @$pb.TagNumber(16)
  set messageDataJson($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasMessageDataJson() => $_has(15);
  @$pb.TagNumber(16)
  void clearMessageDataJson() => clearField(16);

  @$pb.TagNumber(17)
  $core.String get imagesJson => $_getSZ(16);
  @$pb.TagNumber(17)
  set imagesJson($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasImagesJson() => $_has(16);
  @$pb.TagNumber(17)
  void clearImagesJson() => clearField(17);

  @$pb.TagNumber(18)
  $core.String get attachedFileId => $_getSZ(17);
  @$pb.TagNumber(18)
  set attachedFileId($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasAttachedFileId() => $_has(17);
  @$pb.TagNumber(18)
  void clearAttachedFileId() => clearField(18);

  @$pb.TagNumber(19)
  $core.String get attachedFileJson => $_getSZ(18);
  @$pb.TagNumber(19)
  set attachedFileJson($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasAttachedFileJson() => $_has(18);
  @$pb.TagNumber(19)
  void clearAttachedFileJson() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get cryptoChatId => $_getSZ(19);
  @$pb.TagNumber(20)
  set cryptoChatId($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasCryptoChatId() => $_has(19);
  @$pb.TagNumber(20)
  void clearCryptoChatId() => clearField(20);
}

class ContactItem extends $pb.GeneratedMessage {
  factory ContactItem({
    $core.String? userId,
    $core.String? username,
    $core.String? displayName,
    $core.String? avatarUrl,
    $core.bool? isOnline,
    $fixnum.Int64? lastSeen,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (username != null) result.username = username;
    if (displayName != null) result.displayName = displayName;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (isOnline != null) result.isOnline = isOnline;
    if (lastSeen != null) result.lastSeen = lastSeen;
    return result;
  }

  ContactItem._();

  factory ContactItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ContactItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContactItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'displayName')
    ..aOS(4, _omitFieldNames ? '' : 'avatarUrl')
    ..aOB(5, _omitFieldNames ? '' : 'isOnline')
    ..aInt64(6, _omitFieldNames ? '' : 'lastSeen')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContactItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContactItem copyWith(void Function(ContactItem) updates) =>
      super.copyWith((message) => updates(message as ContactItem))
          as ContactItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactItem create() => ContactItem._();
  @$core.override
  ContactItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ContactItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ContactItem>(create);
  static ContactItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get avatarUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set avatarUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvatarUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvatarUrl() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isOnline => $_getBF(4);
  @$pb.TagNumber(5)
  set isOnline($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsOnline() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsOnline() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get lastSeen => $_getI64(5);
  @$pb.TagNumber(6)
  set lastSeen($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLastSeen() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastSeen() => clearField(6);
}

class ContactList extends $pb.GeneratedMessage {
  factory ContactList({
    $core.Iterable<ContactItem>? contacts,
  }) {
    final result = create();
    if (contacts != null) result.contacts.addAll(contacts);
    return result;
  }

  ContactList._();

  factory ContactList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ContactList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContactList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..pc<ContactItem>(1, _omitFieldNames ? '' : 'contacts', $pb.PbFieldType.PM,
        subBuilder: ContactItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContactList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContactList copyWith(void Function(ContactList) updates) =>
      super.copyWith((message) => updates(message as ContactList))
          as ContactList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactList create() => ContactList._();
  @$core.override
  ContactList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ContactList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ContactList>(create);
  static ContactList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ContactItem> get contacts => $_getList<ContactItem>(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
