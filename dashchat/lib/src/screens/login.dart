import 'package:dashchat/src/app.dart';
import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:dashchat/src/screens/register.dart';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback callback;

  LoginPage({required this.callback});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AppColorScheme colorScheme = AppColorScheme.defaultScheme();
  AppFonts fonts = AppFonts.defaultFonts();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool userExists = true;
  bool passwordMatch = true;

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
                          errorText: passwordMatch ? null : 'Password mismatch',
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
              User currentUser = User("", _password.text, "", "");
              if (user.UserName == "") {
                setState(() {
                  userExists = false;
                });
                _username.clear();
                _password.clear();
                return;
              }
              setState(() {
                userExists = true;
              });

              if (currentUser.Password != user.Password) {
                setState(() {
                  passwordMatch = false;
                });
                return;
              }

              widget.callback();
              user.login();
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()));
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
