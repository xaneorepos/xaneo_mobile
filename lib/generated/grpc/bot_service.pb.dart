// This is a generated file - do not edit.
//
// Generated from xaneo/v1/bot_service.proto.

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

class BotSendMessageRequest extends $pb.GeneratedMessage {
  factory BotSendMessageRequest({
    $core.String? botToken,
    $core.String? chatId,
    $core.String? text,
    $core.String? replyToId,
    $core.Iterable<$core.String>? inlineButtons,
  }) {
    final result = create();
    if (botToken != null) result.botToken = botToken;
    if (chatId != null) result.chatId = chatId;
    if (text != null) result.text = text;
    if (replyToId != null) result.replyToId = replyToId;
    if (inlineButtons != null) result.inlineButtons.addAll(inlineButtons);
    return result;
  }

  BotSendMessageRequest._();

  factory BotSendMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BotSendMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BotSendMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'botToken')
    ..aOS(2, _omitFieldNames ? '' : 'chatId')
    ..aOS(3, _omitFieldNames ? '' : 'text')
    ..aOS(4, _omitFieldNames ? '' : 'replyToId')
    ..pPS(5, _omitFieldNames ? '' : 'inlineButtons')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotSendMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotSendMessageRequest copyWith(
          void Function(BotSendMessageRequest) updates) =>
      super.copyWith((message) => updates(message as BotSendMessageRequest))
          as BotSendMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BotSendMessageRequest create() => BotSendMessageRequest._();
  @$core.override
  BotSendMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BotSendMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BotSendMessageRequest>(create);
  static BotSendMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get botToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set botToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBotToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearBotToken() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get chatId => $_getSZ(1);
  @$pb.TagNumber(2)
  set chatId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChatId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChatId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get text => $_getSZ(2);
  @$pb.TagNumber(3)
  set text($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasText() => $_has(2);
  @$pb.TagNumber(3)
  void clearText() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get replyToId => $_getSZ(3);
  @$pb.TagNumber(4)
  set replyToId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReplyToId() => $_has(3);
  @$pb.TagNumber(4)
  void clearReplyToId() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.String> get inlineButtons => $_getList<$core.String>(4);
}

class BotSendMessageResponse extends $pb.GeneratedMessage {
  factory BotSendMessageResponse({
    $core.bool? success,
    $core.String? messageId,
    $core.String? errorMessage,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (messageId != null) result.messageId = messageId;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  BotSendMessageResponse._();

  factory BotSendMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BotSendMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BotSendMessageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOS(3, _omitFieldNames ? '' : 'errorMessage')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotSendMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotSendMessageResponse copyWith(
          void Function(BotSendMessageResponse) updates) =>
      super.copyWith((message) => updates(message as BotSendMessageResponse))
          as BotSendMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BotSendMessageResponse create() => BotSendMessageResponse._();
  @$core.override
  BotSendMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BotSendMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BotSendMessageResponse>(create);
  static BotSendMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get errorMessage => $_getSZ(2);
  @$pb.TagNumber(3)
  set errorMessage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasErrorMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorMessage() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => clearField(4);
}

class BotEvent extends $pb.GeneratedMessage {
  factory BotEvent({
    $core.String? eventId,
    $core.String? eventType,
    $core.String? botId,
    $core.String? chatId,
    $core.String? senderId,
    $core.String? senderUsername,
    $core.String? text,
    $core.String? callbackData,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (eventId != null) result.eventId = eventId;
    if (eventType != null) result.eventType = eventType;
    if (botId != null) result.botId = botId;
    if (chatId != null) result.chatId = chatId;
    if (senderId != null) result.senderId = senderId;
    if (senderUsername != null) result.senderUsername = senderUsername;
    if (text != null) result.text = text;
    if (callbackData != null) result.callbackData = callbackData;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  BotEvent._();

  factory BotEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BotEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BotEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'eventId')
    ..aOS(2, _omitFieldNames ? '' : 'eventType')
    ..aOS(3, _omitFieldNames ? '' : 'botId')
    ..aOS(4, _omitFieldNames ? '' : 'chatId')
    ..aOS(5, _omitFieldNames ? '' : 'senderId')
    ..aOS(6, _omitFieldNames ? '' : 'senderUsername')
    ..aOS(7, _omitFieldNames ? '' : 'text')
    ..aOS(8, _omitFieldNames ? '' : 'callbackData')
    ..aInt64(9, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotEvent copyWith(void Function(BotEvent) updates) =>
      super.copyWith((message) => updates(message as BotEvent)) as BotEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BotEvent create() => BotEvent._();
  @$core.override
  BotEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BotEvent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BotEvent>(create);
  static BotEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get eventType => $_getSZ(1);
  @$pb.TagNumber(2)
  set eventType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEventType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEventType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get botId => $_getSZ(2);
  @$pb.TagNumber(3)
  set botId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBotId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBotId() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get chatId => $_getSZ(3);
  @$pb.TagNumber(4)
  set chatId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChatId() => $_has(3);
  @$pb.TagNumber(4)
  void clearChatId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get senderId => $_getSZ(4);
  @$pb.TagNumber(5)
  set senderId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSenderId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSenderId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get senderUsername => $_getSZ(5);
  @$pb.TagNumber(6)
  set senderUsername($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSenderUsername() => $_has(5);
  @$pb.TagNumber(6)
  void clearSenderUsername() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get text => $_getSZ(6);
  @$pb.TagNumber(7)
  set text($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasText() => $_has(6);
  @$pb.TagNumber(7)
  void clearText() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get callbackData => $_getSZ(7);
  @$pb.TagNumber(8)
  set callbackData($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCallbackData() => $_has(7);
  @$pb.TagNumber(8)
  void clearCallbackData() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get timestamp => $_getI64(8);
  @$pb.TagNumber(9)
  set timestamp($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTimestamp() => $_has(8);
  @$pb.TagNumber(9)
  void clearTimestamp() => clearField(9);
}

class BotAction extends $pb.GeneratedMessage {
  factory BotAction({
    $core.String? botToken,
    $core.String? eventId,
    $core.String? actionType,
    $core.String? replyText,
    $core.Iterable<$core.String>? inlineButtons,
  }) {
    final result = create();
    if (botToken != null) result.botToken = botToken;
    if (eventId != null) result.eventId = eventId;
    if (actionType != null) result.actionType = actionType;
    if (replyText != null) result.replyText = replyText;
    if (inlineButtons != null) result.inlineButtons.addAll(inlineButtons);
    return result;
  }

  BotAction._();

  factory BotAction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BotAction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BotAction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'botToken')
    ..aOS(2, _omitFieldNames ? '' : 'eventId')
    ..aOS(3, _omitFieldNames ? '' : 'actionType')
    ..aOS(4, _omitFieldNames ? '' : 'replyText')
    ..pPS(5, _omitFieldNames ? '' : 'inlineButtons')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotAction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BotAction copyWith(void Function(BotAction) updates) =>
      super.copyWith((message) => updates(message as BotAction)) as BotAction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BotAction create() => BotAction._();
  @$core.override
  BotAction createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BotAction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BotAction>(create);
  static BotAction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get botToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set botToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBotToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearBotToken() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get eventId => $_getSZ(1);
  @$pb.TagNumber(2)
  set eventId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEventId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEventId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get actionType => $_getSZ(2);
  @$pb.TagNumber(3)
  set actionType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActionType() => $_has(2);
  @$pb.TagNumber(3)
  void clearActionType() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get replyText => $_getSZ(3);
  @$pb.TagNumber(4)
  set replyText($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReplyText() => $_has(3);
  @$pb.TagNumber(4)
  void clearReplyText() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.String> get inlineButtons => $_getList<$core.String>(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
