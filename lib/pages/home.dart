import 'dart:io';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/sevices/socket_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Band> bands = [
    /*Band(id: '1', name: 'Nodal', votes: 3),
    Band(id: '2', name: 'Firme', votes: 10),
    Band(id: '3', name: 'Julion', votes: 5),
    Band(id: '4', name: 'Pesado', votes: 7),*/
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(
      context,
      listen: false,
    );

    socketService.socket.on('bandas-activas', _handleActiveBandas);

    super.initState();
  }

  _handleActiveBandas(dynamic payload) {
    this.bands = (payload as List).map((banda) => Band.fromMap(banda)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(
      context,
      listen: false,
    );
    socketService.socket.off('bandas-activas');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Nombre de Bandas',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child:
                //TODO:: Validacion de conexion de server
                (socketService.serverStatus == ServerStatus.Online)
                    ? Icon(Icons.check_circle, color: Colors.blue[300])
                    : Icon(Icons.offline_bolt, color: Colors.red),
            //Icon(Icons.check_circle, color: Colors.blue[300]),
            //Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _showGrafica(),
          SizedBox(
            height: 20.0,
          ),
          SizedBox(
            //width: double.infinity,
            height: 250,
            child: Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: bands.length,
                itemBuilder: (BuildContext context, int i) =>
                    _bandTitle(bands[i]),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 0,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTitle(Band banda) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(banda.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) {
        //TODO: llamar el borrado de servidor
        print('id: ${banda.id}');

        socketService.socket.emit('delete-banda', {'id': banda.id});
      },
      background: Container(
        padding: EdgeInsets.only(left: 20.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: Colors.white,
              ),
              SizedBox(width: 10.0),
              Text(
                'ELIMINANDO',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(banda.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(banda.name),
        trailing: Text(
          '${banda.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          setState(() {
            print(banda.id);
            socketService.socket.emit('votes-banda', {'id': banda.id});
          }); //banda.votes++;
        },
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Nueva Banda'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                  child: Text('Agregar'),
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () => addBandToList(textController.text))
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text('Nueva Banda'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Agregar'),
              textStyle: TextStyle(color: Colors.blue),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Cerrar'),
              textStyle: TextStyle(color: Colors.red),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void addBandToList(String name) {
    if (name.length >= 3) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      //agregar
      //int id = bands.length + 1;

      //print('agregado  id: $id   name: $name');
      /*setState(() {
        //Band band = new Band(id: '$id', name: nameUP, votes: 0);

        this.bands.add(new Band(id: '$id', name: name.toUpperCase(), votes: 0));
      });*/

      //EVENTO DE AGREGADO CON COMINICACION CON EL SERVIDOR
      //print('agregado name: $name');
      //socketService.socket.emit('add-banda', {'name': name.toUpperCase()});
      setState(() {
        print('agregado name: $name');
        socketService.socket.emit('add-banda', {'name': name.toUpperCase()});
      });
    } else {
      print('No se agrego');
    }

    Navigator.pop(context);
  }

  Widget _showGrafica() {
    if (bands.length == 0) {
      Map<String, double> dataMap = {
        "Flutter": 5,
        "React": 3,
        "Xamarin": 2,
        "Ionic": 2,
      };

      return PieChart(dataMap: dataMap);
    } else {
      Map<String, double> dataMap = {};

      bands.forEach((banda) {
        dataMap.putIfAbsent(banda.name, () => banda.votes.toDouble());
      });

      return Container(
        width: double.infinity,
        height: 200.0,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 42,
          chartRadius: MediaQuery.of(context).size.width / 3.0,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          centerText: "VOTOS",

          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            decimalPlaces: 0,
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        ),
      );
    }
  }
}
