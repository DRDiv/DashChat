import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:flutter/material.dart';

class userProfile extends StatefulWidget {
  const userProfile({super.key});

  @override
  State<userProfile> createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  AppColorScheme colorScheme = AppColorScheme.defaultScheme();
  AppFonts fonts = AppFonts.defaultFonts();

  User? user;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    User currentUser = await User.getCurrentUser();
    setState(() {
      user = currentUser;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(backgroundColor: (colorScheme.accentColor), actions: [
        SizedBox(
            width: screenWidth,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('DashChat',
                      style: TextStyle(
                          fontSize: 30,
                          color: (colorScheme.textColorLight),
                          fontFamily: fonts.headingFont)),
                ]))
      ]),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(), // Show loading indicator
            )
          : SizedBox(
              width: screenWidth,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 30, 16, 10),
                      child: CircleAvatar(
                          radius: 60.0,
                          backgroundColor: colorScheme.backgroundColor,
                          child: user!.profileUrl == null
                              ? const Icon(Icons.person, size: 100)
                              : ClipOval(
                                  child: Image.network(
                                  user!.profileUrl,
                                  width: 120.0,
                                  height: 120.0,
                                  fit: BoxFit.cover,
                                ))),
                    ),
                    Text(
                      user!.UserName,
                      style: TextStyle(
                          color: colorScheme.textColorPrimary,
                          fontFamily: fonts.accentFont,
                          fontSize: 40),
                    ),
                    Text(
                      user!.DisplayName,
                      style: TextStyle(
                          color: colorScheme.textColorSecondary,
                          fontFamily: fonts.bodyFont,
                          fontSize: 20),
                    ),
                    Text(
                      user!.caption,
                      style: TextStyle(
                          color: colorScheme.accentColor,
                          fontFamily: fonts.secondaryFont,
                          fontSize: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              user!.followers.length.toString(),
                              style: TextStyle(
                                  color: colorScheme.textColorPrimary,
                                  fontFamily: fonts.anotherFont,
                                  fontSize: 20),
                            ),
                            Text(
                              "FOLLOWERS",
                              style: TextStyle(
                                  color: colorScheme.textColorPrimary,
                                  fontFamily: fonts.anotherFont,
                                  fontSize: 20),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              user!.following.length.toString(),
                              style: TextStyle(
                                  color: colorScheme.textColorPrimary,
                                  fontFamily: fonts.anotherFont,
                                  fontSize: 20),
                            ),
                            Text(
                              "FOLLOWING",
                              style: TextStyle(
                                  color: colorScheme.textColorPrimary,
                                  fontFamily: fonts.anotherFont,
                                  fontSize: 20),
                            )
                          ],
                        )
                      ],
                    )
                  ]),
            ),
    );
  }
}
