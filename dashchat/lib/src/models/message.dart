import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String userToken;
  Map<String, dynamic> messages = {};
  Message(this.userToken);
  Message.set(this.userToken, this.messages);

  Map<String, dynamic> _docReturn() {
    Map<String, dynamic> doc = {
      'userToken': userToken,
      'messages': messages,
    };
    return doc;
  }

  Map<String, dynamic> _messageDocs(
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
    messageCollection.add(_docReturn());
  }

  static Future<Message> getMessages(String userToken) async {
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

    messages[userTokenReceiver]
        .add(_messageDocs(userTokenSender, message, time));
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
    messages[userTokenSender].add(_messageDocs(userTokenSender, message, time));

    messageDocSnapshot = querySnapshot.docs.first;
    messageDocId = messageDocSnapshot.id;
    messageDocRef =
        FirebaseFirestore.instance.collection('messages').doc(messageDocId);
    await messageDocRef.update({
      'messages': messages,
    });
  }
}
