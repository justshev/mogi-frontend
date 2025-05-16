import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal() {
    _channel = WebSocketChannel.connect(Uri.parse('ws://192.168.1.5:3000'));
    _stream = _channel!.stream.asBroadcastStream();
  }

  WebSocketChannel? _channel;
  late Stream _stream;

  Stream get stream => _stream;

  void send(String message) {
    _channel?.sink.add(message);
  }

  void dispose() {
    _channel?.sink.close();
  }
}
