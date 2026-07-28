// This is a generated file - do not edit.
//
// Generated from xaneo/v1/bot_service.proto.

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

@$core.Deprecated('Use botSendMessageRequestDescriptor instead')
const BotSendMessageRequest$json = {
  '1': 'BotSendMessageRequest',
  '2': [
    {'1': 'bot_token', '3': 1, '4': 1, '5': 9, '10': 'botToken'},
    {'1': 'chat_id', '3': 2, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'text', '3': 3, '4': 1, '5': 9, '10': 'text'},
    {'1': 'reply_to_id', '3': 4, '4': 1, '5': 9, '10': 'replyToId'},
    {'1': 'inline_buttons', '3': 5, '4': 3, '5': 9, '10': 'inlineButtons'},
  ],
};

/// Descriptor for `BotSendMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List botSendMessageRequestDescriptor = $convert.base64Decode(
    'ChVCb3RTZW5kTWVzc2FnZVJlcXVlc3QSGwoJYm90X3Rva2VuGAEgASgJUghib3RUb2tlbhIXCg'
    'djaGF0X2lkGAIgASgJUgZjaGF0SWQSEgoEdGV4dBgDIAEoCVIEdGV4dBIeCgtyZXBseV90b19p'
    'ZBgEIAEoCVIJcmVwbHlUb0lkEiUKDmlubGluZV9idXR0b25zGAUgAygJUg1pbmxpbmVCdXR0b2'
    '5z');

@$core.Deprecated('Use botSendMessageResponseDescriptor instead')
const BotSendMessageResponse$json = {
  '1': 'BotSendMessageResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'error_message', '3': 3, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `BotSendMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List botSendMessageResponseDescriptor = $convert.base64Decode(
    'ChZCb3RTZW5kTWVzc2FnZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSHQoKbW'
    'Vzc2FnZV9pZBgCIAEoCVIJbWVzc2FnZUlkEiMKDWVycm9yX21lc3NhZ2UYAyABKAlSDGVycm9y'
    'TWVzc2FnZRIcCgl0aW1lc3RhbXAYBCABKANSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use botEventDescriptor instead')
const BotEvent$json = {
  '1': 'BotEvent',
  '2': [
    {'1': 'event_id', '3': 1, '4': 1, '5': 9, '10': 'eventId'},
    {'1': 'event_type', '3': 2, '4': 1, '5': 9, '10': 'eventType'},
    {'1': 'bot_id', '3': 3, '4': 1, '5': 9, '10': 'botId'},
    {'1': 'chat_id', '3': 4, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'sender_id', '3': 5, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'sender_username', '3': 6, '4': 1, '5': 9, '10': 'senderUsername'},
    {'1': 'text', '3': 7, '4': 1, '5': 9, '10': 'text'},
    {'1': 'callback_data', '3': 8, '4': 1, '5': 9, '10': 'callbackData'},
    {'1': 'timestamp', '3': 9, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `BotEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List botEventDescriptor = $convert.base64Decode(
    'CghCb3RFdmVudBIZCghldmVudF9pZBgBIAEoCVIHZXZlbnRJZBIdCgpldmVudF90eXBlGAIgAS'
    'gJUglldmVudFR5cGUSFQoGYm90X2lkGAMgASgJUgVib3RJZBIXCgdjaGF0X2lkGAQgASgJUgZj'
    'aGF0SWQSGwoJc2VuZGVyX2lkGAUgASgJUghzZW5kZXJJZBInCg9zZW5kZXJfdXNlcm5hbWUYBi'
    'ABKAlSDnNlbmRlclVzZXJuYW1lEhIKBHRleHQYByABKAlSBHRleHQSIwoNY2FsbGJhY2tfZGF0'
    'YRgIIAEoCVIMY2FsbGJhY2tEYXRhEhwKCXRpbWVzdGFtcBgJIAEoA1IJdGltZXN0YW1w');

@$core.Deprecated('Use botActionDescriptor instead')
const BotAction$json = {
  '1': 'BotAction',
  '2': [
    {'1': 'bot_token', '3': 1, '4': 1, '5': 9, '10': 'botToken'},
    {'1': 'event_id', '3': 2, '4': 1, '5': 9, '10': 'eventId'},
    {'1': 'action_type', '3': 3, '4': 1, '5': 9, '10': 'actionType'},
    {'1': 'reply_text', '3': 4, '4': 1, '5': 9, '10': 'replyText'},
    {'1': 'inline_buttons', '3': 5, '4': 3, '5': 9, '10': 'inlineButtons'},
  ],
};

/// Descriptor for `BotAction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List botActionDescriptor = $convert.base64Decode(
    'CglCb3RBY3Rpb24SGwoJYm90X3Rva2VuGAEgASgJUghib3RUb2tlbhIZCghldmVudF9pZBgCIA'
    'EoCVIHZXZlbnRJZBIfCgthY3Rpb25fdHlwZRgDIAEoCVIKYWN0aW9uVHlwZRIdCgpyZXBseV90'
    'ZXh0GAQgASgJUglyZXBseVRleHQSJQoOaW5saW5lX2J1dHRvbnMYBSADKAlSDWlubGluZUJ1dH'
    'RvbnM=');
