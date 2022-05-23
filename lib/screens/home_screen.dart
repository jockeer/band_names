import 'dart:io';

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';
import 'package:provider/provider.dart';

import 'package:pie_chart/pie_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Band> bands = [
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('bands', _handleBands );

    super.initState();
    
  }

  _handleBands(dynamic payload){
    
      bands = (payload as List).map(( band ) => Band.fromMap(band)).toList();
      setState(() {});

  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('bands');
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return  Scaffold(
      appBar: AppBar(
        title:const  Text('BadNames',style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.online 
                    ? const Icon(Icons.check_circle, color:Colors.green) 
                    : const Icon(Icons.offline_bolt, color:Colors.red)
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: ( context, index) => _bandTile(bands[index])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection  direction){
        socketService.socket.emit('delete-band',{"id":band.id});
      },
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text('Eliminando a ${band.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ),

      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0,2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}',style: const TextStyle(fontSize: 20),),
        onTap: (){
         socketService.socket.emit('vote-band',{
           "id": band.id
         });
        },
      ),
    );
  }

  addNewBand(){
    
    final textController = TextEditingController();
    
    if( Platform.isAndroid ){
      showDialog(
        context: context, 
        builder: ( context ) {
          return AlertDialog(
            title: const Text('New Band Name'),
            content:  TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                onPressed: () => addBandToList(textController.text),
                elevation: 5,
                textColor: Colors.blue,
                child: const Text('Add'),
              )
            ],

          );
        },
        
      );
      return;
    }
    showCupertinoDialog(
      context: context, 
      builder: ( _ ) {
        return CupertinoAlertDialog(
          title: const Text('New Band Name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'), 
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'), 
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }
    );

  }
  void addBandToList(String name){
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.socket.emit('add-band',{"name":name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph(){
    Map<String, double> dataMap = {};
    
    bands.forEach((band) { 
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue[50]!,
      Colors.blue[200]!,
      Colors.pink[50]!,
      Colors.pink[200]!,
      Colors.yellow[50]!,
      Colors.yellow[200]!,
      Colors.red[50]!,
      Colors.red[200]!,
    ];
  

    return bands.isEmpty 
      ? const CircularProgressIndicator() 
      : SizedBox(
        width: double.infinity,
        height: 200,
        child: PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width/2.5,
            colorList: colorList,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 20,
            centerText: "",
            legendOptions: const LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.right,
              showLegends: true,
              legendShape: BoxShape.circle,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions:const ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: false,
              decimalPlaces: 1,
            ),
            // gradientList: ---To add gradient colors---
            // emptyColorGradient: ---Empty Color gradient---
        ),
      );
  }
}