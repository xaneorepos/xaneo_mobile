// This is a generated file - do not edit.
//
// Generated from xaneo/v1/chat_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'chat_service.pb.dart' as $0;

export 'chat_service.pb.dart';

/// Service for high-performance Web gRPC-Web chat operations
@$pb.GrpcServiceName('xaneo.v1.ChatWebService')
class ChatWebServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ChatWebServiceClient(super.channel, {super.options, super.interceptors});

  /// Stream message history for a chat
  $grpc.ResponseStream<$0.MessageItem> getMessageHistory(
    $0.HistoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$getMessageHistory, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Fetch user contacts list
  $grpc.ResponseFuture<$0.ContactList> getContacts(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getContacts, request, options: options);
  }

  /// Mark messages in a chat as read
  $grpc.ResponseFuture<$0.MarkAsReadResponse> markAsRead(
    $0.MarkAsReadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$markAsRead, request, options: options);
  }

  // method descriptors

  static final _$getMessageHistory =
      $grpc.ClientMethod<$0.HistoryRequest, $0.MessageItem>(
          '/xaneo.v1.ChatWebService/GetMessageHistory',
          ($0.HistoryRequest value) => value.writeToBuffer(),
          $0.MessageItem.fromBuffer);
  static final _$getContacts = $grpc.ClientMethod<$0.Empty, $0.ContactList>(
      '/xaneo.v1.ChatWebService/GetContacts',
      ($0.Empty value) => value.writeToBuffer(),
      $0.ContactList.fromBuffer);
  static final _$markAsRead =
      $grpc.ClientMethod<$0.MarkAsReadRequest, $0.MarkAsReadResponse>(
          '/xaneo.v1.ChatWebService/MarkAsRead',
          ($0.MarkAsReadRequest value) => value.writeToBuffer(),
          $0.MarkAsReadResponse.fromBuffer);
}

@$pb.GrpcServiceName('xaneo.v1.ChatWebService')
abstract class ChatWebServiceBase extends $grpc.Service {
  $core.String get $name => 'xaneo.v1.ChatWebService';

  ChatWebServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HistoryRequest, $0.MessageItem>(
        'GetMessageHistory',
        getMessageHistory_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.HistoryRequest.fromBuffer(value),
        ($0.MessageItem value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ContactList>(
        'GetContacts',
        getContacts_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ContactList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MarkAsReadRequest, $0.MarkAsReadResponse>(
        'MarkAsRead',
        markAsRead_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MarkAsReadRequest.fromBuffer(value),
        ($0.MarkAsReadResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.MessageItem> getMessageHistory_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HistoryRequest> $request) async* {
    yield* getMessageHistory($call, await $request);
  }

  $async.Stream<$0.MessageItem> getMessageHistory(
      $grpc.ServiceCall call, $0.HistoryRequest request);

  $async.Future<$0.ContactList> getContacts_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getContacts($call, await $request);
  }

  $async.Future<$0.ContactList> getContacts(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.MarkAsReadResponse> markAsRead_Pre($grpc.ServiceCall $call,
      $async.Future<$0.MarkAsReadRequest> $request) async {
    return markAsRead($call, await $request);
  }

  $async.Future<$0.MarkAsReadResponse> markAsRead(
      $grpc.ServiceCall call, $0.MarkAsReadRequest request);
}
