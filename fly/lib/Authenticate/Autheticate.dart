import 'package:fly/Screens/HomeScreen.dart';
import 'package:fly/Authenticate/LoginScree.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      // ignore: prefer_const_constructors
      return HomeScreen(toString());
    } else {
      return LoginScreen();
    }
  }
}
