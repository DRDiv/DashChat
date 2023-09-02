import 'package:dashchat/src/models/stories.dart';
import 'package:flutter/material.dart';

import '../models/colors.dart';
import '../models/fonts.dart';
import '../models/user.dart';

class StoryPage extends StatefulWidget {
  final String userToken;
  final String currentToken;
  final List<Story> storyList;
  final int index;

  StoryPage({
    super.key,
    required this.userToken,
    required this.currentToken,
    required this.storyList,
    required this.index,
  });

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  Future<void> addView() async {
    if (widget.userToken != widget.currentToken)
      Story.addView(widget.storyList[widget.index].storyUrl!, widget.userToken);
  }

  void initState() {
    super.initState();
    addView();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    AppColorScheme colorScheme = AppColorScheme.defaultScheme();
    AppFonts fonts = AppFonts.defaultFonts();
    return Scaffold(
        body: GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          if (widget.index > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoryPage(
                  userToken: widget.userToken,
                  currentToken: widget.currentToken,
                  storyList: widget.storyList,
                  index: widget.index - 1,
                ),
              ),
            );
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } else if (details.primaryVelocity! < 0) {
          if (widget.index < widget.storyList.length - 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoryPage(
                  userToken: widget.userToken,
                  currentToken: widget.currentToken,
                  storyList: widget.storyList,
                  index: widget.index + 1,
                ),
              ),
            );
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      },
      child: Stack(
        // Use Stack to overlay the image with a view
        children: [
          Image.network(
            widget.storyList[widget.index].storyUrl!,
            width: screenWidth,
            height: screenHeight,
            fit: BoxFit.cover,
          ),
          Positioned(
            // Positioned widget for the overlay view
            top: screenHeight * 0.9,

            child: (widget.currentToken == widget.userToken)
                ? IconButton(
                    icon: Icon(Icons.remove_red_eye),
                    onPressed: () async {
                      Story currentStory = widget.storyList[widget.index];
                      List<User> userViews = [];
                      for (String token in currentStory.views) {
                        userViews.add(await User.get(token));
                      }
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: SizedBox(
                                height: screenHeight * 0.3,
                                width: screenWidth * 0.7,
                                child: (userViews.length == 0)
                                    ? Center(child: Text("No Views Yet"))
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: userViews.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            leading: CircleAvatar(
                                                radius: 30.0,
                                                child: userViews[index]
                                                            .profileUrl ==
                                                        ""
                                                    ? const Icon(Icons.person,
                                                        size: 40)
                                                    : ClipOval(
                                                        child: Image.network(
                                                        userViews[index]
                                                            .profileUrl,
                                                        width: 60.0,
                                                        height: 60.0,
                                                        fit: BoxFit.cover,
                                                      ))),
                                            title: Text(
                                              userViews[index].userName,
                                              style: TextStyle(
                                                  color: colorScheme
                                                      .textColorSecondary,
                                                  fontFamily: fonts.headingFont,
                                                  fontSize: 20),
                                            ),
                                            subtitle: Text(
                                                userViews[index].displayName,
                                                style: TextStyle(
                                                    color: colorScheme
                                                        .textColorAccent,
                                                    fontFamily:
                                                        fonts.anotherFont,
                                                    fontSize: 10)),
                                          );
                                        },
                                      ),
                              ),
                            );
                          });
                    },
                    color: Colors.white,
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
          ),
        ],
      ),
    ));
  }
}
