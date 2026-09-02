import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// E1 realtime: a minimal Pusher-protocol client for Laravel Reverb.
///
/// Reverb speaks the Pusher protocol, so we can talk to it over a raw
/// WebSocket (works on web + mobile + desktop, unlike native pusher plugins).
/// This subscribes to public channels and invokes [onEvent] with the `type`
/// payload of each `ops.event`. It auto-reconnects with backoff and reports
/// connection state via [onConnectionChange] so controllers can fall back to
/// polling when the socket is down.
class RealtimeClient {
  RealtimeClient({
    required this.config,
    required this.channels,
    required this.onEvent,
    this.onConnectionChange,
  });

  final RealtimeConfig config;
  final List<String> channels;
  final void Function(String type) onEvent;
  final void Function(bool connected)? onConnectionChange;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _reconnectTimer;
  int _attempt = 0;
  bool _disposed = false;
  bool _connected = false;

  bool get isEnabled => config.isEnabled;

  void connect() {
    if (_disposed || !config.isEnabled) return;
    _reconnectTimer?.cancel();
    try {
      final channel = WebSocketChannel.connect(Uri.parse(config.socketUrl));
      _channel = channel;
      _sub = channel.stream.listen(
        _onMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    Map<String, dynamic> frame;
    try {
      frame = jsonDecode('$raw') as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final event = '${frame['event'] ?? ''}';
    if (event == 'pusher:connection_established') {
      _attempt = 0;
      _setConnected(true);
      for (final name in channels) {
        _send({
          'event': 'pusher:subscribe',
          'data': {'channel': name},
        });
      }
      return;
    }
    if (event == 'pusher:ping') {
      _send({'event': 'pusher:pong', 'data': <String, dynamic>{}});
      return;
    }
    if (event == 'ops.event') {
      // Reverb sends the event payload as a JSON-encoded string in `data`.
      final data = frame['data'];
      final decoded = data is String ? _tryDecode(data) : (data as Map?);
      final type = '${decoded?['type'] ?? ''}';
      if (type.isNotEmpty) onEvent(type);
    }
  }

  Map<String, dynamic>? _tryDecode(String s) {
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void _send(Map<String, dynamic> message) {
    try {
      _channel?.sink.add(jsonEncode(message));
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _setConnected(false);
    _sub?.cancel();
    _sub = null;
    _channel = null;
    if (_disposed || !config.isEnabled) return;
    _attempt = (_attempt + 1).clamp(1, 6);
    final seconds = _attempt * _attempt; // 1,4,9,16,25,36s backoff
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: seconds), connect);
  }

  void _setConnected(bool value) {
    if (_connected == value) return;
    _connected = value;
    onConnectionChange?.call(value);
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _sub?.cancel();
    try {
      _channel?.sink.close();
    } catch (_) {}
  }
}

/// Reverb connection settings, compiled in via --dart-define. When [appKey] or
/// [host] is empty, realtime is disabled and clients rely on polling alone.
@immutable
class RealtimeConfig {
  const RealtimeConfig({
    required this.appKey,
    required this.host,
    required this.port,
    required this.scheme,
  });

  factory RealtimeConfig.fromEnvironment() => const RealtimeConfig(
        appKey: String.fromEnvironment('REVERB_APP_KEY'),
        host: String.fromEnvironment('REVERB_HOST'),
        port: int.fromEnvironment('REVERB_PORT', defaultValue: 8080),
        scheme: String.fromEnvironment('REVERB_SCHEME', defaultValue: 'http'),
      );

  final String appKey;
  final String host;
  final int port;
  final String scheme;

  bool get isEnabled => appKey.isNotEmpty && host.isNotEmpty;

  /// Pusher-protocol WebSocket URL for Reverb.
  String get socketUrl {
    final ws = scheme == 'https' ? 'wss' : 'ws';
    return '$ws://$host:$port/app/$appKey?protocol=7&client=flutter&version=1.0';
  }
}
