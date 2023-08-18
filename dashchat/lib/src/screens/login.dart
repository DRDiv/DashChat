import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:dashchat/src/screens/home.dart';
import 'package:dashchat/src/screens/register.dart';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AppColorScheme colorScheme = new AppColorScheme.defaultScheme();
  AppFonts fonts = new AppFonts.defaultFonts();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool userExists = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: (colorScheme.accentColor),
        title: Center(
          child: Text(
            'DashChat',
            style: TextStyle(
                fontSize: 30,
                color: (colorScheme.textColorLight),
                fontFamily: fonts.headingFont),
          ),
        ),
      ),
      body: Column(
        children: [
          Form(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: TextFormField(
                      controller: _username,
                      decoration: InputDecoration(
                          errorText: userExists ? null : 'Invalid Credentials',
                          hintText: 'Username',
                          hintStyle: TextStyle(
                              color: colorScheme.primaryColor,
                              fontFamily: fonts.accentFont)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: TextFormField(
                      obscureText: true,
                      controller: _password,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              color: colorScheme.primaryColor,
                              fontFamily: fonts.accentFont)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.buttonColor),
            onPressed: () async {
              User user = await User.get(_username.text);
              if (user.UserName == "") {
                setState(() {
                  userExists = false;
                });
                _username.clear();
                _password.clear();
                return;
              }
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            child: Text(
              "Login",
              style: TextStyle(
                  color: colorScheme.buttonText,
                  fontFamily: fonts.secondaryFont),
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              child: Text("Not Registered? Click Here!!",
                  style: TextStyle(
                      color: colorScheme.textColorSecondary,
                      fontFamily: fonts.accentFont)))
        ],
      ),
    );
  }
}
