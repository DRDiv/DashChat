import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/posts.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:dashchat/src/screens/messaging.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _commentText = TextEditingController();
  List<TextEditingController>? _caption;
  bool? following;
  User? user;
  User? loggedUser;
  bool isLoading = true;
  bool postLoading = true;
  bool liked = false;
  Map userTokenMap = {};
  final GlobalKey _alertDialogKey = GlobalKey();
  int? count;
  List<Post> postsUrlList = [];
  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchPost();
  }

  String _format(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();

    if (now.difference(dateTime).inDays < 1) {
      if (now.difference(dateTime).inHours < 1) {
        if (now.difference(dateTime).inMinutes < 1) {
          return 'Just now';
        } else {
          return '${now.difference(dateTime).inMinutes} mins ago';
        }
      } else {
        return '${now.difference(dateTime).inHours} hrs ago';
      }
    } else {
      if (now.year == dateTime.year) {
        return DateFormat('MMM d').format(dateTime);
      } else {
        return DateFormat('MMM d, yyyy').format(dateTime);
      }
    }
  }

  Future<void> _fetchPost() async {
    User loggedUser = await User.getCurrentUser();
    User currentUser = await User.getByUsername(widget.userFound);
    setState(() {
      user = currentUser;
      following = (loggedUser.userToken == currentUser.userToken) ||
          (currentUser.followers.contains(loggedUser.userToken));
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
      _caption = List.generate(
          postsUrlList.length, (index) => TextEditingController());
    });
  }

  Future<void> _captionChange(int postIndex, String caption) async {
    Post post = await Post.getPost(postsUrlList[postIndex].postUrl!);
    await post.updateCaption(caption);
    setState(() {
      postsUrlList[postIndex].caption = caption;
    });
  }

  Future<void> _addCommentToPost(int postIndex, String comment) async {
    Timestamp time = Timestamp.now();

    await Post.addComment(postsUrlList[postIndex].postUrl!, comment,
        loggedUser!.userToken!, time);

    setState(() {
      postsUrlList[postIndex].comments.add({
        'userToken': loggedUser!.userToken,
        'comments': comment,
        'time': time,
      });
    });
  }

  Future<void> _fetchCurrentUser() async {
    User loggedUser = await User.getCurrentUser();
    User currentUser = await User.getByUsername(widget.userFound);
    Map userTokenMap = await User.getUsernameMap();
    setState(() {
      user = currentUser;
      this.loggedUser = loggedUser;
      isLoading = false;
      this.userTokenMap = userTokenMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.accentColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'DashChat',
          style: TextStyle(
            fontSize: 30,
            color: colorScheme.textColorLight,
            fontFamily: fonts.headingFont,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.white,
          ),
        ),
        actions: [
          if (!isLoading &&
              following! &&
              loggedUser!.userToken != user!.userToken)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => messageScreen(
                      loggedUser: loggedUser!,
                      displayUser: user!,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.send_sharp,
                color: colorScheme.chatBubbleOtherUserBackground,
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
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
                              child: user!.profileUrl == ""
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
                          user!.userName,
                          style: TextStyle(
                              color: colorScheme.textColorPrimary,
                              fontFamily: fonts.accentFont,
                              fontSize: 40),
                        ),
                        Text(
                          user!.displayName,
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
                        (loggedUser!.userToken != user!.userToken) && following!
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await loggedUser!
                                        .removeFollowing(user!.userToken!);
                                    await user!
                                        .removeFollower(loggedUser!.userToken!);
                                    setState(() {
                                      following = false;
                                      count = user!.following.length;
                                      isLoading = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme
                                          .chatBubbleOtherUserBackground),
                                  child: Text(
                                    "Following",
                                    style: TextStyle(
                                        color: colorScheme.accentColor),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        following!
                            ? SizedBox(
                                width: 0.8 * screenWidth,
                                child: postLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount:
                                            (postsUrlList.length / 2).ceil(),
                                        itemBuilder: (context, rowIndex) {
                                          int startIndex = rowIndex * 2;
                                          int endIndex = startIndex + 2;
                                          endIndex =
                                              endIndex > postsUrlList.length
                                                  ? postsUrlList.length
                                                  : endIndex;

                                          return Row(
                                            children: List.generate(
                                                endIndex - startIndex, (index) {
                                              return Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: colorScheme
                                                            .buttonColor,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    child: ListTile(
                                                      title: GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                    title: SizedBox(
                                                                        width: screenWidth * 0.9,
                                                                        child: Image.network(
                                                                          postsUrlList[startIndex + index]
                                                                              .postUrl!,
                                                                          width:
                                                                              screenWidth * 0.8,
                                                                        )));
                                                              });
                                                        },
                                                        child: Image.network(
                                                          postsUrlList[
                                                                  startIndex +
                                                                      index]
                                                              .postUrl!,
                                                          height: 100,
                                                        ),
                                                      ),
                                                      subtitle: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          (loggedUser!.userToken ==
                                                                  user!
                                                                      .userToken)
                                                              ? TextFormField(
                                                                  controller: _caption![
                                                                      startIndex +
                                                                          index],
                                                                  decoration: InputDecoration(
                                                                      hintText: postsUrlList[startIndex + index].caption == ""
                                                                          ? 'Touch to Change Caption'
                                                                          : postsUrlList[startIndex + index]
                                                                              .caption,
                                                                      hintMaxLines:
                                                                          100,
                                                                      hintStyle: TextStyle(
                                                                          color: colorScheme
                                                                              .primaryColor,
                                                                          fontFamily: fonts
                                                                              .accentFont,
                                                                          fontSize:
                                                                              10,
                                                                          overflow:
                                                                              TextOverflow.ellipsis)),
                                                                  onChanged:
                                                                      (string) async {
                                                                    await _captionChange(
                                                                        startIndex +
                                                                            index,
                                                                        _caption![startIndex +
                                                                                index]
                                                                            .text);
                                                                  },
                                                                )
                                                              : (postsUrlList[startIndex +
                                                                              index]
                                                                          .caption !=
                                                                      "")
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Text(
                                                                        postsUrlList[startIndex +
                                                                                index]
                                                                            .caption,
                                                                        style: TextStyle(
                                                                            color:
                                                                                colorScheme.primaryColorVariant1,
                                                                            fontFamily: fonts.randomFont,
                                                                            fontSize: 20),
                                                                      ),
                                                                    )
                                                                  : const SizedBox(
                                                                      height: 0,
                                                                      width: 0,
                                                                    ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .favorite,
                                                                  color: postsUrlList[startIndex +
                                                                              index]
                                                                          .likes
                                                                          .contains(loggedUser!
                                                                              .userToken!)
                                                                      ? colorScheme
                                                                          .primaryColorVariant2
                                                                      : Colors
                                                                          .grey,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  bool likedCurrent = postsUrlList[
                                                                          startIndex +
                                                                              index]
                                                                      .likes
                                                                      .contains(
                                                                          loggedUser!
                                                                              .userToken);
                                                                  likedCurrent
                                                                      ? Post.unlikePost(
                                                                          postsUrlList[startIndex + index]
                                                                              .postUrl!,
                                                                          loggedUser!
                                                                              .userToken!)
                                                                      : Post.likePost(
                                                                          postsUrlList[startIndex + index]
                                                                              .postUrl!,
                                                                          loggedUser!
                                                                              .userToken!);
                                                                  setState(() {
                                                                    likedCurrent
                                                                        ? postsUrlList[startIndex +
                                                                                index]
                                                                            .likes
                                                                            .remove(loggedUser!
                                                                                .userToken!)
                                                                        : postsUrlList[startIndex +
                                                                                index]
                                                                            .likes
                                                                            .add(loggedUser!.userToken!);
                                                                  });
                                                                },
                                                              ),
                                                              Text(
                                                                postsUrlList[
                                                                        startIndex +
                                                                            index]
                                                                    .likes
                                                                    .length
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        fonts
                                                                            .bodyFont,
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                            ],
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        "Comments",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              colorScheme.accentColor,
                                                                          fontFamily:
                                                                              fonts.headingFont,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    content:
                                                                        StatefulBuilder(
                                                                      builder: (BuildContext
                                                                              context,
                                                                          StateSetter
                                                                              setState) {
                                                                        return SizedBox(
                                                                          width:
                                                                              double.maxFinite,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Expanded(
                                                                                child: ListView.builder(
                                                                                  itemCount: postsUrlList[startIndex + index].comments.length,
                                                                                  itemBuilder: (context, commentIndex) {
                                                                                    final comment = postsUrlList[startIndex + index].comments[commentIndex];
                                                                                    Timestamp time = comment['time'];

                                                                                    return ListTile(
                                                                                      title: Text(
                                                                                        comment['comments'],
                                                                                        style: TextStyle(fontFamily: fonts.primaryFont, fontSize: 20),
                                                                                      ),
                                                                                      subtitle: Text(
                                                                                        userTokenMap[comment['userToken']] + "\n" + _format(time),
                                                                                        style: TextStyle(fontFamily: fonts.secondaryFont, fontSize: 10),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                alignment: Alignment.bottomCenter,
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: TextFormField(
                                                                                        controller: _commentText,
                                                                                        decoration: InputDecoration(
                                                                                          hintText: 'Enter Comment to Post',
                                                                                          fillColor: colorScheme.chatBubbleUserBackground,
                                                                                          filled: true,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    IconButton(
                                                                                      onPressed: () async {
                                                                                        await _addCommentToPost(startIndex + index, _commentText.text);
                                                                                        setState(() {
                                                                                          _commentText.clear();
                                                                                        });
                                                                                      },
                                                                                      icon: const Icon(
                                                                                        Icons.send,
                                                                                        size: 20,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
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
                                                                    .anotherFont,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                      ),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await loggedUser!
                                      .addFollowing(user!.userToken!);
                                  await user!
                                      .addFollower(loggedUser!.userToken!);
                                  setState(() {
                                    following = true;
                                    count = user!.following.length;
                                    isLoading = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.buttonColor),
                                child: Text(
                                  "Follow",
                                  style:
                                      TextStyle(color: colorScheme.buttonText),
                                ),
                              ),
                      ]),
                ),
              ),
            ),
    );
  }
}
