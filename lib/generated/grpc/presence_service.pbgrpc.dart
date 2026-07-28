// This is a generated file - do not edit.
//
// Generated from xaneo/v1/presence_service.proto.

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

import 'presence_service.pb.dart' as $0;

export 'presence_service.pb.dart';

/// Service for real-time User Presence & Typing status indicators
@$pb.GrpcServiceName('xaneo.v1.PresenceService')
class PresenceServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  PresenceServiceClient(super.channel, {super.options, super.interceptors});

  /// Send status update (e.g., online, typing, idle, away)
  $grpc.ResponseFuture<$0.PresenceAck> sendPresence(
    $0.PresencePing request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendPresence, request, options: options);
  }

  /// Subscribe to real-time status updates of contacts (Server Streaming)
  $grpc.ResponseStream<$0.PresenceUpdate> streamPresenceUpdates(
    $0.PresenceSubscription request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamPresenceUpdates, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$sendPresence =
      $grpc.ClientMethod<$0.PresencePing, $0.PresenceAck>(
          '/xaneo.v1.PresenceService/SendPresence',
          ($0.PresencePing value) => value.writeToBuffer(),
          $0.PresenceAck.fromBuffer);
  static final _$streamPresenceUpdates =
      $grpc.ClientMethod<$0.PresenceSubscription, $0.PresenceUpdate>(
          '/xaneo.v1.PresenceService/StreamPresenceUpdates',
          ($0.PresenceSubscription value) => value.writeToBuffer(),
          $0.PresenceUpdate.fromBuffer);
}

@$pb.GrpcServiceName('xaneo.v1.PresenceService')
abstract class PresenceServiceBase extends $grpc.Service {
  $core.String get $name => 'xaneo.v1.PresenceService';

  PresenceServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PresencePing, $0.PresenceAck>(
        'SendPresence',
        sendPresence_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PresencePing.fromBuffer(value),
        ($0.PresenceAck value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PresenceSubscription, $0.PresenceUpdate>(
        'StreamPresenceUpdates',
        streamPresenceUpdates_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.PresenceSubscription.fromBuffer(value),
        ($0.PresenceUpdate value) => value.writeToBuffer()));
  }

  $async.Future<$0.PresenceAck> sendPresence_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.PresencePing> $request) async {
    return sendPresence($call, await $request);
  }

  $async.Future<$0.PresenceAck> sendPresence(
      $grpc.ServiceCall call, $0.PresencePing request);

  $async.Stream<$0.PresenceUpdate> streamPresenceUpdates_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PresenceSubscription> $request) async* {
    yield* streamPresenceUpdates($call, await $request);
  }

  $async.Stream<$0.PresenceUpdate> streamPresenceUpdates(
      $grpc.ServiceCall call, $0.PresenceSubscription request);
}
