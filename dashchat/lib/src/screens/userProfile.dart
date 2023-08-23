import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/posts.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class userProfile extends StatefulWidget {
  String userFound;
  userProfile({super.key, required this.userFound});

  @override
  State<userProfile> createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  AppColorScheme colorScheme = AppColorScheme.defaultScheme();
  AppFonts fonts = AppFonts.defaultFonts();
  TextEditingController _commentText = TextEditingController();
  bool? following;
  User? user;
  User? loggedUser;
  bool isLoading = true;
  bool postLoading = true;
  bool liked = false;
  final GlobalKey _alertDialogKey = GlobalKey();
  int? count;
  List<Post> postsUrlList = [];
  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    User loggedUser = await User.getCurrentUser();
    User currentUser = await User.get(widget.userFound);
    setState(() {
      user = currentUser;
      following = (loggedUser.UserName == currentUser.UserName) ||
          (currentUser.followers.contains(loggedUser.UserName));
      count = user!.following.length;
      postLoading = true;
    });
    for (var postUrl in currentUser.posts) {
      Post post = await Post.getPost(postUrl);
      setState(() {
        postsUrlList.add(post);
      });
    }
    setState(() {
      postLoading = false;
    });
  }

  Future<void> _addCommentToPost(int postIndex, String comment) async {
    Timestamp time = Timestamp.now();
    print(loggedUser!.UserName);
    await Post.addComment(
        postsUrlList[postIndex].postUrl!, comment, loggedUser!.UserName, time);

    setState(() {
      postsUrlList[postIndex].comments.add({
        'username': loggedUser!.UserName,
        'comments': comment,
        'time': time,
      });
    });
  }

  Future<void> _fetchCurrentUser() async {
    User loggedUser = await User.getCurrentUser();
    User currentUser = await User.get(widget.userFound);
    setState(() {
      user = currentUser;
      this.loggedUser = loggedUser;
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
              child: CircularProgressIndicator(),
            )
          : Scrollbar(
              child: SingleChildScrollView(
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
                                width: 0.8 * screenWidth,
                                child: postLoading
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: postsUrlList.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      colorScheme.buttonColor,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: ListTile(
                                                title: Image.network(
                                                  postsUrlList[index].postUrl!,
                                                  height: 300,
                                                ),
                                                subtitle: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .heart_broken_rounded,
                                                        color: postsUrlList[
                                                                    index]
                                                                .likes
                                                                .contains(
                                                                    loggedUser!
                                                                        .UserName)
                                                            ? colorScheme
                                                                .primaryColorVariant2
                                                            : Colors.grey,
                                                      ),
                                                      onPressed: () async {
                                                        bool likedCurrent =
                                                            postsUrlList[index]
                                                                .likes
                                                                .contains(
                                                                    loggedUser!
                                                                        .UserName);
                                                        await likedCurrent
                                                            ? Post.unlikePost(
                                                                postsUrlList[
                                                                        index]
                                                                    .postUrl!,
                                                                loggedUser!
                                                                    .UserName)
                                                            : Post.likePost(
                                                                postsUrlList[
                                                                        index]
                                                                    .postUrl!,
                                                                loggedUser!
                                                                    .UserName);
                                                        setState(() {
                                                          likedCurrent
                                                              ? postsUrlList[
                                                                      index]
                                                                  .likes
                                                                  .remove(loggedUser!
                                                                      .UserName)
                                                              : postsUrlList[
                                                                      index]
                                                                  .likes
                                                                  .add(loggedUser!
                                                                      .UserName);
                                                        });
                                                      },
                                                    ),
                                                    TextButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: Center(
                                                                  child: Text(
                                                                    "Comments",
                                                                    style: TextStyle(
                                                                        color: colorScheme
                                                                            .accentColor,
                                                                        fontFamily:
                                                                            fonts.headingFont),
                                                                  ),
                                                                ),
                                                                content:
                                                                    Container(
                                                                  width: double
                                                                      .maxFinite,
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Expanded(
                                                                        child: ListView
                                                                            .builder(
                                                                          itemCount: postsUrlList[index]
                                                                              .comments
                                                                              .length,
                                                                          itemBuilder:
                                                                              (context, commentIndex) {
                                                                            final comment =
                                                                                postsUrlList[index].comments[commentIndex];
                                                                            print(comment);
                                                                            Timestamp
                                                                                time =
                                                                                comment['time'];
                                                                            DateTime
                                                                                dateTime =
                                                                                time.toDate(); // Replace with your DateTime object
                                                                            String
                                                                                formattedDateTime =
                                                                                DateFormat('HH:mm:ss dd-MM-yy').format(dateTime);

                                                                            return ListTile(
                                                                              title: Text(
                                                                                comment['comments'],
                                                                                style: TextStyle(fontFamily: fonts.primaryFont, fontSize: 20),
                                                                              ),
                                                                              subtitle: Text(
                                                                                comment['username'] + "\n" + formattedDateTime.toString(),
                                                                                style: TextStyle(fontFamily: fonts.secondaryFont, fontSize: 10),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: TextFormField(
                                                                                controller: _commentText,
                                                                                decoration: InputDecoration(hintText: 'Enter Comment to Post', fillColor: colorScheme.chatBubbleUserBackground, filled: true),
                                                                              ),
                                                                            ),
                                                                            IconButton(
                                                                              onPressed: () async {
                                                                                await _addCommentToPost(index, _commentText.text);
                                                                                setState(() {
                                                                                  _commentText.clear();
                                                                                });
                                                                              },
                                                                              icon: Icon(
                                                                                Icons.send,
                                                                                size: 20,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Text(
                                                          'Comments',
                                                          style: TextStyle(
                                                              color: colorScheme
                                                                  .primaryColor,
                                                              fontFamily: fonts
                                                                  .anotherFont),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  await loggedUser!
                                      .addFollowing(user!.UserName);
                                  await user!.addFollower(loggedUser!.UserName);
                                  setState(() {
                                    following = true;
                                    count = user!.following.length;
                                  });
                                },
                                child: Text(
                                  "Follow",
                                  style:
                                      TextStyle(color: colorScheme.buttonText),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.buttonColor),
                              ),
                      ]),
                ),
              ),
            ),
    );
  }
}
