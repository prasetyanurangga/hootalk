import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hootalk/pages/user_page.dart';
import 'package:username_gen/username_gen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);
  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  final ref = FirebaseDatabase.instance.ref();
  final refRooms = FirebaseDatabase.instance.ref().child("rooms");
  final refUsers = FirebaseDatabase.instance.ref().child("users");
  final message1Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final username = UsernameGen.generateWith(
        seperator: '_'
    );
    message1Controller.text = username;
    
  }

  void initUsers() async {

    final prefs = await SharedPreferences.getInstance();
    final user = {
      "name": message1Controller.text,
      "status" : "online"
    };

    String newPostKey = refUsers.push().key ?? "";
    ref.child("users/"+newPostKey).set(user);
    await prefs.setString('user', json.encode({
        "id" : newPostKey,
        "name": message1Controller.text,
        "status" : "online"
    }));

    Route route = MaterialPageRoute(builder: (context) => UserPage());
    Navigator.push(context, route);

  }


  Widget _body(){
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
          child:   TextButton(
            child: Text('Start'),
            onPressed: () {
              initUsers();
            }
          )
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
      ),
      body: Center(
        child: _body()
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}