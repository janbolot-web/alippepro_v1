// ignore_for_file: library_prefixes

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;
// https://websocket-1ukc.onrender.com'
  SocketClient._internal() {
    socket = IO.io('http://ec2-54-211-138-169.compute-1.amazonaws.com:5001', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
  }

  static SocketClient get instance{
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}
// 44.226.145.213
// 54.187.200.255
// 34.213.214.55
// 35.164.95.156
// 44.230.95.183
// 44.229.200.200