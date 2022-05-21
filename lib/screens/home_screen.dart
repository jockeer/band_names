import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 2),
    Band(id: '3', name: 'Bon Jovi', votes: 10),
    Band(id: '4', name: 'Nirvana', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:const  Text('BadNames',style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: ( context, index) => _bandTile(bands[index])
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection  direction){
        print(direction);
      },
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text('Eliminando...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          print(band.name);
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
    if (name.length > 1) {
      //Podemos Agregar
      setState(() {});
      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
    }
    Navigator.pop(context);
  }
}