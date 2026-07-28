// This is a generated file - do not edit.
//
// Generated from xaneo/v1/presence_service.proto.

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

@$core.Deprecated('Use presencePingDescriptor instead')
const PresencePing$json = {
  '1': 'PresencePing',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'chat_id', '3': 2, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `PresencePing`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presencePingDescriptor = $convert.base64Decode(
    'CgxQcmVzZW5jZVBpbmcSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhcKB2NoYXRfaWQYAiABKA'
    'lSBmNoYXRJZBIWCgZzdGF0dXMYAyABKAlSBnN0YXR1cxIcCgl0aW1lc3RhbXAYBCABKANSCXRp'
    'bWVzdGFtcA==');

@$core.Deprecated('Use presenceAckDescriptor instead')
const PresenceAck$json = {
  '1': 'PresenceAck',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'server_timestamp', '3': 2, '4': 1, '5': 3, '10': 'serverTimestamp'},
  ],
};

/// Descriptor for `PresenceAck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceAckDescriptor = $convert.base64Decode(
    'CgtQcmVzZW5jZUFjaxIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEikKEHNlcnZlcl90aW1lc3'
    'RhbXAYAiABKANSD3NlcnZlclRpbWVzdGFtcA==');

@$core.Deprecated('Use presenceSubscriptionDescriptor instead')
const PresenceSubscription$json = {
  '1': 'PresenceSubscription',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'contact_ids', '3': 2, '4': 3, '5': 9, '10': 'contactIds'},
  ],
};

/// Descriptor for `PresenceSubscription`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceSubscriptionDescriptor = $convert.base64Decode(
    'ChRQcmVzZW5jZVN1YnNjcmlwdGlvbhIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSHwoLY29udG'
    'FjdF9pZHMYAiADKAlSCmNvbnRhY3RJZHM=');

@$core.Deprecated('Use presenceUpdateDescriptor instead')
const PresenceUpdate$json = {
  '1': 'PresenceUpdate',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'chat_id', '3': 2, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'status', '3': 3, '4': 1, '5': 9, '10': 'status'},
    {'1': 'last_seen', '3': 4, '4': 1, '5': 3, '10': 'lastSeen'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `PresenceUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceUpdateDescriptor = $convert.base64Decode(
    'Cg5QcmVzZW5jZVVwZGF0ZRIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSFwoHY2hhdF9pZBgCIA'
    'EoCVIGY2hhdElkEhYKBnN0YXR1cxgDIAEoCVIGc3RhdHVzEhsKCWxhc3Rfc2VlbhgEIAEoA1II'
    'bGFzdFNlZW4SHAoJdGltZXN0YW1wGAUgASgDUgl0aW1lc3RhbXA=');
