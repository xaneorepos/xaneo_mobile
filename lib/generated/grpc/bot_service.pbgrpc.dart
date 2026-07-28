// This is a generated file - do not edit.
//
// Generated from xaneo/v1/bot_service.proto.

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

import 'bot_service.pb.dart' as $0;

export 'bot_service.pb.dart';

/// Service for high-performance Bot Platform real-time communication
@$pb.GrpcServiceName('xaneo.v1.BotEventService')
class BotEventServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  BotEventServiceClient(super.channel, {super.options, super.interceptors});

  /// Bi-directional stream for bot events and real-time bot responses
  $grpc.ResponseStream<$0.BotEvent> streamEvents(
    $async.Stream<$0.BotAction> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$streamEvents, request, options: options);
  }

  /// Unary call for fast message sending by bots
  $grpc.ResponseFuture<$0.BotSendMessageResponse> sendMessage(
    $0.BotSendMessageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendMessage, request, options: options);
  }

  // method descriptors

  static final _$streamEvents = $grpc.ClientMethod<$0.BotAction, $0.BotEvent>(
      '/xaneo.v1.BotEventService/StreamEvents',
      ($0.BotAction value) => value.writeToBuffer(),
      $0.BotEvent.fromBuffer);
  static final _$sendMessage =
      $grpc.ClientMethod<$0.BotSendMessageRequest, $0.BotSendMessageResponse>(
          '/xaneo.v1.BotEventService/SendMessage',
          ($0.BotSendMessageRequest value) => value.writeToBuffer(),
          $0.BotSendMessageResponse.fromBuffer);
}

@$pb.GrpcServiceName('xaneo.v1.BotEventService')
abstract class BotEventServiceBase extends $grpc.Service {
  $core.String get $name => 'xaneo.v1.BotEventService';

  BotEventServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.BotAction, $0.BotEvent>(
        'StreamEvents',
        streamEvents,
        true,
        true,
        ($core.List<$core.int> value) => $0.BotAction.fromBuffer(value),
        ($0.BotEvent value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BotSendMessageRequest,
            $0.BotSendMessageResponse>(
        'SendMessage',
        sendMessage_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.BotSendMessageRequest.fromBuffer(value),
        ($0.BotSendMessageResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.BotEvent> streamEvents(
      $grpc.ServiceCall call, $async.Stream<$0.BotAction> request);

  $async.Future<$0.BotSendMessageResponse> sendMessage_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.BotSendMessageRequest> $request) async {
    return sendMessage($call, await $request);
  }

  $async.Future<$0.BotSendMessageResponse> sendMessage(
      $grpc.ServiceCall call, $0.BotSendMessageRequest request);
}
