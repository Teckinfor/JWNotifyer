import 'package:flutter/material.dart';
import 'package:jwnotifyer/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'JWNotifyer',
      home: HomePage(),
      theme: ThemeData(
        fontFamily: 'Oxygen',
        primaryColor: Colors.deepPurple,
        ),
    );
  }
}