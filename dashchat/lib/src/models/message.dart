import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashchat/src/models/user.dart';

class Message {
  String userToken;
  Map<String, dynamic> messages = {};
  Message(this.userToken) {}
  Map<String, dynamic> docReturn() {
    Map<String, dynamic> doc = {
      'userToken': this.userToken,
      'messages': this.messages,
    };
    return doc;
  }

  Message.set(this.userToken, this.messages) {}
  Map<String, dynamic> messageDocs(
      String sender, String message, Timestamp time) {
    Map<String, dynamic> docs = {
      'sender': sender,
      'message': message,
      'time': time,
    };
    return docs;
  }

  void registerDm() {
    final CollectionReference messageCollection =
        FirebaseFirestore.instance.collection('messages');
    messageCollection.add(docReturn());
  }

  static Future<Message> getMessage(String userToken, String findToken) async {
    final CollectionReference messageCollection =
        FirebaseFirestore.instance.collection('messages');
    Query messageQuery =
        messageCollection.where('userToken', isEqualTo: userToken);
    QuerySnapshot querySnapshot = await messageQuery.get();

    Message message = Message.set(userToken, querySnapshot.docs[0]['messages']);
    return message;
  }

  Future<void> addMessage(String message, String userTokenSender,
      String userTokenReceiver, Timestamp time) async {
    final CollectionReference messageCollection =
        FirebaseFirestore.instance.collection('messages');
    Query messageQuery =
        messageCollection.where('userToken', isEqualTo: userTokenSender);
    QuerySnapshot querySnapshot = await messageQuery.get();
    Map<String, dynamic> messages = querySnapshot.docs[0]['messages'];
    if (messages[userTokenReceiver] == null) {
      messages[userTokenReceiver] = [];
    }
    ;
    messages[userTokenReceiver]
        .add(messageDocs(userTokenSender, message, time));
    this.messages = messages;
    DocumentSnapshot messageDocSnapshot = querySnapshot.docs.first;
    String messageDocId = messageDocSnapshot.id;

    DocumentReference messageDocRef =
        FirebaseFirestore.instance.collection('messages').doc(messageDocId);
    await messageDocRef.update({
      'messages': messages,
    });
    messageQuery =
        messageCollection.where('userToken', isEqualTo: userTokenReceiver);
    querySnapshot = await messageQuery.get();
    messages = querySnapshot.docs[0]['messages'];
    if (messages[userTokenSender] == null) {
      messages[userTokenSender] = [];
    }
    messages[userTokenSender].add(messageDocs(userTokenSender, message, time));

    messageDocSnapshot = querySnapshot.docs.first;
    messageDocId = messageDocSnapshot.id;
    messageDocRef =
        FirebaseFirestore.instance.collection('messages').doc(messageDocId);
    await messageDocRef.update({
      'messages': messages,
    });
  }
}
