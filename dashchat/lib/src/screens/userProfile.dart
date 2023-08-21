import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:flutter/material.dart';

class userProfile extends StatefulWidget {
  String userFound;
  userProfile({super.key, required this.userFound});

  @override
  State<userProfile> createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  AppColorScheme colorScheme = AppColorScheme.defaultScheme();
  AppFonts fonts = AppFonts.defaultFonts();
  bool? following;
  User? user;
  User? loggedUser;
  bool isLoading = true;
  int? count;
  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    User loggedUser = await User.getCurrentUser();
    User currentUser = await User.get(widget.userFound);
    setState(() {
      user = currentUser;
      this.loggedUser = loggedUser;
      isLoading = false;
      following = (loggedUser.UserName == currentUser.UserName) ||
          (currentUser.followers.contains(loggedUser.UserName));
      count = user!.following.length;
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
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: SizedBox(
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  count.toString(),
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
                            ),
                          ],
                        ),
                      ),
                      following!
                          ? SizedBox(
                              width: 0.9 * screenWidth,
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                await loggedUser!.addFollowing(user!.UserName);
                                await user!.addFollower(loggedUser!.UserName);
                                setState(() {
                                  following = true;
                                  count = user!.following.length;
                                });
                              },
                              child: Text(
                                "Follow",
                                style: TextStyle(color: colorScheme.buttonText),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.buttonColor),
                            ),
                    ]),
              ),
            ),
    );
  }
}
