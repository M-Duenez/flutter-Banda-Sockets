import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  Function get emitir => this._socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    // Dart client
    this._socket = IO.io('http://192.168.50.21:3000/', {
      'transports': ['websocket'],
      'autoConnect': true
    });

    this._socket.onConnect((_) {
      this._serverStatus = ServerStatus.Online;
      //Notifica a la aplicacion que existe algun cambio en el servido
      notifyListeners();
    });
    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    /*socket.on('nuevo-mensaje', (payload) {
      print('nuevo-mensaje:');
      print('Nombre: ' + payload['nombre']);
      print('Mnesaje: ' + payload['mensaje']);
      print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No hay');
      print('------------------------------------------------');
    });*/
  }
}
