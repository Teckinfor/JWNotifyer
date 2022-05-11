import 'package:flutter/material.dart';
import 'package:jwnotifyer/homepage.dart';
import 'fetcher_service.dart';

void main() async {
  FetcherService service = await FetcherService();
  service.initializeService();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JWNotifyer',
      home: const HomePage(),
      theme: ThemeData(
        fontFamily: 'Oxygen',
        primaryColor: Colors.deepPurple,
      ),
    );
  }
}
