import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  WebSocketChannel? _channel;
  final String _serverUrl = dotenv.env['WEBSOCKET_URL'] ?? 'ws://localhost:8080';
  final StreamController<Map<String, dynamic>> _streamController = StreamController<Map<String, dynamic>>.broadcast();

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal();

  bool get isConnected => _channel != null;

  void connect() {
    if (_channel != null) {
      print("Already connected");
      return;
    }
    
    _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));

    _channel!.stream.listen(
      (message) {
        String messageData;

        if (message is Uint8List) {
          messageData = utf8.decode(message);
        } else {
          messageData = message;
        }

        Map<String, dynamic> data = jsonDecode(messageData);

        print("Message reçu: $data");
        _streamController.add(data);
      },
      onError: (error) {
        print("Erreur WebSocket: $error");
        _reconnect();
      },
      onDone: () {
        print("Connexion WebSocket fermée");
        _reconnect();
      },
    );
  }

  Stream<Map<String, dynamic>> get messageStream => _streamController.stream;

  void sendMessage(Map<String, dynamic> message) {
    if (_channel == null) {
      print("WebSocket not connected");
      return;
    }

    String jsonString = jsonEncode(message);
    _channel!.sink.add(jsonString);
  }

  void _reconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }

    Future.delayed(const Duration(seconds: 5), () {
      print("Reconnexion au serveur WebSocket...");
      connect();
    });
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway); // Use status.goingAway (1001) for valid close code
      _channel = null;
    }
    _streamController.close();
  }
}
