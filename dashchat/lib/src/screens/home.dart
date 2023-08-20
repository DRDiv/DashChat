import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppColorScheme colorScheme = AppColorScheme.defaultScheme();
  AppFonts fonts = AppFonts.defaultFonts();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: (colorScheme.accentColor),
          actions: [
            Container(
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset('images/dash.png'),
                  ),
                  Text(
                    'DashChat',
                    style: TextStyle(
                        fontSize: 30,
                        color: (colorScheme.textColorLight),
                        fontFamily: fonts.headingFont),
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.people,
                            color: colorScheme.chatBubbleOtherUserBackground,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.message,
                            color: colorScheme.chatBubbleOtherUserBackground,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SizedBox(
            width: screenWidth,
            height: 50,
            child: AppBar(
              actions: [
                Container(
                    height: 50,
                    width: screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                        Icon(Icons.abc),
                      ],
                    )),
              ],
              backgroundColor: colorScheme.chatBubbleUserBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
            )));
  }
}
