import 'dart:io';

import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AppColorScheme colorScheme = AppColorScheme.defaultScheme();
  AppFonts fonts = AppFonts.defaultFonts();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _caption = TextEditingController();
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

  FileImage? _image;

  Future _pickImageGallery(ImageSource source) async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = FileImage(File(pickedImage.path));
      });
    }
  }

  Future _pickImageCamera(ImageSource source) async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = FileImage(File(pickedImage.path));
      });
    }
  }

  bool booleanPassword = false;
  int numberLines1 = 3;
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                              radius: 60.0,
                              backgroundColor: colorScheme.backgroundColor,
                              child: _image == null
                                  ? const Icon(Icons.person, size: 100)
                                  : ClipOval(
                                      child: Image(
                                      image: _image!,
                                      width: 120.0,
                                      height: 120.0,
                                      fit: BoxFit.cover,
                                    ))),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () =>
                                _pickImageGallery(ImageSource.gallery),
                            child: const Text('Pick Photo from Gallery'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                _pickImageCamera(ImageSource.camera),
                            child: const Text('Pick Photo from Camera'),
                          ),
                        ],
                      ),
                    ),
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
                                'Enter Username \nAt least 3 letters,characters,numbers\n and "_" allowed',
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
                        controller: _caption,
                        decoration: InputDecoration(
                            errorText: emailMatch ? null : stringErrorEmail,
                            hintText: 'Enter Caption',
                            hintStyle: TextStyle(
                                color: colorScheme.primaryColor,
                                fontFamily: fonts.accentFont)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            numberLines = 1;
                            booleanPassword = true;
                          });
                        },
                        obscureText: booleanPassword,
                        maxLines: numberLines,
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
                        obscureText: true,
                        maxLines: 1,
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
                    _displayName.text, _image, _caption.text);
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
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                await user.Register();
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: colorScheme.backgroundColor,
                        actions: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: colorScheme.successColor,
                                size: 80,
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'SUCCESSFULY REGISTERED ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: fonts.randomFont,
                                        color: colorScheme.successColor,
                                        fontSize: 30),
                                  ))
                            ],
                          ),
                        ],
                      );
                    });
                setState(() {
                  _username.clear();
                  _email.clear();
                  _displayName.clear();
                  _password.clear();
                  _confirmPassword.clear();
                  _caption.clear();
                  _image = null;
                  booleanPassword = false;
                  numberLines1 = 3;
                  numberLines = 6;
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
