// This is a generated file - do not edit.
//
// Generated from xaneo/v1/presence_service.proto.

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

class PresencePing extends $pb.GeneratedMessage {
  factory PresencePing({
    $core.String? userId,
    $core.String? chatId,
    $core.String? status,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (chatId != null) result.chatId = chatId;
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  PresencePing._();

  factory PresencePing.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PresencePing.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PresencePing',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'chatId')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresencePing clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresencePing copyWith(void Function(PresencePing) updates) =>
      super.copyWith((message) => updates(message as PresencePing))
          as PresencePing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresencePing create() => PresencePing._();
  @$core.override
  PresencePing createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PresencePing getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PresencePing>(create);
  static PresencePing? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get chatId => $_getSZ(1);
  @$pb.TagNumber(2)
  set chatId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChatId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChatId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => clearField(4);
}

class PresenceAck extends $pb.GeneratedMessage {
  factory PresenceAck({
    $core.bool? success,
    $fixnum.Int64? serverTimestamp,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (serverTimestamp != null) result.serverTimestamp = serverTimestamp;
    return result;
  }

  PresenceAck._();

  factory PresenceAck.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PresenceAck.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PresenceAck',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aInt64(2, _omitFieldNames ? '' : 'serverTimestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceAck clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceAck copyWith(void Function(PresenceAck) updates) =>
      super.copyWith((message) => updates(message as PresenceAck))
          as PresenceAck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceAck create() => PresenceAck._();
  @$core.override
  PresenceAck createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PresenceAck getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PresenceAck>(create);
  static PresenceAck? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get serverTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set serverTimestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasServerTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearServerTimestamp() => clearField(2);
}

class PresenceSubscription extends $pb.GeneratedMessage {
  factory PresenceSubscription({
    $core.String? userId,
    $core.Iterable<$core.String>? contactIds,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (contactIds != null) result.contactIds.addAll(contactIds);
    return result;
  }

  PresenceSubscription._();

  factory PresenceSubscription.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PresenceSubscription.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PresenceSubscription',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..pPS(2, _omitFieldNames ? '' : 'contactIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceSubscription clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceSubscription copyWith(void Function(PresenceSubscription) updates) =>
      super.copyWith((message) => updates(message as PresenceSubscription))
          as PresenceSubscription;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceSubscription create() => PresenceSubscription._();
  @$core.override
  PresenceSubscription createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PresenceSubscription getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PresenceSubscription>(create);
  static PresenceSubscription? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get contactIds => $_getList<$core.String>(1);
}

class PresenceUpdate extends $pb.GeneratedMessage {
  factory PresenceUpdate({
    $core.String? userId,
    $core.String? chatId,
    $core.String? status,
    $fixnum.Int64? lastSeen,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (chatId != null) result.chatId = chatId;
    if (status != null) result.status = status;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  PresenceUpdate._();

  factory PresenceUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PresenceUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PresenceUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xaneo.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'chatId')
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..aInt64(4, _omitFieldNames ? '' : 'lastSeen')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PresenceUpdate copyWith(void Function(PresenceUpdate) updates) =>
      super.copyWith((message) => updates(message as PresenceUpdate))
          as PresenceUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PresenceUpdate create() => PresenceUpdate._();
  @$core.override
  PresenceUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PresenceUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PresenceUpdate>(create);
  static PresenceUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get chatId => $_getSZ(1);
  @$pb.TagNumber(2)
  set chatId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChatId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChatId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get lastSeen => $_getI64(3);
  @$pb.TagNumber(4)
  set lastSeen($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLastSeen() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastSeen() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
