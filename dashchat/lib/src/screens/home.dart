import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/posts.dart';
import 'package:dashchat/src/models/stories.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:dashchat/src/screens/story.dart';
import 'package:dashchat/src/screens/userMessage.dart';
import 'package:dashchat/src/screens/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../database/commands.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback callback;
  const HomeScreen({super.key, required this.callback});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _users = List.empty();
  Map<String, List<Story>> storiesList = {};
  User? loggedUser;
  String _searchText = '';
  List<Post> postList = [];
  bool isLoading = true;
  Map<String, String> profilePicture = {};
  TextEditingController _commentText = TextEditingController();
  Map? userTokenMap;
  void initState() {
    super.initState();
    setPostList();
    setStoryList();
  }

  String format(Timestamp timestamp) {
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

  Future<void> _addCommentToPost(int postIndex, String comment) async {
    Timestamp time = Timestamp.now();

    await Post.addComment(
        postList[postIndex].postUrl!, comment, loggedUser!.userToken!, time);

    setState(() {
      postList[postIndex].comments.add({
        'userToken': loggedUser!.userToken,
        'comments': comment,
        'time': time,
      });
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      postList = [];

      userTokenMap = {};
      storiesList = {};
    });

    await setPostList();
    await setStoryList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> setStoryList() async {
    User currentUser = await User.getCurrentUser();
    Map<String, List<Story>> storiesList = {};
    List<Story> storyTemp = [];
    for (String story in currentUser.stories) {
      Story temp = await Story.getStory(story);
      storyTemp.add(temp);
    }
    setState(() {
      profilePicture[currentUser.userToken!] = currentUser.profileUrl;
    });
    storiesList[currentUser.userToken!] = storyTemp;
    List tokenFollowing = currentUser.following;

    for (String u in tokenFollowing) {
      User displayUser = await User.get(u);
      setState(() {
        profilePicture[displayUser.userToken!] = displayUser.profileUrl;
      });
      storyTemp = [];
      for (String story in displayUser.stories) {
        Story temp = await Story.getStory(story);
        storyTemp.add(temp);
      }
      storiesList[u] = storyTemp;
    }

    setState(() {
      this.storiesList = storiesList;
    });
  }

  Future<void> setPostList() async {
    User currentUser = await User.getCurrentUser();
    for (String post in currentUser.posts) {
      Post postUser = await Post.getPost(post);
      setState(() {
        postList.add(postUser);
      });
    }
    List tokenFollowing = currentUser.following;
    List<Post> postListAll = await Post.getAllPost();
    for (Post post in postListAll) {
      if (tokenFollowing.contains(post.userToken)) {
        User niceUser = await User.get(post.userToken!);
        String profilePic = niceUser.profileUrl;

        setState(() {
          postList.add(post);

          profilePicture[post.userToken!] = profilePic;
        });
      }
    }
    Map usertokenmap = await User.getUsernameMap();
    setState(() {
      loggedUser = currentUser;
      userTokenMap = usertokenmap;
      isLoading = false;
      postList.sort((a, b) => b.time!.compareTo(a.time!));
    });
  }

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

  Future _pickImageCameraStory(ImageSource source) async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = FileImage(File(pickedImage.path));
      });
    }
    Story story = Story();
    await story.addStory(_image!);
    User user = await User.getCurrentUser();
    await user.addStory(story.storyUrl!);
  }

  Future _pickImageGalleryStory(ImageSource source) async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = FileImage(File(pickedImage.path));
      });
    }
    Story story = Story();
    await story.addStory(_image!);
    User user = await User.getCurrentUser();
    await user.addStory(story.storyUrl!);
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
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => userMessage()));
                      },
                      icon: Icon(
                        Icons.message,
                        color: colorScheme.chatBubbleOtherUserBackground,
                      )),
                ],
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: isLoading
              ? SizedBox(
                  height: screenHeight * 0.7,
                  width: screenWidth,
                  child: Center(child: CircularProgressIndicator()))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        for (String token in storiesList.keys)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => StoryPage(
                                          username: userTokenMap![token],
                                          storyList: storiesList[token]!,
                                          index: 0))));
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                      radius: 30.0,
                                      backgroundColor:
                                          colorScheme.backgroundColor,
                                      child: profilePicture[token] == ""
                                          ? const Icon(Icons.person, size: 30)
                                          : ClipOval(
                                              child: Image.network(
                                              profilePicture[token]!,
                                              width: 60.0,
                                              height: 60.0,
                                              fit: BoxFit.cover,
                                            ))),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  userTokenMap![token],
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ]),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: postList.length,
                        itemBuilder: (context, rowIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colorScheme.buttonColor,
                                  width: 1.0,
                                ),
                              ),
                              child: ListTile(
                                leading: Column(
                                  children: [
                                    CircleAvatar(
                                        radius: 20.0,
                                        backgroundColor:
                                            colorScheme.backgroundColor,
                                        child: profilePicture[postList[rowIndex]
                                                    .userToken] ==
                                                ""
                                            ? const Icon(Icons.person, size: 20)
                                            : ClipOval(
                                                child: Image.network(
                                                profilePicture[
                                                    postList[rowIndex]
                                                        .userToken]!,
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover,
                                              ))),
                                    Text(userTokenMap![
                                        postList[rowIndex].userToken]),
                                  ],
                                ),
                                title: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              title: SizedBox(
                                                  width: screenWidth * 0.9,
                                                  child: Image.network(
                                                    postList[rowIndex].postUrl!,
                                                    width: screenWidth * 0.8,
                                                  )));
                                        });
                                  },
                                  child: Image.network(
                                    postList[rowIndex].postUrl!,
                                    height: 300,
                                  ),
                                ),
                                subtitle: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(format(postList[rowIndex].time!)),
                                    (postList[rowIndex].caption != "")
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              postList[rowIndex].caption,
                                              style: TextStyle(
                                                  color: colorScheme
                                                      .primaryColorVariant1,
                                                  fontFamily: fonts.randomFont,
                                                  fontSize: 20),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 0,
                                            width: 0,
                                          ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.favorite,
                                                    color: postList[rowIndex]
                                                            .likes
                                                            .contains(
                                                                loggedUser!
                                                                    .userToken!)
                                                        ? colorScheme
                                                            .primaryColorVariant2
                                                        : Colors.grey,
                                                  ),
                                                  onPressed: () async {
                                                    bool likedCurrent =
                                                        postList[rowIndex]
                                                            .likes
                                                            .contains(
                                                                loggedUser!
                                                                    .userToken);
                                                    await likedCurrent
                                                        ? Post.unlikePost(
                                                            postList[rowIndex]
                                                                .postUrl!,
                                                            loggedUser!
                                                                .userToken!)
                                                        : Post.likePost(
                                                            postList[rowIndex]
                                                                .postUrl!,
                                                            loggedUser!
                                                                .userToken!);
                                                    setState(() {
                                                      likedCurrent
                                                          ? postList[rowIndex]
                                                              .likes
                                                              .remove(loggedUser!
                                                                  .userToken!)
                                                          : postList[rowIndex]
                                                              .likes
                                                              .add(loggedUser!
                                                                  .userToken!);
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  postList[rowIndex]
                                                      .likes
                                                      .length
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontFamily:
                                                          fonts.bodyFont,
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ],
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
                                                            fonts.headingFont,
                                                      ),
                                                    ),
                                                  ),
                                                  content: StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return Container(
                                                        width: double.maxFinite,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Expanded(
                                                              child: ListView
                                                                  .builder(
                                                                itemCount: postList[
                                                                        rowIndex]
                                                                    .comments
                                                                    .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        commentIndex) {
                                                                  final comment =
                                                                      postList[rowIndex]
                                                                              .comments[
                                                                          commentIndex];
                                                                  Timestamp
                                                                      time =
                                                                      comment[
                                                                          'time'];

                                                                  return ListTile(
                                                                    title: Text(
                                                                      comment[
                                                                          'comments'],
                                                                      style: TextStyle(
                                                                          fontFamily: fonts
                                                                              .primaryFont,
                                                                          fontSize:
                                                                              20),
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      userTokenMap![comment[
                                                                              'userToken']] +
                                                                          "\n" +
                                                                          format(
                                                                              time),
                                                                      style: TextStyle(
                                                                          fontFamily: fonts
                                                                              .secondaryFont,
                                                                          fontSize:
                                                                              10),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _commentText,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        hintText:
                                                                            'Enter Comment to Post',
                                                                        fillColor:
                                                                            colorScheme.chatBubbleUserBackground,
                                                                        filled:
                                                                            true,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await _addCommentToPost(
                                                                          rowIndex,
                                                                          _commentText
                                                                              .text);
                                                                      setState(
                                                                          () {
                                                                        _commentText
                                                                            .clear();
                                                                      });
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .send,
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
                                              color: colorScheme.primaryColor,
                                              fontFamily: fonts.anotherFont,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
                                                            showDialog(
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                    content: Container(
                                                                        height: screenHeight * 0.20,
                                                                        width: screenWidth * 0.8,
                                                                        child: StatefulBuilder(
                                                                          builder:
                                                                              (context, setState) {
                                                                            return _isLoading
                                                                                ? Center(child: CircularProgressIndicator())
                                                                                : Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          IconButton(
                                                                                            icon: Icon(Icons.arrow_back),
                                                                                            onPressed: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      ElevatedButton(
                                                                                        onPressed: () async {
                                                                                          setState(() {
                                                                                            _isLoading = true;
                                                                                          });
                                                                                          await _pickImageGallery(ImageSource.gallery);
                                                                                          setState(() {
                                                                                            _isLoading = false;
                                                                                            Navigator.pop(context);
                                                                                          });
                                                                                        },
                                                                                        child: const Text('Pick Photo from Gallery'),
                                                                                      ),
                                                                                      ElevatedButton(
                                                                                        onPressed: () async {
                                                                                          setState(() {
                                                                                            _isLoading = true;
                                                                                          });
                                                                                          await _pickImageCamera(ImageSource.gallery);
                                                                                          setState(() {
                                                                                            _isLoading = false;
                                                                                            Navigator.pop(context);
                                                                                          });
                                                                                        },
                                                                                        child: const Text('Pick Photo from Camera'),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                          },
                                                                        )));
                                                              },
                                                            );
                                                          },
                                                          child: const Text(
                                                              'Add Post'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            showDialog(
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                    content: Container(
                                                                        height: screenHeight * 0.20,
                                                                        width: screenWidth * 0.8,
                                                                        child: StatefulBuilder(
                                                                          builder:
                                                                              (context, setState) {
                                                                            return _isLoading
                                                                                ? Center(child: CircularProgressIndicator())
                                                                                : Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          IconButton(
                                                                                            icon: Icon(Icons.arrow_back),
                                                                                            onPressed: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      ElevatedButton(
                                                                                        onPressed: () async {
                                                                                          setState(() {
                                                                                            _isLoading = true;
                                                                                          });
                                                                                          await _pickImageGalleryStory(ImageSource.gallery);
                                                                                          setState(() {
                                                                                            _isLoading = false;
                                                                                            Navigator.pop(context);
                                                                                          });
                                                                                        },
                                                                                        child: const Text('Pick Photo from Gallery'),
                                                                                      ),
                                                                                      ElevatedButton(
                                                                                        onPressed: () async {
                                                                                          setState(() {
                                                                                            _isLoading = true;
                                                                                          });
                                                                                          await _pickImageCameraStory(ImageSource.gallery);
                                                                                          setState(() {
                                                                                            _isLoading = false;
                                                                                            Navigator.pop(context);
                                                                                          });
                                                                                        },
                                                                                        child: const Text('Pick Photo from Camera'),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                          },
                                                                        )));
                                                              },
                                                            );
                                                          },
                                                          child: const Text(
                                                              'Add Story'),
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
                                                          : 'Text Do Not Match',
                                                      hintText:
                                                          'Type "Confirm" (Case Insensitive)',
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
                                                        if (_confirmPassword
                                                                .text
                                                                .toLowerCase() ==
                                                            "Confirm"
                                                                .toLowerCase()) {
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
