import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hootalk/pages/chat_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Map<String, dynamic> currentUser = {
    "id" : "",
    "name" : ""
  };
  final refRooms = FirebaseDatabase.instance.ref().child("rooms");
  final refUsers = FirebaseDatabase.instance.ref().child("users");

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    
  }


  void getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? users = prefs.getString('user') ?? "{}";

    print(users);

    if(users != null && !users.isEmpty){
      Map<String, dynamic> userMap = jsonDecode(users)  as Map<String, dynamic>;
      setState((){
        currentUser = userMap;
      });
    }
  }

  Widget _getReturnUsers(){
    return StreamBuilder(
      stream: refUsers.onValue,
      builder: (context, AsyncSnapshot snap) {
        if (snap.hasData &&
            !snap.hasError &&
            snap.data.snapshot.value != null) {
          Map data = snap.data.snapshot.value;
          List item = [];
          data.forEach(
              (index, data) => item.add({"key": index, ...data}));
          item = item.where((i) => i['key'] != currentUser["id"]).toList();
          return Expanded(
            child: ListView.builder(
              itemCount: item.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (){
                    print(item[index]['key'].toString());
                    Route route = MaterialPageRoute(builder: (context) => ChatPage(userId: item[index]['key'].toString()));
                    Navigator.push(context, route);
                  },
                  child: Text(item[index]['name'].toString())
                );
              },
            ),
          );
        } else {
          return Center(child: Text("No data"));
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Login as ${currentUser["name"]}"),
      ),
      body: Center(
        child: _getReturnUsers()
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}