import 'dart:developer';

import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AppColorScheme colorScheme = new AppColorScheme.defaultScheme();
  AppFonts fonts = new AppFonts.defaultFonts();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _displayName = TextEditingController();
  bool passwordsMatch = true;
  bool usernameMatch = true;
  bool emailMatch = true;
  bool passwordMatch = true;
  String stringErrorUser = "";
  String stringErrorEmail = "";
  Future<void> _emailEmpty() async {
    String emailPattern = r'^[a-zA-Z0-9._%+-]{1,1000}@gmail\.com$';
    RegExp regExp = RegExp(emailPattern);

    emailMatch = regExp.hasMatch(_email.text);
    if (!emailMatch) {
      stringErrorEmail = 'Email does not match specified format';
      _password.clear();
      _confirmPassword.clear();
    }
  }

  void _checkUsername() {
    String usernamePattern = r'^[a-zA-Z0-9_]{3,100}$';
    RegExp regExp = RegExp(usernamePattern);
    usernameMatch = regExp.hasMatch(_username.text);
    if (!usernameMatch) {
      stringErrorUser = 'Username does not match specified format';
      _password.clear();
      _confirmPassword.clear();
    }
  }

  // void _checkPassword() {
  //   String passwordPattern =
  //       r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$';
  //   RegExp regExp = RegExp(passwordPattern);
  //   passwordMatch = regExp.hasMatch(_password.text);
  //   if (!passwordMatch) {
  //     _password.clear();
  //     _confirmPassword.clear();
  //   }
  // }

  void _checkPasswordMatch() {
    if (_password.text != _confirmPassword.text) {
      setState(() {
        passwordsMatch = false;
        _password.clear();
        _confirmPassword.clear();
      });
    } else {
      setState(() {
        passwordsMatch = true;
      });
    }
  }

  int numberLines1 = 2;
  int numberLines = 6;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: (colorScheme.accentColor),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(65.0, 0, 0, 0),
          child: Text('WELCOME',
              style: TextStyle(
                  fontFamily: fonts.headingFont,
                  color: colorScheme.textColorLight)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                        onChanged: (value) {
                          setState(() {
                            numberLines1 = 1;
                          });
                        },
                        maxLines: numberLines1,
                        controller: _username,
                        decoration: InputDecoration(
                            errorText: usernameMatch ? null : stringErrorUser,
                            hintText:
                                'Enter Username (at least 3 letters,\n characters,numbers and "_" allowed)',
                            hintStyle: TextStyle(
                                color: colorScheme.primaryColor,
                                fontFamily: fonts.accentFont)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: TextFormField(
                        controller: _displayName,
                        decoration: InputDecoration(
                            hintText: 'Enter Your Display Name',
                            hintStyle: TextStyle(
                                color: colorScheme.primaryColor,
                                fontFamily: fonts.accentFont)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                            errorText: emailMatch ? null : stringErrorEmail,
                            hintText: 'Enter Your Email Address',
                            hintStyle: TextStyle(
                                color: colorScheme.primaryColor,
                                fontFamily: fonts.accentFont)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: TextFormField(
                        maxLines: numberLines,
                        onChanged: (value) {
                          setState(() {
                            numberLines = 1;
                          });
                        },
                        controller: _password,
                        decoration: InputDecoration(
                          hintMaxLines: numberLines,
                          errorText: passwordMatch
                              ? null
                              : 'Password does not match format',
                          hintText:
                              'Enter Password \nat least one letter (uppercase or lowercase) is present\n at least one digit is present\nat least one special character is present\na minimum length of 8 characters.',
                          hintStyle: TextStyle(
                              color: colorScheme.primaryColor,
                              fontFamily: fonts.accentFont),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: TextFormField(
                        controller: _confirmPassword,
                        decoration: InputDecoration(
                            errorText:
                                passwordsMatch ? null : 'Password Do Not Match',
                            hintText: 'Confirm Password',
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
                setState(() {
                  _checkUsername();
                });
                if (!usernameMatch) return;
                // setState(() {
                // _checkPassword();
                // });

                // if (!passwordMatch) return;
                setState(() {
                  _checkPasswordMatch();
                });

                if (!passwordsMatch) return;
                await _emailEmpty();

                if (!emailMatch) return;

                User user = User(_username.text, _password.text, _email.text,
                    _displayName.text);
                bool userExists = await user.userExist();
                if (userExists) {
                  setState(() {
                    stringErrorUser = "Username already taken";
                    usernameMatch = false;
                    _password.clear();
                    _confirmPassword.clear();
                  });

                  return;
                }
                bool emailExists = await user.emailExist();
                if (emailExists) {
                  setState(() {
                    stringErrorEmail = "Email already taken";
                    emailMatch = false;
                    _password.clear();
                    _confirmPassword.clear();
                  });

                  return;
                }

                await user.Register();

                setState(() {
                  _username.clear();
                  _email.clear();
                  _displayName.clear();
                  _password.clear();
                  _confirmPassword.clear();
                });
              },
              child: Text(
                "Register",
                style: TextStyle(
                    color: colorScheme.buttonText,
                    fontFamily: fonts.secondaryFont),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
