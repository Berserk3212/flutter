import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> userList = ['Users'];

  @override 
  void initState() {  
    super.initState();
    loadUserList();
  }

  Future<void> loadUserList() async { 
    await Future.delayed(const Duration(seconds: 5));
    setState(() {    
      userList = ['New Users!!'];   
    });
  } 
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ 
              ...List.generate(
                userList.length, 
                (i) => Text(
                  userList[i],
                  style: TextStyle(fontSize: 24),
                )
              )
            ]
          )
        )
      ),
    );
  }
}