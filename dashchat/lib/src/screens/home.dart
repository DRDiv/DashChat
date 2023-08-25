import 'dart:io';

import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/posts.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:dashchat/src/screens/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
    _searchText = '';
  }

  FileImage? _image;
  bool _isLoading = false;
  Future _pickImageGallery(ImageSource source) async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = FileImage(File(pickedImage.path));
      });
    }
    Post post = Post();
    await post.addPost(_image!);
    User user = await User.getCurrentUser();
    await user.addPost(post.postUrl!);
  }

  Future _pickImageCamera(ImageSource source) async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = FileImage(File(pickedImage.path));
      });
    }
    Post post = Post();
    await post.addPost(_image!);
    User user = await User.getCurrentUser();
    await user.addPost(post.postUrl!);
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
          leadingWidth: screenWidth * 0.3,
          leading: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset(
              'images/dash.png',
            ),
          ),
          actions: [
            SizedBox(
              width: 0.7 * screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'DashChat',
                    style: TextStyle(
                        fontSize: 30,
                        color: (colorScheme.textColorLight),
                        fontFamily: fonts.headingFont),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.message,
                        color: colorScheme.chatBubbleOtherUserBackground,
                      )),
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
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        userProfile(
                                                                            userFound:
                                                                                _users[index]['userName'])));
                                                          },
                                                          leading: CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(_users[
                                                                        index][
                                                                    'profileUrl']),
                                                          ),
                                                          title: Text(
                                                            _users[index]
                                                                ['userName'],
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
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      content: Container(
                                          height: screenHeight * 0.20,
                                          width: screenWidth * 0.8,
                                          child: StatefulBuilder(
                                            builder: (context, setState) {
                                              return _isLoading
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(Icons
                                                                  .arrow_back),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            setState(() {
                                                              _isLoading = true;
                                                            });
                                                            await _pickImageGallery(
                                                                ImageSource
                                                                    .gallery);
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });
                                                          },
                                                          child: const Text(
                                                              'Pick Photo from Gallery'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            setState(() {
                                                              _isLoading = true;
                                                            });
                                                            await _pickImageCamera(
                                                                ImageSource
                                                                    .gallery);
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });
                                                          },
                                                          child: const Text(
                                                              'Pick Photo from Camera'),
                                                        ),
                                                      ],
                                                    );
                                            },
                                          )));
                                },
                              );
                            },
                            icon: Icon(Icons.add_photo_alternate)),
                        IconButton(
                            onPressed: () async {
                              User currentUser = await User.getCurrentUser();

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => userProfile(
                                          userFound: currentUser.userName)));
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
                                                                .password ==
                                                            user.password) {
                                                          passwordsMatch = true;
                                                          await User.logout();
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
