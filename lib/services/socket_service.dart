

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketService with ChangeNotifier {

  final ServerStatus _serverStatus = ServerStatus.connecting;

  SocketService(){
    _initConfig();
  }

  void _initConfig(){

    Socket socket = io('http://10.0.2.2:4000', 
      OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .enableAutoConnect()  // disable auto-connection
        .build()
    );

    socket.onConnect((_) => debugPrint('Connect'));  
    socket.onDisconnect((_) => debugPrint('Disconnect'));  
  }

}