import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/message.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final Timestamp time;
  MessageBubble(
      {required this.message, required this.isMe, required this.time});
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

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isMe
              ? AppColorScheme.defaultScheme().chatBubbleUserBackground
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              format(time),
              style: TextStyle(fontSize: 5),
            )
          ],
        ),
      ),
    );
  }
}

class messageScreen extends StatefulWidget {
  User loggedUser;
  User displayUser;

  messageScreen(
      {super.key, required this.loggedUser, required this.displayUser});

  @override
  State<messageScreen> createState() => _messageScreenState();
}

class _messageScreenState extends State<messageScreen> {
  AppColorScheme colorScheme = AppColorScheme.defaultScheme();
  AppFonts fonts = AppFonts.defaultFonts();
  List messages = [];
  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _getMessages();
  }

  Future<void> _getMessages() async {
    Message messageObj = await Message.getMessage(
        widget.loggedUser.userToken!, widget.displayUser.userToken!);
    setState(() {
      this.messages = messageObj.messages[widget.displayUser.userToken];
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.accentColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DashChat',
              style: TextStyle(
                fontSize: 30,
                color: colorScheme.textColorLight,
                fontFamily: fonts.headingFont,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              String messageText = messages[index]['message'];
                              bool isMe = messages[index]['sender'] ==
                                  widget.loggedUser.userToken;
                              return MessageBubble(
                                  message: messageText,
                                  isMe: isMe,
                                  time: messages[index]['time']);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          BottomAppBar(
            height: 80,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter Message',
                        fillColor: colorScheme.chatBubbleUserBackground,
                        filled: true,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      String message = _messageController.text;
                      Timestamp time = Timestamp.now();
                      setState(() {
                        _messageController.clear();
                      });
                      Message messageObject =
                          Message(widget.loggedUser.userToken!);
                      await messageObject.addMessage(
                          message,
                          widget.loggedUser.userToken!,
                          widget.displayUser.userToken!,
                          time);
                      setState(() {
                        messages.add({
                          'sender': widget.loggedUser.userToken!,
                          'message': message,
                          'time': time,
                        });
                      });
                    },
                    icon: Icon(
                      Icons.send,
                      size: 20,
                      color: colorScheme.buttonColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
