import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  late WebSocketChannel _channel;
  final String _serverUrl = 'ws://stupid-hotels-visit.loca.lt'; // Remplace par ton URL WebSocket
  final StreamController<Map<String, dynamic>> _streamController = StreamController<Map<String, dynamic>>.broadcast();  // Utilisation de broadcast

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal();

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));

    _channel.stream.listen(
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
    String jsonString = jsonEncode(message);
    _channel.sink.add(jsonString);
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      print("Reconnexion au serveur WebSocket...");
      connect();
    });
  }

  void disconnect() {
    _channel.sink.close(status.goingAway);
    _streamController.close();
  }
}
