import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AppColorScheme colorScheme = new AppColorScheme.defaultScheme();
  AppFonts fonts = new AppFonts.defaultFonts();
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
                      decoration: InputDecoration(
                          hintText: 'Enter Username',
                          hintStyle: TextStyle(
                              color: colorScheme.primaryColor,
                              fontFamily: fonts.accentFont)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: TextFormField(
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
                      decoration: InputDecoration(
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(
                              color: colorScheme.primaryColor,
                              fontFamily: fonts.accentFont)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: TextFormField(
                      decoration: InputDecoration(
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
            onPressed: () {},
            child: Text(
              "Register",
              style: TextStyle(
                  color: colorScheme.buttonText,
                  fontFamily: fonts.secondaryFont),
            ),
          ),
        ],
      ),
    );
  }
}
