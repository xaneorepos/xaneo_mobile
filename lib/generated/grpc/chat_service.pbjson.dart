// This is a generated file - do not edit.
//
// Generated from xaneo/v1/chat_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use markAsReadRequestDescriptor instead')
const MarkAsReadRequest$json = {
  '1': 'MarkAsReadRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'message_ids', '3': 3, '4': 3, '5': 9, '10': 'messageIds'},
  ],
};

/// Descriptor for `MarkAsReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAsReadRequestDescriptor = $convert.base64Decode(
    'ChFNYXJrQXNSZWFkUmVxdWVzdBIXCgdjaGF0X2lkGAEgASgJUgZjaGF0SWQSFwoHdXNlcl9pZB'
    'gCIAEoCVIGdXNlcklkEh8KC21lc3NhZ2VfaWRzGAMgAygJUgptZXNzYWdlSWRz');

@$core.Deprecated('Use markAsReadResponseDescriptor instead')
const MarkAsReadResponse$json = {
  '1': 'MarkAsReadResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'marked_count', '3': 2, '4': 1, '5': 5, '10': 'markedCount'},
  ],
};

/// Descriptor for `MarkAsReadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAsReadResponseDescriptor = $convert.base64Decode(
    'ChJNYXJrQXNSZWFkUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIhCgxtYXJrZW'
    'RfY291bnQYAiABKAVSC21hcmtlZENvdW50');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');

@$core.Deprecated('Use historyRequestDescriptor instead')
const HistoryRequest$json = {
  '1': 'HistoryRequest',
  '2': [
    {'1': 'chat_id', '3': 1, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'before_message_id', '3': 3, '4': 1, '5': 9, '10': 'beforeMessageId'},
  ],
};

/// Descriptor for `HistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List historyRequestDescriptor = $convert.base64Decode(
    'Cg5IaXN0b3J5UmVxdWVzdBIXCgdjaGF0X2lkGAEgASgJUgZjaGF0SWQSFAoFbGltaXQYAiABKA'
    'VSBWxpbWl0EioKEWJlZm9yZV9tZXNzYWdlX2lkGAMgASgJUg9iZWZvcmVNZXNzYWdlSWQ=');

@$core.Deprecated('Use messageItemDescriptor instead')
const MessageItem$json = {
  '1': 'MessageItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'chat_id', '3': 2, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'sender_id', '3': 3, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'sender_username', '3': 4, '4': 1, '5': 9, '10': 'senderUsername'},
    {'1': 'sender_avatar_url', '3': 5, '4': 1, '5': 9, '10': 'senderAvatarUrl'},
    {
      '1': 'encrypted_content',
      '3': 6,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {'1': 'plain_content', '3': 7, '4': 1, '5': 9, '10': 'plainContent'},
    {'1': 'timestamp', '3': 8, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'is_edited', '3': 9, '4': 1, '5': 8, '10': 'isEdited'},
    {'1': 'reply_to_id', '3': 10, '4': 1, '5': 9, '10': 'replyToId'},
  ],
};

/// Descriptor for `MessageItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageItemDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlSXRlbRIOCgJpZBgBIAEoCVICaWQSFwoHY2hhdF9pZBgCIAEoCVIGY2hhdElkEh'
    'sKCXNlbmRlcl9pZBgDIAEoCVIIc2VuZGVySWQSJwoPc2VuZGVyX3VzZXJuYW1lGAQgASgJUg5z'
    'ZW5kZXJVc2VybmFtZRIqChFzZW5kZXJfYXZhdGFyX3VybBgFIAEoCVIPc2VuZGVyQXZhdGFyVX'
    'JsEisKEWVuY3J5cHRlZF9jb250ZW50GAYgASgMUhBlbmNyeXB0ZWRDb250ZW50EiMKDXBsYWlu'
    'X2NvbnRlbnQYByABKAlSDHBsYWluQ29udGVudBIcCgl0aW1lc3RhbXAYCCABKANSCXRpbWVzdG'
    'FtcBIbCglpc19lZGl0ZWQYCSABKAhSCGlzRWRpdGVkEh4KC3JlcGx5X3RvX2lkGAogASgJUgly'
    'ZXBseVRvSWQ=');

@$core.Deprecated('Use contactItemDescriptor instead')
const ContactItem$json = {
  '1': 'ContactItem',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'is_online', '3': 5, '4': 1, '5': 8, '10': 'isOnline'},
    {'1': 'last_seen', '3': 6, '4': 1, '5': 3, '10': 'lastSeen'},
  ],
};

/// Descriptor for `ContactItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactItemDescriptor = $convert.base64Decode(
    'CgtDb250YWN0SXRlbRIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGgoIdXNlcm5hbWUYAiABKA'
    'lSCHVzZXJuYW1lEiEKDGRpc3BsYXlfbmFtZRgDIAEoCVILZGlzcGxheU5hbWUSHQoKYXZhdGFy'
    'X3VybBgEIAEoCVIJYXZhdGFyVXJsEhsKCWlzX29ubGluZRgFIAEoCFIIaXNPbmxpbmUSGwoJbG'
    'FzdF9zZWVuGAYgASgDUghsYXN0U2Vlbg==');

@$core.Deprecated('Use contactListDescriptor instead')
const ContactList$json = {
  '1': 'ContactList',
  '2': [
    {
      '1': 'contacts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.xaneo.v1.ContactItem',
      '10': 'contacts'
    },
  ],
};

/// Descriptor for `ContactList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactListDescriptor = $convert.base64Decode(
    'CgtDb250YWN0TGlzdBIxCghjb250YWN0cxgBIAMoCzIVLnhhbmVvLnYxLkNvbnRhY3RJdGVtUg'
    'hjb250YWN0cw==');
