import 'package:dashchat/src/models/colors.dart';
import 'package:dashchat/src/models/fonts.dart';
import 'package:dashchat/src/models/message.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:dashchat/src/screens/messaging.dart';
import 'package:flutter/material.dart';

class userMessage extends StatefulWidget {
  const userMessage({super.key});

  @override
  State<userMessage> createState() => _userMessageState();
}

class _userMessageState extends State<userMessage> {
  AppColorScheme colorScheme = AppColorScheme.defaultScheme();
  AppFonts fonts = AppFonts.defaultFonts();
  User? user;
  bool isLoading = true;
  // Message? message;
  // Map? userTokenMap;
  List<User> inbox = [];
  @override
  void initState() {
    super.initState();
    _set();
  }

  Future<void> _set() async {
    User user = await User.getCurrentUser();
    Map userTokenMap = await User.getUsernameMap();
    Message message = await Message.getMessages(user.userToken!);
    List<User> inbox = [];
    for (String key in message.messages.keys) {
      User u = await User.getByUsername(userTokenMap[key]);
      inbox.add(u);
    }
    setState(() {
      this.user = user;
      this.inbox = inbox;
      isLoading = false;
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'DashChat',
              style: TextStyle(
                fontSize: 30,
                color: colorScheme.textColorLight,
                fontFamily: fonts.headingFont,
              ),
            ),
            Container()
          ],
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new_sharp,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          isLoading
              ? SizedBox(
                  height: 0.7 * screenHeight,
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: inbox.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => messageScreen(
                                    loggedUser: user!,
                                    displayUser: inbox[index]),
                              ));
                        },
                        leading: CircleAvatar(
                            radius: 30.0,
                            backgroundColor: colorScheme.backgroundColor,
                            child: inbox[index].profileUrl == ""
                                ? const Icon(Icons.person, size: 40)
                                : ClipOval(
                                    child: Image.network(
                                    inbox[index].profileUrl,
                                    width: 60.0,
                                    height: 60.0,
                                    fit: BoxFit.cover,
                                  ))),
                        title: Text(
                          inbox[index].userName,
                          style: TextStyle(
                              color: colorScheme.textColorSecondary,
                              fontFamily: fonts.headingFont,
                              fontSize: 20),
                        ),
                        subtitle: Text(inbox[index].displayName,
                            style: TextStyle(
                                color: colorScheme.textColorAccent,
                                fontFamily: fonts.anotherFont,
                                fontSize: 10)),
                      );
                    },
                  ),
                )
        ],
      ),
    );
  }
}
