import 'package:dashchat/src/models/user.dart';
import 'package:dashchat/src/screens/home.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedIn = false;
  Future<void> _checkLogin() async {
    bool isLoggedIn = await User.userLoggedIn();
    setState(() {
      loggedIn = isLoggedIn;
    });
  }

  void _handleLogin() {
    setState(() {
      loggedIn = true;
    });
  }

  void _handleLogout() {
    setState(() {
      loggedIn = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: loggedIn
          ? HomeScreen(callback: _handleLogout)
          : LoginPage(callback: _handleLogin),
    );
  }
}
