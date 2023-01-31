import 'package:chat_gtp_demo/screens/chat_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat gtp demo',
      
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      
      home: const ChatScreen(),
    );
  }
}
