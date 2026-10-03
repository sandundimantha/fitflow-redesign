import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _feedStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get feedStream => _feedStreamController.stream;

  void connect() {
    try {
      final wsUrl = ApiService.baseUrl.replaceFirst('http', 'ws').replaceFirst('/api', '/ws/feed');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel?.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data.toString());
            _feedStreamController.add(decoded);
          } catch (e) {
            debugPrint('WebSocket parse error: $e');
          }
        },
        onError: (err) {
          debugPrint('WebSocket error: $err');
        },
        onDone: () {
          debugPrint('WebSocket disconnected');
        },
      );
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
