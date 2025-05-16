import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebSocketChannel channel;
  String latestData = "Menunggu data...";

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse(
        'ws://192.168.0.111:3000',
      ), // ws:// bukan wss:// kalau belum SSL
    );

    channel.stream.listen(
      (data) {
        setState(() {
          latestData = data;
        });
      },
      onError: (error) {
        print("WebSocket error: $error");
      },
      onDone: () {
        print("WebSocket connection closed");
      },
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Data realtime dari server:\n$latestData",
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
