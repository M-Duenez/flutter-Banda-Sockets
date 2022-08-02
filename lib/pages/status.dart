import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/sevices/socket_service.dart';

class StatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Text('Hola Mundo'),
      ),
    );
  }
}
