import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hootalk/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hootalk/pages/user_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


  final ref = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    
  }

  void handleLogin() async {
    FirebaseService service = new FirebaseService();
    try {
     await service.signInwithGoogle();
     User? user = FirebaseAuth.instance.currentUser;
     if(user != null){
        initUsers(user);
     }
    } catch(e){
      print(e);
      if(e is FirebaseAuthException){
        print(e.message!);
      }
    }
  }

  void initUsers(User user) async {

    final prefs = await SharedPreferences.getInstance();
    final userRaw = {
      "photoUrl" : user.photoURL,
      "name": user.displayName,
      "status" : "online"
    };

    ref.child("users/"+user.uid).set(userRaw);
    await prefs.setString('user', json.encode({
        "id" : user.uid,
        "photoUrl" : user.photoURL,
        "name": user.displayName,
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
          child:   TextButton(
            child: Text('Start'),
            onPressed: () {
              handleLogin();
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