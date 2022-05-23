

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketService with ChangeNotifier {

  late ServerStatus _serverStatus = ServerStatus.connecting;

  late Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  Socket get socket => _socket;

  SocketService(){
    _initConfig();
  }

  void _initConfig(){

    _socket = io('http://10.0.2.2:4000', 
      OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .enableAutoConnect()  // disable auto-connection
        .build()
    );

    _socket.onConnect((_){
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });  
    _socket.onDisconnect((_){
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });   

    // socket.on('nuevo-mensaje', (data){
    //   print('nuevo-mensaje: $data');
    // });
  }

}