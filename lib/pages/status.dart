import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/sevices/socket_service.dart';

class StatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Estado de Servidor: ${socketService.serverStatus}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          socketService.emitir('emitir-mensaje', {
            'nombre': 'Flutter',
            'mensaje': 'hola mundo f',
            'mensaje2': 'aqui estoy f'
          });
        },
      ),
    );
  }
}
