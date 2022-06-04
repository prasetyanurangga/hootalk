import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.userId}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String userId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Map<String, dynamic> currentUser = {
    "id" : "",
    "name" : ""
  };
  String currentRoom = "";
  String currentMessage = "";
  final refRooms = FirebaseDatabase.instance.ref().child("rooms");
  final refUsers = FirebaseDatabase.instance.ref().child("users");
  final message1Controller = TextEditingController();
  final message2Controller = TextEditingController();



  @override
  void initState() {
      super.initState();

      getCurrentUser();
if(currentRoom != null && !currentRoom.isEmpty){
        
      }

      
  }


  void getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? users = prefs.getString('user') ?? "{}";
    if(users != null && !users.isEmpty){
      Map<String, dynamic> userMap = jsonDecode(users)  as Map<String, dynamic>;
      
      String id = userMap["id"] ?? "";
      setState((){
        currentUser = userMap;
      });

      createRoom(id , widget.userId);
    }
  }


  void createRoom(String user1, String user2) async {
    DatabaseEvent DBevent = await refRooms.child(user2+user1).once();
    String roomId = "";
    print("sudah ada ? ${DBevent.snapshot.exists.toString()}");
    if(DBevent.snapshot.exists){
      print("sudah ada ${user2+user1}");
      roomId = user2+user1;
      setState((){
        currentRoom = user2+user1;
      });
    } else {
      String newRoomKey = user1+user2;
      roomId = newRoomKey;
      print("belum  ada ${newRoomKey}");
      refRooms.set({
        newRoomKey: {
          user1: "",
          user2: ""
        }
      });

      setState((){
        currentRoom = newRoomKey;
      });

    }

   print(roomId);

    Stream<DatabaseEvent> stream = refRooms.child(roomId+"/"+widget.userId).onValue;
    stream.listen((DatabaseEvent event) {
      print('Snapshot: ${event.snapshot.value.toString()}'); // DataSnapshot
      message1Controller.text = event.snapshot.value.toString();
    });
    
  }

  Widget chatRoowm(){
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(20),
          child: TextField(
            controller: message1Controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Full Name',
            )
          )
        ),
        Container(
          margin: EdgeInsets.all(20),
          child: TextField(
            controller: message2Controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Full Name',
            ),
            onChanged: (text) {
                String id = currentUser["id"] ?? "";
                refRooms.child(currentRoom).update({
                  id : text,
                });

              
            },
          )
        ),
      ]
    );
  }

  

  @override
  Widget build(BuildContext context) {




// ...



    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text("Login as ${currentUser["name"]}"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: chatRoowm()
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}