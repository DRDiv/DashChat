import 'package:dashchat/src/models/stories.dart';
import 'package:flutter/material.dart';

class StoryPage extends StatefulWidget {
  final String username;
  final List<Story> storyList;
  final int index;

  StoryPage({
    Key? key,
    required this.username,
    required this.storyList,
    required this.index,
  });

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swiped from left to right (previous story)
            if (widget.index > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryPage(
                    username: widget.username,
                    storyList: widget.storyList,
                    index: widget.index - 1,
                  ),
                ),
              );
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          } else if (details.primaryVelocity! < 0) {
            // Swiped from right to left (next story)
            if (widget.index < widget.storyList.length - 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryPage(
                    username: widget.username,
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
        child: Image.network(
          widget.storyList[widget.index].storyUrl!,
          width: screenWidth,
          height: screenHeight,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
