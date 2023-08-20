import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:dashchat/src/screens/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/commands.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback callback;
  const HomeScreen({super.key, required this.callback});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _users = List.empty();
  String _searchText = '';
  Future<void> _updateUsers(String searchText) async {
    List<Map<String, dynamic>> userTemp =
        await SearchQuery().getUsers(searchText);
    setState(() {
      _users = userTemp;
    });
  }

  AppColorScheme colorScheme = AppColorScheme.defaultScheme();
  AppFonts fonts = AppFonts.defaultFonts();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: (colorScheme.accentColor),
          actions: [
            SizedBox(
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
                SizedBox(
                    height: 50,
                    width: screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  TextEditingController _like =
                                      TextEditingController();

                                  return StatefulBuilder(
                                      builder: (context, setState) {
                                    return AlertDialog(
                                      content: Container(
                                        height: screenHeight * 0.6,
                                        width: screenWidth * 0.8,
                                        child: Column(
                                          children: [
                                            Container(
                                              color: colorScheme
                                                  .chatBubbleUserBackground,
                                              child: TextField(
                                                onChanged: (text) {
                                                  setState(() {
                                                    _searchText = text;
                                                  });
                                                },
                                                controller: _like,
                                                style: TextStyle(
                                                    color: colorScheme
                                                        .textColorPrimary,
                                                    fontFamily:
                                                        fonts.anotherFont),
                                              ),
                                            ),
                                            FutureBuilder(
                                              future: _updateUsers(_searchText),
                                              builder: (context, snapshot) {
                                                print(_users);
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 25),
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                } else if (_users.isEmpty) {
                                                  return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 25),
                                                      child: Text(
                                                          'No users found.',
                                                          style: TextStyle(
                                                              color: colorScheme
                                                                  .textColorPrimary,
                                                              fontFamily: fonts
                                                                  .secondaryFont)));
                                                } else {
                                                  return Expanded(
                                                    child: ListView.builder(
                                                      itemCount: _users.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ListTile(
                                                          leading: CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(_users[
                                                                        index][
                                                                    'profileUrl']),
                                                          ),
                                                          title: Text(
                                                            _users[index]
                                                                ['name'],
                                                            style: TextStyle(
                                                                color: colorScheme
                                                                    .textColorSecondary,
                                                                fontFamily: fonts
                                                                    .headingFont,
                                                                fontSize: 20),
                                                          ),
                                                          subtitle: Text(
                                                              _users[index][
                                                                  'displayName'],
                                                              style: TextStyle(
                                                                  color: colorScheme
                                                                      .textColorAccent,
                                                                  fontFamily: fonts
                                                                      .anotherFont,
                                                                  fontSize:
                                                                      10)),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                },
                              );
                            },
                            icon: const Icon(Icons.search)),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => userProfile()));
                            },
                            icon: Icon(Icons.person_4)),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  bool passwordsMatch = true;
                                  return StatefulBuilder(
                                      builder: (context, setState) {
                                    return AlertDialog(
                                      backgroundColor:
                                          colorScheme.backgroundColor,
                                      content: Container(
                                        width: screenWidth * 0.85,
                                        height: screenHeight * 0.25,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Form(
                                              child: Column(children: [
                                                TextFormField(
                                                  controller: _confirmPassword,
                                                  obscureText: true,
                                                  maxLines: 1,
                                                  decoration: InputDecoration(
                                                      errorText: passwordsMatch
                                                          ? null
                                                          : 'Password Do Not Match',
                                                      hintText:
                                                          'Confirm Password',
                                                      hintStyle: TextStyle(
                                                          color: colorScheme
                                                              .primaryColor,
                                                          fontFamily: fonts
                                                              .accentFont)),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: ElevatedButton(
                                                      onPressed: () async {
                                                        User user = User(
                                                            "",
                                                            _confirmPassword
                                                                .text,
                                                            "",
                                                            "",
                                                            null,
                                                            "");
                                                        User currentUser =
                                                            await User
                                                                .getCurrentUser();

                                                        if (currentUser
                                                                .Password ==
                                                            user.Password) {
                                                          passwordsMatch = true;
                                                          Navigator.pop(
                                                              context);
                                                          widget.callback();
                                                        } else {
                                                          setState(() {
                                                            passwordsMatch =
                                                                false;
                                                          });

                                                          _confirmPassword
                                                              .clear();
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  colorScheme
                                                                      .buttonColor),
                                                      child: Text(
                                                        'Confirm Logout',
                                                        style: TextStyle(
                                                            color: colorScheme
                                                                .buttonText,
                                                            fontFamily: fonts
                                                                .primaryFont),
                                                      )),
                                                ),
                                              ]),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                },
                              );
                            },
                            icon: const Icon(Icons.logout)),
                      ],
                    )),
              ],
              backgroundColor: colorScheme.chatBubbleUserBackground,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
            )));
  }
}
